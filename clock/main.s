    .include "config.inc"
    .include "util.inc"
    .include "segment.inc"
    .include "timer1.inc"

    .include "simple_table.s"
    .include "keypad4x4.s"

    .def  state = r2

    .equ  STATE_NORMAL = 0
    .equ  STATE_SET_TIME = 1

    .def  tick = r23

;;; ---------------------------------
;;; [ ===== MACRO DEFINITIONS ===== ]
;;; ---------------------------------

.macro setup_digits
    ldw   28,   digits

    ldist r16,  0x00, Y+
    ldist r16,  0x59, Y+
    ldist r16,  0x00, Y+
    ldist r16,  0x23, Y+
.endmacro

.macro setup_segment_table
    ldw   28,   segment_table

    ldist r16,  SEG_CHAR_0, Y+
    ldist r16,  SEG_CHAR_1, Y+
    ldist r16,  SEG_CHAR_2, Y+
    ldist r16,  SEG_CHAR_3, Y+
    ldist r16,  SEG_CHAR_4, Y+
    ldist r16,  SEG_CHAR_5, Y+
    ldist r16,  SEG_CHAR_6, Y+
    ldist r16,  SEG_CHAR_7, Y+
    ldist r16,  SEG_CHAR_8, Y+
    ldist r16,  SEG_CHAR_9, Y+
    ldist r16,  SEG_CHAR_NONE, Y
.endmacro

.macro setup_timer1
    ;;; WGM1 = 0b0100
    ;;; clear timer on compare (CTC) mode
    ;;; when TCNT1 is equal to OCR1A TCNT1 is reset to zero
    ;;; CS1 = 0b101
    ;;; prescaler 1024
    ldi   r16,    (1 << WGM12) | (1 << CS12) | (1 << CS10)
    sts   TCCR1B, r16
    ;;; reset TCNT1 to zero
    sts   TCNT1H, zero
    sts   TCNT1L, zero
    ;;; set OCR1A to delay time
    ldi   r17,    HIGH(DELAY_TIME)
    ldi   r16,    LOW(DELAY_TIME)
    sts   OCR1AH, r17
    sts   OCR1AL, r16
.endmacro


.macro clock_tick
    sbis  TIFR1, OCF1A
    rjmp  loop

    sbi   TIFR1, OCF1A

    inc   tick
    cpi   tick, 60
    brne  loop
    clr   tick
.endmacro


.macro clock_update
    clr   r16
    ldw   28,   digits

update:
    ld    r17,  Y
    ldd   r18,  Y+1

    cpse  r17,  r18
    rjmp  update_increment

    st    Y,    zero
    rjmp  update_continue

update_increment:
    mov   r18,  r17
    andi  r18,  0x0F
    cpi   r18,  9
    brne  update_increment_low

    andi  r17,  0xF0

    swap  r17
    mov   r18,  r17
    andi  r18,  0x0F
    cpi   r18,  9
    brne  update_increment_high

    andi  r17,  0xF0

    swap  r17
    st    Y,    r17
    rjmp  update_continue

update_increment_high:
    inc   r17
    swap  r17
    st    Y,    r17
    rjmp  loop

update_increment_low:
    inc   r17
    st    Y,    r17
    rjmp  loop

update_continue:
    adiw  r28,  2

    inc   r16
    cpi   r16,  NUM_DIGITS / 2
    brne update
.endmacro


;;; -------------------------
;;; [ ===== MAIN CODE ===== ]
;;; -------------------------

    .cseg

_start:
    clr   zero
    clr   tick

    setup_digits
    setup_segment_table
    setup_timer1

    setup_keymap keymap
    add_row '1', '2', '3', 'A'
    add_row '4', '5', '6', 'B'
    add_row '7', '8', '9', 'C'
    add_row '*', '0', '#', 'D'

    ser   r16
    out   DDRD, r16
    out   DDRB, r16

    clr   r16
    out   PRTD, r16
    out   PRTB, r16

    ldi   r25,  HIGH(keymap)
    ldi   r24,  LOW(keymap)
    call  keypad_init

    ldi   r16,  STATE_NORMAL
    mov   state, r16

loop:
    rcall clock_display

    ;;; not sure if a jump table is better here
    mov   r16,  state
match_state:
    cpi   r16,  STATE_NORMAL
    breq  case_normal
    cpi   r16,  STATE_SET_TIME
    breq  case_set_time
    ;;; add default case to handle undefined states?

case_normal:
    call  keypad_update
    ldi   r24,  KEY_ASTERISK
    call  keypad_just_pressed
    tst   r24
    breq  case_normal_continue

    ldi   r16,   STATE_SET_TIME
    mov   state, r16
    rjmp  loop

case_normal_continue:
    clock_tick
    
    clock_update

    rjmp  loop

case_set_time:
    ldi   r16,   (10 << 4) | 10
    ldi   r29,   HIGH(digits)
    ldi   r28,   LOW(digits)
    st    Y,     r16
    std   Y+2,   r16
    ldi   r17,   2

case_set_time_loop:
    ldi   r16,  (10 << 4) | 10

    rcall clock_display
    rcall keypad_update
    rcall keypad_any_just_pressed
    ldi   r22,   KEY_CODE
    rcall keypad_translate

    subi  r24,   '0'
    cpi   r24,   10
    brsh  case_set_time_loop

    andi  r16,   0xF0
    or    r16,   r24
    st    Y,     r16

case_set_time_digit_high:
    rcall clock_display
    rcall keypad_update
    rcall keypad_any_just_pressed
    ldi   r22,   KEY_CODE
    rcall keypad_translate

    subi  r24,   '0'
    cpi   r24,   10
    brsh  case_set_time_digit_high

    andi  r16,   0x0F
    swap  r24
    or    r16,   r24
    st    Y,     r16

    adiw  r28,   2

    dec   r17
    brne  case_set_time_loop

    ldi   r16,   STATE_NORMAL
    mov   state, r16

    rjmp  loop


;;; -------------------------
;;; [ ===== FUNCTIONS ===== ]
;;; -------------------------

clock_display:
    push  r17
    push  r16

    push  r29
    push  r28

    ldi   r29,  HIGH(digits)
    ldi   r28,  LOW(digits)

    ldi   r16,  0b0111

    in    r19,  PRTB
    andi  r19,  0xF0
display:
    mov   r17,  r19
    or    r17,  r16
    out   PRTB, r17

    ld    r17,  Y
    adiw  r28,  2

    mov   r24,  r17
    andi  r24,  0x0F
    rcall load_segment
    out   PRTD, r24

    rcall delay

    lsr   r16
    ori   r16,  0b1000

    mov   r18,  r19
    or    r18,  r16
    out   PRTB, r18

    mov   r24,  r17
    swap  r24
    andi  r24,  0x0F
    rcall load_segment
    out   PRTD, r24

    rcall delay

    lsr   r16
    ori   r16,  0b1000

    cpi   r16,  0x0F
    brne  display

    pop   r28
    pop   r29

    pop   r16
    pop   r17

    ret


;;; r24 -> index to load
load_segment:
    push  r31
    push  r30

    ldi   r31,   HIGH(segment_table)
    ldi   r30,   LOW(segment_table)
    add   r30,   r24
    adc   r31,   zero
    ld    r24,  Z

    pop   r30
    pop   r31

    ret


delay:
    push   r16

    ser    r16
delay_loop:
    dec    r16
    brne   delay_loop

    pop    r16
    ret


    .equ DELAY_TIME = 15625
    .equ NUM_DIGITS = 4


    .dseg
_data_start:
    .equ DATA_START = _data_start

digits:
    .byte 4

segment_table:
    .byte 11

keymap:
    .byte 16
_data_end:
    .equ DATA_END = _data_end

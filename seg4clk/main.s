    .include "config.inc"
    .include "segment.inc"
    .include "timer1.inc"

    .def  zero = r0
    .def  retv = r1
    .def  nine = r20
    .def  tick = r21

.macro ldist
    ldi @0, @1
    st  @2, @0
.endmacro

_start:
    clr   zero
    clr   tick
    ldi   nine, 9

    ldi   r26,  LOW(DATA_START)
    ldi   r27,  HIGH(DATA_START)
    ;;; setup digits
    st    X+,   zero
    ldist r16,  0x59, X+
    st    X+,   zero
    ldist r16,  0x23, X+
    ;;; setup segment table
    ldist r16,  SEG_0, X+
    ldist r16,  SEG_1, X+
    ldist r16,  SEG_2, X+
    ldist r16,  SEG_3, X+
    ldist r16,  SEG_4, X+
    ldist r16,  SEG_5, X+
    ldist r16,  SEG_6, X+
    ldist r16,  SEG_7, X+
    ldist r16,  SEG_8, X+
    ldist r16,  SEG_9, X+

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

    ser   r16
    out   DDRD, r16
    out   DDRC, r16
    out   DDRB, r16

    ldi   r26,  LOW(segment_table)
    ldi   r27,  HIGH(segment_table)

loop:
    ldi   r28,  LOW(digits)
    ldi   r29,  HIGH(digits)
    ldi   r16,  ~(1 << (NUM_DIGITS - 1))

write:
    out   PRTB, r16

    ld    r17,  Y
    adiw  r28,  2

    mov   r18,  r17
    andi  r18,  0x0F
    rcall load_segment

    out   PRTD, retv

    lsr   r16

    rcall delay

    out   PRTB, r16

    mov   r18,  r17
    swap  r18
    andi  r18,  0x0F
    rcall load_segment

    out   PRTD, retv

    lsr   r16

    rcall delay

    sbrc  r16,  4
    rjmp  write

    sbis  TIFR1, OCF1A
    jmp   loop

    sbi   TIFR1, OCF1A

    inc   tick
    cpi   tick,  60
    brne  loop
    clr   tick
    
    clr   r16
    ldi   r28,  LOW(digits)
    ldi   r29,  HIGH(digits)

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
    cpse  r18,  nine
    rjmp  update_increment_low

    andi  r17,  0xF0

    swap  r17
    mov   r18,  r17
    andi  r18,  0x0F
    cpse  r18,  nine
    rjmp  update_increment_high

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

    rjmp  loop


load_segment:
    movw  r30,  r26
    add   r30,  r18
    adc   r31,  zero
    ld    retv, Z
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
    .byte 10

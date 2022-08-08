    .ifndef _KEYPAD4x4_S_
    .define _KEYPAD4x4_S_

    .include "util.inc"

;;; attempts to follow the calling convention
;;; used by avr-gcc (described here: https://gcc.gnu.org/wiki/avr-gcc)

.macro setup_keymap
    ldw   26, @0
.endmacro

.macro add_row
    ldist r18, @0,  X+
    ldist r18, @1,  X+
    ldist r18, @2,  X+
    ldist r18, @3,  X+
.endmacro

;;; A0  -> ROW3
;;; A1  -> ROW2
;;; A2  -> ROW1
;;; A3  -> ROW0
;;; A4  -> COL2
;;; A5  -> COL3
;;; D12 -> COL1
;;; D13 -> COL0

;;; to read from keyboard:
;;; set rows to output and columns to input 
;;; pull selected row low and pull the rest of the rows high
;;; test the states of the column bits
;;; if a column is low then a button is pressed

    .cseg

;;; r25:r24 -> pointer to keymap
keypad_init:
    ldw   26,   keypad_descriptor
    st    X+,   r24
    st    X+,   r25

    ldi   r18,  20
keypad_init_zero:
    st    X+,   zero
    dec   r18
    brne  keypad_init_zero

    ret

    .equ COL_0 = 5
    .equ COL_1 = 4
    .equ COL_2 = 4
    .equ COL_3 = 5

_keypad_scan:
    lds   r19,  key_state_new+1
    lds   r18,  key_state_new
    sts   key_state_old+1, r19
    sts   key_state_old,   r18

    ldi   r18,  0b00001111
    ;;; set A0-A3 to output
    ;;; set A4-A5 to input
    out   DDRC, r18

    in    r19,  DDRB
    and   r19,  r18
    ;;; set D12-D13 to input
    out   DDRB, r19

    ;;; r18 = 0b11110000
    com   r18

    ;;; set A4-A5 and D12-D13 to input pullup
    in    r19,  PRTC
    or    r19,  r18
    out   PRTC, r19
    in    r19,  PRTB
    or    r19,  r18
    out   PRTB, r19

    clr   r25
    clr   r24

    ldi   r18,  0b0111
    ldi   r20,  0x0F
_keypad_scan_select_row:
    ;;; pull selected row low and the rest high
    in    r19,  PRTC
    andi  r19,  0xF0
    or    r19,  r18
    out   PRTC, r19

    ;;; add nops to allow hardware time to respond
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    lsr   r25
    ror   r24
    sbis  PINC, COL_3
    ori   r25,  1 << 7

    lsr   r25
    ror   r24
    sbis  PINC, COL_2
    ori   r25,  1 << 7

    lsr   r25
    ror   r24
    sbis  PINB, COL_1
    ori   r25,  1 << 7

    lsr   r25
    ror   r24
    sbis  PINB, COL_0
    ori   r25,  1 << 7

    ;;; shift one column
    lsr   r18
    ori   r18,  0b1000
    cpse  r18,  r20
    rjmp  _keypad_scan_select_row

    sts   key_state_new+1, r25
    sts   key_state_new,   r24

    ret

_keypad_update:
    ldw   26,  key_info

    ldi   r18, 16
    ;;; r23:r22 -> key_state_new
    lds   r23, key_state_new+1
    lds   r22, key_state_new
    ;;; r25:r24 -> key_state_old
    lds   r25, key_state_old+1
    lds   r24, key_state_old
    ;;; r25:r24 -> toggled keys
    eor   r25, r23
    eor   r24, r22
_keypad_update_loop:
    ld    r19, X

    bst   r22, 0
    bld   r19, KEY_PRESSED

    bst   r24, 0
    bld   r19, KEY_TOGGLED

    st    X+,  r19

    lsr   r23
    ror   r22
    lsr   r25
    ror   r24

    dec   r18
    brne  _keypad_update_loop

    ret

keypad_update:
    rcall _keypad_scan
    rcall _keypad_update
    ret

;;; TODO: perform bounds checking on input key codes
_keypad_load_key_info:
    ldw   26,  key_info
    add   r26, r24
    adc   r27, zero
    ld    r24,  X
    ret

;;; r24 -> key info
;;; return: r24 -> bool
;;; if KEY_PRESSED { true } else { false };
_keypad_is_pressed:
    bst   r24, KEY_PRESSED
    clr   r24
    bld   r24, 0
    ret

;;; r24 -> key info
;;; return: r24 -> bool
;;; if KEY_PRESSED && KEY_TOGGLED { true } else { false };
_keypad_just_pressed:
    clr   r18
    clr   r19
    bst   r24, KEY_PRESSED
    bld   r18, 0
    bst   r24, KEY_TOGGLED
    bld   r19, 0
    and   r18, r19
    mov   r24, r18
    ret

;;; r24 -> key info
;;; return: r24 -> bool
;;; if !KEY_PRESSED && KEY_TOGGLED { true } else { false };
_keypad_just_released:
    mov   r0,  r24
    clr   r24

    sbrc  r0,  KEY_PRESSED
    rjmp  keypad_just_released_end

    sbrs  r0,  KEY_TOGGLED
    rjmp  keypad_just_released_end

    inc   r24

keypad_just_released_end:
    ret

keypad_is_pressed:
    rcall _keypad_load_key_info
    rcall _keypad_is_pressed
    ret

keypad_just_pressed:
    rcall _keypad_load_key_info
    rcall _keypad_just_pressed
    ret

keypad_just_released:
    rcall _keypad_load_key_info
    rcall _keypad_just_released
    ret

;;; return: r24 -> key code (-1 on failure)
keypad_any_just_pressed:
    clr   r20
    ldw   26,  key_info
keypad_any_just_pressed_loop:
    ld    r24, X+
    rcall _keypad_just_pressed

    cpse  r24, zero
    rjmp  keypad_any_just_pressed_found

    inc   r20
    cpi   r20, 16
    brne  keypad_any_just_pressed_loop

    ser   r24

    ret

keypad_any_just_pressed_found:
    mov   r24, r20
    ret

;;; r24 -> key code or char to translate
;;; r22 -> mode
;;; return: r24 -> key code or char (returns -1 on failure)
keypad_translate:
    cpi   r22, KEY_CODE
    breq  keypad_translate_to_char

keypad_translate_to_key_code:
    mov   r0,  r24
    clr   r24
    ldi   r18, 16
    lds   r27, key_table_ptr+1
    lds   r26, key_table_ptr

keypad_translate_to_key_code_loop:
    ld    r19, X+
    cpse  r19, r0
    rjmp  keypad_translate_to_key_code_continue

    ret

keypad_translate_to_key_code_continue:
    inc   r24
    dec   r18
    brne  keypad_translate_to_key_code_loop

    rjmp  keypad_translate_fail

keypad_translate_to_char:
    cpi   r24, KEY_CODE_UNLIKELY
    brsh  keypad_translate_fail

    lds   r27, key_table_ptr+1
    lds   r26, key_table_ptr
    add   r26, r24
    adc   r27, zero
    ld    r24, X

    ret

keypad_translate_fail:
    ser   r24
    ret

    .dseg

keypad_descriptor:
key_table_ptr: .byte 2
key_info:      .byte 16
key_state:
key_state_new: .byte 2
key_state_old: .byte 2

    .equ KEY_CODE = 0
    .equ KEY_CHAR = 1

    .equ KEY_CODE_UNLIKELY = 0x10
    .equ KEY_1 = 0x00
    .equ KEY_2 = 0x01
    .equ KEY_3 = 0x02
    .equ KEY_A = 0x03
    .equ KEY_4 = 0x04
    .equ KEY_5 = 0x05
    .equ KEY_6 = 0x06
    .equ KEY_B = 0x07
    .equ KEY_7 = 0x08
    .equ KEY_8 = 0x09
    .equ KEY_9 = 0x0A
    .equ KEY_C = 0x0B
    .equ KEY_ASTERISK = 0x0C
    .equ KEY_0 = 0x0D
    .equ KEY_POUND = 0x0E
    .equ KEY_D = 0x0F

    .equ KEY_PRESSED = 0
    .equ KEY_TOGGLED = 1

    .endif

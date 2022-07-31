    .include "config.inc"
    .include "timer1.inc"

    .org  0x0000
_reset:
    jmp   _start
    .org  0x0016
_timer_1_compare_a:
    jmp   irq

    .org  0x0034
    .cseg

    .equ DELAY_TIME = 0xFF

_start:
    ldi   r16,    (1 << WGM12) | (1 << CS12) | (1 << CS10)
    sts   TCCR1B, r16

    ldi   r17,    HIGH(DELAY_TIME)
    ldi   r16,    LOW(DELAY_TIME)
    sts   OCR1AH, r17
    sts   OCR1AL, r16

    lds   r16,    TIMSK1
    ori   r16,    1 << OCIE1A
    sts   TIMSK1, r16

    clr   r16
    sts   TCNT1H, r16
    sts   TCNT1L, r16
    
loop:
    rjmp  loop

irq:
    nop
    nop
    nop
    reti

    .include "config.inc"
    .include "timer1.inc"

    .def zero = r0
    .def ones = r1
    .cseg

_start:
    clr   zero
    ser   r16
    mov   ones,    r16

    out   DDRB,    ones
    out   PRTB,    zero

    sts   TCCR1A,  zero
    ldi   r16,         (1 << WGM12) | (1 << CS12) | (1 << CS10)
    sts   TCCR1B,  r16

    .equ timer_delay = 15625

    ldi   r16,     high(timer_delay)
    sts   OCR1AH,  r16
    ldi   r16,     low(timer_delay)
    sts   OCR1AL,  r16

    sts   TCNT1H,  zero
    sts   TCNT1L,  zero

    ser    r16
loop:
    sbis   TIFR1,  OCF1A
    jmp    loop

    sbi    TIFR1,  OCF1A
    in     r17,    PRTB
    eor    r17,    r16
    out    PRTB,   r17

    rjmp   loop

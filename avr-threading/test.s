    .include "config.inc"
    .include "vector_table.s"
    .include "malloc.s"
    .include "threading.s"

    .cseg

_start:
    RESERVE_MAIN_STACK 0x80

    MALLOC_INIT

    .equ STACK_SPACE = 0x20

    call thread_state_init

    clr   r16
    out   PRTB, r16

    ser   r16
    out   PRTD, r16
    out   DDRB, r16
    out   DDRD, r16

    ldi   r17,  HIGH(blink)
    ldi   r16,  LOW(blink)
    ldi   r19,  HIGH(STACK_SPACE)
    ldi   r18,  LOW(STACK_SPACE)
    call  thread_create
    call  thread_run

    ldi   r16,  1 << 7
hang:
    in    r17,  PRTD
    eor   r17,  r16
    out   PRTD, r17
    rcall delay
    rjmp  hang

blink:
    ldi   r16,  1 << 5
loop:
    in    r17,  PRTB
    eor   r17,  r16
    out   PRTB, r17
    rcall delay
    rjmp  loop

delay:
    ldi   r17,  50
delay_outer:
    ser   r25
    ser   r24
delay_inner:
    sbiw  r24, 1
    brne  delay_inner
    dec   r17
    brne  delay_outer
    ret

    .dseg
_heap: .byte 2
_data_end:

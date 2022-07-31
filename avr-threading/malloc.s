    .ifndef _HEAP_S_
    .define _HEAP_S_

.macro MALLOC_INIT
    ldi  r17,     HIGH(_data_end)
    ldi  r16,     LOW(_data_end)

    cli

    sts  _heap+1, r17
    sts  _heap,   r16

    sei
.endmacro

;;; malloc memory from data section
;;; mallocd memory cannot be freed
;;; clobbers r30, r31
malloc:
    push  r29
    push  r28

    cli

    lds   r29,     _heap+1
    lds   r28,     _heap

    movw  r30,     r28

    add   r28,     r16
    adc   r29,     r17

    sts   _heap+1, r29
    sts   _heap,   r28

    sei

    pop   r28
    pop   r29

    ret

    .endif

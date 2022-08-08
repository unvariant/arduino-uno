    .ifndef _THREAD_S_
    .define _THREAD_S_

    .include "timer1.inc"

;;; struct Thread {
;;;     // could possible store relative offset to next
;;;     // Thread struct insead of direct pointer
;;;     next: Thread,   // 2
;;;     sp:   u16,      // 2
;;;     done: bool,     // 1
;;;     exit_code: u8   // 1
;;; }
;;; /// size: 6 bytes

    .equ NEXTL_OFFSET = 0
    .equ NEXTH_OFFSET = 1
    .equ SPL_OFFSET   = 2
    .equ SPH_OFFSET   = 3
    .equ DONE_OFFSET  = 4
    .equ EXITC_OFFSET = 5
    .equ THREAD_INFO_SIZE = 6

    .equ CONTEXT_SWITCH_OVERHEAD = 36

    .set THREAD_STACK_POOL = RAMEND - CONTEXT_SWITCH_OVERHEAD
    .set NUM_THREADS = 0


.macro RESERVE_MAIN_STACK
    .set THREAD_STACK_POOL = (THREAD_STACK_POOL - @0)
.endmacro


    .cseg


;;; args:   0
;;; return: none
;;; errors: none
;;; adds the main thread to the thread pool
thread_state_init:
    push  r31
    push  r30

    push  r17
    push  r16

    ldi   r31,     HIGH(THREAD_STACK_POOL)
    ldi   r30,     LOW(THREAD_STACK_POOL)

    sts   _thread_stack_bottom+1, r31
    sts   _thread_stack_bottom,   r30

    ldi   r17,     HIGH(THREAD_INFO_SIZE)
    ldi   r16,     LOW(THREAD_INFO_SIZE)
    call  malloc

    std   Z+NEXTH_OFFSET, r31
    std   Z+NEXTL_OFFSET, r30

    sts   _current_thread+1, r31
    sts   _current_thread,   r30

    sts   _thread_tail+1, r31
    sts   _thread_tail,   r30

setup_timer1:

    .set SWITCH_DELAY = 1562
    .set SWITCH_DELAY = 0xFFFF

    cli

    ldi   r16,    (1 << WGM12) | (1 << CS12) | (1 << CS10)
    sts   TCCR1B, r16
    ldi   r17,    HIGH(SWITCH_DELAY)
    ldi   r16,    LOW(SWITCH_DELAY)
    sts   OCR1AH, r17
    sts   OCR1AL, r16
    lds   r16,    TIMSK1
    ori   r16,    1 << OCIE1A
    sts   TIMSK1, r16
    clr   r16
    sts   TCNT1H, r16
    sts   TCNT1L, r16

    sei

    pop   r16
    pop   r17

    pop   r30
    pop   r31

    ret


;;; args:   4
;;;     - r16: LOW(FUNC_ADDR)
;;;     - r17: HIGH(FUNC_ADDR)
;;;     - r30: LOW(STACK_ADDR)
;;;     - r31: HIGH(STACK_ADDR)
;;; return: r31:r30 -> struct Thread, r29:r28 -> saved info
;;; errors: none
_thread_create:
    in    r26,     SPL
    in    r27,     SPH

    out   SPH,     r31
    out   SPL,     r30

    push  r16
    push  r17

    clr   r28
    ldi   r29,     33
_thread_create_clear:
    push  r28
    dec   r29
    brne  _thread_create_clear

    in    r28,     SPL
    in    r29,     SPH

    out   SPH,     r27
    out   SPL,     r26

;    sbiw  r30,     CONTEXT_SWITCH_OVERHEAD-1

;    clr   r28
;    ldi   r29,     33
;_thread_create_clear:
;    st    Z+,      r28
;    dec   r29
;    brne  _thread_create_clear

;    st    Z+,      r17
;    st    Z+,      r16

;    movw  r28,     r30
;    sbiw  r28,     CONTEXT_SWITCH_OVERHEAD+1
;    sbiw  r28,     CONTEXT_SWITCH_OVERHEAD

    ldi   r17,     HIGH(THREAD_INFO_SIZE)
    ldi   r16,     LOW(THREAD_INFO_SIZE)
    call  malloc

    std   Z+SPH_OFFSET, r29
    std   Z+SPL_OFFSET, r28

    ret


;;; args:   4
;;;     - r16: LOW(FUNC_ADDR)
;;;     - r17: HIGH(FUNC_ADDR)
;;;     - r18: STACK_SPACE
;;;     - r19: STACK_SPACE
;;; return: struct Thread
;;; errors: none
thread_create:
    push  r29
    push  r28

    push  r27
    push  r26

    cli

    lds   r31,      _thread_stack_bottom+1
    lds   r30,      _thread_stack_bottom
    rcall           _thread_create

    sub   r28,      r18
    sbc   r29,      r19

    sts   _thread_stack_bottom+1, r29
    sts   _thread_stack_bottom,   r28

    sei

    pop   r26
    pop   r27
    
    pop   r28
    pop   r29

    ret


thread_run:
    push  r29
    push  r28

    push  r27
    push  r26

    cli

    lds   r29,      _thread_tail+1
    lds   r28,      _thread_tail

    ;;; head = tail->next
    ldd   r27,      Y+NEXTH_OFFSET
    ldd   r26,      Y+NEXTL_OFFSET

    ;;; tail->next = new_thread
    std   Y+NEXTH_OFFSET, r31
    std   Y+NEXTL_OFFSET, r30

    ;;; new_thread->next = head
    std   Z+NEXTH_OFFSET, r27
    std   Z+NEXTL_OFFSET, r26

    ;;; tail = new_thread
    sts   _thread_tail+1, r31
    sts   _thread_tail,   r30

    sei

    pop   r26
    pop   r27

    pop   r28
    pop   r29

    ret


context_switch:
    cli

    push r31
    push r30
    push r29
    push r28
    push r27
    push r26
    push r25
    push r24
    push r23
    push r22
    push r21
    push r20
    push r19
    push r18
    push r17
    push r16
    push r15
    push r14
    push r13
    push r12
    push r11
    push r10
    push r9
    push r8
    push r7
    push r6
    push r5
    push r4
    push r3
    push r2
    push r1
    push r0

    in   r16,     SREG
    push r16

    ldi  r16,     1 << 0
    in   r17,     PRTC
    eor  r17,     r16
    out  PRTC,    r17

    lds  r31,     _current_thread+1
    lds  r30,     _current_thread

    in   r16,     SPL
    in   r17,     SPH
    std  Z+SPH_OFFSET, r17
    std  Z+SPL_OFFSET, r16

    ldd  r29,     Z+NEXTH_OFFSET
    ldd  r28,     Z+NEXTL_OFFSET

    sts  _current_thread+1, r29
    sts  _current_thread,   r28

    ldd  r17,     Y+SPH_OFFSET
    ldd  r16,     Y+SPL_OFFSET
    out  SPH,     r17
    out  SPL,     r16

    pop  r16
    out  SREG,    r16

    pop  r0
    pop  r1
    pop  r2
    pop  r3
    pop  r4
    pop  r5
    pop  r6
    pop  r7
    pop  r8
    pop  r9
    pop  r10
    pop  r11
    pop  r12
    pop  r13
    pop  r14
    pop  r15
    pop  r16
    pop  r17
    pop  r18
    pop  r19
    pop  r20
    pop  r21
    pop  r22
    pop  r23
    pop  r24
    pop  r25
    pop  r26
    pop  r27
    pop  r28
    pop  r29
    pop  r30
    pop  r31

    reti


    .dseg

_thread_tail: .byte 2
_current_thread: .byte 2
_thread_stack_bottom: .byte 2

    .endif

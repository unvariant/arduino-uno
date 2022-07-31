    .ifndef _TIMER1_INC_
    .define _TIMER1_INC_

    ;;; timer counter control register (timer 1) A
    .equ TCCR1A = 0x80
  
      ;;; waveform generation mode (timer 1), bit 0
        .equ WGM10 = 0
        ;;; waveform generation mode (timer 1), bit 1
        .equ WGM11 = 1

        ;;; compare output mode (timer 1) B, bit 0
        .equ COM1B0 = 4
        ;;; compare output mode (timer 1) B, bit 1
        .equ COM1B1 = 5
        ;;; compare output mode (timer 1) A, bit 0
        .equ COM1A0 = 6
        ;;; compare output mode (timer 1) A, bit 1
        .equ COM1A1 = 7

    ;;; timer counter control register (timer 1) B
    .equ TCCR1B = 0x81

        ;;; clock source (timer 1), bit 0
        .equ CS10 = 0
        ;;; clock source (timer 1), bit 1
        .equ CS11 = 1
        ;;; clock source (timer 1), bit 2
        .equ CS12 = 2

        ;;; waveform generation mode (timer 1), bit 2
        .equ WGM12 = 3
        ;;; waveform generation mode (timer 1), bit 3
        .equ WGM13 = 4

        
    ;;; timer counter control register (timer 1) C
    .equ TCCR1C = 0x82

    ;;; timer counter (timer 1), low
    .equ TCNT1L = 0x84
    ;;; timer counter (timer 1), high
    .equ TCNT1H = 0x85

    ;;; interrupt control register (timer 1), low
    .equ ICR1L = 0x86
    ;;; interrupt control register (timer 1), high
    .equ ICR1H = 0x87

    ;;; timer interrupt flag register (timer 1)
    .equ TIFR1 = 0x16

        ;;; timer overflow (timer 1)
        .equ TOV1 = 0
        ;;; output compare flag (timer 1) A
        .equ OCF1A = 1
        ;;; output comapre flag (timer 1) B
        .equ OCF1B = 2

    ;;; timer interrupt mask register (timer 1)
    .equ TIMSK1 = 0x6F

        ;;; timer overflow interrupt (timer 1)
        .equ TOIE1 = 0
        ;;; output compare interrupt (timer 1) A
        .equ OCIE1A = 1
        ;;; output compare interrupt (timer 1) B
        .equ OCIE1B = 2

    ;;; output compare register (timer 1) A, low
    .equ OCR1AL = 0x88
    ;;; output compare register (timer 1) A, high
    .equ OCR1AH = 0x89
    ;;; output compare register (timer 1) B, low
    .equ OCR1BL = 0x8A
    ;;; output compare register (timer 1) B, high
    .equ OCR1BH = 0x8B

    .endif

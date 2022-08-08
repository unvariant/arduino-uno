    .ifndef _VECTOR_TABLE_S_
    .define _VECTOR_TABLE_S_


    .cseg


    .org  0x0000
_reset:                   jmp _start
    .org  0x0002
_external_interrupt_0:    reti
    .org  0x0004
_external_interrupt_1:    reti
    .org  0x0006
_pin_change_0:            reti
    .org  0x0008
_pin_change_1:            reti
    .org  0x000A
_pin_change_2:            reti
    .org  0x000C
_watchdog_timer:          reti
    .org  0x000E
_timer_2_compare_a:       reti
    .org  0x0010
_timer_2_compare_b:       reti
    .org  0x0012
_timer_2_overflow:        reti
    .org  0x0014
_timer_1_capture:         reti
    .org  0x0016
_timer_1_compare_a:       jmp  context_switch
    .org  0x0018
_timer_1_compare_b:       reti
    .org  0x001A
_timer_1_overflow:        reti
    .org  0x001C
_timer_0_compare_a:       reti
    .org  0x001E
_timer_0_compare_b:       reti
    .org  0x0020
_timer_0_overflow:        reti
    .org  0x0022
_spi_transfer_complete:   reti
    .org  0x0024
_usart_rx_complete:       reti
    .org  0x0026
_usart_udr_empty:         reti
    .org  0x0028
_usart_tx_complete:       reti
    .org  0x002A
_adc_conversion_complete: reti
    .org  0x002C
_eeprom_ready:            reti
    .org  0x002E
_analog_comparator:       reti
    .org  0x0030
_two_wire_spi:            reti
    .org  0x0032
_spm_ready:               reti

    .endif

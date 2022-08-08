    .ifndef _CONFIG_INC_
    .define _CONFIG_INC_

    .DEVICE ATmega328p

    .def zero = r1

.equ RAMEND = 0x08FF
;;; NOTE: all of the following register addresses
;;; are their IO address, not data space addresses

.equ SPH  = 0x3E
.equ SPL  = 0x3D

.equ SREG = 0x3F

.equ PINB = 0x03
.equ DDRB = 0x04
.equ PRTB = 0x05

.equ PINC = 0x06
.equ DDRC = 0x07
.equ PRTC = 0x08

.equ PIND = 0x09
.equ DDRD = 0x0A
.equ PRTD = 0x0B

    .endif

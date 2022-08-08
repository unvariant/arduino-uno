assemble: main.s
	avra main.s -o main.hex -I ../include

DEVICE:=$(shell find /dev -maxdepth 2 -name "cu.usbmodem*")

upload: main.hex
	avrdude \
	-p atmega328p \
	-c arduino \
	-P $(DEVICE) \
	-U flash:w:main.hex:i

debug: main.hex
	objcopy -I ihex main.hex -O binary main.bin
	qemu-system-avr -machine uno -bios main.bin -s -S &
	avr-gdb -x ../debug/avr.gdb

clean:
	-rm -r *.bin
	-rm -r *.obj
	-rm -r *.hex

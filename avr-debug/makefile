assemble: main.s
	avra main.s -o main.hex -I ../include

debug: main.hex
	objcopy -I ihex main.hex -O binary main.bin
	qemu-system-avr -machine uno -bios main.bin -s -S &
	avr-gdb -x avr.gdb

clean:
	-rm -r *.bin
	-rm -r *.hex
	-rm -r *.obj

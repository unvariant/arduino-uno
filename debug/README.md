# Debugging

## Debugging assembly
The best method for debugging assembly that I could find was emulating an avr processor using `qemu-system-avr`, then proceeding to use `gdb` to debug the emulated program. `gdb` can accept a file supplied with the `-x` command line switch, and it will attempt to execute the lines in the file as commands within gdb. The `avr.gdb` file contains commands to debug a remote qemu emulator so the command sequence does not need to be manually entered every single time gdb is launched.

## Debugging C/C++
Avarice emulator
Simulavr emulator
Tinkercad arduino debugger
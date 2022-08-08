# Threading

The arduino uno is equipped with a single 8 bit timer (timer 0) and two 16 bit timers (timer 1 & 2). These timers can be programmed to fire interrupts at regular intervals, which can be used to perform switching between threads.

Each thread must be given separate stack, otherwise there is a possibility of threads corrupting each others stack data. The size of each thread stack must be calculated by the callee and passed as an argument. Internally the amount of stack space needed to perform a switch is added to each threads stack size. Ideally each thread stack and thread descriptor is allocated in such a way that it can later be freed after the thread is destroyed. This allows old thread data to be reused by new threads and reduces the possibility of running out of data space memory.
<br>
<br>
Switching:
 - context switch handler is called (manually or through interrupt), address of current instruction is pushed onto the stack
 - registers r0-r31 are saved on the stack
 - status register is saved on the stack
 - current thread descriptor is loaded
 - stack pointer is stored in current thread descriptor stack field
 - next thread is loaded
 - stack pointer is set to next thread stack field
 - status register is restored from the stack
 - registers r0-r31 are restored from the stack
 - return address from previous switch is used to jump into new thread

## TODO
 - write a proper malloc which can allocate memory that later can be freed
    - allocated chunks contain no metadata
    - freed chunks are stored in a singly linked list
        - freed chunks contain
            1. pointer to the next freed chunk
            2. size of the current chunk
        - if the chunks are sorted by address then the size field can be omitted
    - chunks are allocated by traversing the linked list
        - best fit or first fit?
        - selected chunk is split if possible

## Bugs
 - if the context switch is invoked using a timer interrupt it fails, although if the context switch is manually called it works as intended
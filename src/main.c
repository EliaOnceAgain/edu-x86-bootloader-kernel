#include "printf.h"

void kernel_main()
{
    init_screen();
    print("I AM ALIVE!");
    println();
    print("Protected mode activated");
    println();
    printi(777);
    print("-Jackpot!");
    println();
    while(1);
}

void interrupt_handler(int interrupt_num)
{
    println();
    print("Received interrupt: ");
    printi(interrupt_num);
}


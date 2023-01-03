#include "printf.h"

static void welcome_message();

void kernel_main()
{
    init_screen();
    welcome_message();
    while(1);
}

void interrupt_handler(int interrupt_num)
{
    println();
    print("Received interrupt: ");
    printi(interrupt_num);
}

static void welcome_message()
{
    print("Hi...This is protected mode");
    println();
}

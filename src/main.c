#include "printf.h"     /* print(), println(), printi()                     */
#include "process.h"    /* init_process()                                   */
#include "scheduler.h"  /* init_scheduler()                                 */
#include "vsa.h"        /* init_vsa()                                       */

static void proc1();
static void proc2();
static void welcome_message();

void kernel_main()
{
    vsa_t *vsa = init_vsa(0x100000); /* 1mb */
    init_process();
    init_scheduler();
    welcome_message();

    create_process(vsa, proc1);
    create_process(vsa, proc2);

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

static void proc1()
{
    print("Process 1: ");
    while(1)
        asm("mov $111, %eax");
}

static void proc2()
{
    print("Process 2: ");
    while(1)
        asm("mov $222, %eax");
}

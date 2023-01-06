#include "printf.h"     /* print(), printi()                                */
#include "process.h"    /* init_process()                                   */
#include "scheduler.h"  /* init_scheduler()                                 */
#include "vsa.h"        /* init_vsa()                                       */

static void proc1();
static void proc2();

void kernel_main()
{
    print("Initializing kernel...\n");

    vsa_t *vsa = init_vsa(0x100000); /* 1mb */
    init_process();
    init_scheduler();

    create_process(vsa, proc1);
    create_process(vsa, proc2);

    print("Initialization finished.\n");

    while(1);
}

void interrupt_handler(int interrupt_num)
{
    println();
    print("\nReceived interrupt: ");
    printi(interrupt_num);
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

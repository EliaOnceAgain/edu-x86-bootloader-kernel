#include "printf.h"     /* print(), printi()                                */
#include "process.h"    /* init_process()                                   */
#include "scheduler.h"  /* init_scheduler()                                 */
#include "vsa.h"        /* init_vsa()                                       */
#include "paging.h"     /* init_paging()                                    */

vsa_t *vsa = 0x0;

static void proc1();
static void proc2();
static void proc3();

void kernel_main()
{
    print("Initializing kernel...\n");

    /*
    no context switching while initializing because
    (1) processes_count is 0 so we'd get int 0x00 for div by 0
    (2) after first context switch we will not return here
    */
    asm("cli");

    vsa = init_vsa(HEAP_SIZE);
    print("vsa: done\n");

    init_process();
    print("process: done\n");

    init_scheduler();
    print("scheduler: done\n");

    init_paging();
    print("paging: done\n");

    create_process(vsa, proc1);
    create_process(vsa, proc2);

    print("Initialization finished\n\n");

    /*
    enable interrupts and context switching
    after the first context switch we will never
    return here again
    */
    asm("sti");
}

void interrupt_handler(int interrupt_num)
{
    print("int=");
    printi(interrupt_num);
    print(" ");
}

static void proc1()
{
    print("Process 1: UP\n");
    print("Creating Process 3 from inside Process 1\n");
    create_process(vsa, proc3);

    while(1)
        asm("mov $111, %eax");
}

static void proc2()
{
    print("Process 2: UP\n");
    while(1)
        asm("mov $222, %eax");
}

static void proc3()
{
    print("Process 3: UP\n");
    while(1)
        asm("mov $333, %eax");
}
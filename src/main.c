#include "printf.h"     /* init_screen(), print(), println(), printi()      */
#include "process.h"    /* init_process()                                   */
#include "scheduler.h"  /* init_scheduler()                                 */
#include "vsa.h"        /* init_vsa()                                       */

static void welcome_message();

void kernel_main()
{
    vsa_t *vsa = init_vsa(0x20000000); /* 512mb */
    init_screen();
    init_process();
    init_scheduler();

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

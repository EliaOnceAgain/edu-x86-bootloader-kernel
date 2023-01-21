#include "scheduler.h"
#include "process.h"        /* process_table                                */
#include "printf.h"         /* print(), printi()                            */

int next_scheduled_pid, curr_scheduled_pid;
process_t *next_process;

void init_scheduler()
{
    next_scheduled_pid = 0;
    curr_scheduled_pid = 0;
}

void scheduler(int eip, int edi, int esi, int ebp, int esp, int ebx, int edx, int ecx, int eax)
{
    process_t *curr_process = process_table[curr_scheduled_pid];
    next_process = get_next_process();

    print("EAX = ");
    printi(eax);
    println();

    /* store currently running process context */
    if(curr_process->state == RUNNING)
    {
        curr_process->context.eax = eax;
        curr_process->context.ebx = ebx;
        curr_process->context.ecx = ecx;
        curr_process->context.edx = edx;
        curr_process->context.esp = esp;
        curr_process->context.ebp = ebp;
        curr_process->context.esi = esi;
        curr_process->context.edi = edi;
        curr_process->context.eip = eip;
    }
    curr_process->state = READY;

    /* restore next process context */
    asm("   mov %0, %%eax; \
            mov %0, %%ebx; \
            mov %0, %%ecx; \
            mov %0, %%edx; \
            mov %0, %%esi; \
            mov %0, %%edi;"
            : :
            "r" (next_process->context.eax),
            "r" (next_process->context.ebx),
            "r" (next_process->context.ecx),
            "r" (next_process->context.edx),
            "r" (next_process->context.esi),
            "r" (next_process->context.edi)
            );
    next_process->state = RUNNING;
}

process_t *get_next_process()
{
    process_t *next_process = process_table[next_scheduled_pid];
    curr_scheduled_pid = next_scheduled_pid;
    ++next_scheduled_pid;
    next_scheduled_pid = next_scheduled_pid % processes_count;
    return next_process;
}

void run_next_process()
{
    asm("   sti; \
            jmp *%0"
        : :
        "r" (next_process->context.eip)
        );
}

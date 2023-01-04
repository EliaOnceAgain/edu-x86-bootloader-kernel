#include "process.h"
#include "vsa.h"        /* vsa_t                                            */

void init_process()
{
    processes_count = 0;
    curr_pid = 0;
}

process_t *create_process(vsa_t *vsa, vfuncv base_addr)
{
    process_t *p = (process_t *)alloc(vsa, sizeof(process_t));
    p->pid = curr_pid++;

    p->context.eax = 0;
    p->context.ebx = 0;
    p->context.ecx = 0;
    p->context.edx = 0;
    p->context.esp = 0;
    p->context.ebp = 0;
    p->context.esi = 0;
    p->context.edi = 0;
    p->context.eip = base_addr;

    p->state = READY;
    p->base_addr = base_addr;

    process_table[p->pid] = p;
    processes_count++;

    return p;
}

#ifndef __KERNEL_PROCESS_H__
#define __KERNEL_PROCESS_H__

#include "vsa.h"    /* vsa_t                                                */

typedef enum process_state {
    READY,
    RUNNING
} process_state_t;

/* process snapshot of x86 registers */
typedef struct process_context {
    int eax, ebx, ecx, edx, esp, ebp, esi, edi, eip;
} process_context_t;

/* PCB */
typedef struct process {
    int pid;
    process_context_t context;
    process_state_t state;
    int *base_addr;
} process_t;

process_t *process_table[15];

int processes_count, curr_pid;

/*
 * DESCRIPTION:
 * init globals
 */
void init_process();

/*
 * DESCRIPTION:
 * create a new process
 *
 * PARAMS:
 * vsa_t *          memory allocator
 * vfuncf           function pointer to process base address
 *
 * RETURN:
 * pointer to created process PCB
 */
typedef void (*vfuncv)();
process_t *create_process(vsa_t *, vfuncv);

#endif /* __KERNEL_PROCESS_H__ */

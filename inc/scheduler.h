#ifndef __KERNEL_SCHEDULER_H__
#define __KERNEL_SCHEDULER_H__

#include "process.h"

extern int next_scheduled_pid, curr_scheduled_pid;
extern process_t *next_process;

/*
 * DESCRIPTION:
 * init globals to 0
 */
void init_scheduler();

/*
 * DESCRIPTION:
 * called on system timer interrupts to choose the next process to run
 * does context switch by copying the context of the current process
 * from the registers to memory, and the context of the next process
 * from memory to registers
 */
void scheduler(int, int, int, int, int, int, int, int, int);

/*
 * DESCRIPTION:
 * execute next process
 */
void run_next_process();

/*
 * DESCRIPTION:
 * get the next process that should run
 *
 * RETURN:
 * process to run
 */
process_t *get_next_process();

#endif /* __KERNEL_SCHEDULER_H__ */

#ifndef __KERNEL_PRINTF_H__
#define __KERNEL_PRINTF_H__

/*
 * DESCRIPTION:
 * print a null terminated string
 *
 * PARAMS:
 * const char *         ptr to a null terminated string
 */
void print(const char *);

/*
 * DESCRIPTION:
 * print an integer
 *
 * PARAMS:
 * const int            integer to print
 */
void printi(const int);

/*
 * DESCRIPTION:
 * print a new line
 */
void println();

#endif /* __KERNEL_PRINTF_H__ */

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
 * print a single character
 *
 * PARAMS:
 * const char           char to print
 */
void printc(const char);

/*
 * DESCRIPTION:
 * print an integer in hex
 *
 * PARAMS:
 * const int            integer to print
 */
void print0x(const int);

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

#ifndef __KERNEL_PRINTF_H__
#define __KERNEL_PRINTF_H__

volatile unsigned char *video;
int g_print_ind_x;
int g_print_ind_y;

/*
 * DESCRIPTION:
 * init globals video, g_print_ind_x, g_print_int_y
 */
void init_screen();

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

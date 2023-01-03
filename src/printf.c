#include "printf.h"

#define NUM_COLS 80

static const char* DIGITS_STR[] = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"};


void init_screen()
{
    video = (unsigned char *)0xB8000;
    g_print_ind_x = 0;
    g_print_ind_y = 0;
}

void print(const char *str)
{
    while('\0' != *str)
    {
        video[g_print_ind_x * 2] = *str;
        video[g_print_ind_x * 2 + 1] = 15;
        ++g_print_ind_x;
        ++str;
    }
}

void printi(const int num)
{
    if(0 < num)
    {
        printi(num / 10);
        print(DIGITS_STR[num % 10]);
    }
}

void println()
{
    g_print_ind_x = ++g_print_ind_y * NUM_COLS;
}


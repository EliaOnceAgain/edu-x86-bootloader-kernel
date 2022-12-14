#include "printf.h"

#define NUM_COLS 80

volatile unsigned char *video = (unsigned char *)0xB8000;
static int print_ind_x = 0;
static int print_ind_y = 0;
static const char* DIGITS_STR[] = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"};


void print(const char *str)
{
    while('\0' != *str)
    {
        video[print_ind_x * 2] = *str;
        video[print_ind_x * 2 + 1] = 15;
        ++print_ind_x;
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
    print_ind_x = ++print_ind_y * NUM_COLS;
}


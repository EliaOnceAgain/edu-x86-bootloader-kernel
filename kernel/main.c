#define NUM_COLS 80

static const char* DIGITS_STR[] = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"};
volatile unsigned char *video = (unsigned char *)0xB8000;

/* variables for printing on screen */
int g_print_ind_x = 0;
int g_print_ind_y = 0;

void print(const char *);               /* print string     */
void printi(const int);                 /* print int        */
void println();                         /* print new line   */

void kernel_main()
{
    print("I AM ALIVE!");
    println();
    print("Protected mode activated");
    println();
    printi(777);
    print("-Jackpot!");
    println();
    while(1);
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


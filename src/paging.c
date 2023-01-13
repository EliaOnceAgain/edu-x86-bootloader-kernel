#include "paging.h"
#include "printf.h"     /* DELETE ME PLS */

static void print_paging_addr_range(void *);

void init_paging()
{
    unsigned int curr_page_frame = 0;
    unsigned int *page_table = 0;
    page_directory = (unsigned int *)PAGING_START;

    for(int curr_pde = 0; curr_pde < PDE_NUM; curr_pde++)
    {
        page_table = (unsigned char *)page_directory +
                                    (curr_pde + 1) * PTE_BYTES * PTE_NUM;

        for(int curr_pte = 0;
            curr_pte < PTE_NUM;
            curr_pte++, curr_page_frame++)
        {
            page_table[curr_pte] = create_page_entry(curr_page_frame *
                PAGE_SIZE, 1, 0, 0, 1, 1, 0, 0, 0);
        }
        page_directory[curr_pde] = create_page_entry(
            page_table, 1, 0, 0, 1, 1, 0, 0, 0);
    }

    print_paging_addr_range((unsigned char *)page_table + PTE_BYTES * PTE_NUM);
    load_page_directory();
    print("- loaded page directory\n");
    enable_paging();
    print("- enabled paging\n");
}

int create_page_entry(int base_addr, char present, char writable,
                      char privilege_level, char cache_enabled,
                      char write_through_cache, char accessed, char page_size,
                      char dirty)
{
    int entry = 0;

    entry |= present;
    entry |= writable << 1;
    entry |= privilege_level << 2;
    entry |= write_through_cache << 3;
    entry |= cache_enabled << 4;
    entry |= accessed << 5;
    entry |= dirty << 6;
    entry |= page_size << 7;

    return base_addr | entry;
}

static void print_paging_addr_range(void *addr)
{
    print("Paging addr range: ");
    print0x(PAGING_START);
    print(" - ");
    print0x(addr);
    println();
}

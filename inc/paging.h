#ifndef __KERNEL_PAGING_H__
#define __KERNEL_PAGING_H__

#define PAGING_START 0x100000
#define PDE_NUM 1024            /* page directory entries                   */
#define PTE_NUM 1024            /* page table entries                       */
#define PTE_BYTES 4             /* page table entry size in bytes           */
#define PDE_BYTES 4             /* page directory entry size in bytes       */
#define PAGE_SIZE 4096          /* page frame size                          */

unsigned int *page_directory;

/*
 * DESCRIPTION:
 * load kernel page directory address to CR3 register
 */
extern void load_page_directory();

/*
 * DESCRIPTION:
 * enable paging by modifying CR0 register after initializing
 * and loading the page directory
 */
extern void enable_paging();

/*
 * DESCRIPTION:
 * create kernel page directory and page tables
 */
void init_paging();

/*
 * DESCRIPTION:
 * create a PDE/PTE entry which is 4 bytes
 *
 * PARAMS:
 * int      if PDE this is base memory adderss of page table
 *          if PTE this is base memory address of page frame 
 * char     flags for present, writable, privilege level, cache enabled,
 *          write through cache, accessed, page size, dirty
 *
 * RETURN:
 * created entry as an int (4bytes)
 */
int create_page_entry(int, char, char, char, char, char, char, char, char);

#endif /* __KERNEL_PAGING_H__ */

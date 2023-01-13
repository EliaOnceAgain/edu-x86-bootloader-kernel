/* variable size allocator */

#ifndef __KERNEL_VSA_H__
#define __KERNEL_VSA_H__

#define NULL 0
#define HEAP_START 0x600000

typedef struct vsa vsa_t;

/*
 * DESCRIPTION:
 * initializes vsa
 * time complexity O(1)
 *
 * PARAMS:
 * unsigned int        size of memory segment
 *
 * RETURN:
 * on success, vsa_t* to an initialized allocator, otherwise NULL.
 */
vsa_t *init_vsa(unsigned int);

/*
 * DESCRIPTION:
 * allocate a block of at least bytes size, if none are available returns NULL
 * block size will be aligned to word size
 * time complexity: O(n)
 *
 * PARAMS:
 * vsa_t *              vsa memory allocator, UB if NULL
 * unsigned int         number of bytes to allocate (not including padding)
 *
 * RETURN:
 * pointer to the allocated block of memory, NULL if OOM
 */
void *alloc(vsa_t *, unsigned int);

/*
 * DESCRIPTION:
 * deallocate a block of memory
 * double free is UB
 * time complexity O(1)
 *
 * PARAMS:
 * void *               pointer to start of a memory block
 */
void free(void *);

/*
 * DESCRIPTION:
 * return the size of the largest free memory block
 * time complexity: O(n)
 *
 * PARAMS:
 * vsa_t *              vsa memory allocator, UB if NULL
 *
 * RETURN:
 * integer representing the largest free memory block
 */
unsigned int largest_chunk_available(vsa_t *);

#endif /*__KERNEL_VSA_H__*/

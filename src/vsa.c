#include "vsa.h"

#define ZERO_SIZE (0)

static const unsigned int WORDSIZE = sizeof(unsigned int);

struct vsa {
    unsigned int segment_size;
};

typedef struct block_header {
    unsigned int block_size;
} block_header_t;

static long max(long num1, long num2);
static int is_free_block(block_header_t *block);
static unsigned int align_up(unsigned int size);
static unsigned int align_down(unsigned int size);
static long defrag(vsa_t *vsa, block_header_t *block);
static block_header_t *get_block_by_offset(block_header_t *block, unsigned int offset);
static void set_block_header(block_header_t *block, long int block_size);
static block_header_t *get_end_of_mem_segment(vsa_t *vsa);
static block_header_t *allocate_block(block_header_t *block, unsigned int num_bytes);

vsa_t *init_vsa(unsigned int segment_size)
{
    vsa_t *vsa = NULL;
    block_header_t *first_block = NULL;
    unsigned int memory_segment_aligned = ZERO_SIZE;

    /* align memory segment start address */
    memory_segment_aligned = align_up((unsigned int)HEAP_START);
    segment_size -= (memory_segment_aligned - (unsigned int)HEAP_START);

    /* align memory segment end address */
    segment_size = align_down(segment_size);

    /* initialize VSA */
    vsa = (vsa_t *)memory_segment_aligned;

    segment_size -= sizeof(*vsa);
    vsa->segment_size = segment_size;

    first_block = (block_header_t *)(vsa + 1);
    set_block_header(first_block, segment_size);

    return vsa;
}

void *alloc(vsa_t *vsa, unsigned int bytes)
{
    block_header_t *current_block = NULL;
    block_header_t *allocated_block = NULL;
    block_header_t *ptr_tail = NULL;
    long current_block_size = ZERO_SIZE;
    long num_bytes = (long)bytes;

    num_bytes = align_up(num_bytes) + sizeof(block_header_t);
    current_block = (block_header_t *)(vsa + 1);
    ptr_tail = get_end_of_mem_segment(vsa);

    while(ptr_tail != current_block && NULL == allocated_block)
    {
        current_block_size = current_block->block_size;

        if(is_free_block(current_block))
        {
            /* Check if defragmentation is needed */
            if(num_bytes > current_block_size)
            {
                current_block_size = defrag(vsa, current_block);
            }

            /* Initialize a new allocated block */
            if(num_bytes <= current_block_size)
            {
                allocated_block = allocate_block(current_block, num_bytes);
            }

            current_block_size *= -1;
        }

        current_block = get_block_by_offset(current_block, -current_block_size);
    }

    return allocated_block;
}

void free(void *block)
{
    if(NULL != block)
    {
        block_header_t *block_to_free = (block_header_t *)block;
        --block_to_free;
        block_to_free->block_size *= -1;
    }
}

unsigned int largest_chunk_available(vsa_t *vsa)
{
    block_header_t *current_block = NULL;
    block_header_t *ptr_tail = NULL;
    long current_block_size = ZERO_SIZE;
    long max_size = ZERO_SIZE;

    ptr_tail = get_end_of_mem_segment(vsa);
    current_block = (block_header_t *)(vsa + 1);

    while(ptr_tail != current_block)
    {
        current_block_size = current_block->block_size;

        if(is_free_block(current_block))
        {
            current_block_size = defrag(vsa, current_block);
            max_size = max(max_size, current_block_size);
            current_block_size *= -1;
        }

        current_block = get_block_by_offset(current_block, -current_block_size);
    }

    return max(0, max_size - sizeof(block_header_t));
}

static block_header_t *allocate_block(block_header_t *block, unsigned int num_bytes)
{
    block_header_t *allocated_block = NULL;

    block->block_size -= num_bytes;
    allocated_block = get_block_by_offset(block, block->block_size);
    set_block_header(allocated_block, -num_bytes);
    ++allocated_block;

    return allocated_block;
}

static long max(long num1, long num2)
{
    return num1 > num2 ? num1 : num2;
}

static int is_free_block(block_header_t *block)
{
    return ZERO_SIZE < block->block_size;
}

static void set_block_header(block_header_t *block, long int block_size)
{
    block->block_size = block_size;
}

static block_header_t *get_block_by_offset(block_header_t *block, unsigned int offset)
{
    return (block_header_t *)((char *)block + offset);
}

static block_header_t *get_end_of_mem_segment(vsa_t *vsa)
{
    return (block_header_t *)((char *)(vsa + 1) + vsa->segment_size);
}

static long defrag(vsa_t *vsa, block_header_t *block)
{
    block_header_t *next_block = NULL;
    block_header_t *ptr_tail = NULL;

    next_block = get_block_by_offset(block, block->block_size);
    ptr_tail = get_end_of_mem_segment(vsa);

    while(ptr_tail != next_block && is_free_block(next_block))
    {
        block->block_size += next_block->block_size;
        next_block = get_block_by_offset(block, block->block_size);
    }

    return block->block_size;
}

static unsigned int align_up(unsigned int size)
{
    return size + ((WORDSIZE - (size & (WORDSIZE - 1))) & (WORDSIZE - 1));
}

static unsigned int align_down(unsigned int size)
{
    return size & ~(WORDSIZE - 1);
}


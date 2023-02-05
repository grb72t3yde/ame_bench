#ifndef AME_BENCH_H
#define AME_BENCH_H

typedef enum {
    ycsb = 0,
    pim_tree
} type_t;

typedef struct {
    type_t type;
    unsigned long host_mem_size;
    unsigned long nr_dpu_ranks;
    char *cmd;
    pthread_t th;
} workload_t;

#endif

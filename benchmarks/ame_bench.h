#ifndef AME_BENCH_H
#define AME_BENCH_H

typedef struct {
    // cmd to be executed
    char *cmd;
    pthread_t th;
} workload_t;

#endif

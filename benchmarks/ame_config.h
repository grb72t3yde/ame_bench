#ifndef AME_BENCH_CONFIG_H
#define AME_BENCH_CONFIG_H

/* Host memory size and number of dpu ranks */
#define HOST_MEM_SIZE_GB 64
#define NR_DPU_RANKS 16
#define MRAM_SIZE_GB_PER_RANK 4

/* number of workloads */
#define NR_WORKLOADS 5

/* Run mode */
#define RUNMODE 1

#define WITHOUT_AME 0
#define AME_NO_THRESHOLD 1
#define AME_THRESHOLD_HALF 2
#define AME_UTIL_PREDICTION 3

#endif

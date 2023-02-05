#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <string.h>
#include <time.h>
#include "ame_bench.h"
#include "ame_config.h"

workload_t workloads[NR_WORKLOADS];
int used_host_mem_size;
unsigned long nr_used_dpu_ranks;

pthread_mutex_t mutex;

time_t start_t, end_t;

void *run_one_workload(void *arg)
{
    int index = *(int *)arg;

    system(workloads[index].cmd);

    pthread_mutex_lock(&mutex);
    used_host_mem_size -= workloads[index].host_mem_size;
    pthread_mutex_unlock(&mutex);
}

void read_input_file(const char *path, workload_t *workloads)
{
    FILE *fp;
    char bench[100] = {'\0'};
    int i = 0;

    printf("file name %s\n", path);
    if ((fp = fopen(path, "r")) == NULL) {
        printf("Open file failed!\n");
        exit(0);
    }

    while (fgets(bench, 100, fp) != NULL) {
        char *token;

        /* workload type */
        token = strtok(bench, ",");
        workloads[i].type = atoi(token); 

        /* mem size */
        token = strtok(NULL, ",");
        workloads[i].host_mem_size = atoi(token); 

        /* command */
        token = strtok(NULL, ",");
        workloads[i].cmd = malloc(strlen(token)); 
        strcpy(workloads[i].cmd, token);
        ++i;
    }

    fclose(fp);
}

int main()
{
    read_input_file("benchmarks/benchmark1.txt", workloads);

    pthread_mutex_init(&mutex, NULL);
    used_host_mem_size = 0;
    nr_used_dpu_ranks = 0;

    time(&start_t);

    for (int i = 0; i < NR_WORKLOADS; ++i) {
        if (workloads[i].type == ycsb) {
try:
            pthread_mutex_lock(&mutex);
#if RUNMODE == WITHOUT_AME
            if (HOST_MEM_SIZE_GB - used_host_mem_size < workloads[i].host_mem_size) {
#elif RUNMODE == AME_NO_THRESHOLD || RUNMODE == AME_UTIL_PREDICTION
            if (HOST_MEM_SIZE_GB - used_host_mem_size + (NR_DPU_RANKS - nr_used_dpu_ranks) * MRAM_SIZE_GB_PER_RANK < workloads[i].host_mem_size) {
#elif RUNMODE == AME_THRESHOLD_HALF
            if (HOST_MEM_SIZE_GB - used_host_mem_size + (NR_DPU_RANKS / 2 - nr_used_dpu_ranks) * MRAM_SIZE_GB_PER_RANK < workloads[i].host_mem_size) {
#endif
                pthread_mutex_unlock(&mutex);

                printf("No mem, try after 10 secs!!!!!!!!!!!!!!!!!!!!!\n");
                system("bash ./count_down_timer.sh 0 0 10");
                goto try;
            }

            used_host_mem_size += workloads[i].host_mem_size;
            pthread_create(&workloads[i].th, NULL, &run_one_workload, &i);
            pthread_mutex_unlock(&mutex);
        } else {

        }
        system("bash ./count_down_timer.sh 0 0 30");
    }
    
    for (int i = 0; i < NR_WORKLOADS; ++i) {
        if (pthread_join(workloads[i].th, NULL) != 0) {
            perror("Fail to join thread\n");
        }
    }

    time(&end_t);

    double total_t = (double)(end_t - start_t);
    printf("Total time taken by CPU: %f\n", difftime(end_t, start_t));

    pthread_mutex_destroy(&mutex);
    return 0;

}

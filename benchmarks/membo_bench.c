#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <string.h>
#include "timer.h"
#include "membo_bench.h"
#include "membo_config.h"

void *run_one_workload(void *arg)
{
    workload_t *workload = (workload_t *)arg;

    if (workload->cmd_type == RUN) {
        printf(KGRN"Section2 evaluation: Start running YCSB workload\n");
    }

    system(workload->cmd);

    if (workload->cmd_type == RUN) {
        printf(KGRN"Section2 evaluation: YCSB workload done!\n");
    }
}

int read_dpu_input_file(FILE *fp, workload_t *workloads)
{
    char line[100] = {'\0'};
    int i = 0;

    if (fp == NULL) {
        printf("Open file failed!\n");
        exit(0);
    }

    while (fgets(line, 100, fp) != NULL) {

        if (line[0] == '-')
            break;

        workloads[i].cmd = malloc(strlen(line) + 1);
        strcpy(workloads[i].cmd, line);

        ++i;
    }

    return i;
}

int main()
{
    Timer timer;

    start(&timer, 0, 0);
#if RUN_HOST_WORKLOAD == 1
    workload_t host_workload;

    char *load_ycsb_cmd = "bash ./load_one_ycsb_workload.sh 11211 a";
    char *run_ycsb_cmd = "bash ./run_one_ycsb_workload.sh 11211 a";
    host_workload.cmd = malloc(strlen(load_ycsb_cmd) + 1);
    host_workload.cmd_type = LOAD;
    strcpy(host_workload.cmd, load_ycsb_cmd);

    /* Load YCSB workload */
    pthread_create(&host_workload.th, NULL, &run_one_workload, &host_workload);
    if (pthread_join(host_workload.th, NULL) != 0) {
        perror("Fail to join thread\n");
    }

    /* Run YCSB workload */
    strcpy(host_workload.cmd, run_ycsb_cmd);
    host_workload.cmd_type = RUN;
    pthread_create(&host_workload.th, NULL, &run_one_workload, &host_workload);
#endif

#if RUN_DPU_WORKLOADS == 1
    FILE *fp = fopen("benchmarks/dpu/MULTI_CONFIG1.txt", "r");

#if RUN_DPU_WORKLOADS == 1 && RANK_RESERVATION_ACTIVATED == 1
    system("~/membo_rank_reservation/membo_rank_reserv &");
#endif

    /* Pre-DPU program delay */
    system("bash ./count_down_timer.sh 0 5 0");

    workload_t group[NR_ALLOCATION];
    read_dpu_input_file(fp, group);
    
    for (int i = 0; i < NR_ALLOCATION; ++i) {
        printf("=================================================================\n");
        printf(KYEL"Section2 evaluation: Launching DPU process...\n");
        pthread_create(&group[i].th, NULL, &run_one_workload, &group[i]);
        /* delta X */
        system("bash ./count_down_timer.sh 0 1 30");
    }

    for (int i = 0; i < NR_ALLOCATION; ++i) {
        if (pthread_join(group[i].th, NULL) != 0) {
            perror("Fail to join thread\n");
        }
        printf(KYEL"Section2 evaluation: DPU process terminated!\n");
        printf("=================================================================\n");
    }

    fclose(fp);
#endif

#if RUN_HOST_WORKLOAD == 1
    if (pthread_join(host_workload.th, NULL) != 0) {
        perror("Fail to join thread\n");
    }
#endif
    stop(&timer, 0);

    printf("Total time: ");
    print(&timer, 0, 1);
    printf("\n");

    return 0;
}

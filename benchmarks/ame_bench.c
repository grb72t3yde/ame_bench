#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <string.h>
#include "timer.h"
#include "ame_bench.h"
#include "ame_config.h"

void *run_one_workload(void *arg)
{
    workload_t *workload = (workload_t *)arg;

    printf("%s\n", workload->cmd);
    system(workload->cmd);
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
    int nr_used_dpu_ranks = 0;

    // read host side program input
    workload_t host_workload;

    char *ycsb_cmd = "bash ./run_one_ycsb_workload.sh 11211 a";
    host_workload.cmd = malloc(strlen(ycsb_cmd) + 1);
    strcpy(host_workload.cmd, ycsb_cmd);

    start(&timer, 0, 0);
    pthread_create(&host_workload.th, NULL, &run_one_workload, &host_workload);

    FILE *fp = fopen("benchmarks/dpu/workload1.txt", "r");
    for (int i = 0; i < NR_GROUPS; ++i) {
        workload_t group[NR_MAX_WORKLOAD_PER_GROUP];

        // read group 1
        int nr_workloads_of_group = read_dpu_input_file(fp, group);

        // run group 1
        for (int j = 0; j < nr_workloads_of_group; j++) {
            //printf("%s", group[j].cmd);
            pthread_create(&group[j].th, NULL, &run_one_workload, &group[j]);
        }

        for (int j = 0; j < nr_workloads_of_group; j++) {
            if (pthread_join(group[j].th, NULL) != 0) {
                perror("Fail to join thread\n");
            }
        }
        printf("%d\n", i);
        system("bash ./count_down_timer.sh 0 0 5");
    }
    fclose(fp);
    
    if (pthread_join(host_workload.th, NULL) != 0) {
        perror("Fail to join thread\n");
    }
    stop(&timer, 0);

    printf("Total time: ");
    print(&timer, 0, 1);
    printf("\n");

    return 0;

}

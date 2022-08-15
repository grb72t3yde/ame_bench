#!/bin/bash

nr_memcached_ins=5
default_port=11211

# start the logger
bash mem_usage_logger.sh &

# start memcached instances
for (( i = 0; i < ${nr_memcached_ins}; ++i ))
do
    bash ./run_one_ycsb_workload.sh $((default_port + i)) &

    # delay
    bash ./count_down_timer.sh 0 10 0
done



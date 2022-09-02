#!/bin/bash

nr_memcached_ins=2
default_port=11211

interval_hours=(1 0)
interval_minutes=(0 0)
interval_seconds=(0 0)
workloads=('a' 'b')

# start memcached instances
for (( i = 0; i < ${nr_memcached_ins}; ++i ))
do
    bash ./run_one_ycsb_workload.sh $((default_port + i)) ${workloads[$i]} &

    # delay
    bash ./count_down_timer.sh ${interval_hours[$i]} ${interval_minutes[$i]} ${interval_seconds[$i]}
done


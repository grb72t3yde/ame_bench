#!/bin/bash

nr_memcached_ins=2
default_port=11211

for (( i = 0; i < ${nr_memcached_ins}; ++i ))
do
    bash ./run_one_ycsb_workload.sh $((default_port + i)) &

    # delay
    min=20
    sec=0
    while [ $min -gt 0 ]
    do
        while [ $sec -gt 0 ]
        do
            echo -ne "$min:$sec\033[O\r"
            let "sec=sec-1"
            sleep 1
        done
        sec=59
        let "min=min-1"
    done
done



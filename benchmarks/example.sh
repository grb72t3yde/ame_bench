#!/bin/bash

nr_memcached_ins=2

default_port=11211

for (( i = 0; i < ${nr_memcached_ins}; ++i ))
do
    bash ./run_one_ycsb_workload.sh $((default_port + i)) &
done



#!/bin/bash

SUBMODULES_PATH="$( readlink -f "$( dirname "${BASH_SOURCE[0]}" )/../submodules")"
SCRIPT_PATH="$( readlink -f "$( dirname "${BASH_SOURCE[0]}" )")"
port_num="$1"
workload="$2"
nr_threads=32
memory_usage=262144
target_program="memcached"

# Start the logger
bash logger.sh &

# create a memcached instance
cd ${SUBMODULES_PATH}/memcached
numactl --interleave=all ./memcached -m ${memory_usage} -p ${port_num} > memcached_output${port_num} &

# run YCSB workload
cd ${SUBMODULES_PATH}/YCSB
numactl --interleave=all ./bin/ycsb load memcached -s -P workloads/workload${workload} -p "memcached.hosts=127.0.0.1:${port_num}" -threads ${nr_threads} > output_ycsb/outputLoad_${workload}_${ycsb_size}.txt


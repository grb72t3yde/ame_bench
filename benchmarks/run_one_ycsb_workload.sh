#!/bin/bash

SUBMODULES_PATH="$( readlink -f "$( dirname "${BASH_SOURCE[0]}" )/../submodules")"
SCRIPT_PATH="$( readlink -f "$( dirname "${BASH_SOURCE[0]}" )")"
port_num="$1"
workload="$2"
nr_threads=8
memory_usage=16384
target_program="memcached"

run_with_ame="with_ame"
#run_with_ame="without_ame"

# create a memcached instance
cd ${SUBMODULES_PATH}/memcached
./memcached -m ${memory_usage} -p ${port_num} > memcached_output${port_num} &

# run YCSB workload
cd ${SUBMODULES_PATH}/YCSB
./bin/ycsb load memcached -s -P workloads/workload${workload} -p "memcached.hosts=127.0.0.1:${port_num}" -threads ${nr_threads} && \
    ./bin/ycsb run memcached -s -P workloads/workload${workload} -p "memcached.hosts=127.0.0.1:${port_num}" -threads ${nr_threads} > outputRun_${port_num}_${run_with_ame}.txt

# kill the memcached instance
cd $SCRIPT_PATH
bash process_killer.sh ${target_program} ${port_num}

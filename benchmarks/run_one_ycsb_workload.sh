#!/bin/bash

SUBMODULES_PATH="$( readlink -f "$( dirname "${BASH_SOURCE[0]}" )/../submodules")"
SCRIPT_PATH="$( readlink -f "$( dirname "${BASH_SOURCE[0]}" )")"
port_num="$1"

run_with_ame="with_ame"
#run_with_ame="without_ame"

# create a memcached instance
cd ${SUBMODULES_PATH}/memcached
./memcached -m 16384 -p ${port_num} &

# run YCSB workload
cd ${SUBMODULES_PATH}/YCSB
./bin/ycsb load memcached -s -P workloads/workloada -p "memcached.hosts=127.0.0.1:${port_num}" && \
    ./bin/ycsb run memcached -s -P workloads/workloada -p "memcached.hosts=127.0.0.1:${port_num}" > outputRun_${port_num}_${run_with_ame}.txt

# kill the memcached instance
cd $SCRIPT_PATH
bash kill.sh ${port_num}

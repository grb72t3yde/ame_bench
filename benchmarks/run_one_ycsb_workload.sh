#!/bin/bash

SUBMODULES_PATH="$( readlink -f "$( dirname "${BASH_SOURCE[0]}" )/../submodules")"
port_num="$1"

cd ${SUBMODULES_PATH}/memcached
./memcached -m 16384 -p ${port_num} &

cd ${SUBMODULES_PATH}/YCSB
./bin/ycsb load memcached -s -P workloads/workloada -p "memcached.hosts=127.0.0.1:${port_num}" && \
    ./bin/ycsb run memcached -s -P workloads/workloada -p "memcached.hosts=127.0.0.1:${port_num}" > outputRun_${port_num}.txt


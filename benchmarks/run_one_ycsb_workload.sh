#!/bin/bash

SUBMODULES_PATH="$( readlink -f "$( dirname "${BASH_SOURCE[0]}" )/../submodules")"
SCRIPT_PATH="$( readlink -f "$( dirname "${BASH_SOURCE[0]}" )")"
port_num="$1"
workload="$2"
nr_threads=32
target_program="memcached"

# run YCSB workload
cd ${SUBMODULES_PATH}/YCSB
numactl --interleave=all ./bin/ycsb run memcached -s -P workloads/workload${workload} -p "memcached.hosts=127.0.0.1:${port_num}" -threads ${nr_threads} > output_ycsb/outputRun_${workload}.txt

ps -ef | grep memcached | grep -v grep | while read -r line
do
     PID=$(echo $line | awk '{print $2}')
     port_arg=$(echo $line | awk '{print $11}')

     if [ $port_arg = "-p" ]
     then
         PORT_NUM=$(echo $line | awk '{print $12}')

         if [ $PORT_NUM -eq $port_num ]
         then
             ps -o min_flt,maj_flt ${PID} > output_major_pf/out_pf_${workload}.txt
         fi
     fi
done

# kill the memcached instance
cd $SCRIPT_PATH
bash process_killer.sh ${target_program} ${port_num}

#!/bin/bash

port=$1
ps -ef | grep memcached | grep -v grep | while read -r line
do
    PORT_NUM=$(echo $line | awk '{print $12}')
    PID=$(echo $line | awk '{print $2}')

    if [ $PORT_NUM -eq $port ]
    then
        kill -9 $PID
    fi
done


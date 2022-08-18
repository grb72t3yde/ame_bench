#!/bin/bash

target_program=${1}

if [ ${target_program} = "memcached" ]
then
    port=${2}
fi

ps -ef | grep ${target_program} | grep -v grep | while read -r line
do
    PID=$(echo $line | awk '{print $2}')
    port_arg=$(echo $line | awk '{print $11}')

    if [ ${target_program} = "memcached" ] && [ $port_arg = "-p" ]
    then
        PORT_NUM=$(echo $line | awk '{print $12}')

        if [ $PORT_NUM -eq $port ]
        then
            kill -9 $PID
        fi
    fi
done


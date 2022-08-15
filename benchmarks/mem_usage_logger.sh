#!/bin/bash

if [[ -f logs/mem_log.txt ]]
then
    rm logs/mem_log.txt
fi
touch logs/mem_log.txt

echo "      date     time $(free -m | grep total | sed -E 's/^    (.*)/\1/g')" >> logs/mem_log.txt
while true; do
    echo "$(date '+%Y-%m-%d %H:%M:%S') $(free -m | grep Mem: | sed 's/Mem://g')" >> logs/mem_log.txt
    bash ./count_down_timer.sh 0 5 0
done

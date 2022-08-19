#!/bin/bash

if [[ -f logs/managed.txt ]]
then
    rm logs/managed.txt
fi
touch logs/managed.txt

if [[ -f logs/free.txt ]]
then
    rm logs/free.txt
fi
touch logs/free.txt

# print field titles
printf "Time\\Zones\t" >> logs/managed.txt
printf "Time\\Zones\t" >> logs/free.txt

cat /proc/zoneinfo | grep -e "Node *." | while read -r line
do
    node=$(echo $line | awk '{print $2}')
    zone=$(echo $line | awk '{print $4}')
    printf "Node %s Zone %s\t" $node $zone >> logs/managed.txt
    printf "Node %s Zone %s\t" $node $zone >> logs/free.txt
done
printf "\n" >> logs/managed.txt
printf "\n" >> logs/free.txt

# periodically gleaning zoneinfo
while true; do
    time=$(date '+%Y-%m-%d:%H:%M:%S')
    # print managed
    printf "%s\t" $time >> logs/managed.txt
    cat /proc/zoneinfo | grep -e "managed" | while read -r line
    do
        managed_mb=$(echo $line | awk '{print $2}')
        printf "%d MB\t" $managed_mb >> logs/managed.txt
    done
    printf "\n" >> logs/managed.txt

    # print free
    printf "%s\t" $time >> logs/free.txt
    cat /proc/zoneinfo | grep -e "pages free" | while read -r line
    do
        free_mb=$(echo $line | awk '{print $3}')
        printf "%d MB\t" $free_mb >> logs/free.txt
    done
    printf "\n" >> logs/free.txt

    bash ./count_down_timer.sh 0 1 0
done

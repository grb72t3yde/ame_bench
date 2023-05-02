#!/bin/bash

run_with_ame="$1"
workload="$2"
item_num="$3"
item_size="$4"

if [[ -f logs/managed.txt ]]
then
    rm logs/managed_${run_with_ame}_${workload}_${item_num}_${item_size}.txt
fi
touch logs/managed_${run_with_ame}_${workload}_${item_num}_${item_size}.txt

if [[ -f logs/free.txt ]]
then
    rm logs/free_${run_with_ame}_${workload}_${item_num}_${item_size}.txt
fi
touch logs/free_${run_with_ame}_${workload}_${item_num}_${item_size}.txt

if [[ -f logs/total.txt ]]
then
    rm logs/total_${run_with_ame}_${workload}_${item_num}_${item_size}.txt
fi
touch logs/total_${run_with_ame}_${workload}_${item_num}_${item_size}.txt

if [[ -f logs/swap.txt ]]
then
    rm logs/swap_${run_with_ame}_${workload}_${item_num}_${item_size}.txt
fi
touch logs/swap_${run_with_ame}_${workload}_${item_num}_${item_size}.txt

# print field titles
printf "Time\\Zones\t" >> logs/managed_${run_with_ame}_${workload}_${item_num}_${item_size}.txt
printf "Time\\Zones\t" >> logs/free_${run_with_ame}_${workload}_${item_num}_${item_size}.txt
printf "      date     time $(free -m | grep total | sed -E 's/^    (.*)/\1/g')\n" >> logs/total_${run_with_ame}_${workload}_${item_num}_${item_size}.txt

cat /proc/zoneinfo | grep -e "Node *." | while read -r line
do
    node=$(echo $line | awk '{print $2}')
    zone=$(echo $line | awk '{print $4}')
    printf "Node %s Zone %s\t" $node $zone >> logs/managed_${run_with_ame}_${workload}_${item_num}_${item_size}.txt
    printf "Node %s Zone %s\t" $node $zone >> logs/free_${run_with_ame}_${workload}_${item_num}_${item_size}.txt
done
printf "\n" >> logs/managed_${run_with_ame}_${workload}_${item_num}_${item_size}.txt
printf "\n" >> logs/free_${run_with_ame}_${workload}_${item_num}_${item_size}.txt

# periodically gleaning zoneinfo
while true; do
    time=$(date '+%Y-%m-%d@%H:%M:%S')
    # print managed
    printf "%s\t" $time >> logs/managed_${run_with_ame}_${workload}_${item_num}_${item_size}.txt
    cat /proc/zoneinfo | grep -e "managed" | while read -r line
    do
        managed_mb=$(echo $line | awk '{print $2}')
        printf "%d\t" $managed_mb >> logs/managed_${run_with_ame}_${workload}_${item_num}_${item_size}.txt
    done
    printf "\n" >> logs/managed_${run_with_ame}_${workload}_${item_num}_${item_size}.txt

    # print free
    printf "%s\t" $time >> logs/free_${run_with_ame}_${workload}_${item_num}_${item_size}.txt
    cat /proc/zoneinfo | grep -e "pages free" | while read -r line
    do
        free_mb=$(echo $line | awk '{print $3}')
        printf "%d\t" $free_mb >> logs/free_${run_with_ame}_${workload}_${item_num}_${item_size}.txt
    done
    printf "\n" >> logs/free_${run_with_ame}_${workload}_${item_num}_${item_size}.txt

    # print total
    printf "%s $(free -m | grep Mem: | sed 's/Mem://g')\n" $time >> logs/total_${run_with_ame}_${workload}_${item_num}_${item_size}.txt

    # print swap usage
    printf "%s $(free -m | grep Swap: | sed 's/Mem://g')\n" $time >> logs/swap_${run_with_ame}_${workload}_${item_num}_${item_size}.txt

    bash ./count_down_timer.sh 0 0 10
done

#!/bin/bash

nr_memcached_ins=5

sz_mem_memcached_ins=16384

default_port=11211

for (( i = 0; i < ${nr_memcached_ins}; ++i ))
do
    ../submodules/memcached/memcached -m ${sz_mem_memcached_ins} -p $((default_port + i)) &
done



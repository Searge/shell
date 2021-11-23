#!/usr/bin/env bash
source read_line.sh

IPs="10.0.0"

array=()

for i in {1..9}; do
    array+=("$IPs.$i")
done

for value in "${array[@]}"; do
    traceroute -T "${value}" | read_line
done

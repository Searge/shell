#!/usr/bin/env bash
source read_line.sh

IPs="10.0.0"

array=()

for i in {1..9}; do
    ping $IPs.$i -c 1 -w 5 >/dev/null &&
        array+=("$IPs.$i")
done

for value in "${array[@]}"; do
    traceroute -T "${value}" | read_line
done

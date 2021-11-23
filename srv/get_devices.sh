#!/usr/bin/env bash
set -e

IPs="10.0.0"

array=()

for i in {1..9}; do
    array+=("$IPs.$i")
done

for value in "${array[@]}"; do
    echo "${value}"
done

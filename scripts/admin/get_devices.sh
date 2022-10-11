#!/usr/bin/env bash
source .env

get_devices() {
    ip_array=()

    for i in {2..254}; do
        IP="$IPs.$i"
        ping "$IP" -c 1 -w 2 >/dev/null &&
            ip_array+=("$IP") &&
            echo "$IP"
    done

    for ip in "${ip_array[@]}"; do
        host "${ip}"
    done
}

get_devices

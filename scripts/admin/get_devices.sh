#!/usr/bin/env bash
source .env

# Pass the first argument to the script
# Example: ./get_devices.sh 10.0.0
IPs="$1"

get_devices() {
  # Initialize an empty array of IPs
  ip_array=()

  for i in {2..254}; do
    # Concatenate the IPs with the suggested range number
    IP="$IPs.$i"

    # Ping the IP and if it's alive, add it to the array
    ping "$IP" -c 1 -w 2 >/dev/null &&
      ip_array+=("$IP") &&
      echo "$IP"
  done

  # Loop through the array and get the hostnames
  for ip in "${ip_array[@]}"; do
    host "${ip}"
  done
}

# Call the function
get_devices

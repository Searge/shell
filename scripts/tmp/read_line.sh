#!/usr/bin/env bash

read_line() {
  while IFS= read -r line; do
    lastline="$line"
  done

  echo "$lastline"
}

[[ "${FUNCNAME[0]}" == "source" ]] &&
  return read_line

# Get arguments from the command line
Arguments=("$@")

# Parse the arguments to variables:
for var in "${Arguments[@]}"; do
  if [[ "$var" == *=* ]]; then
    key="${var%%=*}"
    value="${var#*=}"
    eval "$key"="$value"
  fi
done

echo "$VAR" "$VAR2"

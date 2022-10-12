#!/bin/bash

# Read certain line from file
function read_line {
  local file="$1" # File path
  local line="$2" # Line number
  local result=""

  if [[ -f "${file}" ]]; then
    result=$(sed -n "${line}p" "${file}")
  fi

  echo "${result}"
}

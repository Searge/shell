#!/usr/bin/env bash

read_line() {
    while IFS= read -r line; do
        lastline="$line"
    done

    echo "$lastline"
}

[[ "${FUNCNAME[0]}" == "source" ]] &&
    return read_line

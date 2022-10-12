#!/usr/bin/env bash

# Storre files in an array
files_to_array() {
    local directory="$1"
    local pattern="$2"
    local result=()

    for file in "${directory}"/*; do
        if [[ -f "${file}" ]]; then
            if [[ "${pattern}" ]]; then
                if [[ "${file}" =~ "${pattern}" ]]; then
                    result+=("${file}")
                fi
            else
                result+=("${file}")
            fi
        fi
    done

    echo "${result[@]}"
}

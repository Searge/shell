#!/usr/bin/env bash
set -e

# Wrapper for remote script execution
function run_remote() {
    local script="$1"
    shift
    local args
    printf -v args '%q ' "$@"
    ssh -o StrictHostKeyChecking=no ${SERVER} "bash -s" <<EOF

    # pass quoted arguments through for parsing by remote bash
    set -- $args

    # substitute literal script text into heredoc
    $(<"$script")
EOF
}

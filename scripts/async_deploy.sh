#!/usr/bin/env bash

# List of images to process
DOCKER_IMAGES=(
    image1
    image2
    image3
)

# Registry configuration
REGISTRY1_PUSH_TIME=5  # seconds
REGISTRY2_PUSH_TIME=1  # seconds

# FIFO paths
REGISTRY1_FIFO="/tmp/reg1.fifo"
REGISTRY2_FIFO="/tmp/reg2.fifo"

# Build a docker image.
#
# Args:
#   $1: The name of the image to build.
#
# Output:
#   Prints a message indicating the start and end of the build process.
function docker_build() {
    echo "Start build for $1"
    sleep 1.5
    echo "End build for $1"
}

# Push a docker image to a registry.
#
# Args:
#   $1: The name of the image to push.
#   $2: The number of seconds to sleep, simulating the push process.
#
# Output:
#   Prints a message indicating the start and end of the push process.
function docker_push() {
    echo "Start push for $1"
    sleep "$2"
    echo "End push for $1"
}

# Send a webhook notification.
#
# Args:
#   $1: The name of the image for which to send a webhook notification.
#
# Output:
#   Prints a message indicating the start and end of the webhook notification process.
function webhook() {
    echo "Start webhook for $1"
    sleep 0.1
    echo "End webhook for $1"
}

# Create FIFO for an image and return the paths
#
# Args:
#   $1: Image name
#
# Output:
#   Returns paths to both registry FIFOs for the image
function create_image_fifos() {
    local image_name=$1
    local reg1_fifo="/tmp/reg1-${image_name}.fifo"
    local reg2_fifo="/tmp/reg2-${image_name}.fifo"

    mkfifo "$reg1_fifo"
    mkfifo "$reg2_fifo"

    echo "$reg1_fifo $reg2_fifo"
}

# Process a single image (build, wait for registry pushes, webhook)
#
# Args:
#   $1: Image name
#   $2: Registry 1 FIFO path for this image
#   $3: Registry 2 FIFO path for this image
function process_single_image() {
    local image_name=$1
    local reg1_fifo=$2
    local reg2_fifo=$3

    docker_build "$image_name"
    (
        cat "$reg1_fifo" &>/dev/null &
        wait_for_reg1=$!
        cat "$reg2_fifo" &>/dev/null &
        wait_for_reg2=$!
        wait $wait_for_reg1 $wait_for_reg2
        webhook "$image_name"
        rm "$reg1_fifo" "$reg2_fifo"
    ) &
}

# Start registry push processes
#
# Args:
#   $1: Registry FIFO path
#   $2: Registry name
#   $3: Push time in seconds
function start_registry_push() {
    local registry_fifo=$1
    local registry_name=$2
    local push_time=$3

    xargs -I{} bash -c "docker_push ${registry_name}/{} ${push_time}; echo > /tmp/${registry_name}-{}.fifo" <"$registry_fifo" &
}

# Main function to orchestrate the deployment process
function main() {
    # Export functions for subshell usage
    export -f docker_build docker_push webhook

    # Create main registry FIFOs
    mkfifo "$REGISTRY1_FIFO"
    mkfifo "$REGISTRY2_FIFO"

    # Start main process
    (
        exec 3>"$REGISTRY1_FIFO"
        exec 4>"$REGISTRY2_FIFO"

        for image in "${DOCKER_IMAGES[@]}"; do
            read -r reg1_fifo reg2_fifo <<< "$(create_image_fifos "$image")"
            process_single_image "$image" "$reg1_fifo" "$reg2_fifo"
            echo "$image" >&3
            echo "$image" >&4
        done

        # Close and cleanup main FIFOs
        exec 3>&-
        exec 4>&-
        rm "$REGISTRY1_FIFO" "$REGISTRY2_FIFO"
    ) &

    # Start registry push processes
    start_registry_push "$REGISTRY1_FIFO" "reg1" "$REGISTRY1_PUSH_TIME"
    start_registry_push "$REGISTRY2_FIFO" "reg2" "$REGISTRY2_PUSH_TIME"

    # Wait for all background processes to complete
    wait
}

# Execute main function
main

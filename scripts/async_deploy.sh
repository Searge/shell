#!/usr/bin/env bash

LIST=(
  image1
  image2
  image3
  )

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

export -f docker_build
export -f docker_push
export -f webhook

mkfifo /tmp/reg1.fifo
mkfifo /tmp/reg2.fifo
(
  exec 3>/tmp/reg1.fifo
  exec 4>/tmp/reg2.fifo
  for i in "${LIST[@]}"; do
    mkfifo "/tmp/reg1-${i}.fifo"
    mkfifo "/tmp/reg2-${i}.fifo"
    docker_build "${i}"
    (
      cat "/tmp/reg1-${i}.fifo" &>/dev/null &
      wait_for_reg1=$!
      cat "/tmp/reg2-${i}.fifo" &>/dev/null &
      wait_for_reg2=$!
      wait $wait_for_reg1 $wait_for_reg2
      webhook "${i}"
      rm "/tmp/reg1-${i}.fifo" "/tmp/reg2-${i}.fifo"
    ) &
    echo "${i}" >&3
    echo "${i}" >&4
  done
  exec 3>&-
  exec 4>&-
  rm /tmp/reg1.fifo /tmp/reg2.fifo
) &

xargs -I{} bash -c "docker_push reg1/{} 5; echo > /tmp/reg1-{}.fifo" </tmp/reg1.fifo &
xargs -I{} bash -c "docker_push reg2/{} 1; echo > /tmp/reg2-{}.fifo" </tmp/reg2.fifo &
wait

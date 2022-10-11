#!/usr/bin/env bash
lsof | grep log4j

for file in $(lsof |
  grep log4j-core |
  awk 'match($0,/\/([^ ])*|\/([^$])*/){print substr($0,RSTART,RLENGTH)}' |
  sort |
  uniq); do
  echo "$(hostname);${file};$(zipgrep -h Log4jReleaseVersion "$file" | cut -d ' ' -f 2)"
done

dpkg -l | grep log

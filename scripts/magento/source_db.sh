#!/bin/bash

set -e

project=$(hostname)
Date='13.05'

ls -lh "DUMP/${project}-${Date}.sql.gz"

zcat "DUMP/${project}-${Date}.sql.gz" | mysql -u${project} \
  -p${project} ${project} &&
  echo "$(date): db imported" >>log/dump.log

exit $?

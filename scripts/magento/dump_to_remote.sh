#!/bin/bash
set -o pipefail

DUMPS='/tmp/dumps'
DB_NAME='db_name'

USER='user'
BASTION='bastion'
PORT='22'
HOST_SQL='privatehost'

echo "All dumps"
ls -lh ${DUMPS}
echo "Show latest"
ls -t ${DUMPS}/${DB_NAME}_*.sql.gz | tail -n 1

rsync -azhP ${DUMPS}/${DB_NAME}_*.sql.gz \
    -e "ssh -A ${USER}@${BASTION} -p $PORT ssh" ${USER}@${HOST_SQL}:/tmp

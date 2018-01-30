#!/usr/bin/env bash

ssh ${BACKUP_REMOTE} << EOF
cd ${BACKUP_REMOTE_ROOT}
if [ -f ${BACKUP} ]; then
  (>&2 echo "extracting previous backup...")
  tar -xf ${BACKUP}
elif [ ! -d ${BACKUP_DIR} ]; then
  mkdir ${BACKUP_DIR}
fi
EOF

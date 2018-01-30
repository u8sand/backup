#!/usr/bin/env bash

ssh ${BACKUP_REMOTE} << EOF
$(typeset exit_clean)
cd ${BACKUP_REMOTE_ROOT}
if [ -f ${BACKUP} ]; then
  (>&2 echo "extracting previous backup...")
  tar -xf ${BACKUP}
  if [ $? -ne 0 ]; then
    exit_clean $? "previous backup extract failed..."
  fi
elif [ ! -d ${BACKUP_DIR} ]; then
  mkdir ${BACKUP_DIR}
fi
EOF
if [ $? -ne 0 ]; then
  exit_clean $? "previous backup extract failed..."
fi

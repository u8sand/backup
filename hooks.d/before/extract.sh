#!/usr/bin/env bash

if [ -f ${BACKUP} ]; then
  (>&2 echo "extracting previous backup...")
  tar -xf ${BACKUP}
  if [ $? -ne 0 ]; then
    exit_clean $? "previous backup extract failed..."
  fi
elif [ ! -d ${BACKUP_DIR} ]; then
  mkdir ${BACKUP_DIR}
fi

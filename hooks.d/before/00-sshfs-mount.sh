#!/usr/bin/env bash

if [ ! -d ${BACKUP_DIR} ]; then
  mkdir -p ${BACKUP_DIR}
fi

(>&2 echo "mounting remote backup_dir...")
sshfs ${BACKUP_REMOTE}:${BACKUP_REMOTE_ROOT} ${BACKUP_DIR}
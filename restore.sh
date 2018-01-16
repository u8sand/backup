#!/usr/bin/env bash

BACKUP_ROOT=/
BACKUP=backup.tar.gz
HOOKS_DIR=hooks.d

handle_hook_dir() {
  DIR=$1
  if [ -d "${DIR}" ]; then
    find "${DIR}" -type f -regex ".*\.sh" -exec {} \;
  fi
}

handle_hook_dir "${HOOKS_DIR}/before-restore"
tar -xf ${BACKUP} -C ${BACKUP_ROOT}
handle_hook_dir "${HOOKS_DIR}/after-restore"

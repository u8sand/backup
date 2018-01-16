#!/usr/bin/env bash

export BACKUP_ROOT=/
export BACKUP=backup.tar.gz
export HOOKS_DIR=hooks.d

handle_hook_dir() {
  DIR=$1
  if [ -d "${DIR}" ]; then
    find "${DIR}" -type f -regex ".*\.sh" -exec {} \;
  fi
}

handle_hook_dir "${HOOKS_DIR}/before"
handle_hook_dir "${HOOKS_DIR}/before-restore"
tar -xf ${BACKUP} -C ${BACKUP_ROOT}
handle_hook_dir "${HOOKS_DIR}/after-restore"
handle_hook_dir "${HOOKS_DIR}/after"

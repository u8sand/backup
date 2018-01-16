#!/usr/bin/env bash

if [ "$UID" != "0" ]; then
  echo "You must run this script as root." 1>&2
  exit 1
fi

SRCDIR=$(dirname "$(realpath $0)")
cd ${SRCDIR}
source config.sh

handle_hook_dir "${HOOKS_DIR}/before"
handle_hook_dir "${HOOKS_DIR}/before-restore"

tar -xf ${BACKUP} -C ${BACKUP_ROOT}

handle_hook_dir "${HOOKS_DIR}/after-restore"
handle_hook_dir "${HOOKS_DIR}/after"

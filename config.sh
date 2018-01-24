#!/usr/bin/env bash

export BACKUP_ROOT=/
export BACKUP=backup.tar.gz
export BACKUP_DIR=backup
export WHITELIST_DIR=whitelist.d
export BLACKLIST_DIR=blacklist.d
export HOOKS_DIR=hooks.d
export FILELIST_CMD=./filelist.py
export TODAY=$(date +'%Y-%m-%d')

handle_hook_dir() {
  DIR=$1
  if [ -d "${DIR}" ]; then
    find "${DIR}" -type f -regex ".*\.sh" -exec bash {} \;
  fi
}

# Custom exports will be available in hooked scripts
# export MY_CUSTOM_VARIABLE="my_value"

#!/usr/bin/env bash

export BACKUP_ROOT=/
export BACKUP=backup.tar.gz
export BACKUP_DIR=backup
export WHITELIST_DIR=whitelist.d
export BLACKLIST_DIR=blacklist.d
export HOOKS_DIR=hooks.d

handle_hook_dir() {
  DIR=$1
  if [ -d "${DIR}" ]; then
    find "${DIR}" -type f -regex ".*\.sh" -exec bash {} \;
  fi
}

# Custom exports will be available in hooked scripts
export PARTITION_BACKUP_DIR=/root/partitions
export PACMAN_BACKUP_DIR=/root/pacman
export AUR_HELPER=yaourt

write_and_echo_file() {
  FILE=$1
  (>&2 echo "generating ${FILE}...")
  cat > ${FILE}
  echo ${FILE}
}
export -f write_and_echo_file

#!/usr/bin/env bash

if [ "$UID" != "0" ]; then
  echo "WARN: You probably want to run this script as root." 1>&2
  echo "In particular, if you expect to be backing up root-owned files." 1>&2
fi

SRCDIR=$(dirname "$(realpath $0)")
cd ${SRCDIR}
source config.sh

handle_dir() {
  # Output each .txt file and execute each .sh file
  #  in the directory argument, assembling a unique
  #  list of files.
  DIR=$1
  if [ -d "${DIR}" ]; then
    (>&2 echo "building list from ${DIR}...")
    find "${DIR}" -type f \
      \( -regex ".*\.txt$" -exec cat {} \; \) -o \
      \( -regex ".*\.sh$" -exec bash {} \; \) \
      | sort
    if [ $? -ne 0 ]; then
      exit_clean $? "handle_dir ${DIR} failed..."
    fi
  fi
}

build_file_list() {
  (>&2 echo "building file list...")
  ${FILELIST_CMD} $1 $2
  if [ $? -ne 0 ]; then
    exit_clean $? "${FILELIST_CMD} failed..."
  fi
}

rsync_files_from() {
  build_file_list \
    <(handle_dir ${WHITELIST_DIR}) \
    <(handle_dir ${BLACKLIST_DIR}) \
  | awk "/.*/ {
      print \"+\", \$0
    } END {
      print \"- ***\"
    }"
  if [ $? -ne 0 ]; then
    exit_clean $? "rsync_files_from failed..."
  fi
}

rsync_backup() {
  (>&2 echo "excecuting rsync...")
  rsync \
    --acls \
    --backup \
    --backup-dir="../archives/${TODAY}" \
    --checksum \
    --compress \
    --delete \
    --delete-excluded \
    --executability \
    --include-from=- \
    --fuzzy \
    --group \
    --links \
    --no-devices \
    --no-specials \
    --owner \
    --perms \
    --progress \
    --relative \
    --recursive \
    --times \
    --verbose \
    --verbose \
    --xattrs \
    $@ \
    "${BACKUP_ROOT}" \
    "${BACKUP_DIR}/root/"
  if [ $? -ne 0 ]; then
    exit_clean $? "rsync failed..."
  fi
}

handle_hook_dir "${HOOKS_DIR}/before"
handle_hook_dir "${HOOKS_DIR}/before-backup"
rsync_files_from | rsync_backup $@
handle_hook_dir "${HOOKS_DIR}/after-backup"
handle_hook_dir "${HOOKS_DIR}/after"

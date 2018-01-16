#!/usr/bin/env bash

export BACKUP_ROOT=/
export BACKUP=backup.tar.gz
export BACKUP_DIR=backup
export WHITELIST_DIR=whitelist.d
export BLACKLIST_DIR=blacklist.d
export HOOKS_DIR=hooks.d

if [ "$UID" != "0" ]; then
  echo "You must run this script as root." 1>&2
  exit 1
fi

SRCDIR=$(dirname "$(realpath $0)")
cd ${SRCDIR}

ensure_full_paths() {
  # Given paths like /root/sub/dir/
  #  produce multiple items:
  #  /root/
  #  /root/sub/
  #  /root/sub/dir/
  python - <(cat) << END
import sys
L = set()
for l in open(sys.argv[1], 'r').read().splitlines():
  ls = l.split('/')
  for i in range(2, len(ls)):
    L.add('/'.join(ls[:i])+'/')
  L.add(l)
print('\n'.join(L))
END
}

handle_dir() {
  # Output each .txt file and execute each .sh file
  #  in the directory argument, assembling a unique
  #  list of files.
  DIR="$1"
  if [ -d "${DIR}" ]; then
    (>&2 echo "building list from ${DIR}...")
    find "${DIR}" -type f \
      \( -regex ".*\.txt$" -exec cat {} \; \) -o \
      \( -regex ".*\.sh$" -exec bash {} \; \) \
      | ensure_full_paths \
      | sort
  fi
}

handle_hook_dir() {
  DIR=$1
  if [ -d "${DIR}" ]; then
    find "${DIR}" -type f -regex ".*\.sh" -exec bash {} \;
  fi
}

rsync_filters() {
  (>&2 echo "building rsync filter...")
  cat <(comm \
        <(handle_dir ${WHITELIST_DIR}) \
        <(handle_dir ${BLACKLIST_DIR}) \
        | sed 's/^\t\t\(.*\)$/+ \1/; s/^\t\(.*\)$/- \1/; s/^[^+-]/+ \0/' \
      ) \
      <(echo "- $(realpath ${BACKUP}))") \
      <(echo "- $(realpath ${BACKUP_DIR}))") \
    | LC_ALL=C sort
}

rsync_backup() {
  (>&2 echo "excecuting rsync...")
  rsync \
    --acls \
    --archive \
    --backup \
    --backup-dir="../archives/$(date +'%Y-%m-%d')" \
    --checksum \
    --compress \
    --delete \
    --delete-excluded \
    --exclude-from=- \
    --executability \
    --fuzzy \
    --progress \
    --relative \
    --verbose \
    --xattrs \
    --no-specials \
    --no-devices \
    --links \
    "${BACKUP_ROOT}" \
    "${BACKUP_DIR}/root/"
}

handle_hook_dir "${HOOKS_DIR}/before"
handle_hook_dir "${HOOKS_DIR}/before-backup"
rsync_filters | rsync_backup
handle_hook_dir "${HOOKS_DIR}/after-backup"
handle_hook_dir "${HOOKS_DIR}/after"

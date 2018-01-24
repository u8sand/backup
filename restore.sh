#!/usr/bin/env bash

if [ "$UID" != "0" ]; then
  echo "WARN: You probably want to run this script as root." 1>&2
  echo "In particular, if you expect to be backing up root-owned files." 1>&2
fi

SRCDIR=$(dirname "$(realpath $0)")
cd ${SRCDIR}
source config.sh

rsync_restore() {
  (>&2 echo "excecuting rsync...")
  rsync \
    --acls \
    --backup \
    --backup-dir="archives/$(date +'%Y-%m-%d')" \
    --checksum \
    --compress \
    --executability \
    --fuzzy \
    --group \
    --links \
    --no-devices \
    --no-specials \
    --owner \
    --perms \
    --progress \
    --recursive \
    --times \
    --verbose \
    --verbose \
    --xattrs \
    $@ \
    "${BACKUP_DIR}/root/" \
    "${BACKUP_ROOT}"
}

handle_hook_dir "${HOOKS_DIR}/before"
handle_hook_dir "${HOOKS_DIR}/before-restore"
rsync_restore $@
handle_hook_dir "${HOOKS_DIR}/after-restore"
handle_hook_dir "${HOOKS_DIR}/after"

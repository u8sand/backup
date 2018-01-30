#!/usr/bin/env bash

(>&2 echo "unmounting sshfs...")
fusermount -u ${BACKUP_DIR}
rmdir ${BACKUP_DIR}

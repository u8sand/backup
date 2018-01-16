#!/usr/bin/env bash

(>&2 echo "compressing backup...")
tar -cf ${BACKUP} ${BACKUP_DIR}
(>&2 echo "removing local tree...")
rm -r ${BACKUP_DIR}

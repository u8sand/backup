#!/usr/bin/env bash

ssh ${BACKUP_REMOTE} << EOF
cd ${BACKUP_REMOTE_ROOT}
(>&2 echo "compressing backup...")
tar -cf ${BACKUP} ${BACKUP_DIR}
(>&2 echo "removing local tree...")
rm -r ${BACKUP_DIR}
EOF

#!/usr/bin/env bash

ssh ${BACKUP_REMOTE} << EOF
$(typeset exit_clean)
cd ${BACKUP_REMOTE_ROOT}
(>&2 echo "compressing backup...")
tar -cf ${BACKUP} ${BACKUP_DIR}
if [ $? -ne 0 ]; then
  exit_clean $? "backup compression failed..."
fi
(>&2 echo "removing local tree...")
rm -r ${BACKUP_DIR}
EOF
if [ $? -ne 0 ]; then
  exit_clean $? "backup compression failed..."
fi

#!/usr/bin/env bash

ls ${BACKUP_DIR}/archives/ \
  | awk 'BEGIN {
  split(ENVIRON["TODAY"], "-", TODAY);
  CUTOFF = (TODAY[0]-1)"-"TODAY[1]"-"TODAY[2];
} $0 <= CUTOFF {
  print $0
}' | while read DIR; do
  (>&2 echo "removing old archive ${DIR}...")
  rm -r ${BACKUP_DIR}/archives/${DIR}
done

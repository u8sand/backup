#!/usr/bin/sh

if [ ! -d ${PARTITION_BACKUP_DIR} ]; then
  mkdir -p ${PARTITION_BACKUP_DIR}
fi

lsblk -l \
 | awk '$6 == "disk" { print $1 }' \
 | while read DISK; do
  sfdisk --dump /dev/${DISK} \
   | write_and_echo_file "${PARTITION_BACKUP_DIR}/${DISK}"
done

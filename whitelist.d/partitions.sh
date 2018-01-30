#!/usr/bin/sh

if [ ! -d ${PARTITION_BACKUP_DIR} ]; then
  mkdir -p ${PARTITION_BACKUP_DIR}
fi

lsblk -l \
 | awk '$6 == "disk" { print $1 }' \
 | while read DISK; do
  sfdisk --dump /dev/${DISK} \
   | write_and_echo_file "${PARTITION_BACKUP_DIR}/${DISK}"
  if [ $? -ne 0 ]; then
    exit_clean $? "failed to dump ${DISK} partition table..."
  fi
done
if [ $? -ne 0 ]; then
  exit_clean $? "failed to enumerate disks..."
fi

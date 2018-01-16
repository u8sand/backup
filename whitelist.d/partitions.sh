#!/usr/bin/sh

PARTITION_BACKUP_DIR=/root/partitions

write_and_echo_file() {
  FILE=$1
  (>&2 echo "generating ${FILE}...")
  cat > ${FILE}
  echo ${FILE}
}

if [ ! -d ${PARTITION_BACKUP_DIR} ]; then
  mkdir -p ${PARTITION_BACKUP_DIR}
fi

lsblk -l \
 | awk '$6 == "disk" { print $1 }' \
 | while read DISK; do
  sfdisk --dump /dev/${DISK} \
   | write_and_echo_file "${PARTITION_BACKUP_DIR}/${DISK}"
done

#!/usr/bin/sh

if [ ! -d ${PACMAN_BACKUP_DIR} ]; then
  mkdir -p ${PACMAN_BACKUP_DIR}
fi

pacman -Qenq | write_and_echo_file "${PACMAN_BACKUP_DIR}/archpacks.txt"
pacman -Qdnq | write_and_echo_file "${PACMAN_BACKUP_DIR}/archdeps.txt"
pacman -Qemq | write_and_echo_file "${PACMAN_BACKUP_DIR}/aurpacks.txt"
pacman -Qdmq | write_and_echo_file "${PACMAN_BACKUP_DIR}/aurdeps.txt"
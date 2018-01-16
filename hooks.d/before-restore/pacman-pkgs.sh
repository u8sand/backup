#!/usr/bin/sh

PACMAN_BACKUP_DIR=/root/pacman
AUR_HELPER=yaourt

cat "${PACMAN_BACKUP_DIR}/archpacks.txt" | pacman -S --needed --asexplicit -
cat "${PACMAN_BACKUP_DIR}/archdeps.txt" | pacman -S --needed --asdeps -
cat "${PACMAN_BACKUP_DIR}/aurpacks.txt" | AUR_HELPER -S --needed --asexplicit -
cat "${PACMAN_BACKUP_DIR}/aurdeps.txt" | AUR_HELPER -S --needed --asdeps -

#!/usr/bin/sh

cat "${PACMAN_BACKUP_DIR}/archpacks.txt" | pacman_helper --asexplicit
cat "${PACMAN_BACKUP_DIR}/archdeps.txt" | pacman_helper --asdeps
cat "${PACMAN_BACKUP_DIR}/aurpacks.txt" | aur_helper --asexplicit
cat "${PACMAN_BACKUP_DIR}/aurdeps.txt" | aur_helper --asdeps

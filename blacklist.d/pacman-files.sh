#!/usr/bin/env sh

pacman -Qlq | grep -v '/$'
if [ $? -ne 0 ]; then
  exit_clean $? "failed to get pacman files..."
fi

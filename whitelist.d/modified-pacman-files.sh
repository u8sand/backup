#!/usr/bin/env sh

pacman -Qii \
  | awk '/^MODIFIED/{print $2}'
if [ $? -ne 0 ]; then
  exit_clean $? "failed to get modified pacman files..."
fi

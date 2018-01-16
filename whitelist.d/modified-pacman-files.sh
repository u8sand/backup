#!/usr/bin/env sh

pacman -Qii \
  | awk '/^MODIFIED/{print $2}'

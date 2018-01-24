#!/usr/bin/env sh

pacman -Qlq | grep -v '/$'

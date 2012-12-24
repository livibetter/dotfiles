#!/bin/bash

TMP="$(readlink /usr/src/linux)"
DIR_KERNEL="${TMP%/}"
KERNEL_CONFIG="/usr/src/$DIR_KERNEL/.config"

cp -dR --preserve=mode,timestamps kernel-config "$KERNEL_CONFIG"

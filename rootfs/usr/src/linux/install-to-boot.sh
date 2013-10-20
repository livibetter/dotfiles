#!/bin/bash

TMP="$(readlink /usr/src/linux)"
DIR_KERNEL="${TMP%/}"
KC=/usr/src/$DIR_KERNEL/.config

VERSION=${DIR_KERNEL#*-}

# I really like to do in bad way, bite me! XD
eval "$(grep LOCALVERSION= "$KC")"

BOOTIMG=/boot/kernel-$(uname -m)-$VERSION$CONFIG_LOCALVERSION

if cp /usr/src/$DIR_KERNEL/arch/$(uname -m)/boot/bzImage "$BOOTIMG"; then
  grub2-mkconfig -o /boot/grub/grub.cfg
fi

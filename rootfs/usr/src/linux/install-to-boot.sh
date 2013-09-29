#!/bin/bash

TMP="$(readlink /usr/src/linux)"
DIR_KERNEL="${TMP%/}"
KC=/usr/src/$DIR_KERNEL/.config

VERSION=${DIR_KERNEL#*-}

# I really like to do in bad way, bite me! XD
eval "$(grep LOCALVERSION= "$KC")"

BOOTIMG=/boot/kernel-$(uname -m)-$VERSION$CONFIG_LOCALVERSION

if cp /usr/src/$DIR_KERNEL/arch/$(uname -m)/boot/bzImage "$BOOTIMG"; then
  sed -i "
/splashimage/ a\\
\\
title Gentoo Linux $VERSION$CONFIG_LOCALVERSION\\
root (hd0,0)\\
kernel /boot/kernel-$(uname -m)-$VERSION$CONFIG_LOCALVERSION root=/dev/sda3 quiet\\
\\
title Gentoo Linux $VERSION$CONFIG_LOCALVERSION (recuse)\\
root (hd0,0)\\
kernel /boot/kernel-$(uname -m)-$VERSION$CONFIG_LOCALVERSION root=/dev/sda3 init=/bin/bb
" /boot/grub/grub.conf
fi

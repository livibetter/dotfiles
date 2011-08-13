#!/bin/bash
# Created at 2011-05-18T15:02:53Z

TMP="$(readlink /usr/src/linux)"
DIR_KERNEL="${TMP%/}"
KERNEL_CONFIG="/usr/src/$DIR_KERNEL/.config"

if (( $# == 0 )); then
	echo "$0 <gzipfile>" >&2
	exit 1
fi

gunzip -c "$1" > "$KERNEL_CONFIG"

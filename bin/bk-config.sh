#!/bin/bash
# Created at 2011-05-18T15:02:53Z

TMP="$(readlink /usr/src/linux)"
DIR_KERNEL="${TMP%/}"
KERNEL_CONFIG="/usr/src/$DIR_KERNEL/.config"

if [[ ! -f "$KERNEL_CONFIG" ]]; then
	echo ".config cannot be found at $DIR_KERNEL" >&2
	exit 1
fi

# I really like to do in bad way, bite me! XD
eval "$(grep LOCALVERSION= "$KERNEL_CONFIG")"
BK_NAME="${DIR_KERNEL}${CONFIG_LOCALVERSION}"
BK_FILE="${BK_NAME}.config.gz"

if [[ ! -f "$BK_FILE" ]]; then
	gzip -c "$KERNEL_CONFIG" > "$BK_FILE"
	echo "Backup as $BK_FILE"
else
	echo "Already a backup for $BK_NAME"
fi

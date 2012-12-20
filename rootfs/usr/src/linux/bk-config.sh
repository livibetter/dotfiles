#!/bin/bash

TMP="$(readlink /usr/src/linux)"
DIR_KERNEL="${TMP%/}"
KERNEL_CONFIG="/usr/src/$DIR_KERNEL/.config"

if [[ ! -f "$KERNEL_CONFIG" ]]; then
  echo ".config cannot be found at $DIR_KERNEL" >&2
  exit 1
fi

if ! diff kernel-config "$KERNEL_CONFIG" >/dev/null; then
  cp -a "$KERNEL_CONFIG" kernel-config
  echo "Saved"
else
  echo ".config unchanged."
fi

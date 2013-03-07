#!/bin/bash

DIR_KERNEL="$(readlink -f /usr/src/linux)"
KERNEL_CONFIG="$DIR_KERNEL/.config"
TARGET="kernel-config"

if [[ ! -f "$KERNEL_CONFIG" ]]; then
  echo ".config cannot be found at $DIR_KERNEL" >&2
  exit 1
fi

if ! cmp --silent "$TARGET" "$KERNEL_CONFIG"; then
  cp -dR --preserve=mode,timestamps "$KERNEL_CONFIG" "$TARGET"
  echo "$TARGET saved."
else
  echo "$KERNEL_CONFIG unchanged."
fi

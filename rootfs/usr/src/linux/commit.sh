#!/bin/bash

TMP="$(readlink /usr/src/linux)"
DIR_KERNEL="${TMP%/}"

# I really like to do in bad way, bite me! XD
eval "$(grep LOCALVERSION= kernel-config)"
msg="Update kernel .config ${DIR_KERNEL}${CONFIG_LOCALVERSION}"
(( $# )) && msg="$msg. $@"

git add kernel-config
git commit -m "$msg"

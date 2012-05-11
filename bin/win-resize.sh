#!/bin/bash
# Using xwininfo and wmctrl to resize a window
# Written by Yu-Jie Lin
# Public Domain

WIN_ID=$(xwininfo | egrep -om 1 '0x[0-9a-z]+')
W=$1
H=$2
X=${3:--1}
Y=${4:--1}

wmctrl -i -r $WIN_ID -e 0,$X,$Y,$W,$H

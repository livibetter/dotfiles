#!/bin/bash
# Using xwininfo and wmctrl to resize a window
# Written by Yu-Jie Lin
# Public Domain

W=$1
H=$2
X=${3:--1}
Y=${4:--1}

wmctrl -r :SELECT: -e 0,$X,$Y,$W,$H

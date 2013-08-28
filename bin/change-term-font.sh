#!/bin/bash
# Written by Yu-Jie Lin

FONTNAME='Envy Code R'
FONTSIZE='9'

while getopts "f:s:" opt; do
  case $opt in
    f)
      FONTNAME="$OPTARG"
      ;;
    s)
      FONTSIZE="$OPTARG"
      ;;
  esac
done

FONT="xft:$FONTNAME:style=Regular:size=$FONTSIZE:antialias=false"

printf '\e]710;%s\007' "$FONT"

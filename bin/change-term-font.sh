#!/bin/bash
# Written by Yu-Jie Lin

FONTNAME='Envy Code R'
FONTSIZE='9'
FONTSTYLE='Regular'

while getopts "f:s:S:" opt; do
  case $opt in
    f)
      FONTNAME="$OPTARG"
      ;;
    s)
      FONTSIZE="$OPTARG"
      ;;
    S)
      FONTSTYLE="$OPTARG"
      ;;
  esac
done

FONT="xft:$FONTNAME:style=$FONTSTYLE:size=$FONTSIZE:antialias=false"

printf '\e]710;%s\007' "$FONT"

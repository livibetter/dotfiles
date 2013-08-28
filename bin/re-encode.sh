#!/bin/bash
# Written by Yu-Jie Lin

# https://trac.ffmpeg.org/wiki/EncodeforYouTube
INFILE="$1"
OUTFILE="${INFILE%.*}.re-encoded.mkv"

ffmpeg \
  -i "$INFILE" \
  -c:v libx264 \
  -preset slow \
  -crf 18 \
  -pix_fmt yuv420p \
  "$OUTFILE"

#!/bin/bash
# Written by Yu-Jie Lin

OUTFILE=out.mkv
OPTS="-show_region 1"
POS=0,0
FPS=5
SIZE=1280x720

while getopts 'f:s:p:y:o:' opt; do
  case "$opt" in
    f)
      FPS=$OPTARG
      ;;
    s)
      SIZE=$OPTARG
      ;;
    p)
      POS=$OPTARG
      ;;
    o)
      OUTFILE="$OPTARG"
      ;;
  esac
done

REGION=":0.0+$POS"

# http://stackoverflow.com/questions/10166204/ffmpeg-screencast-recording-which-codecs-to-use
ffmpeg \
  -f x11grab \
  $OPTS \
  -r "$FPS" -s "$SIZE" -i "$REGION" \
  -vcodec ffvhuff -threads 0 \
  "$OUTFILE"

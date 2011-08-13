#!/bin/bash

WIDTH=840
HEIGHT=525
CLOUDS_JPG=~/.xplanet/clouds.jpg
CLOUDS_XPM=/tmp/clouds.xpm

read _ _ S_WIDTH S_HEIGHT _ <<<"$(xprop -root _NET_WORKAREA | sed 's/[^0-9]/ /g')"

{
TS=$(stat -c %Z "$CLOUDS_JPG")
if [[ ! -f "$CLOUDS_JPG" ]] || (($(date +%s) - TS >= 60 * 10)); then
	echo "Running xplanet.sh..." >&2
	xplanet.sh >&2
fi
if [[ ! -f "$CLOUDS_XPM" ]] || [[ "$TS" != "$(stat -c %Z "$CLOUDS_JPG")" ]]; then
	echo "Converting to XPM..." >&2
	convert "$CLOUDS_JPG" "xpm:$CLOUDS_XPM" >&2
fi
echo "^i($CLOUDS_XPM)"
} |
dzen2 \
	-x $((S_WIDTH - WIDTH)) -y $((S_HEIGHT - HEIGHT)) \
	-w $WIDTH -h $HEIGHT \
	-e 'leavetitle=exit;button3=exit;' \
	-p

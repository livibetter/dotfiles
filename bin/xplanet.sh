#!/bin/bash
# 2008-07-26T14:23:17+0800
X_DIR=~/.xplanet
OUTPUT=$X_DIR/clouds.jpg

GEOMETRY=840x525
# Google "LOCATION geographic coordinates"
LONGITUDE=121
LATITUDE=23.3
FOV=0.05

[[ ! -d "$X_DIR" ]] && mkdir -p "$X_DIR"

CLOUDS_URL='http://www.narrabri.atnf.csiro.au/operations/NASA/clouds_4096.jpg'
CLOUDS_FILE="$X_DIR/clouds_4096.jpg"

# download cloud
if [[ ! -f "$CLOUDS_FILE" ]] || (($(date +%s) - $(stat -c %Z "$CLOUDS_FILE") >= 3600 * 3)); then
	echo "Getting new clouds..."
	wget -q -nv -O "$CLOUDS_FILE" "$CLOUDS_URL"
fi

# set day and night map
month=$(date +%m)
BLUE_URL="http://earthobservatory.nasa.gov/Features/BlueMarble/images_bmng/8km/world.2004$month.3x5400x2700.jpg"
BLUE_CURRENT="$X_DIR/blue-marble-$month.jpg"
BLUE_CURRENT_NIGHT="$X_DIR/blue-marble-$month-night.jpg"

if [[ ! -e "$BLUE_CURRENT" ]]; then
	wget -q -nv -O "$BLUE_CURRENT" "$BLUE_URL"
	# increase brightness and saturation, then resize
	mogrify -modulate 150,150 -resize 4096x2048 "$BLUE_CURRENT"
	# night map
	cp "$BLUE_CURRENT" "$BLUE_CURRENT_NIGHT"
	mogrify -modulate 25,50 "$BLUE_CURRENT_NIGHT"
fi

# Ref: http://xplanet.sourceforge.net/default
config="[earth]
cloud_map=clouds_4096.jpg
map=$BLUE_CURRENT
night_map=$BLUE_CURRENT_NIGHT
"
xplanet -num_times 1 -output "$OUTPUT" -config <(echo "$config") \
	-geometry $GEOMETRY -longitude $LONGITUDE -latitude $LATITUDE \
	-pango \
	-label_string "$(td.sh $(($(date +%s) - $(stat -c %Z "$CLOUDS_FILE")))) ago" -utclabel \
	-labelpos +10-10 \
		-font 'Inconsolata' -fontsize 16 \
		-color 0x88aa88 \
		-date_format '%c' \
	-fov $FOV

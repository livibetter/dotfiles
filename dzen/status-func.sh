read _ _ S_WIDTH S_HEIGHT _ <<< "$(xprop -root | sed '/_NET_WORKAREA(CARDINAL)/ {s/[^0-9 ]//g;q} ; d')"

# Default values
################

# status

BG='#303030'
FG='#aaa'
FONT='Envy Code R-9'

# status popup

SP_BG='#222'
SP_FG='#aaa'
SP_FONT_PIXELSIZE=16
SP_FONT="Envy Code R:pixelsize=$SP_FONT_PIXELSIZE"
SP_LINE_HEIGHT=$((SP_FONT_PIXELSIZE+4))

SP_LINES=${SP_LINES:-20}
SP_TW=${SP_TW:-80}

SP_WIDTH=$(((SP_TW)*(SP_FONT_PIXELSIZE/2+1)))
SP_HEIGHT=$((SP_LINE_HEIGHT*(SP_LINES+1)))
SP_X=$((S_WIDTH-SP_WIDTH))
SP_Y=$((S_HEIGHT-SP_HEIGHT))

# Functions
###########

print_status_title () {
	echo "^fg(#303030)^r(${SP_WIDTH}x${SP_LINE_HEIGHT})^p(_LEFT)^p(+1;+1)^fg(#000)^bg(#303030)$1^p(_LEFT)^ib(1)^fg(#f00)$1^fg()^bg()"
}

used_color () {
	# used_color v [max] [color_max] [min]
	local v=$1
	local max=${2:-100}
	[[ "$v" -gt "$max" ]] && v=$max
	# 176 = aa
	local color_max=${3:-176}
	local min=${4:-0}
	[[ "$v" -lt "$min" ]] && v=$min
	local c
	printf -v c "%02x" $((color_max-(v-min)*color_max/(max-min)))
	printf -v color "#%02x$c$c" $color_max
}

ma () {
	# mavg ma_name new_sample [samples:default=3]
	# new_sample will be stored at the beginning of array of what ma_name
	# points at.
	local ma_name="$1"
	local ma_ref="$ma_name[@]"
	local ma_samples=("${!ma_ref}")
	local samples=${3:-5}

	# Put new sample in
	ma_samples=($2 "${ma_samples[@]}")
	ma_samples=("${ma_samples[@]::$samples}")

	# calculation moving average
	local dummy="${ma_samples[@]}"
	local avg=$(((${dummy// /+})/samples))
	eval $ma_name'=("${ma_samples[@]}")'
	eval "${ma_name}_ma=$avg"
}

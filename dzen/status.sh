#!/bin/bash
# Copyright 2010 Yu-Jie Lin
# BSD License

# Configuration
###############

# How many characters should be displayed?
MPD_TEXT_SIZE=20

# What icon should be shown above the battery remaining capacity left
# Colors:
#   green is charged, yellow is discharing, blue is recharging,
#   red is unknown to this script,
#   yellow-red flashing is meaning battery capacity is low
#   yellow-cyan flashing is meaning battery capacity is low and charging
BAT_FULL=50
BAT_LOW=10

# UI = update interval, PAD is for padding nano seconds
PAD="000000000"
PAD_MS="000000"
ui_cpu="1$PAD"
ui_mem="10$PAD"
ui_fs="60$PAD"
ui_thm="10$PAD"
ui_sound="200$PAD_MS"
ui_clock="1$PAD"
ui_mpd="1$PAD"
ui_network="5$PAD"
# On my laptop, /proc/acpi/battery/... update interval is 15 seconds
# Normal update interval when capacity is more than low capacity
ui_bat_normal="5$PAD"
# Flashing rate when in low capacity, the default is 500ms for red, 500ms for yellow/cyan
ui_bat_flash="500$PAD_MS"
ui_bat=$ui_bat_normal
unset PAD
# Controlling final refresh rate, the following is 0.2 seconds
ui_output="200$PAD_MS"

# Interval of each iteration of main loop, should be equal to or smaller than $ui_output
SLEEP=0.2

# Components update functions
#############################

update_cpu () {
	local ncpu cpu_val cpu_maxval cpu_total
	# 0 1:user 2:unice 3:sys 4:idle 5:iowait 6:irq 7:softirq 8:steal 9:guest 10:?
	ncpu=($(line</proc/stat))
	local sum="${ncpu[@]:1}"

	cpu_total=$((${sum// /+}))
	cpu_maxval=$((cpu_total - ocpu_total))
	cpu_val=$((cpu_maxval - (ncpu[4]-ocpu[4])))
	cpu_percentage=$((100 * cpu_val / cpu_maxval))

	ocpu=("${ncpu[@]}")
	ocpu_total=$cpu_total

	ma cpu_percentage $cpu_percentage 3
	used_color $cpu_percentage_ma 75 '' 10

	printf -v cpu_dzen "^ca(1,./status-cpu.sh)^i(icons/cpu.xbm)^ca() ^fg(%s)%3s%%^fg()" $color $cpu_percentage_ma
	update_next_ts cpu
	}

update_mem () {
	read _ _ mem_used mem_free <<< "$(free -b | grep -)"
	
	mem_total=$((mem_used + mem_free))
	mem_used_MB=$((mem_used / 1024 / 1024))
	mem_used_percentage=$((100 * mem_used / mem_total))

	used_color $mem_used_MB 1024 '' 100
	printf -v mem_dzen "^ca(1,./status-mem.sh)^i(icons/mem.xbm)^ca() ^fg(%s)%4sMB %2s%%^fg()" $color ${mem_used_MB} ${mem_used_percentage}

	update_next_ts mem
	}

update_fs () {
	# 0:dev 1:size 2:used 3:free 4:percentage 5:mount point
	read _ _ fs_root_used _ fs_root_percentage _ <<< "$(df -h / | tail -1)"

	used_color ${fs_root_used%G} 60 '' 10
	fs_dzen="^ca(1,./status-fs.sh)^i(icons/diskette.xbm)^ca() ^fg($color)${fs_root_used}B $fs_root_percentage^fg()"

	update_next_ts fs
	}

update_thm () {
	read _ thm _ </proc/acpi/thermal_zone/THM/temperature

	used_color $thm 70 '' 40
	thm_dzen="^i(icons/temp.xbm) ^fg($color)${thm}°C^fg()"

	update_next_ts thm
	}

update_clock () {
	clock_dzen="^ca(1,./status-clock.sh)^i(icons/clock.xbm)^ca() $(date +'%A, %B %d, %Y %H:%M:%S')"

	update_next_ts clock
	}

update_sound () {
	read _ _ _ _ volume _ sound_enabled <<< "$(amixer get Master | grep 'Front Left:')"

	volume=${volume#[}
	volume=${volume%\%]}

	sound_dzen="^ca(1,urxvtc -name 'dzen-status-sound' -title 'Sound Mixer' -geometry 160x40 -e alsamixer)^i(icons/spkr_01.xbm)^ca() "

	if [[ "$sound_enabled" == "[on]" ]]; then
		printf -v sound_dzen "$sound_dzen^fg(#%02xaaaa)%3s%%^fg()" $((176-volume*176/100)) $volume
	else
		printf -v sound_dzen "$sound_dzen^fg(#a00)%3s%%^fg()" $volume
	fi

	update_next_ts sound
	}

update_network () {
	local ifx=ppp0 n_rxb n_txb net_check_ts=$(date +%s%N)
	read n_rxb < /sys/class/net/$ifx/statistics/rx_bytes
	read n_txb < /sys/class/net/$ifx/statistics/tx_bytes
	local net_check_dur=$((net_check_ts - net_last_check_ts))
	net_last_check_ts=$net_check_ts
	
	# rate in bytes
	rx_rate=$(((n_rxb - rxb) * 1000000000 / net_check_dur))
	tx_rate=$(((n_txb - txb) * 1000000000 / net_check_dur))
	rxb=$n_rxb
	txb=$n_txb
	
	ma rx_rate $rx_rate
	ma tx_rate $tx_rate

	# to Kbytes
	((rx_rate/=1024))
	((rx_rate_ma/=1024))
	((tx_rate/=1024))
	((tx_rate_ma/=1024))

	used_color rx_rate 500
	rx_color=$color
	used_color tx_rate 200
	tx_color=$color

	printf -v network_dzen "^i(icons/net_wired.xbm) ^fg($tx_color)%3s^fg()/^fg($rx_color)%4s^fg() KB/s" $tx_rate_ma $rx_rate_ma
	update_next_ts network
	}

update_mpd () {
	local mpd_text
	if pgrep mpd &>/dev/null; then
		mpd_text="$(mpc | line)"
		local pos=0
		if [[ "$mpd_text" != "$old_mpd_text" ]]; then
			# New song, popup info box!
			killall status-mpd.sh &>/dev/null
			./status-mpd.sh 10 &
			old_mpd_text="$mpd_text"
			mpd_text_pos=
			mpd_text_dir=
		fi
		if [[ ${#mpd_text} -gt $MPD_TEXT_SIZE ]]; then
			# Text is too long, need to scroll
			if [[ $mpd_text_dir ]]; then
				# scroll right
				if ((++mpd_text_pos >= ${#mpd_text} + 5 - MPD_TEXT_SIZE)); then
					mpd_text_pos=$((${#mpd_text} - MPD_TEXT_SIZE))
					mpd_text_dir=
				fi
			else
				# scroll left, will be first direction since $mpd_text_dir is unset by default
				if ((--mpd_text_pos <= -5)); then
					mpd_text_pos=0
					mpd_text_dir=1
				fi
			fi
			pos=$mpd_text_pos
			[[ $pos -lt 0 ]] && pos=0
			((pos > ${#mpd_text} - MPD_TEXT_SIZE)) && pos=$((${#mpd_text} - MPD_TEXT_SIZE))
		fi
		local scrobble_color='#a00'
		pgrep mpdscribble &>/dev/null && scrobble_color='#0a0'
		printf -v mpd_dzen "^ca(1,./status-mpd.sh)^ca(3,bash -c 'killall status-mpd.sh &>/dev/null ; mpd --kill ; killall mpdscribble')^fg($scrobble_color)^i(icons/note.xbm)^fg()^ca()^ca() ^fg(#aa0)%-${MPD_TEXT_SIZE}s^fg()" "${mpd_text:$pos:$MPD_TEXT_SIZE}"
	else
		old_mpd_text=
		mpd_dzen="^ca(1,mpd;mpdscribble)^fg(#aaa)^i(icons/note.xbm)^fg()^ca()"
	fi
	update_next_ts mpd
	}

update_bat () {
	read bat_full_capacity <<< "$(sed '/last full capacity:/ {s/[^0-9]//g;q} ; d' </proc/acpi/battery/BAT0/info)"
	read _ _ bat_state <<< "$(grep 'charging state:' </proc/acpi/battery/BAT0/state)"
	read bat_remaining <<< "$(sed '/remaining capacity:/ {s/[^0-9]//g;q} ; d' </proc/acpi/battery/BAT0/state)"

	bat_remaining_percentage=$((100*bat_remaining/bat_full_capacity))

	# Formating icon
	case "$bat_state" in
		charged)    bat_dzen="^fg(#0a0)" bat_remaining_percentage=100 ;;
		charging)   bat_dzen="^fg(#0aa)" ;;
		discharging)bat_dzen="^fg(#aa0)" ;;
		*)          bat_dzen="^fg(#a00)" ;;
	esac
	ui_bat=$ui_bat_normal
	if [[ $bat_remaining_percentage -ge $BAT_FULL ]]; then
		bat_dzen="$bat_dzen^i(icons/bat_full_01.xbm)"
	elif [[ $bat_remaining_percentage -ge $BAT_LOW ]]; then
		bat_dzen="$bat_dzen^i(icons/bat_low_01.xbm)"
	else
		ui_bat=$ui_bat_flash
		if [[ $bat_flash ]]; then
			bat_dzen="$bat_dzen^fg(#a00)"
			bat_flash=
		else
			bat_flash=1
		fi
		bat_dzen="$bat_dzen^i(icons/bat_empty_01.xbm)"
	fi
	bat_dzen="$bat_dzen^fg()"

	used_color $((100-bat_remaining_percentage))

	printf -v bat_dzen "$bat_dzen ^fg($color)%3s%%^fg()" $bat_remaining_percentage

	update_next_ts bat
	}

# Controlling timestamp functions
#################################

update_ts_current () {
	ts_current=$(date +%s%N)
	}

update_next_ts () {
	# $1 is the variable name
	eval "next_$1=\$((ts_current+ui_$1))"
	}

# Initialization
################

cd ~/.dzen

source status-func.sh

update_ts_current
update_cpu
update_mem
update_fs
update_network
update_thm
update_clock
update_sound
update_mpd
update_bat

# Main loop
###########

while :; do
	update_ts_current
	# Time to output?
	if [[ "$next_output" < "$ts_current" ]]; then
		# Update each component
		[[ "$next_cpu" < "$ts_current" ]] && update_cpu
		[[ "$next_mem" < "$ts_current" ]] && update_mem
		[[ "$next_fs" < "$ts_current" ]] && update_fs
		[[ "$next_network" < "$ts_current" ]] && update_network
		[[ "$next_thm" < "$ts_current" ]] && update_thm
		[[ "$next_sound" < "$ts_current" ]] && update_sound
		[[ "$next_clock" < "$ts_current" ]] && update_clock
		[[ "$next_mpd" < "$ts_current" ]] && update_mpd
		[[ "$next_bat" < "$ts_current" ]] && update_bat

		# Composing a new output
		output="$cpu_dzen $mem_dzen $fs_dzen $network_dzen $thm_dzen $bat_dzen $mpd_dzen $sound_dzen $clock_dzen ^ca(1,./status-misc.sh)^i(icons/info_01.xbm)^ca()"
		[[ "$last_output" != "$output" ]] && echo "$output" && last_output=output
		update_next_ts output
	fi
	sleep $SLEEP
done |
dzen2 \
	-bg $BG -fg $FG \
	-fn "$FONT" \
	-x $((S_WIDTH/2)) -y $S_HEIGHT \
	-w $((S_WIDTH/2)) \
	-ta right \
	-e 'button3=;onstart=lower'

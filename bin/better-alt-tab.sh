#!/bin/bash

if [[ $1 ]]; then
	case "$1" in
		# terminal
		t)
			t_class='urxvt|xterm'
			;;
		# Firefox or Vimperator
		f|v)
			t_class='Navigator'
			;;
		# Mplayer
		m)
			t_class='smplayer|mplayer'
			;;
		# KeepNote
		k)
			t_class='keepnote'
			;;
	esac

	wmctrl -l -x |
	while read win_id _ class _; do
		if [[ $class =~ $t_class ]]; then
			wmctrl -i -a $win_id
			break
		fi
	done
else
	{
		echo 'Windows'
		wmctrl -l | sed 's/^\(0x[0-9a-f]\+\)/wmctrl -i -a \1 #/'
		echo '^uncollapse()'
	} |
	dzen2 \
		-fn 'Envy Code R' \
		-w 800 \
		-m -l 10 -xs 1 \
		-e 'button1=menuexec;button3=exit;button4=scrollup;button5=scrolldown' \
		-p 
fi

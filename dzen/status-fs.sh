#!/bin/bash

SP_LINES=8
SP_TW=60

source status-func.sh

{
print_status_title 'Filesystems Status'
df -h | while read fs size used avail usep mountp; do
	if [[ "$fs" == "Filesystem" ]]; then
		# Header
		printf "^fg(#0aa)%-10s %8s %8s %8s %8s %-10s^fg()\n" "$fs" $size $used $avail $usep "$mountp"
	else
		printf "%-10s %8s %8s %8s %8s %-10s^fg()\n" "$fs" $size $used $avail $usep "$mountp"
	fi
done
echo '^uncollapse()'
} | 
dzen2 \
	-bg $SP_BG -fg $SP_FG \
	-fn "$SP_FONT" -h $SP_LINE_HEIGHT \
	-x $SP_X -y $SP_Y \
	-w $SP_WIDTH -l $SP_LINES \
	-ta left \
	-e 'leaveslave=exit;button3=exit;button4=scrollup;button5=scrolldown' \
	-p


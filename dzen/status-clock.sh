#!/bin/bash

SP_LINES=28
SP_TW=74

source status-func.sh

{
print_status_title 'Calendar'
gcal --cc-holiday=TW+US_NY --holiday-list=short --highlighting=\<:\>:[:] . |
sed 's/</ ^fg(#a00)^bg(#fff)/g;s/\[/ ^fg(#fff)^bg(#0a0)/g;s/\(>\|]\)/^bg()^fg() /g'
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

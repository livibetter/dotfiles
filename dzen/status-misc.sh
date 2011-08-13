#!/bin/bash

SP_LINES=11
SP_TW=80

source status-func.sh

{
print_status_title 'Miscellaneous'

read l1 l2 l3 procs _ <<< "$(</proc/loadavg)"
read upsec _ <<< "$(</proc/uptime)"
updur="$(td.sh ${upsec%.*})"

thres=$((7*24*60*60))
ts="$(date -d "$(</usr/portage/metadata/timestamp.chk)" +%s)"
dur=$(($(date +%s) - ts))
td="$(td.sh $((thres-dur)))"

# Formating
echo " $(uname -srv)"
echo
echo " Uptime : $updur"
echo " Loadavg: $l1 $l2 $l3   Processes: $procs"
echo

echo -n " Portage: "
((dur>=thres)) && echo -n "T + " || echo -n "T - "
echo "$td"

echo "          $(date --date=@$((ts + thres)) +'%A, %B %d, %Y %H:%M:%S')"
echo

echo "$(./weather.sh TWXX0021)" | sed 's/^/ /'

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

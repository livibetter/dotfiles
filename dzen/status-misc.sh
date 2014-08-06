#!/bin/bash

SP_LINES=18
SP_TW=80

source status-func.sh

{
print_status_title 'Miscellaneous'

read l1 l2 l3 procs _ <<< "$(</proc/loadavg)"
read upsec _ <<< "$(</proc/uptime)"
updur="$(td.sh ${upsec%.*})"

thres=$((30 * 24 * 60 * 60))
ts="$(date -d "$(</usr/portage/metadata/timestamp.chk)" +%s)"
dur=$(($(printf "%(%s)T" -1) - ts))
td="$(td.sh -- $((thres-dur)))"

# Formating
echo " $(uname -srv)"
echo
echo " Uptime : $updur"
echo " Loadavg: $l1 $l2 $l3   Processes: $procs"
echo

echo -n " Portage: "
((dur>=thres)) && echo -n "T + " || echo -n "T - "
echo "$td"

printf "          %(%A, %B %d, %Y %H:%M:%S)T\n" $((ts + thres))
echo

echo "   mt.sh: $(mt.sh | tail -1 | sed 's/\(for\|since\)  \+/\1  /')"
echo

wget -O - 'http://weather.yahooapis.com/forecastrss?w=2306179&u=c' |
sed -n '/CDATA/,/]]/{s/<[^>]*>//g;p}' |
sed -n '1n;/^$/n;/Full Forecast/q;s/^/ /g;/Current\|Forecast/!s/^/  /;p'

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

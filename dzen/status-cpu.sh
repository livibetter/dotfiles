#!/bin/bash

CMD_TW=80
SP_TW=$((CMD_TW+28))

source status-func.sh

{
print_status_title 'CPU Status'
printf "^fg(#0aa)%5s %5s %4s %5s %4s %s^fg()\n" '%CPU' '%MEM' 'MEM' 'PID' 'USER' 'COMMAND'
ps -eo pcpu,pmem,rss,pid,user,comm,args --no-headers | sort -k 1 -n -r | head -$SP_LINES |
while read _PCPU _PMEM _RSS _PID _USER _COMM _COMMAND; do
	dzen_COMMAND="$(fold -w $CMD_TW -s <<< "${_COMMAND/$_COMM/^fg(#f00)$_COMM^fg()}" | sed '2~1 s/^/                            /')"
	printf "%5s %5s %4s %5s %4s %s\n" $_PCPU $_PMEM $((_RSS / 1024)) $_PID ${_USER::4} "$dzen_COMMAND"
done ; echo '^uncollapse()' ; echo '^scrollhome()' ; } |
dzen2 \
	-bg $SP_BG -fg $SP_FG \
	-fn "$SP_FONT" -h $SP_LINE_HEIGHT \
	-x $SP_X -y $SP_Y \
	-w $SP_WIDTH -l $SP_LINES \
	-ta left \
	-e 'leaveslave=exit;button3=exit;button4=scrollup;button5=scrolldown' \
	-p

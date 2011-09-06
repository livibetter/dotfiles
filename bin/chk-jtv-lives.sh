#!/bin/bash
# Copyright 2011 Yu-Jie Lin
# WTFPL License

JTV_USERNAME="${1:-livibetter}"
LOGINS="$(wget -q "http://www.justin.tv/$JTV_USERNAME/following" -O - |
sed -n '/videos">$/ {s/\([^\/]\+\/\)\([^\/]\+\).*/\2/;H} ; $ {x;s/\n/,/g;s/^,//;p}')"

i=0
API_URL="http://api.justin.tv/api/stream/list.xml?channel=$LOGINS"
wget -q "$API_URL" -O - |
sed -n '/ <\(title\|status\)>[^<]\+/ {s/ *<[^>]\+>//g;p}' |
while read line; do
  case "$i" in
    0)
      echo -e "\e[1;32m$line\e[0m\n"
      ;;
    1)
      echo -e "\e[1;37m$line\e[0m" | fold -w 67 -s | sed '/^/ s/^/    /'
      echo
      ;;
  esac
  (( i = (i+1) % 2 )) ; :
done

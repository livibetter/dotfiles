#!/bin/bash
# Copyright 2011 Yu-Jie Lin
# WTFPL License
#
# Requires
#   http://code.google.com/p/yjl/source/browse/Bash/td.sh

XSLT="$(readlink "$0")"
XSLT="${XSLT%.sh}.xslt"

JTV_USERNAME="${1:-livibetter}"
# Favorites are whom this user follows
# http://apiwiki.justin.tv/mediawiki/index.php/User/favorites
LOGINS="$JTV_USERNAME$(wget -q "http://api.justin.tv/api/user/favorites/$JTV_USERNAME.xml?live=true" -O - |
sed -n '/login/ {s/ \+<login>\([^<]\+\)<\/login>/\1/;H} ; $ {x;s/\n/,/g;p}')"

i=0
API_URL="http://api.justin.tv/api/stream/list.xml?channel=$LOGINS"
wget -q "$API_URL" -O - |
xsltproc "$XSLT" - |
sed $'s/ANSI/\033/g' |
while read line; do
  if [[ "$line" =~ "%DATE%" ]]; then
    echo "NOFOLD$(td.sh $(($(date +%s) - $(date -d "${line:6} PDT" +%s)))) ago"
  else
    echo "$line"
  fi
done |
fold -w 68 |
sed '/NOFOLD/ {s/NOFOLD//;p;d} ; s/^./    &/'

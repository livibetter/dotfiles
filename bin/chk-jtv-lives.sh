#!/bin/bash
# Copyright 2011 Yu-Jie Lin
# WTFPL License
XSLT="$(readlink "$0")"
XSLT="${XSLT%.sh}.xslt"

JTV_USERNAME="${1:-livibetter}"
LOGINS="$JTV_USERNAME,$(wget -q "http://www.justin.tv/$JTV_USERNAME/following" -O - |
sed -n '/videos">$/ {s/\([^\/]\+\/\)\([^\/]\+\).*/\2/;H} ; $ {x;s/\n/,/g;p}')"

i=0
API_URL="http://api.justin.tv/api/stream/list.xml?channel=$LOGINS"
wget -q "$API_URL" -O - |
xsltproc "$XSLT" - |
sed $'s/ANSI/\033/g' |
fold -w 68 |
sed '/32m/ n ; s/^./    &/'

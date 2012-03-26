#!/bin/sh
# 2011-08-22T15:25:33Z
my-rst2html.py "$1" > /tmp/draft.html

TITLE=$(basename "$1")
TITLE="${TITLE%.rst}"

case "$(dirname "$1")" in
  *series/BSME*)
    TITLE="${TITLE/ /: }"
    TITLE="BSME $TITLE"
    ;;
esac

sed "s/%%Title%%/$TITLE/" tmpl/tmpl1.html > /tmp/preview.html
cat /tmp/draft.html >> /tmp/preview.html
cat tmpl/tmpl2.html >> /tmp/preview.html

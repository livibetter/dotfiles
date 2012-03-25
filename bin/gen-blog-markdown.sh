#!/bin/sh
# 2010-01-09T20:47:29+0800

#markdown2 --extras=code-friendly,footnotes "$1" > /tmp/draft.html
~/bin/markdown2.py -v --extras=code-friendly,footnotes=^ "$1" > /tmp/draft.html
#~/bin/markdown2.py -v --extras=toc,code-friendly,footnotes=^ "$1" > /tmp/draft.html
#~/bin/markdown2.py -v --extras=smarty-pants,toc,code-friendly,footnotes=^ "$1" > /tmp/draft.html

sed "s/%%Title%%/${1%.mkd}/" tmpl/tmpl1.html > /tmp/preview.html
cat /tmp/draft.html >> /tmp/preview.html
cat tmpl/tmpl2.html >> /tmp/preview.html

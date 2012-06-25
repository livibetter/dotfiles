#!/bin/bash
# Generates login issue, prelogin message and identification file.
# Written by Yu-Jie Lin <http://yjl.im>
#
# This is the script I use to generate issue file, it is run as daily system
# cron job. There will be more text sources added in the future.
#
# You need to enable issue file in /etc/login.defs:
#
#   ISSUE_FILE      /etc/issue
#
# Dependencies
# ------------
#
# * Wget
# * xmllint
#
# ASCII
# -----
#
# * /etc/issue.logo
#   <http://www.gentoo-wiki.info/TIP_Login_issue>
#   <https://github.com/livibetter/dotfiles/blob/master/rootfs/etc/issue.logo>
# * /etc/issue.orig
#   The original issue file
#   <https://github.com/livibetter/dotfiles/blob/master/rootfs/etc/issue.orig>
#
# Text
# ----
#
# * That's What She Said
#   <http://www.twssstories.com/>
# * I ♥ Quotes
#   <http://iheartquotes.com/>
# * QDB
#   <http://www.qdb.us/>

gen_text()
{
  case "$((RANDOM % 3))" in
    0) # That's What She Said
      xmllint --xpath '//item[1]/description/text()' <(wget -q -O - http://www.twssstories.com/rss.xml) |
      sed 's/&lt;\/\?p&gt;//g;q' |
      fold -s
      ;;
    1) # I ♥ Quotes
      wget -q -O - http://www.iheartquotes.com/api/v1/random |
      head -n -2 |
      sed 's/&amp;/\&/g;s/&quot;/"/g'
      ;;
    2) # QDB
      echo -e 'setns a=http://purl.org/rss/1.0/\ncat //a:item[1]/a:description/text()' |
      xmllint --shell <(wget -q -O - 'http://qdb.us/qdb.xml?action=random&fixed=0') |
      sed '1,3d;$d;s/&amp;/\&/g;s/&lt;/</g;s/&gt;/>/g;s/&nbsp;/ /g;s/&quot;/"/g;s/<br \/>//g' |
      fold -s
      ;;
  esac
}

cat /etc/issue.logo \
    <(echo -e '\e[1;34m') \
    <(gen_text) \
    <(echo -e '\e[0m') \
    /etc/issue.orig \
    > /etc/issue

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
# * /etc/issue.orig
#   The original issue file
#
# Text
# ----
#
# * That's What She Said
#   <http://www.twssstories.com/>

cat /etc/issue.logo \
    <(echo -e '\e[1;34m') \
    <(xmllint --xpath '//item[1]/description/text()' <(wget -q -O - http://www.twssstories.com/rss.xml) |
      sed 's/&lt;\/\?p&gt;//g;q' |
      fold -s) \
    <(echo -e '\e[0m') \
    /etc/issue.orig \
    > /etc/issue

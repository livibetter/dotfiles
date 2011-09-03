#!/bin/bash
# Copyright 2011 Yu-Jie Lin
# MIT License

FMT_DIR="%-30s"
FMT_OUT="\033[1;32m+ %5d\033[0m / \033[1;31m- %5d\033[0m\n"

usage() {
  cat <<EOF

$(basename "$0") [''|AUTHOR_NAME [''|HG_DATESPEC [''|GIT_SINCE [''|GIT_UNTIL]]]]

Every argument is basically optional, however you need to use '' to indicate
that you are not specifying it.

HG_DATESPEC Examples
====================

  "2011-08"
  "2011-01 to 2011-03" # Jan. to Mar. in 2011
  ">2011-05"           # Since May.
  "-3"                 # Last three days

See hg manpage for DATE FORMATS section.

GIT_SINCE and GIT_UNTIL Examples
================================

  "2011-01-23"
  "yesterday"
  "2 weeks ago"

See..., uhm I have no idea where to look at. gitrevisions manpage for
date specification, perhaps?
EOF
}

parse_stat() {
  grep 'files changed' |
  sed -e 's/[^0-9]/ /g' |
  awk "
    BEGIN {
      ins = 0;
      del = 0;
      }
    {
      ins += \$2;
      del += \$3;
    }
    END {
      printf(\"$FMT_OUT\", ins, del);
    }"
}

if [[ "$1" =~ -h ]]; then
  usage
  exit
fi

GIT_ARGS=()
HG_ARGS=()

if [[ ! -z "$1" ]]; then
  HG_ARGS=(  "${HG_ARGS[@]}" "--user"   "$1")
  GIT_ARGS=("${GIT_ARGS[@]}" "--author" "$1")
fi

[[ ! -z "$2" ]] && HG_ARGS=(  "${HG_ARGS[@]}" "--date"  "$2")
[[ ! -z "$3" ]] && GIT_ARGS=("${GIT_ARGS[@]}" "--since" "$3")
[[ ! -z "$4" ]] && GIT_ARGS=("${GIT_ARGS[@]}" "--until" "$4")

for d in */; do
  cd "$d"
  d=${d%\/}
  if [[ -d .hg ]]; then
    printf "[%3s] $FMT_DIR" "Hg" "$d"
    hg  log  "${HG_ARGS[@]}" --stat | parse_stat
  elif [[ -d .git ]]; then
    printf "[%3s] $FMT_DIR" "Git" "$d"
    git log "${GIT_ARGS[@]}" --shortstat --oneline | parse_stat
  else
    :
  fi
  cd ..
done

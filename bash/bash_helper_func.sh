# My Bash helper functions
# Copyright (c) 2011-2013 Yu-Jie Lin
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

############
# wget & tar

# Usage: wt 'http://example.com/blah.blah.tar.gz' [keep]
# If [keep] is presented, whatever it is, the tarball will be kept.
# (opt) dtrx: rhttp://brettcsmith.org/2007/dtrx/
# ref: http://blog.yjl.im/2011/08/simplifying-wget-and-and-tar-and-and-cd.html

wt() {
  (( $# == 0 )) && return
  URL="$1"
  keep="$2"
  filename="$(basename "$URL")"
  wget "$URL" -O "$filename"
  if type dtrx &>/dev/null; then
    dtrx -n "$filename"
  else
    tar xf "$filename"
  fi
  [[ -z "$keep" ]] && rm "$filename"
  # Guessing the directory
  cd "${filename%%.[a-z]*}"*
  }

################################
# uf: Unarchive in new directory

# Usage: df [-n] <archive>
# Option:
#   -n: do not change to new directory
# ref: http://blog.yjl.im/2012/04/extracting-archive-to-different.html

uf() {
  local no_cd ext d

  if [[ "$1" == "-n" ]]; then
    no_cd=1
    shift
  fi

  ext=${1##*.} # extension of archive
  d="${1%.*}"  # directory to be created
  # unrar needs $d to be created already
  mkdir -p "$d"

  [[ -z $ext ]] && return

  case "$ext" in
    rar)
      unrar x "$1" "$d" 
      ;;
    zip)
      unzip "$1" -d "$d"
      ;;
    *)
      echo "Unknown archive type: $ext" >&2
  esac

  [[ -z $no_cd ]] && cd "$d"
  return 0
  }

#######################
# sleeptil: Sleep until

# Usage: sleeptil [-v] <date/time string> 
# Option:
#   -v: display date/time and seconds until the time
# Optional:
#   td.sh: for printing out human readable time
#          https://github.com/livibetter/td.sh
# ref: http://blog.yjl.im/2012/11/sleeptil-sleep-until-bash-function.html

sleeptil () {
  local verbose END_TS END_DATE DUR

  if [[ $1 == -v ]]; then
    verbose=1
    shift
  fi

  # Checking valid of date/time string
  if ! END_TS=$(date -d "$*" +%s); then
    return 1
  fi

  # This is not a sci-fi, you cannot sleep back into the past.
  if (( END_TS < $(date +%s ))); then
    echo "$(date -d "$*") is in the past!" >&2
    return 1
  fi

  if [[ ! -z $verbose ]]; then
    END_DATE="$(date -d @$END_TS)"
    if type td &>/dev/null; then
      DUR="$(td $((END_TS - $(date +%s))))"
    else
      DUR="$((END_TS - $(date +%s))) seconds"
    fi
    echo "$END_DATE in $DUR"
  fi

  sleep $((END_TS - $(date +%s)))
  }

######################################################################
# beeps: Providing visual and audio notifications via dzen2 and a wave

# Usage: beeps <message is written here>
# ref: http://blog.yjl.im/2013/06/beeps-with-dzen.html

beeps() {
  (( BEEPS_RET=$? )) && BEEPS=error || BEEPS=generic

  # subshell'd to get rid of: [JOB#] PID#
  (
    for i in {1..5}; do
      (aplay -q /usr/share/sounds/$BEEPS.wav &) >/dev/null
      sleep 1
    done &

    echo "$@" |
    dzen2 -p 10 -fn 'Envy Code R:size=24' -fg '#ff0000' &
  )

  return $BEEPS_RET
}

########################################################
# ghclone: Cloning GitHub repository with different URLs

# Usage: gitclone <url>
# url could be one of:
# Smart HTTP: https://github.com/{user}/{repo}.git
# SSH       : git@github.com:{user}/{repo}.git
# Subversion: https://github.com/{user}/[repo}

ghclone() {
  local URL="${1%.git}" user repo
  URL="${URL%/}"
  repo="${URL##*/}"
  URL="${URL%/$repo}"
  user="${URL##*[:/]}"

  git clone "git@github.com:$user/$repo" && cd "$repo"
}

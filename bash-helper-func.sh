# My Bash helper functions
# Copyright (c) 2011, 2012 Yu-Jie Lin
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
# ref: http://blog.yjl.im/2011/08/simplifying-wget-and-and-tar-and-and-cd.html

wt() {
  (( $# == 0 )) && return
  URL="$1"
  keep="$2"
  filename="$(basename "$URL")"
  wget "$URL" -O "$filename"
  tar xf "$filename"
  [[ -z "$keep" ]] && rm "$filename"
  # Guessing the directory
  d="${filename%%.[a-z]*}"
  if [[ -d "$d" ]]; then
    cd "$d"
  else
    echo "Sorry, I don't know what's the name of extracted directory."
  fi
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

# My Bash helper functions
# Copyright (c) 2011-2015 Yu-Jie Lin
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

############################################################################
# beeps: Providing visual and audio notifications via dzen2 and wave command

# Usage: beeps <message is written here>
# ref: http://blog.yjl.im/2013/06/beeps-with-dzen.html

beeps() {
  local BEEPS

  (( BEEPS_RET=$? )) && BEEPS=3 || BEEPS=1

  # subshell'd to get rid of: [JOB#] PID#
  (
    for i in {1..5}; do
      {
        echo "4800 0.75 $((100 * i * BEEPS))"
        echo "4800 0.75 $((200 * i * BEEPS))"
      } | wave | aplay -f FLOAT_LE -r 48000 -c 1 -q
      sleep 0.1
    done &

    echo "$@" |
    dzen2 -p 10 -fn 'Envy Code R:size=24' -fg '#ff0000' &
  )

  return $BEEPS_RET
}

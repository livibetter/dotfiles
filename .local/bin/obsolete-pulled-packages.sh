#!/bin/bash
# Helper for listing pulled packages that are obsolete
# Copyright (c) 2017 Yu-Jie Lin
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

TMPLIST=/tmp/list
TMPPKGS=/tmp/pkgs

main()
{
  local CMD

  if (($# == 0)); then
    echo "need a list of packages" >&2
    return 1
  fi

  rm -f "$TMPLIST" "$TMPPKGS"

  # generating a pulled package list
  CMD="emerge -puD"
  echo "running $CMD $@..."
  $CMD "$@" | sed -n '/\[ebuild/ s/-[0-9].*//p' | cut -c 18- > "$TMPLIST"

  # checking each package with eix
  touch "$TMPPKGS"
  while read pn; do
    echo -n "checking $pn... "
    if eix -q -I -\# -T $pn; then
      echo -e "\e[1;31mobsolete\e[0m"
      echo "$pn" >> "$TMPPKGS"
    else
      echo "not obsolete"
    fi
  done < "$TMPLIST"

  n="$(wc -l "$TMPLIST" | cut -d ' ' -f 1)"
  printf "%3d package(s) pulled.\n" $n
  n="$(wc -l "$TMPPKGS" | cut -d ' ' -f 1)"
  printf "%3d package(s) obsolete, see %s.\n" $n "$TMPPKGS"
}

main "$@"

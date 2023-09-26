#!/bin/bash
# Checking last sync of Portage tree (metadata timestamp / sync command issued)
# Created at around 2014-01-13 08:43:29.000000000 +0800
#
# Copyright (c) 2014, 2017, 2023 Yu-Jie Lin
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

TS="$(date -d "$(</var/db/repos//gentoo/metadata/timestamp.chk)" +%s)"
printf '%s: %(%c)T\n' meta "$TS"

if ! (( UID )); then
  SYNC="$(grep 'Sync completed' /var/log/emerge.log | sed -n '$ s/:.*//p')"
  printf '%s: %(%c)T\n' sync "$SYNC"
else
  printf '%s: run with sudo\n' sync
fi

#!/bin/bash
# bzen2.sh - Bouncing dzen2
# Copyright 2011 Yu-Jie Lin
# MIT License

FONT='Envy Code R-9'
CHAR_WIDTH=6
TEXT="$@"
WIDTH=$(( CHAR_WIDTH * ${#TEXT} + CHAR_WIDTH / 2))
HEIGHT=16
# How long should dzen2 remains on screen after bouncing in milliseconds.
WAIT_DURATION=3000

trap 'kill $DZEN_PID ; exit 0' INT QUIT TERM EXIT

# Set $X $Y to the position where dzen2 will be below cursor
get_xy() {
  read x y sw sh cw ch cx cy <<< $(xcinfo)
  let "X = x - WIDTH / 2"
  # ch and cy could vary because cursor changes when dzen moves under cursor,
  # so it's not a good idea to use them
  let "Y = y + HEIGHT"
}

# Reference: http://blog.chewearn.com/2010/01/18/find-window-id-of-a-process-id-in-bash-script/
# $1: PID
get_wid() {
  ret=
  wids=$(xwininfo -root -children | sed -n '/^ \+0x/ {s/ \+\(0x[0-9a-z]\+\).*/\1/;p}')
  for wid in $wids; do
    wid_pid=$(xprop -id "$wid" _NET_WM_PID | grep -o '[0-9]\+')
    if [[ "$wid_pid" == "$1" ]]; then
      ret=$wid
      return 0
    fi
  done
  return 1
}

# Kill existing bzen2.sh
# TODO

echo "$@" | dzen2 -x $X -y $Y -w $WIDTH -h $HEIGHT -fg '#ffaaaa' -bg '#603030' -fn "$FONT" -p &
DZEN_PID=$!

# Wait up for up to 3 second
for i in {1..30}; do
  get_wid $DZEN_PID
  (( $? == 0 )) && break
  sleep 0.1
done

if [[ -z "$ret" ]]; then
  echo "Cannot find window ID of dzen2, killing..."
  kill $DZEN_PID
  exit 1
fi

DZEN_WID=$ret

for j in {1..3}; do
  for i in {0..9} {8..0}; do
    get_xy
    wmctrl -i -r $DZEN_WID -e 0,$X,$((Y - i)),-1,-1
    # 40 times per second
    sleep 0.025
  done
done

# Keep dzen2 for a while
time_start=$(date +%s%N)
while (( $(date +%s%N) - time_start < WAIT_DURATION * 1000000 )); do
  get_xy
  wmctrl -i -r $DZEN_WID -e 0,$X,$Y,-1,-1
  sleep 0.025
done

kill $DZEN_PID
exit 0

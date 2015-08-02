#!/bin/bash

trap 'kill $tmpcount_pid ; rm -f "$tmpcount"; exit 130' INT

test_command () {

  echo "Benchmarking ${TD[@]}"
  echo -n "Please wait for 5 seconds..."
  tmpcount="$(mktemp)"
  ( trap exit TERM; "${SETUP[@]}"; while :; do ${TD[@]}; echo >> "$tmpcount"; done ) &>/dev/null &
  tmpcount_pid=$!
  sleep 5
  kill $tmpcount_pid
  echo -ne "\033[3K\033[0G$(bc <<< "$(wc -l < "$tmpcount") / 5") prompts per second via $VIA.\n"
  rm "$tmpcount"

}

bash_ps1 () {
  local STR_MAX_LENGTH dirnames p d i

  STR_MAX_LENGTH=3

  echo -n ' '

  p=${PWD/$HOME/}
  [[ "$p" != "$PWD" ]] && echo -n '~'
  if [[ "$p" != "" ]]; then
  until [[ "$p" == "$d" ]]; do
    p=${p#*/}
    d=${p%%/*}
    dirnames[${#dirnames[@]}]="$d"
  done
  fi

  for ((i = 0; i < ${#dirnames[@]}; i++)); do
    if ((i == 0)) || ((i == ${#dirnames[@]} - 1)) || ((${#dirnames[i]} <= STR_MAX_LENGTH)); then
      echo -n "/${dirnames[i]}"
    else
      echo -n "/${dirnames[i]:0:$STR_MAX_LENGTH}"
    fi
  done

}

SETUP=('enable' '-f' "$PWD/vimps1" 'vimps1')
VIA='vimps1'
TD=(vimps1)

test_command

SETUP=()
VIA='Bash PS1'
TD=(bash_ps1)

test_command

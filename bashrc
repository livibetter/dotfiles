# .bashrc
# Author: Yu-Jie Lin
# Creation Date: 2007-12-27T05:58:17+0800

#######
# Alias
#######

####
# ls
alias ll='ls -l --color=auto'
alias l.='ls -d .* --color=auto'
alias ls='ls --color=auto'

#####
# vim
alias vim.='/usr/bin/vim'
alias vi.='vim.'
_vim() {
  if (( $# > 0 )); then
    /usr/bin/vim --servername VIM --remote-silent "$@"
  else
    /usr/bin/vim --servername VIM
  fi
  }
alias vimp='/usr/bin/vim --servername VIM --remote-tab'
alias vim='_vim'
alias vip='vimp'
alias vi='vim'

#######
# misc.
alias mc='. /usr/libexec/mc/mc-wrapper.sh -x'
alias ytdl='cd /tmp ; youtube-dl --max-quality=22 -t'

alias beeps='(BEEPS_RET=$? ; ((BEEPS_RET)) && BEEPS=error || BEEPS=generic ; for i in {1..5} ; do (aplay -q /usr/share/sounds/$BEEPS.wav &) >/dev/null ; sleep 1 ; done ; exit $BEEPS_RET)'
alias pyhttp='python -m SimpleHTTPServer'

# Helper functions
[[ -f $HOME/.bash-helper-func.sh ]] && source $HOME/.bash-helper-func.sh

# for root
if (( UID == 0 )); then
  alias rm='rm -i'
  alias cp='cp -i'
  alias mv='mv -i'
fi

# Source global definitions
[[ -f /etc/bashrc ]] && . /etc/bashrc

[[ -f $HOME/p/g/g ]] && . $HOME/p/g/g || echo "Can not found g script!"

for comp in $HOME/.bash_completion.d/* ; do
    [[ -r "$comp" ]] && . "$comp"
done
unset comp

# Prompt
if enable -f ~/bin/vimps1 vimps1; then
    PS1='$(vimps1 $?)'
else # fail to enable vimps1

[[ $TERM == 'linux' ]] && STR_MAX_LENGTH=2 || STR_MAX_LENGTH=3
DIR_COLOR='\[\e[1;32m\]'
DIR_HOME_COLOR='\[\e[1;35m\]'
DIR_SEP_COLOR='\[\e[1;31m\]'
ABBR_DIR_COLOR='\[\e[1;37m\]'
(( UID == 0 )) && USER_COLOR='\[\e[1;31m\]' || USER_COLOR='\[\e[1;34m\]'

NEW_PWD='$(
p=${PWD/$HOME/}
[[ "$p" != "$PWD" ]] && echo -n "'"$DIR_HOME_COLOR"'~"
if [[ "$p" != "" ]]; then
until [[ "$p" == "$d" ]]; do
    p=${p#*/}
    d=${p%%/*}
    dirnames[${#dirnames[@]}]="$d"
done
fi
for (( i=0; i<${#dirnames[@]}; i++ )); do
    if (( i == 0 )) || (( i == ${#dirnames[@]} - 1 )) || (( ${#dirnames[$i]} <= '"$STR_MAX_LENGTH"' )); then
        echo -n "'"$DIR_SEP_COLOR"'/'"$DIR_COLOR"'${dirnames[$i]}"
    else
        echo -n "'"$DIR_SEP_COLOR"'/'"$ABBR_DIR_COLOR"'${dirnames[$i]:0:'"$STR_MAX_LENGTH"'}"
    fi
done
)'

PS1_ERROR='$(
ret=$?
(( ret == 0 )) ||
printf "\e[41;1;37m%${COLUMNS}s\e[$(((COLUMNS-${#ret})/2))G%s\e[0m\n\[\e[0m\]" "" "$ret"
)'

# the first $DIR_COLOR can be removed
if [[ $TERM == 'screen' ]]; then
    PS1="$PS1_ERROR $DIR_COLOR$NEW_PWD"'\[\033k\033\\\]'" $USER_COLOR\$ \[\e[0m\]"
else
    PS1="$PS1_ERROR $DIR_COLOR$NEW_PWD $USER_COLOR\$ \[\e[0m\]"
fi

unset STR_MAX_LENGTH DIR_COLOR DIR_HOME_COLOR DIR_SEP_COLOR ABBR_DIR_COLOR USER_COLOR NEW_PWD PS1_ERROR

fi # end of prompt

# Change the window title of X terminals
# originally from /etc/bash/bashrc on Gentoo
case ${TERM} in
  xterm*|rxvt*|Eterm|aterm|kterm|gnome*|interix)
    PROMPT_COMMAND='echo -ne "\033]0;${PWD/$HOME/~}\007"'
    ;;
  screen)
    PROMPT_COMMAND='echo -ne "\033_${PWD/$HOME/~}\033\\"'
    ;;
esac

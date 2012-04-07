#!/bin/sh

# .bash_profile ##############################################################

# User specific environment and startup programs

PATH=$HOME/bin:/sbin:/usr/sbin:/usr/games/bin:$PATH
MANPATH=$HOME/share/man:$MANPATH
PYTHONPATH="$HOME/lib64/python2.6/site-packages:$HOME/lib/python2.5:/usr/local/lib64/python2.6:$PYTHONPATH"
XDG_CONFIG_HOME=~/.config
XDG_DATA_HOME=~/.local/share
BROWSER=firefox
EDITOR=vim
#OOO_FORCE_DESKTOP="gnome"

export PATH
export MANPATH
export PYTHONPATH
export XDG_CONFIG_HOME
export XDG_DATA_HOME
export BROWSER
export EDITOR
#export OOO_FORCE_DESKTOP

# .bashrc ####################################################################

#export XMODIFIERS="@im=gcin"
#export GTK_IM_MODULE="xim"
#export QT_IM_MODULE="xim"
#export XIM_PROGRAM="gcin"

# .xinitrc ###################################################################

xrdb -merge .Xresources
xset fp+ ~/.fonts/Envy\ Code\ R/
setxkbmap -model pc104 -layout us -option compose:menu

synclient HorizTwoFingerScroll=1

pulseaudio --start

urxvtd -q -o -f

# clean up serverauth files, which were left due to unexpected exit of X window
for sa in ~/.serverauth.*; do pid=${sa/*.serverauth./}; [[ ! -d /proc/$pid ]] && rm ~/.serverauth.$pid; :; done
unset sa pid

if [[ "$1" == "dwm" ]]; then
	{ sleep 1s ; dzen-status ; } &
fi
exec "$1"

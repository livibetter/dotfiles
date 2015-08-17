#!/bin/sh

# .bash_profile ##############################################################

# User specific environment and startup programs

source $HOME/.bash/bash_base

XDG_CONFIG_HOME=~/.config
XDG_DATA_HOME=~/.local/share

export PATH
export MANPATH
export PYTHONPATH
export XDG_CONFIG_HOME
export XDG_DATA_HOME
export BROWSER
export EDITOR

# .bashrc ####################################################################

#export XMODIFIERS="@im=gcin"
# Make sure updates of ~/.XCompose take effective on newly started programs
# without needing to restart X.
export GTK_IM_MODULE="xim"
export QT_IM_MODULE="xim"
#export XIM_PROGRAM="gcin"

# .xinitrc ###################################################################

xrdb -merge .Xresources
xset fp+ ~/.fonts/Envy\ Code\ R/
setxkbmap -model pc104 -layout us -option compose:menu

synclient HorizTwoFingerScroll=1

pulseaudio --start

urxvtd -q -o -f

exec "$1"

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

# .profile

[ -f /etc/xprofile ] && . /etc/xprofile
[ -f ~/.xprofile ] && . ~/.xprofile

# Let WM take over
exec "$1"

# .bash_profile

# Get the aliases and functions
[[ -f $HOME/.bashrc ]] && . $HOME/.bashrc

# User specific environment and startup programs

PATH=$HOME/bin:$PATH:/sbin:/usr/sbin:/usr/games/bin
MANPATH=$MANPATH:$HOME/share/man
PYTHONPATH="$HOME/lib/python2.5:/usr/local/lib64/python2.6:$PYTHONPATH"
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

# Go Stuff
#GOROOT=$HOME/go
#GOOS=linux
#GOARCH=amd64
#export GOROOT
#export GOOS
#export GOARCH

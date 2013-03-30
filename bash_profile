# .bash_profile

# Get the aliases and functions
[[ -f $HOME/.bashrc ]] && . $HOME/.bashrc

# User specific environment and startup programs

export PATH=$HOME/bin:$HOME/.local/bin:$PATH:/sbin:/usr/sbin:/usr/games/bin
export MANPATH=$MANPATH:$HOME/share/man:$HOME/.local/man
export BROWSER=firefox-bin
# Invoking Vim directly, not server mode via vi* alias defined in bashrc
# Only use server mode by my explict command, programs invoke editor may have
# problem with server mode.
export EDITOR=/usr/bin/vim

export HISTCONTROL=ignoredups

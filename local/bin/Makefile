CFLAGS   = -std=gnu99 -fPIC -g -O2 -Wall -Wextra
CPPFLAGS = -U_FORTIFY_SOURCE \
           -I/usr/include \
           -I$(BASH_INCDIR) \
           --include=/usr/include/getopt.h
LDFLAGS  = -shared -Wl,-soname,$@

##########

# Use Gentoo's path as default
BASH_INCDIR = /usr/include/bash-plugins

.PHONY: all
all: CHECK_DIRS vimps1

.PHONY: CHECK_DIRS
CHECK_DIRS:
	@if ! test -f '$(BASH_INCDIR)'/builtins.h; then \
	  echo 'error: cannot find Bash headers at $(BASH_INCDIR)' >&2; \
	  echo 'maybe: $$ make BASH_INCDIR=/path/to/find/bash/builtins.h/at' >&2; \
	  exit 1; \
	fi

vimps1: vimps1.o

.PHONY: clean
clean:
	rm -f vimps1 vimps1.o

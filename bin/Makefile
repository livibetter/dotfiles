CFLAGS   = -std=gnu99 -fPIC -g -O2 -Wall -Wextra
CPPFLAGS = -U_FORTIFY_SOURCE \
           -I/usr/include \
           -I$(BASH_INCDIR) \
           -I$(VCPROMPT_INCDIR) \
           --include=/usr/include/getopt.h
LDFLAGS  = -shared -Wl,-soname,$@

##########

# Use Gentoo's path as default
BASH_INCDIR = /usr/include/bash-plugins

VCPROMPT_TOPDIR = vcprompt
VCPROMPT_INCDIR = ${VCPROMPT_TOPDIR}/src
VCPROMPT_SOURCES = $(wildcard $(VCPROMPT_TOPDIR)/src/*.c)
VCPROMPT_OBJECTS = $(addprefix $(VCPROMPT_TOPDIR).o/,$(notdir $(subst .c,.o,$(VCPROMPT_SOURCES))))

.PHONY: all
all: CHECK_DIRS vimps1

.PHONY: CHECK_DIRS
CHECK_DIRS:
	@if ! test -f '$(BASH_INCDIR)'/builtins.h; then \
	  echo 'error: cannot find Bash headers at $(BASH_INCDIR)' >&2; \
	  echo 'maybe: $$ make BASH_INCDIR=/path/to/find/bash/builtins.h/at' >&2; \
	  exit 1; \
	fi
	@if ! test -f '$(VCPROMPT_INCDIR)'/vcprompt.c; then \
	  echo 'error: cannot find vcprompt sources at $(VCPROMPT_INCDIR)' >&2; \
	  echo 'maybe: $$ hg clone http://hg.gerg.ca/vcprompt/' >&2; \
	  exit 1; \
	fi
	mkdir -p $(VCPROMPT_TOPDIR).o

vimps1: vimps1.o $(VCPROMPT_OBJECTS)

$(VCPROMPT_OBJECTS):
	$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $(subst .o,/src,$(@:.o=.c))

.PHONY: clean
clean:
	rm -f vimps1 vimps1.o $(VCPROMPT_OBJECTS)

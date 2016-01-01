PROGRAM = status

CC       ?= gcc
CFLAGS   ?= -g -O2
CFLAGS   += -Wall -Wextra
CFLAGS   += -std=c99
CPPFLAGS += -D_POSIX_C_SOURCE=199309L
LDLIBS   += -lasound

all: $(PROGRAM)
.PHONY: all

$(PROGRAM): status.c

clean:
	$(RM) $(PROGRAM)
.PHONY: clean

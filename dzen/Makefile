CC       ?= gcc
CFLAGS   ?= -g -O2
CFLAGS   += -Wall -Wextra
CFLAGS   += -std=c99
CPPFLAGS += -D_POSIX_C_SOURCE=199309L
LDFLAGS  += -lasound

all: status

status: status.o

status.o: status.c

clean:
	rm -f status status.o

.PHONY: clean

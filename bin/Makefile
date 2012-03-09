# vimps1
# ======
# Save a copy or make symlink for bash source at ./bash

CFLAGS += -g -O2

##########

VIMPS1_CFLAGS = -fPIC -DHAVE_CONFIG_H -DSHELL ${CFLAGS}
VIMPS1_LDFLAGS = -shared -Wl,-soname,$@ 

BASH_TOPDIR = bash
BASH_BUILDDIR = ${BASH_TOPDIR}
BASH_INCDIR = ${BASH_TOPDIR}/include
BASH_LIBBUILD = ${BASH_BUILDDIR}/lib
BASH_INTLINC = 

VIMPS1_INC = -I. -I.. -I$(BASH_TOPDIR) -I$(BASH_TOPDIR)/lib -I$(BASH_TOPDIR)/builtins \
      -I$(BASH_INCDIR) -I$(BASH_BUILDDIR) -I$(BASH_LIBBUILD) \
      -I$(BASH_BUILDDIR)/builtins $(BASH_INTLINC)

##########

XCINFO_LDFLAGS = ${LD_FLAGS} -lX11 -lXfixes

##########

.c.o:
	$(CC) $(VIMPS1_CFLAGS) $(CCFLAGS) $(VIMPS1_INC) -c -o $@ $<

##########

all: vimps1 xcinfo

##########

vimps1: vimps1.o
	$(CC) $(VIMPS1_LDFLAGS) -o $@ vimps1.o $(LIBS)

xcinfo: xcinfo.o
	$(CC) $(XCINFO_LDFLAGS) -o $@ xcinfo.o $(LIBS)

##########

vimps1.o: vimps1.c
xcinfo.o: xcinfo.c

##########

clean:
	rm -f vimps1 vimps1.o xcinfo xcinfo.o

.PHONY: all clean

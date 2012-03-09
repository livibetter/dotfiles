CFLAGS += -g -O2

##########

VIMPS1_CFLAGS = -fPIC -DHAVE_CONFIG_H -DSHELL ${CFLAGS}
VIMPS1_LDFLAGS = -shared -Wl,-soname,$@ 

BASH_TOPDIR = bash
BASH_BUILDDIR = ${BASH_TOPDIR}
BASH_INCDIR = ${BASH_TOPDIR}/include
BASH_LIBBUILD = ${BASH_BUILDDIR}/lib
BASH_INTLINC = 

VCPROMPT_TOPDIR = vcprompt
VCPROMPT_INCDIR = ${VCPROMPT_TOPDIR}
VCPROMPT_SOURCES = $(wildcard $(VCPROMPT_TOPDIR)/*.c)
VCPROMPT_OBJECTS = $(addprefix $(VCPROMPT_TOPDIR).o/,$(notdir $(subst .c,.o,$(VCPROMPT_SOURCES))))

VIMPS1_INC = -I. -I.. -I$(BASH_TOPDIR) -I$(BASH_TOPDIR)/lib -I$(BASH_TOPDIR)/builtins \
      -I$(BASH_INCDIR) -I$(BASH_BUILDDIR) -I$(BASH_LIBBUILD) \
      -I$(BASH_BUILDDIR)/builtins $(BASH_INTLINC) -I$(VCPROMPT_INCDIR) --include=/usr/include/getopt.h

##########

XCINFO_LDFLAGS = ${LD_FLAGS} -lX11 -lXfixes

##########

$(shell mkdir -p $(VCPROMPT_TOPDIR).o)

all: vimps1 xcinfo

##########

vimps1: vimps1.o $(VCPROMPT_OBJECTS)
	@echo $(VCPROMPT_OBJECTS)
	$(CC) $(VIMPS1_LDFLAGS) -o $@ vimps1.o $(VCPROMPT_OBJECTS) $(LIBS)

xcinfo: xcinfo.o
	$(CC) $(XCINFO_LDFLAGS) -o $@ xcinfo.o $(LIBS)

##########

$(VCPROMPT_OBJECTS):
	$(CC) $(VIMPS1_CFLAGS) $(CCFLAGS) $(VIMPS1_INC) -c -o $@ $(subst .o,,$(@:.o=.c))

vimps1.o: vimps1.c
	$(CC) $(VIMPS1_CFLAGS) $(CCFLAGS) $(VIMPS1_INC) -c -o $@ $<

xcinfo.o: xcinfo.c

##########

clean:
	rm -f vimps1 vimps1.o $(VCPROMPT_OBJECTS) xcinfo xcinfo.o

.PHONY: all clean

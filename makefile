# Makefile for gcc (and MinGW,  and clang)
# Usage: make [CLANG=Y] [XCOMPILE=Y] [MSWIN=Y] [tgt]
#
# [all|asc2eph|dump_eph|eph2asc|ftest|merge_de|testeph|sub_eph]
#
# Note 'all' does _not_ build 'sub_eph'.  'sub_eph', depends on the 'lunar'
# library,  available at https://github.com/Bill-Gray/lunar .  Get that,
# make and 'make install' it,  and _then_ do 'make sub_eph' if you really
# need the ability to extract a section of a DE ephemeris file.
#
#	'XCOMPILE' = cross-compile for Windows,  using MinGW,  on a Linux/BSD box
#	'MSWIN' = compile for Windows,  using MinGW,  on a Windows machine
#	'CLANG' = use clang instead of GCC;  Linux/BSD only
# None of these: compile using g++ on Linux or BSD

CFLAGS=-Wall -O3 -Wextra -pedantic -I $(INSTALL_DIR)/include
CC=g++
RM=rm -f
LIB=-lm

ifdef DEBUG
	CFLAGS += -g
endif

# You can have your include files in ~/include and libraries in
# ~/lib,  in which case only the current user can use them;  or
# (with root privileges) you can install them to /usr/local/include
# and /usr/local/lib for all to enjoy.

ifdef GLOBAL
	INSTALL_DIR=/usr/local
else
	INSTALL_DIR=~
endif

ifdef CLANG
	CC=clang
endif


# I'm using 'mkdir -p' to avoid error messages if the directory exists.
# It may fail on very old systems,  and will probably fail on non-POSIX
# systems.  If so,  change to '-mkdir' and ignore errors.

ifdef MSWIN
	EXE=.exe
	MKDIR=-mkdir
else
	MKDIR=mkdir -p
endif

ifdef XCOMPILE
	CC=x86_64-w64-mingw32-g++
	EXE=.exe
endif

all: asc2eph$(EXE) dump_eph$(EXE) eph2asc$(EXE) ftest$(EXE) merge_de$(EXE) testeph$(EXE)

install:
	$(MKDIR) $(INSTALL_DIR)/include
	cp jpleph.h $(INSTALL_DIR)/include
	$(MKDIR) $(INSTALL_DIR)/lib
	cp libjpl.a $(INSTALL_DIR)/lib

uninstall:
	-rm $(INSTALL_DIR)/include/jpleph.h
	-rm $(INSTALL_DIR)/lib/libjpl.a

libjpl.a: jpleph.o
	-$(RM) libjpl.a
	ar rv libjpl.a jpleph.o

.cpp.o:
	$(CC) $(CFLAGS) -c $<

asc2eph$(EXE):          asc2eph.o f_strtod.o
	$(CC) -o asc2eph$(EXE) asc2eph.o f_strtod.o $(LIB)

ftest$(EXE):          ftest.o f_strtod.o
	$(CC) -o ftest$(EXE) ftest.o f_strtod.o

eph2asc$(EXE):          eph2asc.o libjpl.a
	$(CC) -o eph2asc$(EXE) eph2asc.o libjpl.a $(LIB)

dump_eph$(EXE):          dump_eph.o libjpl.a
	$(CC) -o dump_eph$(EXE) dump_eph.o libjpl.a $(LIB)

merge_de$(EXE):          merge_de.o libjpl.a
	$(CC) -o merge_de$(EXE) merge_de.o libjpl.a $(LIB)

sub_eph$(EXE):          sub_eph.o libjpl.a
	$(CC) -o sub_eph$(EXE) sub_eph.o libjpl.a -L $(INSTALL_DIR)/lib -llunar $(LIB)

sub_eph.o: sub_eph.cpp
	$(CC) $(CFLAGS) -c -DTEST_MAIN sub_eph.cpp

testeph$(EXE):          testeph.o libjpl.a
	$(CC) -o testeph$(EXE) testeph.o libjpl.a $(LIB)

clean:
	$(RM) *.o
	$(RM) asc2eph$(EXE)
	$(RM) dump_eph$(EXE)
	$(RM) eph2asc$(EXE)
	$(RM) ftest$(EXE)
	$(RM) merge_de$(EXE)
	$(RM) sub_eph$(EXE)
	$(RM) testeph$(EXE)
	$(RM) libjpl.a

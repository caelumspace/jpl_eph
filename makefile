# Makefile for gcc (and MinGW,  and clang)
# Note dependence of 'sub_eph' on the 'lunar' library.  This is available
# at https://github.com/Bill-Gray/lunar .
# Note also that 'sub_eph' is the last file to be built.  You can make
# everything else and ignore the missing dependency error if you aren't
# interested in building 'sub_eph'.
#	'XCOMPILE' = cross-compile for Windows,  using MinGW,  on a Linux/BSD box
#	'MSWIN' = compile for Windows,  using MinGW,  on a Windows machine
#	'CLANG' = use clang instead of GCC;  Linux/BSD only
# None of these: compile using g++ on Linux or BSD

CFLAGS=-Wall -O3 -Wextra -pedantic -I $(INSTALL_DIR)/include
CC=g++
RM=-rm

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
	LIB=-lm
endif

ifdef MSWIN
	EXE=.exe
endif

ifdef XCOMPILE
	CC=x86_64-w64-mingw32-g++
	EXE=.exe
endif

all: asc2eph$(EXE) dump_eph$(EXE) eph2asc$(EXE) ftest$(EXE) merge_de$(EXE) testeph$(EXE) sub_eph$(EXE)

install:
	-mkdir $(INSTALL_DIR)
	cp jpleph.h $(INSTALL_DIR)/include
	cp libjpl.a $(INSTALL_DIR)/lib

uninstall:
	-rm $(INSTALL_DIR)/include/jpleph.h
	-rm $(INSTALL_DIR)/lib/libjpl.a

libjpl.a: jpleph.o
	$(RM) libjpl.a
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

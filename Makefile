
.PHONY:	ALWAYS

all:	tarlisted

CC=gcc

CFLAGS=	-O2
LFLAGS=	-s

WARN0=	-Wall -Wstrict-prototypes -pedantic -Wno-long-long
WARN1=	$(WARN0) -Wcast-align -Wpointer-arith  # -Wfloat-equal #-Werror
WARN=	$(WARN1) -W -Wwrite-strings -Wcast-qual -Wshadow  # -Wconversion

LFOPT=	-DLARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64

TLOBJS=	tarlisted.o md5.o

tarlisted: conf.h $(TLOBJS)
	$(CC) $(LFLAGS) $(WARN) -o $@ $(TLOBJS) $(LFOPT)


.c.o:
	$(CC) $(CFLAGS) $(WARN) -c -o $@ $< $(LFOPT)

md5.o: md5.h conf.h 


conf.h:	genconf.sh Makefile
	sh genconf.sh $(CC) $(LFOPT)

test:	tarlisted
	sed -n 's/#[:]#//p' tarlisted.c | ./tarlisted -V -zo test.tar.gz
	sed -n 's/#[:]#//p' tarlisted.c | ./tarlisted -V -Mo test.md5sum

#FIXME more tests.

chkprefix: ALWAYS
	@[ x"$(PREFIX)" != x ] \
		|| { sed -n 's/^#pfx: \?//p;' Makefile; false; }

#pfx:
#pfx:  Can not install: PREFIX missing.
#pfx:
#pfx:  try for example: make install PREFIX=/usr/local
#pfx:

install: tarlisted chkprefix
	sed -n "/^itl: / { s/itl://; s|%PREFIX|$$PREFIX|p; }" Makefile \
		| ./tarlisted '|' tar -C / -xvf -

itl: tarlisted file version 2
itl: 755 root root . %PREFIX /
itl: 755 root root . %PREFIX/bin /
itl: 755 root root . %PREFIX/bin/tarlisted tarlisted
itl: 755 root root . %PREFIX/man /
itl: 755 root root . %PREFIX/man/man1 /
itl: 644 root root . %PREFIX/man/man1/tarlisted.1 tarlisted.1
itl: tarlisted file end


GitLog: ALWAYS #SvnVersion_unmodified #ALWAYS #$(FILES)
	git log --name-status > $@

targz: tarlisted GitLog
	sed -n '/^targz.sh:/,/^ *$$/ p' Makefile | tail -n +3 | sh -ve #-nv

bindeb: tarlisted GitLog
	sed -n '/^bindeb.sh:/,/^ *$$/ p' Makefile | tail -n +3 | sh -ve #-nv


clean: ALWAYS
	rm -f tarlisted *.o conf.h test.* GitLog *~ 

distclean: clean


targz.sh:
	exit 1 # this target is not to be run.
	version=`sed -n 's/^#define VERSION "//; T; s/".*//p; q;' tarlisted.c`
	for n in tarlisted.c md5.c md5.h genconf.sh tarlisted.1 Makefile GitLog
	do
		echo 644 root root . tarlisted-$version/$n $n
	done | ./tarlisted -V -zo tarlisted-$version.tar.gz
	set +e
	echo Created tarlisted-$version.tar.gz
	exit 0

bindeb.sh:
	exit 1 # this target is not to be run.
	echo to be done

#EOF

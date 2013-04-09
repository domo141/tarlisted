
.PHONY:	ALWAYS

all:	tarlisted

CC=gcc

CFLAGS=	-O2 #-fstack-protector-all
LFLAGS=	-s

WARN0=	-Wall -Wstrict-prototypes -pedantic -Wno-long-long
WARN1=	$(WARN0) -Wcast-align -Wpointer-arith  # -Wfloat-equal #-Werror
WARN=	$(WARN1) -W -Wwrite-strings -Wcast-qual -Wshadow  # -Wconversion

LFOPT=	-D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64

TLOBJS=	tarlisted.o

tarlisted: tarlisted.o
	$(CC) $(LFLAGS) -o $@ $(TLOBJS) $(LFOPT)

tarlisted.o: tarlisted.c Makefile
	$(CC) $(CFLAGS) $(WARN) -c -o $@ $< $(LFOPT)

test:	tarlisted
	sed -n 's/#[:]#//p' tarlisted.c | ./tarlisted -V -zo test.tar.gz

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
	sed '1,/^$@.sh:/d;/^#.#eos/q' Makefile | sh -s yes

# Note: this goal does not cross-compile.
targz.sh:
	test -n "$1" || exit 1 # internal shell script; not to be made directly
	set -eu
	version=`sed -n 's/^#define VERSION "//; T; s/".*//p; q;' tarlisted.c`
	for n in tarlisted.c tarlisted.1 Makefile GitLog
	do
		echo 644 root root . tarlisted-$version/$n $n
	done | ./tarlisted -V -zo tarlisted-$version.tar.gz
	set +e
	echo Created tarlisted-$version.tar.gz
#	#eos
	exit 1 # not reached

webpage:
	sed '1,/^$@.sh:/d;/^#.#eos/q' Makefile | sh -s yes
	@echo check date in tarlisted.1 separately
	@echo Update freshmeat and linuxlinks '(+sourcefiles)'

webpage.sh:
	test -n "$1" || exit 1 # internal shell script; not to be made directly
	set -eu
	GROFF_NO_SGR=1 TERM=vt100; export GROFF_NO_SGR TERM
	exec >README.html
	echo '<hr/>'
	echo '<pre>'
	groff -man -T latin1 tarlisted.1 | perl -e '
	my %htmlqh = qw/& &amp;   < &lt;   > &gt;   '\'' &apos;   " &quot;/;
	sub htmlquote($) { $_[0] =~ s/([&<>'\''"])/$htmlqh{$1}/ge; }
	while (<>) { htmlquote $_; s/[_&]\010&/&/g;
		s/((?:_\010[^_])+)/<u>$1<\/u>/g; s/_\010(.)/$1/g;
		s/((?:.\010.)+)/<b>$1<\/b>/g; s/.\010(.)/$1/g; print $_; }'
	echo '</pre>'
	exec > /dev/null
#	#eos
	exit 1 # not reached

clean: ALWAYS
	rm -f tarlisted *.o test.* GitLog *~

distclean: clean

.SUFFIXES:

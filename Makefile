
.PHONY:	ALWAYS

all:	tarlisted

tarlisted: tarlisted.c
	sh tarlisted.c

test:	tarlisted
	sed -n 's/#[:]#//p' tarlisted.c \
		| ./tarlisted -V -o test.tar.gz '|' gzip -c

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


SvnLog: ALWAYS #SvnVersion_unmodified #ALWAYS #$(FILES)
	( echo "# Created using svn -v log" | tr '\012' ' ';\
	  echo "| sed -n -e '\$${x;p;x;p;q};/^--*\$$/{x;/./p;d};x;p'" ;\
	  echo '# This file is not version controlled' ;\
	  echo ;\
	  svn -v log | sed -n -e '$${x;p;x;p;q};/^--*$$/{x;/./p;d};x;p' \
	) > $@

SvnVersion_unmodified: SvnVersion
	@[ x"`sed 's/[0-9]*//' SvnVersion`" = x ] || \
	  {  echo Version number `cat SvnVersion` not single, unmodified.; \
	     exit 1; } # exit 0 when testing, exit 1 when not.

SvnVersion: ALWAYS
	svn up
	svnversion . > $@

tgz: tarlisted SvnVersion_unmodified SvnLog
	sed -n '/^targz.sh:/,/^ *$$/ p' Makefile | tail +3 | sh -ve #-nv

clean: ALWAYS
	rm -f tarlisted Svn[LV]* *~ 

distclean: clean


targz.sh:
	exit 1 # this target is not to be run.
	version=`sed -n 's/^#define VERSION "//; T; s/".*//p; q;' tarlisted.c`
	for n in tarlisted.c tarlisted.1 Makefile SvnLog
	do
		echo 644 root root . tarlisted-$version/$n $n
	done | ./tarlisted -V -o tarlisted-$version.tar.gz '|' gzip -c 
	exit 0


# Every now and then I need to test some subversion functionality...
tmprepo: clean
	sed -n '/^tmprepo.sh:/,/^ *$$/ p' Makefile | tail +3 | sh -ve #-nv

tmprepo.sh:
	exit 1 # this target is not to be run.
	ts=`date +%Y%m%d-%H%M`
	pwd=`pwd`
	exlfile=../excl.$$
	trd=tmprepo-$ts
	rm -rf $trd
	mkdir $trd $trd/R
	trap 'rm -f $exlfile' 0
#	#svn st --no-ignore | sed -ne 's/[?I] *//; T; s/.*/"&"/p' > $exlfile
	svn st --no-ignore | sed -ne 's/[?I] *//p' > $exlfile
	svnadmin create $trd/R
	svn co file://$pwd/$trd/R $trd/w
	gtar --exclude .svn -X $exlfile -cf - * | tar -C $trd/w -xvf -
	(cd $trd/w; svn add .; svn commit -m 'Added files.')
	: ignore warning: "''" ... above.
	set +v
	echo Temp repository is located at ./$trd/w

#EOF

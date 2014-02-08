Tarlisted
=========

Tarlisted creates ***IEEE Std 1003.1-1988 (“POSIX.1”) ustar format***
archives whose header contents can be adjusted flexibly.

The original name 'tarlisted' is due to the file list format used
for tarlisted input data. New `tarlisted.pm` uses perl function call
interface for this data to be provided.

The new perl "module" is more flexible in many ways but currently
its functionality is limited to plain files whose name length
is maximum of 99 octets long; The C binary provides support to
files (maxlen 254 octets), directories (maxlen 254), symbolic/hard
links (maxlen 99 octets) and fifos & device nodes (max 254 octets).

That said, c code is pretty much complete -- from the git history
one can see features have even been removed. It would probably
be nice to have more flexible conditionals in tarlisted file format
but that is probably just SMOP unless critical need arises.
The perl "module" will gain new features on the need basis
(patches tol^H^H^H^H welcome, though).

At the time of writing, theere is a small usage example of `tarlisted.pm`
in Makefile creating `tarlisted-3.2.tar.xz` (*txz32.pl:*). See the manual
page [tarlisted32.md](tarlisted32.md) for the features of unix/w32
compilable executable.

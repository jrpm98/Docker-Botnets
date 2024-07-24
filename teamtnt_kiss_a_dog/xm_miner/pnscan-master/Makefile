# Makefile.in for pnscan
#
# Makefile.  Generated from Makefile.in by configure.


# Some 'make' variants does not include CPPFLAGS when compiling, some do
.c.o:
	$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

DESTDIR =
srcdir =	.


prefix =	/usr/local
exec_prefix =	${prefix}
datarootdir =	${prefix}/share

bindir =	${exec_prefix}/bin
mandir =	${datarootdir}/man
man1dir =	${mandir}/man1

CC = 		gcc
INSTALL =	/usr/bin/install -c
TAR =		tar

PACKAGE = 	pnscan
VERSION =	1.14.1

CPPFLAGS = 	 -I. -I${srcdir}
CFLAGS = 	-pthread -Wall -g -O2
LDFLAGS = 	
LIBS = 		-lpthread 



VALGRIND = 	valgrind
VALGRINDFLAGS =	--leak-check=full --track-origins=yes --error-exitcode=1 # --show-leak-kinds=all 

DISTCHECKDIR =	/tmp/distcheck-$(PACKAGE)-$(VERSION)
DISTDIR =	/tmp/build-$(PACKAGE)-$(VERSION)

PBINS =		pnscan
POBJS =		pnscan.o bm.o

TBINS =		t_listen
TOBJS = 	t_listen.o

BINS =		$(PBINS) $(TBINS)


all: $(BINS) Makefile


Makefile: Makefile.in config.status
	./config.status

config.h: config.h.in config.status
	./config.status


pnscan: $(POBJS)
	$(CC) $(LDFLAGS) -o pnscan $(POBJS) $(LIBS)

pnscan.o: 	pnscan.c bm.h
bm.o:		bm.c bm.h

t_listen: t_listen.o
	$(CC) $(LDFLAGS) -o t_listen $(TOBJS) $(LIBS)


# Clean targets
maintainer-clean: distclean
	rm -f configure config.h.in

distclean: clean
	rm -fr config.status config.log stamp-h1 .deps autom4te.cache Makefile config.h *.tar.gz
	(cd pkgs && $(MAKE) distclean)

clean mostlyclean:
	-rm -f *~ \#* *.o *.o core *.core vgcore.* $(BINS)


# Git targets
push: distclean
	git add -A && git commit -a && git push

pull:
	git pull


# Install targets
install install-all: install-bin install-man

install-strip: install-strip-bin install-man

install-bin: $(PBINS)
	$(INSTALL) -d "$(DESTDIR)$(bindir)"
	$(INSTALL) $(PBINS) "$(DESTDIR)$(bindir)"

install-strip-bin: $(PBINS)
	$(INSTALL) -d "$(DESTDIR)$(bindir)"
	$(INSTALL) -s $(PBINS) "$(DESTDIR)$(bindir)"

install-man:  pnscan.1
	-$(INSTALL) -d "$(DESTDIR)$(man1dir)"
	-$(INSTALL) pnscan.1 "$(DESTDIR)$(man1dir)" && \
	  gzip -f "$(DESTDIR)$(man1dir)/pnscan.1"


uninstall-all uninstall: uninstall-bin uninstall-man

uninstall-bin:
	rm -f "$(DESTDIR)$(bindir)/pnscan"

uninstall-man:
	test -d "$(TESTDIR)$(man1dir)" && rm -f "$(DESTDIR)$(man1dir)"/pnscan.1 "$(DESTDIR)$(man1dir)"/pnscan.1.gz


CHECKCMD =	./pnscan

# Check targets
check:	check-simple check-verbose check-hostname check-response check-response-fail

check-simple: $(BINS)
	$(CHECKCMD) 127.0.0.1 `./t_listen`

check-verbose: $(BINS)
	$(CHECKCMD) -v 127.0.0.1 `./t_listen`

check-hostname: $(BINS)
	$(CHECKCMD) -s 127.0.0.1 `./t_listen`

check-response: $(BINS)
	$(CHECKCMD) -r "Hello" 127.0.0.1 `./t_listen`

check-response-fail: $(BINS)
	$(CHECKCMD) -r "Hejsan" 127.0.0.1 `./t_listen`

check-valgrind:
	$(MAKE) CHECKCMD="$(VALGRIND) $(CHECKCMD)" check


distcheck: $(PACKAGE)-$(VERSION).tar.gz
	@if test -d "$(DISTCHECKDIR)"; then \
	  chmod -R +w "$(DISTCHECKDIR)" && rm -fr "$(DISTCHECKDIR)"; \
	fi;
	mkdir -p "$(DISTCHECKDIR)" && \
	  gunzip <"$(PACKAGE)-$(VERSION).tar.gz" | \
	    (cd "$(DISTCHECKDIR)" && $(TAR) xf - && \
	     chmod -R -w "$(PACKAGE)-$(VERSION)" && \
	     mkdir b && cd b && ../$(PACKAGE)-$(VERSION)/configure && \
	     $(MAKE) && $(MAKE) -s check) && echo "*** distcheck: OK"
	@chmod -R +w "$(DISTCHECKDIR)" && rm -fr "$(DISTCHECKDIR)";


# Dist targets

dist:	$(PACKAGE)-$(VERSION).tar.gz

$(PACKAGE)-$(VERSION).tar.gz: Makefile
	rm -fr "$(DISTDIR)" && mkdir -p "$(DISTDIR)/$(PACKAGE)-$(VERSION)" && \
	  cp -r * "$(DISTDIR)/$(PACKAGE)-$(VERSION)" && \
	  (cd "$(DISTDIR)/$(PACKAGE)-$(VERSION)" && $(MAKE) distclean)
	(cd "$(DISTDIR)" && $(TAR) cvf - "$(PACKAGE)-$(VERSION)") | gzip >"$(PACKAGE)-$(VERSION)".tar.gz
	echo rm -fr "$(DISTDIR)"
	@echo ""
	@echo "*** $(PACKAGE)-$(VERSION).tar.gz created"


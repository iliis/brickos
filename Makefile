##
## brickOS - the independent LEGO Mindstorms OS
## Makefile - allows you to keep the upper hand
## (c) 1998 by Markus L. Noga <markus@noga.de>
##

#  distribution name (all lower-case by convention)
PACKAGE = brickos
#  version of this release, let's use the verision from our VERSION file
VERSION = $(shell cat VERSION)

#  set this once to accommodate our new dir name
export BRICKOS_ROOT=$(shell cd . && pwd)/


#
#  makefile to build the brickOS operating system and demo files
# 
SUBDIRS=util lib boot demo


all:
	for i in $(SUBDIRS) ; do $(MAKE) $(MFLAGS) -C $$i || exit 2 ; done

depend:
	for i in $(SUBDIRS) ; do $(MAKE) $(MFLAGS) NODEPS=yes -C $$i depend || exit 2 ; done

clean:
	for i in $(SUBDIRS) ; do $(MAKE) $(MFLAGS) NODEPS=yes -C $$i clean ; done
	rm -rf *.o *.map *.coff *.srec *.dis* *~ *.bak *.tgz *.s tags

c++:
	$(MAKE) -C demo c++

realclean:
	for i in $(SUBDIRS) ; do $(MAKE) $(MFLAGS) NODEPS=yes -C $$i realclean ; done
	rm -rf *.o *.map *.coff *.srec *.dis* *~ *.bak *.tgz *.s tags
	rm -rf doc/html-c++ doc/html-c doc/rtf-c doc/rtf-c++ doc/rtf
	rm -f Doxyfile-c.log Doxyfile-c.rpt .Doxyfile-c-doneflag  *.out

upgrade-doxygen:
	doxygen -u Doxyfile-c 
	doxygen -u Doxyfile-c++
	doxygen -u Doxyfile

# doc/html-c subdirectory
html-c: Doxyfile-c-report

brickos-html-c-dist.tar.gz: html-c 
	cd doc;tar --gzip -cvf $@ $?;mv $@ ..;cd -

html-c-dist: brickos-html-c-dist.tar.gz

Doxyfile-c.log:
	doxygen Doxyfile-c >Doxyfile-c.log 2>&1

Doxyfile-c.rpt: Doxyfile-c.log
	grep Warn Doxyfile-c.log | sed -e 's/^.*brickos\///' | cut -f1 -d: | sort | \
	 uniq -c | sort -rn | tee Doxyfile-c.rpt

.Doxyfile-c-doneflag:  Doxyfile-c.rpt
	@for FIL in `cat Doxyfile-c.rpt | cut -c9-99`; do \
	  OUTFILE=`echo $$FIL | sed -e 's/[\/\.]/-/g'`.out; \
	  echo "# FILE: $$OUTFILE" >$$OUTFILE; \
	  grep "$$FIL" Doxyfile-c.rpt >>$$OUTFILE; \
	  grep "$$FIL" Doxyfile-c.log | grep Warn >>$$OUTFILE; \
	done
	@touch $@


Doxyfile-c-report: .Doxyfile-c-doneflag
	ls -ltr *.out





# doc/html-c++ subdirectory
html-c++:
	doxygen Doxyfile-c++

# doc/html subdirectory
html-full:
	doxygen Doxyfile

html: html-full html-c html-c++

# tags
tag:
	ctags --format=1 kernel/*.c include/*.h include/*/*.h

.PHONY: all depend clean realclean html tag c++


# ------------------------------------------------------------
#  Components of this release to be packaged
# ------------------------------------------------------------
#
SOURCES = boot demo kernel lib util
HEADERS = include 

EXTRA_DIST = Doxy* doc h8300.rcx

DIST_COMMON =  README ChangeLog CONTRIBUTORS LICENSE VERSION Makefile* NEWS TODO


# ------------------------------------------------------------
#  No user customization below here...
# ------------------------------------------------------------
#
# The following 'dist' target code is taken from a makefile 
#   generated by the auto* tools
#
SHELL = /bin/sh

DISTFILES = $(DIST_COMMON) $(SOURCES) $(HEADERS) $(TEXINFOS) $(EXTRA_DIST)

#  locations for this package build effort
SRC_ROOTDIR = .
DISTDIR = $(PACKAGE)-$(VERSION)

#  tools we use to make distribution image
TAR = tar
GZIP_ENV = --best

#  make our distribution tarball
dist: notinsourcetree distdir
	-chmod -R a+r $(DISTDIR)
	GZIP=$(GZIP_ENV) $(TAR) chozf $(DISTDIR).tar.gz $(DISTDIR)
	-rm -rf $(DISTDIR)
	@echo "---------------------------------------------------------"
	@echo "     MD5 sum for $(PACKAGE) v$(VERSION)"
	@md5sum $(DISTDIR).tar.gz
	@echo "---------------------------------------------------------"

#  check for target being run in CVS source tree... bail if is...
notinsourcetree:
	@if [ -d $(SRC_ROOTDIR)/CVS ]; then \
		echo ""; \
		echo "---------------------------------------------------------"; \
		echo "  make: target 'dist' not for use in source tree"; \
		echo "---------------------------------------------------------"; \
		echo ""; \
		exit 2; \
	fi

#  build a copy of the source tree which can be zipped up and then deleted
distdir: $(DISTFILES)
	-rm -rf $(DISTDIR)
	mkdir $(DISTDIR)
	-chmod 777 $(DISTDIR)
#	DISTDIR=`cd $(DISTDIR) && pwd`; 
	@for file in $(DISTFILES); do \
	  d=$(SRC_ROOTDIR); \
	  if test -d $$d/$$file; then \
	    cp -pr $$d/$$file $(DISTDIR)/$$file; \
	  else \
	    test -f $(DISTDIR)/$$file \
	    || ln $$d/$$file $(DISTDIR)/$$file 2> /dev/null \
	    || cp -p $$d/$$file $(DISTDIR)/$$file || :; \
	  fi; \
	done
#  cleanup files which should not make it into any release
	@find $(DISTDIR) -type d -depth -name 'CVS' -exec rm -rf {} \; 
	@find $(DISTDIR) -type f -name '.cvs*' -exec rm -f {} \; 
	@find $(DISTDIR) -type f -name '.dep*' -exec rm -f {} \; 

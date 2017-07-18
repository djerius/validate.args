include $(top_srcdir)/snippets/create_am_macros.mk

ACLOCAL_AMFLAGS = -I m4 --install

EXTRA_DIST              +=			\
			bootstrap		\
			$(ROCKSPEC_FILE_NAME)

MAINTAINERCLEANFILES	+= \
			Makefile.in   \
			aclocal.m4    \
			config.guess  \
			config.h.in   \
			config.sub    \
			configure     \
			depcomp       \
			install-sh    \
			ltmain.sh     \
			missing       \
			mkinstalldirs


include %D%/src/Makefile.am
include %D%/doc/Makefile.am
include %D%/tests/Makefile.am

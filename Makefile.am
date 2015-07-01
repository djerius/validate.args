include $(top_srcdir)/snippets/create_am_macros.mk

ACLOCAL_AMFLAGS = -I m4

SUBDIRS			=		\
			validate	\
			doc		\
			tests		\
			m4

#-------------------------------------------------------------------
#

# sources that must be made prior to compilation
BUILT_SOURCES           +=

# extra files to add to the distribution
EXTRA_DIST              +=			\
			bootstrap		\
			$(ROCKSPEC_FILE_NAME)

# Any files make built
CLEANFILES              +=

# Any files configure built
DISTCLEANFILES          += config.cache

# Any files maintainer built(with autoconf, automake, etc)
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


#-------------------------------------------------------------------
# Snippets go after here, unless their docs say otherwise
# Any files make built

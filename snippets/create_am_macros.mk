#============================================================================
# create_am_macros.mk

CREATE_AM_MACROS_MK =

include $(top_srcdir)/snippets/am_vars.mk
include $(top_srcdir)/snippets/inst_vars.mk

#-------------------------------------------------------------------
# The following must ALWAYS be defined, as certain makefile snippets
# require them.  If you get errors like
#
#  EXTRA_DIST must be set with `=' before using `+='
#
# we've missed defining one here.

# local build scripts
noinst_SCRIPTS		=

# local headers
noinst_HEADERS		=

# convenience libraries
noinst_LTLIBRARIES	=

# libtool libraries
lib_LTLIBRARIES		=
pkglib_LTLIBRARIES	=

# installed headers
include_HEADERS		=
pkginclude_HEADERS	=
nobase_include_HEADERS	=

AM_CPPFLAGS             =

# -----------------------
# Test stuff

TESTS			=
XFAIL_TESTS		=
check_PROGRAMS		=
check_SCRIPTS		=

# sources that must be made prior to compilation
BUILT_SOURCES           =

# extra files to add to the distribution
EXTRA_DIST              =

# Files tha make built but that one would want to rebuild
MOSTLYCLEANFILES	=

# Any other files make built
CLEANFILES              =

# Any files configure built
DISTCLEANFILES          =

# Any files maintainer built (with autoconf, automake, etc)
MAINTAINERCLEANFILES    =

# Extra suffixes for automake
SUFFIXES		=

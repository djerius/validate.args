##============================================================================
## create_am_macros.mk

CREATE_AM_MACROS_MK =

include %D%/am_vars.mk
include %D%/inst_vars.mk

##-------------------------------------------------------------------
## The following must ALWAYS be defined, as certain makefile snippets
## require them.  If you get errors like
##
##  EXTRA_DIST must be set with `=' before using `+='
##
## we've missed defining one here.

## programs
bin_PROGRAMS		=

## distributed scripts
bin_SCRIPTS		=

## distributed scripts
dist_bin_SCRIPTS	=

## local build scripts
noinst_SCRIPTS		=

## local headers
noinst_HEADERS		=

## convenience libraries
noinst_LTLIBRARIES	=

noinst_DATA		=

## libtool libraries
lib_LTLIBRARIES		=
pkglib_LTLIBRARIES	=

## installed headers
include_HEADERS		=
pkginclude_HEADERS	=
nobase_include_HEADERS	=

AM_CPPFLAGS             =

## -----------------------
## Test stuff

AM_TESTS_ENVIRONMENT    =
TESTS			=
TESTS_ENVIRONMENT	=
TEST_EXTENSIONS		=
XFAIL_TESTS		=
check_PROGRAMS		=
check_SCRIPTS		=

## sources that must be made prior to compilation
BUILT_SOURCES           =

## extra files to add to the distribution
EXTRA_DIST              =

## Files tha make built but that one would want to rebuild
MOSTLYCLEANFILES	=

## Any other files make built
CLEANFILES              =

## Any files configure built
DISTCLEANFILES          =

## Any files maintainer built (with autoconf, automake, etc)
MAINTAINERCLEANFILES    =

## Extra suffixes for automake
SUFFIXES		=

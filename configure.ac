#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.
AC_PREREQ([2.57])

AC_INIT([validate-args],[1.5.9],[https://bitbucket.org/djerius/validate.args/issues],[validate-args], [https://bitbucket.org/djerius/validate.args])
AM_INIT_AUTOMAKE([ check-news subdir-objects silent-rules color-tests parallel-tests ])

AC_SUBST( ROCKSPEC_VERSION, 1 )
AC_SUBST( ROCKSPEC_FILE_NAME,[AC_PACKAGE_NAME-AC_PACKAGE_VERSION-${ROCKSPEC_VERSION}.rockspec] )
AC_CONFIG_SRCDIR([src/validate/args.lua])
AC_CONFIG_MACRO_DIR([m4])

# Checks for programs.
MST_CHECK_LUA([5.1],[5.2])
AC_PROG_INSTALL

MST_POD_GEN_DOCS

MST_TESTDEP_SETUP

AC_PATH_PROG(BUSTED,busted)
MST_TESTDEP_TEST( [test -n "$BUSTED"],[Missing test dependency, 'busted' ])

MST_PROG_LUA_MODULES([
                      busted
                     ]
                     , ,
                     [ MST_TESTDEP_FLAG([no], [missing required Lua modules])]
)

MST_TESTDEP_STATUS

# Checks for library functions.
AC_CONFIG_FILES([Makefile])
AC_CONFIG_FILES(${ROCKSPEC_FILE_NAME}:rockspec.in)
AC_OUTPUT

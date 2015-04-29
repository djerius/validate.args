#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.
AC_PREREQ([2.57])

AC_INIT([validate-args],[1.5.6],[https://bitbucket.org/djerius/validate.args/issues],[validate-args], [https://bitbucket.org/djerius/validate.args])
AM_INIT_AUTOMAKE([ check-news ])

AC_SUBST( ROCKSPEC_VERSION, 1 )
AC_SUBST( ROCKSPEC_FILE_NAME,[AC_PACKAGE_NAME-AC_PACKAGE_VERSION-${ROCKSPEC_VERSION}.rockspec] )
AC_CONFIG_SRCDIR([validate/args.lua])

# Checks for programs.
AC_PATH_PROG(LUA,lua)
test -z "$LUA" &&
	AC_MSG_ERROR([Cannot find lua executable])

AC_PATH_PROG(LUAC,luac)
test -z "$LUAC" &&
	AC_MSG_ERROR([Cannot find luac executable])

AC_PROG_INSTALL

m4_include(snippets/lib_lua.ac)
MST_POD_GEN_DOCS

# requirements for tests
MST_PROG_LUA_MODULES([
		       lunatest
                      ], ,
                     [ AC_MSG_ERROR([missing required Lua modules])]
                     )


# Checks for library functions.
AC_CONFIG_FILES([Makefile
		 validate/Makefile
		 doc/Makefile
		 tests/Makefile
		 ])
AC_CONFIG_FILES(${ROCKSPEC_FILE_NAME}:rockspec.in)
AC_OUTPUT

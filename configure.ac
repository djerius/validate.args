#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.
AC_PREREQ([2.57])


AC_INIT([validate-args],[1.0.0],[http://jeeves.cfa.harvard.edu/bugzilla/],[validate-args])
AM_INIT_AUTOMAKE([ check-news ])

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
m4_include(snippets/pod_docs.ac)

# requirements for tests

LUA_DEPENDENCIES="lunatest"

for dep in $LUA_DEPENDENCIES ; do
    if ! lua -l $dep -e 'return' 2>/dev/null ; then
    	AC_MSG_ERROR([Cannot find lua library/module $dep])
    fi
done

# Checks for library functions.
AC_CONFIG_FILES([Makefile
		 validate/Makefile
		 docs/Makefile
		 tests/Makefile
		 ])
AC_CONFIG_FILES([tests/test1], [chmod +x tests/test1])
AC_OUTPUT

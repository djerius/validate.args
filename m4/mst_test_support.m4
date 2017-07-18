##							-*- Autoconf -*-

# serial 1

# MST_TESTDEP_SETUP
#------------------
# Perform setup steps for dependencies needed to run tests
# By default missing test dependencies results in a fatal error.
# This routine provides a configure switch to make them optional,
# as well as creating the variables which will hold state information
#
# Use MST_TESTDEP_TEST and MST_TESTDEP_FLAG to update the state,
# and MST_TESTDEP_STATUS to report on the final status of the test
# dependencies (and die if necessary)
AC_DEFUN([MST_TESTDEP_SETUP],
[
 AC_ARG_ENABLE(testdeps,
	AC_HELP_STRING([--enable-testdeps],
		       [missing test dependencies are a fatal error. [[default=yes]]]),
	[MST_REQUIRE_TESTDEPS="$enableval"],
	[MST_REQUIRE_TESTDEPS=yes] )

 # normalize flag
 test "$MST_REQUIRE_TESTDEPS" != no && MST_REQUIRE_TESTDEPS=yes

 MST_HAVE_TESTDEPS=

])# MST_TESTDEP_SETUP


# MST_TESTDEP_TEST(command, message)
#-----------------------------------
# Run the command.  If it returns false, report that the test dependency
# has failed and update the global dependency state.
AC_DEFUN([MST_TESTDEP_TEST],
[AC_REQUIRE([MST_TESTDEP_SETUP])
 AS_IF( [$1],
	[ test "$MST_HAVE_TESTDEPS" != no && MST_HAVE_TESTDEPS=yes ],
	[
	  MST_HAVE_TESTDEPS=no
	  m4_ifnblank([$2],[AC_MSG_WARN([$2: Missing test dependency])])
	]
      )
])# MST_TESTDEP_TEST

# MST_TESTDEP_FLAG( flag value, message)
#---------------------------------------
# If the flag value is "no", report that the test dependency has failed
# and update the global dependency state.
AC_DEFUN([MST_TESTDEP_FLAG],
[
  MST_TESTDEP_TEST([test "$1" != no], [$2])
])# MST_TESTDEP_FLAG


# MST_TESTDEP_STATUS
#-------------------
# If any test dependencies have failed, report that.  Exit with error
# unless --disable-testdeps was passed to configure.
# Creates and automake conditional HAVE_TESTDEPS which reflects the
# state of test dependencies
AC_DEFUN([MST_TESTDEP_STATUS],
[AC_REQUIRE([MST_TESTDEP_SETUP])
  if  test "$MST_HAVE_TESTDEPS" = no ; then
    if test $MST_REQUIRE_TESTDEPS = yes ; then
	AC_MSG_ERROR([Missing test dependencies.  Use --disable-testdeps to ignore])
    else
	AC_MSG_WARN([Missing test dependencies.  Some test will not be run])
    fi

  fi
 AM_CONDITIONAL( HAVE_TEST_DEPS, test "$MST_HAVE_TESTDEPS" != no)
])# MST_TESTDEP_STATUS



# MST_PROG_TESTPERL
# -----------------
# Check if Perl is available.  Sets the global test dependency state.
# Sets the AM_CONDITIONAL HAVE_TESTPERL
AC_DEFUN([MST_PROG_TESTPERL],
[AC_REQUIRE([MST_TESTDEP_SETUP])
 AC_PATH_PROG(PERL,perl)
 MST_TESTDEP_TEST( [test -n "$PERL"], [Can't find Perl])
 AM_CONDITIONAL( HAVE_TESTPERL, [test -n "$PERL"] )
])# MST_PROG_TESTPERL


# MST_PROG_TESTSHELL
# -------------------
# Check if an acceptable shell (bash, ksh) is available.
# Sets the global test dependency state.
# Sets the AM_CONDITIONAL HAVE_TESTSHELL
AC_DEFUN([MST_PROG_TESTSHELL],
[AC_ARG_VAR([TESTSHELL],[shell used to run tests])
 if test "x$ac_cv_env_TESTSHELL_set" != "xset"; then
    AC_MSG_NOTICE([checking for a compatible test shell])
    AC_PATH_PROG(BASHELL,bash)
    TESTSHELL="$BASHELL"
    if test -z "$TESTSHELL"; then
      AC_PATH_PROG(KSHELL,ksh)
      TESTSHELL="$KSHELL"
    fi
    MST_TESTDEP_TEST([test -n "$TESTSHELL"],[Can't find ksh or bash])
 else
   AC_MSG_NOTICE([using $TESTSHELL as the test shell])
 fi
 test -n "$TESTSHELL" && test ! -x "$TESTSHELL" \
	  && AC_MSG_ERROR( [testshell $TESTSHELL is not an executable] )
 AM_CONDITIONAL( HAVE_TESTSHELL, [test -n "$TESTSHELL"] )
])# MST_CHECK_TESTSHELL

# MST_CHECK_TESTPROG(program)
#-----------------------------------
# check if the program exists
AC_DEFUN([MST_CHECK_TESTPROG],
[AC_REQUIRE([MST_TESTDEP_SETUP])
 mst_check_testprog=no

 m4_define(mst_check_testprog,m4_normalize([$1]))
 AS_VAR_PUSHDEF(mst_check_testprog_var,mst_check_testprog_var_[]mst_check_testprog)
 AC_CHECK_PROG(mst_check_testprog_var,mst_check_testprog,[yes],[no])
 MST_TESTDEP_FLAG($mst_check_testprog_var)
 m4_undefine([mst_check_testprog_var])
 m4_undefine([mst_check_testprog])

])# MST_CHECK_TESTPROG

# MST_CHECK_TEST_PKG_MODULES(VARIABLE-PREFIX, MODULES)
#-----------------------------------
# check if the modules exist. uses pkg-config's PKG_CHECK_MODULES to
# see if the modules exist, but instead of aborting on error, sets the
# MST_TESTDEP flag appropriately
AC_DEFUN([MST_CHECK_TEST_PKG_MODULES],
[PKG_CHECK_MODULES([$1],[$2],
	[MST_TESTDEP_FLAG([yes])],
	[MST_TESTDEP_FLAG([no])])
])# MST_CHECK_TEST_PKG_MODULES


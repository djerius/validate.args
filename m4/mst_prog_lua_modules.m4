# serial 1

AC_DEFUN([MST_PROG_LUA_MODULES],[dnl

m4_define([mst_lua_modules])
m4_foreach([mst_lua_module], m4_split(m4_normalize([$1])),
	  [
	   m4_append([mst_lua_modules],[']mst_lua_module[' ])
          ])

# Make sure we have perl
if test -z "$LUA"; then
   AC_PATH_PROG(LUA,lua)
fi

if test "x$LUA" != x; then
   mst_lua_modules_failed=0
  for mst_lua_module in mst_lua_modules; do

    mst_lua_modulex=`echo $mst_lua_module | sed "s/\./_/g"`

    AC_CACHE_CHECK([for lua module $mst_lua_module], [mst_cv_lua_$mst_lua_modulex],
                   [eval mst_cv_lua_$mst_lua_modulex=no
		     $LUA -l $mst_lua_module -e 'return' 2>/dev/null \
		       && eval mst_cv_lua_$mst_lua_modulex=yes
		   ]
		   )
    if eval test "x\${mst_cv_lua_$mst_lua_modulex}" = "xno" ; then
      mst_lua_modules_failed=1
    fi

  done

  # Run optional shell commands
  if test "$mst_lua_modules_failed" = 0; then
    :
    $2
  else
    :
    $3
  fi
else
  AC_MSG_WARN(could not find lua)
fi])dnl

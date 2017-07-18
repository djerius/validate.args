include $(top_srcdir)/snippets/lua_compile.mk

noinst_PROGRAMS = %D%/LUA

%C%_LUA_SOURCES	=				\
	%D%/validate/args.lua			\
	%D%/validate/inplace.lua

%D%/LUA$(EXEEXT) : $(%C%_LUA_SOURCES:%.lua=%.lc)
	touch $@

DISTCLEANFILES  +=                              \
	%D%/LUA$(EXEEXT)                        \
	$(%C%_LUA_SOURCES:%.lua=%.lc)

include %D%/lua_lib.mk

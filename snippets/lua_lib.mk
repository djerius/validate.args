#============================================================================
# lua_lib.mk

LUA_LIB_MK =

# Snippets required:
#
#	lib_lua.ac
LUA_COMPILE_MK +=

# Variables
#
# Required
#	LUA_SRCS - list of lua source files (with .lua suffix)
#
# Optional
#       sublib   - path heirarchy of module

luasublibdir = $(lualibdir)/$(sublib)
luacsublibdir = $(luaclibdir)/$(sublib)

dist_luasublib_DATA  = $(LUA_SRCS)
dist_luacsublib_DATA  = $(LUA_SRCS:%.lua=%.lc)

CLEANFILES		+= $(dist_luacsublib_DATA)
EXTRA_DIST		+= $(dist_luasublib_DATA)

# recompile code on install so binary chunks get the correct path to the source
install-data-hook:
	@test "$(LUA_PATH)set" = set || export LUA_PATH="$(LUA_PATH)" ;\
	list='$(dist_luasublib_DATA)' ;\
	for p in $$list; \
	do \
	  b=`expr "$$p" : "\(.*\)[.]lua"` ;\
	  $(LUAC) -o $(DESTDIR)$(luacsublibdir)/$$b.lc $(DESTDIR)$(luasublibdir)/$$b.lua ;\
	done

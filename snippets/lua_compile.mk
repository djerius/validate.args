#============================================================================
# lua_compile.mk

LUA_COMPILE_MK =

SUFFIXES += .lc .lua
.lua.lc :
	test "$(LUA_PATH)set" = set || export LUA_PATH="$(LUA_PATH)" ;\
	$(LUAC) -o $@ $<


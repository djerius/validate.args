#============================================================================
# lua_compile.mk

LUA_COMPILE_MK =

%.lc : %.lua
	test "$(LUA_PATH)set" = set || export LUA_PATH="$(LUA_PATH)" ;\
	$(LUAC) -o $@ $<


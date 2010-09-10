#============================================================================
# lua_compile.mk

%.lc : %.lua
	test "$(LUA_PATH)set" = set || export LUA_PATH="$(LUA_PATH)" ;\
	$(LUAC) -o $@ $< 


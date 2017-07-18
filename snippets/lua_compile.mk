##============================================================================
## lua_compile.mk

LUA_COMPILE_MK =

SUFFIXES += .lc .lua
AX_V_LUAC = $(AX_V_LUAC_@AM_V@)
AX_V_LUAC_ = $(AX_V_LUAC_@AM_DEFAULT_V@)
AX_V_LUAC_0 = @echo LUAC $@;

mst__lua_set_path=test "$(LUA_PATH)set" = set || export LUA_PATH="$(LUA_PATH)"
.lua.lc :
	@$(MKDIR_P) `expr "$@" : "\(.*\)/[^/]*.lc"`
	$(AX_V_LUAC)$(mst__lua_set_path); $(LUAC) -o $@ $<


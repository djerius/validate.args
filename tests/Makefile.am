# Test executables to be run

if HAVE_TEST_DEPS
TESTS                   +=			\
			%D%/api.lua		\
			%D%/callback.lua	\
			%D%/constraints.lua	\
			%D%/defaults.lua	\
			%D%/default_spec.lua	\
			%D%/deffunc.lua		\
			%D%/excludes.lua	\
			%D%/inplace.lua		\
			%D%/multiple.lua	\
			%D%/mutate.lua		\
			%D%/named.lua		\
			%D%/name.lua		\
			%D%/nested.lua		\
			%D%/object.lua		\
			%D%/ordered.lua		\
			%D%/positional.lua	\
			%D%/requires.lua	\
			%D%/special.lua		\
			%D%/vtypes.lua
endif


TEST_EXTENSIONS += .lua
LUA_LOG_COMPILER=$(BUSTED) -o TAP -m '$(top_srcdir)/%D%/?.lua;$(top_srcdir)/src/?.lua;$$LUA_PATH;;'

EXTRA_DIST              +=			\
			$(TESTS)		\
			%D%/setup.lua

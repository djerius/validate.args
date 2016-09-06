include $(top_srcdir)/snippets/create_am_macros.mk

# Test executables to be run

if HAVE_TEST_DEPS
TESTS                   += 			\
			callback.lua		\
			constraints.lua		\
			defaults.lua		\
			default_spec.lua	\
			deffunc.lua		\
			excludes.lua		\
			inplace.lua		\
			multiple.lua		\
			mutate.lua		\
			named.lua		\
			name.lua		\
			nested.lua		\
			object.lua		\
			ordered.lua		\
			positional.lua		\
			requires.lua		\
			special.lua		\
			vtypes.lua
endif


TEST_EXTENSIONS = .lua
LUA_LOG_COMPILER=$(BUSTED) -o TAP -m '$(srcdir)/?.lua;$(top_srcdir)/?.lua;$$LUA_PATH;;'


#-------------------------------------------------------------------
#

# sources that must be made prior to compilation
BUILT_SOURCES           +=

# extra files to add to the distribution
EXTRA_DIST              +=			\
			$(TESTS)		\
			setup.lua

# Any files make built
CLEANFILES              +=

# Any files configure built
DISTCLEANFILES          +=

# Any files maintainer built(with autoconf, automake, etc)
MAINTAINERCLEANFILES	+= Makefile.in

#-------------------------------------------------------------------
# Snippets go after here, unless their docs say otherwise

include $(top_srcdir)/snippets/substitute_config_variables.mk

DO_SUBST	+= \
		-e 's,[@]LUA[@],$(LUA),g'

%: %.in Makefile
	p="$@"; f=$(strip_dir) \
	$(do_subst) < $(srcdir)/$$f.in > $$f
	chmod +x $@

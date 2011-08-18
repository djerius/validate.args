include $(top_srcdir)/snippets/create_am_macros.mk

# Test executables to be run
TESTS			= driver.lua
TESTS_ENVIRONMENT	= \
		LUA_PATH="@top_srcdir@/?.lua;@srcdir@/?.lua;$$LUA_PATH;;" \
		$(LUA)



#-------------------------------------------------------------------
#

# sources that must be made prior to compilation
BUILT_SOURCES           +=

# extra files to add to the distribution
EXTRA_DIST              +=		\
			callback.lua	\
			constraints.lua	\
			deepcompare.lua	\
			defaults.lua	\
			default_spec.lua	\
			deffunc.lua	\
			driver.lua	\
			excludes.lua	\
			inplace.lua	\
			multiple.lua	\
			mutate.lua	\
			named.lua	\
			name.lua	\
			nested.lua	\
			object.lua	\
			ordered.lua	\
			positional.lua	\
			requires.lua	\
			special.lua	\
			utils.lua	\
			vtypes.lua

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

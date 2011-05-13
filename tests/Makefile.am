include $(top_srcdir)/snippets/create_am_macros.mk

# Test executables to be run
TESTS			= test1


#-------------------------------------------------------------------
#

# sources that must be made prior to compilation
BUILT_SOURCES           +=

# extra files to add to the distribution
EXTRA_DIST              +=		\
			constraints.lua	\
			deffunc.lua	\
			driver.lua	\
			excludes.lua	\
			mutate.lua	\
			named.lua	\
			nested.lua	\
			positional.lua	\
			requires.lua	\
			special.lua	\
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

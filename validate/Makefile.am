include $(top_srcdir)/snippets/create_am_macros.mk
include $(top_srcdir)/snippets/substitute_config_variables.mk

LUA_SRCS	= args.lua
sublib		= validate

#-------------------------------------------------------------------
#

# sources that must be made prior to compilation
BUILT_SOURCES           +=

# extra files to add to the distribution
EXTRA_DIST              +=

# Any files make built.
CLEANFILES              += $(dist_lualib_DATA)

# Any files configure built
DISTCLEANFILES          +=

# Any files maintainer built(with autoconf, automake, etc)
MAINTAINERCLEANFILES    += Makefile.in

#-------------------------------------------------------------------
# Snippets go after here, unless their docs say otherwise

include $(top_srcdir)/snippets/lua_compile.mk
include $(top_srcdir)/snippets/lua_lib.mk

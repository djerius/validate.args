##============================================================================
## lua_lib.mk
##
##  * distributes sources
##  * compiles sources
##  * installs sources
##  * recompiles and installs compiled objects to get correct path in installed objects
##  * uninstalls compiled objects
##  * maintains leading directory paths
##
## The Lua Makefile.am should be in the *parent* directory of the top
## level module directory E.g. if your namespace is saotrace, create
## the following hierarchy:
##
##
## lua
## |-- Makefile.am
## |-- saotrace
## |   |-- raygen
## |   |   |-- config.lua
## |   |   |-- validate
## |   |   |   |-- idist.lua
## |   |   `-- validate.lua
## |   `-- raygen.lua
##
## Note how the first level of lua source files is in the saotrace subdirectory.
##
## Makefile.am should look something like this:
##
## include $(top_srcdir)/snippets/lua_compile.mk
## 
## noinst_PROGRAMS = %D%/LUA
## %C%_LUA_SOURCES =		\
## 	%D%/x.lua
## 
## %D%/LUA$(EXEEXT) : $(%C%_LUA_SOURCES:%.lua=%.lc)
## 	touch $@
## 
## DISTCLEANFILES	+=			\
## 	%D%/LUA$(EXEEXT)		\
## 	$(%C%_LUA:%.lua=%.lc)
## 
## include lua_lib.mk


##============================================================================
## Prerequisites
##
CREATE_AM_MACROS_MK +=
LUA_COMPILE_MK +=

##============================================================================
## Variables
##
##	%C%_LUA_SRCS - list of lua source files (with .lua suffix)

%C%_LUA_SOURCES		+=

##============================================================================

noinst_DATA		+= $(%C%_LUA_SOURCES:%.lua=%.lc)
CLEANFILES		+= $(%C%_LUA_SOURCES:%.lua=%.lc)

## recompile code on install so binary chunks get the correct path to
## the source

install-data-hook::
	$(mst__lua_set_path) ;							\
	list='$(%C%_LUA_SOURCES)' ;						\
	D="%D%";								\
	for p in $$list; do							\
	  s="$$p"; p=$(mst__strip_pfx); d=$(mst__dirname);			\
	  $(MKDIR_P) $(DESTDIR)$(lualiblcdir)/$$d $(DESTDIR)$(lualibdir)/$$d;	\
	  cp $(top_srcdir)/"$$s" "$(DESTDIR)$(lualibdir)/$$p" ;			\
	  $(LUAC) -o								\
	        $(DESTDIR)$(lualiblcdir)/$(mst__strip_sfx).lc			\
		$(DESTDIR)$(lualibdir)/$$p ;					\
	done

uninstall-local::
	-list='$(%C%_LUA_SOURCES)' ;				\
	D="%D%";						\
	for p in $$list; do					\
	  p=$(mst__strip_pfx);					\
	  rm -f $(DESTDIR)$(lualiblcdir)/$(mst__strip_sfx).lc;	\
	  rm -f $(DESTDIR)$(lualibdir)/$$p;			\
	done

#============================================================================
# substitute_config_variables.mk

SUBSTITUTE_CONFIG_VARIABLES_MK =

# this sed statement is used to fill in configuration variables in
# source (not autotool) files which use the following configuration
# variables:

# extras from the fans 
DO_SUBST	=

do_subst	= sed \
		  -e 's,[@]PACKAGE[@],$(PACKAGE),g'			\
		  -e 's,[@]PACKAGE_VERSION[@],$(PACKAGE_VERSION),g'	\
		  -e 's,[@]PERL[@],$(PERL),g'				\
		  -e 's,[@]PERL_USELIB[@],$(PERL_USELIB),g'		\
		  -e 's,[@]STARTPERL[@],$(STARTPERL),g'			\
		  -e 's,[@]VERSION[@],$(VERSION),g'			\
		  -e 's,[@]bindir[@],$(bindir),g'			\
		  -e 's,[@]datadir[@],$(datadir),g'			\
		  -e 's,[@]includedir[@],$(includedir),g'		\
		  -e 's,[@]infodir[@],$(infodir),g'			\
		  -e 's,[@]libdir[@],$(libdir),g'			\
		  -e 's,[@]libexecdir[@],$(libexecdir),g'		\
		  -e 's,[@]localstatedir[@],$(localstatedir),g'		\
		  -e 's,[@]mandir[@],$(mandir),g'			\
		  -e 's,[@]sbindir[@],$(sbindir),g'			\
		  -e 's,[@]sharedstatedir[@],$(sharedstatedir),g'	\
		  -e 's,[@]sysconfdir[@],$(sysconfdir),g'		\
		  -e 's,[@]paramdir[@],$(paramdir),g'			\
		  -e 's,[@]perllibdir[@],$(perllibdir),g'		\
		  -e 's,[@]pdllibdir[@],$(pdllibdir),g'			\
		  -e 's,[@]lualibdir[@],$(lualibdir),g'			\
		  -e 's,[@]pkgdatadir[@],$(pkgdatadir),g'		\
		  -e 's,[@]pkgvdatadir[@],$(pkgvdatadir),g'		\
		  -e 's,[@]prefix[@],$(prefix),g'			\
		  -e 's,[@]program_prefix[@],$(program_prefix),g'	\
		  -e 's,[@]mst_program_prefix[@],$(mst_program_prefix),g'	\
		  -e 's,[@]top_builddir[@],$(top_builddir),g'		\
		  -e 's,[@]top_srcdir[@],$(top_srcdir),g'		\
		  -e 's,[@]srcdir[@],$(srcdir),g'			\
		  $(DO_SUBST)


# use this as follows:
#
# target : Makefile $(srcdir)/target.in
#	p="$@"; f=$(strip_dir) \
#	$(do_subst) < $(srcdir)/$$f.in > $$f || { rm $$f ; false ; }
#
# additional commands (such as chmod +x $@) may prove useful

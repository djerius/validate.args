include $(top_srcdir)/snippets/create_am_macros.mk

#-------------------------------------------------------------------
#

# sources that must be made prior to compilation
BUILT_SOURCES           +=

# extra files to add to the distribution
EXTRA_DIST              +=			\
			validate.args.pod	\
			validate.inplace.pod

# Any files make built.
CLEANFILES              +=

# Any files configure built
DISTCLEANFILES          +=

# Any files maintainer built(with autoconf, automake, etc)
MAINTAINERCLEANFILES    += Makefile.in

#-------------------------------------------------------------------
# Snippets go after here, unless their docs say otherwise


# this must be an explicit list of man pages; no make variables allowed.
# currently, only section l man pages are supported.
dist_manl_MANS = validate.args.l validate.inplace.l

POD_SFX = .pod
PODS = validate.args validate.inplace
POD_HTML = validate.inplace.html validate.args.html
POD_PDF  = validate.inplace.pdf validate.args.pdf

include $(top_srcdir)/snippets/prog_pod.mk

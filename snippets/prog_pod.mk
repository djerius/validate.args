#============================================================================
# prog_pod.mk - generate program documentation from POD input

# this snippets orchestrates the creation of PostScript,
# HTML, and UNIX section l man pages from POD input.
# see prog_pod_base.mk for more information.

# Prerequisites:
#	create_am_macros.mk



POD_DIR = $(srcdir)/

include $(top_srcdir)/snippets/prog_pod_base.mk

EXTRA_DIST 		+= $(PODS:%=%$(POD_SFX))

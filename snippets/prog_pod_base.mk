#============================================================================
# prog_pod_base.mk - generate program documentation from POD input

PROG_POD_BASE_MK =

# this snippets orchestrates the creation of PDF, HTML, and
# UNIX section l man pages from POD input.  it is generally not used
# directly.

# Prerequisites:
CREATE_AM_MACROS_MK +=


# THE caller must define
#  POD_SFX - the suffix of the pod source file
#  PODS    - the list of documentation, basenames only
#  POD_DIR - where the POD source is located. must end in / if not empty.

POD_SFX +=
PODS +=

# Because of how automake works, the caller must set
# 	dist_manl_MANS
# to the explicit list of man pages. no makefile variables allowed!

# Note that this implies that all pod source files have the same suffix
# If this is not the case, add rules to create .pod files like so:
#
# %.pod : %.xx
#	podselect %< > $@
#
# and set POD_SFX to .pod.  Just make sure that %.xx is an invariant
# file (i.e. not something created from a .in file).  Usually just using
# the .in file as the source is pretty safe.

include $(top_srcdir)/snippets/pod_html.mk
include $(top_srcdir)/snippets/pod_man.mk
include $(top_srcdir)/snippets/pod_pdf.mk

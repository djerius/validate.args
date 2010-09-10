#============================================================================
# pod_html.mk

# The caller must define
#  POD_SRC - the POD source file pattern match (see prog_pod.mk)
#  POD_SFX - the suffix of the pod source file
#  PODS    - the list of documentation, basenames only

# Note that this implies that all pod source files have the same suffix
# If this is not the case, add rules to create .pod files like so:
#
# %.pod : %.xx
#	podselect %< > $@
#
# and set POD_SFX to .pod.  Just make sure that %.xx is an invariant
# file (i.e. not something created from a .in file).  Usually just using
# the .in file as the source is pretty safe.

# The caller must 
#	include create_am_macros.mk
# prior to 
#	include pod_html.mk

# if the caller is using this file directly (and not going through prog_pod.mk)
# add
#
#   EXTRA_DIST += $(PODS:%=%$(POD_SFX))



# Any files make built
CLEANFILES		+=			\
			pod2htmi.tmp		\
			pod2htmd.tmp

POD_HTML		= $(PODS:%=%.html)

MAINTAINERCLEANFILES	+= $(POD_HTML)

htmldir			= $(datadir)/doc/$(PACKAGE)/html

dist_html_DATA		= $(POD_HTML)

SUFFIXES += .html

%.html: $(POD_DIR)%$(POD_SFX)
	pod2html --outfile=$@ --infile=$< --title=`basename $< $(POD_SFX)`

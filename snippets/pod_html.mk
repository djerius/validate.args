##============================================================================
## pod_html.mk

POD_HTML_MK =

## prerequisite packages
CREATE_AM_MACROS_MK +=
DOC_DIRS_MK +=

##----------------------------------------
## caller must define these
##
## A simple list of POD files to process.  Just the basename's, no suffix.
## No Make Magic
PODS +=

## A simple list of the generated HTML files.  No Make Magic!
POD_HTML +=

## the suffix of the files containing POD
POD_SFX +=


## Note that this implies that all pod source files have the same suffix
## If this is not the case, add rules to create .pod files like so:
##
## %.pod : %.xx
##	podselect %< > $@
##
## and set POD_SFX to .pod.  Just make sure that %.xx is an invariant
## file (i.e. not something created from a .in file).  Usually just using
## the .in file as the source is pretty safe.

## if the caller is using this file directly (and not going through prog_pod.mk)
## add
##
##   EXTRA_DIST += $(PODS:%=%$(POD_SFX))


## Only attempt to generate documentation if we can.  Always
## distribute it; this will cause failure on devel systems without
## pod2html, but that's ok.


## Any files make built
CLEANFILES		+=			\
			%D%/pod2htmi.tmp	\
			%D%/pod2htmd.tmp


MAINTAINERCLEANFILES	+= $(POD_HTML)

dist_html_DATA		+= $(POD_HTML)

if MST_POD_GEN_DOCS_HTML

SUFFIXES += .html $(POD_SFX)

$(POD_SFX).html:
	pod2html --outfile=$@ --infile=$< --cachedir=%D% --title=`basename $< $(POD_SFX)`


else !MST_POD_GEN_DOCS_HTML

## can't create documentation.  for end user, the distributed
## documentation will get installed.

## for maintainer, must create fake docs or make will fail,
## but don't distribute


$(POD_SFX).html:
	touch $@

dist-hook::
	echo >&2 "Cannot create distribution as cannot create HTML documentation"
	echo >&2 "Install pod2html (from CPAN)"
	false

endif !MST_POD_GEN_DOCS_HTML

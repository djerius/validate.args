#============================================================================
# pod_pdf.mk

POD_PDF_MK =

# Prerequistes:
CREATE_AM_MACROS_MK +=

#----------------------------------------
# caller must define these
#
# A simple list of POD files to process.  Just the basename's, no suffix.
# No Make Magic
PODS +=

# A simple list of the generated PDF files.  No Make Magic!
POD_PDF +=

# the suffix of the files containing POD
POD_SFX +=

MAINTAINERCLEANFILES   += $(POD_PDF)

pdfdir			= $(datadir)/doc/$(PACKAGE)
dist_pdf_DATA		= $(POD_PDF)

if MST_POD_GEN_DOCS_PDF

SUFFIXES	+= .pdf $(POD_SFX)

if MST_POD_GEN_DOCS_PDF_MAN_PS

SUFFIXES	+= .man .ps .pdf

$(POD_SFX).man: $(POD_DIR)
	pod2man  --release=' ' --center=' ' $< > $@

.man.ps:
	groff -man $< > $@

.ps.pdf :
	ps2pdf $< $@

endif  MST_POD_GEN_DOCS_PDF_MAN_PS

if HAVE_POD2PDF

$(POD_SFX).pdf:
	pod2pdf --title=`basename $< $(POD_SFX)` --output-file $@ --page-size=Letter $<

endif  HAVE_POD2PDF

else !MST_POD_GEN_DOCS_PDF

# can't create documentation.  for end user, the distributed
# documentation will get installed.

# for maintainer, must create fake PDF docs or make will fail,
# but don't distribute

$(POD_SFX).pdf:
	touch $@

dist-hook::
	echo >&2 "Cannot create distribution as cannot create PDF documentation"
	echo >&2 "Install ps2pdf or App::pod2pdf (from CPAN)"
	false

endif !MST_POD_GEN_DOCS_PDF




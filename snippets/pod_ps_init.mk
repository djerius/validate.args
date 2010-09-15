#============================================================================
# pod_ps_init.mk

# this snippet initializes the "environment" for the pod_ps family of snippets

# Prerequisites:
#	create_am_macros.mk


POD_PS			= $(PODS:%=%.ps)
POD_PDF			= $(PODS:%=%.pdf)

MAINTAINERCLEANFILES   += $(POD_PS) $(POD_PDF)

psdir			= $(datadir)/doc/$(PACKAGE)
dist_ps_DATA		= $(POD_PS)

pdfdir			= $(datadir)/doc/$(PACKAGE)
dist_pdf_DATA		= $(POD_PDF)

SUFFIXES 	       += .ps .pdf

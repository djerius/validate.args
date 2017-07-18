##=========================================================
## doc_dirs.mk - installation directories for documentation

DOC_DIRS_MK =

## Prerequisites:
CREATE_AM_MACROS_MK +=

docdir		= $(datadir)/doc/$(PACKAGE)
doc_DATA	=

htmldir         = $(docdir)/html
dist_html_DATA  =

pdfdir          = $(docdir)
dist_pdf_DATA	=


psdir           = $(docdir)
dist_ps_DATA    =




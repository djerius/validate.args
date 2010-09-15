#============================================================================
# pod_psl.mk - generate PostScript from man section l input

# Prerequisites:
#	pod_ps_init.mk
#	pod_manl.mk

SUFFIXES		+= .l.ps .l.pdf

%.l.ps: %.l
	groff -man $< > $@

%.ps: %.l
	groff -man $< > $@

%.l.pdf : %.l.ps
	ps2pdf $< $@

%.pdf : %.ps
	ps2pdf $< $@

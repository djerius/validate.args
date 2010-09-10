#============================================================================
# pod_ps_init.mk

# this snippet initializes the "environment" for the pod_ps family of snippets

# Prerequisites:
#	create_am_macros.mk


POD_PS			= $(PODS:%=%.ps)

MAINTAINERCLEANFILES   += $(POD_PS)

psdir			= $(datadir)/doc/$(PACKAGE)
dist_ps_DATA		= $(POD_PS)

SUFFIXES 	       += .ps

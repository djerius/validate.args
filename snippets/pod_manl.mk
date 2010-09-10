#============================================================================
# pod_manl.mk

# Snippets required:
#	create_am_macros.mk
#	pod_man_init.mk

# Variables required:
#
# see pod_man_init.mk
#
#  PODLSFX 
#    may be empty.  explicit suffix for .l files. used in conjunction
#    with POD_SFX


# ensure that 
#
#	pod_man_l.mk
#	pod_man_3.mk
#	pod_man_5.mk
#	pod_man_7.mk
#
# are kept in sync!

POD_MAN		+= $(dist_manl_MANS)

SUFFIXES += .l
MAINTAINERCLEANFILES	+=		  \
			$(dist_manl_MANS)

%.l: $(POD_DIR)%$(PODLSFX)$(POD_SFX)
	pod2man --name=`basename $< $(PODLSFX)$(POD_SFX)` \
		--section=l --release=' ' --center=' ' $< > $@

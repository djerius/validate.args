#============================================================================
# pod_man.mk

POD_MAN_MK =

# Snippets required:
CREATE_AM_MACROS_MK +=

# Variables required:
#
# see pod_man_init.mk
#
#  POD?SFX
#    may be empty.  explicit suffix for .? files. used in conjunction
#    with POD_SFX

POD_MAN		=				\
		$(dist_manl_MANS)		\
		$(dist_man3_MANS)		\
		$(dist_man5_MANS)		\
		$(dist_man7_MANS)

if MST_POD_GEN_DOCS_MAN


SUFFIXES += .l .3 .5 .7
MAINTAINERCLEANFILES	+= $(POD_MAN)

PODL_SFX = .l
POD3_SFX = .3
POD5_SFX = .5
POD7_SFX = .7


# e.g. create foo.l from foo.pod
%.l: $(POD_DIR)%$(POD_SFX)
	pod2man --name=`basename $< $(POD_SFX)` \
		--section=l --release=' ' --center=' ' $< > $@

# e.g. create foo.l from foo.l.pod
%.l: $(POD_DIR)%$(PODL_SFX)$(POD_SFX)
	pod2man --name=`basename $< $(PODL_SFX)$(POD_SFX)` \
		--section=l --release=' ' --center=' ' $< > $@


%.3: $(POD_DIR)%$(POD3_SFX)$(POD_SFX)
	pod2man --name=`basename $< $(POD3_SFX)$(POD_SFX)` \
		--section=3 --release=' ' --center=' ' $< > $@

%.5: $(POD_DIR)%$(POD5_SFX)$(POD_SFX)
	pod2man --name=`basename $< $(POD5_SFX)$(POD_SFX)` \
		--section=5 --release=' ' --center=' ' $< > $@

%.7: $(POD_DIR)%$(POD7_SFX)$(POD_SFX)
	pod2man --name=`basename $< $(POD7_SFX)$(POD_SFX)` \
		--section=7 --release=' ' --center=' ' $< > $@


endif MST_POD_GEN_DOCS_MAN



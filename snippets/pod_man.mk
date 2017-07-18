##============================================================================
## pod_man.mk

POD_MAN_MK =

## Snippets required:
CREATE_AM_MACROS_MK +=

## Variables required:
##
## see pod_man_init.mk
##
##  POD?SFX
##    may be empty.  explicit suffix for .? files. used in conjunction
##    with POD_SFX

POD_MAN		=				\
		$(dist_manl_MANS)		\
		$(dist_man3_MANS)		\
		$(dist_man5_MANS)		\
		$(dist_man7_MANS)

if MST_POD_GEN_DOCS_MAN

MAINTAINERCLEANFILES	+= $(POD_MAN)

PODL_SFX = .l
POD3_SFX = .3
POD5_SFX = .5
POD7_SFX = .7


SUFFIXES +=					\
	$(PODL_SFX) $(PODL_SFX)$(POD_SFX)	\
	$(POD3_SFX) $(POD3_SFX)$(POD_SFX)	\
	$(POD5_SFX) $(POD5_SFX)$(POD_SFX)	\
	$(POD7_SFX) $(POD7_SFX)$(POD_SFX)

## e.g. create foo.l from foo.pod
$(POD_SFX).l:
	pod2man --name=`basename $< $(POD_SFX)` \
		--section=l --release=' ' --center=' ' $< > $@

## e.g. create foo.l from foo.l.pod
$(PODL_SFX)$(POD_SFX).l:
	pod2man --name=`basename $< $(PODL_SFX)$(POD_SFX)` \
		--section=l --release=' ' --center=' ' $< > $@

$(POD3_SFX)$(POD_SFX).3:
	pod2man --name=`basename $< $(POD3_SFX)$(POD_SFX)` \
		--section=3 --release=' ' --center=' ' $< > $@

$(POD5_SFX)$(POD_SFX).5:
	pod2man --name=`basename $< $(POD5_SFX)$(POD_SFX)` \
		--section=5 --release=' ' --center=' ' $< > $@

$(POD7_SFX)$(POD_SFX).7:
	pod2man --name=`basename $< $(POD7_SFX)$(POD_SFX)` \
		--section=7 --release=' ' --center=' ' $< > $@


endif MST_POD_GEN_DOCS_MAN



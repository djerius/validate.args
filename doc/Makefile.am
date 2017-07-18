include $(top_srcdir)/snippets/doc_dirs.mk

EXTRA_DIST              +=			\
			%D%/validate.args.pod	\
			%D%/validate.inplace.pod


POD_SFX = .pod
dist_manl_MANS = %D%/validate.args.l %D%/validate.inplace.l
PODS = %D%/validate.args %D%/validate.inplace
POD_HTML = %D%/validate.inplace.html %D%/validate.args.html
POD_PDF  = %D%/validate.inplace.pdf %D%/validate.args.pdf

include $(top_srcdir)/snippets/prog_pod.mk

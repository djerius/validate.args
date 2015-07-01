# MST_POD_GEN_DOCS
# ----------------
#
#  Find Pod conversion programs to generate documentation
AC_DEFUN([MST_POD_GEN_DOCS],
[
  AC_ARG_ENABLE([gen-docs],
    [AS_HELP_STRING([--enable-gen-docs],
       [generate documentation if possible])],
    [],
    [enable_gen_docs=yes])

  AS_CASE([$enable_gen_docs],
	  [yes],[
		  AC_CHECK_PROG([POD2MAN],[pod2man],[yes],[no])
		  AM_CONDITIONAL([MST_POD_GEN_DOCS_MAN],[test $POD2MAN = yes])
		  AM_COND_IF([MST_POD_GEN_DOCS_MAN],
			     [],
			     [AC_MSG_WARN( "unable to generate manual pages; will install distributed version" )
			     ])
		  AC_CHECK_PROG([POD2HTML],[pod2html],[yes],[no])
		  AM_CONDITIONAL([MST_POD_GEN_DOCS_HTML],[test $POD2HTML = yes])
		  AM_COND_IF([MST_POD_GEN_DOCS_HTML],
			     [],
			     [AC_MSG_WARN( "unable to generate HTML documentation; will install distributed version" )
			     ])

		  AC_CHECK_PROG([POD2PDF],[pod2pdf],[yes],[no])
		  AM_CONDITIONAL([HAVE_POD2PDF],[test $POD2PDF = yes])

		  # if pod2pdf is not available, use pod2man, groff, and ps2pdf
		  doc_gen_pdf_from_man_ps=no
		  AM_COND_IF([HAVE_POD2PDF],
			     [],
			     [AM_COND_IF([MST_POD_GEN_DOCS_MAN],
					 [AC_CHECK_PROG([GROFF],[groff],[yes],[no])
					  AS_IF([test $GROFF = yes],
						[AC_CHECK_PROG([PS2PDF],[ps2pdf],[yes],[no])
						 AS_IF([test $PS2PDF = yes],
						       [doc_gen_pdf_from_man_ps=yes]
						      )
						],
					  )
					 ]
			      )
			     ]
		  )
		  AM_CONDITIONAL([MST_POD_GEN_DOCS_PDF_MAN_PS],[test $doc_gen_pdf_from_man_ps = yes])
		  AM_CONDITIONAL([MST_POD_GEN_DOCS_PDF],[test $POD2PDF = yes -o $doc_gen_pdf_from_man_ps = yes])

		  AM_COND_IF([MST_POD_GEN_DOCS_PDF],
			     [],
			     [AC_MSG_WARN( "unable to generate PDF documentation; will install distributed version" )
			     ]
		  )
		  ],
		  [
		  AM_CONDITIONAL([MST_POD_GEN_DOCS_MAN],[false])
		  AM_CONDITIONAL([MST_POD_GEN_DOCS_HTML],[false])
		  AM_CONDITIONAL([HAVE_POD2PDF],[false])
		  AM_CONDITIONAL([MST_POD_GEN_DOCS_PDF_MAN_PS],[false])
		  AM_CONDITIONAL([MST_POD_GEN_DOCS_PDF],[false])
		  AC_MSG_NOTICE([Not generating documentation; will install distributed documentation])		  
		  ]
)]

) # MST_POD_GEN_DOCS

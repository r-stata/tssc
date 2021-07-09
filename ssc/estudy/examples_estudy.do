use data_estudy.dta

*EXAMPLE 1
*Event study on two varlists, with one event window around the event date (July 9, 2015)
estudy boa ford boeing (apple netflix amazon facebook google) , datevar(date) evdate(07092015) dateformat(MDY) indexlist(mkt) lb1(-3) ub1(3) 

*EXAMPLE 2
*Event study on two varlists, with three event windows around the event date (July 9, 2015), a customized estimation window and the BMP test 
estudy boa ford boeing (apple netflix amazon facebook google) , datevar(date) evdate(07092015) dateformat(MDY) indexlist(mkt) lb1(-3) ub1(3) lb2(-3) ub2(-1) lb3(0) ub3(3) diagn(BMP) eswlb(-250) eswub(-20)

*EXAMPLE 3														
*Event study on four varlists, with three event windows around the event date (July 9, 2015), a customized estimation window and the KP test.
*ARs on single securities are not reported. Historical Mean Model is used.
estudy boa ford boeing(ibm facebook apple) (netflix cocacola amazon) (facebook boa ford boeing google) , datevar(date) evdate(07092015) dateformat(MDY) modtype(HMM) lb1(-3) ub1(3) lb2(-3) ub2(-1) lb3(0) ub3(3) diagn(KP) eswlb(-250) eswub(-20) supp(ind)

*EXAMPLE 4
*Event study on four varlists, with three event windows around the event date (July 9, 2015), a customized estimation window and the KP test.
*Only ARs on single securities are reported. Fama-French 3 factors model is used.
estudy boa ford boeing(ibm facebook apple) (netflix cocacola amazon) (facebook boa ford boeing google) , datevar(date) evdate(07092015) dateformat(MDY) modtype(MFM) indexlist(mkt smb hml) lb1(-3) ub1(3) lb2(-3) ub2(-1) lb3(0) ub3(3) diagn(KP) eswlb(-250) eswub(-20) supp(group) showpvalues nostar

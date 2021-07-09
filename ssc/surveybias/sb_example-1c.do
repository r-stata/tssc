use gles-preelection, replace
qui svyset vnvpoint [pweight=w_ipfges_1] , strata(distost)
surveybias educ, popvalues(4 36.1 30.5 29) svy 

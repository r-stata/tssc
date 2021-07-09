*!logtest version 1.0
*!Written 12Dec2014
*!Written by Mehmet Mehmetoglu
//set trace on
capture program drop logtest
	program logtest    
	version 13.1
syntax [if], m1(varlist) m2(varlist) 
	//di "`m1'"
	//di "`m2'"
	di " "
	
di in green "{bf:Likelihood ratio test for logit models}"
	di " "
	
di in white "     {bf:m2 (unrestricted/extended model)}"
tokenize `m2' // full model
	local depv2 `1'
	macro shift
	local indv2 `*'
	//di "`depv2'"
	//di "`indv2'"
local logopt "nolog noheader noci"
logit `depv2' `indv2', `logopt'   
	//ereturn list
tempname dfm2
	scalar `dfm2' = e(df_m)
	//di `dfm2'
tempname lrm2
	scalar `lrm2' = e(chi2)
	//di `lrm2'
di in yellow  "Nobs:" `e(N)' "     " "Pseudo-R2:" %-12.2f `e(r2_p)' "LR chi2(`e(df_m)'):" %-12.2f `e(chi2)'
di in yellow "                                      p-value:" %-12.3f `e(p)'
	di " "

di in white "     {bf:m1 (restricted/parsimonous model)}"
tokenize `m1' // parsimonous model
	local depv `1'
	macro shift
	local indv `*'
	//di "`depv'"
	//di "`indv'"
local logopt2 "nolog noheader noci"	
logit `depv' `indv' if e(sample), `logopt2'
	//ereturn list
tempname dfm1
	scalar `dfm1' = e(df_m) 
	//di `dfm1'
tempname lrm1
	scalar `lrm1' = e(chi2)
	//di `lrm1'
di in yellow  "Nobs:" `e(N)' "     " "Pseudo-R2:" %-12.2f `e(r2_p)' "LR chi2(`e(df_m)'):" %-12.2f `e(chi2)'
di in yellow "                                      p-value:" %-12.3f `e(p)'

if `dfm2' <= `dfm1' {
	di " "
	di in red "Number of predictors in m2 must be > than that in m1"
	exit
	}
di " "

di in white "     m2 versus m1"
di as smcl as txt  "{hline 53}"
tempname dfdiff
	scalar `dfdiff' = `dfm2'-`dfm1'
	//di `dfdiff'
tempname lrdiff
	scalar `lrdiff' = `lrm2'-`lrm1'
	//di `lrdiff' 

tempname pvaldiff
	scalar `pvaldiff' = chi2tail(`dfdiff', `lrdiff')
	di " "
if `pvaldiff' < 0.05 {
	di in yellow "             {bf:LR-difference between m2 and m1:} " %-12.2f `lrdiff' 
	di in yellow "                                     {bf:p-value:} " %-12.3f `pvaldiff'
	}
else {
	di in red "             {bf:LR-difference between m2 and m1:} " %-12.2f `lrdiff' 
	di in red "                                     {bf:p-value:} " %-12.3f `pvaldiff'
	}
	
di as smcl as txt  "{hline 53}"

end











****xvalols***************************************************************************
****Version 1.0.0
****07Dec2012                                           
****Joel Middleton (New York University) & John Ternovski (Analyst Institute)                                               
****joel.middleton@gmail.com               johnt1@gmail.com
**************************************************************************************

version 11
program define xvalols, eclass
syntax varlist, [cutoff(string)] 
***dropping old outputs
cap matrix drop crossfold_output
cap matrix define empty=(.)
cap ereturn matrix crossfold_output = empty

*tokenizing
tokenize `varlist'
local dv `1'
macro shift
preserve

*determining if the cutoff is missing, a variable, or a number
if "`cutoff'"=="" {
	local cutoff=2
}
cap confirm integer number `cutoff' 
if !_rc{
	tempvar randnum
	qui gen `randnum'=runiform()
	sort `randnum'
	tempvar sample
	qui egen `sample'=seq(), from(1) to(`cutoff')
	local length=`cutoff'
}
else {
	tempvar sample
	egen `sample'=group(`cutoff')
	qui sum `sample'
	local length=r(max)
	local custom_var=1
}


*runnning the crossfold	
tempvar yhat
qui gen `yhat'=.
forval i=1/`length' {
	ereturn scalar  output`i'=.
	qui reg `dv' `*' if `sample'!=`i'
	tempvar yhat_`i'
	qui predict `yhat_`i'' if `sample'==`i'
	qui replace `yhat'=`yhat_`i'' if `sample'==`i'
}

****outputting the data		
qui reg `yhat' `*'
local lnth=wordcount("`*'")
forval i=1/`lnth' {
	ereturn scalar  output`i'=_b[``i'']	
}
if "`custom_var'"=="1" {
	mkmat `yhat', matrix(crossfold_output) rownames(`cutoff')
}
else {
	mkmat `yhat', matrix(crossfold_output) rownames(`sample')
}
matrix colnames crossfold_output = yhat 
ereturn matrix crossfold_output = crossfold_output
restore
		
end

*

*! 1.2.0 NJC 4 September 2015 
* 1.1.1 NJC 14 August 2001 
* 1.1.0 NJC 25 April 2001 
* 1.0.0 NJC 28 February 2001
program cpspear, rclass 
        version 10 

	capture syntax varlist [if] [in] /// 
	[, Square Matrix(str) Header Format(str) * ]
	
	* if this syntax fails, try that with slash 
	local slash = _rc 

	if `slash' { 
		gettoken rowvars 0 : 0, parse("\")
		unab rowvars : `rowvars'
		local nrow : word count `rowvars'
		gettoken bs 0 : 0, parse("\") 
        	syntax varlist [if] [in] ///
		[, Square Matrix(str) Header Format(str) * ]
	}
	else { 
		local rowvars "`varlist'" 
		local nrow : word count `varlist' 
	} 	

	local ncol : word count `varlist'
	tokenize `varlist' 

        marksample touse
	if `slash' markout `touse' `rowvars'  
	
	tempname p 
	if "`matrix'" == "" { 
		tempname matrix 
		if "`header'" == "" local nohdr "noheader" 
	} 
	matrix `matrix' = J(`nrow',`ncol',.) 
	matrix `p' = `matrix'                

	if "`square'" != "" local square "^2" 
	if "`format'" == "" local format "%5.4f"  

        quietly forval i = 1/`nrow' {
                local row`i' : word `i' of `rowvars'
                forval j = 1/`ncol' {
                        spearman `row`i'' ``j'' if `touse'  
			mat `p'[`i',`j'] = r(p) 
			mat `matrix'[`i',`j'] = (r(rho))`square' 
                }
        }
	
	qui count if `touse' 	
	di in g "(obs=`r(N)')" 

	mat rownames `matrix' = `rowvars'
	mat colnames `matrix' = `varlist'
	mat li `matrix', `options' `nohdr' format(`format') 

	return matrix p = `p' 
	return matrix Rho = `matrix' 
	return scalar N = r(N) 	
end

/*

The original syntax was 

cpspear rowvarlist \ colvarlist [if] [in] [, options]

After the first -gettoken- `rowvars'   should be   rowvarlist
After the second -gettoken `bs'      should be   "\" 

The syntax is then 

colvarlist [if] [in] [, options]

Now (1.1.0) we allow also

cpspear varlist [if] [in] [, options]

which yields square matrices. 

*/

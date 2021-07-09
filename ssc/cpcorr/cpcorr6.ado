* rename NJC 3 September 2015 
*! 1.2.1 NJC 14 August 2001 
* 1.2.0 NJC 25 April 2001 
* 1.1.1 NJC 24 April 2001 
* 1.1.0 NJC 28 February 2001
program define cpcorr6
        version 6.0

	capture syntax varlist [if] [in] [aweight fweight] /*
	*/ [, Covariance Square Matrix(str) Header Format(str) * ]
	
	* if this syntax fails, try that with slash 
	local slash = _rc 

	if `slash' { 
		gettoken rowvars 0 : 0, parse("\")
		unab rowvars : `rowvars'
		local nrow : word count `rowvars'
		gettoken bs 0 : 0, parse("\") 
        	syntax varlist [if] [in] [aweight fweight] /*
		*/ [, Covariance Square Matrix(str) Header Format(str) * ]
	} 
	else { 
		local rowvars "`varlist'" 
		local nrow : word count `varlist' 
	} 	
	
	if "`square'" != "" & "`covariance'" != "" { 
		di in r "squaring covariance not allowed" 
		exit 198 
	}	
	
	local ncol : word count `varlist'
	tokenize `varlist' 

        marksample touse
	if `slash' { markout `touse' `rowvars' } 
	
	if "`matrix'" == "" { 
		tempname matrix 
		if "`header'" == "" { 
			local nohdr "noheader" 
		} 
	} 
	matrix `matrix' = J(`nrow',`ncol',0) 

	if "`square'" != "" { local square "^2" } 
	if "`format'" == "" { local format "%5.4f" } 

        local i = 1
        qui while `i' <= `nrow' {
                local row`i' : word `i' of `rowvars'
                local j = 1
                while `j' <= `ncol' {
                        corr `row`i'' ``j'' if `touse' [`weight' `exp'] /*
                         */ , `covariance'
			if "`covariance'" != "" {  
				mat `matrix'[`i',`j'] = (`r(cov_12)')
			} 
			else mat `matrix'[`i',`j'] = (`r(rho)')`square' 
                        local j = `j' + 1
                }
                local i = `i' + 1
        }
	
        qui count if `touse' 	
	di in g "(obs=`r(N)')"  
	
	mat rownames `matrix' = `rowvars'
	mat colnames `matrix' = `varlist'
	mat li `matrix', `options' `nohdr' format(`format') 
end

/*

The original syntax was

cpcorr rowvarlist \ colvarlist [if] [in] [weight] [, options]

After the first -gettoken-   `rowvars'  should be  rowvarlist
After the second -gettoken-  `bs'       should be  "\" 

The syntax is then 

colvarlist [if] [in] [weight] [, options]

Now (1.2.0) we allow also

cpcorr varlist [if] [in] [weight] [, options]

which yields square matrices. 

*/

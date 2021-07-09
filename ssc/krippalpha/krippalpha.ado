* ==========================================================
* krippalpha: compute Krippendorff's alpha intercoder reliability coefficient
* Version 1.3.1, 2015-01-14
* (Version 1.0.0 corresponds to 2013-10-18)
* ==========================================================
*! version 1.3.1, Alexander Staudt, Mona Krewel, 14jan2015

*mata mata clear
*program drop _all
program krippalpha, rclass 
	version 11.2
	syntax varlist [if] [in] [, Method(string) Format(string)]
	
	capture confirm existence `method'
	if _rc == 6 {
		local method = "nominal"
	}
	* save method in r(method)
	return local method = "`method'"

	ka `varlist' `if' `in', method(`method')
	
	* save results as scalars of rclass-type
	return scalar k_alpha = k_alpha
	return scalar rater = rater
	return scalar units = units
		
	* save results in r(table)
	matrix results = units\rater\k_alpha
	matrix colnames results = values
	matrix rownames results = units rater k_alpha
	return matrix table = results
		
	* drop scalars in memory
	scalar drop k_alpha units rater
	
	* display results
	display
	display as txt "{hline 80}"
	display as txt " Krippendorff's Alpha reliability coefficient"
	display 
	display as txt " Variable/Coders" as result " `varlist'" 
	display as txt " Method" _col(11) as result "`method'"	
	display as txt " Units " _col(11) as result return(units)
	display as txt " Raters" _col(11) as result return(rater)			
	display as txt " alpha " _col(11) as result `format' return(k_alpha)
	display as txt "{hline 80}"

end

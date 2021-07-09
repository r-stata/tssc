*! NJC 2.0.1 2 April 2004 
* NJC 2.0.0 21 January 2004 
* NJC 1.1.1 16 December 1998
* NJC 1.1.0 26 October 1996
* nonparametric density estimation for circular data: Fisher 1993 pp.24-27
program circkdensity 
	version 8.0
	syntax varname(numeric) [if] [in] ///
	[, H(real 30) GENPDF(str) GENDEG(str) PLOT(str asis) * ]

	marksample touse 
	qui count if `touse' 
	if r(N) == 0 error 2000

	if "`genpdf'" != "" confirm new variable `genpdf'
	if "`gendeg'" != "" confirm new variable `gendeg'
	
	tempvar deg d e f
	
	qui {
		if _N < 360 gen `deg' = _n / _N * 360
		else gen `deg' = _n in 1/360
		if `"`:variable label `varlist''"' != "" { 
			label var `deg' `"`:variable label `varlist''"' 
		}
		else label var `deg' "`varlist'" 

		local n = min(_N, 360) 
		gen `d' = .
		gen `e' = .
		gen `f' = .
  	        label var `f' ///
		"biweight density estimate, half-width `h'`=char(176)'"

		forval i = 1/`n' {  
			replace `d' = abs(`deg'[`i'] - `varlist') if `touse'
			replace `e' = min(`d' , 360 - `d')
			replace `e' = cond(`e' >= `h', 0, (1 - `e'^2 / `h'^2)^2)
			su `e', meanonly
			replace `f' = 0.9375 * r(sum) / (`n' * `h') in `i'
	    	}
	}
	
	twoway line `f' `deg', ///
	xla(0 "0" 90 "90" 180 "180" 270 "270" 360 "360") yla(, ang(h)) ///
	`options' /// 
	|| `plot' 
	
	qui if "`genpdf'" != "" { 
		gen `genpdf' = `f' in 1/`n' 
		label var `genpdf' ///
		"biweight density estimate, half-width `h'`=char(176)'"

	} 	
	qui if "`gendeg'" != "" { 
		gen `gendeg' = `deg' in 1/`n' 
		label var `gendeg' `"`:variable label `varlist''"' 
	} 	
end

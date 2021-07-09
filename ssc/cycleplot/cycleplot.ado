*! 1.2.0 NJC 5 April 2006 
* 1.1.0 NJC 29 August 2005 
* 1.0.0 NJC 31 January 2003 
* sssplot 1.2.0 NJC 24 March 1999
program cycleplot
	version 8.2 
	syntax varlist(min=3 numeric) [if] [in] ,    ///
	[ STart(int 1) LEngth(int 12) SUmmary(str) ///
	Connect(str) SQueeze(real 1) MYLAbels(str asis) * ]

	// fatal error checks 
	if "`summary'" != "" { 
		capture which _g`summary' 
		if _rc { 
			di as err "unknown egen function `summary'"
			exit _rc 
		}	
	}
	
	if `start' > `length' {
		di as err "start() should not be greater than length()"
		exit 198
	}

	if `"`mylabels'"' != "" { 
		local nlabels : word count `mylabels' 
		if `nlabels' != `length' { 
			di as err "`nlabels' supplied, but length `length'" 
			exit 198 
		}
	}	
	
	// any data to do this? 
	marksample touse, novarlist
	qui { 
		count if `touse' 
		if r(N) == 0 error 2000
			
		preserve 
		if r(N) < _N keep if `touse' 
	} 	

	// abbreviations 
	local nvars : word count `varlist' 
	local y : word `nvars' of `varlist' 
	local m : word `= `nvars' - 1' of `varlist' 
	
	tokenize `varlist'
	local nq = `nvars' - 2 
	
	forval i = 1/`nq' { 
		local Q `Q' ``i''
	}	
	
	local s = `start' 
	local l = `length' 

	tokenize `"`mylabels'"'  
	
	// start in middle?  
	qui if `s' != 1 {
	 	replace `m' = ///
	                cond(`m' >= `s', `m' - `s' + 1, `m' + `l' - `s' + 1) 
	}
	
	tempname xlbl 
	local j = `s'
	forval i = 1 / `l' { 
		if `"``j''"' != "" { 
			label def `xlbl' `i' `"``j''"', modify
		}
		else label def `xlbl' `i' "`j'", modify 
		
		local j = cond(`j' == `l', 1, `j' + 1)
	} 			    
	
	// rectangularise data set 
	fillin `m' `y'
	
	// summary function? 
	if "`summary'" != "" {
		foreach q of local Q { 
			tempvar sm
		 	egen `sm' = `summary'(`q'), by(`m')
			label var `sm' "`summary' `q'" 
			local SM `SM' `sm' 
		}	
	}

	// x axis variable 
	tempvar x 
	su `y', meanonly 
	gen `x' = `m' + `squeeze' * ((`y' - r(min)) / (r(max) - r(min)) - 0.5) 
	
	if "`xlbl'" != "" { 
		label val `x' `xlbl' 
		local vlbl "xlabel(, valuelabel)"
	} 	

	_crcslbl `x' `m'
	
	// sort order to leave gaps 
	gsort - `m' `y'

	// N.B. any user connect() ignored 
	twoway line `Q' `SM' `x', ///
	c(L ..) xla(1/`length', noticks) `vlbl' `options' 
end


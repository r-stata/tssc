*! 6.0.0 NJC 3 October 2012 
* 5.0.0 NJC 15 April 2010 
* 4.0.1 NJC 16 October 2006 
* 4.0.0 NJC 4 October 2006 
* 3.3.0 NJC 20 April 2006
* 3.2.1 NJC 23 November 2004
* 3.2.0 NJC 18 October 2004
* 3.1.0 NJC 27 September 2004  
* 3.0.0 NJC 1 July 2003  
* 2.2.0 NJC 31 March 1999
* 2.1.0 NJC 12 February 1999
* 2.0.2 NJC 8 January 1999
* 2.0.1 NJC 1 September 1998
* 2.0.0 NJC 26 April 1998
* 1.0.0 NJC 17 September 1997
* based on lshape v 2.0.1 PR 06Oct95.
program lmoments, rclass byable(recall)   
        version 10 
        syntax [varlist] [if] [in] /// 
        [, Format(str) lmax(numlist int >=4)  ALLobs variablenames short by(varlist) MISSing saving(str asis) * ]

	quietly {
		// screen out string variables 
		ds `varlist', has(type numeric) 
		local varlist "`r(varlist)'" 
	
		// what to use 
		if "`allobs'" != "" marksample touse, novarlist 
		else marksample touse 

		count if `touse' 
		if r(N) == 0 error 2000 
		local rN = r(N) 
		
		// variable(s) or group(s) 
		local nvars : word count `varlist'
		local ng : word count `varlist'

		if "`by'" != "" { 
			if `ng' > 1 { 
				di as err ///
				"by() cannot be combined with `ng' variables"
				exit 198 
			}
			
			tempvar group 
			egen `group' = group(`by') if `touse', label `missing'  
			su `group', meanonly  
			local ng = r(max) 
		} 	
		else { 
			local group "`touse'"
			tokenize `varlist' 
		}	

		// initialisation
		if `ng' > _N {
			preserve 
			set obs `ng'
			local preserved 1 
		}
		else local preserved 0 

		tempvar nnum nstr t myuse which  
		tempname V          

		capture label list which 
		if _rc == 0 tempname mylbl 
		else local mylbl "which" 

		gen long `which' = _n  
		compress `which' 
		gen long `nnum' = . 
		if "`lmax'" == "" local lmax = 4 

		forval l = 1/`lmax' { 
			tempvar l_`l' 
			gen double `l_`l'' = . 
                	label var `l_`l'' "l_`l'"
			local LTEMP `LTEMP' `l_`l'' 
		}

		gen double `t' = . 
                label var `t' "t"
	
 		forval l = 3/`lmax' { 
			tempvar t_`l' 
			gen double `t_`l'' = . 
                	label var `t_`l'' "t_`l'"
			local TTEMP `TTEMP' `t_`l'' 
		} 

		gen byte `myuse' = `touse' 

		// loop over variables(s) or groups(s) 
		forval i = 1/`ng' {
			// get results
			if "`by'" != "" { 
				replace `myuse' = `touse' & `group' == `i' 
				mata: _lmo("`varlist'", "`myuse'", "`nnum'", "`LTEMP'", `i',`lmax')  
			} 	
			else mata: _lmo("``i''", "`myuse'", "`nnum'", "`LTEMP'", `i', `lmax')
  			
			// group or variable labels 
			if "`by'" != "" { 
				local V = trim(`"`: label (`group') `i''"')
			}
			else { 
				local V = trim(`"`: variable label ``i'''"')  
				if `"`V'"' == "" | "`variablenames'" != "" { 
					local V "``i''" 
				} 	
			}	
			label def `mylbl' `i' `"`V'"', modify 
		} // end loop over variables or groups

                // L-moment ratios             
		replace `t'  = `l_2' / `l_1' in 1/`ng'
		forval l = 3/`lmax' { 
			replace `t_`l'' = `l_`l'' / `l_2' in 1/`ng'
		} 
	} // end quietly 	

	// -tabdisp- of results 
        label val `which' `mylbl'
	if "`by'" != "" label var `which' "Group" 
	else if "`allobs'" != "" label var `which' "Variable" 
        else label var `which' "n = `rN'"

        if "`format'" == "" local format "%9.3f"
	if "`allobs'`by'" != "" { 
		gen `nstr' = string(`nnum')  
		label var `nstr' "n" 
		local shown "`nstr'"
	} 

	if "`short'" == "" { 
	        tabdisp `which' in 1/`ng', ///
        	c(`shown' `l_1' `l_2' `l_3' `l_4') `options' f(`format') 
	        tabdisp `which' in 1/`ng', ///
        	c(`t' `t_3' `t_4') `options' f(`format') 
	} 
        else {
                tabdisp `which' in 1/`ng', ///
                c(`shown' `l_1' `l_2' `t_3' `t_4') `options' f(`format') 
        }
        
	// returned values 
        ret scalar N = `nnum'[`ng'] 

	forval l = 1/`lmax' { 
	        ret scalar l_`l' = `l_`l''[`ng'] 
	} 

        ret scalar t = `t'[`ng'] 

	forval l = 3/`lmax' { 
	        ret scalar t_`l' = `t_`l''[`ng'] 
	}

	// saving dataset? 
	qui if `"`saving'"' != "" { 
		if !`preserved' preserve 
		keep in 1/`ng' 
		keep `which' `nnum' `LTEMP' `t' `TTEMP' 
		rename `which' which 
		rename `nnum' n
		 
		foreach v in `LTEMP' `t' `TTEMP' { 
			rename `v' `: var label `v'' 
		} 
	
		save `saving'             
	} 	 
end

mata : 

real matrix bweights (real scalar n, real scalar k) { 
	return(editmissing(comb((0::n-1), (0..k-1)) :/ comb(n-1, (0..k-1)), 0))  
} 	

real matrix pweights(real scalar k) { 
	real matrix w
	real scalar i, j  
	w = J(k, k, .) 

	for(i = 0; i < k; i++) { 
		for(j = 0; j < k; j++) {
			w[i+1,j+1] = (-1)^(j-i) * exp(lnfactorial(j+i) - 2 * lnfactorial(i) - lnfactorial(j-i)) 
		}
	}

	return(editmissing(w, 0))
} 

real matrix lmocoeff(real scalar n, real scalar k) { 
	return(bweights(n, k) * pweights(k)) 
}

void _lmo(string scalar varname, string scalar usename, string scalar nname, string scalar lnames, real scalar i, real scalar lmax) 
{ 
	real colvector x, result    
	real scalar n  

	x = st_data(., varname, usename) 
	x = select(x, x :< .) 
	n = length(x) 
	st_store(i, nname, n) 
	if (n == 0) return 

	_sort(x, 1)
	result = lmocoeff(n, lmax)' * x / n
	if (n < lmax) result[(n + 1)::lmax] = J(lmax - n, 1, .) 
	st_store(i, tokens(lnames), result') 
}

end


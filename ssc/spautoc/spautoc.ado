*! 2.0.0 NJC 23 February 2005 
* 1.2.0 NJC 14 April 1999 
* 1.1.0 NJC 30 Oct 1998
* 1.0.0 NJC 3 Apr 1997
program spautoc, rclass sort 
	version 8   
	syntax varlist(min=2 max=2) [if] [in] /// 
	[ , LMEAn(str) LMEDian(str) Weight(str) ]

	local w "`weight'"
	local weight 

	marksample touse, strok 
	qui count if `touse' 
	if r(N) == 0 error 2000 

	tokenize `varlist' 
	args x nei 
	confirm str var `nei'

	if "`lmean'`lmedian'" != "" { 
		confirm new variable `lmean' `lmedian' 
	}

	if "`w'" != "" {
		confirm str var `w'
		tempvar W
		qui gen `W' = .
		local uneqwt = 1
		local ww "[w = `W']"
	}
	else local uneqwt = 0

	tempvar xdev xsq xlocal xmean xmed wrow wcol s2
	tempname sumsq sum4p iprod cprod S0 S1 S2 b2
	tempname I EI varNI varRI sNI sRI c varNc varRc sNc sRc

	qui {
		su `x' if `touse', meanonly
		local n = r(N)
		gen double `xdev' = `x' - r(mean) if `touse'
		gen double `xsq' = `xdev'^2
		su `xsq', meanonly
		scalar `sumsq' = r(sum)
		replace `xsq' = `xdev'^4
		su `xsq', meanonly
		scalar `sum4p' = r(sum)
		drop `xsq' 

		gen `xlocal' = .
		gen `xmean' = .
		gen `xmed' = .
		gen `wrow' = 0 if `touse'
		gen `wcol' = 0 if `touse'
		scalar `iprod' = 0
		scalar `cprod' = 0
		scalar `S0' = 0
		scalar `S1' = 0

		replace `touse' = -`touse' 
		sort `touse' 
		
		// loop over observations
		forval i = 1/`n' { 
			local nabors = `nei'[`i']
			tokenize "`nabors'"
			local ni : word count `nabors'
			forval j = 1/`ni' {
				local j`j' = ``j''
			}
			
			if `uneqwt' {
				local wi = `w'[`i']
				tokenize "`wi'"
        		        local nw : word count `wi'
				if `nw' != `ni' {
					di as err ///
            	       "number of weights != number of neighbours in `i'"
			                exit 498
                    		}
			} 	

			// for each neighbour
			forval j = 1/`ni' {
				if `uneqwt' { 	
				        local wij : word `j' of `wi'
					replace `W' = `wij' in `j'
		        	}
                		else local wij 1
				
				scalar `iprod' = `iprod' + ///
        	         	`wij' * `xdev'[`i'] * `xdev'[`j`j'']
				scalar `cprod' = `cprod' + ///
                 		`wij' * (`xdev'[`i'] - `xdev'[`j`j''])^2
		                scalar `S0' = `S0' + `wij'
	                	replace `xlocal' = `x'[`j`j''] in `j'
				replace `wrow' = `wrow' + `wij' in `i'
				replace `wcol' = `wcol' + `wij' in `j`j''

				// look up w[j,i] which may differ from w[i,j] 
		    	    	local naborsj = `nei'[`j`j''] 
				
				local pos : list posof "`i'" in naborsj 
			    	if `pos' == 0 { 
					di as r ///
				"`i' neighbours `j`j'', but not vice versa"
					exit 498 
			    	}	
				
				if `uneqwt' { 
					local wj = `w'[`j`j''] 
					local wji : word `pos' of `wj' 
				}
				else local wji = 1 
    	    
				scalar `S1' = `S1' + (`wij' + `wji' )^2
			} // next neighbour 
    	
			if `ni' > 0 {
				su `xlocal' in 1/`ni' `ww', d
				replace `xmed' = r(p50) in `i'
			        replace `xmean' = r(mean) in `i'
			}
		} // next observation 

		scalar `S1' = `S1' / 2
		scalar `I' = (`iprod' * `n') / (`S0' * `sumsq')
		scalar `EI' = -1 / (`n' - 1)
		gen `s2' = (`wrow' + `wcol')^2
		su `s2', meanonly
		scalar `S2' = r(sum)
		scalar `b2' = (`n' * `sum4p') / `sumsq'^2
		scalar `varNI' = (`n'^2 * `S1' - `n' * `S2' + 3 * `S0'^2)
		scalar `varNI' = `varNI' / (`S0'^2 * (`n'^2 - 1)) - `EI'^2
		scalar `varRI' = (`n'^2 - 3 * `n' + 3) * `S1' - `n' * `S2' + ///
		3 * `S0'^2
		scalar `varRI' = `n' * `varRI'
		scalar `varRI' = `varRI' - `b2' *  ///
		((`n'^2 - `n') * `S1' - 2 * `n' * `S2' + 6 * `S0'^2)
		scalar `varRI' = `varRI' / ///
     		((`n' - 1) * (`n' - 2) * (`n' - 3) * `S0'^2) - `EI'^2
		scalar `sNI' = (`I' - `EI') / sqrt(`varNI')
		scalar `sRI' = (`I' - `EI') / sqrt(`varRI')

		scalar `c' = (`cprod' * (`n' - 1)) / (2 * `S0' * `sumsq')
		local Ec = 1
		scalar `varNc' = ((2 * `S1' + `S2') * (`n' - 1) - 4 * `S0'^2) / ///
     		(2 * (`n' + 1) * `S0'^2)
		scalar `varRc' = (`n' - 1) * `S1' * ///
     		(`n'^2 - 3 * `n' + 3 - (`n' - 1) * `b2')
		scalar `varRc' = `varRc' - ( 1 / 4 * (`n' - 1) * `S2' * ///
		(`n'^2 + 3 * `n' - 6 - (`n'^2 - `n' + 2) * `b2'))
		scalar `varRc' = `varRc' + `S0'^2 * (`n'^2 - 3 - (`n' - 1)^2 * `b2')
		scalar `varRc' = `varRc' / (`n' * (`n' - 2) * (`n' - 3) * `S0'^2)
		scalar `sNc' = (`c' - `Ec') / sqrt(`varNc')
		scalar `sRc' = (`c' - `Ec') / sqrt(`varRc')
	}

	di _n as txt _dup(28) " "  "           expected  standard"
	di    as txt _dup(28) " "  "statistic    value    deviate  P-value"
	di _n as txt "Moran coefficient I      "  /*
	*/ as res %10.3f  `I' %11.3f `EI'
	di as txt "           normality" _dup(26) " " /*
	*/ as res %9.3f `sNI' %10.3f  2 * (1 - normprob(abs(`sNI')))
	di as txt "           randomisation" _dup(22) " " /*
	*/ as res %9.3f `sRI' %10.3f 2 * (1 - normprob(abs(`sRI')))
	di _n as txt "Geary coefficient c      " /*
	*/ as res %10.3f `c' %11.3f `Ec'
	di as txt "           normality" _dup(26) " " /*
	*/ as res %9.3f `sNc' %10.3f 2 * (1 - normprob(abs(`sNc')))
	di as txt "           randomisation" _dup(22) " " /*
	*/ as res %9.3f `sRc' %10.3f 2 * (1 - normprob(abs(`sRc')))

	qui if "`lmean'" != "" { 
		gen `lmean' = `xmean' if `touse' 
	}
	qui if "`lmedian'" != "" { 
		gen `lmedian' = `xmed' if `touse' 
	}

	return scalar sRc = `sRc'
	return scalar sNc = `sNc'
	return scalar Ec = `Ec'
	return scalar c = `c'
	return scalar sRI = `sRI'
	return scalar sNI = `sNI'
	return scalar EI = `EI'
	return scalar I = `I'
end

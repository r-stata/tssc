*! 1.3.0 NJC 30 April 2013 
* 1.2.0 NJC 15 April 2013 
* 1.1.0 NJC 9 April 2013 
* 1.0.0 NJC 31 January 2013 
program trimplot, sort 
	version 8.2 
    	syntax varlist [if] [in] [ , allobs over(varname) ///
	YTItle(str asis) by(str asis) metric percent mad addplot(str asis) * ]

	local vlist "`varlist'" 	
 	local nvars : word count `varlist'

	if `"`by'"' != "" { 
		if "`over'" != "" { 
			di as err "by() and over() may not be combined" 
			exit 198
		}

		gettoken byvar rest : by, parse(",") 
		gettoken comma rest : rest, parse(",") 
		local over "`byvar'" 
		local byby by(`byvar', `rest' legend(off))    
	} 

	if "`over'" != "" {
        	if `nvars' > 1 {
                	di as err "too many variables specified"
                	exit 103
        	}
        }

	if "`allobs'" != "" & `nvars' > 1 { 
		marksample touse, novarlist 
	}
	else marksample touse 

       	if "`over'" != "" { 
		markout `touse' `over', strok 
        }
    
   	qui count if `touse'
	if r(N) == 0 error 2000

        qui if `nvars' > 1 {
        	preserve
		tokenize `varlist' 
		tempvar id 
		gen long `id' = _n 
        	tempname data lbl 
		forval i = 1 / `nvars' {
			local which : variable label ``i''
			if `"`which'"' == "" { 
				local which "``i''" 
			} 	
			label def `lbl' `i' `"`which'"', modify
			rename ``i'' `data'`i' 
        	}
        	reshape long `data', i(`id') 
		drop if missing(`data') 
	        local y `data'
        	label val _j `lbl'
	        local over "_j"
        }
	else local y `varlist' 
	
        tempvar trmean depth   
	quietly {

		if "`metric'" != "" { 
			tempvar median 
			bysort `touse' `over' (`y'): ///
			gen `median' = cond(mod(_N, 2), `y'[(_N + 1)/2], (`y'[_N/2] + `y'[(_N/2) + 1])/2)  if `touse'  
			gen `depth' = abs(`y' - `median') 

			if "`mad'" != "" { 
				tempvar MAD 
				bysort `touse' `over' (`depth'): gen `MAD' = ///
				cond(mod(_N, 2), `depth'[(_N + 1)/2], (`depth'[_N/2] + `depth'[(_N/2) + 1])/2)  if `touse'  
				replace `depth' = `depth'/`MAD' 
			}
		}
		else {
			bysort `touse' `over' (`y'): ///
			gen `depth' = -min(_n, _N - _n  + 1)  if `touse'  
		}

                bysort `touse' `over' (`depth') : gen double `trmean' = ///
			sum(`y') if `touse'  
		by `touse' `over' (`depth') : replace `trmean' = `trmean'/_n  
		by `touse' `over' `depth' : replace `trmean' = `trmean'[_N] 	
		label var `trmean' "trimmed mean"

		if "`metric'" != "" { 
			if "`mad'" != "" { 
				label var `depth' "absolute deviation from median / MAD" 
			}
			else label var `depth' "absolute deviation from median" 
		}
		else { 
			replace `depth' = -`depth'
			if "`percent'" != "" { 
				by `touse' `over': replace `depth' = 100 * (`depth' - 1)/_N
				label var `depth' "percent trimmed" 
			}
			else label var `depth' "depth"
		}
	}

	qui if "`over'" != "" {
		separate `trmean', by(`over') veryshortlabel 
		local trmean "`r(varlist)'" 
	} 	
 	

	if "`ytitle'" == "" { 
		if `nvars' == 1 { 
			local w : variable label `varlist'
			if "`w'" == "" | length(`"`w'"') > 30  local w "`varlist'" 
		        local ytitle "trimmed mean of `w'" 
		} 
		else local ytitle "trimmed mean" 
	}
	
	if "`msymbol'" == "" { 
		local msymbol "oh dh th sh smplus x O D T S + X"
	}
	
	twoway scatter `trmean' `depth' if `touse',        ///
	yla(, ang(h)) yti(`ytitle') msymbol(`msymbol') ///
	`byby' `options' ///
        || `addplot' 
end
 

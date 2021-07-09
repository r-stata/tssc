*! 3.0.1 NJC 6 February 2003 
*! 3.0.0 NJC 3 February 2003 
* 2.0.0 NJC 25 August 1999 
* 1.0.2 NJC 16 March 1998 
* 1.0.1 NJC 3 April 1996
* 1.0.0 NJC 19 August 1994
program define skewplot
	version 8
    	syntax varlist [if] [in] /// 
        [ , SKEW BY(varname) MISSing YTITle(str asis) L2title(str asis) ///
	MSymbol(str) * ]
	
	marksample touse, novarlist 
	if "`missing'" == "" {
        	if "`by'" != "" { 
			markout `touse' `by', strok 
		}
        }
        else {
        	if "`by'" == "" { 
			di as txt "missing only applies with by()" 
		}
    	}
    
   	qui count if `touse'
	if r(N) == 0 {
        	error 2000
        }
	
 	local nvars : word count `varlist'

	if "`by'" != "" {
        	if "`in'" != "" {
	        	di as err "in may not be combined with by()"
           	        exit 190
	        }
        	if `nvars' > 1 {
                	di as err "too many variables specified"
                	exit 103
        	}
        }

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
	        local varlist "`data'"
        	label val _j `lbl'
	        local by "_j"
        }
	
	markout `touse' `varlist' 

        tempvar mid spread median  
	quietly {
		bysort `touse' `by' (`varlist'): ///
			gen `spread' = `varlist'[_N  + 1 - _n] - `varlist' ///
			if `touse'  
                by `touse' `by' : gen `mid' = ///
			0.5 * (`varlist'[_N + 1 - _n] + `varlist') if `touse'  
		
		if "`skew'" != "" { 
			#delimit ; 
			by `touse' `by' : gen `median' =  
		        cond(mod(_N, 2) == 0, 
			(`varlist'[_N / 2] + `varlist'[(_N / 2) + 1]) / 2,
			`varlist'[(_N + 1) / 2]) ;
			#delimit cr 
			replace `mid' = `mid' - `median' 
			replace `spread' = `spread' / 2 
			label var `mid' "Skewness" 
		}	
		else label var `mid' "Midsummary"
		
		label var `spread' "Spread"
	}

	qui if "`by'" != "" {
        	tempvar group
                by `touse' `by' : gen byte `group' = _n == 1 if `touse'
                replace `group' = sum(`group')
                local max = `group'[_N]
                local bylab : value label `by'
                count if !`touse'
                local j = 1 + r(N)
               	forval i = 1 / `max' {
	                tempvar mid`i'
               		gen `mid`i'' = `mid' if `group' == `i'
	                local byval = `by'[`j']
               		if `"`bylab'"' != "" { 
				local byval : label `bylab' `byval' 
			}
	                label var `mid`i'' `"`byval'"'
	                local midlist "`midlist' `mid`i''"
	                count if `group' == `i'
               		local j = `j' + r(N)
	        }
		local mid "`midlist'" 
	} 	
 	
	if `"`l2title'"' == "" & `nvars' == 1 {
		local w : variable label `varlist'
		if "`w'" == "" { 
			local w "`varlist'" 
		}
		local l2title "`w'" 
	}
	if `"`l2title'"' != "" { 
		local l2 "l2title(`"`l2title'"')" 
	}	
	if "`ytitle'" == "" { 
		local ytitle = cond("`skew'" != "", "Skew", "Midsummary") 
	}	
	if "`msymbol'" == "" { 
		local msymbol "oh dh th sh smplus x O D T S + X"
	}
	
	twoway scatter `mid' `spread' if `touse' & `spread' >= 0, ///
	ytitle(`"`ytitle'"') msymbol(`msymbol') `l2' `options' 
end
 

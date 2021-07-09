*! 2.0.2 NJC 6 May 2004
* 2.0.1 NJC 30 March 2004
* 2.0.0 NJC 15 January 2004
* NJC 1.0.0 7 August 2001 
program circrao, sort  
        version 8.0
        syntax varlist(numeric) [if] [in] [ , BY(varname)]

	marksample use, novarlist 
	qui count if `use' 
	if r(N) == 0 error 2000 

	tokenize `varlist'
	local nvars : word count `varlist'
	
        if `nvars' > 1 & "`by'" != "" {
                di as err "too many variables specified"
                exit 103
        }
	
	if "`by'" != "" local which "        Group "
	else            local which "     Variable "
	// cond() strips leading spaces 

        di _n as txt "`which'{c |}   Obs"  ///
	    _col(31) "U"                   ///
            _col(38) "%"          ///
	    _col(44) "P-value" 
	    
        di as txt " {hline 13}{c +}{hline 35}"

        qui foreach v of local varlist {
	        tempvar touse group
                mark `touse' `if' `in'
                markout `touse' `v'

		count if `touse' 
		if r(N) > 0 { 
			bysort `touse' `by' : gen `group' = _n == 1 if `touse'
			replace `group' = sum(`group')
			local max = `group'[_N]
			
			forval j = 1/`max' {
				Rao `v' if `group' == `j' 
				
				if "`by'" != "" {
					local name = `by'[_N]
					local bylab : value label `by'
					if "`bylab'" != "" {
						local name : label `bylab' `name'
					}
				}
				else local name "`v'"
				
				if length("`name'") > 12 {
					if "`by'" == "" local name = abbrev("`name'",12) 
					else local name = substr("`name'",1,12) + "+"
				}
				local skip = 13 - length("`name'")
	 
				noi di _skip(`skip') as txt "`name' {c |}" as res ///
				%6.0f  `r(N)'                                     ///
				%10.1f  `r(U)'                                     ///
				%7.1f  `r(U_pc)'                                  ///
				%12.3f  `r(P_Rao)'
			}
			drop `group' 
		} 	

                drop `touse'  
        }
end

program Rao, rclass 
	version 8 
	syntax varname(numeric) [if] [in]   

	qui { 
		marksample touse 
		tempvar spacing 
		tempname U  
		sort `touse' `varlist' 
		count if `touse' 
		local n = r(N) 
		local first = _N - `n' + 1 
		gen `spacing' = `varlist'[_n + 1] - `varlist' 
		replace `spacing' = 360 - `varlist' + `varlist'[`first'] in l
		replace `spacing' = `spacing' - 360 / `n' 
		su `spacing' if `spacing' > 0 & `touse', meanonly 
		scalar `U' = r(sum) 
	} 

	return scalar N = `n'  
	return scalar U = `U' 
	return scalar Upc = 100 * `U' / 360 
	
	tempname mean sd P 
	scalar `mean' = 360 / exp(1) 
	scalar `sd' = 360 * sqrt(2 * exp(-1) - 5 * exp(-2)) / sqrt(`n')
	if `U' > `mean' scalar `P' = norm(-(`U' - `mean') / `sd')   
	else scalar `P' = 1 - norm((`U' - `mean') / `sd') 
	return scalar PRao = `P' 
end 	
	

*! version 1.0.0 Ariel Linden 25aug2014
program define alignedsets, rclass byable(recall)

	version 13.0
	syntax varlist(numeric min=1 max=1) [if] [in], BY(varname) SET(varname) 


	tempname  g1 g2 n1 n2 w1 varT sum_Ews wsT diff se z p 
	tempvar cnt mean_y diff_y rank ws ki mi ni e_ws k Ni fact ss_k var_ws
	
quietly {
    
	* Data verification *
	marksample touse 
	count if `touse' 
    if r(N) == 0 error 2000
    local N = r(N) 
    replace `touse' = -`touse'
	

	local origby "`by'"
	capture confirm numeric variable `by'
	if _rc {
	di as err "`by' must be numeric"
	exit 108 
	}
   
	if ("`set'" != "") {
    local origset "`set'"
    capture confirm numeric variable `set'
    if _rc {
		tempvar numset
        encode `set', generate(`numset')
        local set "`numset'"
		}
	}
    	
	tabulate `by' if `touse' 
	if r(r) != 2 { 
	di as err "`by' must have exactly two values (coded 0 or 1)."
	exit 420  
    } 
	else if r(r) == 2 { 
	capture assert inlist(`by', 0, 1) if `touse' 
	if _rc { 
	di as err "`by' must be coded as either 0 or 1."
	exit 450 
		}
	}
	
	summarize `by' if `touse', meanonly
	scalar `g1' = r(min)    
    scalar `g2' = r(max)  

 
  	local y "`varlist'" 

	by `set' `by', sort: gen `cnt' =  _n	if `touse'					//counter within set by group
	
	* get alignment within set
	bys `set': egen `mean_y' = mean(`y') if `touse'
	gen `diff_y' = `y'- `mean_y' if `touse'
	egen `rank' = rank(`diff_y') if `touse'
	

	* gets ranking
	bys `set' (`by'): egen `ws' = total(`rank') if `by'==1	& `touse'	//ranks for the treated group (so that we can do a sum of ranks later)
	replace `ws' =. if `by'==1 & `cnt' >1 & `touse'
	bys `set' (`by'): egen  `ki' = mean(`rank') if `touse'
	bys `set' (`by'): egen `mi' = count(`by') if `by'==0 & `touse'
	bys `set' (`by'): egen `ni' = count(`by') if `by'==1 & `touse'
	gen `e_ws'=`ni'*`ki' if `by'==1 & `touse'								//expected values (not summed)
	replace `e_ws' =. if `by'==1 & `cnt' >1 & `touse'
	* for variance
	gen `k'=(`rank'-`ki')^2 if `touse'
	bys `set' (`by'): egen `ss_k' = total(`k') if `touse'

	* to get factor for variance
	bys `set' (`by'): gen `Ni' = _N if `touse'
	gen `fact' = (`ni'*`mi'[_n-1])/(`Ni'*(`Ni'-1)) if `by' ==1 & `touse'
	gen `var_ws' = `fact'*`ss_k' if `touse'
	sum `var_ws' if `touse', meanonly 
	scalar `varT' = r(sum) 					//variance of model
	sum `e_ws' if `touse', meanonly 
	scalar `sum_Ews' = r(sum) 				//predicted sum of ranks (tx)
	sum `ws' if `touse', meanonly
	scalar `wsT' = r(sum) 					//actual sum of ranks (tx)
	scalar `diff' = `wsT' - `sum_Ews'		//actual - predicted (tx)
	scalar `se' = sqrt(`varT')				//se of model
	scalar `z' = `diff' / `se'				//z stat
	scalar `p' = 2*normprob(-abs(`z'))		//p val

	summarize `rank' if `by'==`g1' & `touse', meanonly
    local   n1   = r(N)
    scalar `w1'  = r(sum)
    summarize `rank' if `touse'
    local   n    = r(N)
	local   n2   = `n' - `n1'
	
}	
	local holdg1 = `g1' 
	local g1 = `g1'
	local g2 = `g2'

	local valulab : value label `by'
	if `"`valulab'"'!=`""' {
	local g1 : label `valulab' `g1'
	local g2 : label `valulab' `g2'
	}

	local by "`origby'"
	di in gr _n `"Aligned ranks test (Hodges-Lehmann) for matched sets"' _n
	di in smcl in gr %12s abbrev(`"`by'"',12) /*
			*/ " {c |}      obs    rank sum    expected"
	di in smcl in gr "{hline 13}{c +}{hline 33}"
	ditablin `"`g1'"' `n1' `w1' (`n'*(`n'+1)/2)-`sum_Ews'
	ditablin `"`g2'"' `n2' `wsT' `sum_Ews'
	di in smcl in gr "{hline 13}{c +}{hline 33}"
	ditablin combined `n' (`wsT'+`w1') `n'*(`n'+1)/2

    if `varT' < 1e7 local vfmt `"%10.3f"' 
    else  local vfmt `"%10.0g"'

		
	local xab = abbrev("`y'",8)
	local byab = abbrev("`by'",8)
	di in smcl in gr " " _n(2) 					///
		in gr _col(7) `"variance = "'			///
        in ye `vfmt' `varT' _n					///
		in gr _col(14) `"z = "'					///
        in ye %10.3f `z' _n						///
        in gr _col(5) `"Prob > |z| = "'			///
        in ye %10.3f 2*normprob(-abs(`z')) 
	
	return scalar actual = `wsT' 
	return scalar expect = `sum_Ews'
	return scalar diff = `diff'
	return scalar var = `varT'
	return scalar se = `se'
	return scalar z = `z'
	return scalar p = `p'
	

end

program define ditablin
        if length(`"`1'"') > 12 {
                local 1 = substr(`"`1'"',1,12)
        }
      
    di in smcl in gr %12s `"`1'"' " {c |}" in ye ///
        _col(17) %7.0f `2' 			             ///
        _col(26) %10.0f `3'                      ///
        _col(38) %10.0f `4' 
end 

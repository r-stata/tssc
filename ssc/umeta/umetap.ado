
*! predict program to accompany -umeta- 

capture program drop umetap
program define umetap


	if "`e(cmd)'" != "umeta" { 
		di in red  "umeta or umetab was not the last estimation command"
		exit 301
	}

	syntax anything(name=pref id="variable name prefix") [if] [in] /*
		*/  [, COOKsd FIXed STFixed REFFects RESes RSTandard FITted STFITted LEV  SHOW(string) *]

	local nopt = ("`fixed'" != "")  + ("`stfixed'" != "") ///
	+ ("`reffects'" !="") + ("`reses'" !="") + ("`rstandard'" !="") +  ("`fitted'" != "") + ("`stfitted'" != "") + ("`lev'" != "") + ("`cooksd'" != "") 
	if `nopt' > 1 { 
		disp in re "only one of the following options allowed: fixed, stfixed, reffects, reses, rstandard, fitted, stfitted, lev, cooksd"
	} 
	local var
	if `nopt' == 0 { 
	local xb "xb"
	}
	marksample touse, novarlist	/* novarlist because new vars generated */
	qui count if `touse'
	local N=r(N)
	if r(N) < 1 {
		di in red "no observations"
		exit 2000
	}
	


	
		tempvar id
		gen `id'=_n
		foreach mat in b yvars svars Sigma {
		tempname `mat'
		mat ``mat'' = e(`mat')
		} 
	
		
		if !missing("`fixed'")  {
		if missing("`show'") {
		di in gr "(fixed will be stored in variables `pref'i, i = 1,...,#eqs)"
		}
		forval i = 1/`e(dims)' {
		confirm new var `pref'`i'
		if _rc==110 {
		drop `pref'`i'
		}
		_predict `pref'`i' if `touse', xb equation(#`i')
		}
		if !missing("`show'") {
		di in gr "(Outcomes-specific fixed-effects only prediction)"
		list `pref'*, `show'
		}
		}

		if !missing("`stfixed'")    {
		if missing("`show'") {
		di in gr "(stfixed will be stored in variables `pref'i, i = 1,...,#eqs)"
		}
		forval i = 1/`e(dims)' {
		confirm new var `pref'`i'
		if _rc==110 {
		drop `pref'`i'
		}
		_predict `pref'`i' if `touse', stdp equation(#`i')
		}
		if !missing("`show'") {
		di in gr "(Outcomes-specific standard error of the fixed-effects only prediction)"
		list `pref'*, `show'
		}
		}


		if "`reffects'" != ""  {
		if missing("`show'") {
		di in gr "(reffects will be stored in variables `pref'i, i = 1,...,#eqs)"
		}
		forval i = 1/`e(dims)' {
		confirm new var `pref'`i'
		if _rc==110 {
		drop `pref'`i'
		}
		tempvar uuxb`i' depvar`i' wsvar`i' B`i' 
		local tau`i'= `Sigma'[`i', `i']
		gen `depvar`i''= `yvars'[`id', `i'] if `touse' 
		gen `wsvar`i''= `svars'[`id', `i'] if `touse' 
		gen `B`i''= (`tau`i''/ (`tau`i'' + `svars'[`id', `i'])) if `touse' 
	    _predict `uuxb`i'' if `touse', xb equation(#`i')
		gen `pref'`i' = (`B`i'' * (`depvar`i'' - `uuxb`i'')) if `touse'
		}
		if !missing("`show'") {
		di in gr "(Outcomes-specific predicted random effects)"
		list `pref'*, `show'
		}
		}
		
		if "`reses'" != "" {
		if missing("`show'") {
		di in gr "(reses will be stored in variables `pref'i, i = 1,...,#eqs)"
		}
		forval i = 1/`e(dims)' {
		confirm new var `pref'`i'
		if _rc==110 {
		drop `pref'`i'
		}
		local tau`i'= `Sigma'[`i', `i']
		tempvar  ustdp`i'  wsvar`i' 
		gen `wsvar`i''= `svars'[`id', `i'] if `touse' 
		_predict `ustdp`i'' if `touse', stdp equation(#`i')
		gen `pref'`i' =  sqrt(`wsvar`i'' + `tau`i'' - (`ustdp`i''*`ustdp`i'')) if `touse'
		}
		if !missing("`show'") {
		di in gr "(Outcomes-specific standard error of predicted random effects)"
		list `pref'*, `show'
		}
		}
		

		if "`fitted'" != "" {
		if missing("`show'") {
		di in gr "(fitted will be stored in variables `pref'i, i = 1,...,#eqs)"
		}
		forval i = 1/`e(dims)' {
		confirm new var `pref'`i'
		if _rc==110 {
		drop `pref'`i'
		}
		local tau`i'= `Sigma'[`i', `i']
		tempvar uxb`i' depvar`i' wsvar`i' B`i' 
		gen `depvar`i''= `yvars'[`id', `i'] if `touse' 
		gen `wsvar`i''= `svars'[`id', `i'] if `touse' 
		gen `B`i''= (`tau`i''/ (`tau`i'' + `svars'[`id', `i'])) if `touse' 
		_predict `uxb`i'' if `touse', xb equation(#`i')
		gen `pref'`i' = (`B`i'' * `depvar`i'' + (1-`B`i'') * `uxb`i'') if `touse'
		}
		if !missing("`show'") {
		di in gr "(Outcomes-specific prediction incl. random effects)"
		list `pref'*, `show'
		}
		}

		if "`stfitted'" != "" {
		if missing("`show'") {
		di in gr "(stfitted will be stored in variables `pref'i, i = 1,...,#eqs)"
		}
		forval i = 1/`e(dims)' {
		confirm new var `pref'`i'
		if _rc==110 {
		drop `pref'`i'
		}
		tempvar stdxbustdp`i' depvar`i' wsvar`i' B`i' 
		local tau`i'= `Sigma'[`i', `i']
		gen `depvar`i''= `yvars'[`id', `i'] if `touse' 
		gen `wsvar`i''= `svars'[`id', `i'] if `touse' 
		gen `B`i''= (`tau`i''/ (`tau`i'' + `svars'[`id', `i'])) if `touse' 
	   _predict `stdxbustdp`i'' if `touse', stdp equation(#`i')
		gen `pref'`i' =  sqrt(`B`i'' * `wsvar`i''  + (1-`B`i'')*(1-`B`i'') * (`stdxbustdp`i''* `stdxbustdp`i'') ) if `touse'
		}
		if !missing("`show'") {
		di in gr "(Outcomes-specific S.E. of prediction incl. random effects)"
		list `pref'*, `show'
		}
		}


		if "`rstandard'" != "" {
		if missing("`show'") {
		di in gr "(rstandard will be stored in variables `pref'i, i = 1,...,#eqs)"
		}
		forval i = 1/`e(dims)' {
		confirm new var `pref'`i'
		if _rc==110 {
		drop `pref'`i'
		}
		local tau`i'= `Sigma'[`i', `i']
		tempvar uxb`i' ustdp`i' depvar`i' wsvar`i' B`i' 
		gen `depvar`i''= `yvars'[`id', `i'] if `touse' 
		gen `wsvar`i''= `svars'[`id', `i'] if `touse' 
		gen `B`i''= (`tau`i''/ (`tau`i'' + `svars'[`id', `i'])) if `touse' 
		_predict `uxb`i'' if `touse', xb equation(#`i')
		_predict `ustdp`i'' if `touse', stdp equation(#`i')
		gen `pref'`i' =  (`depvar`i'' - `uxb`i'') /  sqrt(`wsvar`i'' + `tau`i'' - (`ustdp`i''*`ustdp`i'')) if `touse'
		}
		if !missing("`show'") {
		di in gr "(Outcomes-specific standardized predicted random effects)"
		list `pref'*, `show'
		}
		}

		if "`lev'" != ""  {
		if missing("`show'") {
		di in gr "(leverages will be stored in variables `pref')"
		}
		forval i = 1/`e(dims)' {
		confirm new var `pref'`i'
		if _rc==110 {
		drop `pref'`i'
		}
		tempvar   hatstdp`i' depvar`i' wsvar`i' B`i' 
		local tau`i'= `Sigma'[`i', `i']
		gen `depvar`i''= `yvars'[`id', `i'] if `touse' 
		gen `wsvar`i''= `svars'[`id', `i'] if `touse' 
		gen `B`i''= (`tau`i''/ (`tau`i'' + `svars'[`id', `i'])) if `touse'  
	    _predict `hatstdp`i'' if `touse', stdp equation(#`i')
		gen `pref'`i' = (`hatstdp`i''* `hatstdp`i'')/ (`wsvar`i'' + `tau`i'' ) if `touse'
		}
		mkmat `pref'*, mat(B)
		qui drop `pref'*
		qui gen double `pref'=.
		qui count if `touse'
		local N=r(N)
		forvalues i = 1/`N' {
		mat lev=B[`i',`e(dims)']
		local lev=trace(lev)
		qui replace `pref'= `lev' in `i' if `touse'
		}
		if !missing("`show'") {
		di in gr "(leverages)"
		list `pref', `show'
		}
		}
		
		
		if "`cooksd'" != "" {
		if missing("`show'") {
		di in gr "(cooksd will be stored in variable `pref')"
		}
		forval i = 1/`e(dims)' {
		local tau`i'= `Sigma'[`i', `i']
		tempvar uxb`i' depvar`i' wsvar`i' B`i' 
		gen `depvar`i''= `yvars'[`id', `i'] if `touse' 
		gen `wsvar`i''= `svars'[`id', `i'] if `touse' 
		gen `B`i''= (`tau`i''/ (`tau`i'' + `svars'[`id', `i'])) if `touse' 
		_predict `uxb`i'' if `touse', xb equation(#`i')
		gen lres`i' =`depvar`i'' - (`B`i'' * `depvar`i'' + (1-`B`i'') * `uxb`i'') if `touse'
		}
		
			tempname H  scorei ci
			local N=e(N)
            matrix `H' = e(V)
        
            qui gen cooksd= .
            local i = 1
            while `i'<=`N'{
             mkmat lres* if `id'==`i' , matrix(`scorei')
             matrix `ci' = 2*`scorei'*`H'*`scorei''
             qui replace `pref' = `ci'[1,1] in `i'
             local i = `i' + 1
            }
		if !missing("`show'") {
		di in gr "(Cook's Distances)"
		list `pref', `show'
		}
		}
		
	
	

end

	
	
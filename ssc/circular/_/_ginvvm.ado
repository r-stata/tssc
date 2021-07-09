*! NJC 1.1.1 3 May 2004 
* NJC 1.1.0  29 April 2004 
* NJC 1.0.0  1 August 2001
program _ginvvm 
	version 8 
	syntax newvarname =/exp [if] [in] /// 
	[ , Kappa(numlist max=1 min=0 >=0) tol(real 1e-6) log RADians]  
	
	if "`kappa'" == "" {
		tempname kappa 
		scalar `kappa' = r(kappa) 
		if `kappa' == . { 
			di as err "kappa needed" 
			exit 198 
		} 	
	} 

	tempvar P f t v u g 
	tempname c
	marksample touse, novarlist
		
	quietly {
		gen double `P' = `exp' 
		replace `touse' = 0 if `P' > 1 | `P' < 0 
		gen double `f' = 0.5 
		gen double `t' = 0
		i0kappa `kappa' 
		scalar `c' = log(r(i0kappa))
		gen double `v' = . 
		gen double `u' = . 
		gen double `g' = . 
		local done = 0 
		while !`done' { 
			replace `g' = `f' - `P' 
			replace `u' = ///
		`t' - sign(`g') * exp(log(abs(`g')) + `c' - `kappa' * cos(`t'))
			replace `t' = `u' 
			tempvar newf 
			egen double `newf' = vm(`t'), k(`kappa') radians 
			replace `f' = `newf' 
			drop `newf' 
			replace `v' = abs(`f' - `P') 
			su `v', meanonly 
			if "`log'" != "" noi di `r(max)'
			if r(max) < `tol' local done 1
		} 

		// ignore user type
		if "`radians'" == "" { 
			gen double `varlist' = `t' * 180 / _pi if `touse' 
		} 
		else gen double `varlist' = `t' if `touse' 
	}
end

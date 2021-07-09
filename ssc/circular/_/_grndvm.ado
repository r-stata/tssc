*! NJC 1.0.1 3 May 2004
* NJC 1.0.0 15 April 2004
program _grndvm  
	version 8
	gettoken type 0 : 0
        gettoken g 0 : 0
        gettoken eqs 0 : 0
        gettoken lparen 0 : 0, parse("(")
        gettoken rparen 0 : 0, parse(")")
        syntax [if] [in] [ , Kappa(numlist max=1 min=0 >=0) Mu(str) RADians]  
	
	if "`kappa'" == "" {
		tempname kappa 
		scalar `kappa' = r(kappa) 
		if `kappa' == . { 
			di as err "kappa needed" 
			exit 198 
		} 	
	}

	if "`mu'" == "" {
		local mu = r(vecmean) 
		if `mu' == . { 
			di as txt "mu assumed " as res 0 
			local mu 0 
		} 	
	} 

	local murad = _pi * `mu' / 180 

	tempname a b r z f c U2 
	marksample touse, novarlist

	quietly {
		gen `g' = . 
		scalar `a' = 1 + sqrt(1 + 4 * `kappa'^2) 
		scalar `b' = (`a' - sqrt(2 * `a')) / (2 * `kappa') 
		scalar `r' = (1 + (`b')^2) / (2 * (`b')) 

		forval i = 1/`=_N' { 
			if `touse'[`i'] { 
				local bad 1  
				while `bad' {  
			        	scalar `z' = cos(_pi * uniform()) 
					scalar `f' = (1 + `r' * `z') / (`r' + `z') 
					scalar `c' = `kappa' * (`r' - `f') 
					scalar `U2' = uniform() 
			                if (`c' * (2 - `c') - `U2') >= 0 { 
						local bad 0 
					} 	
					else if (log(`c' / `U2') + 1 - `c') >= 0 { 
						local bad 0 
					} 
				} 
				replace `g' = ///
				sign(uniform() - 0.5) * acos(`f') in `i'
				if "`radians'" == "" { 
					replace `g' = ///
					mod(`mu' + 180 / _pi * `g', 360) in `i'
				} 
				else { 
					replace `g' = ///
					mod(`murad' + `g', 2 * _pi) in `i'
				} 	
			} 	
		} 	
	}
end

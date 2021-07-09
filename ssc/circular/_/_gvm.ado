*! NJC 2.0.2 10 May 2004 
* NJC 2.0.1 3 May 2004 
* NJC 2.0.0 28 April 2004 
* NJC 1.0.0 1 August 2001 
* von Mises F(theta | kappa, mu)                                      
* ignore user type
program _gvm
	version 8  
	syntax newvarname =/exp [if] [in] ///
	[ , Kappa(numlist max=1 >=0) Mu(str) radians ]  
	marksample touse, novarlist
	
	tempname z p  
	tempvar theta u y v s c sn cn r zz 

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
		else if "`radians'" != "" { 
			local mu = `mu' * _pi / 180 
		} 	
	} 

	local a1 = 12 
	local a2 = 0.8 
	local a3 = 8 
	local a4 = 1 
	local ck = 10.5 
	local c1 = 56

	quietly { 
		scalar `z' = `kappa'
		
		if "`radians'" != "" { 
			gen double `theta' = ///
			mod((`exp') - `mu' + 2 * _pi, 2 * _pi) 
		} 	
		else { 
			gen double `theta' = mod((`exp') - `mu' + 360, 360) 
			replace `theta' = `theta' - 360 if `theta' > 180  
			replace `theta' = _pi * `theta' / 180 
		}	
		
		markout `touse' `theta' 
		count if `touse' 
		if r(N) == 0 error 2000 
				
		gen double `u' = mod(`theta' + _pi, 2 * _pi) 
		replace `u' = `u' + 2 * _pi if `u' < 0 
		gen double `y' = `u' - _pi 

		if `z' <= `ck' { 
			gen double `v' = 0 
			if `z' > 0 { 
				scalar `p' = /// 
					`z' * `a2' - `a3' / (`z' + `a4') + `a1'
				local ip = int(`p')
				scalar `p' = `ip' 
				gen double `s' = sin(`y') 
				gen double `c' = cos(`y') 
				replace `y' = `p' * `y' 
				gen double `sn' = sin(`y') 
				gen double `cn' = cos(`y') 
				gen double `r' = 0 
				scalar `z' = 2 / `z'
				forval i = 2 / `ip' { 
					scalar `p' = `p' - 1 
					replace `y' = `sn' 
					replace `sn' = `sn' * `c' - `cn' * `s' 
					replace `cn' = `cn' * `c' + `y' * `s' 
					replace `r' = 1 / (`p' * `z' + `r') 
					replace `v' = (`sn' / `p' + `v') * `r'
				} 
			}
			gen double `varlist' = /// 
				(`u' * 0.5 + `v') / _pi if `touse' 
		} 
		else { 
			scalar `c' = 24.0 * `z' 
			gen double `v' = `c' - `c1' 
			gen double `r' = ///
			sqrt((54 / (347 / `v' + 26 - `c') - 6 + `c') / 6)
			gen double `zz' = sin(`y' * 0.5) * `r' 
			gen double `s' = `zz' * `zz' 
			replace `v' = `v' - `s' + 3 
			replace `y' = (`c' - `s' - `s' - 16) / 3
			replace `y' = ((`s' + 1.75) * `s' + 83.5) / `v' - `y' 
			gen double `varlist' = ///
				norm(`zz' - `s' / (`y' * `y') * `z') if `touse' 
		} 

		replace `varlist' = 0 if `varlist' < 0 
		replace `varlist' = 1 if `varlist' > 1  & `varlist' < . 
	} 	
end

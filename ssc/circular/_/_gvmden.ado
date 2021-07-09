*! NJC 1.0.2 9 June 2004 
* NJC 1.0.1 3 May 2004 
* NJC 1.0.0 30 March 2004 
program _gvmden 
	version 8
	syntax newvarname =/exp [if] [in] [ , Kappa(str) Mu(str) RADians]  
	
	if "`kappa'" == "" {
		local kappa = r(kappa)
		if "`kappa'" == "" { 
			di as err "kappa needed" 
			exit 198 
		} 	
	}

	if "`mu'" == "" {
		local mu = r(vecmean) 
		if `mu' == . di as txt "mu assumed " as res 0 
	} 

	marksample touse, novarlist
		
	quietly {
		i0kappa `kappa'
		// ignore user type
		if "`radians'" == "" { 
			gen double `varlist' = /// 
			exp(`kappa' * cos(_pi * ((`exp') - `mu') / 180)) ///
			/ (360 * r(i0kappa)) if `touse' 
		} 
		else { 
			gen double `varlist' = /// 
			exp(`kappa' * cos((`exp') - `mu')) ///
			/ (2 * _pi * r(i0kappa)) if `touse' 
		} 	
	}
end

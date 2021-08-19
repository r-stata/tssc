*! ISHU 1.0.0 09 July 2012
*! Based on NJC 1.0.1 29 April 2004
* and NJC 1.0.0 1 August 2001 
* IO(kappa)                                      
program i1kappa, rclass 
	version 11.0
	args kappa garbage 
	
	if "`kappa'" == "" | "`garbage'" != "" { 
		di as error "use as i0kappa #"
		exit 198 
	} 
	if `kappa' < -3.75 { 
		di as err "number out of range of approximations"
		exit 459 		
	} 

	tempname t i1kappa i1kappa 
	scalar `t' = `kappa' / 3.75
	
	if `t' <= 1 { 
		#delimit ; 
	scalar `i1kappa' = (0.5 + 0.87890594 * (`t'^2) + 0.51498869 * (`t'^4)  
	+ 0.15084934 * (`t'^6) + 0.02658733 * (`t'^8) 
	+ 0.00301532 * (`t'^10) + 0.00032411 * (`t'^12))*`kappa' ; 
		#delimit cr 
	} 
	else { 
		#delimit ; 
		scalar `i1kappa' = ( 0.39894228 - 0.03988024 / `t' 
		- 0.00362018 / (`t'^2) + 0.00163801 / (`t'^3) 
		- 0.01031555 / (`t'^4) + 0.02282967 / (`t'^5) 
		- 0.02895312 / (`t'^6) + 0.01787654 / (`t'^7) 
		- 0.00420059 / (`t'^8) ) * ( exp(`kappa') / sqrt(`kappa') ) ; 
		#delimit cr 
	} 	
        di as res `i1kappa' 
        return scalar i1kappa = `i1kappa'
end	
	

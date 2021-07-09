*! NJC 1.0.1 29 April 2004
* NJC 1.0.0 1 August 2001 
* IO(kappa)                                      
program i0kappa, rclass 
	version 8.0
	args kappa garbage 
	
	if "`kappa'" == "" | "`garbage'" != "" { 
		di as error "use as i0kappa #"
		exit 198 
	} 
	if `kappa' < -3.75 { 
		di as err "number out of range of approximations"
		exit 459 		
	} 

	tempname t i0kappa 
	scalar `t' = `kappa' / 3.75
	
	if `t' <= 1 { 
		#delimit ; 
	scalar `i0kappa' = 1 + 3.5156229 * (`t'^2) + 3.0899424 * (`t'^4)  
	+ 1.2067492 * (`t'^6) + 0.2659732 * (`t'^8) 
	+ 0.0360768 * (`t'^10) + 0.0045813 * (`t'^12) ; 
		#delimit cr 
	} 
	else { 
		#delimit ; 
		scalar `i0kappa' = ( 0.39894228 + 0.01328592 / `t' 
		+ 0.00225319 / (`t'^2) - 0.00157565 / (`t'^3) 
		+ 0.00916281 / (`t'^4) - 0.02057706 / (`t'^5) 
		+ 0.02635537 / (`t'^6) - 0.01647633 / (`t'^7) 
		+ 0.00392377 / (`t'^8) ) * ( exp(`kappa') / sqrt(`kappa') ) ; 
		#delimit cr 
	} 	
        di as res `i0kappa' 
        return scalar i0kappa = `i0kappa'
end	
	

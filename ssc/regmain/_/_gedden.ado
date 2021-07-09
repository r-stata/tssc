program _gedden, eclass
version 12.0
args dvar mu sigma p
	confirm name `dvar'
	confirm number `mu' 
	confirm number `sigma'
	confirm number `p'
	
	if `p' <=0{
		di as error "Parameter p must be positive"
	}
	if `sigma' <= 0{
		di as error "Parameter sigma must be positive"
	}

	
tempvar v 
qui gen double `v' = sqrt(exp(lngamma(1/`p') - lngamma(3/`p')))
gen _gedden_`dvar' = (`p'*exp(-(abs(`dvar' - `mu')/(`v'*`sigma'))^`p'))/(2*`v'*`sigma'*exp(lngamma(1/`p')))

end

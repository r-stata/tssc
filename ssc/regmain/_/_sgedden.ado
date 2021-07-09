program _sgedden, eclass
version 12.0

args dvar mu sigma lambda p
	confirm name `dvar'
	confirm number `mu' 
	confirm number `lambda'
	confirm number `sigma'
	confirm number `p'
	
	if `p' <=0{
		di as error "Parameter p must be positive"
	}
	if `sigma' <= 0{
		di as error "Parameter sigma must be positive"
	}
	if `lambda' <= -1 | `lambda' >= 1{
		di as error "Parameter lambda must be between -1 and 1."
	}
	
tempvar m v 
qui gen double `v' = sqrt(_pi*exp(lngamma(1/`p'))/(_pi*(1+3*`lambda'^2)*exp(lngamma(3/`p'))-16^(1/`p')*`lambda'^2 * exp(lngamma(1/2 + 1/`p'))^2 * exp(lngamma(1/`p'))))
qui gen double `m' = (2^(2/`p')*`v'*`sigma'*`lambda'*exp(lngamma(1/2+1/`p')))/sqrt(_pi)
gen _sgedden_`dvar' = (`p'*exp(-(abs(`dvar' - `mu' + `m')/(`v'*`sigma'*(1+`lambda'*sign(`dvar'-`mu'+`m'))))^`p'))/(2*`v'*`sigma'*exp(lngamma(1/`p')))

end

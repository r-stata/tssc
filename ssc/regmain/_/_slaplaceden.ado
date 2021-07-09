program _slaplaceden, eclass
version 12.0

args dvar mu sigma lambda 
	confirm name `dvar'
	confirm number `mu' 
	confirm number `lambda'
	confirm number `sigma'

	if `sigma' <= 0{
		di as error "Parameter sigma must be positive"
	}
	if `lambda' <= -1 | `lambda' >= 1{
		di as error "Parameter lambda must be between -1 and 1."
	}
	
tempvar m v 
qui gen double `v' = (2*(1 + `lambda'^2))^(-.5)
qui gen double `m' = 2*`v'*`sigma'*`lambda'
gen _slaplaceden_`dvar' = exp((-abs(`dvar'-`mu'+`m'))/(`v'*`sigma'*(1 + `lambda'*sign(`dvar'-`mu'+`m'))))/(`v'*`sigma')
end

program _snormalden, eclass
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
qui gen double `v' = sqrt((2*_pi)/(_pi - 8*`lambda'^2 + 3*_pi*`lambda'^2))
qui gen double `m' = 2*`v'*`sigma'*`lambda'/sqrt(_pi)
gen _snormalden_`dvar' = exp(-((abs(`dvar' + `m'))/(`v'*`sigma'*(1 + `lambda'*sign(`dvar' + `m'))))^2)/(`v'*`sigma'*sqrt(_pi))
end

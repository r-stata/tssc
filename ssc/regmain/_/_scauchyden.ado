program _scauchyden, eclass
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

gen _scauchyden_`dvar' = 1/(`sigma'*_pi*((`dvar'^2)/(`sigma'^2*(`lambda'*sign(`dvar') + 1)^2) + 1))
end

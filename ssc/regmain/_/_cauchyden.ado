program _cauchyden, eclass
version 12.0

args dvar mu sigma lambda q
	confirm name `dvar'
	confirm number `mu' 
	confirm number `sigma'
	
	if `sigma' <= 0{
		di as error "Parameter sigma must be positive"
	}
	
gen _cauchyden_`dvar' = 1/(`sigma'*_pi*(((`dvar'-`mu')/`sigma')^2 + 1))
end

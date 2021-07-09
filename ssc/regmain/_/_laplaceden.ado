program _laplaceden, eclass
version 12.0

args dvar mu sigma 
	confirm name `dvar'
	confirm number `mu' 
	confirm number `sigma'
	
	if `sigma' <= 0{
		di as error "Parameter sigma must be positive"
	}
	
gen _laplaceden_`dvar' = exp(-abs(`dvar'-`mu')/`sigma')/(2*`sigma')
end

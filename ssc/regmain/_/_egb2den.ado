program _egb2den, eclass
version 12.0

args dvar mu sigma delta p q
	confirm name `dvar'
	confirm number `mu' 
	confirm number `sigma'
	confirm number `delta'
	confirm number `p'
	confirm number `q'
	
	if `q' <=0{
		di as error "Parameter q must be positive"
	}
	if `p' <=0{
		di as error "Parameter p must be positive"
	}



gen _egb2den_`dvar' = exp(`p'*(`dvar'-`delta')/`sigma')/(abs(`sigma')*exp(lngamma(`p') + lngamma(`q') - lngamma(`p' + `q')) * (1 + exp((`dvar' - `delta')/`sigma'))^(`p' + `q'))


end

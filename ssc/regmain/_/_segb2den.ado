program _segb2den, eclass
version 12.0

args dvar mu sigma delta p
	confirm name `dvar'
	confirm number `mu' 
	confirm number `sigma'
	confirm number `delta'
	confirm number `p'

	if `p' <=0{
		di as error "Parameter p must be positive"
	}
gen _segb2den_`dvar' = exp(`p'*(`dvar'-`delta')/`sigma')/(abs(`sigma')*exp(2*lngamma(`p') - lngamma(2*`p')) * (1 + exp((`dvar' - `delta')/`sigma'))^(2*`p'))

end

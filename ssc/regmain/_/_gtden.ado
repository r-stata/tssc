program _gtden, eclass
version 12.0

args dvar mu sigma p q
	confirm name `dvar'
	confirm number `mu' 
	confirm number `sigma'
	confirm number `p'
	confirm number `q'
	
	if `q' <=0{
		di as error "Parameter q must be positive"
	}
	if `p' <=0{
		di as error "Parameter p must be positive"
	}
	if `sigma' <= 0{
		di as error "Parameter sigma must be positive"
	}


tempvar v m b1 b2
qui gen double `b1' = lngamma(1/`p') + lngamma(`q') - lngamma(1/`p' + `q')
qui gen double `b2' = lngamma(3/`p') + lngamma(`q'-2/`p') - lngamma(3/`p' + `q' - 2/`p')
qui gen double `v' = `q'^(-1/`p') * (exp(`b1')/exp(`b2'))^(1/2)
qui gen double `m' = ((abs(`x' - `mu')^`p')/(`q'*(`v'*`sigma')^`p') + 1)
gen _gtden_`dvar' = `p'/(2*`v'*`sigma'*`q'^(1/`p') * exp(`b1') * ((abs(`dvar')^`p')/(`q'*(`v'*`sigma')^`p') + 1)^(1/`p' + `q'))


end

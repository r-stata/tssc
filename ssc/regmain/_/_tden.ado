program _tden, eclass
version 12.0

args dvar mu sigma q
	confirm name `dvar'
	confirm number `mu' 
	confirm number `sigma'
	confirm number `q'
	
	if `q' <=0{
		di as error "Parameter q must be positive"
	}

	if `sigma' <= 0{
		di as error "Parameter sigma must be positive"
	}

tempvar m v bet 
loc p = 2
loc lambda = 0
qui gen double `v' = (`q'^(-1/`p'))/((3*(`lambda'^2)+1)*(exp(lngamma(3/`p') + lngamma(`q'-2/`p')-lngamma(3/`p'+`q'-2/`p'))/exp(lngamma(1/`p')+lngamma(`q')-lngamma(1/`p'+`q')))-4*(`lambda'^2)*((exp(lngamma(2/`p')+lngamma(`q'-1/`p')-lngamma(2/`p'+`q'-1/`p')))^(2)/((exp(lngamma(1/`p')+lngamma(`q')-lngamma(1/`p'+`q')))^2)))^(1/2)
qui gen double `bet' = exp(lngamma(1/`p') + lngamma(`q') - lngamma(1/`p' + `q'))
qui gen double `m' = (2*`v'*`sigma'*`lambda'*`q'^(1/`p')*exp(lngamma(2/`p')+lngamma(`q'-1/`p')-lngamma(2/`p'+`q'-1/`p')))/(exp(lngamma(1/`p')+lngamma(`q')-lngamma(1/`p'+`q')))
gen _tden_`dvar' =  (`p')/(2*`v'*`sigma'*`q'^(1/`p')*`bet'*((abs(`dvar' + `mu' + `m'))^(`p')/(`q'*(`v'*`sigma')^(`p')*(`lambda'*sign(`dvar' - `mu' + `m') + 1)^`p') + 1)^(1/`p' + `q'))
end

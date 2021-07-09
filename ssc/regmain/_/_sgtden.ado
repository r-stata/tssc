program _sgtden, eclass
version 12.0

args dvar mu sigma lambda p q 
	confirm name `dvar'
	confirm number `mu' 
	confirm number `lambda'
	confirm number `sigma'
	confirm number `p'
	confirm number `q'
	
	if `p' <=0{
		di as error "Parameter p must be positive"
	}
	if `q' <=0{
		di as error "Parameter q must be positive"
	}
	if `sigma' <= 0{
		di as error "Parameter sigma must be positive"
	}
	if `lambda' <= -1 | `lambda' >= 1{
		di as error "Parameter lambda must be between -1 and 1."
	}
	
tempvar m v bet
qui gen double `v' = (`q'^(-1/`p'))/((3*(`lambda'^2)+1)*(exp(lngamma(3/`p') + lngamma(`q'-2/`p')-lngamma(3/`p'+`q'-2/`p'))/exp(lngamma(1/`p')+lngamma(`q')-lngamma(1/`p'+`q')))-4*(`lambda'^2)*((exp(lngamma(2/`p')+lngamma(`q'-1/`p')-lngamma(2/`p'+`q'-1/`p')))^(2)/((exp(lngamma(1/`p')+lngamma(`q')-lngamma(1/`p'+`q')))^2)))^(1/2)
qui gen double `bet' = exp(lngamma(1/`p') + lngamma(`q') - lngamma(1/`p' + `q'))
qui gen double `m' = (2*`v'*`sigma'*`lambda'*`q'^(1/`p')*exp(lngamma(2/`p')+lngamma(`q'-1/`p')-lngamma(2/`p'+`q'-1/`p')))/(exp(lngamma(1/`p')+lngamma(`q')-lngamma(1/`p'+`q')))
gen _sgtden_`dvar' =  (`p')/(2*`v'*`sigma'*`q'^(1/`p')*`bet'*((abs(`dvar' + `mu' + `m'))^(`p')/(`q'*(`v'*`sigma')^(`p')*(`lambda'*sign(`dvar' - `mu' + `m') + 1)^`p') + 1)^(1/`p' + `q'))
end

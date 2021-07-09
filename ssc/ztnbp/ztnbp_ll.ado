program define ztnbp_ll
	args lnf xb lnalpha p
	qui {
	local y "$ML_y1"
	tempvar m
	gen double `m' = exp((2-`p')*`xb'-`lnalpha')
	replace `lnf'  = lngamma(`m'+`y') - lngamma(`y'+1) /*
		*/ - lngamma(`m') + `m' * ln(`m'/(`m'+exp(`xb'))) /*
		*/ + `y' * ln(exp(`xb')/(`m'+exp(`xb')))	 /*
		*/ - ln(1 - (`m'/(`m'+exp(`xb')))^(`m'))	
	}
end

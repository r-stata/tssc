*! version 1.6.0 MLB 12Sep2012
program propcnspoisson_lf
	version 8.2
	args lnf unconstrained constrained lambda
	tempvar theta
	
	quietly{
		gen double `theta' = `unconstrained' + (`lambda'*`constrained')
		replace `lnf' = $ML_y1*`theta' - exp(`theta') - lngamma($ML_y1 +1)
	}
end

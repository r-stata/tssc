*! version 1.0.0 MLB 28 Jul 2007
program propcnsreg_lf
	version 8.2
	args lnf unconstrained constrained lambda ln_sigma
	tempvar theta
	
	quietly{
		gen double `theta' = `unconstrained' + (`lambda'*`constrained')
		replace `lnf' = ln(normalden($ML_y1,`theta',exp(`ln_sigma')))
	}
end

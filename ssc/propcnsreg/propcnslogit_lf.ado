*! version 1.6.0 MLB 12Sep2012
program propcnslogit_lf
	version 8.2
	args lnf unconstrained constrained lambda
	tempvar theta
	
	quietly{
		gen double `theta' = `unconstrained' + (`lambda'*`constrained')
		replace `lnf' = ln(invlogit( `theta')) if $ML_y1 == 1
		replace `lnf' = ln(invlogit(-`theta')) if $ML_y1 == 0
	}
end

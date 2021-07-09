*! version 1.0.0 MLB 28 Jul 2007
program mimic_lf
	version 8.2
	args lnf unconstrained constrained lambda ln_sigma ln_sigma_latent
	tempvar theta sigma
	
	quietly{
		gen double `theta' = `unconstrained' + (`lambda'*`constrained')
		gen double `sigma' = sqrt(exp(`ln_sigma')^2 + (`lambda')^2*exp(`ln_sigma_latent')^2)
		replace `lnf' = ln(normalden($ML_y1,`theta',`sigma'))
	}
end

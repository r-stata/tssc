*! version 1.2.0 Stephen P. Jenkins, April 2004
*! Fitting of Lognormal distribution by ML
*! Called by lognfit.ado

program define lognfit_ll

	version 8.2
	args lnf m v

	quietly replace `lnf' = -ln($S_mlinc) - ln(sqrt(2*_pi)) - ln(`v') 	///
		- .5*(`v'^(-2))*( ln($S_mlinc) - `m')^2

end


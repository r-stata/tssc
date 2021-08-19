/*
Plot the kdensity of the marginal effect estimates with one line per functional form.
*/
program multivrs_marginsplot, rclass
syntax , model(string)
	return add
	local lpatterns solid dash dot shortdash longdash
	local kdensity_per_model
	local labs_per_model	
	local nmodels 0
	foreach  m of local model {
		local ++nmodels
		local lp : word `nmodels' of `lpatterns' 
		if "`kdensity_per_model'" != "" local kdensity_per_model "`kdensity_per_model' || "
		local kdensity_per_model `"`kdensity_per_model' kdensity b_intvar if model == "`m'", lpattern("`lp'")"'
		local labs_per_model `"`labs_per_model' lab(`nmodels' "`m'")"'		
	}

	twoway `kdensity_per_model' , ///
		xtitle("Marginal Effect Estimates") legend(`labs_per_model') ///	
		graphregion(color(white)) ytitle("Density") //saving("graphs/figure-1-multivrs", replace)

end


*!1.0.1 Brent McSharry brent@focused-light.net 6Mar2011
program oeratio, rclass byable(recall)
version 10.1
	syntax [namelist(max=2)] [if] [in] [, LEVel(integer $S_level) SEonly]
	marksample touse
	/* qui replace `touse' = 0 if !e(sample) */
	
	tempvar florapq 
	tempname sumprob predict_se zscore
	
	qui count if `touse'
	local n = `r(N)'
	if `n' == 0{
		error 2000
	}
	
	if "`namelist'" == "" {
		capture assert "`e(cmd)'" == "logit" | "`e(cmd)'" == "logistic"
		if _rc != 0 {
			di as error "Command must follow logit or logistic if no prediction variables specified"
			error 301
		}
		if "`if'" == "" & "`in'" == "" {
			qui replace `touse' = e(sample)
		}
		tempvar p
		qui predict double `p' if `touse', pr
		local depvar `e(depvar)'
	}
	else {
		local novars:word count `namelist'
		capture confirm numeric variable `namelist'
		if `novars' != 2 | _rc != 0 {
			di as error "must specify dependant variable and prediction variable"
			error 7
		}
		tokenize `namelist'
		local p `2'
		local depvar `1'
		qui replace `touse' = 0 if missing(`1',`2')
	}
	qui count if `touse'
	di as res `r(N)' /*
		*/ as txt " observations included:"
	sum `p' if `touse', meanonly
	scalar `sumprob' = `r(sum)'
	
	sum `depvar' if `touse', meanonly
	local observed = `r(sum)'
	
	qui generate double `florapq' = `p' * (1 - `p') if `touse'
	sum `florapq', meanonly
	scalar `predict_se' = sqrt(`r(sum)')
	scalar `zscore' = ((`observed'-`sumprob')/`predict_se')
	
	if "`seonly'" == "" {
		local z = invnormal((100 + `level')/200)
		local obs_ub = `observed' + (`z' * `predict_se')
		local obs_lb = `observed' - (`z' * `predict_se')
		if `obs_lb' < 0 {
			local obs_lb = 0
		}
		local pc = int(normal(`zscore') * 100)
		if `pc' == 0 {
			local pc < 1
			local suf st
		}
		else if int(`pc'/10) == 1 {
			local suf th
		}
		else {
			local suf th st nd rd th th th th th th
			local i = mod(`pc', 10) + 1
			local suf:word `i' of `suf'
		}
		///%5.1g 
		local col 26
		di as text "{ralign `col':outcomes observed =}" /*
			*/ as res %9.0g `observed' /*
			*/ as text "{space 4}(`level'% CI " /*
			*/ as res %3.1f `obs_lb' /*
			*/ as text " - " /*
			*/ as res %3.1f `obs_ub' /*
			*/ as text ")"
		di as text "{ralign `col':outcomes expected =}" /*
			*/ as res %11.1f `sumprob' 
		di as text "{ralign `col':Standardized Ratio =}" /*
			*/ as res %12.2f `observed'/`sumprob' /*
		    */ as text " (`level'% CI " /*
			*/ as res %4.2f `obs_lb' / `sumprob' /*
			*/ as text " - " /*
			*/ as res %4.2f `obs_ub' / `sumprob' /*
			*/ as text ")"
		di as text "{ralign `col':z =}" /*
			*/ as res %12.2f `zscore' /*
			*/ as text " (" /*
			*/ as res "`pc'" /*
			*/ as text "`suf' centile)"
	}

	return scalar predicted = `sumprob'
	return scalar se = `predict_se'
	return scalar N = `n'
	return scalar obs = `observed'
	return scalar ratio = `observed'/`sumprob'
	return scalar z = `zscore'
end



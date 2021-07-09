*! version 1.0.1
*! Predict Program for the Command tslstarmod
*! Diallo Ibrahima Amadou
*! All comments are welcome, 18Sep2019



capture program drop tslstarmod_p
program tslstarmod_p
    version 15.1
	syntax anything(id="newvarname") [if] [in] [, lngamma cpar lnsigma gamma sigma regime1 regime2 xb RESiduals theta * ]
	if "`lngamma'" != "" {
		syntax newvarname [if] [in] [, lngamma ]
		_predict `typlist' `varlist' `if' `in', equation(lngamma)
		label variable `varlist' "Predicted ln(gamma)"
		exit
	}
	if "`cpar'" != "" {
		syntax newvarname [if] [in] [, cpar ]
		_predict `typlist' `varlist' `if' `in', equation(cpar)
		label variable `varlist' "Predicted cpar"
		exit
	}
	if "`lnsigma'" != "" {
		syntax newvarname [if] [in] [, lnsigma ]
		_predict `typlist' `varlist' `if' `in', equation(lnsigma)
		label variable `varlist' "Predicted ln(sigma)"
		exit
	}
	if "`gamma'" != "" {
		syntax newvarname [if] [in] [, gamma ]
		_predict `typlist' `varlist' `if' `in', equation(lngamma)
		quietly replace `varlist' = exp(`varlist')
		label variable `varlist' "Predicted gamma"
		exit
	}
	if "`sigma'" != "" {
		syntax newvarname [if] [in] [, sigma ]
		_predict `typlist' `varlist' `if' `in', equation(lnsigma)
		quietly replace `varlist' = exp(`varlist')
		label variable `varlist' "Predicted sigma"
		exit
	}
	if "`regime1'" != "" {
		syntax newvarname [if] [in] [, regime1 ]
		_predict `typlist' `varlist' `if' `in', equation(Regime1)
		label variable `varlist' "Predicted Regime1"
		exit
	}
	if "`regime2'" != "" {
		syntax newvarname [if] [in] [, regime2 ]
		_predict `typlist' `varlist' `if' `in', equation(Regime2)
		label variable `varlist' "Predicted Regime2"
		exit
	}
    if "`residuals'" != "" {
                            syntax newvarname [if] [in] [, RESiduals  ]
							tempvar myregimz1 myregimz2 theta gammap cpar vxb4
							quietly _predict double `myregimz1' `if' `in', equation(Regime1)
							quietly _predict double `myregimz2' `if' `in', equation(Regime2)
							local lagy = "`e(thresva)'"
							quietly _predict double `gammap' `if' `in', equation(lngamma)
							quietly replace `gammap' = exp(`gammap')
							quietly _predict double `cpar' `if' `in', equation(cpar)
							quietly generate double `theta'  = (1+exp(-`gammap'*(`lagy' - `cpar')))^(-1) `if' `in'	
							quietly generate double `vxb4'  = `myregimz1' + `theta'*(`myregimz2')  `if' `in'							
                            local depvars4 = "`e(depvar)'"
                            generate `typlist' `varlist'  = `depvars4' - `vxb4'  `if' `in'
                            label variable `varlist' "Predicted Residuals"
                            exit
    }
	if "`theta'" != "" {
		syntax newvarname [if] [in] [, theta ]
		tempvar gammap cpar
		local lagy = "`e(thresva)'"
		quietly _predict double `gammap' `if' `in', equation(lngamma)
		quietly replace `gammap' = exp(`gammap')
		quietly _predict double `cpar' `if' `in', equation(cpar)
		generate `typlist' `varlist' = (1+exp(-`gammap'*(`lagy' - `cpar')))^(-1) `if' `in'		
		label variable `varlist' "Predicted theta"
		exit
	}
	if "`options'" != "" {
		ml_p `0'
		exit
	}		

	syntax newvarname [if] [in] [, xb ]
	tempvar myregimz1 myregimz2 theta gammap cpar
	quietly _predict double `myregimz1' `if' `in', equation(Regime1)
	quietly _predict double `myregimz2' `if' `in', equation(Regime2)
	local lagy = "`e(thresva)'"
	quietly _predict double `gammap' `if' `in', equation(lngamma)
	quietly replace `gammap' = exp(`gammap')
	quietly _predict double `cpar' `if' `in', equation(cpar)
	quietly generate double `theta'  = (1+exp(-`gammap'*(`lagy' - `cpar')))^(-1) `if' `in'		
	generate `typlist' `varlist'  = `myregimz1' + `theta'*(`myregimz2')  `if' `in'
	label variable `varlist' "Prediction from all the Equations Taken Together"
	
end



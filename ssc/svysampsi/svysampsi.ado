*! 1.1.0 Ariel Linden 14jul2013 // added additional return scalars 
* suggestions NJC 4aug2013 
*! 1.0.0 Ariel Linden 14jul2013 

program svysampsi, rclass
	version 11.0
	syntax anything(id="argument numlist") [,  ///
		Proportion(numlist max=1 >0.00 <1.00)  ///
		MOE(numlist max=1 >0 <100.00)        ///
		RESPonse(numlist max=1 >0.00 <1.00)  ///
		LEVel(cilevel) ]                             
         

    /// handling inputs 
	local ntokens : word count `anything'
        if `ntokens' > 1 exit 103
        else if `ntokens' < 1 exit 102
	local pop `anything' // population size
	confirm number `pop'			
	return scalar pop = `pop'
	
	tempname zval ss fsc adjss resp_adjss
	scalar `zval' = abs(invnormal((100 - `level')/200))

	if "`proportion'" == "" local prop 0.5 
	else local prop `proportion'
	return scalar prop = `prop'
	
	if "`moe'" == "" local moe 0.05 
    else local moe = `moe' / 100
	return scalar moe = `moe'
	
	if "`response'" == "" local resp 1 
	else local resp `response'
	return scalar resp = `resp'
	
    // calculate sample sizes and correct for finite samples	

    // unadjusted sample size
	scalar `ss' = (`zval'^2 * `prop' * (1 - `prop')) / `moe'^2 	
	return scalar ss = round(`ss')

	// finite sample correction factor
	scalar `fsc' = 1 + ((`ss' - 1) / `pop')

	// corrected sample size
	scalar `adjss' = `ss' / `fsc'	
	return scalar adjss = round(`adjss')

	// sample size adjusted for response rate
	scalar `resp_adjss' = `adjss' /`resp'			
	return scalar resp_adjss = round(`adjss' /`resp')
	
	// display results
    di 
	di as txt "Estimated sample size needed to survey, assuming the following: " _n
	di as txt "   Population size: " as result `pop' 
	di as txt "   Proportion of sample with the expected outcome: " as result %4.2f `prop' 
	di as txt "   Margin of error: +/- " as result %4.1f `moe' * 100 " %"
	di as txt "   Confidence level: " as result %4.1f `level' " %"
	
	// when response rate is provided
	if `resp' != 1  {
		di as txt "   Response rate: " as result %4.1f `resp' * 100 " %"
	}
	
	di _n as txt "Estimated required sample size:" 
	di _n as txt "       n = " as result round(`adjss')

	// when response rate is provided
	if `resp' != 1  {
		di _n as txt "Estimated required sample size adjusted for "  as result ///
		%4.1f `resp' * 100 " %" as text " response rate:" 
		di _n as txt "       n = " as result round(`resp_adjss')
	}
	
end

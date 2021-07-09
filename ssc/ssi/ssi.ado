*! version 1.0.0 14may2010 \ Philip M Jones (Copyright), pjones8@uwo.ca
/* ssi: Sample size calculation program including non-inferiority and equivalence */
/* No claims about the accuracy of this program are stated or implied. */

capture program drop ssi
program define ssi, rclass
	version 11
	
	gettoken m1 0 : 0, parse(" ,")
    gettoken m2 0 : 0, parse(" ,")

    /* error checking */
    confirm number `m1'
    confirm number `m2'

	syntax [, Power(real 0.80) Alpha(real 0.05) SD1(real -1) sd2(real -1) Loss(real 0) c1(real 0) c2(real 0) ///
			n(real 0) NONinferiority EQUivalence]
	
	if `sd2' == -1 & `sd1' ~= -1 {
		local sd2 = `sd1'
	}
		
	if (`m1' < 0 | `m2' < 0 | (`sd1' ~= -1 & `sd1' < 0) | (`sd2' ~= -1 & `sd2' < 0) | `power' < 0 | `alpha' < 0) ///
		| (`sd1' == -1) & (`m1' > 1 | `m1' < 0 |`m2' > 1 | `m2' < 0) {
		di as error "If testing means, then sd(#) must be specified."
		di as error "If testing proportions, the proportions must be between 0 and 1."
		di as error "If n(#) is included as part of the command, power is calculated."
		di as error "See {help ssi:help ssi} for details."
		exit
	}
	
	//determine what sample size the user is wanting to compute
	// if sd1 is -1 then user did not enter a SD and therefore must be computing a sample size for proportions
	
	local type = 0 			// type identifies whether noninferiority (1) or equivalence (2) or neither (0)
	if "`noninferiority'" ~= "" {
		local type = 1
	}
	else if "`equivalence'" ~= "" {
		local type = 2
	}
	
	if `sd1' == -1 {
		local proportion = 1		// user did not enter a SD, therefore this is a proportion
		}
	else {
		local proportion = 0		// user entered a SD, therefore this is not a proportion
	}
	
	di ""							// make some space in the output
	
	// calculate sample size for proportions
	if `proportion' == 1 {
		if `type' == 0 {					// proportion, normal
			
			local dalpha = 1 - `alpha'/2	
			local func_alpha_beta = ( invnorm(`dalpha') + invnorm(`power')  )^2
			local per_group_size = ceil(`func_alpha_beta' * ( (`m1' * (1 - `m1') + `m2' * (1 - `m2') ) / (`m1' - `m2')^2 ))
			
			if `n' == 0 {
			
				display in green "Estimated sample size for two-sample comparison of proportions"
				di ""
				di "Null hypothesis:" _col(25) in yellow " p1 = p2" in green ", where:  p1 is the proportion in population 1"
				di _col(43) "p2 is the proportion in population 2"
				di "Alternative hypothesis: " in yellow "p1 != p2"
				di in green ""
				di "Assumptions:"
				di _col(10) in green "power = " _col(10) in yellow string(`power', "%9.4f")
				di _col(10) in green "alpha = " _col(10) in yellow string(`alpha', "%9.4f") in green " (two-sided)"
				di _col(13) in green "p1 = " _col(10) in yellow string(`m1', "%9.4f")
				di _col(13) in green "p2 = " _col(10) in yellow string(`m2', "%9.4f")
				di _col(10) in green "estimated required sample size (per group) = " _col(10) in yellow string(`per_group_size', "%9.0f")
				di ""
			}
			
			else {
			
				local calc_power = normal(sqrt( (`m1' - `m2')^2 * `n' / ( `m1' * (1-`m1') + `m2' * (1-`m2') ))  - invnorm(`dalpha'))
				display in green "Calculated power for a two-sample comparison of proportions."
				di ""
				di "Assumptions:"
				di _col(10) in green "n (per group) = " _col(10) in yellow string(`n', "%9.0f")
				di _col(10) in green "alpha = " _col(10) in yellow string(`alpha', "%9.4f") in green " (two-sided)"
				di _col(10) in green "p1 = " _col(10) in yellow string(`m1', "%9.4f")
				di _col(10) in green "p2 = " _col(10) in yellow string(`m2', "%9.4f")
				di ""
				di in yellow "The power is: " string(`calc_power', "%9.4f")

			}
					
		}
		
		else if `type' == 1 {			// proportion, noninferiority
			
			local dalpha = 1 - `alpha'	
			local func_alpha_beta = ( invnorm(`dalpha') + invnorm(`power')  )^2
			local per_group_size = ceil(`func_alpha_beta' * ( (2 * `m1' * (1 - `m1')) / (`m2')^2 ))
			
			if `n' == 0 {
			
				display in green "Estimated sample size for two-sample comparison of proportions " in yellow "(non-inferiority)"
				di ""
				di in green "Null hypothesis: " in yellow "p2 - p1 ³ delta" in green " (inferior), where:"
				di _col(32) "pi (entered in command) is the overall proportion of participants"
				di _col(32) "expected to experience the outcome if the treatments"
				di _col(32) "are non-inferior, and delta is the smallest change in"
				di _col(32) "proportions between groups (p2 - p1) which would still"
				di _col(32) "be clinically important."
				di ""
				di "Alternative hypothesis: " in yellow "p2 - p1 < delta" in green " (non-inferior)"
				di in green ""
				di "Note: a non-inferiority analysis is one-sided."
				di ""
				di "Assumptions:"
				di _col(10) in green "power = " _col(10) in yellow string(`power', "%9.4f")
				di _col(10) in green "alpha = " _col(10) in yellow string(`alpha', "%9.4f") in green " (one-sided)"
				di _col(13) in green "pi = " _col(10) in yellow string(`m1', "%9.4f")
				di _col(10) in green "delta = " _col(10) in yellow string(`m2', "%9.4f")
				di _col(10) in green "estimated required sample size (per group) = " _col(10) in yellow string(`per_group_size', "%9.0f")
				di ""
			}
			
			else {
			
				local calc_power = normal(sqrt( (`m2')^2 * `n' / ( 2 * `m1' * (1-`m1') ))  - invnorm(`dalpha'))
				display in green "Calculated power for a two-sample comparison of proportions " in yellow "(non-inferiority)."
				di in green ""
				di "Assumptions:"
				di _col(10) in green "n (per group) = " _col(10) in yellow string(`n', "%9.0f")
				di _col(10) in green "alpha = " _col(10) in yellow string(`alpha', "%9.4f") in green " (one-sided)"
				di _col(10) in green "average p = " _col(10) in yellow string(`m1', "%9.4f")
				di _col(10) in green "delta = " _col(10) in yellow string(`m2', "%9.4f")
				di ""
				di in yellow "The power is: " string(`calc_power', "%9.4f")
				
			}
		}
		
		else if `type' == 2 {			// proportion, equivalence
		
			local dalpha = 1 - `alpha'/2
			local dbeta = (1 - `power') / 2
			local func_alpha_beta = ( invnorm(`dalpha') + invnorm(1- `dbeta')  )^2
			local per_group_size = ceil(`func_alpha_beta' * ( (2 * `m1' * (1 - `m1')) / (`m2')^2 ))
			
			if `n' == 0 {
						
				display in green "Estimated sample size for two-sample comparison of proportions " in yellow "(equivalence)"
				di ""
				di in green "Null hypothesis: " in yellow "|p2 - p1| ³ delta" in green " (inequivalent), where:"
				di _col(32) "pi (entered in command) is the overall proportion of participants"
				di _col(32) "expected to experience the outcome if the treatments"
				di _col(32) "are equivalent, and delta is the smallest change in"
				di _col(32) "proportions between groups (p2 - p1) which would still"
				di _col(32) "be clinically important."
				di ""
				di "Alternative hypothesis: " in yellow "-delta < (p2 - p1) < +delta" in green " (equivalent)"
				di in green ""
				di "Note: an equivalence analysis is two-sided."
				di ""
				di "Assumptions:"
				di _col(10) in green "power = " _col(10) in yellow string(`power', "%9.4f")
				di _col(10) in green "alpha = " _col(10) in yellow string(`alpha', "%9.4f") in green " (two-sided)"
				di _col(13) in green "pi = " _col(10) in yellow string(`m1', "%9.4f")
				di _col(10) in green "delta = " _col(10) in yellow string(`m2', "%9.4f")
				di _col(10) in green "estimated required sample size (per group) = " _col(10) in yellow string(`per_group_size', "%9.0f")
				di ""
			}
			
			else {
				
				local n_sqrtt = sqrt(`n' * `m2'^2 / (2 * `m1' * (1-`m1')))
				local calc_power = 2 * normal(`n_sqrtt' - invnorm(`dalpha')) - 1
				display in green "Calculated power for a two-sample comparison of proportions " in yellow "(equivalence)."
				di in green ""
				di "Assumptions:"
				di _col(10) in green "n (per group) = " _col(10) in yellow string(`n', "%9.0f")
				di _col(10) in green "alpha = " _col(10) in yellow string(`alpha', "%9.4f") in green " (two-sided)"
				di _col(10) in green "average p = " _col(10) in yellow string(`m1', "%9.4f")
				di _col(10) in green "delta = " _col(10) in yellow string(`m2', "%9.4f")
				di ""
				di in yellow "The power is: " string(`calc_power', "%9.4f")
			
			}
		}
	}
	
	// calculate sample size for continuous variable
	if `proportion' == 0 {
		if `type' == 0 {					// continuous, normal
			
			local delta = abs(`m1' - `m2')
			local dalpha = 1 - `alpha'/2	
			local func_alpha_beta = ( invnorm(`dalpha') + invnorm(`power')  )^2
			local per_group_size = ceil(`func_alpha_beta' * ((`sd1'^2 + `sd2'^2) / `delta'^2))
			
			if `n' == 0 {
			
				display in green "Estimated sample size for two-sample comparison of means"
				di ""
				di in green "Null hypothesis: " in yellow "        m1 = m2" in green ", where: m1 is the mean in population 1"
				di _col(42) "m2 is the mean in population 2"
				di "Alternative hypothesis: " in yellow "m1 != m2"			
				di in green ""
				di "Assumptions:"
				di _col(10) in green "power = " _col(18) in yellow string(`power', "%9.4f")
				di _col(10) in green "alpha = " _col(18) in yellow string(`alpha', "%9.4f") in green " (two-sided)"
				di _col(13) in green "m1 = " _col(15) in yellow string(`m1',"%9.4f")
				di _col(13) in green "m2 = " _col(15) in yellow string(`m2',"%9.4f")
				di _col(12) in green "sd1 = " _col(15) in yellow string(`sd1',"%9.4f")
				di _col(12) in green "sd2 = " _col(15) in yellow string(`sd2',"%9.4f")
				di _col(10) in green "estimated required sample size (per group) = " _col(18) in yellow string(`per_group_size', "%9.0f")
				di ""
			}
			
			else {
			
				local calc_power = normal(sqrt( `delta'^2 * `n' / (`sd1'^2 + `sd2'^2))  - invnorm(`dalpha'))
				display in green "Calculated power for a two-sample comparison of means."
				di ""
				di "Assumptions:"
				di _col(10) in green "n (per group) = " _col(10) in yellow string(`n', "%9.0f")
				di _col(10) in green "alpha = " _col(10) in yellow string(`alpha', "%9.4f") in green " (two-sided)"
				di _col(10) in green "m1 = " _col(10) in yellow string(`m1', "%9.4f")
				di _col(10) in green "m2 = " _col(10) in yellow string(`m2', "%9.4f")
				di _col(10) in green "difference between means = " _col(10) in yellow string(`delta', "%9.4f")
				di _col(10) in green "observed sd1 = " _col(10) in yellow string(`sd1', "%9.4f")
				di _col(10) in green "observed sd2 = " _col(10) in yellow string(`sd2', "%9.4f")
				di ""
				di in yellow "The power is: " string(`calc_power', "%9.4f")
			}
			
		}
		
		else if `type' == 1 {			// continuous, noninferiority
		
			local delta = abs(`m1' - `m2')
			local dalpha = 1 - `alpha'
			local func_alpha_beta = ( invnorm(`dalpha') + invnorm(`power')  )^2
			local per_group_size = ceil(`func_alpha_beta' * 2 * ((`sd1'^2) / `delta'^2))
			
			if `n' == 0 {
				display in green "Estimated sample size for two-sample comparison of means {yellow:(non-inferiority)}"
				di ""
				di in green "Null hypothesis: " in yellow "       m2 - m1 ³ delta" in green " (inferior)"
				di in green "Alternative hypothesis: " in yellow "m2 - m1 < delta" in green " (non-inferior)"
				di ""
				di "Note: a non-inferiority analysis is one-sided."  
				di ""
				di "Assumptions:"
				di _col(10) in green "power = " _col(10) in yellow string(`power', "%9.4f")
				di _col(10) in green "alpha = " _col(10) in yellow string(`alpha', "%9.4f") in green " (one-sided)"
				di _col(10) in green "delta = " _col(10) in yellow string(`delta', "%9.4f")
				di _col(10) in green "expected standard deviation = " _col(10) in yellow string(`sd1', "%9.4f") in green " (in each group)
				di _col(10) in green "estimated required sample size (per group) = " _col(10) in yellow string(`per_group_size', "%9.0f")
				di ""
			}
			else {	
				// power calculation for non-inferiority
				
				local calc_power = normal(sqrt( `delta'^2 * `n' / (`sd1'^2 * 2))  - invnorm(`dalpha'))
				display in green "Calculated power for a two-sample comparison of means {yellow:(non-inferiority)}"				
				di ""
				di "Note: a non-inferiority analysis is one-sided."  
				di ""
				di "Assumptions:"
				di _col(10) in green "n (per group) = " _col(10) in yellow string(`n', "%9.0f")
				di _col(10) in green "alpha = " _col(10) in yellow string(`alpha', "%9.4f") in green " (one-sided)"
				di _col(10) in green "delta = " _col(10) in yellow string(`delta', "%9.4f")
				di _col(10) in green "observed standard deviation = " _col(10) in yellow string(`sd1', "%9.4f") in green " (in each group)
				di ""
				di in yellow "The power is: " string(`calc_power', "%9.4f")
			}
			
		}
		else if `type' == 2 {			// continuous, equivalence
		
			local delta = abs(`m1' - `m2')
			local dalpha = 1 - `alpha'/2
			local dbeta = (1 - `power') / 2
			local func_alpha_beta = ( invnorm(`dalpha') + invnorm(1 - `dbeta')  )^2
			local per_group_size = ceil(`func_alpha_beta' * 2 * ((`sd1'^2) / `delta'^2))
			
			if `n' == 0 {
			
				display in green "Estimated sample size for two-sample comparison of means {yellow:(equivalence)}"
				di ""
				di in green "Null hypothesis: " in yellow "                |m2 - m1| ³ delta" in green "  (inequivalent)"
				di in green "Alternative hypothesis: " in yellow "-delta < (m2 - m1) < +delta" in green " (equivalent)"
				di ""
				di "Note: an equivalence analysis is two-sided."
				di ""
				di "Assumptions:"
				di _col(10) in green "power = " _col(10) in yellow string(`power', "%9.4f")
				di _col(10) in green "alpha = " _col(10) in yellow string(`alpha', "%9.4f") in green " (two-sided)"
				di _col(10) in green "delta = " _col(10) in yellow string(`delta', "%9.4f")
				di _col(10) in green "expected standard deviation = " _col(10) in yellow string(`sd1', "%9.4f") in green " (in each group)
				di _col(10) in green "estimated required sample size (per group) = " _col(10) in yellow string(`per_group_size', "%9.0f")
				di ""
				return scalar power = `power'
				}
			else {
				
				// power calculation for equivalence
				
				local calc_power = 1 + (2 * (normal( sqrt( `delta'^2 * `n' / (`sd1'^2 * 2))  - invnorm(`dalpha'))) - 2)
				display in green "Calculated power for a two-sample comparison of means {yellow:(equivalence)}"
				di ""
				di "Note: an equivalence analysis is two-sided."  
				di ""
				di "Assumptions:"
				di _col(10) in green "n (per group) = " _col(10) in yellow string(`n', "%9.0f")
				di _col(10) in green "alpha = " _col(10) in yellow string(`alpha', "%9.4f") in green " (two-sided)"
				di _col(10) in green "delta = " _col(10) in yellow string(`delta', "%9.4f")
				di _col(10) in green "observed standard deviation = " _col(10) in yellow string(`sd1', "%9.4f") in green " (in each group)
				di ""
				di in yellow "The power is: " string(`calc_power', "%9.4f")
				
			}
		}
	}
	
	if `n' == 0 {
		
		display in green "The total estimated sample size is " in yellow string(2 * `per_group_size', "%9.0f")
	
		return scalar ss = 2 * `per_group_size'
		return scalar per_group_size = `per_group_size'
	
		local adj_ss = 2 * `per_group_size'
		
		if `c1' ~= 0 {			// some cross over occurred
			local adj_factor = (1 / (1 - `c1'/100 - `c2'/100)^2 )
			local adj_ss = ceil( (2 * `per_group_size' * (`adj_factor')))
			di ""
			di in green "Since " in yellow abs(`c1') "%" in green " of subjects in group 1 and " in yellow abs(`c2') "%"  ///
			in green " of subjects in group 2 crossed over,"
			di "the total sample size is adjusted to " in yellow `adj_ss'
		}
	
		if `loss' ~= 0 {		// some loss to follow-up has occurred
			local adj_ss = ceil( (`adj_ss' * (1 / (1 - abs(`loss') / 100))))
			di ""
			di in green "Since " in yellow abs(`loss') "%" in green " of subjects are expected to be lost to follow-up,"
			di _col(5) "the total sample size is adjusted to " in yellow `adj_ss'
		}
	
		return scalar adj_ss = `adj_ss'
		return scalar power = `power'
		}
	else {
		return scalar power = `calc_power'
	}
	
	
	
end

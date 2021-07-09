*! 1.0.0 Ariel Linden 29May2019

program define esizeregi, rclass
version 11.0

			syntax  anything ,				 	///
				SDy(numlist max=1)				///
				n1(numlist max=1)				///
				n2(numlist max=1)				///
				[, LEVel(cilevel) ]

			numlist "`anything'", min(1) max(1)

			tempname N sdpooled d v se iz CohensD_Lower CohensD_Upper 

			scalar `N' = `n1' + `n2'

			// Original formula for the within groups standard deviation from Lipsey and Wilson (2001) (formula 14 - Table B10)  
*			scalar `sdpooled' = sqrt(((`sdy'^2) * (`N'-1) - ((`m1'^2) + (`m2'^2) - 2 * (`m1') * (`m2')) * (`n1' * `n2') /`N') / (`N'-1))

			// This pooled SD is algebraically equivalent to formula 14, but more parsimonious
			scalar `sdpooled' = sqrt(((`sdy'^2) * (`N'-1) - (`anything'^2) * (`n1' * `n2') / `N') / (`N'-1))
			scalar `d' = `anything' / `sdpooled'
			scalar `v' = (`n1' + `n2') / (`n1' * `n2') + (`d'^2) / (2 *(`n1' + `n2'))
			scalar `se' = sqrt(`v')
			scalar `iz' = invnorm(1-(1-`level'/100)/2)
			scalar `CohensD_Lower' = `d' - `iz' * sqrt(`v')
			scalar `CohensD_Upper' = `d' + `iz' * sqrt(`v')

			// Display Title
			disp _newline as text "Effect size based on the regression coefficient of the treatment (exposure) variable"
                
			// Display table header information 
			disp _newline %45s "Obs per group:"
			disp %47s "Group 1 = " %10.0fc `n1'
			disp %47s "Group 2 = " %10.0fc `n2'
      
			// Display output table for the flavor of -esize-

			tempname mytab
			.`mytab' = ._tab.new, col(5) lmargin(0)
			.`mytab'.width    20   |11  12  12    12
			.`mytab'.titlefmt  .     .   . %24s   .
			.`mytab'.pad       .     1   1  3     3
			.`mytab'.numfmt    . %9.6f %9.6f %9.6f %9.6f
			.`mytab'.strcolor result  .  .  .  .
			.`mytab'.strfmt    %19s  .  .  .  .
			.`mytab'.strcolor   text  .  .  .  .
			.`mytab'.sep, top
			.`mytab'.titles "Effect Size"							/// 1
							"Estimate"								/// 2
							"Std. Err."								/// 3
							"[`level'% Conf. Interval]" ""          //  4 5
			.`mytab'.sep, middle
                .`mytab'.strfmt    %24s  .  .  .  .
                .`mytab'.row    "Cohen's {it:d}"        ///
                        `d' 	                      	///
                        `se'							///
						`CohensD_Lower'                 ///
                        `CohensD_Upper'
			.`mytab'.sep, bottom	

			// Return results
			return scalar d = `d'
			return scalar se_d = `se'
            return scalar lb_d = `CohensD_Lower'
			return scalar ub_d = `CohensD_Upper'
	
			// Make a c_local macro of d and se 
			c_local d = `d'
			c_local se = `se'

end

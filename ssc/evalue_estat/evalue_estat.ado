*! version 1.0.0  //  Ariel Linden 24Aug2019 

program define evalue_estat, rclass
version 11.0

			// * turn "==" into "=" if needed before calling syntax *//
			gettoken treat rest : 0, parse(" =")
			gettoken eq rest : rest, parse(" =")
			if "`eq'" == "==" {
				local 0 `treat' = `rest'
			}

	syntax anything [=/exp]
	
			// * ensure "true" value is numeric
			if "`exp'" != "" confirm number `exp'
		
			// * store model estimates * //
			estimates store results
			
			// * verify that the previous model estimates are available * //
			capture assert matrix list r(table)
				if _rc { 
					qui estimates restore results
					qui estimates replay results
				}
	
			// * save table of estimates as matrix * //
			qui matrix b = r(table)
			
			
			// * generate error if treat(name) is not in regression table * //  
			local colnames : colnames b
			if !`: list treat in colnames' {
				di as err "The regressor {bf:`treat'} is not found." ///
				" Use the model's option -coeflegend- to display coefficient names"
				exit 498
			}

			// * retrieve estimate and CI* // 
			local est = b[1,colnumb(matrix(b),"`treat'")]
			local ll = b[5,colnumb(matrix(b),"`treat'")]
			local ul = b[6,colnumb(matrix(b),"`treat'")]
		
			// * Exponentiate if eform = 0	for exponentiated models * //	
			if inlist("`e(cmd)'", "logistic", "logit", "cloglog", "scobit", "clogit", "stcox", "streg") | inlist("`e(cmd)'", "tpoisson", "nbreg", "zip", "zinb", "poisson", "cpoisson") {
				if b[9,colnumb(matrix(b),"`treat'")] == 0 {
					local est = exp(`est')
					local ll = exp(`ll')
					local ul = exp(`ul')
				}
			} // end exponentiated
		
			**************
			* Odds Ratio *
			**************
			if inlist("`e(cmd)'", "logistic", "logit", "cloglog", "scobit", "clogit") {
				
				// * assess whether outcome is common * //
				sum `e(depvar)' if e(sample), meanonly
				if inrange(r(mean), 0.15, 0.85) local common common
				
				// * run evalue *//
				evalue or `est', lcl(`ll') ucl(`ul') true(`exp') `common'
	        
			} // end OR

			****************
			* Hazard Ratio *
			****************
			else if inlist("`e(cmd2)'", "stcox", "streg") {
				
				// * assess whether outcome is common * //
				sum `e(depvar)' if e(sample), meanonly
				if inrange(r(mean), 0.15, 0.85) local common common
				
				// * run evalue *//
				evalue hr `est', lcl(`ll') ucl(`ul') true(`exp') `common'
	        
			} // end HR
			
			**************
			* Rate Ratio *
			**************
			else if inlist("`e(cmd)'", "poisson", "cpoisson", "tpoisson", "nbreg", "zip", "zinb") {
				
				// * run evalue *//
				evalue rr `est', lcl(`ll') ucl(`ul') true(`exp')
	        
			} // end RR
			
			*********************************
			* Standardized Mean Difference *
			*********************************
			else if inlist("`e(cmd)'", "regress", "tobit", "truncreg", "hetregress", "xtreg") {
			
				// * get effect size * //
				qui esizereg `treat'
				local n1 = r(n1)
				local n2 = r(n2)
				local sdy = r(sdy)
				
 				evalue smd `d', se(`se') true(`exp')

			} // end SMD
			
						
			*****************
			* invalid model *
			*****************
			else {
				di as err `"`e(cmd)' is not supported by {bf:evalue_estat}"'
				exit 198
			}

			*****************
			* saved results * 		
			*****************
			if inlist("`e(cmd)'", "regress", "tobit", "truncreg", "hetregress", "xtreg") { 
				return scalar n2 = `n2'	
				return scalar n1 = `n1'
				return scalar sdy = `sdy'				
				return scalar se_d = `se'
				return scalar d = `d'
			}
			return scalar eval_ci = `r(eval_ci)'
			return scalar eval_est = `r(eval_est)'		
			return scalar ul = `ul'
			return scalar ll = `ll'
			return scalar est = `est'

end

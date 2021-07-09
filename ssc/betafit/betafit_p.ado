*! 1.1.8 MLB 02Feb2012

program define betafit_p
        version 8.2

			/* handle scores */
	syntax [anything] [if] [in] [, SCores var(varname) * ]
        if `"`scores'"' != "" {
                GenScores `0'
                exit
        }


        local myopts "Proportion SD PEarson IProportion SCResidual mu phi alpha beta WORKing partial var(varname)"
        _pred_se "`myopts'" `0'
        if `s(done)'  exit 
        local vtyp `s(typ)'
        local varn `s(varn)'
        local 0    `"`s(rest)'"'
        syntax [if] [in] [, `myopts']

                        /* concatenate switch options together */
        local type "`proportion'`sd'`pearson'`iproportion'`scresidual'`mu'`phi'`alpha'`beta'`working'`partial'"

                        /* quickly process default case        */
        if ("`type'"=="" | "`type'"=="proportion" | "`type'" == "mu")  {
                if "`type'"=="" {
                        di in gr "(option pr assumed)"
                }
                if "`e(title)'" == "ML fit of beta (mu, phi)" {
	                tempvar t
	                qui _predict double `t' `if' `in', `offset'
	                gen `vtyp' `varn' = invlogit(`t') `if' `in'
	        }
	        if "`e(title)'" == "ML fit of beta (alpha, beta)" {
			tempvar a b
			qui _predict double `a' `if' `in', `offset' equation(alpha)
			qui _predict double `b' `if' `in', `offset' equation(beta)
			gen `vtyp' `varn' = `a'/(`a' + `b') `if' `in'
	        }
	        label var `varn' "Proportion"
		exit
        }
        
        marksample touse
        
       			/* The iproportion option is undocumenten. */
       			/* Its primary purpose is to make the sd option
       			   for the alternative specification more 
       			   numerically stable. */
        if "`iproportion'" != "" {
                if "`e(title)'" == "ML fit of beta (mu, phi)" {
        		tempvar t
			qui _predict double `t' if `touse'
		        gen `vtyp' `varn' = invlogit(-`t') `if' `in'
        	}
        	if "`e(title)'" == "ML fit of beta (alpha, beta)" {
			tempvar a b
			qui _predict double `a' `if' `in',  equation(alpha)
			qui _predict double `b' `if' `in',  equation(beta)
			gen `vtyp' `varn' = `b'/(`a' + `b') if `touse'
	        }
	        label var `varn' "Inverse proportion"
		exit
        }
        
		if "`phi'" != "" {
			if "`e(title)'" == "ML fit of beta (mu, phi)" {
				tempvar zg
				qui _predict double `zg', equation(ln_phi)
				gen `vtyp' `varn' = exp(`zg') `if' `in'
			}
			if "`e(title)'" == "ML fit of beta (alpha, beta)" {
				tempvar a b
				qui _predict double `a' `if' `in', equation(alpha)
				qui _predict double `b' `if' `in', equation(beta)
				gen `vtyp' `varn' = `a' + `b' if `touse' 
			}
			label var `varn' "phi"
			exit
		}

		if "`alpha'" != "" {
			if "`e(title)'" == "ML fit of beta (mu, phi)" {
				tempvar muhat phihat
				qui predict double `muhat' , proportion
				qui predict double `phihat', phi
				gen `vtyp' `varn' = `muhat'*`phihat' if `touse'
			}
			else {
				_predict `vtyp' `varn' `if' `in', equation(alpha)
			}
			label var `varn' "alpha"
			exit
		}
		if "`beta'" != "" {
			if "`e(title)'" == "ML fit of beta (mu, phi)" {
				tempvar imuhat phihat
				qui predict double `imuhat' , iproportion
				qui predict double `phihat', phi
				gen `vtyp' `varn' = `imuhat'*`phihat' if `touse'
			}
			else {
				_predict `vtyp' `varn' if `touse' , equation(beta)
			}
			label var `varn' "beta"
			exit
		}
        if "`sd'" != "" {
        	if "`e(title)'" == "ML fit of beta (mu, phi)" {
	        	tempvar pr ipr ln_phi
	        	qui predict double `pr' if `touse' , pr 
	        	qui predict double `ipr' if `touse' , ipr 
	        	qui _predict double `ln_phi' if `touse', equation(ln_phi)
	        	gen `vtype' `varn' = sqrt(`pr'*`ipr'*1/(1+exp(`ln_phi'))) if `touse'
	        }
	        if "`e(title)'" == "ML fit of beta (alpha, beta)" {
		        tempvar a b
			qui _predict double `a' `if' `in', `offset' equation(alpha)
			qui _predict double `b' `if' `in', `offset' equation(beta)
			gen `vtyp' `varn' = sqrt((`a'*`b')/((`a' + `b')^2*(`a' + `b' + 1))) if `touse'
	        }
		label var `varn' "Standard deviation"
		exit
        }
        
        qui replace `touse'=0 if !e(sample)
        if "`pearson'" != "" {
        	tempvar pr sd
        	qui predict double `pr' if `touse' , proportion 
        	qui predict double `sd' if `touse' , sd
        	gen `vtype' `varn' = (`e(depvar)'-`pr')/(`sd') if `touse'
            label var `varn' "Pearson residual"
            exit
        }
        
        if "`working'" != "" {
        	tempvar pr ipr
        	qui predict double `pr' if `touse' , proportion 
        	qui predict double `ipr' if `touse' , iproportion
        	gen `vtype' `varn' =  (`e(depvar)'-`pr')/(`pr'*`ipr') if `touse'
            label var `varn' "working residual"
            exit
        }

		if "`partial'" != "" {
			if "`e(title)'" == "ML fit of beta (alpha, beta)" {
				di as err "partial is only allowed after betafit in the alternative specification"
				exit 198
			}
			if "`var'" ==""{
				di as err "the var() needs to be specified when the partial option is specified"
				exit 198
			}
			capture confirm number `= _b[`var']' 
			if _rc {
				di as err "`var' needs to be an explanatory variable in tha last model"
				exit 198
			}
			tempvar working
			qui predict double `working' if `touse', working
			gen `vtype' `varn' = `working' + _b[`var']*`var' if `touse'
			exit
		}

		if "`scresidual'" != "" {
			tempvar ystar mustar a
			qui gen double `ystar' = logit(`e(depvar)')
			if "`e(title)'" == "ML fit of beta (mu, phi)" {
				tempvar xb zg
				qui _predict double `xb', xb equation(#1)
				qui _predict double `zg', xb equation(#2)
				qui gen double `mustar' = digamma( invlogit(`xb') * exp(`zg') ) - ///
										  digamma( invlogit(-`xb') * exp(`zg'))
				qui gen double `a' = trigamma( invlogit(`xb') * exp(`zg') ) + ///
									 trigamma( invlogit(-`xb') * exp(`zg'))
			}
			else {
				tempvar aa bb
				qui _predict double `aa', equation(#1)
				qui _predict double `bb', equation(#2)
				qui gen double `mustar' = digamma( `aa' ) - ///
										  digamma( `bb' )
				qui gen double `a' = trigamma( `aa' ) + ///
									 trigamma( `bb' )				
			}
			gen `vtype' `varn' = (`ystar' - `mustar')/sqrt(`a') if `touse'
			label var `varn' "score residual"
			exit
		}
		
        error 198
end

program GenScores
        version 8.2
        syntax [anything] [if] [in] [, * ]
        marksample touse
        
        _score_spec `anything', `options'
        local varn `s(varlist)'
        if "`s(eqname)'" != "" local eq "eq(`s(eqname)')"
        
        ml score `varn' if `touse', `eq'
end




*! version 1.1.1  18apr2014
*! Taken from Stata's -xtfront_p- version 1.1.0  04jun2009 and -front_p- version 1.2.0 14may2009

* 1.1.0 - Added predictions for -frontier- 
* 1.1.1 - Corrected error in cost CI

program define frontier_teci
	version 11
	syntax namelist(max=1 ) [if] [in], [Level(cilevel) ]
	marksample touse
	local varn  `namelist'
	
        if "`e(function)'" == "cost" {
		local COST=-1
	}
	
	if "`e(cmd)'" ==  "xtfrontier" {
		Xtfront_teci `varn' `touse' `level'
	}
	
	if "`e(cmd)'" ==  "frontier" {
			Front_teci `varn' `touse' `level'
	}
	
end

program define Xtfront_teci
        args varn cond level

        local y=e(depvar)
        local ivar=e(ivar)
        local by "by `ivar'"
        if "`e(model)'" == "tvd" {
                local tvar=e(tvar)
        }
        if "`e(function)'" == "cost" {
		local COST=-1
	}
        else	local COST=1

        sort `ivar' `tvar' 
                                        /* Predict xb, and get ei */
        tempvar xb res
        qui _predict double `xb' if e(sample), xb
        qui gen double `res'=`y'-`xb' if e(sample)

        tempname sigma_u2 sigma_v2 eta mu       
        scalar `sigma_u2' = e(sigma_u)^2
        scalar `sigma_v2' = e(sigma_v)^2
        scalar `mu' = [mu]_cons
        
        tempvar eta_e eta2 mui sigmai2 expu T zl zu
        if "`e(model)'" == "tvd" {
                scalar `eta' = [eta]_cons
                qui `by': egen double `T' = max(`tvar') if e(sample)
                local td `:char _dta[_TSdelta]'
                if "`td'" == "" {
                	local td 1
                }
                local eta_it (exp(-`eta'*(`tvar'-`T')/`td'))
        }
        else {
                local eta_it 1        
        }

        quietly {
                `by': gen double `eta_e' = cond( _n==_N, sum(`eta_it'*`res'), . ) 
                `by': gen double `eta2' = cond( _n==_N, sum(`eta_it'^2), . ) 
                gen double `mui' = (`mu'*`sigma_v2'  - `COST'*`eta_e'*`sigma_u2')/(`sigma_v2' + `eta2'*`sigma_u2') 
		gen double `sigmai2' = `sigma_v2'*`sigma_u2' /(`sigma_v2' + `eta2'*`sigma_u2') 
                `by': replace `mui' = `mui'[_N] if `cond'
                `by': replace `sigmai2' = `sigmai2'[_N] if `cond'

                local sigmai (sqrt(`sigmai2'))  
        }
        
	gen double `zl'  = invnormal(1 - ((1- `level'/100)/2)*[1-normal(-`eta_it'*`mui'/sqrt(`sigmai2'))])        
	gen double `varn'_l= exp(-`COST'*`eta_it'*`mui' - `zl'*sqrt(`sigmai2'))
	gen double `zu'  = invnormal(((1- `level'/100)/2)*[1-normal(-`eta_it'*`mui'/sqrt(`sigmai2'))])        
	gen double `varn'_u = exp(-`COST'*`eta_it'*`mui' - `zu'*sqrt(`sigmai2'))
	label var `varn'_l "Lower bound technical efficiency"
	label var `varn'_u "Upper bound technical efficiency"

end



program define Front_teci
        args varn cond level

	local y `e(depvar)'
	if "`e(function)'" == "cost" { 
		local COST=-1 
	}
	else { 
		local COST=1 
	}

				/* half-normal or exponential */
	if "`e(dist)'" != "tnormal" {
		if "`e(het)'" == "" {
			tempname sigma_v sigma_u
			scalar `sigma_v' = exp(0.5*[lnsig2v]_cons)
			scalar `sigma_u' = exp(0.5*[lnsig2u]_cons)
		}

		else if "`e(het)'" == "u" {
			tempname sigma_v
			scalar `sigma_v' = exp(0.5*[lnsig2v]_cons)

			tempvar xb_u sigma_u
			qui _predict double `xb_u' if `cond', xb eq(lnsig2u)
			qui gen double `sigma_u' = exp(0.5*`xb_u')
		}

		else if "`e(het)'" == "v" {
			tempname sigma_u
			scalar `sigma_u' = exp(0.5*[lnsig2u]_cons)

			tempvar xb_v sigma_v
			qui _predict double `xb_v' if `cond', xb eq(lnsig2v)
			qui gen double `sigma_v' = exp(0.5*`xb_v')
		}

		else if "`e(het)'" == "uv" {
			tempvar xb_u xb_v sigma_v sigma_u
			qui _predict double `xb_u' if `cond', xb eq(lnsig2u)
			qui gen double `sigma_u' = exp(0.5*`xb_u')

			qui _predict double `xb_v' if `cond', xb eq(lnsig2v)
			qui gen double `sigma_v' = exp(0.5*`xb_v')
		}
	}
				/* truncated-normal */
	else {
		tempname gamma sigmaS2 sigma_v sigma_u
		scalar `sigmaS2' = exp([lnsigma2]_cons)
		scalar `gamma' = [ilgtgamma]_cons
		scalar `gamma' = exp(`gamma')/(1+exp(`gamma'))		
		scalar `sigma_u' = sqrt(`gamma'*`sigmaS2')
		scalar `sigma_v' = sqrt((1-`gamma')*`sigmaS2')

		tempvar zd
		qui _predict double `zd' if `cond', xb eq(mu)
	}			

					/* Predict xb, and get ei */
	tempvar xb res zl zu
	qui _predict double `xb' if `cond', xb
	qui gen double `res'=`y'-`xb' if `cond'

					/* assume u_i|e_i is distributed
					   as N(mu1, sigma1^2) */
	tempvar mu1 sigma1
	if "`e(dist)'" == "hnormal" {
		qui gen double `mu1' = -`COST'*`res'*`sigma_u'^2 /*
			*/ /(`sigma_u'^2+`sigma_v'^2) if `cond'
		qui gen double `sigma1' = `sigma_u'*`sigma_v' /*
			*/ /sqrt(`sigma_u'^2+`sigma_v'^2) if `cond'
	}
	else if "`e(dist)'" == "exponential" {
		qui gen double `mu1'=-`COST'*`res'-(`sigma_v'^2/`sigma_u') /*
			*/ if `cond'
		qui gen `sigma1' = `sigma_v' if `cond'
	}
	else {
		qui gen double `mu1' = (-`COST'*`res'*`sigma_u'^2 + /*
		*/ `zd'*`sigma_v'^2)/(`sigma_u'^2+`sigma_v'^2) if `cond'
		qui gen double `sigma1' = `sigma_u'*`sigma_v' /*
			*/ /sqrt(`sigma_u'^2+`sigma_v'^2) if `cond'
	}

	local z (`mu1'/`sigma1') 

	gen double `zl'  = invnormal(1 - ((1- `level'/100)/2)*[normal(`z')])        
	gen double `varn'_l= exp(`COST'*(-1*`mu1' - `zl'*`sigma1'))
	
	gen double `zu'  = invnormal(1-(1-(1- `level'/100)/2)*[normal(`z')])        
	gen double `varn'_u = exp(`COST'*(-1*`mu1' - `zu'*`sigma1'))
		
	label var `varn'_l "Lower bound technical efficiency"
	label var `varn'_u "Upper bound technical efficiency"

end
       
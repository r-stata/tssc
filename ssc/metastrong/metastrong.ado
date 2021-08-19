*! 1.0.0 Ariel Linden 05Sep2020

program define metastrong, rclass
version 16.0

		syntax anything  [,					///
				PARAmetric					/// proportions computed parametrically
				above						/// proportion of effects above q
				exp							/// exponentiated values
				BOOTstrap(string) * ]		// bootstrap options
                         
				// Ensure that data are meta set/esize
				cap confirm variable _meta_es _meta_se
				if _rc {
					di as err "data not {bf:meta} set"
					di as err "{p 4 4 2}You must declare your meta-analysis " "data using {helpb meta esize} or {helpb meta set}.{p_end}"
					exit 119
                }

				// model is random
				if "`_dta[_meta_model]'" != "random" {
					di as err "{bf:metastrong} works only with random effects models"
					exit					
				} 
				
				tokenize `anything', parse(" ")
				numlist "`anything'", min(1) max(1)
                
				local q `anything'
				
				// log exponentiated q to ensure it's on a linear scale, like the estimates
				if "`exp'" != "" {
					local q = log(`q')
				}

				// generate touse from from meta set/esize
				local ifexp "`_dta[_meta_ifexp]'"
				local inexp "`_dta[_meta_inexp]'"
				
				tempvar touse
				qui gen `touse' = 1 `ifexp' `inexp'
	
				// parse bootstrap options
				local bootstrap `", `bootstrap'"'
				parse_bootstrap_options `bootstrap'


				******************************************************************
				// * parametrically derived proportions and then bootstrapped * //
				*****************************************************************
				if "`parametric'" != "" {

						if "`above'" != "" {
							bootstrap above = (1- normal((`q'-(_b[_cons]))/sqrt(e(tau2)))), `s(bsoptions)' title(Parametrically derived proportions) : meta regress _cons
						}
						else if "`above'" == "" {
							bootstrap below = (normal((`q'-(_b[_cons]))/sqrt(e(tau2)))), `s(bsoptions)' title(Parametrically derived proportions): meta regress _cons
						}

				} // end parametric	
				
				**********************************************************************
				// * calibrated estimates, non-parametrically derived proportions * //
				**********************************************************************
				if "`parametric'" == "" {
						
						preserve
						qui keep if `touse' == 1
						if "`above'" != "" {
							bootstrap above=r(phat), `s(bsoptions)' title(Calibrated estimates, non-parametrically derived proportions): metastrong_nonpar `anything', above `exp'
						}	
						else if "`above'" == "" {
							bootstrap below=r(phat), `s(bsoptions)' title(Calibrated estimates, non-parametrically derived proportions): metastrong_nonpar	`anything', `exp'
						}
				
				} // end calibrated, non-parametric

				mat p = e(b)
				scalar phat = p[1,1]
				return scalar phat = phat

end


capture program drop parse_bootstrap_options
program parse_bootstrap_options, sclass
    version 16
    syntax [varlist(default=none)]        ///
           [, reps(integer 50) * ]
            
    local bsoptions "reps(`reps') nowarn `options'"
    sreturn clear
    sreturn local bsoptions `bsoptions'
end

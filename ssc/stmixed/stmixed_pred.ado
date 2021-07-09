*! version 1.0.0 23may2014 MJC

/*
History
MJC 23may2014 version 1.0.0
*/

program stmixed_pred
	version 12.1
	syntax anything(name=vlist) [if] [in], 	[							///
												Survival 				///	-Survival function-
												Hazard 					///	-Hazard function-
												CUMHazard				///	-Cumulative hazard function-
												XB						///	-Prediction only includes fixed effects-
												FITTED					///	-Prediction includes fixed and BLUPS of random effects-
												CI 						///	-Calculate confidence intervals-
												STDP					///	-Standard error of linear predictor of first ml equation-
																		///
												REFfects				///	-Empirical Bayes predictions of the random effects-							
												RESEs					/// -Standard errors of BLUPS-													
																		///
												Level(cilevel) 			///	-confidence level-
												TIMEvar(varname) 		///	-specify a timevar()-
												AT(string)				///	-specific predictions-
												ZEROS					///	-baseline predictions-
											]

	marksample touse, novarlist
	//local newvarname `vlist'
	qui count if `touse'
	if r(N)==0 {
		error 2000		//no observations
	}
	
	//Distribution
	local smodel "`e(model)'"
	
	//==================================================================================================================================================//
	// Error checks 
	
		local wc = wordcount(`"`hazard' `survival' `cumhazard' `reffects' `reses' `stdp'"')
		if `wc'>1 {
			di as error "More than one prediction has been specified"
			exit 198
		}
		if `wc'==0 {
			di as error "No statistic has been specified"
			exit 198
		}	
		
		if wordcount(`"`ci' `stdp'"')>1 {
			di as error "Invalid syntax"
			exit 198
		}
				
		if "`smodel'"=="gamma" & "`ci'"!="" {
			di as error "ci not available"
			exit 198
		}	
		
		if wordcount(`"`xb' `fitted'"')>1 {
			di as error "Can only specify one of xb/fitted"
			exit 198
		}
		
		if wordcount(`"`at' `zeros'"')>0 & wordcount(`"`reffects' `reses'"')>0 {
			di as error "Invalid syntax"
			exit 198
		}
	
	//==================================================================================================================================================//
	// Prelims 
	
		//handle newvarlist
		if "`reffects'"!="" | "`reses'"!="" {
			_stubstar2names `vlist', nvars(`e(n_re)')
		}	
		else _stubstar2names `vlist', nvars(1) singleok
		local newvarname `s(varlist)'	
			
		//Preserve data for out of sample prediction
		tempfile newvars 
		preserve	
		
		//Use _t if option timevar not specified
		tempvar t
		if "`timevar'"=="" {
			gen `t' = _t if `touse'
		}
		else gen `t' = `timevar' if `touse'

		//Rebuild spline vars
		if "`smodel'"=="fpm" & "`timevar'"!="" {
		
			tempvar lnt
			gen double `lnt' = log(`t') if `touse'
		
			capture drop _rcs* _d_rcs*
			if "`e(noorthog)'"=="" {
				tempname rmatrix
				matrix `rmatrix' = e(R_bh)
				local rmatrixopt rmatrix(`rmatrix')
			}
			qui rcsgen `lnt' if `touse', knots(`e(ln_bhknots)') gen(_rcs) dgen(_d_rcs) `rmatrixopt'
		
			if "`e(tvc)'"!="" {
				foreach tvcvar in `e(tvc)' {
					if "`e(noorthog)'"=="" {
						tempname rmatrix_`tvcvar'
						matrix `rmatrix_`tvcvar'' = e(R_`tvcvar')
						local rmatrixopt rmatrix(`rmatrix_`tvcvar'')
					}
					qui rcsgen `lnt' if `touse',  gen(_rcs_`tvcvar') knots(`e(ln_tvcknots_`tvcvar')') dgen(_d_rcs_`tvcvar') `rmatrixopt'
					forvalues i = 1/`e(df_`tvcvar')' {
						qui replace _rcs_`tvcvar'`i' = _rcs_`tvcvar'`i'*`tvcvar' if `touse'
						qui replace _d_rcs_`tvcvar'`i' = _d_rcs_`tvcvar'`i'*`tvcvar' if `touse'
					}

				}
			}	
		
		}	
		
		//Baseline predictions
		if "`zeros'"!="" {
			foreach var in `e(fixed_varlist)' `e(random_varlist)' `e(tvc)' {
				if `"`: list posof `"`var'"' in at'"' == "0" { 
					qui replace `var' = 0 if `touse'
				}
			}
		}	
		
		//Out of sample predictions using at()
		if "`at'" != "" {
			tokenize `at'
			while "`1'"!="" {
				unab 1: `1'
				cap confirm var `2'
				if _rc {
					cap confirm num `2'
					if _rc {
						di in red "invalid at(... `1' `2' ...)"
						exit 198
					}
				}
				qui replace `1' = `2' if `touse'
				mac shift 2
			}
		}	
		
		//CI option
		if "`ci'"!="" {
			local ciopt "ci(`newvarname'_lci `newvarname'_uci)"
		}
		if "`stdp'"!="" {
			local ciopt "se(`newvarname'_se)"
		}
		
	
	//==================================================================================================================================================//
	// Prediction 
	
		if "`reffects'"!="" | "`reses'"!="" | "`fitted'"!="" {
			
			//need final row per panel indicator var
			tempvar _tempidp finalrowind
			qui egen `_tempidp' = group(`e(panel)')	if e(sample)==1
			qui bys `_tempidp': gen byte `finalrowind' = _n==_N if e(sample)==1
			qui replace `finalrowind' = 0 if `finalrowind'==.
			
			//generate newvars
			if "`fitted'"=="" {
				foreach var in `newvarname' {	
					qui gen double `var' = .	if `touse'==1
				}
				local nameblupvars `newvarname'
			}
			else {
				forvalues i=1/`e(n_re)' {	
					tempvar temp_blups`i'
					qui gen double `temp_blups`i'' = .	if `touse'==1
					local nameblupvars `nameblupvars' `temp_blups`i''
				}			
			}
			
			//get blups
			if "`reses'"!="" local reise reise
			`e(cmdline)' getblups(`nameblupvars') `reise' posttouse(`finalrowind')

			// replicate final row 
			foreach var in `nameblupvars' {	
				qui bys `_tempidp': replace `var' = `var'[_N]	if `touse'==1
			}

			// label variables
			if "`fitted'"=="" {
				if "`reses'"!="" {
					local sd " std. errors"
				}
				local i = 1
				if "`e(random_varlist)'"!="" {
					foreach name in `e(random_varlist)' { 
						local newvar : word `i' of `newvarname'
						label variable `newvar' "BLUP r.e.`sd' for `name'"
						local `++i'
					}
				}
				if "`e(re_nocons)'"=="" {
					local nintvar : word count `newvarname'
					local intvar : word `nintvar' of `newvarname'
					label variable `intvar' "BLUP r.e.`sd' for intercept"	
				}
			}
			
			//fitted requested -> build blups*randomvars
			local i = 1
			foreach var in `e(random_varlist)' {
				local addblups `addblups' + `var' * `: word `i' of `nameblupvars''
				local `++i'
			}
			if "`e(re_nocons)'"=="" {
				local addblups `addblups' + `: word `i' of `nameblupvars''
			}
		}

		//std. error of linear predictor of first ml equation
		if "`stdp'"!="" {
			_predict double `newvarname' if `touse', stdp eq(#1)
        }
	
		//[log] Hazard function
		if "`hazard'"!="" {
			if "`smodel'"=="e" {
				predictnl `newvarname' = xb(ln_lambda) `addblups' if `touse', `ciopt' level(`level')
			}
			else if "`smodel'"=="w" {
				predictnl `newvarname' = xb(ln_lambda) `addblups' + xb(ln_p) + (exp(xb(ln_p))-1)*log(`t') if `touse', `ciopt' level(`level')
			}
			else if "`smodel'"=="gom" {
				predictnl `newvarname' = xb(ln_lambda) `addblups' + xb(gamma)*`t' if `touse', `ciopt' level(`level')
			}
			else if "`smodel'"=="fpm" {
				predictnl `newvarname' = log(xb(dxb)) - log(`t') + xb(xb) `addblups' if `touse', `ciopt' level(`level')
			}
			else if "`smodel'"=="llogistic" {
				predictnl double `newvarname' = 																		/*
				*/ (1/exp(xb(ln_gamma)))*(-(xb(beta)`addblups')) + ((1/exp(xb(ln_gamma)))-1)*log(`t')					/*
				*/ - ( log(exp(xb(ln_gamma))) + 2*log(1+ (exp(-(xb(beta)`addblups'))*`t')^(1/exp(xb(ln_gamma)))) )		/*
				*/ + log(1 + (exp(-(xb(beta)`addblups'))*`t')^(1/exp(xb(ln_gamma))))									/*
				*/ if `touse', `ciopt' level(`level')
			}
			else if "`smodel'"=="lnormal" {
				predictnl double `newvarname' = 																				/*
				*/ -log(`t'*exp(xb(ln_sigma))*sqrt(2*_pi)) - (1/(2*exp(xb(ln_sigma))^2)) * (log(`t')-(xb(mu)`addblups'))^2		/*
				*/ -log( 1-normal((log(`t') - (xb(mu)`addblups'))/exp(xb(ln_sigma))) )											/*
				*/ if `touse', `ciopt' level(`level')
			}
			else if "`smodel'"=="gamma" {
				tempvar sigma kappa
				qui _predict double `sigma' if `touse', xb eq(#2)
				qui replace `sigma'=exp(`sigma') if `touse'
				qui _predict double `kappa' if `touse', xb eq(#3)

                tempvar xb ff z s sgn l
                qui gen double `sgn'=cond(`kappa'<0,-1,1) if `touse'
                qui gen double `l'= (abs(`kappa'))^(-2) if `touse'
                qui _predict double `xb' if `touse', xb `offset' eq(#1)
				if "`fitted'"!="" {
					replace `xb' = `xb' `addblups'
				}
                qui gen double `z'= `sgn'*(ln(`t')-`xb')/ `sigma' if `touse'
                qui gen double `s'= gammap(`l',`l'*exp(`z'/sqrt(`l'))) if `touse'
                qui replace `s'=cond(`sgn'==1,1-`s',`s') if `touse'

                qui gen double `ff'=((`l'-0.5)*ln(`l')) /*
                   */  + (`z'*sqrt(`l'))-`l'*exp(`z'/sqrt(`l')) /*
                   */ -lngamma(`l') - ln(`t'* `sigma') if `touse'
                qui replace `ff'= exp(`ff') if `touse'

                gen double `newvarname'= `ff'/`s' if `touse'
			
			}
		}
		
		//[log(-log())] Survival/cumhazard
		if "`survival'"!="" | "`cumhazard'"!="" {
			if "`smodel'"=="e" {
				predictnl double `newvarname' = xb(ln_lambda) `addblups' + log(`t') if `touse', `ciopt' level(`level')
			}
			else if "`smodel'"=="w" {
				predictnl double `newvarname' = log(exp(xb(ln_lambda)`addblups')*`t'^exp(xb(ln_p))) if `touse', `ciopt' level(`level')
			}
			else if "`smodel'"=="gom" {
				predictnl double `newvarname' = log(exp(xb(ln_lambda)`addblups')/xb(gamma) * (exp(xb(gamma)*`t')-1)) if `touse', `ciopt' level(`level')
			}
			else if "`smodel'"=="fpm" {
				predictnl double `newvarname' = xb(xb) `addblups' if `touse', `ciopt' level(`level')
			}
			else if "`smodel'"=="llogistic" {
				predictnl double `newvarname' = log(log(1 + (exp(-(xb(beta)`addblups'))*`t')^(1/exp(xb(ln_gamma))))) if `touse', `ciopt' level(`level')
			}
			else if "`smodel'"=="lnormal" {
				predictnl double `newvarname' = log(-log(1 - normal((log(`t') - (xb(mu)`addblups'))/exp(xb(ln_sigma))))) if `touse', `ciopt' level(`level')
			}
			else if "`smodel'"=="gamma" {
				tempvar sigma kappa xb ff z
				qui _predict double `sigma' if `touse', xb eq(#2)
				qui replace `sigma'=exp(`sigma') if `touse'
				qui _predict double `kappa' if `touse', xb eq(#3)
				tempvar sgn l
				qui gen double `sgn'=cond( `kappa'<0,-1,1) if `touse'
				qui gen double `l'= (abs(`kappa'))^(-2) if `touse'
				qui _predict double `xb' if `touse', xb `offset' eq(#1)
				if "`fitted'"!="" {
					replace `xb' = `xb' `addblups'
				}				
				qui gen double `z' = `sgn'*(ln(`t')-`xb')/ `sigma' if `touse'
				qui gen double `ff'= gammap(`l',`l'*exp(`z'/sqrt(`l'))) if `touse'
				qui replace `ff'=cond(`sgn'==1,1-`ff',`ff') if `touse'
				gen double `newvarname' = `ff' if `touse'
				if "`cumhazard'"!="" {
					qui replace `newvarname' = -log(`ff') if `touse'
				}
			}		
		}
		
	//==================================================================================================================================================//
	// Restore scale and post vars		
		
		if ("`hazard'"!="" | "`cumhazard'"!="") & "`smodel'"!="gamma" {
			qui replace `newvarname' = exp(`newvarname') if `touse'
			if "`ci'"!="" {
				qui replace `newvarname'_lci = exp(`newvarname'_lci) if `touse'
				qui replace `newvarname'_uci = exp(`newvarname'_uci) if `touse'			
			}		
		}
		
		if "`survival'"!="" & "`smodel'"!="gamma" {
			qui replace `newvarname' = exp(-exp(`newvarname')) if `touse'
			if "`ci'"!="" {
				qui replace `newvarname'_lci = exp(-exp(`newvarname'_lci)) if `touse'
				qui replace `newvarname'_uci = exp(-exp(`newvarname'_uci)) if `touse'
			}		
		}

		//restore original data and merge in new variables 
		if "`hazard'"!="" | "`survival'"!="" | "`cumhazard'"!="" | "`reffects'"!="" | "`reses'"!="" {
			local keep `newvarname'
		}
		if "`ci'" != "" { 
			local keep `keep' `newvarname'_lci `newvarname'_uci
		}
		if "`stdp'"!="" {
			local keep `keep' `newvarname'_se
		}

		keep `keep'
		qui save `newvars'
		restore
		merge 1:1 _n using `newvars', nogenerate noreport
	
end

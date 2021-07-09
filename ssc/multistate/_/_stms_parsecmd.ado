*! version 1.0.0 ??????2015 MJC

// parsing utility 

/*
MJC ?????2015 version 1.0.0
*/

program define _stms_parsecmd, rclass
	syntax [varlist(default=empty numeric)] [if] [in], 							///
														TRANSVAR(varname)		///
														modelindex(string)		///
														model(string)			///	-Distribution family-	
														tousevar(string)		///
																				///
														[						///
															ANCillary(varlist)	///
															ANC2(varlist)		///
																				///
															NOISILY				///
																				///
															*					///	-stpm2 opts-
														]						///
																				///
														
	
	
	
	if "`transvar'"!="" {
		qui gen byte `tousevar' = (`transvar'==`modelindex')
	}
	else {
		mark `tousevar' `if' `in'
	}
	qui replace `tousevar' = 0  if _st==0 | `tousevar'==.
	
	qui count if `tousevar'==1
	if `r(N)'==0 {
		di as error "No obs for transvar == `modelindex'"
		exit 198
	}
	
	//=====================================================================================================================================================//
	// ml eqns
	
	local l = length("`model'")
	if substr("exponential",1,max(1,`l'))=="`model'" {
		local model ereg
		local mleqn (ln_lambda`modelindex': `varlist')	
	}
	else if substr("weibull",1,max(1,`l'))=="`model'" {
		local model weibull
		local mleqn (ln_lambda`modelindex': `varlist')(ln_gamma`modelindex': `ancillary')
	}
	else if substr("gompertz",1,max(1,`l'))=="`model'" {
		local model gompertz
		local mleqn (ln_lambda`modelindex': `varlist')(gamma`modelindex': `ancillary')
	}
	else if substr("llogistic",1,max(2,`l'))=="`model'" | substr("loglogistic",1,max(4,`l'))=="`model'" {
		local model llogistic
		local mleqn (ln_lambda`modelindex': `varlist')(gamma`modelindex': `ancillary')
	}	
	else if substr("lnormal",1,max(2,`l'))=="`model'" | substr("lognormal",1,max(4,`l'))=="`model'" {
		local model lnormal
		local mleqn (mu`modelindex': `varlist')(ln_sigma`modelindex': `ancillary')
	}
	else if substr("ggamma",1,max(2,`l'))=="`model'" {
		local model gamma
		local mleqn (mu`modelindex': `varlist')(ln_sigma`modelindex': `ancillary')(kappa`modelindex': `anc2')
	}
	else if "fpm"=="`model'" {
	}
	else {
		di as error "Unknown model(`model')"
		exit 198	
	}
	
	if "fpm"!="`model'" {
		qui `noisily' streg `varlist' if `tousevar'==1, dist(`model') ancillary(`ancillary') anc2(`anc2')
		tempname inits
		mat `inits' = e(b)
		return matrix inits = `inits'
	}
	else {
		local model stpm2
		qui `noisily' stpm2 `varlist' if `tousevar'==1, `options'
		tempname inits
		mat `inits' = e(b)
		return matrix inits = `inits'
		
		//stuff for eret list for tprob
		c_local nocons`modelindex' `e(noconstant)'
		c_local orthog`modelindex' `e(orthog)'
		c_local scale`modelindex' `e(scale)'
		c_local rcsbaseoff`modelindex' `e(rcsbaseoff)'
		c_local rcsterms_base`modelindex' `e(rcsterms_base)'
		c_local ln_bhknots`modelindex' `e(ln_bhknots)'
		c_local boundary_knots`modelindex' `e(boundary_knots)'
		if "`e(orthog)'"=="orthog" {
			tempname rbhtemp
			mat `rbhtemp' = e(R_bh)
			return matrix R_bh`modelindex' = `rbhtemp'
		}
		c_local tvc`modelindex' `e(tvc)'
		foreach var in `e(tvc)' {
		
			c_local boundary_knots_`var'`modelindex' `e(boundary_knots_`var')'
			c_local ln_tvcknots_`var'`modelindex' `e(ln_tvcknots_`var')'
			if "`e(orthog)'"=="orthog" {
				tempname rbhtemp`var'
				mat `rbhtemp`var'' = e(R_`var')
				return matrix R_`var'`modelindex' = `rbhtemp`var''
			}
			
		}
		//
		cap drop _`modelindex'_rcs?
		rename _rcs? _`modelindex'_rcs?, r
		local newrcs `r(newnames)'
		cap drop _`modelindex'_d_rcs?
		rename _d_rcs? _`modelindex'_d_rcs?, r
		local newdrcs `r(newnames)'
		if `e(del_entry)' {
			cap drop _`modelindex'_s0_rcs?
			rename _s0_rcs? _`modelindex'_s0_rcs?, r
			local news0rcs `r(newnames)'
		}
		
		//handle constraints
		local index = 1
		foreach con in `e(rcsterms_base)' {
			constraint free
			constraint `r(free)' [xb`modelindex'][_`modelindex'_rcs`index']=[dxb`modelindex'][_`modelindex'_d_rcs`index']
			local conslist `conslist' `r(free)'
			if `e(del_entry)' {
				constraint free
				constraint `r(free)' [xb`modelindex'][_`modelindex'_rcs`index']=[xb0`modelindex'][_`modelindex'_s0_rcs`index']
				local conslist `conslist' `r(free)'
			}	
			local index = `index' +1
		}
		foreach var in `e(tvc)' {
			cap drop _`modelindex'_rcs_`var'?
			rename _rcs_`var'? _`modelindex'_rcs_`var'?, r
			local newrcs `newrcs' `r(newnames)'
			cap drop _`modelindex'_d_rcs_`var'?
			rename _d_rcs_`var'? _`modelindex'_d_rcs_`var'?, r
			local newdrcs `newdrcs' `r(newnames)'
			if `e(del_entry)' {
				cap drop _`modelindex'_s0_rcs_`var'?
				rename _s0_rcs_`var'? _`modelindex'_s0_rcs_`var'?, r
				local news0rcs `news0rcs' `r(newnames)'
			}
			local index = 1
			foreach con in `e(rcsterms_`var')' {
				constraint free
				constraint `r(free)' [xb`modelindex'][_`modelindex'_rcs_`var'`index']=[dxb`modelindex'][_`modelindex'_d_rcs_`var'`index']
				local conslist `conslist' `r(free)'
				if `e(del_entry)' {
					constraint free
					constraint `r(free)' [xb`modelindex'][_`modelindex'_rcs_`var'`index']=[xb0`modelindex'][_`modelindex'_s0_rcs_`var'`index']
					local conslist `conslist' `r(free)'
				}	
				local index = `index' +1
			}
		}
		
		local mleqn (xb`modelindex': `varlist' `newrcs')(dxb`modelindex': `newdrcs',nocons)

		if `e(del_entry)' {
			constraint free
			constraint `r(free)' [xb`modelindex'][_cons]=[xb0`modelindex'][_cons]
			local conslist `conslist' `r(free)'
			
			//covariate constraints with delentry
			foreach var in `e(varlist)' {
				constraint free
				constraint `r(free)' [xb`modelindex'][`var']=[xb0`modelindex'][`var']
				local conslist `conslist' `r(free)'
			}

			local mleqn `mleqn'(xb0`modelindex': `varlist' `news0rcs')

		}
		
		
	}

	
	return local model `model'
	return local mleqn `mleqn'
	return local transmatrix `transmatrix'
	return local constraints `conslist'
	return local varlist `varlist'
	return local ancillary `ancillary'
	return local anc2 `anc2'

end

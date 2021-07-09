
program predictms_stms_model, rclass
	syntax [, TRANS(string) MODEL(string) BMAT(string) at(string) ind(string) ]
		
	tempname bmat`trans' dm indices
	
	if "`model'"=="ereg" {
		local model ereg
		mat `bmat`trans'' = `bmat'[1,"ln_lambda`trans':"]
	}
	else if "`model'"=="weibull" {
		mat `bmat`trans'' = `bmat'[1,"ln_lambda`trans':"],`bmat'[1,"ln_gamma`trans':"]
	}
	else if "`model'"=="gompertz" {
		mat `bmat`trans'' = `bmat'[1,"ln_lambda`trans':"],`bmat'[1,"gamma`trans':"]
	}
	else if "`model'"=="llogistic" {
		mat `bmat`trans'' = `bmat'[1,"ln_lambda`trans':"],`bmat'[1,"gamma`trans':"]
	}
	else if "`model'"=="lnormal" {
		mat `bmat`trans'' = `bmat'[1,"mu`trans':"],`bmat'[1,"ln_sigma`trans':"]
	}
	else if "`model'"=="gamma" {
		mat `bmat`trans'' = `bmat'[1,"mu`trans':"],`bmat'[1,"ln_sigma`trans':"],`bmat'[1,"kappa`trans':"]
	}
	else if "`model'"=="stpm2" {
		mat `bmat`trans'' = `bmat'[1,"xb`trans':"]
		tempname bmat2`trans'
		mat `bmat2`trans'' = `bmat`trans'',`bmat'[1,"dxb`trans':"],nullmat(`bmat'[1,"xb0`trans':"])
		local Nparams2 = colsof(`bmat2`trans'')
		return local Nparams2 = `Nparams2'
	}
	
	local Nparams = colsof(`bmat`trans'')
	return local Nparams = `Nparams'
	
	local varlist `e(varlist`trans')'
	local ancillary `e(ancillary`trans')'
	local anc2 `e(anc2`trans')'
	
	if "`model'"!="stpm2" {
		
		mat `dm' = J(1,`Nparams',0)
		
		local colindex = 1
		foreach corevar in `varlist' {
			tokenize `at'
			while "`1'"!="" {
				unab 1: `1'
				if "`corevar'"=="`1'" {
					mat `dm'[1,`colindex'] = `2'
				}
				mac shift 2
			} 
			local colindex = `colindex' + 1
		}
		if "`e(noconstant`trans')'"=="" {
			mat `dm'[1,`colindex'] = 1
			local colindex = `colindex' + 1
		}
		
		if "`model'"!="ereg" {
			local Nmleqns = 2
			foreach corevar in `ancillary' {
				tokenize `at'
				while "`1'"!="" {
					unab 1: `1'
					if "`corevar'"=="`1'" {
						mat `dm'[1,`colindex'] = `2'
					}
					mac shift 2
				} 
				local colindex = `colindex' + 1
			}
			mat `dm'[1,`colindex'] = 1
			local colindex = `colindex' + 1
				
			if "`model'"=="gamma" {
				local Nmleqns = 3
				foreach corevar in `anc2' {
					tokenize `at'
					while "`1'"!="" {
						unab 1: `1'
						if "`corevar'"=="`1'" {
							mat `dm'[1,`colindex'] = `2'
						}
						mac shift 2
					} 
					local colindex = `colindex' + 1
				}
				mat `dm'[1,`colindex'] = 1
			}
			
			//indices
			mat `indices' = J(2,`Nmleqns',1)
			local colindex = 1
			foreach corevar in `varlist' {
				local colindex = `colindex' + 1
			}
			if "`noconstant'"=="" {
				local colindex = `colindex' + 1
			}
			mat `indices'[2,1] = `colindex' - 1
			mat `indices'[1,2] = `colindex'
			if `Nmleqns'==3 {
				foreach corevar in `ancillary' {
					local colindex = `colindex' + 1
				}
				local colindex = `colindex' + 1
				mat `indices'[2,2] = `colindex'-1
				mat `indices'[1,3] = `colindex'
			}
			mat `indices'[2,`Nmleqns'] = `Nparams'
			
			return matrix indices = `indices'
		}
		
		return matrix dm = `dm'		
	}
	else if "`model'"=="stpm2" {
	
		//DM is only for varlist, tvc splines and base splines are handled separately
		local Ncovs : word count `varlist'
		c_local Ncovs`trans' `Ncovs'
		c_local nocons`trans' `e(noconstant`trans')'
		c_local orthog`trans' `e(orthog`trans')'
		c_local scale`trans' `e(scale`trans')'
		
		//overall design matrix for each transition, stacked
		if `Ncovs' > 0 {
			tempname dm 
			mat `dm' = J(1,`Ncovs',0)
			//now update DM and indices
			//can match variables in trans#() with varlist and ancillary
			local colindex = 1
			foreach corevar in `varlist' {
				tokenize `at'
				while "`1'"!="" {
					unab 1: `1'
					if "`corevar'"=="`1'" {
						mat `dm'[1,`colindex'] = `2'
					}
					mac shift 2
				} 
				local colindex = `colindex' + 1
			}
			return matrix dm = `dm'
		}
		
		c_local rcsbaseoff`trans' `e(rcsbaseoff`trans')'
		if "`e(rcsbaseoff`trans')'"=="" {
			local Nsplines : word count `e(rcsterms_base`trans')'
			c_local ln_bknots`trans' `e(ln_bhknots`trans')'										//all log baseline knots including boundary knots
			if "`e(ln_bhknots`trans')'"=="" {	//this is empty when df(1)
				c_local ln_bknots`trans' `=log(`: word 1 of `e(boundary_knots`trans')'')' `=log(`: word 2 of `e(boundary_knots`trans')'')'
			}
			if "`e(orthog`trans')'"=="orthog" {
				tempname rmat
				matrix `rmat' = e(R_bh`trans')
				return matrix rmat = `rmat'
			}			
		}
				
		c_local tvc`trans' `e(tvc`trans')'
		if "`e(tvc`trans')'"!="" {
			local i = 1
			foreach tvcvar in `e(tvc`trans')' {
				local boundary_knots_`i' `e(boundary_knots_`tvcvar'`trans')'
				local ln_tvcknots`trans'_`i' `e(ln_tvcknots_`tvcvar'`trans')'
				if "`ln_tvcknots`trans'_`i''"=="" {
					local ln_tvcknots`trans'_`i' `=log(`: word 1 of `boundary_knots_`i''')' `=log(`: word 2 of `boundary_knots_`i''')'
				}				
				if "`e(orthog`trans')'"=="orthog" {
					tempname R_`i'
					mat `R_`i'' = e(R_`tvcvar'`trans')
					return matrix R_`i' = `R_`i''
				}
				c_local ln_tvcknots`trans'_`i' `ln_tvcknots`trans'_`i''
				local i = `i' + 1
			}
			local Ntvcvars = `i' - 1
			c_local Ntvcvars`trans' = `Ntvcvars'

			//tvc DM
			tempname dmtvc
			mat `dmtvc' = J(1,`Ntvcvars',0)
			local colindex = 1
			foreach corevar in `e(tvc`trans')' {
				tokenize `at'
				while "`1'"!="" {
					unab 1: `1'
					if "`corevar'"=="`1'" {
						mat `dmtvc'[1,`colindex'] = `2'
					}
					mac shift 2
				} 
				local colindex = `colindex' + 1
			}
			
			return matrix dmtvc = `dmtvc'
		}
	
	}

end


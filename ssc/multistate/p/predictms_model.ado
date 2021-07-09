
program predictms_model, rclass
	syntax [, TRANS(string) NPARAMS(string) Ntrans(real 1) AT(string) STD  out(real 0) aind(string)]
	
	local cmdname "`e(cmd)'"
	if `aind'==1 {
		c_local cmdname `cmdname'
	}

	if "`e(cmd2)'"=="streg" {
		
		//design matrix for transition
		tempname dm indices
		mat `dm' = J(1,`nparams',0)
	
		if "`e(cmd)'"=="ereg" {						//!! don't need index for exp
			
			local cmdline `e(cmdline)'
			gettoken cmd 0 : cmdline
			if `out' {
				syntax [anything(everything)],  [NOCONstant *]
				//strip off if and in
				local t1 = strpos("`anything'"," if ")
				if `t1' local anything = substr("`anything'",1,`t1')
				local t1 = strpos("`anything'"," in ")
				if `t1' local anything = substr("`anything'",1,`t1')
				local varlist `anything'
			}
			else {
				syntax [varlist(default=empty)] [if] [in], [NOCONstant *]	
			}

			//now update DM and indices
			local colindex = 1
			foreach corevar in `varlist' {
				local inat = 0
				predictms_atparse, 	corevar(`corevar') colindex(`colindex') dmmat(`dm') 		///
							i(`trans') ntrans(`ntrans') at(`at') out(`out')
				local inat = r(inat)
				local todrop `todrop' `r(todrop)'
				if !`inat' & "`std'"!="" {
					predictms_stdparse `corevar' `trans' `ntrans'
					if r(include) {
						local stdvars `stdvars' `r(stdvar)'
						local stdvarsindex `stdvarsindex' `colindex'
					}
				}
				local colindex = `colindex' + 1
			}
			if "`noconstant'"=="" {
				mat `dm'[1,`colindex'] = 1
			}
	
		}
		else {
			
			local isgamma = "`e(cmd)'"=="gamma"
			local Nmleqns = 2
			if `isgamma' {
				local Nmleqns = 3
			}
			local cmdline `e(cmdline)'
			gettoken cmd 0 : cmdline
			
			if `out' {
				syntax [anything(everything)],  [NOCONstant ANCillary(varlist) ANC2(varlist) *]	
				//strip off if and in
				local t1 = strpos("`anything'"," if ")
				if `t1' local anything = substr("`anything'",1,`t1')
				local t1 = strpos("`anything'"," in ")
				if `t1' local anything = substr("`anything'",1,`t1')
				local varlist `anything'
			}
			else {
				syntax [varlist(default=empty)] [if] [in], [NOCONstant ANCillary(varlist) ANC2(varlist) *]	
			}
			local corevars1 `varlist'		
			local corevars2 `ancillary'
			local corevars3 `anc2'
			
			//now update DM and indices
			//can match variables in at() with varlist and ancillary
			local colindex = 1
			foreach corevar in `corevars1' {
				local inat = 0
				predictms_atparse, 	corevar(`corevar') colindex(`colindex') dmmat(`dm') 		///
							i(`trans') ntrans(`ntrans') at(`at') out(`out')
				local inat = r(inat)
				local todrop `todrop' `r(todrop)'
				if !`inat' & "`std'"!="" {
					predictms_stdparse `corevar' `trans' `ntrans'
					if r(include) {
						local stdvars `stdvars' `r(stdvar)'
						local stdvarsindex `stdvarsindex' `colindex'
					}
				}
				local colindex = `colindex' + 1
			}
			if "`noconstant'"=="" {
				mat `dm'[1,`colindex'] = 1
				local colindex = `colindex' + 1
			}
			foreach corevar in `corevars2' {
				local inat = 0
				predictms_atparse, 	corevar(`corevar') colindex(`colindex') dmmat(`dm') 		///
							i(`trans') ntrans(`ntrans') at(`at') out(`out')
				local inat = r(inat)
				local todrop `todrop' `r(todrop)'
				if !`inat' & "`std'"!="" {
					predictms_stdparse `corevar' `trans' `ntrans'
					if r(include) {
						local stdvars `stdvars' `r(stdvar)'
						local stdvarsindex `stdvarsindex' `colindex'
					}
				}
				local colindex = `colindex' + 1
			}
			mat `dm'[1,`colindex'] = 1
			local colindex = `colindex' + 1
			
			if `isgamma' {
				foreach corevar in `corevars3' {
					local inat = 0
					predictms_atparse, 	corevar(`corevar') colindex(`colindex') dmmat(`dm') 		///
								i(`trans') ntrans(`ntrans') at(`at') out(`out')
					local inat = r(inat)
					local todrop `todrop' `r(todrop)'
					if !`inat' & "`std'"!="" {
						predictms_stdparse `corevar' `trans' `ntrans'
						if r(include) {
							local stdvars `stdvars' `r(stdvar)'
							local stdvarsindex `stdvarsindex' `colindex'
						}
					}
					local colindex = `colindex' + 1
				}
				mat `dm'[1,`colindex'] = 1			
			}
			
			//indices
			if `aind'==1 {
				mat `indices' = J(2,`Nmleqns',1)
				local colindex = 1
				foreach corevar in `corevars1' {
					local colindex = `colindex' + 1
				}
				if "`noconstant'"=="" {
					local colindex = `colindex' + 1
				}
				mat `indices'[2,1] = `colindex' - 1
				
				mat `indices'[1,2] = `colindex'
				foreach corevar in `corevars2' {
					local colindex = `colindex' + 1
				}
				local colindex = `colindex' + 1
				mat `indices'[2,2] = `colindex' - 1
				if `isgamma' {
					mat `indices'[1,3] = `colindex'
					foreach corevar in `corevars3' {
						local colindex = `colindex' + 1
					}
					local colindex = `colindex' + 1
					mat `indices'[2,3] = `colindex' - 1
				}
				
				return matrix indices = `indices'
			}
		}
		return matrix dm = `dm'
	}
	else if "`e(cmd)'"=="stpm2" | "`e(cmd)'"=="strcs" {
	
		//DM is only for varlist, tvc splines and base splines are handled separately
		local corevars `e(varlist)'
		local Ncovs : word count `corevars'
		if `aind'==1 {
			c_local Ncovs`trans' `Ncovs'
			c_local nocons`trans' `e(noconstant)'
			c_local orthog`trans' `e(orthog)'
			c_local scale`trans' `e(scale)'
			c_local bhazard`trans' `e(bhazard)'
		}
		
		//design matrix 
		if `Ncovs' > 0 {
			tempname dm 
			mat `dm' = J(1,`Ncovs',0)
			//now update DM and indices
			//can match variables in at() with varlist and ancillary
			local colindex = 1
			foreach corevar in `corevars' {
				local inat = 0
				predictms_atparse, 	corevar(`corevar') colindex(`colindex') dmmat(`dm') 		///
							i(`trans') ntrans(`ntrans') at(`at') out(`out')
				local inat = r(inat)
				local todrop `todrop' `r(todrop)'
				if !`inat' & "`std'"!="" {
					predictms_stdparse `corevar' `trans' `ntrans'
					if r(include) {
						local stdvars `stdvars' `r(stdvar)'
						local stdvarsindex `stdvarsindex' `colindex'
					}
				}
				local colindex = `colindex' + 1
			}
			return matrix dm = `dm'
		}
		
		if `aind'==1 {
			c_local rcsbaseoff`trans' `e(rcsbaseoff)'
			if "`e(rcsbaseoff)'"=="" {
				local Nsplines : word count `e(rcsterms_base)'
				if "`e(cmd)'"=="stpm2" {
					local ln_bknots`trans' `e(ln_bhknots)'										//all log baseline knots including boundary knots
					if "`ln_bknots`trans''"=="" {	//this is empty when df(1)
						local ln_bknots`trans' `=log(`: word 1 of `e(boundary_knots)'')' `=log(`: word 2 of `e(boundary_knots)'')'
					}
				}
				else {
					local ln_bknots`trans' `e(bhknots)'										//all log baseline knots including boundary knots
					if "`ln_bknots`trans''"=="" {	//this is empty when df(1)
						local ln_bknots`trans' -5 10 //fudge - these values are not used
					}
				}
				c_local ln_bknots`trans' `ln_bknots`trans''
				if "`e(orthog)'"=="orthog" {
					tempname rmat
					matrix `rmat' = e(R_bh)
					return matrix rmat = `rmat'
				}			
			}
					
			c_local tvc`trans' `e(tvc)'
		}
		
		if "`e(tvc)'"!="" {
		
			local i = 1
			foreach tvcvar in `e(tvc)' {
				local boundary_knots_`i' `e(boundary_knots_`tvcvar')'
				if "`e(cmd)'"=="stpm2" {
					local ln_tvcknots`trans'_`i' `e(ln_tvcknots_`tvcvar')'									//all log baseline knots including boundary knots
					if "`ln_tvcknots`trans'_`i''"=="" {	//this is empty when df(1)
						local ln_tvcknots`trans'_`i' `=log(`: word 1 of `e(boundary_knots_`tvcvar')'')' `=log(`: word 2 of `e(boundary_knots_`tvcvar')'')'
					}
				}
				else {
					local ln_tvcknots`trans'_`i' `e(tvcknots_`tvcvar')'											//all log baseline knots including boundary knots
					if "`ln_tvcknots`trans'_`i''"=="" {	//this is empty when df(1)
						local ln_tvcknots`trans'_`i' -5 10 //fudge - these values are not used
					}
				}
				if "`e(orthog)'"=="orthog" {
					tempname R_`i'
					mat `R_`i'' = e(R_`tvcvar')
					return matrix R_`i' = `R_`i''
				}
				if `aind'==1 {
					c_local ln_tvcknots`trans'_`i' `ln_tvcknots`trans'_`i''
				}
				local i = `i' + 1
			}
			local Ntvcvars = `i' - 1
			if `aind'==1 {
				c_local Ntvcvars`trans' = `Ntvcvars'
			}
			
			//tvc DM
			tempname dmtvc
			mat `dmtvc' = J(1,`Ntvcvars',0)
			local colindex = 1
			foreach corevar in `e(tvc)' {
				local inat = 0
				predictms_atparse, 	corevar(`corevar') colindex(`colindex') dmmat(`dmtvc') 		///
							i(`trans') ntrans(`ntrans') at(`at') out(`out')
				local inat = r(inat)
				local todrop `todrop' `r(todrop)'
				if !`inat' & "`std'"!="" {
					predictms_stdparse `corevar' `trans' `ntrans'
					if r(include) {
						local tvcstdvars `tvcstdvars' `r(stdvar)'
						local tvcstdvarsindex `tvcstdvarsindex' `colindex'
					}
				}
				local colindex = `colindex' + 1
			}
			return local tvcstdvars `tvcstdvars'
			return local tvcstdvarsindex `tvcstdvarsindex'
			return matrix dmtvc = `dmtvc'
		}
	
	}
	else if "`e(cmd)'"=="merlin" {
	
		local varlist `e(allvars)'
		tempname dm 
		local nv : word count `varlist'
		mat `dm' = J(1,`nv',0)
		
		local colindex = 1
		foreach corevar in `varlist' {
			local inat = 0
			predictms_atparse, 	corevar(`corevar') colindex(`colindex') 	///
								at(`at') out(`out') ntrans(`ntrans') dmmat(`dm')
			local inat = r(inat)
			local todrop `todrop' `r(todrop)'
			if !`inat' & "`std'"!="" {
				predictms_stdparse `corevar' `trans' `ntrans'
				if r(include) {
					local stdvars `stdvars' `r(stdvar)'
				}
			}
			local colindex = `colindex' + 1
		}
	
	}
	
	return local stdvars `stdvars'
	return local stdvarsindex `stdvarsindex'
	return local todrop `todrop'

end


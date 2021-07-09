
program predictms_model_at2, rclass
	syntax [, MODEL(string) TRANS(string) Ntrans(real 1) NPARAMS(string) AT(string) STD out(real 0)]

	tempname dm
	
	local varlist `e(varlist)'

	if "`model'"!="stpm2" & "`model'"!="strcs" {
		
		mat `dm' = J(1,`nparams',0)
	
		local cmdline `e(cmdline)'
		gettoken cmd 0 : cmdline
		
		if `out' {
			syntax [anything(everything)], [NOCONstant ANCillary(varlist) ANC2(varlist) *]
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
			local colindex = `colindex' + 1
		}
		
		if "`model'"!="ereg" {
			local Nmleqns = 2
			foreach corevar in `ancillary' {
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

			if "`model'"=="gamma" {
				local Nmleqns = 3
				foreach corevar in `anc2' {
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
			
		}
		
		return matrix dm = `dm'		
	}
	else if "`model'"=="stpm2" | "`model'"=="strcs" {
	
		//DM is only for varlist, tvc splines and base splines are handled separately
		local Ncovs : word count `varlist'

		if `Ncovs' > 0 {
			tempname dm 
			mat `dm' = J(1,`Ncovs',0)
			//now update DM and indices
			//can match variables in trans#() with varlist and ancillary
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
			return matrix dm = `dm'
		}
				
		if "`e(tvc)'"!="" {
			local Ntvcvars : word count `e(tvc)'
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

	return local stdvars `stdvars'
	return local stdvarsindex `stdvarsindex'

end


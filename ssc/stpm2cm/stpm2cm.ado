*! Version 1.0 30Jun2011

program define stpm2cm
	version 10.0
	syntax using/ , [AT(string) MERGEBY(string) DIAGAge(int 50) DIAGYear(int 1990) SEX(int 1) ATTAge(name) ///
						ATTyear(name) MAXAge(int 99) Nobs(int 1000) CI MAXT(real 10) STUB(string) TGEN(name) ///
						MERGEGEN(string) ADDLHR(real 0) survprob(name)]

									
/* Other merge variables - Check this is done using mergegen */									
	
	/* Error checks */
	if "`stub'" == "" {
		di as error "You must use the stub option."
		exit 198
	}

	if "`e(cmd)'" != "stpm2" {
		di as error "You can only use stpm2cm after fitting an stpm2 model."
		exit 198
	}

	
	if "`e(bhazard)'" == "" {
		di as error "You can only use stpm2cm after fitting a relative survival model."
		exit 198
	}
	
	
	tempvar id age yydx failure time St_star rate lnt lambda
	tempfile ind
	preserve
	clear
	qui set obs 1
	qui gen `id' = _n
	qui gen `age' = `diagage'
	qui gen sex = `sex'
	qui gen `yydx' = `diagyear'
	qui gen `failure' = 0
	qui gen `time' = `maxt'
	local atstep = `maxt'/`nobs'
	if "`attyear'" == "" {
		local attyear _year
	}
	if "`attage'" == "" {
		local attage _age
	}
	
	if "`mergegen'" != "" {
		tokenize `mergegen'
		while "`1'"!="" {
			qui gen `1' = `2'
			mac shift 2
		}
	}

	if "`survprob'" == "" {
		local survprob prob
	}
	
	
	qui stset `time', failure(`failure' = 1) id(`id')	
	qui strs using 	"`using'", br(0(`atstep')`maxt') mergeby(`mergeby') diagage(`age') diagyear(`yydx') ///
					 savind(`ind', replace) attage(`attage') attyear(`attyear') maxage(`maxage') notables ///
					 survprob(`survprob')

	qui use `ind', clear
	
	qui gen double `St_star' = exp(sum(ln(p_star))) 
	qui gen double `rate' = -ln(p_star)/`atstep'
	keep end `St_star' `age' `rate'

	rename end _t
	qui gen double  `lnt' = ln(_t)

	/* Out of sample predictions using at() */
	if "`at'" != "" {
		tokenize `at'
		while "`1'"!="" {
			qui gen `1' = `2'
			mac shift 2
		}
	}

	if "`e(orthog)'" != "" {
		tempname R
		matrix `R' = e(R_bh)
		local rmatrix rmatrix(`R')
	}

	qui rcsgen `lnt', knots(`e(ln_bhknots)') gen(_rcs) dgen(_d_rcs) `rmatrix' 	
				 
	*GENERATE OTHER SPLINES*/
	foreach tvcvar in `e(tvc)' {
		if "`e(orthog)'" != "" {
			matrix `R' = e(R_`tvcvar')
			local rmatrix rmatrix(`R')
		}
		qui rcsgen `lnt', knots(`e(ln_tvcknots_`tvcvar')') gen(_rcs_`tvcvar') dgen(_d_rcs_`tvcvar') `rmatrix'
		forvalues	 i = 1/`e(df_`tvcvar')' {
			qui replace _rcs_`tvcvar'`i' = _rcs_`tvcvar'`i'*`tvcvar'
			qui replace _d_rcs_`tvcvar'`i' = _d_rcs_`tvcvar'`i'*`tvcvar'
		}
	}
	if "`ci'" != "" {
		local g1 g(_d1)
		local g2 g(_d2)
	}
	
	qui predictnl double St_starXft = (1/_t) * xb(dxb)*exp(xb(xb)+`addlhr'-exp(xb(xb)+`addlhr'))*`St_star', ///
			`g1' force
			
	qui predictnl double RtXS_starXlambda_star = exp(-exp(xb(xb)+`addlhr'))*`St_star'*`rate', `g2' force 
	
	qui predict double lambda , hazard 
	
	qui predictnl double s_all = exp(-exp(xb(xb)+`addlhr'))*`St_star', force
	
	if "`ci'" != "" {
		unab d1: _d1*
		unab d2: _d2*
		foreach var in `d1' {
			local add = subinstr("`var'","_d1","",1)
			local d1coeffnum `d1coeffnum' `add'
		}
		foreach var in `d2' {
			local add = subinstr("`var'","_d2","",1)
			local d2coeffnum `d2coeffnum' `add'
		}
	}
	
	mata: genci("`stub'")

	if "`ci'" != "" {
		qui gen `stub'_d_uci = `stub'_d + 1.96*sqrt(`stub'_d_var)
		qui gen `stub'_d_lci = `stub'_d - 1.96*sqrt(`stub'_d_var)
		qui gen `stub'_o_uci = `stub'_o + 1.96*sqrt(`stub'_o_var)
		qui gen `stub'_o_lci = `stub'_o - 1.96*sqrt(`stub'_o_var)
	}

	qui gen `stub'_all = `stub'_d + `stub'_o
	qui gen `stub'_s_all = s_all
	
	keep `stub'* _t lambda `rate'  `St_star' RtXS_starXlambda_star
	rename _t `tgen'
	rename lambda `stub'_lambda
	rename `rate' `stub'_rate
	rename `St_star' `stub'_St_star
	
	tempfile ci_res
	qui save `ci_res'

	restore
	tempname merge
	qui merge using `ci_res', _merge(`merge')
end

	mata: 
	void genci(string scalar stub)
	{
		if (st_local("ci") != "") {
			g1 = st_data(.,tokens(st_local("d1")))
			g2 = st_data(.,tokens(st_local("d2")))
			V = st_matrix("e(V)")
		}
		St_starXft = st_data(.,"St_starXft")
		RtXS_starXlambda_star = st_data(.,"RtXS_starXlambda_star")
		L = lowertriangle(J(strtoreal(st_local("nobs")),
							strtoreal(st_local("nobs")),
							strtoreal(st_local("atstep"))),
							0.5*strtoreal(st_local("atstep")))
		L[,1] = L[,1]:/2
		(void) st_addvar("double",stub+"_d")
		st_store(., stub+"_d", L*St_starXft)

		(void) st_addvar("double",stub+"_o")
		st_store(., stub+"_o", L*RtXS_starXlambda_star)

		if (st_local("ci") != "") {
			(void) st_addvar("double",stub+"_d_var") 

			
			Vindex = strtoreal(tokens(st_local("d1coeffnum")))
			st_store(., stub+"_d_var", diagonal(L*g1*V[Vindex,Vindex]*g1'*L'))
			(void) st_addvar("double",stub+"_o_var") 
			Vindex = strtoreal(tokens(st_local("d2coeffnum")))
			st_store(., stub+"_o_var",diagonal(L*g2*V[Vindex,Vindex]*g2'*L'))
		}
		

	}
	end

*! mixlogitwtp 1.1.0 29Mar2016
*! author arh

*  1.1.0:	a bug that could affect the estimation results in the case of 
*			extreme parameter values during the iterations has been fixed

program mixlogitwtp
	version 11.1
	if replay() {
		if (`"`e(cmd)'"' != "mixlogitwtp") error 301
		Replay `0'
	}
	else	Estimate `0'
end

program Estimate, eclass
	syntax varlist [if] [in] 		///
		[pweight iweight],			///
		GRoup(varname) 				///
		PRICE(varname) [			///
		RAND(varlist) 				///		
		ID(varname) 				///
		LN(integer 0) 				///
		CORR						///
		NREP(integer 50)			///
		BURN(integer 15)			///
		FRom(string)				/// 
		Level(integer `c(level)')	///
		USERdraws					///		
		TRace						///
		GRADient					///
		HESSian						///
		SHOWSTEP					///
		ITERate(passthru)			///
		TOLerance(passthru)			///
		LTOLerance(passthru)		///
		GTOLerance(passthru)		///
		NRTOLerance(passthru)		///
		CONSTraints(passthru)		///
		TECHnique(passthru)			///
		DIFficult					///
		VCE(passthru)				///		
		COLL						///		
	]

	local mlopts `trace' `gradient' `hessian' `showstep' `iterate' `tolerance' 	///
	`ltolerance' `gtolerance' `nrtolerance' `constraints' `technique' 			///
	`difficult' `vce'

	local randnop `rand'
	local rand `rand' `price'
	local ln = `ln' + 1
	
	if ("`search'" != "") {
		local search
		set seed `seed'
	}
	else local search search(off)
	
	** Check that group and id variables are numeric **
	capture confirm numeric var `group'
	if _rc != 0 {
		di in r "The group variable must be numeric"
		exit 498
	}
	if ("`id'" != "") {
		capture confirm numeric var `id'
		if _rc != 0 {
			di in r "The id variable must be numeric"
			exit 498
		}
	}

	** Create local wgt for use with clogit if weights are specified **
	if ("`weight'" != "") local wgt "[`weight'`exp']"

	** Mark the estimation sample **
	marksample touse
	markout `touse' `group' `rand' `id' `cluster'

	** Check that no variables have been specified to have both fixed and random coefficients **
	gettoken lhs fixed : varlist
	local k1 : word count `fixed'
	local k2 : word count `rand' 
	local k12 = `k1'+`k2'
	
	if (`k12' == 0) {
		di in red "No explanatory variables have been specified"
		exit 498
	}
	forvalues i = 1(1)`k1' {
		forvalues j = 1(1)`k2' {
			local w1 : word `i' of `fixed' 
			local w2 : word `j' of `rand'
			if ("`w1'" == "`w2'") {
				di in red "The variable `w1' is specified to have both fixed and random coefficients"
				exit 498
			} 	
		}
	}

	** Check that starting values are specified with the constraints option **
	if ("`constraints'" != "" & "`from'" == "") {
		di in red "When constraints are specified it is compulsory to supply starting values using the from option"
		exit 498
	}

	** Check that starting values are specified with the coll option **
	if ("`coll'" != "" & "`from'" == "") {
		di in red "When the coll option is specified it is compulsory to supply starting values using the from option"
		exit 498
	}

	** Check for multicollinearity **
	local rhs `fixed' `rand'
	if ("`coll'" == "") {
		qui _rmcoll `rhs' 
		if ("`r(varlist)'" != "`rhs'" & "`constraints'" != "") {
			di in gr "Some variables are collinear - make sure this is intended, i.e. because you are"
			di in gr "estimating an error-components model with the necessary constraints imposed"
		}
		if ("`r(varlist)'" != "`rhs'" & "`constraints'" == "") {
			di in red "Some variables are collinear - check your model specification"
			exit 498
		}
	}
	
	** Estimate conditional logit model - if constraints or the coll option are specified this is simply to set estimation sample **
	if ("`constraints'" == "" & "`coll'" == "") {
		qui clogit `lhs' `rhs' if `touse' `wgt', group(`group')
		local nobs = e(N)
		local ll = e(ll)
		local k  = e(k)
		qui replace `touse' = e(sample)
	}
	else {
		qui clogit `lhs' `rhs' if `touse' `wgt', group(`group') iter(0)
		local nobs = e(N)
		qui replace `touse' = e(sample)
	}

	** Drop missing data **
	preserve
	qui keep if `touse'
	
	** Check that the independent variables vary within groups **
	sort `group'
	foreach var of varlist `rhs' {
		capture by `group': assert `var'==`var'[1]
		if (_rc == 0) {
			di in red "Variable `var' has no within-group variance"
			exit 459		
		}
	}

	** Check that the dependent variable only takes values 0-1 **
	capture assert `lhs' == 0 | `lhs' == 1
	if (_rc != 0) {
		di in red "The dependent variable must be a 0-1 variable indicating which alternatives are chosen"
		exit 450		
	}

	** Check that each group has only one chosen alternative **
	tempvar chonum
	sort `group'
	qui by `group': egen `chonum' = sum(`lhs')
	capture assert `chonum' == 1
	if (_rc != 0) {
		di in red "At least one group has more than one chosen alternative"
		exit 498		
	}

	** Generate individual id **
	if ("`id'" != "") {
		tempvar nchoice pid
		sort `group'
		by `group': gen `nchoice' = cond(_n==_N,1,0)
		sort `id'
		by `id': egen `pid' = sum(`nchoice')		
		qui duplicates report `id'
		mata: mixlwtp_np = st_numscalar("r(unique_value)")
		mata: mixlwtp_T = st_data(., st_local("pid"))
	}
	else {
		qui duplicates report `group'
		mata: mixlwtp_np = st_numscalar("r(unique_value)")
		mata: mixlwtp_T = J(st_nobs(),1,1)
	}

	** Generate choice occasion id **
	tempvar csid
	sort `group'
	by `group': egen `csid' = sum(1)

	** Sort data **
	sort `id' `group'

	** Set Mata matrices and scalars to be used in optimisation routine **
	local kfix: word count `fixed'
	local krnd: word count `rand'

	mata: mixlwtp_X = st_data(., tokens(st_local("rhs")))
	mata: mixlwtp_Y = st_data(., st_local("lhs"))
	mata: mixlwtp_CSID = st_data(., st_local("csid"))

	mata: mixlwtp_nrep = strtoreal(st_local("nrep"))
	mata: mixlwtp_kfix = strtoreal(st_local("kfix"))
	mata: mixlwtp_krnd = strtoreal(st_local("krnd"))
	mata: mixlwtp_krln = strtoreal(st_local("ln"))
	mata: mixlwtp_burn = strtoreal(st_local("burn"))

	if ("`userdraws'" != "") mata: mixlwtp_user = 1	
	else mata: mixlwtp_user = 0

	** Restore data **
	restore

	** Create macro to define equations for optimisation routine **
	local mean (Mean: `rhs', noconst)
	if ("`corr'" == "") {
		mata: mixlwtp_corr = 0
		local sd (SD: `rand', noconst)
		local max `mean' `sd' 
	}
	else {
		mata: mixlwtp_corr = 1
		local cho = `krnd'*(`krnd'+1)/2
		mata: mixlwtp_ncho = strtoreal(st_local("cho"))
		local max `mean'
		forvalues i = 1(1)`krnd' {
			forvalues j = `i'(1)`krnd' {
				local max `max' /l`j'`i'
			}
		}
	}
	
	/*
	** Create macro to define equations for optimisation routine **
	local meanwtp (Mean_WTP: `fixed' `randnop', noconst)
	local meanlnp (Mean_ln_price: `price', noconst)	
	if ("`corr'" == "") {
		mata: mixlwtp_corr = 0
		local sdwtp (SD_WTP: `randnop', noconst)
		local sdlnp (SD_ln_price: `price', noconst)		
		local max `meanwtp' `meanlnp' `sdwtp' `sdlnp' 
	}
	else {
		mata: mixlwtp_corr = 1
		local cho = `krnd'*(`krnd'+1)/2
		mata: mixlwtp_ncho = strtoreal(st_local("cho"))
		local max `meanwtp' `meanlnp'
		forvalues i = 1(1)`krnd' {
			forvalues j = `i'(1)`krnd' {
				local max `max' /l`j'`i'
			}
		}
	}
	*/
	
	** Create matrix of starting values unless specified **
	if ("`from'" == "") {
		tempname b from
		matrix `b' = e(b)

		local fixnorm = `kfix'+`krnd'-`ln'
		forvalues  i = 1(1)`fixnorm' {
			matrix `from' = nullmat(`from'), `b'[1,`i'] / `b'[1,(`kfix'+`krnd')]
		}	

		local lnmin1 = `ln' - 1
		forvalues i = 1(1)`lnmin1' {
			if (`b'[1,(`kfix'+`krnd'-`ln'+`i')] <= 0) {
				di in red "Variables specified to have log-normally distributed WTP coefficients should have positive"
				di in red "coefficients in the conditional logit model. Try multiplying the variable by -1."
				exit 498
			}
			matrix `from' = nullmat(`from'), ln(`b'[1,(`kfix'+`krnd'-`ln'+`i')] / `b'[1,(`kfix'+`krnd')])
		} 

		if (`b'[1,(`kfix'+`krnd')] <= 0) {
			di in red "The price variable should be  multiplied by -1 so that it has a positive coefficient in the"
			di in red "conditional logit model."
			exit 498
		}		
		matrix `from' = nullmat(`from'), ln(`b'[1,(`kfix'+`krnd')])

		if ("`corr'" == "") matrix `from' = `from', J(1,`krnd',0.1)
		else matrix `from' = `from', J(1,`cho',0.1)
		local copy , copy
	}

	
	** Run optimisation routine **
	if ("`id'" != "") {
		ml model gf0 mixlwtp_gf0()										///
			`max' if `touse' `wgt', group(`id') init(`from' `copy')		///
			`search' `mlopts' maximize missing nopreserve `coll' 				
	}
	else {
		ml model gf0 mixlwtp_gf0()										///
			`max' if `touse' `wgt', group(`group') init(`from' `copy')	///
			`search' `mlopts' maximize missing nopreserve `coll' 				
	}

	** To be returned as e() **
	ereturn local title "Mixed logit model in WTP space"
	ereturn local indepvars `rhs'
	ereturn local depvar `lhs'
	ereturn local group `group'
	ereturn scalar kfix = `kfix'

	ereturn scalar krnd = `krnd'
	ereturn scalar krln = `ln'
	ereturn scalar nrep = `nrep'
	ereturn scalar burn = `burn'
	if ("`corr'" != "") {
		ereturn scalar corr = 1
		ereturn scalar k_aux = `cho'
	}
	else ereturn scalar corr = 0
	if ("`id'" != "") ereturn local id `id'
	if ("`userdraws'" != "") ereturn scalar userdraws = 1
	else ereturn scalar userdraws = 0
	
	ereturn local cmd "mixlogitwtp"

	if ("`corr'" == "") Replay , level(`level')
	else Replay , level(`level') corr
end

program Replay
	syntax [, Level(integer `c(level)') CORR]
	ml display , level(`level')
	if ("`corr'" == "") {
		di in gr "The sign of the estimated standard deviations is irrelevant: interpret them as"
		di in gr "being positive"
	}
end

exit



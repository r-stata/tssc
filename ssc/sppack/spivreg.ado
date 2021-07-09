*! version 1.0.3  05nov2012
program define spivreg, eclass
	version 11.1

	if replay() {
		if `"`e(cmd)'"' != "spivreg" {
			error 301
		}
		Display `0'
		exit
	}
	
	tempname mlopts
	cap noi Estimate `mlopts' `0'
	local rc = c(rc)
	cap mata: mata drop `mlopts'
        if `rc' exit `rc'
        
        ereturn local cmdline `"spivreg `0'"'
	
end

program define Estimate, eclass sortpreserve

	gettoken mlopts 0 : 0
	
	_spivreg_parse `0'
	
	local lhs "`s(lhs)'"
	local exog "`s(exog)'"
	local endog "`s(endog)'"
	local inst "`s(inst)'"
	local 0 "`s(zero)'"
	
	syntax [if] [in] ,				///
		id(varname)				///
		[					///
		DLmat(name)				///
		ELmat(name)				///
		HETeroskedastic				///
		from(numlist max=1 >=-1 <=1)		///
		impower(integer 2)			///
		noCONStant				///
		Level(cilevel)				///
		ITERate(numlist max=1 integer >=0)	///
		TRace					///
		GRADient				///
		showstep				///
		SHOWTOLerance				///
		TOLerance(real 1e-6)			///
		LTOLerance(real 1e-7)			///
		noLOG					///
		Conly					///  UNDOCUMENTED
		condition				///  UNDOCUMENTED
		spreg					///  UNDOCUMENTED
		]
	
	marksample touse, //!! novarlist
	
	local conly conly
	
	preserve
	qui keep if `touse'
	
	if "`iterate'" == "" local iterate = c(maxiter)
	
	// SPMAT_ML_ops_parse parses optimize options in Mata and
	// returns a structure which is in turn passed to SPIVREG_main()
	
	mata: `mlopts' = SPMAT_ML_opts_parse("","","`log'","`trace'",	///
		"`showstep'","`gradient'","","`showtolerance'","",	///
		`iterate',`tolerance',`ltolerance',.)
	
	if "`from'" == "" {
		local rho0 = .
	}
	else local rho0 = `from'
	
	qui count
	local lim = floor(sqrt(`r(N)'))
	if `impower' < 2 | `impower' > `lim' {
		di "{err}impower() must specify an integer between 2 and `lim'"
		exit 498
	}
	
	if "`heteroskedastic'" !=  "" {
		local hetcase 1
	}
	else local hetcase 0
	
	gettoken depvar indeps : varlist
	
	_rmcoll `indeps' if `touse', `constant'
        local indeps `r(varlist)'
        
	if "`dlmat'`elmat'" == "" {			// ++++++ regress: case1
		
		if "`heteroskedastic'" != "" {
			di
			di "({txt}note: option {inp}heteroskedastic "	///
			       "{txt}affects Std. Err. but not point estimates)"
			local robust robust
		}
		
		local case 1
		
		if "`endog'"=="" {
			
			// this is an OLS case, could call regress directly
			// but must get the right ereturn list therefore it is
			// easier to call _spreg_ml which calls regress but
			// gives us the desired ereturn list
			
			_spreg_ml `lhs' `exog', `constant' id(`id') `robust'
			ereturn local estimator "gs2sls"
			
			if "`spreg'"=="spreg" {	// called from spreg gs2sls
				ereturn local cmd "spreg"
			}
			else {
ereturn local title "Spatial autoregressive model with endogenous variables"
ereturn local cmd "spivreg"
			}
			ereturn repost, esample(`touse')
			exit 0
		}
		else {
			qui ivregress 2sls `lhs' `exog' (`endog'=`inst'), ///
				`constant' `robust'
		}
	}
	else if "`dlmat'" != "" & "`elmat'" == "" {	// ++++++++++++++ case 2
		
		local case 2
		
		ObjCheck, objname(`dlmat') id(`id') touse(`touse') y(`lhs') ///
			x(`exog' `endog' `inst')
		
		mata: SPIVREG_main(2,"`lhs'","`exog'","`endog'","`inst'",   ///
		      "`constant'","`touse'","`dlmat'","`elmat'","`conly'", ///
		      `hetcase',`impower',`iterate',`rho0',"`condition'",   ///
		      `mlopts')
	}
	else if "`dlmat'" == "" & "`elmat'" != "" {	// ++++++++++++++ case 3
		
		local case 3
		
		ObjCheck, objname(`elmat') id(`id') touse(`touse') y(`lhs') ///
			x(`exog' `endog' `inst')
		
		mata: SPIVREG_main(3,"`lhs'","`exog'","`endog'","`inst'",   ///
		      "`constant'","`touse'","`dlmat'","`elmat'","`conly'", ///
		      `hetcase',`impower',`iterate',`rho0',"`condition'",   ///
		      `mlopts')
	}
	else {						// ++++++++++++++ case 4
		
		local case 4
		
		ObjCheck, objname(`dlmat') id(`id') touse(`touse') y(`lhs') ///
			x(`exog' `endog' `inst') o2(`elmat')
		
		mata: SPIVREG_main(4,"`lhs'","`exog'","`endog'","`inst'",   ///
		      "`constant'","`touse'","`dlmat'","`elmat'","`conly'", ///
		      `hetcase',`impower',`iterate',`rho0',"`condition'",   ///
		      `mlopts')
	}
	
	// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++ return list
	
	tempname b v delta_tilde
	
	if `case'==1 {
		local o = "e"
	}
	else local o = "r"
	
	matrix `b' = `o'(b)
	matrix `v' = `o'(V)
	
	if "`constant'" == ""  {
		local cons _cons
	}
	
	local names `endog' `exog' `cons'
	foreach nm of local names {
		local names2 `names2' `lhs':`nm'
	}
	
	if (`case'==2) local names2 `names2' lambda:_cons
	if (`case'==3) local names2 `names2' rho:_cons
	if (`case'==4) local names2 `names2' lambda:_cons rho:_cons
	
	if `case'>1 {
		matrix rownames `b' = ""
		matrix colnames `b' = `names2'
		matrix rownames `v' = `names2'
		matrix colnames `v' = `names2'
	}
	
	local n = `o'(N)
	
	local H_omitted `r(H_omitted)'
	
	// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ereturn list
		
	ereturn post `b' `v', obs(`n')
	
	if `case'>1 ereturn scalar k = r(k)
	
	//ereturn local gof "spreg_gof"
	ereturn local estat_cmd "spreg_estat"
	ereturn local predict "spreg_p"
	
	if "`dlmat'" != "" ereturn local dlmat "`dlmat'"
	if "`elmat'" != "" ereturn local elmat "`elmat'"
	
	if `case'>1 {
		
		if (`case'>2) ereturn scalar rho_2sls    = r(rho_tilde)
		
		matrix `delta_tilde'       = r(delta_tilde)
		ereturn matrix delta_2sls  = `delta_tilde'
		
		if "`condition'" != "" {
			ereturn scalar cond2sls  = r(cond2sls)
			ereturn scalar condg2sls = r(condg2sls)
		}
	}
	
	if `case'>2 {
		//ereturn scalar rho_2sls  = r(rho_tilde)	
		//ereturn scalar hess      = r(hess)
		//ereturn scalar hess_2sls = r(hess_2sls)
		
		ereturn scalar iterations      = r(iterations)
		ereturn scalar iterations_2sls = r(iterations_2sls)
		
		ereturn scalar converged      = r(converged)
		ereturn scalar converged_2sls = r(converged_2sls)
	}
	
	ereturn local idvar "`id'"
	ereturn local insts = "`inst'"
	ereturn local exogr = "`exog'"
	ereturn local instd = "`endog'"
	ereturn local indeps = "`endog' `exog'"
	ereturn local depvar = "`lhs'"
	ereturn local H_omitted `H_omitted'
	
	if "`constant'"=="" {
		ereturn local constant hasconstant
	}
	else ereturn local constant noconstant
	
	if (`hetcase') {
		ereturn local het heteroskedastic
	}
	else ereturn local het homoskedastic
	
	if (`case'==1) ereturn local model lr
	if (`case'==2) ereturn local model sar
	if (`case'==3) ereturn local model sare
	if (`case'==4) ereturn local model sarar
	
	if "`spreg'" != "" {
		ereturn local title "Spatial autoregressive model"
		ereturn local estimator "gs2sls"
		ereturn local cmd "spreg"
	}
	else {
		ereturn local title 	///
			"Spatial autoregressive model with endogenous variables"
		ereturn local cmd "spivreg"
	}
	
	di
	di as txt "Spatial autoregressive model " 		///
		"{col 51}Number of obs {col 67}= " 		///
		as res %8.0f `n'
	
	di as txt "(GS2SLS estimates)"
	di
	
	Display, level(`level')
	
	restore
	
	ereturn repost, esample(`touse')
	
end

program define Display
	
	syntax [, level(cilevel) * ]
	
	_get_diopts diopts, `options'
	
	_coef_table, `options' level(`level')
	
	if "`e(instd)'" != "" ivreg_footnote, noline
	
end

program define ObjCheck
	
	syntax , Objname(string) [ id(varname) Touse(varname) ///
			y(varname) x(string) o2(string) ]
	
	capture mata: SPMAT_assert_object("`objname'")
	if _rc {
		di "{inp}`objname' {err}is not a valid {help spmat} object"
		exit 498
	}
	//mata: SPMAT_check_if_banded("`objname'")
	
	if "`o2'"!="" {
		capture mata: SPMAT_assert_object("`o2'")
		if _rc {
			di "{inp}`o2' {err}is not a valid {help spmat} object"
			exit 498
		}
		//mata: SPMAT_check_if_banded("`o2'")
	}
	
	if "`id'"!="" {
		mata: SPMAT_idmatch("`objname'","`id'","`y'","`x'","`o2'")
	}

end

*slight variation on _iv_parse.ado
program _spivreg_parse, sclass
	
	local n 0

	gettoken lhs 0 : 0, parse(" ,[") match(paren) bind
	if (strpos("(",`"`lhs'"')) {
		fvunab lhs : `lhs'
		if `:list sizeof lhs' > 1 {
			gettoken lhs rest : lhs
			local 0 `"`rest' `0'"'
		}
	}
	IsStop `lhs'
	if `s(stop)' { 
		error 198 
	}  
	_fv_check_depvar `lhs'
	while `s(stop)'==0 {
		if "`paren'"=="(" {
			local n = `n' + 1
			if `n'>1 {
				capture noi error 198
di as error `"syntax is "(all instrumented variables = instrument variables)""'
				exit 198
			}
			gettoken p lhs : lhs, parse(" =") bind
			while "`p'"!="=" {
				if "`p'"=="" {
					capture noi error 198
di as error `"syntax is "(all instrumented variables = instrument variables)""'
di as error `"the equal sign "=" is required"'
					exit 198
				}
				local end`n' `end`n'' `p'
				gettoken p lhs : lhs, parse(" =") bind
			} 
			if "`end`n''" != "" {
				fvunab end`n' : `end`n''
			}
			capture fvunab exog`n' : `lhs'
		}
		else {
			local exog `exog' `lhs'
		}
		gettoken lhs 0 : 0, parse(" ,[") match(paren) bind
		IsStop `lhs'
	}
	local 0 `"`=trim(`"`lhs' `0'"')'"'

	fvunab exog : `exog'
	fvexpand `exog'
	local exog `r(varlist)'
	tokenize `exog'
	local lhs "`1'"
	local 1 " "
	local exog `*'
	
	// Eliminate vars from `exog1' that are in `exog'
	local inst : list exog1 - exog
	_fv_check_depvar `end1'
	
	// `lhs' contains depvar, 
	// `exog' contains RHS exogenous variables, 
	// `end1' contains RHS endogenous variables, and
	// `inst' contains the additional instruments
	// `0' contains whatever is left over (if/in, weights, options)
	
	sret local lhs `lhs'
	sret local exog `exog'
	sret local endog `end1'
	sret local inst `inst'
	sret local zero `"`0'"'

end

program define IsStop, sclass

	if `"`0'"' == "[" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "," {
		sret local stop 1
		exit
	}
	if `"`0'"' == "if" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "in" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "" {
		sret local stop 1
		exit
	}
	else {
		sret local stop 0
	}

end

exit

Version history

1.0.3

Instrument matrix H was incorrectly computed as H = {X} in the case of the
	spatial error model.  This has been fixed to H = {X, M*X}.

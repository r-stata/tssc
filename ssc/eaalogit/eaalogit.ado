*! eaalogit 1.1.0 02Apr2016
*! author arh

*  1.1.0:	a bug that could affect the estimation results in the case of 
*			extreme parameter values during the iterations has been fixed

program eaalogit
	version 12.1
	if replay() {
		if (`"`e(cmd)'"' != "eaalogit") error 301
		Replay `0'
	}
	else	Estimate `0'
end

program Estimate, eclass sortpreserve
	syntax varlist [if] [in] 	///
		[pweight iweight],		///	
		GRoup(varname) 			///
		ID(varname) 			///
		Keaa(integer)			///
		EAAspec(string) [		///
		Zvars(varlist)			/// 		
		FRom(string)			/// 
		SEArch					///
		Level(integer `c(level)')	///
		TRace					///
		GRADient				///
		HESSian					///
		SHOWSTEP				///
		ITERate(passthru)		///
		TOLerance(passthru)		///
		LTOLerance(passthru)	///
		GTOLerance(passthru)	///
		NRTOLerance(passthru)	///
		CONSTraints(passthru)	///
		TECHnique(passthru)		///
		DIFficult				///
		VCE(passthru)			///
		COLL					///
	]

	local mlopts `trace' `gradient' `hessian' `showstep' `iterate' `tolerance' 	///
	`ltolerance' `gtolerance' `nrtolerance' `constraints' `technique' 			///
	`difficult' `vce'

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
	markout `touse' `group' `id' `zvars'

	gettoken lhs rhs : varlist
	local rhs = trim("`rhs'")

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
	if ("`coll'" == "") {
		qui _rmcoll `rhs' 
		if ("`r(varlist)'" != "`rhs'") {
			di in red "Some variables are collinear - if this is intended use the coll option"
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
		qui clogit `lhs' `rhs' if `touse' `wgt', group(`group')
		local nobs = e(N)
		qui replace `touse' = e(sample)
	}

	** Create matrices representing possible ANA patterns **	
	preserve
	clear
	tempname levels
	matrix `levels' = J(1,`keaa',2)
	genfact, levels(`levels')
	foreach var of varlist * {
		qui replace `var' = `var' - 1
	}
	mata: eaa_F = st_data(.,.)
	qui gen one = 1
	mata: eaa_FCOLDUP = st_data(.,tokens(st_local("eaaspec")))
	restore
	
	** Drop missing data **
	preserve
	qui keep if `touse'

	** Generate dummy for last obs for each decision-maker**
	tempvar last
	bysort `id': gen `last' = cond(_n==_N,1,0)
	qui replace `last' = 0 if `touse' == 0

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
	tempvar nchoice pid
	sort `group'
	by `group': gen `nchoice' = cond(_n==_N,1,0)
	sort `id'
	by `id': egen `pid' = sum(`nchoice')		
	qui duplicates report `id'
	mata: eaa_np = st_numscalar("r(unique_value)")
	mata: eaa_T = st_data(., st_local("pid"))

	** Generate choice occasion id **
	tempvar csid
	sort `group'
	by `group': egen `csid' = sum(1)

	** Sort data **
	sort `id' `group'

	** Set Mata matrices and scalars to be used in optimisation routine **
	local krhs: word count `rhs'
	local kzvs: word count `zvars'

	mata: eaa_X = st_data(., tokens(st_local("rhs")))
	mata: eaa_Y = st_data(., st_local("lhs"))
	mata: eaa_CSID = st_data(., st_local("csid"))
	if ("`zvars'" != "") mata: eaa_Z = st_data(., tokens(st_local("zvars")), st_local("last"))
		
	mata: eaa_krhs = strtoreal(st_local("krhs"))
	mata: eaa_kzvs = strtoreal(st_local("kzvs"))
	mata: eaa_keaa = strtoreal(st_local("keaa"))

	** Restore data **
	restore

	** Create macro to define equations for optimisation routine **
	local max (Beta: `rhs', noconst)
	forvalues i = 1(1)`keaa' {
		local max `max' (Gamma`i': `zvars')
	}	

	** Create matrix of starting values unless specified **
	if ("`from'" == "") {
		tempname from
		if ("`zvars'" == "") {
			matrix `from' = e(b), J(1,`keaa',1)
		}
		else {
			matrix `from' = e(b)
			forvalues i = 1(1)`keaa' {
				matrix `from' = `from', J(1,`kzvs',0), 1
			}	
		}	
		local copy , copy
	}

	** Sort data **
	sort `id' `group'
	
	** Run optimisation routine **
	ml model gf0 eaa_gf0()											///
		`max' if `touse' `wgt', group(`id') init(`from' `copy')		///
		`search' `mlopts' `coll' maximize missing nopreserve				

	** To be returned as e() **
	ereturn local title "Endogenous attribute attendance model"
	ereturn local indepvars `rhs'
	ereturn local depvar `lhs'
	ereturn local group `group'
	ereturn local id `id'
	if ("`zvars'" != "") ereturn local zvars `zvars' 

	ereturn local eaaspec `eaaspec'

	ereturn scalar krhs = `krhs'		
	ereturn scalar keaa = `keaa'			
	ereturn scalar kzvs = `kzvs'
	if ("`zvars'" == "") ereturn scalar k_aux = `keaa'
	
	ereturn local cmd "eaalogit"

	Replay , level(`level')
end

program Replay
	syntax [, Level(integer `c(level)')]
	ml display , level(`level')
end

exit



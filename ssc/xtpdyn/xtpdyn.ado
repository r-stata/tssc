*! xtpdyn 2.0.0 28may2018 Raffaele Grotti & Giorgio Cutuli

program xtpdyn, eclass  byable(recall) sortpreserve
	version 13
	
	if replay() {
		syntax,  [keep | drop]
		
		if "`e(uh)'"=="" {
			dis as error "last estimates not found"
			exit 301
		}
		
		if "`keep'"!="" & "`drop'"!="" {
			display as error "too many options specified"
			exit 1003
		}

		if "`keep'"!="" {
			xtpdyn_keep
			}
		else if "`drop'"!="" {
			xtpdyn_drop
		}
		else {
			noi dis "Dynamic random-effects probit model with unobserved heterogeneity"
			capture noi meprobit
			if _rc!=0 exit _rc
		}
	}

	if !replay() {
	syntax varlist(ts fv min=2) [if] [in] [fw pw iw], uh(varlist fv min=1) [re(string)] 
	
	local avg "`uh'"
	
	if "`s(fvops)'" == "true" | _caller() >= 11 {
		local vv: di "version " string(max(11,_caller())) ", missing: "
		gettoken lhs rest : varlist
		_fv_check_depvar `lhs'						
	}
		
	quietly {
		marksample touse
				
		count if `touse'
		if r(N) == 0 error 2000
		
		tempvar panelvar timevar nob
		xtset 
		if "`r(panelvar)'" != "" clonevar `panelvar' = `r(panelvar)'
		else {
		   display as error "panel variable not set."
		   exit 459
		}	  
		if "`r(timevar)'" != "" clonevar `timevar' = `r(timevar)'
		else {
			 display as error "time variable not set."	
			 exit 459
		}	  
		lab var `timevar' "`timevar'"
		
		local vlist "`varlist'"
		gettoken depvar indepvars: varlist 
		
		capture sum `depvar'__0, meanonly
		if _rc == 0 {
			 display as error "uh() variables already exist. You need to drop them. see xtpdyn, drop"	
			 exit 110
		}	 
	
		fvexpand `indepvars' if `touse'
		local indexp `r(varlist)'

		local avg_ori "`avg'"
		fvexpand `avg' if `touse'
		if "`r(tsops)'"!="" {
		   display as error "time-series operator not allowed in avg()"
		   exit 101
		}	
		
		fvexpand `avg' if `touse'
		local avg "`r(varlist)'"
		foreach wrd of local avg {
			if strpos("`wrd'", "o.") != 0 {
				display as error "omit operator not allowed in avg()"
				exit 101			
			}
		}
		
		fvrevar `avg' if `touse', list
		local nfi "`r(varlist)'"

		local fvni : list nfi - avg	

		local nfv : list nfi - fvni	

		fvexpand `avg' if `touse'
		local fv  "`r(varlist)'"
		local fv :  list fv - nfv

		ret list

		foreach wrd of local fv {
			if strpos("`wrd'", "b.") != 0 local vlbase `vlbase' `wrd'
			if strpos("`wrd'", "b.") == 0 local vlrest `vlrest' `wrd'
			
		}

		local var_to_mean "`vlrest' `nfv'"
		local var_to_initial "`vlbase' `nfv'"


		fvrevar `indepvars'  if `touse', list
		local nfindep "`r(varlist)'"
		local check1 :  list nfi - nfindep
		if "`check1'" != "" {
			display as error "variable(s) `check1' not present among indep. vars."
			exit 103
		}
		
		foreach var of local vlrest {
			tokenize "`var'", parse(".")
			bys `touse' `panelvar': gen m`1'__`3' = sum(`var')/sum((`var'<.)) if `touse'
			bys `touse' `panelvar': replace m`1'__`3' = m`1'__`3'[_N] if `touse'
			local meantv `meantv' m`1'__`3'
			lab var m`1'__`3' "Time average of `3'=`1'"
		}
		foreach var of local nfv {
			bys `touse' `panelvar': gen m__`var' = sum(`var')/sum((`var'<.)) if `touse'
			bys `touse' `panelvar': replace m__`var' = m__`var'[_N] if `touse'
			local meantv `meantv' m__`var' 	
			lab var m__`var' "Time average of `var'"
		}

		local bl "`vlbase'"
		foreach var of local fvni {
			bys `touse' `panelvar' (`timevar'): gen byte `var'__0 = `var'[1] if `touse' & `touse'[1]==1	
			local initialv `initialv' `var'__0	
			gettoken bc bl : bl 
			gettoken bc : bc ,parse("b.")
			local initial `initial' ib`bc'.`var'__0	
			lab var `var'__0 "Initial period of `var'"
		}

		foreach var of local nfv {
			bys `touse' `panelvar' (`timevar'): gen `var'__0 = `var'[1] if `touse' & `touse'[1]==1
			local initial `initial' `var'__0
			local initialv `initialv' `var'__0	
			lab var `var'__0 "Initial period of `var'"
		}
		
		
		bys `touse' `panelvar' (`timevar'): gen byte `depvar'__0 = `depvar'[1] if `touse' 
		lab var `depvar'__0 "Initial condition. `depvar' at time 0"
	}
	
	local intop "intpoints(12)"
	foreach op of local re { 
		local op = substr("`op'",1,4)
		if "`op'"=="intp" local intop ""
	}

		di ""
		di as text "   	            GSD (Yt-1): L.`depvar'"
		di as text "   Initial condition (Yt0): `depvar'__0"
		di as text "	  Initial period of Xs: `initialv'"
		di as text "Within-unit averages of Xs: `meantv'"
		di ""
		qui xtset
		qui xtset `r(panelvar)' `r(timevar)'
		
		capture noisily meprobit `depvar' iL.`depvar' `indexp' i.`depvar'__0 `initial' `meantv' ///
			if `touse' [`weight'`exp']  || `r(panelvar)' : , `intop' `re'
			
		qui drop `initialv' `meantv' `depvar'__0
		
		if _rc!=0 {
			local oldrc = _rc
			exit `oldrc'
		}
		
		ereturn local if "`if' `in'"
		ereturn local uh "`avg_ori'"
		ereturn local varlist "`vlist'"
		ereturn local depvar "`depvar'"
	}
end

program define xtpdyn_drop

	tempname prev_ret
	_return hold `prev_ret'
	
	local va "`e(datasignaturevars)'"
	local ev = 0
	while "`va'"!="" {
		gettoken v va : va
		tokenize `v', parse("__")
		if "`3'"!="" {
			capture sum `v', meanonly
			if _rc==0 {
				local ++ev
				local evl "`evl' `v'"
			}
		}
	}
	if `ev'==0 {
		dis as err "variables not found"
		exit 111
	}

	qui xtset
	local panelvar `r(panelvar)'
	local timevar `r(timevar)'
	local if `e(if)'
	local vt "`e(varlist)'"
	local avg "`e(uh)'"

	tempvar touse
	mark `touse' `if'
	markout `touse' `vt'

	fvrevar `avg' if `touse', list
	local nfi "`r(varlist)'"
	local fvni : list nfi - avg			
	local nfv : list nfi - fvni	

	fvexpand `avg' if `touse'
	local fv  "`r(varlist)'"
	local fv :  list fv - nfv

	foreach wrd of local fv {
		if strpos("`wrd'", "b.") != 0 local vlbase `vlbase' `wrd'
		if strpos("`wrd'", "b.") == 0 local vlrest `vlrest' `wrd'
			
	}
	local var_to_mean "`vlrest' `nfv'"
	local var_to_initial "`vlbase' `nfv'"

	foreach var of local vlrest {
		tokenize "`var'", parse(".")
		local meantv `meantv' m`1'__`3'
	}
		
	foreach var of local nfv {
		local meantv `meantv' m__`var'
	}
		
	local bl "`vlbase'"
	foreach var of local fvni {
		local initialv `initialv' `var'__0	
			
		gettoken bc bl : bl 
		gettoken bc : bc ,parse("b.")
		local initial `initial' ib`bc'.`var'__0
	}
		
	foreach var of local nfv {
		local initial `initial' `var'__0
		local initialv `initialv' `var'__0
	}
		
	local depvar `e(depvar)'
			
	foreach vr in `depvar'__0 `initialv' `meantv' {
		capture drop `vr'
		if _rc==0 local vrdropped "`vrdropped' `vr'"
	}
	noi dis "`vrdropped' have been dropped"
	_return restore `prev_ret'
end

program define xtpdyn_keep	
	
	tempname prev_ret
	_return hold `prev_ret'
	
	local va "`e(datasignaturevars)'"
	local ev = 0
	while "`va'"!="" {
		gettoken v va : va
		tokenize `v', parse("__")
		if "`3'"!="" {
			capture sum `v', meanonly
			if _rc==0 {
				local ++ev
				local evl "`evl' `v'"
			}
		}
	}

	if `ev'>0 {
		
		dis as err "one or more variables already defined"
		exit 110
	}
	
	qui xtset
	local panelvar `r(panelvar)'
	local timevar `r(timevar)'
	local if `e(if)'
	local vt "`e(varlist)'"
	local avg "`e(uh)'"

	tempvar touse
	mark `touse' `if'
	markout `touse' `vt'

	fvrevar `avg' if `touse', list
	local nfi "`r(varlist)'"
	local fvni : list nfi - avg			
	local nfv : list nfi - fvni	

	fvexpand `avg' if `touse'
	local fv  "`r(varlist)'"
	local fv :  list fv - nfv

	foreach wrd of local fv {
		if strpos("`wrd'", "b.") != 0 local vlbase `vlbase' `wrd'
		if strpos("`wrd'", "b.") == 0 local vlrest `vlrest' `wrd'
			
	}
	local var_to_mean "`vlrest' `nfv'"
	local var_to_initial "`vlbase' `nfv'"

	foreach var of local vlrest {
		tokenize "`var'", parse(".")
		capture bys `touse' `panelvar': gen m`1'__`3' = sum(`var')/sum((`var'<.)) if `touse'
		capture bys `touse' `panelvar': replace m`1'__`3' = m`1'__`3'[_N] if `touse'
		capture lab var m`1'__`3' "Time average of `3'=`1'"
		local meantv `meantv' m`1'__`3'
	}
		
	foreach var of local nfv {
		capture bys `touse' `panelvar': gen m__`var' = sum(`var')/sum((`var'<.)) if `touse'
		capture bys `touse' `panelvar': replace m__`var' = m__`var'[_N] if `touse'
		capture lab var m__`var' "Time average of `var'"
		local meantv `meantv' m__`var'
	}
	
	local bl "`vlbase'"
	foreach var of local fvni {
		capture bys `touse' `panelvar' (`timevar'): gen byte `var'__0 = `var'[1] if `touse' & `touse'[1]==1	
		local initialv `initialv' `var'__0	
			
		gettoken bc bl : bl 
		gettoken bc : bc ,parse("b.")
		local initial `initial' ib`bc'.`var'__0
		capture lab var `var'__0 "Initial period of `var'"
	}
		
	foreach var of local nfv {
		capture bys `touse' `panelvar' (`timevar'): gen `var'__0 = `var'[1] if `touse'
		capture lab var `var'__0 "Initial period of `var'"
		local initial `initial' `var'__0
		local initialv `initialv' `var'__0
	}
		
	local depvar `e(depvar)'
	capture bys `touse' `panelvar' (`timevar'): gen byte `depvar'__0 = `depvar'[1] if `touse'
	capture lab var `depvar'__0 "Initial condition. `depvar' at time 0"
			
	foreach vr in `depvar'__0 `initialv' `meantv' {
		order `vr', last
	}
	
	noi dis "`depvar'__0 `initialv' `meantv' have been created"
	
	qui xtset `r(panelvar)' `r(timevar)'
	_return restore `prev_ret'
end



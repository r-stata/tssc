capture program drop createImputedCopy
program define createImputedCopy
	version 9.0
	syntax varname, type(string) imputeprefix(name)
	
	capture drop `imputeprefix'`varlist'
	quietly clonevar `imputeprefix'`varlist' = `varlist' 
	local varlab : variable label `varlist'
	local newlab = "* MEAN-PLUGGED (`type') * " + "`varlab'"
	label variable `imputeprefix'`varlist' "`newlab'"
	
end

capture program drop gendist
program define gendist
	version 9.0
	
	syntax varlist(min=1), [CONtextvars(varlist)] [PPRefix(name)] [DPRefix(name)] RESpondent(varname) [MISsing(string)] [ROUnd] [REPlace] [MPRefix(name)] [MCOuntname(name)] [MPLuggedcountname(name)] [STAckid(varname)] [NOStacks] [DROpmissing]

	if ("`missing'"=="" & "`pprefix'"!="") {
		display "{text}{pstd}ERROR: the {bf:missing} option was not specified, thus the {bf:pprefix} option is illegal."
		exit
	}
	
	local imputePref = "p_"
	if ("`pprefix'"!="") {
		local imputePref = "`pprefix'"
	}
	
	local distPref = "d_"
	if ("`dprefix'"!="") {
		local distPref = "`dprefix'"
	}
	
	local missingFlagPref = "m_"
	if ("`mprefix'"!="") {
		local missingFlagPref = "`mprefix'"
	}
	
	local missingCntName = "_gendist_mc"
	if ("`mcountname'"!="") {
		local missingCntName = "`mcountname'"
	}
	
	local missingImpCntName = "_gendist_mpc"
	if ("`mpluggedcountname'"!="") {
		local missingImpCntName = "`mpluggedcountname'"
	}
	
	local nvars : list sizeof varlist
	
	tokenize `varlist'
    local first `1'
	local last ``nvars''

	
	if ("`missing'"!="") {
		capture drop `missingCntName'
		capture label drop `missingCntName'
		quietly egen `missingCntName' = rowmiss(`varlist')
		capture label var `missingCntName' "N of missing values in `nvars' variables to impute (`first'...`last')"

		capture drop `missingImpCntName'
		capture label drop `missingImpCntName'
		capture label var `missingImpCntName' "N of missing values in mean-plugged versions of `nvars' variables (`first'...`last')"

		local imputedvars = ""

		foreach var of varlist `varlist' {
			capture drop `missingFlagPref'`var'
			quietly generate `missingFlagPref'`var' = missing(`var')
			capture label var `missingFlagPref'`var' "Was `var' originally missing?"
			local imputedvars = "`imputedvars' `imputePref'`var'"

		}
	}

	capture drop _ctx_temp
	capture label drop _ctx_temp


	if ("`stackid'" != "") & ("`nostacks'" == "") {
		local thisCtxVars = "`contextvars' `stackid'"
	}
	else {
		local thisCtxVars = "`contextvars'"
	}
	
	if ("`thisCtxVars'" == "") {
		gen _ctx_temp = 1
		local ctxvar = "_ctx_temp"
	}
	else {
		quietly _mkcross `thisCtxVars', generate(_ctx_temp) missing
		local ctxvar = "_ctx_temp"
	}
	
	
	/* old naming too verbose
	
	if ("`missing'"!="") {
		local fullDistancePref = "`imputePref'`distPref'`respondent'_"
	}
	else {
		local fullDistancePref = "`distPref'`respondent'_"
	}
	*/
	local fullDistancePref = "`distPref'"
	
	
	
	// loads all values of the context variable
	quietly levelsof `ctxvar', local(contexts)
	
	display in smcl
	display as text
	display "{pstd}{text}Computing distances between R's position ({result:`respondent'}){break}"
	display "and her placement of different objects: {result:`varlist'}"

	// create imputed copies first
	if ("`missing'"!="") {
		foreach var of varlist `varlist' {
			createImputedCopy `var', type("`missing'") imputeprefix("`imputePref'")
		}
	}
	
	// create empty variables regardless of context
	if ("`missing'"!="") {
		foreach var of varlist `varlist' {
			capture drop `fullDistancePref'`var'
			capture quietly gen `fullDistancePref'`var' = .
			local newlab = "Euclidean distance between `respondent' and `imputePref'`var'"
			label variable `fullDistancePref'`var' "`newlab'"
		}
	} 
	else {
		foreach var of varlist `varlist' {
			capture drop `fullDistancePref'`var'
			capture quietly gen `fullDistancePref'`var' = .
			local newlab = "Euclidean distance between `respondent' and `var'"
			label variable `fullDistancePref'`var' "`newlab'"
		}
	}
	
	display ""
	
	//display "{text}{pstd}"
	// loops over all contexts
	foreach context in `contexts' {
		display "{text}{pstd}Context {result:`context'}: Generating " _continue
		foreach var of varlist `varlist' {
			if ("`missing'"=="mean") {
			
				quietly summarize `imputePref'`var' if `ctxvar'==`context'
				quietly return list
				local theMean = r(mean)
				if ("`round'"=="round") local theMean = round(`theMean')
				
				capture replace `imputePref'`var'=`theMean' if `imputePref'`var'==. & `ctxvar'==`context'
				capture replace `fullDistancePref'`var' = abs(`imputePref'`var' - `respondent') if `ctxvar'==`context'
				
				display "{result:`imputePref'`var'},{result:`fullDistancePref'`var'}... " _continue
				
 
			}
			else if ("`missing'"=="same") {
			
				quietly summarize `imputePref'`var' if `respondent'==`imputePref'`var' & `ctxvar'==`context'
				quietly return list
				local theMean = r(mean)
				if ("`round'"=="round") local theMean = round(`theMean')
				
				capture replace `imputePref'`var'=`theMean' if `imputePref'`var'==. & `ctxvar'==`context'
				capture replace `fullDistancePref'`var' = abs(`imputePref'`var' - `respondent') if `ctxvar'==`context'
				
				display "{result:`imputePref'`var'},{result:`fullDistancePref'`var'}... " _continue

			}
			else if ("`missing'"=="diff") {
			
				quietly summarize `imputePref'`var' if `respondent'!=`imputePref'`var' & `ctxvar'==`context'
				quietly return list
				local theMean = r(mean)
				if ("`round'"=="round") local theMean = round(`theMean')
				
				capture replace `imputePref'`var'=`theMean' if `imputePref'`var'==. & `ctxvar'==`context'
				capture replace `fullDistancePref'`var' = abs(`imputePref'`var' - `respondent') if `ctxvar'==`context'
				
				display "{result:`imputePref'`var'},{result:`fullDistancePref'`var'}... " _continue

			}
			else {
				capture replace `fullDistancePref'`var' = abs(`var' - `respondent') if `ctxvar'==`context'
				display "{result:`fullDistancePref'`var'}... " _continue

			}

			// centering, removed.
			/*
			if ("`nocenter'"!="") {
				// do nothing
			}
			else {
				quietly summarize `fullDistancePref'`var' if `ctxvar'==`context'
				quietly return list
				local theDistanceMean = r(mean)
				replace `fullDistancePref'`var'=`fullDistancePref'`var'-`theDistanceMean' if `ctxvar'==`context'	
			}
			*/
		
		}
	
		display "{break}"
		display ""
		//display as text
		//display "{p_end}"
		//display ""
	}
	
	if ("`missing'"!="") {
		quietly egen `missingImpCntName' = rowmiss(`imputedvars')
	} 
	
	if ("`replace'" != "") {
		capture drop `varlist'
	}

	if ("`dropmissing'"!="") {
		capture drop `missingFlagPref'*
		capture drop `imputePref'*
	}
	
	capture drop _ctx_temp
	capture label drop _ctx_temp

	display ""
	display "done."
	
end	


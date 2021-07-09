*! 1.3.0 MLB 14Feb2017

/*------------------------------------------------ playback request */
program fmlogit, eclass byable(onecall)
	if c(stata_version) >= 11 {
		version 11
		global fv "fv"
	}
	else {
		version 8.2
	}
		if replay() {
		if "`e(cmd)'" != "fmlogit" {
			di as err "results for fmlogit not found"
			exit 301
		}
		if _by() error 190 
		Display `0'
		exit `rc'
	}
	syntax varlist [if] [in] [fw pw], *
	if _by() by `_byvars'`_byrc0': Estimate `0'
	else Estimate `0'
end

/*------------------------------------------------ estimation */
program Estimate, eclass byable(recall)
	syntax varlist [if] [in] [fw pw] [,  ///
		ETAvar(varlist numeric $fv)      ///
		Baseoutcome(varname)             ///
		Cluster(varname)                 ///
		Level(real `=c(level)')          ///
		rpr                              ///
		noLOG                            ///
		METHod(string)                   ///
		from(passthru)                   ///
		init(passthru)                   ///
        NOCONstant                       ///
		*                                ///
		]

	local k : word count `varlist'
			
	if !`: list baseoutcome in varlist' {
		di as err "varlist must contain baseoutcome"
		exit 198
	}

	marksample touse 
	markout `touse' `varlist' `etavar' `cluster'
	
	foreach var of varlist `varlist' {
		local test "`test' | `var' < 0 | `var' > 1"
	}
	tempvar tot
	
	qui gen double `tot' = 0 if `touse'
	qui foreach v of local varlist {
		replace `tot' = `tot' + cond(missing(`v'),0,`v') if `touse'
	}
	qui count if (`tot' < .99 | `tot' > 1.01 `test') & `touse'
	if r(N) {
		noi di " "
		noi di as txt ///
		"{p}warning: {res:`varlist'} has " as result "`r(N)'" as txt " values < 0 or > 1" 
		noi di as txt ///
		" or rowtotal(`varlist') != 1; not used in calculations{p_end}"
	}
	qui replace `touse' = 0 if `tot' < .99 | `tot' > 1.01 `test' 

	qui count if `touse' 
	if r(N) == 0 error 2000 

	local title "ML fit of fractional multinomial logit"
	
	local wtype `weight'
	local wtexp `"`exp'"'
	if "`weight'" != "" local wgt `"[`weight'`exp']"'  
	
	if "`cluster'" != "" { 
		local clopt "cluster(`cluster')" 
	}

	if "`level'" != "" local level "level(`level')"
    local log = cond("`log'" == "", "noisily", "quietly") 
	
	if `"`from'"' != "" & c(stata_version) < 10 {
		di as err "the from() option is only allowed in Stata version 10 or higher; use the init() option instead"
		exit 198
	}
	if `"`from'"' != "" & `"`init'"' != "" {
		di as err "the from() and init() options may not be combined"
		exit 198
	}
	
	mlopts mlopts, `options'
		
	if "baseoutcome" != "" {
		local varlist2 "`baseoutcome'"
		foreach var of local varlist {
			if "`var'" != "`baseoutcome'" local varlist2 = "`varlist2' `var'"
		}
		local varlist "`varlist2'"
	}
	
	if `"`from'`init'`noconstant'"' == "" {
		Start `varlist' if `touse' `wgt'
		tempname b0
		matrix `b0' = r(init)
		local init init(`b0')
	}
	
	tokenize `varlist'
	global S_ref "`1'"
	global S_depvars = "`varlist'"
	
	forvalues i = 2/`k' {
		if `i' == 2 {
			local eta "(eta_``i'': `varlist' = `etavar', `noconstant')"
		}
		else {
			local eta "`eta' (eta_``i'': `etavar', `noconstant')"
		}
	}
	
	if c(stata_version) >= 11 {
		local negh "negh"
		if "`method'" == "" {
			local method "e2"
		}
		else {
			if `: word count `method'' > 1 {
				di as err "method() can only contain one method"
				exit 198
			}
			local valid "lf d0 e1 e2"
			local ok : list method in valid
			if !`ok' {
				di as err "method() can contain only lf, d0, e1, or e2"
				exit 198
			}
		}
	}
	else {
		if "`method'" == "" {
			local method "d2"
		}
		else {
			if `: word count `method'' > 1 {
				di as err "method() can only contain one method"
				exit 198
			}
			local valid "lf d0 d1 d2"
			local ok : list method in valid
			if !`ok' {
				di as err "method() can contain only lf, d0, d1, or d2"
				exit 198
			}
		}
	}
	if "`method'" == "lf" {
		local progn "lf"
	}
	else {
		local progn "d2"
	}
	`log' ml model `method' fmlogit_`progn' `eta'                      ///
		`wgt' if `touse' , maximize 				 ///
		collinear title(`title') robust  `from' `init'        	 ///
		search(off) `clopt' `level' `mlopts' `stdopts' `modopts' ///
		waldtest(`=`k'-1') `negh'

	eret local cmd "fmlogit"
	eret local depvars "`varlist'"
	ereturn local predict "fmlogit_p"

        Display, `level' `diopts' `rpr'
end

program Start, rclass
	syntax varlist [if] [fw pw] 
	marksample touse

	local wtype = cond("`weight'" == "pweight", "aweight","fweight")
	if "`weight'" != "" local wgt `"[`wtype'`exp']"'  

	tempname init
	local k : word count `varlist'
	matrix `init' = J(1,`=`k'-1', .)
	local i = 0
	foreach var of local varlist {
		sum `var' if `touse', meanonly
		if `i' == 0 {
			tempname ref
			scalar `ref' = r(mean)
			local `i++'
		}
		else {
			matrix `init'[1,`i'] = ln(`r(mean)'/`ref')
			local `i++'
		}
	}
	gettoken ref rest: varlist
	foreach eq of local rest {
		local coln "`coln' eta_`eq':_cons"
	}
	matrix colnames `init' = `coln'
	return matrix init = `init'
end

program Display
	syntax [, Level(real `=c(level)') rpr *]
	local diopts "`options'"
	if "`rpr'" != "" {
        local rpr "eform(RPR)"
    }

	if `level' < 10 | `level' > 99 local level = 95
	ml display, level(`level') `diopts' `rpr'
end



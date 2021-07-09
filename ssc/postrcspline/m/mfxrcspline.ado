*! version 1.2.0 MLB 12Dec2013
program define mfxrcspline, rclass
	if c(stata_version) >= 11 {
		version 11
	}
	else {
		version 10
	}
	
	syntax [if] [in],              ///
	[                              ///
	at(str asis)                   ///	
	link(str)                      /// manually specify link if e(cmd) isn't recognized
	CUSTomdydxb(string)            /// manually specify a custom link
	ciopts(str asis)               ///  
	lineopts(str asis)             ///
	level(passthru)                ///
	EQuation(str asis)             ///
	SHowknots                      ///
	YTItle(passthru)               ///
	legend(passthru)               ///
	addplot(str asis)              /// extra overlaid graph
	GENerate(namelist max=3)       ///
	noci                           ///   
	*                              /// other -twoway options 
	]
	
	marksample touse
	
	local splines : char _dta[rcsplines]
	local oldvar : char _dta[oldvar]
	local knots : char _dta[knots]
	
	if "`splines'" == "" | "`oldvar'" == "" | "`knots'" == "" {
		di as err "adjustrcspline can only be used when the spline was created with mkspine2 with the cubic option"
		exit 198
	}
	
	capture confirm variable `oldvar'
	if _rc {
		di as err "the original variable on which the spline is based needs to be present in the dataset"
		exit 198
	}
	
	tempname b
	matrix `b' = e(b)
	local indepvars : colnames `b'
	local ok : list splines in indepvars
	if !`ok' {
		di as err "all variables created in the last call to mkspline2 must be"
		di as err "independent variables in the last estimation command"
		exit 198
	}

	capture assert `:word count `generate'' != 2
	if _rc {
		di as err "only 1 or 3 new variables can be specified in the generate option"
		exit 198
	}
	if "`generate'" != "" {
		confirm new variable `generate'
	}
	
	if `"`equation'"' != "" {
		local eq `"[`equation']"'
	}
	
	tempname b
	matrix `b' = e(b)
	local indepvars : colnames `b'
	
// Collect and check the link function
	if "`link'" != "" {
		// allow case insensitive link names
		local link = lower("`link'")
		
		// allow abreviations
		local l = max(4,length("`link'"))
		
		if "`link'" == substr("log", 1, `l') {
			local link = "probit"
		}
		else if "`link'" == substr("identity", 1, `l') {
			local link = "identity"
		}
		else if "`link'" == substr("logit", 1, `l') {
			local link = "logit" 
		}
		else if "`link'" == substr("probit", 1, `l') {
			local link = "probit"
		}
		else if "`link'" == substr("logcomplement",1,`l') {
			local link = "logcomplement"
		}
		else if "`link'" == substr("loglog", 1, `l') {
			local link = "loglog"
		}
		else if "`link'" == substr("cloglog", 1, `l') {
			local link = "cloglog"
		}
		else if "`link'" == substr("reciprocal", 1, `l') {
			local link = "reciprocal"
		}
		else if "`: word 1 of `link''" == substr("power", 1, `l') {
			capture confirm numeric `: word 2 of `link''
			if _rc {
				di as error "the second element specified in the link() option should be a number when specifying the power link "
				exit 198
			}
			if `: word 2 of `link'' == 0 {
				local link "log"
			}
			else {
				local link = "power `: word 2 of `link''"
			}
		}
		else if "`: word 1 of `link''" == substr("opower", 1, `l') {
			capture confirm numeric `: word 2 of `link''
			if _rc {
				di as error "the second element specified in the link() option should be a number when specifying the odds power link "
				exit 198
			}
			if `: word 2 of `link'' == 0 {
				local link "logit"
			}
			else {
				local link = "opower `: word 2 of `link''"
			}
		}
		else {
			di as err "link `link' not recognized"
			exit 198
		}
	}
	else if "`customdydxb'" == "" {
		if inlist("`e(cmd)'", "regress") | ///
		   ("`e(cmd)'" == "glm" & "`e(linkt)'" == "Identity") {
			local link "identity"
		}
		if inlist("`e(cmd)'", "logit",      ///
	                              "logistic",   ///
	                              "betafit",    ///
	                              "seqlogit") | ///
	           ("`e(cmd)'" == "glm" & "`e(linkt)'" == "Logit") {
	        	local link "logit"   
	        }
	        if inlist("`e(cmd)'", "probit") | ///
	           ("`e(cmd)'" == "glm" & "`e(linkt)'" == "Probit") {
	        	local link = "probit"   
	        }
	        if inlist("`e(cmd)'", "poisson", "nbreg") |  ///
	           ("`e(cmd)'" == "glm" & "`e(linkt)'" == "Log") {
	        	local link = "log"
	        }
	        if "`e(cmd)'" == "glm" & "`e(linkt)'" == "Log complement" {
	        	local link = "logcomplement"
	        }
	        if "`e(cmd)'" == "glm" & "`e(linkt)'" == "Log-log" {
	        	local link = "loglog"
	        }
	        if ("`e(cmd)'" == "glm" & "`e(linkt)'" == "Complementary log-log") | ///
	           "`e(cmd)'" == "cloglog" {
	        	local link = "cloglog"
	        }
	        if "`e(cmd)'" == "glm" & "`e(linkt)'" == "Reciprocal" {
	        	local link = "reciprocal"
	        }
	        if "`e(cmd)'" == "glm" & strpos("`e(linkt)'", "Power") == 1 {
	        	local link = "power `e(power)'"
	        }
	        if "`e(cmd)'" == "glm" & "`e(linkt)'" == "Odds power" {
	        	local link = "opower `e(power)'"
	        }
	}
	
	if "`link'`customdydxb'" == "" & "`e(cmd)'" != "glm" {
		di as err "last estimation command (`e(cmd)') was not recognized"
		di as err "specify the link() or customdydxb() option to manually specify the link function"
		exit 198
	}
	if "`link'`customdydxb'" == "" & "`e(cmd)'" == "glm" {
		di as err "the `e(linkt)' link function used in the last glm command was not recognized"
		di as err "specify the link() or customdydxb() option to manually specify the link function"
		exit 198
	}
	
// dxb/dx
	local i = 1
	local n : word count `knots'
	foreach k of local knots {
		local k`i++' = `k'
	}
	
	gettoken sp1 rest: splines
	local dxbdx "`eq'_b[`sp1']"
	
	local a1 = 1/((`k`n''-`k1')^2)
	
	local n1 = `n' - 1
	local i = 1
	foreach var of varlist `rest' {
		local a2 = (`k`n''-`k`i'')/((`k`n''-`k`n1'')*(`k`n''-`k1')^2)
		local a3 = (`k`n1''-`k`i'')/((`k`n''-`k`n1'')*(`k`n''-`k1')^2)
		

		local va "cond(`oldvar'-`k`i'' >0, 3*`eq'_b[`var']*`a1'*(`oldvar'-`k`i'' )^2, 0)"
		local vb "cond(`oldvar'-`k`n1''>0, 3*`eq'_b[`var']*`a2'*(`oldvar'-`k`n1'')^2, 0)"
		local vc "cond(`oldvar'-`k`n'' >0, 3*`eq'_b[`var']*`a3'*(`oldvar'-`k`n'' )^2, 0)"
		local dxbdx "`dxbdx' + `va' - `vb' + `vc'"
		local `i++'
	}

// dy/dxb
	// set other covariates at the mean or as specified in at()
	if "`link'" != "identity" {
		if c(stata_version) >= 11 {
			foreach coef of local indepvars {
				_ms_parse_parts `coef'
				if inlist("`r(type)'", "variable", "factor") & !r(omit) local other "`other' `r(name)'"
				if "`r(type)'" == "factor" & !r(omit) local factor "`factor' `r(name)'"
				if "`r(type)'" == "interaction" {
					local intvar ""
					forvalues i = 1/`r(k_names)' {
						local intvar "`r(name`i')'"
						if `: list intvar in splines' {
							di as err "the spline variables may not be part of an interaction"
							exit 198
						}
					}
				}
			}
			local cons "_cons"
			local other : list other - cons	
			local factor : list uniq factor
		}
		else {
			local cons "_cons"
			local other : list indepvars - cons	
		}
		local other : list uniq other
		local other : list other - splines
		
// local notis created because "=" sign might be attached to variable name without space
		local notis : subinstr local at "=" " ", all
		local other : list other - notis

		quietly {
			// gen id var to merge the new vars into the original dataset	
			tempvar id
			qui gen long `id' = _n
	
			preserve
			tempname atmat
			
			if `"`e(offset)'"' != "" {
				local xb `"(xb() + `e(offset)')"'
				tempvar offvar
				qui gen double `offvar' = `e(offset)'
				local expvar `e(offset)'
				// remove "ln(" and ")" in case -exposure()-  was specified instead of offset
				local expvar1 : subinstr local expvar "ln(" "", all  
				if "`expvar1'" != "`expvar'" {
					local exposure "exposure"
				}
				local expvar : subinstr local expvar1 ")" "", all
				if !`: list offvar in notis' {
					sum `offvar' if `touse', meanonly
					if "`exposure'" != "" {
						qui replace `expvar' = exp(r(mean))
						matrix `atmat' = exp(r(mean))
					}
					else {
						qui replace `expvar' = r(mean)
						matrix `atmat' = r(mean)
					}
					local atmatrow "`expvar'"
				}
			}
			else {
				local xb "xb()"
			}
			
			if "`other'" != "" {
				foreach var of local other {
					if `: list var in factor' {
						Leftmode `var' if `touse'
						tempvar t
						qui gen double `t' = r(lmode)
						qui drop `var'
						rename `t' `var'
						matrix `atmat' = nullmat(`atmat') \ `=r(lmode)'
						local atmatrow "`atmatrow' `var'"
					}
					else {
						sum `var' if `touse', meanonly
						tempvar t
						qui gen double `t' = r(mean)
						qui drop `var'
						rename `t' `var'
						matrix `atmat' = nullmat(`atmat') \ `=r(mean)'
						local atmatrow "`atmatrow' `var'"
					}
				}
			}
			local at : subinstr local at " =" "=", all
			local at : subinstr local at "= " "=", all
			local k_at : word count `at'
			tokenize `at'
			forvalues i = 1/`k_at' {
				gettoken var val : `i', parse("=")
				qui drop `var'
				qui gen double ``i''
				matrix `atmat' = nullmat(`atmat') \ ``val''
				local atmatrow "`atmatrow' `var'"
			}
		}
	}


	// link specific derivatives
	if "`link'" == "identity" {
		local dydxb "1"
	}
	if "`link'" == "logit" {
		local dydxb "invlogit(`xb')*invlogit(-`xb')"
	}
	if "`link'" == "probit" {
		local dydxb "normalden(`xb')"
	}
	if "`link'" == "log"{
		local dydxb "exp(`xb')"
	}
	if "`link'" == "logcomplement" {
		local dydxb "-1*exp(`xb')"
	}
	if "`link'" == "loglog"{
		local mu "exp(-1*exp(-1*(`xb')))"
		local dydxb "-1*(`mu')*ln(`mu')"
	}
	if "`link'" == "cloglog" {
		local mu "invcloglog(`xb')"
		local dydxb "(`mu'-1)*ln(1-`mu')"
	}
	if "`link'" == "reciprocal"{
		local dydxb "-1*`xb'^-2"
	}
	if "`: word 1 of `link''" == "power" {
		local power : word 2 of `link'
		local mu "`xb'^(1/`power')"
		local dydxb "1/`power'*(`mu')^(1-`power')"
	}
	if "`: word 1 of `link''" == "opower" {
		local power : word 2 of `link'
		local mu "(1 + `power'*`xb')^(1/`power') / (1 + (1 + `power'*`xb')^(1/`power'))"
		local dydxb "((`mu')*(1-(`mu')))/(1+`power'*xb())"
	}
	if "`customdydxb'" != "" {
		local dydxb "`customdydxb'"
	}
	
// dy/dx
	tempvar eff lb ub mis mark
	qui predictnl double `eff' = (`dydxb')*(`dxbdx') if `touse' , ci(`lb' `ub') `level'
	
	qui gen byte `mis' = missing(`oldvar')
	qui bys `oldvar' `mis' : gen byte `mark' = _n == 1 if `mis' == 0
	
	if "`showknots'" != "" {
		local shknots "xline(`knots')"
	}
	if `"`ytitle'"' == "" {
		if c(stata_version) >= 11 {
			local ytitle `"ytitle("({&part} `e(depvar)')/({&part} `oldvar')")"'
		}
		else {
			local ytitle `"ytitle("(d `e(depvar)')/(d `oldvar')")"'
		}
	}
	if `"`legend'"' == "" {
		local legend "legend(nodraw)"
	}
	
	if "`ci'" == "" {
		twoway rarea `lb' `ub' `oldvar' if `mark',   ///
		       sort                                  /// 
		       `ciopts' ||                           ///
		       line `eff' `oldvar' if `mark',        ///
		       sort                                  ///
		       lpattern(solid)                       ///
		       `ytitle'                              ///
		       `shknots'                             ///
		       `lineopts'                            ///
        	   `legend'                              ///
		       `options'                             ///
		       || `addplot'
	}
	else {	
		twoway line `eff' `oldvar' if `mark',        ///
		       sort                                  ///
		       lpattern(solid)                       ///
		       `ytitle'                              ///
		       `shknots'                             ///
		       `lineopts'                            ///
	       	   `legend'                              ///
		       `options'                             ///
		       || `addplot'
	}
	
	if "`link'" != "identity" & "`generate'" == ""{
		qui restore
	}
	if "`link'" != "identity" & "`generate'" != ""{
		qui keep `id' `eff' `lb' `ub'
		sort `id'
		tempfile newvars
		qui save `newvars'
		qui restore
		sort `id'
		tempvar merge
		qui merge `id' using `newvars', _merge(`merge')
	}
	
	if `: word count `generate'' == 1 {
		gen double `generate' = `eff'	
	}
	if `: word count `generate'' == 3 {
		tokenize `generate'
		gen double `1' = `eff'
		gen double `2' = `lb'
		gen double `3' = `ub'
	}
	
	capture confirm matrix `atmat' 
	if !_rc {
		matrix rownames `atmat' = `atmatrow'
		matrix colnames `atmat' = "value"
		return matrix atmat = `atmat'
	}
	
end

program define Leftmode, sort rclass
	syntax varname [if]
	marksample touse

	tempvar freq minus
	quietly {
		bys `touse' `varlist' : gen `freq' = sum(`touse')*`touse'
		by  `touse' `varlist' : replace `freq' = (_n == _N)*`freq'[_N]
		gen `minus' = -`varlist'
		sort `touse' `freq' `minus' 
	}
	return scalar lmode = `varlist'[_N]
end

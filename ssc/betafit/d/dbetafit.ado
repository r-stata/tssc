*! MLB 1.1.7 07 Apr 2011
*above shift to version number of betafit
* MLB 1.3.0 06 Apr 2011
* MLB 1.2.0 01 Nov 2009
* MLB 1.1.0 20 Jan 2007 
* MLB 1.0.0 08 Aug 2006 
program dbetafit, rclass
	if c(stata_version) >= 11 {
		version 11
	}
	else {
		version 8.2
	}
	syntax [, at(string) ]
	if "`e(cmd)'" != "betafit" {
		di as err "results for betafit not found"
		exit 301
	}
	if "`e(title)'" != "ML fit of beta (mu, phi)" {
		di as err "dbetafit only possible with alternative parameterization"
		exit 301
	}

	/* get variable names */
	local vars: colnames(e(b_mu))
	
	if "`e(munocons)'" == "" {
		local cons "_cons"
		local vars : list vars - cons
	}
	else {
		foreach var of local vars {
			capture assert `var' == 1 if e(sample)
			if !_rc {
				local hascons "`var'"
			}
		}
	}
	if c(stata_version) >= 11 {
		foreach var of local vars {
			_ms_parse_parts `var'
			if inlist("`r(type)'", "interaction", "product") {
				di as err "dbetafit cannot meaningfully handle interactions, use margins instead"
				exit 198
			}
		}
	}
	
	/* make matrix with values at which effects are to be evaluated
	   and summary stats */	
	tempname partat atx
	if "`at'" != "" {
		tokenize `at'
		local length : word count `at'
		local length = `length'/2
		local end = 2*`length'
		
		forvalues i = 1(2)`end' {
			local atvars "`atvars' ``i''"
		}

		local i = 1
		matrix `partat' = J(`length',5,0)

		foreach var of local atvars {
			local valid  : list var in vars
			if `valid' == 0 {
				di as err "`var' is not an explanatory variable in the last model"
				exit 198
			}
			local j = `i' *2
			if real("``j''") != . {
				quietly sum `var' if e(sample)
				matrix `partat'[`i',1] = ``j'', r(mean), r(sd), r(min), r(max)
			}
			else {
				quietly sum `var' if e(sample), detail 
				local stat = cond("``j''"=="median", "p50", "``j''")
				local stats "mean min max p1 p5 p10 p25 p50 p75 p90 p95 p99"
				local valid : list stat in stats
				if `valid' {
					matrix `partat'[`i',1] = r(`stat'), /*
					   */ r(mean), r(sd), r(min), r(max)
				}
				else {
					di as err "You requested that the variable `var' is evaluated at `stat'."
					di as err "Variables can only be evaluated at a number or at"
					di as err "mean, median, min, max, p1, p5, p10, p25, p50, p75, p90, p95, and p99."
					exit 198
				}
			}
			local atvarlist "`atvarlist' `var'"
			local `++i'
		}
		matrix rownames `partat' = `atvarlist'
		matrix colnames `partat' = x mean sd min max
	}


	
	local k : word count `vars'
	matrix `atx' = J(`k',5,0)
	local i = 1
	foreach var of local vars {
		local part : list var in atvarlist
		if `part' == 1 matrix `atx'[`i',1] = `partat'[rownumb(`partat',"`var'"),1..5]
		else {
			quietly sum `var' if e(sample)
			matrix `atx'[`i',1] = r(mean), r(mean), r(sd), r(min), r(max)
		}
		local `++i'
	}
	
	matrix rownames `atx' = `vars'
	matrix colnames `atx' = x mean sd min max
	
	tempname summary b v xb xb1 xb2
	matrix `b' = e(b)
	matrix `b' = `b'[1, "mu:"]
	matrix `v' = e(V)
	
	matrix `summary' = `atx'
	if "`e(munocons)'" == ""  {
		matrix `atx' = `atx'[1...,1] \ 1
	}
	
	matrix `xb' = `b'*`atx'
	scalar `xb' = el(`xb', 1, 1)

	local vars : list vars - hascons
	local k : word count `vars'
	
	tempname minmax unit sd marg maxmarg b
	matrix `minmax'  = J(`k',2,.)
	matrix `unit'    = J(`k',2,.) 
	matrix `sd'      = J(`k',2,.) 
	matrix `marg'    = J(`k',2,.) 
	matrix `maxmarg' = J(`k',2,.)

	
	local i = 0
	foreach var of local vars {
		quietly {
			local `i++'
			local varn : subinstr local var "." ""
			tempvar unique`varn'
			capture bys `var': gen byte `unique`varn'' =  _n==1
			if _rc {
				tempvar newvar
				gen `newvar' = `var'
				bys `newvar': gen byte `unique`varn'' =  _n==1
			}
			count if `unique`varn''
			if r(N) > 2 {
				scalar `xb1' = `xb' - `atx'[`i',1]*_b[`var'] + _b[`var']*`summary'[`i',5]
				scalar `xb2' = `xb' - `atx'[`i',1]*_b[`var'] + _b[`var']*`summary'[`i',4]
				scalar `b' = invlogit(`xb1') - invlogit(`xb2')
				local dg1db "invlogit(`xb1')*invlogit(-1*`xb1') *`summary'[`i',5]"
				local dg2db "invlogit(`xb2')*invlogit(-1*`xb2') *`summary'[`i',4]"
				matrix `minmax'[`i',1] = `b', sqrt(`v'[`i',`i']*(`dg1db' - `dg2db')^2)
	
				scalar `xb1' = `xb' + _b[`var']*`summary'[`i',3]/2
				scalar `xb2' = `xb' - _b[`var']*`summary'[`i',3]/2
				scalar `b' = invlogit(`xb1') - invlogit(`xb2')
				local dg1db "invlogit(`xb1')*invlogit(-1*`xb1') *(`summary'[`i',1]+`summary'[`i',3]/2)"
				local dg2db "invlogit(`xb2')*invlogit(-1*`xb2') *(`summary'[`i',1]-`summary'[`i',3]/2)"
				matrix `sd'[`i',1] = `b', sqrt(`v'[`i',`i']*(`dg1db' - `dg2db')^2)
	
				scalar `xb1' = `xb' + _b[`var']*.5
				scalar `xb2' = `xb' - _b[`var']*.5
				scalar `b' = invlogit(`xb1') - invlogit(`xb2')
				local dg1db "invlogit(`xb1')*invlogit(-1*`xb1') *(`summary'[`i',1]+.5)"
				local dg2db "invlogit(`xb2')*invlogit(-1*`xb2') *(`summary'[`i',1]-.5)"
				matrix `unit'[`i',1] = `b', sqrt(`v'[`i',`i']*(`dg1db' - `dg2db')^2)
	
				local p "invlogit(`xb')"
				local pp "invlogit(-1*`xb')"
				scalar `b' = `p'*`pp'*_b[`var']
				local dgdb "`p'*`pp'* (_b[`var']*`summary'[`i',1] - 2*_b[`var']*`summary'[`i',1]*`p'+1)"
				matrix `marg'[`i',1] = `b', sqrt(`v'[`i',`i']*(`dgdb')^2)
	
				matrix `maxmarg'[`i',1] = _b[`var']/4, _se[`var']/4
			}
			else {
				scalar `xb1' = `xb' - `atx'[`i',1]*_b[`var'] + _b[`var']*`summary'[`i',5]
				scalar `xb2' = `xb' - `atx'[`i',1]*_b[`var'] + _b[`var']*`summary'[`i',4]
				scalar `b' = invlogit(`xb1') - invlogit(`xb2')
				local dg1db "invlogit(`xb1')*invlogit(-1*`xb1') *`summary'[`i',5]"
				local dg2db "invlogit(`xb2')*invlogit(-1*`xb2') *`summary'[`i',4]"
				matrix `minmax'[`i',1] = `b', sqrt(`v'[`i',`i']*(`dg1db' - `dg2db')^2)
			}
		}
	}


	di in text "{hline 14}{c TT}{hline 64}
	di in text "discrete" _col(15) "{c |}  Min --> Max               +-SD/2                  +-1/2" 
	di in text "change"   _col(15) "{c |}  coef.     se           coef.     se            coef.     se"
	di in text "{hline 14}{c +}{hline 64}
	local i = 1
	foreach var of local vars{
		local bminmax  = el(`minmax',`i',1)
		local seminmax = el(`minmax',`i',2)
		if el(`sd',`i',1) != . {
			local bsd      = el(`sd',`i',1)
			local sesd     = el(`sd',`i',2)
			local b1       = el(`unit',`i',1)
			local se1      = el(`unit',`i',2)
		}
		else {
			local bsd      = ""
			local sesd     = ""
			local b1       = ""
			local se1      = ""
		}
		output_line `var' `bminmax' `seminmax' `bsd' `sesd' `b1' `se1' 
		local `i++'
	}
	di in text "{hline 14}{c BT}{hline 64}
	
	di _newline(1)
	
	di in text "{hline 14}{c TT}{hline 41}
	di in text "Marginal"  _col(15) "{c |}    MFX at x                Max MFX" 
	di in text "Effects"   _col(15) "{c |}  coef.     se           coef.     se"
	di in text "{hline 14}{c +}{hline 41}
	local i = 1
	foreach var of local vars{
		local varn: subinstr local var "." ""
		quietly count if `unique`varn''
		if r(N) > 2 {
			local bmarg     = el(`marg',`i',1)
			local semarg    = el(`marg',`i',2)
			local bmaxmarg  = el(`maxmarg',`i',1)
			local semaxmarg = el(`maxmarg',`i',2)
			output_line `var' `bmarg' `semarg' `bmaxmarg' `semaxmarg'
		}
		local `i++'
	}
	di in text "{hline 14}{c BT}{hline 41}
	
	di _newline(1)
	
	di in text "E(" e(depvar) "|x) = " as result %6.0g invlogit(`xb')
	
	di _newline(1)
	
	matrix list `summary', noheader noblank format(%6.0g) 
	
	matrix rownames `minmax'  = `vars'
	matrix rownames `sd'      = `vars'
	matrix rownames `unit'    = `vars'
	matrix rownames `marg'    = `vars'
	matrix rownames `maxmarg' = `vars'
	matrix colnames `minmax'  = "coef" "se"
	matrix colnames `sd'      = "coef" "se"
	matrix colnames `unit'    = "coef" "se"
	matrix colnames `marg'    = "coef" "se"
	matrix colnames `maxmarg' = "coef" "se"
	
	
	return matrix summary = `summary'
	return matrix maxmarg = `maxmarg'
	return matrix marg    = `marg'
	return matrix unit    = `unit'
	return matrix sd      = `sd'
	return matrix minmax  = `minmax'
	
	return scalar pr      = invlogit(`xb')
end	

program output_line
	args var b1 se1 b2 se2 b3 se3
	noi di in text %13s abbrev("`var'",12) " {c |}" /*
	   */ as result /*
	   */          %6.0g `b1' _col(25) %6.0g `se1' /*
	   */ _col(39) %6.0g `b2' _col(49) %6.0g `se2' /*
	   */ _col(62) %6.0g `b3' _col(72) %6.0g `se3' 
end


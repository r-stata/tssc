*! version 1.3.0 PR 04jan2018
program define marginscontplot2
version 12.1

if "`e(cmd)'" == "" {
	error 301
}

syntax [anything(name=xlist)] [if] [in] [, at(string) at1(string) at2(string) ///
 ci Formatlegend(string) MARgopts(string) name(string) nograph PLOTopts(string) ///
 PREfix(string) SHowmarginscmd SAVing(string) var1(string) var2(string) ///
 AREAopts(string) COMBopts(string) LINEopts(string) ]

if "`name'" != "" local name name(`name')

if (`"`saving'"' == "") & ("`prefix'" != "") {
	di as txt "[prefix(`prefix') ignored]"
}

if `"`plotopts'"' != "" & `"`areaopts'`combopts'`lineopts'"' != "" {
	di as err "plotopts() may not be used with areaopts(), combopts() or lineopts()"
	exit 198
}

if `"`at'"' != "" {
	// Check whether at() has >1 margin (not permitted)
	qui margin, at(`at')
	if colsof(r(b)) > 1 {
		di as err "at() may only define one margin; yours specifies " colsof(r(b))
		exit 198
	}
}

local format = cond("`formatlegend'" == "", "%9.0g", "`formatlegend'")

GetVL `xlist'

local nx = r(nx)
if (`nx' < 1) error 102
if (`nx' > 4) error 103
local bad 0
if `nx' == 1 {
	local x1 `r(xvar1)'
	local nx 1
}
else if `nx' == 2 {
	if "`r(paren2)'" != "" {
		local x1 `r(xvar1)'
		local x1a `r(xvar2)'
		local nx 1
	}
	else {
		local bad = ("`r(paren1)'`r(paren2)'" != "")
		if !`bad' {
			local x1 `r(xvar1)'
			local x1a
			local x2 `r(xvar2)'
			local x2a
		}
	}
}
else if `nx' == 3 {
	local bad = ("`r(paren1)'" != "") | ///
			("`r(paren2)'" != "" & "`r(paren3)'" != "") | ///
			("`r(paren2)'" == "" & "`r(paren3)'" == "")
	if !`bad' {
		local x1 `r(xvar1)'
		if ("`r(paren2)'" != "") {
			local x1a `r(xvar2)'
			local x2 `r(xvar3)'
			local x2a
		}
		else {
			local x1a
			local x2 `r(xvar2)'
			local x2a `r(xvar3)'
		}
	}
}
else {
	local bad = ("`r(paren2)'" == "") | ///
			("`r(paren4)'" == "") | ///
			("`r(paren1)'" != "") | ///
			("`r(paren3)'" != "")
	if !`bad' {
		local x1 `r(xvar1)'
		local x1a `r(xvar2)'
		local x2 `r(xvar3)'
		local x2a `r(xvar4)'
	}
}
if `bad' {
	di as err "invalid `xlist'"
	exit 198
}
if `nx' == 1 & "`at2'`var2'" != "" {
	di as err "invalid at2(`at2') or var2(`var2'), not needed as only one variable is being plotted"
	exit 198
}
local reversal 0 // for when first FP power is <0, need to reverse range of at1 values to get correct plot.
forvalues k = 1 / 2 {
	local treat_as_cat`k' 0 // set to 1 if variable is factor and has no at`k'() or var`k'() option set
	// Check if x`k'a or x`k' is in model and if x`k' is a factor variable
	if "`x`k'a'" != "" {
		capture _ms_extract_varlist `x`k'a'
		if c(rc) {
			di as err "`x`k'a' not in model"
			exit 111
		}
		local term`k' c.(`x`k'a')
	}
	else {
		// Strip leading "i." if present
		local x`k' = substr("`x`k''", 1 + strpos("`x`k''", "."), .)
		capture _ms_extract_varlist `x`k''
		if c(rc) {
			capture _ms_extract_varlist i.`x`k''
			if (c(rc) == 0) local term2 i.`x`k''
			else {
				di as err "neither `x`k'' nor i.`x`k'' are in the model"
				exit 111
			}
		}
		else local term`k' c.`x`k''
	}

	// Check for syntax var`k'(#) to replace r`k'(#)
	capture confirm integer number `var`k''
	if c(rc) == 0 {
		local r`k' `var`k''
		local var`k'
	}
	if "`r`k''" != "" & "`at`k''" != "" {
		di as err "cannot combine at`k'() with var`k'(#)"
		exit 198
	}

	// Parse var1 and var2 options. If given, they should resemble
	// xlists, and may include parens.
	if "`var`k''" != "" {
		GetVL `var`k''
		local nv`k' = r(nx)
		if (`nv`k'' < 1) error 102
		if (`nv`k'' > 2) error 103
		local v`k' `r(xvar1)'
		if ("`r(paren2)'" != "") {
			local v`k'a `r(xvar2)'
			if "`v`k'a'" != "" & "`x`k'a'" == "" {
				di as err "invalid `v`k'a'"
				exit 198
			}
			if "`v`k'a'" == "" & "`x`k'a'" != "" {
				di as err "invalid `var`k'', term(s) corresponding to `x`k'a' missing"
				exit 198
			}
			local nvar`k': word count `v`k'a'
			if `nvar`k'' != wordcount("`x`k'a'") {
				di as err "invalid `v`k'a', should have wordcount("`x`k'a'") terms"
				exit 198
			}
		}
		copy_values `v`k'', local(at`k')
		local nat`k': word count `at`k''
		forvalues j = 1 / `nat`k'' {
			local at`k'`j': word `j' of `at`k''
		}
		if "`v`k'a'" != "" {
			forvalues i = 1 / `nvar`k'' {
				local X`k'`i' : word `i' of `x`k'a'
				local v : word `i' of `v`k'a'
				copy_values `v', local(X)
				forvalues j = 1 / `nat`k'' {
					local at`k'tsf`i'`j': word `j' of `X'
				}
			}
		}
		else {
			local nvar`k' 1
			local i 1
			local X`k'`i' `x`k''
			forvalues j = 1 / `nat`k'' {
				local at`k'tsf`i'`j' `at`k'`j''
			}
		}
	}
	else {
		// Extract at`k' values, i.e. values of x`k' (x1 or x2) at which f(x1, x2) is evaluated
		local nat`k' 0
		if "`x`k''" != "" {
			if "`r`k''" != "" {
				tempvar range
				qui sum `x`k'' `if' `in', meanonly
				local left  : di `format' r(min)
				local right : di `format' r(max)
				qui range `range' `left' `right' `r`k''
				qui levelsof `range', local(at`k')
				drop `range'
			}
			if substr("`at`k''", 1, 1) == "%" {
				local percent`k' 1
				local at`k' = substr("`at`k''", 2, .)
			}
			else local percent`k' 0
			if "`at`k''" == "" {
				if `percent`k'' == 1 {
					di as err "percentile option is inappropriate for plotting the observed values of x`k'"
					exit 198
				}
				// Check if factor variable
				capture margins `x`k''
				if c(rc) == 0 {
					// `x`k'' is a factor variable; goes in front of comma in -margins-
					local treat_as_cat`k' 1
					// label levels of `x`k''
					qui levelsof `x`k'' `if' `in', local(X)
					numlist "`X'"
					local X `r(numlist)'
					local nX : word count `X'
					forvalues j = 1 / `nX' {
						local at`k'`j' : word `j' of `X'
						local lab`k'`j' : label (`x`k'') `at`k'`j''
					}
				}
				else {
					// `x`k'' is not a factor variable, just take its levels as-is
					qui levelsof `x`k'' `if' `in', local(at`k')
				}
			}
			if `treat_as_cat`k'' == 0 {
				numlist "`at`k''", sort // !! Note: now sort !!
				local at`k' `r(numlist)'
				local nat`k' : word count `at`k''
				// Count distinct at values
				local distinct_at 0
				forvalues j = 1 / `nat`k'' {
					local ++distinct_at
					local atj : word `j' of `at`k''
					if `percent`k'' {
						qui centile `x`k'' `if' `in', centile(`atj')
						if `distinct_at' > 1 {
							if (r(c_1) > `c') { // centiles are distinct
								local c : di `format' r(c_1)
								local at`k'`distinct_at' = trim("`c'")
							}
							else local --distinct_at // centiles are not distinct
						}
						else {
							local c : di `format' r(c_1)
							local at`k'`distinct_at' = trim("`c'")
						}
					}
					else local at`k'`distinct_at' `atj'
*di in red "j=`j' distinct = `distinct_at' at = `at`k'`distinct_at''"
					local lab`k'`distinct_at' : label (`x`k'') `at`k'`distinct_at''
				}
				local nat`k' `distinct_at'
				if "`x`k'a'" != "" { // x`k' has an FP or linear transformation whose name(s), `x`k'a', are in parens
					// compute and store functions of each `slice' value for each FP term in x`k'a
					local nvar`k': word count `x`k'a'
					// Check if first var of `x`k'a' has notes: if so, assume origin is -fp-.
					local X : word 1 of `x`k'a'
					fp_extract_info `X'
					if r(hasnotes) {
						// Code for use with -fp- generated variables
						local powers `r(powers)'
						local a = r(a)
						local b = r(b)
						local c = r(c)
						if ("`c'" == ".") local c
						else local c c(`c')
						// Eval FP functions of "at" values with above parameters
						tempname at_tsf
						forvalues j = 1 / `nat`k'' {
							// `nat`k'' is the # of "at" values for variable `x`k'' (k = 1, 2)
							fpeval, x(`at`k'`j'') p(`powers') a(`a') b(`b') `c'
							matrix `at_tsf' = r(result)
							forvalues i = 1 / `nvar`k'' {
								local X`k'`i' : word `i' of `x`k'a'
								local at`k'tsf`i'`j' = `at_tsf'[1, `i']
							}
						}
					}
					else {
						local 0: char `X'[fp]
						if `"`0'"' == "" {
							noi di as error "no fractional polynomial information found for `x`k'a'"
							exit 198
						}
						// Code for use with -fracpoly- or -fracgen- generated variables
						forvalues i = 1 / `nvar`k'' {
							local X`k'`i' : word `i' of `x`k'a'
							local 0: char `X`k'`i''[fp] // e.g. "X^2*ln(X): X = age/10", or "bmi-25.53789165"
							mata: _parse_colon("hascolon", "rhs")
							local exp_left `0'
							local exp_right
							if "`rhs'" != "" {
								local 0 `rhs'
								syntax anything =/exp
								local exp_right `exp'
								forvalues j = 1 / `nat`k'' {
									local X : subinstr local exp_right "`x`k''" "`at`k'`j''"
									local Xval = `X'
									local Y : subinstr local exp_left "X" "`Xval'", all
									local at`k'tsf`i'`j' = `Y'
								}
							}
							else {
								// Variable name is included explicitly in `exp_left';
								// substitute for `slice' value(s)
								forvalues j = 1 / `nat`k'' {
									local X : subinstr local exp_left "`x`k''" "`at`k'`j''", all
									local at`k'tsf`i'`j' = `X'
								}
							}
						}
					}
					// check for reversal of FP-transformed values across range of at1.
					// Occurs if first FP power is <0.
					if `k'==1 {
						local i 1
						local j1 1
						local j2 `nat`k''
						local reversal = (`at`k'tsf`i'`j2'' < `at`k'tsf`i'`j1'')
					}
				}
				else {
					local nvar`k' 1
					local i 1
					local X`k'`i' `x`k''
					forvalues j = 1 / `nat`k'' {
						local at`k'tsf`i'`j' `at`k'`j''
					}
				}
			}
		}
	}
}

// Prepare at-strings for -margins-
local ats
local nats 0
local nx1a : word count `x1a'
local nx2a : word count `x2a'
if `nx1a' > 1 & `nx2a' > 1 {
	// need an at for every combination of x1a and x2a
	forvalues j1 = 1 / `nat1' {
		local this1
		forvalues i = 1 / `nx1a' {
			local this1 `this1' `X1`i''=`at1tsf`i'`j1''
		}
		forvalues j2 = 1 / `nat2' {
			local this2
			forvalues i = 1 / `nx2a' {
				local this2 `this2' `X2`i''=`at2tsf`i'`j2''
			}
			local ats `ats' at(`at' `this1' `this2')
			local ++nats
		}
	}
}
else if `nx1a' > 1 {
	// at values for x2 are clumped. Build at() part for x2.
	if `nat2' > 0 {
		local i 1
		local this2 `X2`i''=(
		forvalues j2 = 1 / `nat2' {
			local this2 `this2' `at2tsf`i'`j2''
		}
		local this2 `this2')
	}
	// Build at() part for x1
	forvalues j1 = 1 / `nat1' {
		local this1
		forvalues i = 1 / `nx1a' {
			local this1 `this1' `X1`i''=`at1tsf`i'`j1''
		}
		local ats `ats' at(`at' `this1' `this2')
		local ++nats
	}
}
else if `nx2a' > 1 {
	// at values for x1 are clumped. Build at() part for x1.
	if `nat1' > 0 {
		local i 1
		local this1 `X1`i''=(
		forvalues j1 = 1 / `nat1' {
			local this1 `this1' `at1tsf`i'`j1''
		}
		local this1 `this1')
	}
	// Build at() part for x2
	forvalues j2 = 1 / `nat2' {
		local this2
		forvalues i = 1 / `nx2a' {
			local this2 `this2' `X2`i''=`at2tsf`i'`j2''
		}
		local ats `ats' at(`at' `this1' `this2')
		local ++nats
	}
}
else {
	// Make use of concatenated at1 and at2 here in a single at() option
	local i 1
	if `nat1' > 0 {
		local this1 `X1`i''=(
		forvalues j1 = 1 / `nat1' {
			local this1 `this1' `at1tsf`i'`j1''
		}
		local this1 `this1')
	}
	if `nat2' > 0 {
		local this2 `X2`i''=(
		forvalues j2 = 1 / `nat2' {
			local this2 `this2' `at2tsf`i'`j2''
		}
		local this2 `this2')
	}
	local ats at(`at' `this1' `this2')
	local nats 1
}
if `nats' > 70 {
	di as err "too many at() options (`nats'), cannot execute -margins-; max is 70"
	exit 1003
}
if `treat_as_cat1' & `treat_as_cat2' {
	di as err "must specify at#() or var#() option for at least one of xvar1 or xvar2"
	exit 198
}

// Margins and plot
quietly {
	// Copy values to local macro if necessary
	local ndim = `treat_as_cat1' + `treat_as_cat2' + (`nat1' > 0) + (`nat2' > 0)
	local marv
	forvalues j = 1 / 2 {
		if `treat_as_cat`j'' {
			// x`j' goes before the brackets in margins
			local marv `x`j''
			levelsof `x`j'', local(at`j')
			local nat`j' : word count `at`j''
			forvalues i = 1 / `nat`j'' {
				local at`j'`i' : word `i' of `at`j''
			}
		}
	}
	local marginsdim = `nat1' * `nat2'
	local matsize = c(matsize)
	if `marginsdim' > `matsize' {
		di as err "too many parameter values (`marginsdim') for the current {helpb matsize} (`matsize')"
		di as err "either reduce the number of values in at1(), at2(), var1(), or var2(),"
		di as err "or type {cmd:set matsize `marginsdim' and re-run the command}"
		exit 908
	}
	tempfile filenm
	if ("`showmarginscmd'" != "") noi di as txt `"margins `marv', `ats' `margopts'"'
	capture margins `marv', `ats' `margopts' saving(`"`filenm'"', replace)
	local rc = c(rc)
	if `rc' {
		di as err "There was a problem executing -margins-."
		di as err "The command issued was essentially as follows:"
		di as err `"margins `marv', `ats' `margopts'"'
		exit `rc'
	}
	preserve
	use `"`filenm'"', clear

	// Store values of second variable for use in legend
	forvalues i = 1 / `nat2' {
		local legend `"`legend' label(`i' "`x2' = `lab2`i''")"'
	}

	// If 2 dimensions, reshape data for plotting.
	// Need to determine which data structure margins has created.
	if `ndim' > 1 {
		local u_at : char _dta[_u_at_vars]
		capture confirm var _m1
		if c(rc)==0 {
			if (`treat_as_cat1') sort _m1 `u_at'
			else sort `u_at' _m1
		}
		else {
			sort `u_at' // at2 within at1
		}
		genlev i `nat1' `nat2'
		genlev j `nat2' 1
		keep _margin _ci_lb _ci_ub i j
		reshape wide _margin _ci_lb _ci_ub, i(i) j(j)

		// Store values of first variable for use as x dimension in plot
		local x `x1'
		local leg legend(`legend')
		gen `x' = .
		local i2 `nat1'
		forvalues i = 1 / `nat1' {
			if `reversal' {
				qui replace `x1' = `at1`i'' in `i2'
			}
			else qui replace `x1' = `at1`i'' in `i'
			local --i2
		}
	}
	else {
		keep _margin _ci_lb _ci_ub
		// Store values of first variable for use as x dimension in plot
		local x `x1'
		local leg legend(off)
		gen `x' = .
		forvalues i = 1 / `nat1' {
			qui replace `x1' = `at1`i'' in `i'
		}
	}
}
// Plot
if "`graph'" != "nograph" {
	if "`ci'" == "" {
		line _margin* `x', sort `leg' `lineopts' `plotopts' `name'
	}
	else {
		if `nat2' > 0 {
			local gi
			forvalues i = 1 / `nat2' {
				tempname g`i'
				twoway (rarea _ci_lb`i' _ci_ub`i' `x', sort pstyle(ci) `areaopts') ///
				 (line _margin`i' `x', sort lstyle(refline) `lineopts'), legend(off) ///
				 title("`x2' = `lab2`i''") name(`g`i'', replace) nodraw
				local gi `gi' `g`i''
			}
			graph combine `gi', `combopts' `plotopts' `name'
		}
		else {
			twoway (rarea _ci_lb _ci_ub `x', sort pstyle(ci) `areaopts') ///
			 (line _margin `x', sort lstyle(refline) `lineopts'), `leg' `plotopts' `name'
		}
	}
	if `"`saving'"' != "" {
		_prefix_saving `saving'
		local saving `"`s(filename)'"'
		local replace `"`s(replace)'"'
		// Rename margins-related variables with prefix `prefix'
		if "`prefix'" != "" {
			foreach v of varlist _margin* _ci_lb* _ci_ub* {
				rename `v' `prefix'`v'
			}
		}
		save `"`saving'"', `replace'
	}
}
end

program define GetVL, rclass /* xvarlist [(xvarlist)] ... */
local xlist `0'
if (`"`xlist'"'=="") {
	error 102
}
local nx 0
gettoken xvar xlist : xlist, parse("()") match(par)
while (`"`xvar'"'!="" & `"`xvar'"'!="[]") {
	fvunab xvar : `xvar'
	local nvar : word count `xvar'
	if ("`par'"!="" | `nvar'==1) {
		local ++nx
		local xvar`nx' "`xvar'"
		local xvars "`xvars' `xvar'"
		if ("`par'"!="") local paren`nx' 1
	}
	else {
		tokenize `xvar'
		forvalues i = 1 / `nvar' {
			local ++nx
			local xvar`nx' "``i''"
			local xvars "`xvars' ``i''"
		}
	}
	gettoken xvar xlist : xlist, parse("()") match(par)
	if ("`par'"=="(" & `"`xvar'"'=="") {
		di as err "empty () found"
		exit 198
	}
}
forvalues i = 1 / `nx' {
	return local xvar`i' `xvar`i''
	return local paren`i' `paren`i''
}
return scalar nx = `nx'
end

** v 1.1.0 PR 16mar2010.
** Lachenbruch, STB-7: dm8. (renamed genlev to avoid conflict with Stata 3.05)
program define genlev
	version 6
	args gen levels repeats start
	confirm new var `gen'
	confirm integer num `levels'
	if !missing("`start'") {
		confirm integer num `start'
	}
	if `levels'<1 {
		di in red "invalid `levels'"
		exit 198
	}
	if "`repeats'"=="" {
		local repeats=int(_N/`levels')
		di in bl "[`repeats' repeats assumed]"
	}
	else confirm integer num `repeats'
	if `repeats'<1 {
		di in red "invalid `repeats'"
		exit 198
	}
	gen int `gen' = int(mod((_n-1)/`repeats',`levels'))+1
	if !missing("`start'") {
		qui replace `gen' = `gen' - 1 + `start'
	}
end

program define copy_values
/*
	Copy non-missing values in varname to local macro `local'
	until encounter missing value.
	!! would be faster in Mata.
*/
version 11.0
syntax varname, local(string)
local vals
local n = _N
forvalues i = 1 / `n' {
	if missing(`varlist'[`i']) {
		continue, break
	}
	else {
		local v = `varlist'[`i']
		local vals `vals' `v'
	}
}
c_local `local' `vals'
end

program define fp_extract_info, rclass
version 12
/*
	Extracts FP powers, scale and center info from a variable.
	This variable is the first FP variable, since info for other powers
	comes from the notes for the first variable.
*/
syntax varname
notes _count nn : `varlist'
if `nn' == 0 {
	// no notes found for `varlist'
	return scalar hasnotes = 0
	exit
}
local phr1 fp term 1
local phr2 Scaling was
local phr3 Centering was
forvalues n = 1/`nn' {
	notes _fetch thisnote : `varlist' `n'
	// `j' indexes types of phrase in the notes
	forvalues j = 1/3 {
		if strpos(`"`thisnote'"', "`phr`j''") > 0 {
			if `j' == 1 {
				// extract powers by matching on paren
				gettoken stuff thisnote : thisnote, parse("()") match(par)
				gettoken powers thisnote : thisnote, parse("()") match(par)
			}
			if `j' == 2 {
				// extract a and b
				tokenize `thisnote'
				while "`1'"!="" {
					if (substr("`1'", 1, 2) == "a=") local a = substr("`1'", 3, .)
					if (substr("`1'", 1, 2) == "b=") local b = substr("`1'", 3, .)
					mac shift
				}
			}
			if `j' == 3 {
				// extract centering (c) on original scale
				tokenize "`thisnote'", parse("=")
				while "`1'"!="" {
					if "`1'" == "=" {
						mac shift
						local c `1'
						// Trim trailing "." if present
						if "`c'"!="" & substr("`c'", -1, 1) == "." {
							local c = substr("`c'", 1, length("`c'")-1)
						}
					}
					mac shift
				}
			}
		}
	}
}
// If powers not found then notes are not relevant to -fp-
if "`powers'" == "" {
	return scalar hasnotes = 0
}
else {
	if ("`a'" == "") local a 0
	if ("`b'" == "") local b 1
	if ("`c'" == "") local c .
	return local powers `powers'
	return scalar a = `a'
	return scalar b = `b'
	return scalar c = `c'
	return scalar hasnotes = 1
}
end

program define fpeval, rclass
version 11
/*
	Evaluates an FP function of a scalar, allowing for scsaling
	and centering.
	For args x, powers vector p, scaling scalars a and b, and centering
	scalar c, the result is vector ((x+a)/b)^(p) - ((c+a)/b)^(p).
*/
syntax, x(real) p(string) [ a(real 0) b(real 1) c(string) ]
tempname result
fpcalc `x' "`p'" `a' `b'
matrix `result' = r(result)
if "`c'" != "" {
	confirm num `c'
	fpcalc `c' "`p'" `a' `b'
	matrix `result' = `result' - r(result)
}
return matrix result = `result'
end

program define fpcalc, rclass
version 11
// Evaluate FP of scalar x with powers p and scaling a, b.
// Returns 1 * #powers matrix of results.
args x p a b
tempname small fp h hlast lnx plast xx result
scalar `small' = 1e-6
scalar `xx' = (`x' + `a') / `b'
if `xx' < 0 {
	di as error "negative scaled argument not allowed for FP functions"
	exit 198
}
scalar `lnx' = ln(`xx')
scalar `h' = .
scalar `hlast' = 1
scalar `plast' = 0
local np : word count `p' // FP dimension
matrix `result' = J(1, `np', .)
forvalues j = 1 / `np' {
	local pj : word `j' of `p'
	matrix `result'[1, `j'] = cond(abs(`pj' - `plast') < `small', `lnx' * `hlast', ///
	 cond(abs(`pj') < `small', `lnx', ///
	 cond(abs(`pj' - 1) < `small', `xx', `xx'^`pj')))
	scalar `hlast' = `result'[1, `j']
	scalar `plast' = `pj'
}
return matrix result = `result'
end

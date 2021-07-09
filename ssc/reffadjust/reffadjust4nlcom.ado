*! version 1.1.0 2sep2013 Tom Palmer & Corrie Macdonald-Wallis
program reffadjust4nlcom, rclass
if _caller() >= 13 version 13.0
if _caller() < 13 version 11.2


syntax namelist(min=2 max=5), eqn(string) [sf(numlist min=1 max=4) mcmcsum SUBlevel(numlist min=1 max=1)]

* only allow for certain commands
if c(version) < 13 & !inlist(e(cmd), "runmlwin", "xtmixed", "xtmelogit", "xtmepoisson") {
	di as err "reffadjust4nlcom currently only works for estimates returned by runmlwin, xtmixed, xtmelogit, xtmepoisson."
	error 322
}
else if c(version) >= 13 & !inlist(e(cmd), "runmlwin", "mixed", "meqrlogit", "meqrpoisson") {
	di as err "reffadjustsim currently only works for estimates returned by runmlwin, mixed, meqrlogit, or meqrpoisson."
	error 322
}


* check no repeats in namelist of variables
tempname test test2 eqntest
tokenize "`namelist'"
local len = wordcount("`namelist'")
local y `1'
local colnames : colnames e(V)
* check no repeats in namelist
local nx = `len' - 1
forvalues i=1/`nx' {
	local k = `i' + 1
	forvalues j=`k'/`len' {
		if `i' != `j' {
			if "``i''" == "``j''" {
				di as err "``i'' is repeated in the namelist."
				error 197
			}
		}
	}
}

if e(cmd) == "runmlwin" {
	* option sublevel not allowed with runmlwin
	if "`sublevel'" != "" {
		di as err "Option sublevel not allowed with runmlwin estimates."
		error 197
	}

	if e(converged) != 1 & "`mcmcsum'" == "" {
		if e(method) == "MCMC" {
			di as err `"runmlwin reports e(method) = "MCMC", please use option mcmcsum with MCMC estimates"'
			error 322
		}
		else {
			di as err "runmlwin model did not converge."
			error 322
		}
	}

	if real(e(version)) < 2.23 {
		di as err "reffadjust4nlcom requires runmlwin ouput using MLwiN version 2.23 or above."
		error 322
	}

	* check mlwin estimation method was mcmc
	if "`mcmcsum'" == "mcmcsum" & e(method) != "MCMC" {
		di as err "With option mcmcsum the runmlwin model must be fitted using MCMC."
		error 322
	}

	* check eqn name exists in e(V)
	mata st_numscalar(st_local("eqntest"), sum(strmatch(uniqrows(st_matrixcolstripe("e(V)")[,1]), st_local("eqn"))))
	if `eqntest' == 0 {
		mata st_local("eqnnames", invtokens(uniqrows(st_matrixcolstripe("e(V)")[,1])'))
		di as err "Equation name `eqn' not present in e(V)"
		di as err "Equation name in eqn() option may be one of: `eqnnames'"
		error 322
	}

	* check all the var() colnames exist
	forvalues i = 1/`len' {
		local varcolname : di "var(" abbrev(strtoname("``i''"), 27) ")"
		mata st_numscalar(st_local("test"),sum(strmatch(st_matrixcolstripe("e(V)")[,2], st_local("varcolname"))))
		if (`test' == 0) {
			di as err "No column named `eqn':var(" abbrev(strtoname("``i''"), 27) ") in e(V)." ///
				_n "Check all specified variables are valid for this level."
			error 322
		}
		* check the variance and hence SE of this parameter is not zero
		* if se == 0 issue a warning (could be convergence problem or due to a constraint)
		if _se[`eqn':`varcolname'] == 0 {
			di as err "`eqn':`varcolname' has variance = 0 in e(V)." ///
				_n "It is advised not to run reffadjust4nlcom for this case."
		}
	}

	* create x_i locals with variable names
	* and create cov(y,x_i) expressions
	local i = 1
	while `i' < `len' {
		local j = `i' + 1
		local x`i' ``j''
		local covyx`i' : di "cov(" abbrev(strtoname("`y'"), 13) "\" abbrev(strtoname("`x`i''"), 13) ")"
		mata st_numscalar(st_local("test"),sum(strmatch(st_matrixcolstripe("e(V)")[,2], st_local("covyx`i'"))))
		if (`test' == 0) {
			local covyx`i' : di "cov(" abbrev(strtoname("`x`i''"), 13) "\" abbrev(strtoname("`y'"), 13) ")"
			mata st_numscalar(st_local("test2"),sum(strmatch(st_matrixcolstripe("e(V)")[,2], st_local("covyx`i'"))))
			if (`test2' == 0) {
				di as err "No column named `eqn':cov(" ///
					abbrev(strtoname("`x`i''"), 13) "\" abbrev(strtoname("`y'"), 13) ")" ///
					" or `eqn':cov(" ///
					abbrev(strtoname("`y'"), 13) "\" abbrev(strtoname("`x`i''"), 13) ") in e(V)." ///
					_n "Please check you have not specified the " ///
					"diagonal random part option in runmlwin."
				error 322
			}
		}
		* check the variance and hence SE of this parameter is not zero
		* if se == 0 issue a warning (could be convergence problem or due to a constraint)
		if _se[`eqn':`covyx`i''] == 0 {
			di as err "`eqn':`covyx`i'' has variance = 0 in e(V)." ///
				_n "It is advised not to run reffadjust4nlcom for this case."
		}
		local i = `i' + 1
	}

	* create cov(x_i,x_j) expressions
	local i = 1
	while `i' < `len' {
		forvalues k = `i'/`len' {
			if (`i' != `k') {
				local covx`i'x`k' : di "cov(" abbrev(strtoname("`x`i''"), 13) "\" abbrev(strtoname("`x`k''"), 13) ")"
				mata st_numscalar(st_local("test"),sum(strmatch(st_matrixcolstripe("e(V)")[,2], st_local("covx`i'x`k'"))))
				if (`test' == 0) {
					local covx`i'x`k' : di "cov(" abbrev(strtoname("`x`k''"), 13) "\" abbrev(strtoname("`x`i''"), 13) ")"
					mata st_numscalar(st_local("test2"),sum(strmatch(st_matrixcolstripe("e(V)")[,2], st_local("covx`i'x`k'"))))
					if (`test2' == 0) {
						di as err "No column named `eqn':cov(" ///
							abbrev(strtoname("`x`k''"), 13) "\" abbrev(strtoname("`x`i''"), 13) ")" ///
							" or `eqn':cov(" ///
							abbrev(strtoname("`x`i''"), 13) "\" abbrev(strtoname("`x`k''"), 13) ") in e(V)." ///
							_n "Please check you have not specified the " ///
							"diagonal random part option in runmlwin."
						error 322
					}
				}
				* check the variance and hence SE of this parameter is not zero
				* if se == 0 issue a warning (could be convergence problem or due to a constraint)
				if _se[`eqn':`covx`i'x`k''] == 0 {
					di as err "`eqn':`covx`i'x`k'' has variance = 0 in e(V)." ///
						_n "It is advised not to run reffadjust4nlcom for this case."
				}
			}
			if (`k' == `len' - 1) {
				continue, break
			}
		}
		local i = `i' + 1
	}
}
else if inlist(e(cmd), "xtmixed", "xtmelogit", "xtmepoisson", "mixed", "meqrlogit", "meqrpoisson") {
	* disallow mcmcsum option
	if "`mcmcsum'" == "mcmcsum" {
		di as err "Option mcmcsum only allowed with estimation results from runmlwin." ///
		_n "Your estimation results are from", e(cmd) "."
		error 197
	}

	* check model converged
	if e(converged) != 1 {
		di as err "`e(cmd)' model did not converge."
		error 322
	}

	/*
	note: useful xt ereturned estimates
	e(redim): no of re covariates for each level
	e(vartypes): structure for each level
	 */

	* make a local without repeats in e(ivars)
	local ivars `e(ivars)'
	local uivars : list uniq ivars

	* check eqn name exists in e(V)
	local eivarslist `""`=subinstr("`uivars'", " ", `"",""', .)'""'
	if !inlist("`eqn'", `eivarslist') {
		di as err "Equation name `eqn' not valid"
		di as err "Equation name in eqn() option may be one of: `uivars'"
		error 322
	}
	* check which level the eqn() var is
	local eivarslen = wordcount("`uivars'")
	forvalues i = 1/`eivarslen' {
		if "`eqn'" == word("`uivars'", `i') {
			local relevel `i'
		}
	}
	* option sublevel only allowed if there are repeats of eqn in ivars
	* repeats of eqn in ivars
	mata st_local("eqnreps", strofreal(sum(strmatch(tokens("`ivars'"), "`eqn'"))))
	if `eqnreps' == 1 & "`sublevel'" != "" {
		di as err "`eqn' is not repeated in e(ivars), sublevel option not allowed."
		error 197
	}
	else if `eqnreps' > 1 & "`sublevel'" == "" {
		di as err "`eqn' is repeated in e(ivars), please specify sublevel option."
		error 197
	}
	// work out position of correct eqn in ivars
	local diff = wordcount("`ivars'") - wordcount("`uivars'")
	if `diff' == 0 {
		local repos `relevel'
	}
	else {
		if "`sublevel'" != "" {
			local repos = `relevel' + (`sublevel' - 1)
		}
		else {
			local repos = `relevel' + `diff'
		}
	}
	* set sublevel to 1 it doesn't exist
	if "`sublevel'" == "" {
		local sublevel 1
	}

	* disallow e(vartypes) == "Identity" "Independent" as they do not have covariance terms
	if inlist(word("`e(vartypes)'", `repos'), "Identity", "Independent") {
		di as err "In", e(cmd), "option cov(" word("`e(vartypes)'", `repos') ") not allowed; only exchangeable and unstructured allowed."
		error 322
	}

	* check depvar `y' and indepvars are in e(revars) for corresponding eqn
	local restart 1
	if `repos' > 1 {
		forvalues i=1/`=`repos' - 1' {
			local restart = `restart' + real(word("`e(redim)'", `i'))
		}
	}
	local restop = `restart' + real(word("`e(redim)'", `repos')) - 1
	mata st_local("eqnrevars", invtokens(tokens(st_macroexpand("`e(revars)'"))[strtoreal(st_local("restart"))::strtoreal(st_local("restop"))]))
	mata st_numscalar(st_local("test"), sum(strmatch(tokens(st_macroexpand("`eqnrevars'")), st_local("y"))))
	if `test' != 1 {
		if `eqnreps' > 1 {
			local suberrmessage " sublevel `sublevel'"
		}
		di as err "`y' not one of the random effect variables at: level `eqn'`suberrmessage'."
		error 197
	}

	* create x_i locals with variable names
	* check the x_i are in the revars at the eqn level
	* work out the order number for the x_i
	local i = 1
	while `i' < `len' {
		local j = `i' + 1
		* check this variable is in eqnrevars
		mata st_numscalar(st_local("test"), sum(strmatch(tokens(st_macroexpand("`eqnrevars'")), st_macroexpand("``j''"))))
		if `test' != 1 {
			if `eqnreps' > 1 {
				local suberrmessage " sublevel `sublevel'"
			}
			di as err "``j'' not one of the random effect variables at: level `eqn'`suberrmessage'."
			error 197
		}
		local x`i' ``j''
		* order nos for the x_i
		forvalues k=1/`=real(word("`e(redim)'", `repos'))' {
			if word("`eqnrevars'", `k') == "`x`i''" {
				local x`i'pos = `k'
			}
		}
		local ++i
	}

	* order number for y
	forvalues i=1/`=real(word("`e(redim)'", `repos'))' {
		if word("`eqnrevars'", `i') == "`y'" {
			local ypos = `i'
		}
	}

	* create cov(y,x_i) expressions
	local i 1
	while `i' < `len' {
		* work out which has smaller/bigger pos no
		local lowpos = min(`ypos', `x`i'pos')
		local upppos = max(`ypos', `x`i'pos')
		local lns lns`relevel'_`sublevel'
		local atr atr`relevel'_`sublevel'
		if word("`e(vartypes)'", `repos') == "Exchangeable" {
			* check the components exist as colnames in e(V)
			mata st_numscalar(st_local("test"),sum(strmatch(st_matrixcolstripe("e(V)")[,1], st_macroexpand("`atr'_1_1"))))
			if (`test' == 0) {
				di as err "No column named `atr'_1_1:_cons ") in e(V)."
				error 322
			}
			mata st_numscalar(st_local("test"),sum(strmatch(st_matrixcolstripe("e(V)")[,1], st_macroexpand("`lns'_1"))))
			if (`test' == 0) {
				di as err "No column named `lns'_1:_cons ") in e(V)."
				error 322
			}
			* check non-zero SE
			if _se[`atr'_1_1:_cons] == 0 {
				di as err "`atr'_1_1:_cons has variance = 0 in e(V)." ///
					_n "It is advised not to run reffadjust4nlcom for this case."
			}
			if _se[`lns'_1:_cons] == 0 {
				di as err "`lns'_1:_cons has variance = 0 in e(V)." ///
					_n "It is advised not to run reffadjust4nlcom for this case."
			}
			local covyx`i' tanh([`atr'_1_1]_cons)*exp(2*[`lns'_1]_cons)
		}
		else if word("`e(vartypes)'", `repos') == "Unstructured" {
			* check the components exist as colnames in e(V)
			mata st_numscalar(st_local("test"),sum(strmatch(st_matrixcolstripe("e(V)")[,1], st_macroexpand("`atr'_`lowpos'_`upppos'"))))
			if (`test' == 0) {
				di as err "No column named `atr'_`lowpos'_`upppos':_cons ") in e(V)."
				error 322
			}
			mata st_numscalar(st_local("test"),sum(strmatch(st_matrixcolstripe("e(V)")[,1], st_macroexpand("`lns'_`lowpos'"))))
			if (`test' == 0) {
				di as err "No column named `lns'_`lowpos':_cons ") in e(V)."
				error 322
			}
			mata st_numscalar(st_local("test"),sum(strmatch(st_matrixcolstripe("e(V)")[,1], st_macroexpand("`lns'_`upppos'"))))
			if (`test' == 0) {
				di as err "No column named `lns'_`upppos':_cons ") in e(V)."
				error 322
			}
			* check non-zero SE
			if _se[`atr'_`lowpos'_`upppos':_cons] == 0 {
				di as err "`atr'_`lowpos'_`upppos':_cons has variance = 0 in e(V)." ///
					_n "It is advised not to run reffadjust4nlcom for this case."
			}
			if _se[`lns'_`lowpos':_cons] == 0 {
				di as err "`lns'_`lowpos':_cons has variance = 0 in e(V)." ///
					_n "It is advised not to run reffadjust4nlcom for this case."
			}
			if _se[`lns'_`upppos':_cons] == 0 {
				di as err "`lns'_`upppos':_cons has variance = 0 in e(V)." ///
					_n "It is advised not to run reffadjust4nlcom for this case."
			}
			local covyx`i' tanh([`atr'_`lowpos'_`upppos']_cons)*exp([`lns'_`lowpos']_cons + [`lns'_`upppos']_cons)
		}
		local ++i
	}

	* create cov(x_i,x_j) expressions
	if `len' > 2 {
		local i 1
		while `i' < `len' {
			forvalues k = `i'/`len' {
				if (`i' != `k') {
					* work out which has smaller/bigger pos no
					local lowpos = min(`x`i'pos', `x`k'pos')
					local upppos = max(`x`i'pos', `x`k'pos')
					local lns lns`relevel'_`sublevel'
					local atr atr`relevel'_`sublevel'
					if word("`e(vartypes)'", `repos') == "Exchangeable" {
						* check the components exist as colnames in e(V): already checked
						* check non-zero SE
						if _se[`atr'_1_1:_cons] == 0 {
							di as err "`atr'_1_1:_cons has variance = 0 in e(V)." ///
								_n "It is advised not to run reffadjust4nlcom for this case."
						}
						if _se[`lns'_1:_cons] == 0 {
							di as err "`lns'_1:_cons has variance = 0 in e(V)." ///
								_n "It is advised not to run reffadjust4nlcom for this case."
						}
						local covx`i'x`k' tanh([`atr'_1_1]_cons)*exp(2*[`lns'_1]_cons)
					}
					else if word("`e(vartypes)'", `repos') == "Unstructured" {
						* check the components exist as colnames in e(V)
						mata st_numscalar(st_local("test"),sum(strmatch(st_matrixcolstripe("e(V)")[,1], st_macroexpand("`atr'_`lowpos'_`upppos'"))))
						if (`test' == 0) {
							di as err "No column named `atr'_`lowpos'_`upppos':_cons ") in e(V)."
							error 322
						}
						mata st_numscalar(st_local("test"),sum(strmatch(st_matrixcolstripe("e(V)")[,1], st_macroexpand("`lns'_`lowpos'"))))
						if (`test' == 0) {
							di as err "No column named `lns'_`lowpos':_cons ") in e(V)."
							error 322
						}
						mata st_numscalar(st_local("test"),sum(strmatch(st_matrixcolstripe("e(V)")[,1], st_macroexpand("`lns'_`upppos'"))))
						if (`test' == 0) {
							di as err "No column named `lns'_`upppos':_cons ") in e(V)."
							error 322
						}
						* check non-zero SE
						if _se[`atr'_`lowpos'_`upppos':_cons] == 0 {
							di as err "`atr'_`lowpos'_`upppos':_cons has variance = 0 in e(V)." ///
								_n "It is advised not to run reffadjust4nlcom for this case."
						}
						if _se[`lns'_`lowpos':_cons] == 0 {
							di as err "`lns'_`lowpos':_cons has variance = 0 in e(V)." ///
								_n "It is advised not to run reffadjust4nlcom for this case."
						}
						if _se[`lns'_`upppos':_cons] == 0 {
							di as err "`lns'_`upppos':_cons has variance = 0 in e(V)." ///
								_n "It is advised not to run reffadjust4nlcom for this case."
						}
						local covx`i'x`k' tanh([`atr'_`lowpos'_`upppos']_cons)*exp([`lns'_`lowpos']_cons + [`lns'_`upppos']_cons)
					}
				}
				if (`k' == `len' - 1) {
					continue, break
				}
			}
			local i = `i' + 1
		}
	}
}

* locals for scaling factors sf
if "`sf'" == "" {
	forvalues i=1/`nx' {
		local sfexp`i' ""
	}
}
else {
	local sflen = wordcount("`sf'")
	if `sflen' == `nx' {
		forvalues i=1/`nx' {
			local sf`i' = word("`sf'", `i')
			local sfexp`i' "`sf`i''*"
		}
	}
	else {
		di as err "sf(numlist) not the same length as no. covariates"
		error 197
	}
}


* make the locals containing the coefficient expressions
if `len' == 2 {
	if "`mcmcsum'" == "" & e(cmd) == "runmlwin" {
		local eqnvarx1 "[`eqn']var(`x1')"
		local eqncovyx1 "[`eqn']`covyx1'"
	}
	else if "`mcmcsum'" == "mcmcsum" & e(cmd) == "runmlwin" {
		local eqnvarx1 = strtoname("`eqn'_var_`x1'_")
		local eqncovyx1 = strtoname("`eqn'_`=strtoname("`covyx1'")'")
	}
	else if e(cmd) != "runmlwin" {
		if word("`e(vartypes)'", `repos') == "Exchangeable" {
			local eqnvarx1 exp(2*[`lns'_1]_cons)
		}
		else if word("`e(vartypes)'", `repos') == "Unstructured" {
			local eqnvarx1 exp(2*[`lns'_`x1pos']_cons)
		}
		local eqncovyx1 `covyx1'
	}
	local beta1 "`sfexp1'`eqncovyx1'/`eqnvarx1'"
	ret local `=strtoname("beta_`x1'")' "`beta1'"
}
else if `len' == 3 {
	if "`mcmcsum'" == "" & e(cmd) == "runmlwin" {
		local eqnvarx1 "[`eqn']var(`x1')"
		local eqnvarx2 "[`eqn']var(`x2')"
		local eqncovyx1 "[`eqn']`covyx1'"
		local eqncovyx2 "[`eqn']`covyx2'"
		local eqncovx1x2 "[`eqn']`covx1x2'"
	}
	else if "`mcmcsum'" == "mcmcsum" & e(cmd) == "runmlwin" {
		local eqnvarx1 = strtoname("`eqn'_var_`x1'_")
		local eqnvarx2 = strtoname("`eqn'_var_`x2'_")
		local eqncovyx1 = strtoname("`eqn'_`=strtoname("`covyx1'")'")
		local eqncovyx2 = strtoname("`eqn'_`=strtoname("`covyx2'")'")
		local eqncovx1x2 = strtoname("`eqn'_`=strtoname("`covx1x2'")'")
	}
	else if e(cmd) != "runmlwin" {
		if word("`e(vartypes)'", `repos') == "Exchangeable" {
			local eqnvarx1 exp(2*[`lns'_1]_cons)
			local eqnvarx2 exp(2*[`lns'_1]_cons)
		}
		else if word("`e(vartypes)'", `repos') == "Unstructured" {
			local eqnvarx1 exp(2*[`lns'_`x1pos']_cons)
			local eqnvarx2 exp(2*[`lns'_`x2pos']_cons)
		}
		local eqncovyx1 `covyx1'
		local eqncovyx2 `covyx2'
		local eqncovx1x2 `covx1x2'
	}
	local num11 "`eqnvarx2'*`eqncovyx1'"
	local num12 "`eqncovx1x2'*`eqncovyx2'"
	local den1 "`eqnvarx1'*`eqnvarx2'"
	local den2 "(`eqncovx1x2')^2"
	local num21 "`eqnvarx1'*`eqncovyx2'"
	local num22 "`eqncovx1x2'*`eqncovyx1'"
	local beta1 "`sfexp1'(`num11' - `num12')/(`den1' - `den2')"
	ret local `=strtoname("beta_`x1'")' "`beta1'"
	local beta2 "`sfexp2'(`num21' - `num22')/(`den1' - `den2')"
	ret local `=strtoname("beta_`x2'")' "`beta2'"
}
else if `len' == 4 {
	if "`mcmcsum'" == "" & e(cmd) == "runmlwin" {
		local eqnvarx1 "[`eqn']var(`x1')"
		local eqnvarx2 "[`eqn']var(`x2')"
		local eqnvarx3 "[`eqn']var(`x3')"
		local eqncovyx1 "[`eqn']`covyx1'"
		local eqncovyx2 "[`eqn']`covyx2'"
		local eqncovyx3 "[`eqn']`covyx3'"
		local eqncovx1x2 "[`eqn']`covx1x2'"
		local eqncovx1x3 "[`eqn']`covx1x3'"
		local eqncovx2x3 "[`eqn']`covx2x3'"
	}
	else if "`mcmcsum'" == "mcmcsum" & e(cmd) == "runmlwin" {
		local eqnvarx1 = strtoname("`eqn'_var_`x1'_")
		local eqnvarx2 = strtoname("`eqn'_var_`x2'_")
		local eqnvarx3 = strtoname("`eqn'_var_`x3'_")
		local eqncovyx1 = strtoname("`eqn'_`=strtoname("`covyx1'")'")
		local eqncovyx2 = strtoname("`eqn'_`=strtoname("`covyx2'")'")
		local eqncovyx3 = strtoname("`eqn'_`=strtoname("`covyx3'")'")
		local eqncovx1x2 = strtoname("`eqn'_`=strtoname("`covx1x2'")'")
		local eqncovx1x3 = strtoname("`eqn'_`=strtoname("`covx1x3'")'")
		local eqncovx2x3 = strtoname("`eqn'_`=strtoname("`covx2x3'")'")
	}
	else if e(cmd) != "runmlwin" {
		if word("`e(vartypes)'", `repos') == "Exchangeable" {
			local eqnvarx1 exp(2*[`lns'_1]_cons)
			local eqnvarx2 exp(2*[`lns'_1]_cons)
			local eqnvarx3 exp(2*[`lns'_1]_cons)
		}
		else if word("`e(vartypes)'", `repos') == "Unstructured" {
			local eqnvarx1 exp(2*[`lns'_`x1pos']_cons)
			local eqnvarx2 exp(2*[`lns'_`x2pos']_cons)
			local eqnvarx3 exp(2*[`lns'_`x3pos']_cons)
		}
		local eqncovyx1 `covyx1'
		local eqncovyx2 `covyx2'
		local eqncovyx3 `covyx3'
		local eqncovx1x2 `covx1x2'
		local eqncovx1x3 `covx1x3'
		local eqncovx2x3 `covx2x3'
	}
	local det1 "`eqnvarx1'*(`eqnvarx2'*`eqnvarx3' - (`eqncovx2x3')^2)"
	local det2 "-1*`eqncovx1x2'*(`eqnvarx3'*`eqncovx1x2' - `eqncovx2x3'*`eqncovx1x3')"
	local det3 "`eqncovx1x3'*(`eqncovx2x3'*`eqncovx1x2' - `eqnvarx2'*`eqncovx1x3')"
	local det "`det1' + `det2' + `det3'"

* SS denotes (X'X)^(-1) matrix i.e. inverse sum of squares
	local SS11 "`eqnvarx2'*`eqnvarx3' - (`eqncovx2x3')^2"
	local SS12 "`eqncovx1x3'*`eqncovx2x3' - `eqncovx1x2'*`eqnvarx3'"
	local SS13 "`eqncovx1x2'*`eqncovx2x3' - `eqncovx1x3'*`eqnvarx2'"
	local SS21 `SS12'
	local SS22 "`eqnvarx1'*`eqnvarx3' - (`eqncovx1x3')^2"
	local SS23 "`eqncovx1x3'*`eqncovx1x2' - `eqnvarx1'*`eqncovx2x3'"
	local SS31 `SS13'
	local SS32 `SS23'
	local SS33 "`eqnvarx1'*`eqnvarx2' - (`eqncovx1x2')^2"

	local num1 "(`SS11')*`eqncovyx1' + (`SS12')*`eqncovyx2' + (`SS13')*`eqncovyx3'"
	local beta1 "`sfexp1'(`num1')/(`det')"
	ret local `=strtoname("beta_`x1'")' "`beta1'"

	local num2 "(`SS21')*`eqncovyx1' + (`SS22')*`eqncovyx2' + (`SS23')*`eqncovyx3'"
	local beta2 "`sfexp2'(`num2')/(`det')"
	ret local `=strtoname("beta_`x2'")' "`beta2'"

	local num3 "(`SS31')*`eqncovyx1' + (`SS32')*`eqncovyx2' + (`SS33')*`eqncovyx3'"
	local beta3 "`sfexp3'(`num3')/(`det')"
	ret local `=strtoname("beta_`x3'")' "`beta3'"
}
else if `len' == 5 {
	if "`mcmcsum'" == "" & e(cmd) == "runmlwin" {
		local eqnvarx1 "[`eqn']var(`x1')"
		local eqnvarx2 "[`eqn']var(`x2')"
		local eqnvarx3 "[`eqn']var(`x3')"
		local eqnvarx4 "[`eqn']var(`x4')"
		local eqncovyx1 "[`eqn']`covyx1'"
		local eqncovyx2 "[`eqn']`covyx2'"
		local eqncovyx3 "[`eqn']`covyx3'"
		local eqncovyx4 "[`eqn']`covyx4'"
		local eqncovx1x2 "[`eqn']`covx1x2'"
		local eqncovx1x3 "[`eqn']`covx1x3'"
		local eqncovx1x4 "[`eqn']`covx1x4'"
		local eqncovx2x3 "[`eqn']`covx2x3'"
		local eqncovx2x4 "[`eqn']`covx2x4'"
		local eqncovx3x4 "[`eqn']`covx3x4'"
	}
	else if "`mcmcsum'" == "mcmcsum" & e(cmd) == "runmlwin" {
		local eqnvarx1 = strtoname("`eqn'_var_`x1'_")
		local eqnvarx2 = strtoname("`eqn'_var_`x2'_")
		local eqnvarx3 = strtoname("`eqn'_var_`x3'_")
		local eqnvarx4 = strtoname("`eqn'_var_`x4'_")
		local eqncovyx1 = strtoname("`eqn'_`=strtoname("`covyx1'")'")
		local eqncovyx2 = strtoname("`eqn'_`=strtoname("`covyx2'")'")
		local eqncovyx3 = strtoname("`eqn'_`=strtoname("`covyx3'")'")
		local eqncovyx4 = strtoname("`eqn'_`=strtoname("`covyx4'")'")
		local eqncovx1x2 = strtoname("`eqn'_`=strtoname("`covx1x2'")'")
		local eqncovx1x3 = strtoname("`eqn'_`=strtoname("`covx1x3'")'")
		local eqncovx1x4 = strtoname("`eqn'_`=strtoname("`covx1x4'")'")
		local eqncovx2x3 = strtoname("`eqn'_`=strtoname("`covx2x3'")'")
		local eqncovx2x4 = strtoname("`eqn'_`=strtoname("`covx2x4'")'")
	}
	else if e(cmd) != "runmlwin" {
		if word("`e(vartypes)'", `repos') == "Exchangeable" {
			local eqnvarx1 exp(2*[`lns'_1]_cons)
			local eqnvarx2 exp(2*[`lns'_1]_cons)
			local eqnvarx3 exp(2*[`lns'_1]_cons)
			local eqnvarx4 exp(2*[`lns'_1]_cons)
		}
		else if word("`e(vartypes)'", `repos') == "Unstructured" {
			local eqnvarx1 exp(2*[`lns'_`x1pos']_cons)
			local eqnvarx2 exp(2*[`lns'_`x2pos']_cons)
			local eqnvarx3 exp(2*[`lns'_`x3pos']_cons)
			local eqnvarx4 exp(2*[`lns'_`x4pos']_cons)
		}
		local eqncovyx1 `covyx1'
		local eqncovyx2 `covyx2'
		local eqncovyx3 `covyx3'
		local eqncovyx4 `covyx4'
		local eqncovx1x2 `covx1x2'
		local eqncovx1x3 `covx1x3'
		local eqncovx1x4 `covx1x4'
		local eqncovx2x3 `covx2x3'
		local eqncovx2x4 `covx2x4'
		local eqncovx3x4 `covx3x4'
	}
	local det01 "`eqnvarx1'*`eqnvarx2'*`eqnvarx3'*`eqnvarx4'"
	local det02 "`eqnvarx1'*`eqncovx2x3'*`eqncovx3x4'*`eqncovx2x4'"
*	local det03 "[`eqn']var(`x1')*[`eqn']`covx2x4'*[`eqn']`covx2x3'*[`eqn']`covx3x4'" // ==det02
	local det04 "(`eqncovx1x2')^2*(`eqncovx3x4')^2"
	local det05 "`eqncovx1x2'*`eqncovx2x3'*`eqncovx1x3'*`eqnvarx4'"
	local det06 "`eqncovx1x2'*`eqncovx2x4'*`eqnvarx3'*`eqncovx1x4'"
*	local det07 "[`eqn']`covx1x3'*[`eqn']`covx1x2'*[`eqn']`covx2x3'*[`eqn']var(`x4')" // ==det05
	local det08 "`eqncovx1x3'*`eqnvarx2'*`eqncovx3x4'*`eqncovx1x4'"
	local det09 "(`eqncovx1x3')^2*(`eqncovx2x4')^2"
*	local det10 "[`eqn']`covx1x4'*[`eqn']`covx1x2'*[`eqn']var(`x3')*[`eqn']`covx2x4'" // ==det06
*	local det11 "[`eqn']`covx1x4'*[`eqn']var(`x2')*[`eqn']`covx1x3'*[`eqn']`covx3x4'" // ==det08
	local det12 "(`eqncovx1x4')^2*(`eqncovx2x3')^2"
	local det13 "`eqnvarx1'*`eqnvarx2'*(`eqncovx3x4')^2"
	local det14 "`eqnvarx1'*`eqnvarx4'*(`eqncovx2x3')^2"
	local det15 "`eqnvarx1'*`eqnvarx3'*(`eqncovx2x4')^2"
	local det16 "`eqnvarx3'*`eqnvarx4'*(`eqncovx1x2')^2"
	local det17 "`eqncovx1x2'*`eqncovx2x3'*`eqncovx3x4'*`eqncovx1x4'"
	local det18 "`eqncovx1x2'*`eqncovx2x4'*`eqncovx1x3'*`eqncovx3x4'"
*	local det19 "[`eqn']`covx1x3'*[`eqn']`covx1x2'*[`eqn']`covx3x4'*[`eqn']`covx2x4'" // ==det18
	local det20 "`eqnvarx2'*`eqnvarx4'*(`eqncovx1x3')^2"
	local det21 "`eqncovx1x3'*`eqncovx2x4'*`eqncovx2x3'*`eqncovx1x4'"
*	local det22 "[`eqn']`covx1x4'*[`eqn']`covx1x2'*[`eqn']`covx2x3'*[`eqn']`covx3x4'" // ==det17
	local det23 "`eqnvarx2'*`eqnvarx3'*(`eqncovx1x4')^2"
*	local det24 "[`eqn']`covx1x4'*[`eqn']`covx2x3'*[`eqn']`covx1x3'*[`eqn']`covx2x4'" // ==det21

	local det "`det01' + 2*`det02' + `det04' + 2*`det05' + 2*`det06' + 2*`det08' + `det09' + `det12'"
	local det "`det' - `det13' - `det14' - `det15' - `det16' - 2*`det17' - 2*`det18' - `det20' - 2*`det21' - `det23'"

* SS denotes (X'X)^(-1) matrix i.e. inverse sum of squares
	local SS11a "`eqnvarx2'*`eqnvarx3'*`eqnvarx4' + 2*`eqncovx2x3'*`eqncovx3x4'*`eqncovx2x4'"
	local SS11b "`eqnvarx2'*(`eqncovx3x4')^2 - `eqnvarx4'*(`eqncovx2x3')^2 - `eqnvarx3'*(`eqncovx2x4')^2"
	local SS11 "`SS11a' - `SS11b'"
	local SS12a "`eqncovx1x2'*(`eqncovx3x4')^2 + `eqncovx1x3'*`eqncovx2x3'*`eqnvarx4' + `eqncovx1x4'*`eqnvarx3'*`eqncovx2x4'"
	local SS12b "`eqncovx1x2'*`eqnvarx3'*`eqnvarx4' - `eqncovx1x3'*`eqncovx3x4'*`eqncovx2x4' - `eqncovx1x4'*`eqncovx2x3'*`eqncovx3x4'"
	local SS12 "`SS12a' - `SS12b'"
	local SS13a "`eqncovx1x2'*`eqncovx2x3'*`eqnvarx4' + `eqncovx1x3'*(`eqncovx2x4')^2 + `eqncovx1x4'*`eqnvarx2'*`eqncovx3x4'"
	local SS13b "`eqncovx1x2'*`eqncovx2x4'*`eqncovx3x4' - `eqncovx1x3'*`eqnvarx2'*`eqnvarx4' - `eqncovx1x4'*`eqncovx2x3'*`eqncovx2x4'"
	local SS13 "`SS13a' - `SS13b'"
	local SS14a "`eqncovx1x2'*`eqncovx2x4'*`eqnvarx3' + `eqncovx1x3'*`eqnvarx2'*`eqncovx3x4' + `eqncovx1x4'*(`eqncovx2x3')^2"
	local SS14b "`eqncovx1x2'*`eqncovx2x3'*`eqncovx3x4' - `eqncovx1x3'*`eqncovx2x4'*`eqncovx2x3' - `eqncovx1x4'*`eqnvarx2'*`eqnvarx3'"
	local SS14 "`SS14a' - `SS14b'"
	local SS21 "`SS12'"
	local SS22a "`eqnvarx1'*`eqnvarx3'*`eqnvarx4' + 2*`eqncovx1x3'*`eqncovx3x4'*`eqncovx1x4'"
	local SS22b "`eqnvarx1'*(`eqncovx3x4')^2 - `eqnvarx4'*(`eqncovx1x3')^2 - `eqnvarx3'*(`eqncovx1x4')^2"
	local SS22 "`SS22a' - `SS22b'"
	local SS23a "`eqnvarx1'*`eqncovx2x4'*`eqncovx3x4' + `eqncovx1x3'*`eqncovx1x2'*`eqnvarx4' + `eqncovx2x3'*(`eqncovx1x4')^2"
	local SS23b "`eqnvarx1'*`eqncovx2x3'*`eqnvarx4' - `eqncovx1x3'*`eqncovx2x4'*`eqncovx1x4' - `eqncovx1x4'*`eqncovx1x2'*`eqncovx3x4'"
	local SS23 "`SS23a' - `SS23b'"
	local SS24a "`eqnvarx1'*`eqncovx2x3'*`eqncovx3x4' + `eqncovx2x4'*(`eqncovx1x3')^2 + `eqncovx1x4'*`eqncovx1x2'*`eqnvarx3'"
	local SS24b "`eqnvarx1'*`eqncovx2x4'*`eqnvarx3' - `eqncovx1x3'*`eqncovx1x2'*`eqncovx3x4' - `eqncovx1x4'*`eqncovx2x3'*`eqncovx1x3'"
	local SS24 "`SS24a' - `SS24b'"
	local SS31 "`SS13'"
	local SS32 "`SS23'"
	local SS33a "`eqnvarx1'*`eqnvarx2'*`eqnvarx4' + 2*`eqncovx1x2'*`eqncovx2x4'*`eqncovx1x4'"
	local SS33b "`eqnvarx1'*(`eqncovx2x4')^2 - `eqnvarx4'*(`eqncovx1x2')^2 - `eqnvarx2'*(`eqncovx1x4')^2"
	local SS33 "`SS33a' - `SS33b'"
	local SS34a "`eqnvarx1'*`eqncovx2x4'*`eqncovx2x3' + `eqncovx3x4'*(`eqncovx1x2')^2 + `eqncovx1x4'*`eqnvarx2'*`eqncovx1x3'"
	local SS34b "`eqnvarx1'*`eqnvarx2'*`eqncovx3x4' - `eqncovx1x2'*`eqncovx2x4'*`eqncovx1x3' - `eqncovx1x2'*`eqncovx2x4'*`eqncovx1x3'"
	local SS34 "`SS34a' - `SS34b'"
	local SS41 "`SS14'"
	local SS42 "`SS24'"
	local SS43 "`SS34'"
	local SS44a "`eqnvarx1'*`eqnvarx2'*`eqnvarx3' + 2*`eqncovx1x2'*`eqncovx2x3'*`eqncovx1x3'"
	local SS44b "`eqnvarx1'*(`eqncovx2x3')^2 - `eqnvarx3'*(`eqncovx1x2')^2 - `eqnvarx2'*(`eqncovx1x3')^2"
	local SS44 "`SS44a' - `SS44b'"

	local num1 "(`SS11')*`eqncovyx1' + (`SS12')*`eqncovyx2' + (`SS13')*`eqncovyx3' + (`SS14')*`eqncovyx4'"
	local beta1 "`sfexp1'(`num1')/(`det')"
	ret local `=strtoname("beta_`x1'")' "`beta1'"

	local num2 "(`SS21')*`eqncovyx1' + (`SS22')*`eqncovyx2' + (`SS23')*`eqncovyx3' + (`SS24')*`eqncovyx4'"
	local beta2 "`sfexp2'(`num2')/(`det')"
	ret local `=strtoname("beta_`x2'")' "`beta2'"

	local num3 "(`SS31')*`eqncovyx1' + (`SS32')*`eqncovyx2' + (`SS33')*`eqncovyx3' + (`SS34')*`eqncovyx4'"
	local beta3 "`sfexp3'(`num3')/(`det')"
	ret local `=strtoname("beta_`x3'")' "`beta3'"

	local num4 "(`SS41')*`eqncovyx1' + (`SS42')*`eqncovyx2' + (`SS43')*`eqncovyx3' + (`SS44')*`eqncovyx4'"
	local beta4 "`sfexp4'(`num4')/(`det')"
	ret local `=strtoname("beta_`x4'")' "`beta4'"
}
end
exit

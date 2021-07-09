*! version 1.1.0 2sep2013 Tom Palmer & Corrie Macdonald-Wallis
program reffadjustsim, rclass
if _caller() >= 13 version 13.0
if _caller() < 13 version 11.2


* estimates replay
if replay() {
	if "`e(cmd)'" != "reffadjustsim" {
		error 301
	}
	syntax [, Level(cilevel)]
	tempname means VAR
	mat `means' = e(b)
	mat `VAR' = e(V)
	local ecolnames : colnames e(V)
	local nx = wordcount("`ecolnames'")
	local edepvar `e(depvar)'
	reffadjustsim_waldtype_display, b("`means'") v("`VAR'") fmt(%9.0g) ///
		varnames(`ecolnames') nx(`nx') depname(`edepvar') ///
		level(`level')
	exit
}
* check eret estimate have b V
if "`e(properties)'" == "" {
	error 301
}
if (!has_eprop(b) | !has_eprop(V)) {
	error 321
}

syntax namelist(min=2), eqn(string) ///
	[seed(numlist >=0 <=2147483647 integer min=1 max=1) n(numlist >=10 integer min=1 max=1) ///
	 SAVing(string) sf(numlist min=1) Level(cilevel) ///
	 WALDtype centileopts(string) post statadrawnorm mcmcsum replace SUBlevel(numlist min=1 max=1)]
* eqn equation name
* seed: random number seed for drawnorm
* n: no. obs for drawnorm
* saving(filename, replace)
* sf: scaling factors for each covariate
* waldtype: report Wald type CIs rather than centiles
* centileopts: options passed to centile (apart from centile as that set by level())
* post: post estimates as ereturn
* statadrawnorm: use stata -drawnorm- instead of mata version
* mcmcsum: perform reffadjust on output from -mcmcsum, getchains- after -runmlwin-
* replace: overwrite variables named beta_indepvar when mcmcsum specified
* sublevel: of the nested random effect structure for xtmixed, xtmelogit, xtmepoisson


if c(version) < 13 & !inlist(e(cmd), "runmlwin", "xtmixed", "xtmelogit", "xtmepoisson") {
	di as err "reffadjustsim currently only works for estimates returned by runmlwin, xtmixed, xtmelogit, or xtmepoisson."
	error 322
}
else if c(version) >= 13 & !inlist(e(cmd), "runmlwin", "mixed", "meqrlogit", "meqrpoisson") {
	di as err "reffadjustsim currently only works for estimates returned by runmlwin, mixed, meqrlogit, or meqrpoisson."
	error 322
}


if e(converged) != 1 & "`mcmcsum'" == "" {
	if e(cmd) == "runmlwin" & e(method) == "MCMC" {
		di as err `"runmlwin reports e(method) = "MCMC", please use option mcmcsum with MCMC estimates"'
		error 322
	}
	else {
		di as err e(cmd), "model did not converge"
		error 322
	}
}

if e(cmd) == "runmlwin" {
	* option sublevel not allowed with runmlwin
	if "`sublevel'" != "" {
		di as err "Option sublevel not allowed with runmlwin estimates."
		error 197
	}

	if real(e(version)) < 2.23 {
		di as err "reffadjustsim requires runmlwin estimates using MLwiN version 2.23 or above."
		error 322
	}
}
else {
	* disallow mcmcsum option with xtmixed
	if "`mcmcsum'" == "mcmcsum" {
		di as err "Option mcmcsum only allowed with estimation results from runmlwin." ///
		_n "Your estimation results are from", e(cmd) "."
		error 197
	}
}

if "`mcmcsum'" == "" {
	* set default no. reps 10000
	if "`n'" == "" {
		local n 10000
	}
	else if `n' < 1000 {
		di as txt "Warning: option n(`n') is quite small, you may like to try a larger number."
	}
}
else {
	if "`n'" != "" {
		di as err "option n(#) not allowed with option mcmcsum"
		error 197
	}
	* set n to no. obs with mcmcsum
	local n = _N
	* check mlwin estimation method was mcmc
	if e(cmd) == "runmlwin" {
		if e(method) != "MCMC" {
			di as err "With option mcmcsum the runmlwin model must be fitted using MCMC"
			error 322
		}
	}
}

tempname test diagtest1 diagtest2 test1 test2 eqntest diagtest3

* upper and lower centiles
local lowcentile = (100 - `level')/2
local uppcentile = 100 - (100 - `level')/2

* check no specification of centileopts with centile
if "`centileopts'" != "" & "`waldtype'" == "waldtype" {
	di as err "option centileopts() cannot be specified with option waldtype."
	error 197
}

* check post and centile options are not both specified
if "`waldtype'" == "" & "`post'" == "post" {
	di as err "option post may only be specified with option waldtype"
	error 197
}

* check mcmcsum and waldtype are not both specified
if "`mcmcsum'" == "mcmcsum" & "`waldtype'" == "waldtype" {
	di as err "option waldtype may not be specified with option mcmcsum"
	error 197
}

* check mcmcsum and seed or statadrawnorm not both specified
if "`mcmcsum'" == "mcmcsum" {
	if "`seed'" != "" {
		di as err "option seed may not be specified with option mcmcsum"
		error 197
	}
	if "`statadrawnorm'" == "statadrawnorm" {
		di as err "option statadrawnorm may not be specified with option mcmcsum"
		error 197
	}
}

* check replace specified with mcmcsum
if "`replace'" == "replace" & "`mcmcsum'" == "" {
	di as err "option replace can only be specified with option mcmcsum"
	error 197
}

* locals containing y and xi varnames, xvars for all x variable names
tokenize "`namelist'"
local len = wordcount("`namelist'")
local nx = `len' - 1
local y `1'
forvalues i=2/`len' {
	local j = `i' - 1
	local x`j' ``i''
	local xvars "`xvars' ``i''"
}
mata st_local("xvars", strltrim(st_local("xvars")))

* check no repeats in namelist
forvalues i=1/`nx' {
	local k = `i' + 1
	forvalues j=`k'/`len' {
		if `i' != `j' {
			if "``i''" == "``j''" {
				di as err "``i'' is repeated in the namelist"
				error 197
			}
		}
	}
}

* locals for scaling factors sf
if "`sf'" == "" {
	forvalues i=1/`nx' {
		local sf`i' ""
	}
}
else {
	local sflen = wordcount("`sf'")
	if `sflen' == `nx' {
		forvalues i=1/`nx' {
			local sf`i' : word `i' of `sf'
		}
	}
	else {
		di as err "sf(numlist) not the same length as no. covariates"
		error 197
	}
}

* test eqn() equation name is valid
if e(cmd) == "runmlwin" {
	mata  st_numscalar(st_local("eqntest"), sum(strmatch(uniqrows(st_matrixcolstripe("e(V)")[,1]), st_local("eqn"))))
	if `eqntest' == 0 {
		mata st_local("eqnnames", invtokens(uniqrows(st_matrixcolstripe("e(V)")[,1])'))
		di as err "Equation name `eqn' not present in e(V)." ///
			_n "Equation name in eqn() option may be one of: `eqnnames'"
		error 322
	}
}
else { // xtmixed:

	* make a local without repeats in e(ivars)
	local ivars `e(ivars)'
	local uivars : list uniq ivars

	* eqn() name check
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
}

* extract random part e(b) and e(V) elements (if other level has a var=0 use just eqn level)
tempname rpb rpV // temporary names for our random part e(b) e(V) matrices
if e(cmd) == "runmlwin" {
	mata pos = strpos(st_matrixcolstripe("e(V)")[,1], "R")
	mata st_matrix(st_local("rpb"), select(st_matrix("e(b)"), pos'))
	mata st_matrix(st_local("rpV"), select(select(st_matrix("e(V)"), pos), pos'))
	mata colnames = select(st_matrixcolstripe("e(V)"), pos)
	mata st_matrixcolstripe("`rpV'", colnames)
	mata st_matrixrowstripe("`rpV'", colnames)
	mata st_matrixcolstripe("`rpb'", colnames)
	cap mata mata drop pos colnames

	* check if any of leading diagonal in rpV are 0
	mata st_numscalar(st_local("diagtest1"), anyof(diagonal(st_matrix("`rpV'")), 0))
	* if a variance is zero try just using eqn: part
	if `diagtest1' == 1 {
		tempname b V
		mat `b' = e(b)
		mat `V' = e(V)
		mat `rpb' = `b'[1,"`eqn':"]
		mat `rpV' = `V'["`eqn':","`eqn':"]
		* check if any of leading diagonal in rpV are 0
		mata st_numscalar(st_local("diagtest2"), anyof(diagonal(st_matrix("`rpV'")), 0))
		if `diagtest2' == 1 {
			di as err "One or more parameters in e(V) in level `eqn' have variance = 0." ///
				_n "Results may not be reliable for this case."
		}
	}
}
else { // xtmixed: extract relevant rows and cols from e(b) & e(V)
	* extract all random levels and residuals
	mata pos = 1 :- strpos(st_matrixcolstripe("e(V)")[,1], "`e(depvar)'")
	mata st_matrix(st_local("rpb"), select(st_matrix("e(b)"), pos'))
	mata st_matrix(st_local("rpV"), select(select(st_matrix("e(V)"), pos), pos'))
	mata colnames = select(st_matrixcolstripe("e(V)"), pos)
	mata st_matrixcolstripe("`rpV'", colnames)
	mata st_matrixrowstripe("`rpV'", colnames)
	mata st_matrixcolstripe("`rpb'", colnames)

	* check if any of leading diagonal in rpV == 0
	mata st_numscalar(st_local("diagtest1"), anyof(diagonal(st_matrix("`rpV'")), 0))
	* if a variance is zero try just using eqn: and residuals part
	if `diagtest1' == 1 {
		forvalues i = 1/`=wordcount("`e(redim)'")' {
			if `i' != `relevel' {
				* remove other level lns & atr names from rpb rbV
				mata poslns = strpos(st_matrixcolstripe("`rpV'")[,1], "lns`i'")
				mata posatr = strpos(st_matrixcolstripe("`rpV'")[,1], "atr`i'")
				mata pos = 1 :- (poslns + posatr)
				mata st_matrix("`rpb'", select(st_matrix("`rpb'"), pos'))
				mata st_matrix("`rpV'", select(select(st_matrix("`rpV'"), pos), pos'))
				mata colnames = select(colnames, pos)
				mata st_matrixcolstripe("`rpV'", colnames)
				mata st_matrixrowstripe("`rpV'", colnames)
				mata st_matrixcolstripe("`rpb'", colnames)
				cap mata mata drop poslns posatr
			}
		}
		* check if any of leading diagonal in rpV == 0
		mata st_numscalar(st_local("diagtest2"), anyof(diagonal(st_matrix("`rpV'")), 0))
		* if a diagonal el of V == 0 extract `eqn' level
		if `diagtest2' == 1 {
			* select lns & atr rows for `relevel' from rpb rpV
			mata poslns = strpos(st_matrixcolstripe("`rpV'")[,1], "lns`relevel'")
			mata posatr = strpos(st_matrixcolstripe("`rpV'")[,1], "atr`relevel'")
			mata pos = (poslns + posatr)
			mata st_matrix("`rpb'", select(st_matrix("`rpb'"), pos'))
			mata st_matrix("`rpV'", select(select(st_matrix("`rpV'"), pos), pos'))
			mata colnames = select(colnames, pos)
			mata st_matrixcolstripe("`rpV'", colnames)
			mata st_matrixrowstripe("`rpV'", colnames)
			mata st_matrixcolstripe("`rpb'", colnames)
			cap mata mata drop poslns posatr pos colnames

			* if a diagonal el of V == 0 issue warning
			mata st_numscalar(st_local("diagtest3"), anyof(diagonal(st_matrix("`rpV'")), 0))
			if `diagtest3' == 1 {
				foreach se0var in `: colfullnames `rpV'' {
					if _se[`se0var'] == 0 {
						local var0list "`var0list' `se0var'"
					}
				}
				di as err "In e(V) the following parameters have variance = 0:`var0list'." ///
					_n "Results may not be valid for this case."
				if "`statadrawnorm'" == "" {
					di as err "Please specify statadrawnorm option."
					error 322
				}
			}
		}
	}
	cap mata mata drop pos colnames
}

* make a local containing new variable names for drawnorm
if e(cmd) == "runmlwin" {
	local colfullnames : colfullnames `rpV'
	mata st_local("newcolfullnames", subinstr(subinstr(subinstr(subinstr(st_local("colfullnames"), ":", "_"), "(", "_"), ")", ""), "\", "_"))
}
else {
	local colfullnames : colfullnames `rpV'
	mata st_local("newcolfullnames", invtokens(strtoname(tokens(st_local("colfullnames")))))
}

* make a local namelist2 containing the required var names for var_xi terms
* make a local namelist2a containing the required cov names for cov_xi_xj terms
* make a local namelist3 containing the required cov names for cov_y_xi terms
if e(cmd) == "runmlwin" {
	forvalues i=1/`nx' {
		local add2 : di "`eqn'_var_" abbrev(strtoname("`x`i''"), 27)
		mata st_numscalar(st_local("test1"), sum(strmatch(tokens(st_local("newcolfullnames")), st_local("add2"))))
		if `test1' == 0 {
			di as err "created variable `add2' not in derived column names"
			error 322
		}
		local add3 : di "`eqn'_cov_" abbrev(strtoname("`y'"), 13) "_" abbrev(strtoname("`x`i''"), 13)
		mata st_numscalar(st_local("test1"), sum(strmatch(tokens(st_local("newcolfullnames")), st_local("add3"))))
		if `test1' == 0 {
			local add3 : di "`eqn'_cov_" abbrev(strtoname("`x`i''"), 13) "_" abbrev(strtoname("`y'"), 13)
			mata st_numscalar(st_local("test2"), sum(strmatch(tokens(st_local("newcolfullnames")), st_local("add3"))))
			if `test2' == 0 {
				di as err "created variable `add3' not in derived column names." ///
					_n "Please check you have not specified the " ///
					"diagonal random part option in runmlwin."
				error 322
			}
		}
		if `i' == 1 {
			local namelist2 "`add2'"
			local namelist3 "`add3'"
		}
		else {
			local namelist2 "`namelist2' `add2'"
			local namelist3 "`namelist3' `add3'"
		}
		local j = `i' + 1
		while `j' <= `nx' {
			if `j' != `i' {
				local add2cov : di "`eqn'_cov_" abbrev(strtoname("`x`j''"), 13) "_" abbrev(strtoname("`x`i''"), 13)
				mata st_numscalar(st_local("test1"), sum(strmatch(tokens(st_local("newcolfullnames")), st_local("add2cov"))))
				if `test1' == 0 {
					local add2cov : di "`eqn'_cov_" abbrev(strtoname("`x`i''"), 13) "_" abbrev(strtoname("`x`j''"), 13)
					mata st_numscalar(st_local("test2"), sum(strmatch(tokens(st_local("newcolfullnames")), st_local("add2cov"))))
					if `test2' == 0 {
						di as err "created variable `add2cov' not in derived column names." ///
							_n "Please check you have not specified the " ///
							"diagonal random part option in runmlwin."
						error 322
					}
				}
				local namelist2a "`namelist2a' `add2cov'"
			}
			local j = `j' + 1
		}
	}
	mata st_local("namelist2a", strltrim(st_local("namelist2a")))

	* abbreviate variable names in newcolfullnames, namelist2, namelist2a, namelist3
	if "`mcmcsum'" == "" {
		mata st_local("newcolfullnames", invtokens(strtoname(tokens(st_local("newcolfullnames")))))
		mata st_local("namelist2", invtokens(strtoname(tokens(st_local("namelist2")))))
		mata st_local("namelist2a", invtokens(strtoname(tokens(st_local("namelist2a")))))
		mata st_local("namelist3", invtokens(strtoname(tokens(st_local("namelist3")))))
	}
	else {
		* mcmcsum: add "_" to each varname and then make into a name
		mata st_local("newcolfullnames", invtokens(strtoname(tokens(st_local("newcolfullnames")) :+ "_")))
		mata st_local("namelist2", invtokens(strtoname(tokens(st_local("namelist2")) :+ "_")))
		mata st_local("namelist2a", invtokens(strtoname(tokens(st_local("namelist2a")) :+ "_")))
		mata st_local("namelist3", invtokens(strtoname(tokens(st_local("namelist3")) :+ "_")))
	}
}

* seed option
if "`seed'" == "" {
	local seedopt ""
}
else {
	local seedopt set seed `seed'
}

* saving the drawnorm dataset option
if "`saving'" == "" {
	local savecmd ""
}
else {
	tokenize "`saving'", p(",")
	local filename "`1'"
	local 3 = lower(subinstr("`3'", " ", "", .))
	if "`3'" != "replace" & "`3'" != "" {
		di as err "In saving() only sub-option replace allowed"
		error 197
	}
	else if "`3'" == "replace" {
		local replaceopt ", replace"
	}
	local savecmd "save `filename'`replaceopt'"
}

/* drawnorm */
if "`mcmcsum'" == "" {
	preserve
	`seedopt'
	if "`statadrawnorm'" == "statadrawnorm" {
		qui drawnorm `newcolfullnames', n(`n') ///
			cov(`rpV') means(`rpb') clear double // go back to e(b) e(V) for this??
	}
	else {
		drop _all
		qui set obs `n'
		* TODO implement mata eigenvalue decomposition for non-positive definite rpV
		mata dmsim_drawnorm(`n', "`rpb'", "`rpV'", "`newcolfullnames'")
	}
	if e(cmd) == "runmlwin" {
		keep `eqn'*
	}
}

* xtmixed: create new variables back transforming relevant bits
* and namelist2, namelist2a, namelist3 of varxi covyxi covxixj to pass to solver
if e(cmd) != "runmlwin" { //
	forvalues i=1/`nx' {
		local lns lns`relevel'_`sublevel'
		local atr atr`relevel'_`sublevel'
		if word("`e(vartypes)'", `repos') == "Unstructured" {
			* variance terms namelist2
			local add2 var_x`i'
			gen double `add2' = exp(2*`lns'_`x`i'pos'__cons)
			local namelist2 "`namelist2' `add2'"

			* cov(y,xi) terms namelist3
			* work out which has smaller/bigger pos no
			local lowpos = min(`ypos', `x`i'pos')
			local upppos = max(`ypos', `x`i'pos')
			local add3 cov_y_x`i'
			gen double `add3' = tanh(`atr'_`lowpos'_`upppos'__cons)*exp(`lns'_`lowpos'__cons + `lns'_`upppos'__cons)
			local namelist3 "`namelist3' `add3'"

			* cov(xi,xj) terms namelist2a
			local j = `i' + 1
			while `j' <= `nx' {
				if `j' != `i' {
					* work out which has smaller/bigger pos no
					local lowpos = min(`x`i'pos', `x`j'pos')
					local upppos = max(`x`i'pos', `x`j'pos')
					local add2a cov_x`i'_x`j'
					gen double `add2a' = tanh(`atr'_`lowpos'_`upppos'__cons)*exp(`lns'_`lowpos'__cons + `lns'_`upppos'__cons)
					local namelist2a "`namelist2a' `add2a'"
				}
				local j = `j' + 1
			}
		}
		else if word("`e(vartypes)'", `repos') == "Exchangeable" {
			* variance terms namelist2
			local add2 var_x`i'
			gen double `add2' = exp(2*`lns'_1__cons)
			local namelist2 "`namelist2' `add2'"

			* cov(y,xi) terms namelist3
			local add3 cov_y_x`i'
			gen double `add3' = tanh(`atr'_1_1__cons)*exp(2*`lns'_1__cons)
			local namelist3 "`namelist3' `add3'"

			* cov(xi,xj) terms namelist2a
			local j = `i' + 1
			while `j' <= `nx' {
				if `j' != `i' {
					local add2a cov_x`i'_x`j'
					gen double `add2a' = tanh(`atr'_1_1__cons)*exp(2*`lns'_1__cons)
					local namelist2a "`namelist2a' `add2a'"
				}
				local j = `j' + 1
			}
		}
	}
	* trim any leading spaces
	mata st_local("namelist2", strltrim(st_local("namelist2")))
	mata st_local("namelist2a", strltrim(st_local("namelist2a")))
	mata st_local("namelist3", strltrim(st_local("namelist3")))
}

* create new variables for the beta#
local betanames ""
foreach var in `xvars' {
	local betaindepvar = strtoname("beta_`var'")
	capture gen `betaindepvar' = .
	if _rc == 110 {
		if "`replace'" == "" {
			di as error "`betaindepvar' already defined, please specify replace option"
			error 110
		}
		else {
			qui replace `betaindepvar' = .
		}
	}
}

mata st_local("betanames", invtokens(strtoname("beta_" :+ tokens(st_local("xvars")))))

* call the solver
mata dmsim_caller("`namelist2'", "`namelist2a'", "`namelist3'", `n', `nx', "`betanames'", "`sf'")

tempname n2
scalar `n2' = `n'
return scalar N = `n2'

if "`waldtype'" == "" {
	local i 1
	foreach var in `xvars' {
		qui centile beta_`var', centile(`lowcentile' `uppcentile' 50) `centileopts'
		local `i'c1 = r(c_1)
		local `i'c2 = r(c_2)
		local `i'c3 = r(c_3)
		ret sca `=strtoname("n_cent_`x`i''")' = r(n_cent)
		ret sca `=strtoname("ub_med_`x`i''")' = r(ub_3)
		ret sca `=strtoname("lb_med_`x`i''")' = r(lb_3)
		ret sca `=strtoname("med_`x`i''")' = ``i'c3'
		ret sca `=strtoname("ub_2_`x`i''")' = r(ub_2)
		ret sca `=strtoname("lb_2_`x`i''")' = r(lb_2)
		ret sca `=strtoname("c_2_`x`i''")' = ``i'c2'
		ret sca `=strtoname("ub_1_`x`i''")' = r(ub_1)
		ret sca `=strtoname("lb_1_`x`i''")' = r(lb_1)
		ret sca `=strtoname("c_1_`x`i''")' = ``i'c1'
		local centile_display_res `centile_display_res' ``i'c3' ``i'c1' ``i'c2'
		local i = `i' + 1
	}

	dmsim_centile_display "`centile_display_res'", fmt(%9.0g) ///
		varnames(`xvars') nx(`nx') depname(`y') ///
		lowcentile(`lowcentile') uppcentile(`uppcentile')
}
else {
	matname means `xvars', columns(.) explicit
	matname VAR `xvars', explicit
	return matrix V VAR, copy
	return matrix b means, copy

	if "`post'" == "post" {
		reffadjustsim_waldtype_display, b("means") v("VAR") fmt(%9.0g) ///
			varnames(`xvars') nx(`nx') depname(`y') ///
			level(`level')
		dmsim_post , b(means) vce(VAR) depname(`y') n(`n')
	}
	else {
		reffadjustsim_waldtype_display, b("means") v("VAR") fmt(%9.0g) ///
			varnames(`xvars') nx(`nx') depname(`y') ///
			level(`level')
	}
	di as txt "Warning: Coef. & Wald-type conf. interval limits may be inaccurate." ///
	_n "Please compare with default output which reports median & centiles."
}

`savecmd'
if "`mcmcsum'" == "" {
	restore
}

end


program dmsim_centile_display
syntax anything, fmt(string) varnames(string) ///
	nx(real) depname(string) lowcentile(string) uppcentile(string)
tokenize `anything'

forvalues i=1/`nx' {
	local var`i' = abbrev(word("`varnames'", `i'), 12)
}

di _n _d(13) as txt "{c -}" "{c TT}" _d(64) "{c -}"
di as txt %12s abbrev("`depname'", 12) _col(14) "{c |}" _col(20) "Median" _col(40) "`lowcentile' Percentile" _col(60) "`uppcentile' Percentile"
di _d(13) as txt "{c -}" "{c +}" _d(64) "{c -}"
forvalues i=1/`nx' {
di as txt %12s "`var`i''" _col(14) "{c |}" ///
	_col(17) as res `fmt' ``=1 + (`i' - 1)*3'' ///
	_col(42) as res `fmt' ``=2 + (`i' - 1)*3'' ///
	_col(62) as res `fmt' ``=3 + (`i' - 1)*3''
}
di _d(13) as txt "{c -}" "{c BT}" _d(64) "{c -}"
end


program dmsim_post, eclass
syntax, b(string) vce(string) depname(string) n(integer)
ereturn post `b' `vce', depname(`depname') obs(`n')
ereturn local cmd "reffadjustsim"
end


program reffadjustsim_waldtype_display
syntax, b(name) v(name) fmt(string) varnames(string) ///
	nx(real) depname(string) Level(cilevel)
tempname coef se z low upp

forvalues i=1/`nx' {
	local var`i' = abbrev(word("`varnames'", `i'), 12)
}

sca `z' = invnormal((100 - (100 - `level')/2)/100)

di _n _d(13) as txt "{c -}" "{c TT}" _d(64) "{c -}"
di as txt %12s abbrev("`depname'", 12) _col(14) "{c |}" _col(21) "Coef." _col(29) "Std. Err." ///
	_col(59) "[`level'% Conf. Interval]"
di _d(13) as txt "{c -}" "{c +}" _d(64) "{c -}"
forvalues i=1/`nx' {
	sca `coef' = `b'[1,`i']
	sca `se' = sqrt(`v'[`i',`i'])
	sca `low' = `coef' - `z'*`se'
	sca `upp' = `coef' + `z'*`se'
	di as txt %12s "`var`i''" _col(14) "{c |}" _col(17) as res `fmt' `coef' ///
		_col(28) as res `fmt' `se' ///
		_col(58) as res `fmt' cond(missing(`se'), ., `low') ///
		_col(70) as res `fmt' cond(missing(`se'), ., `upp')
}
di _d(13) as txt "{c -}" "{c BT}" _d(64) "{c -}"
end


version 11.2
mata

function dmsim_drawnorm(real scalar n, string scalar b,
	string scalar V, string scalar newcolfullnames)
{
	real rowvector means
	real matrix P, C, data
	string rowvector newcolfulnames

	newnametokens = tokens(newcolfullnames)
	means = st_matrix(b)
	P = st_matrix(V)
	nx = cols(P)

	// check if P positive definite
	C = cholesky(P)
	// if not use eigen decomposition

	rand = rnormal(n*nx,1,0,1)
	data = J(n, nx, .)
	for (i=1; i<=nx; i++) {
		start = 1 + (i - 1)*n
		stop = n*i
		data[,i] = rand[start..stop, 1]
	}
	data = data*C'
	data = data + J(n,1,means)
	(void) st_addvar("double", newnametokens)
	st_store(., newnametokens, data)
}

function dmsim_Amatrix(real colvector VARS,
	real colvector COVS, real scalar nx)
{
	real matrix A
	real scalar col, counter, ncovs, colstart

	/* make the A matrix */
	A = I(nx):*VARS
	if (nx > 1) {
		counter = 1
		ncovs = rows(COVS)
		col = 1
		while (counter <= ncovs) {
			colstart = col + 1
			for (i=colstart; i<=nx; i++) {
				A[col, i] = A[i, col] = COVS[counter,1]
				counter = counter + 1
			}
			col = col + 1
		}
	}
	return(A)
}

void function dmsim_caller(string scalar namelist2,
	string scalar namelist2a, string scalar namelist3, real scalar n,
	real scalar nx, string scalar betanames, string scalar sf)
{
	real matrix namelist2data, namelist2adata, namelist3data, betahats, A, SY, b, x, V, means

	namelist2data = st_data(., namelist2)
	if (namelist2a == "") {
		namelist2adata = J(n, 1, .)
	}
	else {
		namelist2adata = st_data(., namelist2a)
	}
	namelist3data = st_data(., namelist3)
	betahats = J(n, nx, .)
	b = I(nx)

	for (i=1; i<=n; i++) {
		A = dmsim_Amatrix(namelist2data[i,]', namelist2adata[i,]', nx)
		x = lusolve(A, b)
		SY = namelist3data[i,]'
		betahats[i,] = (x*SY)'
	}

	// rescale betas by sf scaling factors
	if (sf != "") {
		realsf = strtoreal(tokens(sf))
		realsfmat = J(n, 1, realsf)
		betahats = betahats:*realsfmat
	}

	// store the betahats in dataset
	st_store(., tokens(betanames), betahats)
	// generate and save means and V matrices
	V = meanvariance(betahats)
	means = mean(betahats)
	V = variance(betahats)
	st_matrix("means", means)
	st_matrix("VAR", V)
}

end
exit

*! version 1.7.2 05Feb2013 MLB
program define propcnsasl, rclass
	version 10.1
	syntax, [ reps(numlist max=1 integer >0) nodots mcci(cilevel) SAving(string)]
	
	// check whether an appropriate propcnsreg model is in memory
	if "`e(cmd)'" != "propcnsreg" {
		di as err "propcnsasl can only used after propcnsreg"
		exit 198
	}
	if "`e(model)'" == "mimic" {
		di as err "propcnsasl can not be used after a mimic model"
		exit 198
	}
	if "`e(wtype)'" != "" {
		di as err "propcnsasl can not be used after weighted estimation"
		exit 198
	}
	
	// parse the saving() option
	Parsesaving `saving'
	local filename `"`r(filename)'"'
	local replace   "`r(replace)'"
	local double    "`r(double)'"
	local every     "`r(every)'"
	
	// the default number of replications
	if "`reps'" == "" local reps 1000
	
	// recover information from the last -propcnsreg- command
	tempvar touse ysim mu mu2 w
	tempname asl lb ub alph orig
	gen byte `touse' = e(sample)
	
	local constrained   "`e(constrained)'"
	local lambda        "`e(lambda)'"
	local unconstrained "`e(unconstrained)'"
	local y             "`e(depvar)'"
	local model         "`e(model)'"
	
	qui predict double `mu' if `touse', mu
	
	// store original model
	_estimates hold `orig', restore
	
	// estimate the non-linear Wald statistic (Chi^2) in actual data
	propcnswald if `touse', y(`y') constrained(`constrained') ///
	            unconstrained(`unconstrained') lambda(`lambda') ///
				model(`model') mu(`mu2')
	tempname stat
	scalar `stat' = r(stat) 
	local df = r(df)
	if "`model'" == "reg" {
		local df_r = r(df_r)
	}

	// prepare for simulation (`mu2' is predicted values for unconstrained model)
	if "`model'" != "logit" {
		qui gen double `ysim' = `y' - `mu2' + `mu'
		qui gen long `w' = .
		local wgt "[fw=`w']"
	}
	else {
		qui gen byte `ysim' = .
	}
	
	scalar `asl' = 0
	local count = 0
	if "`dots'" == "" {
		_dots 0 , title(computing ASL) reps(`reps')
	}
	if `"`saving'"' != "" {
		tempname memhold pval
		postfile `memhold' `double' Wald_stat `double' p using `"`filename'"', `replace' `every'
	}
	
	// compute non-linear Wald statistice in reps simulations where the null hypothesis is true
	forvalues i = 1/`reps' {
		capture {
			if "`model'" != "logit" {
				bsample if `touse', weight(`w')
			}
			else {
				replace `ysim' = runiform() < `mu'
			}
			propcnswald if `touse' `wgt', y(`ysim') constrained(`constrained') unconstrained(`unconstrained') lambda(`lambda') model(`model') 
			scalar `asl' = `asl' + (r(stat) > `stat') 
			if `"`saving'"' != "" {
				if "`model'" == "reg" {
					scalar `pval' = Ftail(`df',`df_r',r(stat))
				}
				else {
					scalar `pval' = chi2tail(`df',r(stat))
				}
				post `memhold' (r(stat)) (`pval')
			}
		}
		if "`dots'" == "" {
			_dots `i' `=_rc!=0'
		}
		local count = `count' + (_rc==0)
	}
	if `"`saving'"' != "" {
		postclose `memhold'
	}
	
	// display results
    scalar `alph' = (100-`mcci')/200
	local ndecimal = min(ceil(log10(`reps'+1)),4)
	local aslfmt "%`=`ndecimal'+2'.`ndecimal'f"

	local a = `asl'
	local b = `count' + 1 - `asl'
	
	scalar `lb' = invibeta(`a', `b', `alph')
	scalar `ub' = invibetatail(`a', `b', `alph')
	scalar `asl' = (`asl'+1)/(`count'+1)
	di _n
	if "`model'" == "reg" {
		di as txt "non-linear Wald statistic (F(`df',`df_r')): {col 45}" as result %-6.2f `stat'
		di as txt "asymptotic p-value:                         " as result `aslfmt' Ftail(`df',`df_r',`stat')
		return scalar F    = `stat'
		return scalar df_m = `df'
		return scalar df_r = `df_r'
		return scalar p_asymp = Ftail(`df',`df_r',`stat')
	}
	else {
		di as txt "non-linear Wald statistic (Chi2(`df')): {col 45}" as result %-6.2f `stat'
		di as txt "asymptotic p-value:                         " as result `aslfmt'  chi2tail(`df',`stat')
		return scalar chi2 = `stat'
		return scalar df   = `df'
		return scalar p_asymp = chi2tail(`df',`stat')
	}
	di as txt "achieved significance level (ASL):          " as result `aslfmt' `asl'
	di as txt "`mcci'% Monte Carlo CI for ASL: {col 45}[" _c
	di as result `aslfmt' `lb' as txt ", " as result `aslfmt' `ub' as txt "]"
	
	return scalar asl = `asl'
	return scalar reps = `count'
	return scalar mcci_lb = `lb'
	return scalar mcci_ub = `ub'
	
	// restore original model
	_estimates unhold `orig'
end

// estimate the non-linear Wald test for the proportionality constraint using 
// analytical derivatives instead of the numerical derivatives used in -testnl-
// this greatly speeds up the program since we have to perform this computation
// many (reps) times
program define propcnswald, rclass
	version 10.1
	syntax [if] [fw], y(varname) unconstrained(varlist) constrained(varlist) lambda(varlist) model(string) [mu(name)]

	marksample touse
	
	// create interactions for the full model
	foreach cvar of local constrained {
		foreach lvar of local lambda {
			tempvar `lvar'X`cvar'
			qui gen double ``lvar'X`cvar'' = `lvar'*`cvar' if `touse'
			local int "`int' ``lvar'X`cvar''"
		}
	}
	
	// parse freqency weights (used from drawing bootstrap samples)
	if "`weight'" != "" local wgt "[`weight' `exp']"
	
	// estimate the full model
	qui `model' `y' `unconstrained' `constrained' `int' if `touse' `wgt', vce(robust) 
	
	// compute the test
	gettoken base rest : constrained
	local nc : word count `constrained'
	local nl : word count `lambda'
	local k = (`nc'-1)*`nl'
	tempname Rb G b V chi2
	matrix `Rb' = J(`k',1,.)
	local i = 1
	foreach lvar of local lambda {
		foreach cvar of local rest {
			matrix `Rb'[`i',1] =  _b[``lvar'X`base'']/_b[`base'] - _b[``lvar'X`cvar'']/_b[`cvar']
			local i = `i' + 1
		}
	}
	matrix `b' = e(b)
	matrix `V' = e(V)
	matrix `G' = J(`k', `=colsof(`b')',0)
	matrix colnames `G' = `: colfullnames `b''
	local i = 1
	foreach lvar of local lambda {
		foreach cvar of local rest {
			matrix `G'[`i', colnumb(`G',"``lvar'X`base''")] = 1/_b[`base']
			matrix `G'[`i', colnumb(`G',"`base'")]          = -_b[``lvar'X`base'']/(_b[`base']^2)
			matrix `G'[`i', colnumb(`G',"``lvar'X`cvar''")] = - 1/_b[`cvar']
			matrix `G'[`i', colnumb(`G',"`cvar'")]          = _b[``lvar'X`cvar'']/(_b[`cvar']^2)
			local i = `i' + 1
		}
	}
	matrix `chi2' = `Rb''*invsym(`G'*`V'*`G'')*`Rb'
	
	// return results
	return scalar stat = el(`chi2',1,1) / cond("`model'" == "reg",`k', 1)
	return scalar df = `k'
	if "`model'" == "reg" {
		return scalar df_r = e(df_r)
	}
	
	// predict the conditional means under the full model
	if "`mu'" != "" {
		qui predict double `mu' if `touse'
	}
end

// Parse the saving() option
program define Parsesaving, rclass 
	syntax [ anything(name=filename everything) ] [, replace DOUBle EVery(numlist min=1 max=1 integer > 0)]
	
	if `"`filename'"' == "" & "`replace'`double'" != "" {
		di as err "need to specify a file name when specifying the replace or the double option inside the saving() option"
		exit 198
	}
	if "`replace'" == "" & `"`filename'"' != "" {
		confirm new file `filename'
	}
	return local filename `filename'
	return local replace `replace'
	return local double `double'
	if "`every'" != "" {
		return local every "every(`every')"
	}
end

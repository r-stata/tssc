*! firthlogit.ado Version 1.1 JRC 2015-07-17
program define firthlogit
    version 13.1

    if replay() {
        if ("`e(cmd)'" != "firthlogit") error 301
		syntax [, Level(cilevel) OR]
		ml display , level(`level') `or'
    }
    else firthlogit_ml `0'
end

program define firthlogit_ml, eclass sortpreserve byable(recall)
	version 13.1
	syntax varlist(numeric fv) [if] [in] [fweight/], ///
		[noLOG Level(cilevel) OR from(string) *]

	marksample touse

	gettoken lhs predictors : varlist

	_fv_check_depvar `lhs'
	tempvar response
	quietly generate byte `response' = (`lhs' != 0) if `touse'

	mlopts mlopts, `options'
	if "`constant'" == "" & `: word count `predictors'' == 0 {
		display in smcl as error "{b:noconstant} specified without any predictor"
		error = 102
	}

	_rmcoll `predictors', expand
	global firthlogitpredictors `r(varlist)'

	local weight = cond("`weight'`exp'" == "", "", "[`weight' = `exp']")

	// Initial values
	tempname Init
	if "`from'" == "" {
		initial_values `weight', response(`response') init(`Init')
		local from `Init', copy
	}

	ml model d0 firthlogit_ll (xb: `response' = `predictors') if `touse' `weight', ///
		missing init(`from') `mlopts' ///
		maximize crittype("penalized log likelihood") `log'
	ereturn local depvar `lhs'
	ereturn local cmd "firthlogit"
    ml display , level(`level') `or'
end

program define initial_values
	version 13.1
	syntax [fweight], Response(varname) INIT(name) 

	local weight = cond("`weight'" == "", "", "[`weight' `exp']")

	summarize `response' `weight', meanonly
	if r(mean) == 0 scalar define `init' = -5
	else if r(mean) == 1 scalar define `init' = 5
	else scalar define `init' = logit(r(mean))

	local k : word count $firthlogitpredictors
	if (`k') matrix define `init' = (J(1, `k', 0), `init')
	else matrix define `init' = (`init')
end

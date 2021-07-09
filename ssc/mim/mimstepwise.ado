*! version 1.0.0 PR 14jan2009
* Based on Stata 10 stepwise.ado version 6.1.1 16jul2007
program define mimstepwise, eclass byable(onecall)
	version 9
	local version : di "version " string(_caller()) ", missing:"
	if _by() {
		local BY `"by `_byvars'`_byrc0':"'
	}
	if _caller() < 9 {
		di as err "not supported for versions earlier than 9"
		exit 198
		* `version' `BY' sw_8 `0'
		* exit
	}

	capture _on_colon_parse `0'
	if c(rc) | `"`s(after)'"' == "" {
		gettoken old : 0, parse(" ,")
		if "`old'" != "," {
			capture which `old'
			if !c(rc) {
				`version' `BY' sw_8 `0'
				exit
			}
		}
		if (_by()) error 190
// !! PR: line replaced by mim equivalent		if ("`e(cmd)'" == "") error 301
		if ("`e(MIM_prefix2)'" == "") error 301
		Display `0'
		exit
	}
	`version' `BY' StepWise `0'
	ereturn local cmdline `"mimstepwise `0'"'
end

program Display
*	local cmd = cond("`e(cmd2)'" == "", "`e(cmd)'", "`e(cmd2)'")
	mim `0'
end

program StepWise, eclass byable(recall)
	version 9
	local version : di "version " string(_caller()) ":"

	// <my_stuff> : <command>
	_on_colon_parse `0'
	local command `"`s(after)'"'
	local 0 `"`s(before)'"'

	// !! PR: lr option disabled
	syntax [fw iw pw aw] [if] [in] [,		///
			pr(numlist max=1 >0 <1)		///
			pe(numlist max=1 >0 <1)		///
			FORWard				///
			HIERarchical			///
			LOCkterm1			///
			Level(passthru)			///
		]
	local hier `hierarchical'
	if "`weight'" != "" {
		local wgt [`weight'`exp']
	}
	if `"`pr'`pe'"' == "" {
		di as err "at least one of pr(#) and pe(#) must be specified"
		exit 198
	}
	if "`pr'" != "" & "`pe'" != "" {
		if "`hier'" != "" {
			di as err "hierarchical pe(#) pr(#) invalid"
			exit 198
		}
		if `pr' <= `pe' {
			di as err "pr(`pr') <= pe(`pe') invalid"
			exit 198
		}
	}
	if "`forward'" != "" & "`pe'" == "" {
		di as err "option forward invalid or option pe(#) is missing"
		exit 198
	}

	// parse the command and check for conflicts
	`version' _prefix_command stepwise ///
		`wgt' `if' `in' , `level' : `command'

	local version	`"`s(version)'"'
	local cmdname	`"`s(cmdname)'"'
	local termlist	`"`s(anything0)'"'
	local wgt	`"`s(wgt)'"'
	local weight	`"`s(wtype)'"'
	local exp	`"`s(wexp)'"'
	local if	`"`s(if)'"'
	local in	`"`s(in)'"'
	local cmdopts	`"`s(options)'"'
	local rest	`"`s(rest)'"'
	CheckProps `cmdname' `lr'
	Check4Robust "`lr'" `wgt', `cmdopts'
	local constant `"`s(constant)'"'

	// Display options
	local diopts	`"`s(efopt)' level(`s(level)')"'

	// build up part of the command that follows the varlist
	local cmdrest `"`wgt'"'
	if `"`cmdopts'"' != "" {
		local cmdrest `"`cmdrest', `cmdopts'"'
	}
	if `"`rest'"' != "" {
		local cmdrest `"`cmdrest' `rest'"'
	}

	// note: marksample looks at `varlist' `if' `in' and [`weight'`exp']
	// and takes into account if I am being called with the -by:- prefix
	marksample touse, novarlist

	// !! PR: remove _mj==0 from model
	quietly replace `touse' = 0 if _mj == 0

	// parse termlist, and build the list of variable names
	ParseTerms depvar termlist				///
		: `touse' `cmdname' "`wgt'" "`constant'"	///
		: `termlist'

	TermMacros term k curr : `lockterm1' : `termlist'
	// !! PR: fit full model using mim (was `version' `cmdname' `depvar' `curr' if `touse' `cmdrest')
	quietly `version' mim, storebv:`cmdname' `depvar' `curr' if `touse' `cmdrest'
	local colna : colname e(b)
	local varlist : subinstr local colna "_cons" "", all
	local dropped : list curr - varlist
	// check for missing standard errors
	tempname v
	matrix `v' = e(V)
	if diag0cnt(`v') {
		local dim = colsof(`v')
		forval i = 1/`dim' {
			local vname : word `i' of `colna'
			if `v'[`i',`i'] == 0 & "`vname'" != "_cons" {
				local dropped `dropped' `vname'
			}
		}
	}
	// check for dropped variables
	if "`dropped'" != "" {
		gettoken term termlist : termlist, bind match(par)
		while `"`term'"' != "" {
			local term : list term - dropped
			if `"`term'"' != "" {
				local tlist `"`tlist' (`term')"'
			}
			gettoken term termlist : termlist, bind match(par)
		}
		local termlist `"`tlist'"'
		foreach dvar of local dropped {
			di as txt "note: `dvar' dropped because of estimability"
		}
	}
	// check for dropped observations
	quietly count if `touse' & !e(sample)
	if r(N) {
		di as txt "note: `r(N)' obs. dropped because of estimability"
		quietly replace `touse' = 0 if !e(sample)
	}

	// !! PR: `cmdname' is the Stata command name. Needs to be prefixed with mim:.
	local cmdname mim:`cmdname'

	if "`pr'" != "" {
		if "`pe'" == "" {
			BackSel	`pr'		///
				"`hier'"	///
				"`lr'"		///
				"`lockterm1'"	///
				"`version'"	///
				`cmdname'	///
				"`depvar'"	///
				"`termlist'"	///
				`touse'		///
				"`cmdrest'"
		}
		else if "`forward'" == "" {
			BackStep `pr'		///
				`pe'		///
				"`lr'"		///
				"`lockterm1'"	///
				"`version'"	///
				`cmdname'	///
				"`depvar'"	///
				"`termlist'"	///
				`touse'		///
				"`cmdrest'"
		}
		else {
			ForStep	`pr'		///
				`pe'		///
				"`lr'"		///
				"`lockterm1'"	///
				"`version'"	///
				`cmdname'	///
				"`depvar'"	///
				"`termlist'"	///
				`touse'		///
				"`cmdrest'"
		}
	}
	else {
		ForSel	`pe'		///
			"`hier'"	///
			"`lr'"		///
			"`lockterm1'"	///
			"`version'"	///
			`cmdname'	///
			"`depvar'"	///
			"`termlist'"	///
			`touse'		///
			"`cmdrest'"
	}

	ereturn local stepwise stepwise

	Display, `diopts'
end

program BackSel
	args pr hier lr lock version cmdname depvar termlist touse cmdrest

	TermMacros term k curr : `lock' : `termlist'

	if "`lr'" != "" {
		local LRtest "LR test"
	}

	di in smcl as txt "{p2colset 0 23 32 2}{...}"
	di as txt "{p2col :`LRtest'}begin with full model{p_end}"

	// note: the "full" model has already been fit, and e() should already
	// contain it's results

	if "`lr'" != "" {
		tempname ll1 df1 ll0 df0
		GetLR `ll1' `df1'
	}

	local prfmt : display %6.4f `pr'
	local done 0
	local k0 `k'
	while !`done' {
		local drop_i 0
		local p_i 0
		if "`hier'" != "" & `k' > 0 {
			local start `k'
		}
		else	local start 1
		forval i = `start'/`k' {
			if "`lr'" != "" {

local curr1 : subinstr local curr "`term`i''" "", word
quietly `version' `cmdname' `depvar' `curr1' if `touse' `cmdrest'

				quietly LRtest `ll1' `df1'
				
			}
			else	quietly mim: testparm `term`i''
			if r(p) > `p_i' {
				local p_i = r(p)
				local drop_i `i'
				if "`lr'" != "" {
					GetLR `ll0' `df0'
				}
			}
		}
		if `p_i' >= `pr' {
			local p : display %6.4f `p_i'
			di as txt ///
"{p2col :p = {res:`p'} >= `prfmt'}removing {res:`term`drop_i''}{p_end}"
			local newcurr : list curr - term`k'
			local curr : ///
			subinstr local newcurr "`term`drop_i''" "`term`k''", word
			local term`drop_i' `term`k''
			local term`k'
			local --k
		}
		else {
			if "`hier'" != "" & `k' > 0 {
				local p : display %6.4f `p_i'
				di as txt ///
"{p2col :p = {res:`p'} <{space 2}`prfmt'}" ///
"keeping{space 2}{res:`term`drop_i''}{p_end}"
			}
			local done 1
		}

		if "`lr'" != "" {
			scalar `ll1' = `ll0'
			scalar `df1' = `df0'
		}
		else {

quietly `version' `cmdname' `depvar' `curr' if `touse' `cmdrest'

		}

	}
	if "`lr'" != "" {

quietly `version' `cmdname' `depvar' `curr' if `touse' `cmdrest'

	}
	if `k' == `k0' {
		di as txt ///
"{p2col :p < `prfmt'}for all terms in model{p_end}"
	}
	di in smcl as txt "{p2colreset}{...}"
end

program BackStep
	args pr pe lr lock version cmdname depvar termlist touse cmdrest

	TermMacros term k curr : `lock' : `termlist'

	if "`lr'" != "" {
		local LRtest "LR test"
	}

	di in smcl as txt "{p2colset 0 23 32 2}{...}"
	di as txt "{p2col :`LRtest'}begin with full model{p_end}"

	// note: the "full" model has already been fit, and e() should already
	// contain it's results

	if "`lr'" != "" {
		tempname ll1 df1 ll0 df0
		GetLR `ll1' `df1'
	}

	local prfmt : display %6.4f `pr'
	local pefmt : display %6.4f `pe'
	local done 0
	local k0 `k'
	local kp1 = `k' + 1
	local first 1
	while !`done' {
		// backward step
		local drop_i 0
		local p_i 0

		forval i = 1/`k' {
			if "`lr'" != "" {

local curr1 : subinstr local curr "`term`i''" "", word
quietly `version' `cmdname' `depvar' `curr1' if `touse' `cmdrest'

				quietly LRtest `ll1' `df1'
				
			}
			else	quietly mim: testparm `term`i''
			if r(p) > `p_i' {
				local p_i = r(p)
				local drop_i `i'
				if "`lr'" != "" {
					GetLR `ll0' `df0'
				}
			}
		}
		if `p_i' >= `pr' {
			local p : display %6.4f `p_i'
			di as txt ///
"{p2col :p = {res:`p'} >= `prfmt'}removing {res:`term`drop_i''}{p_end}"
			local newcurr : list curr - term`k'
			local curr : ///
			subinstr local newcurr "`term`drop_i''" "`term`k''", word
			local tmp `term`k''
			local term`k' `term`drop_i''
			local term`drop_i' `tmp'
			local --k
			local --kp1
			if `first' & "`lr'" != "" {
				scalar `ll1' = `ll0'
				scalar `df1' = `df0'
			}
		}
		else {
			local done 1
			if "`lr'" != "" {
				scalar `ll0' = `ll1'
				scalar `df0' = `df1'
			}
		}

		if `first' {
			if "`lr'" == "" {

quietly `version' `cmdname' `depvar' `curr' if `touse' `cmdrest'

			}
			local first 0
			continue
		}

		// forward step
		local add_i 0
		local p_i 2
		forval i = `kp1'/`k0' {

quietly `version' `cmdname' `depvar' `curr' `term`i'' if `touse' `cmdrest'

			if "`lr'" != "" {
				quietly LRtest `ll0' `df0'
			}
			else	quietly mim: testparm `term`i''
			if r(p) < `p_i' {
				local p_i = r(p)
				local add_i `i'
				if "`lr'" != "" {
					GetLR `ll1' `df1'
				}
			}
		}
		if `p_i' < `pe' {
			local p : display %6.4f `p_i'
			di as txt ///
"{p2col :p = {res:`p'} <{space 2}`pefmt'}" ///
"adding{space 3}{res:`term`add_i''}{p_end}"
			local curr `curr' `term`add_i''
			if "`hier'" != "" {
				local ++start
			}
			else {
				local tmp `term`kp1''
				local term`kp1' `term`add_i''
				local term`add_i' `tmp'
				local ++k
				local ++kp1
			}
			local done 0
		}
		else {
			if "`lr'" != "" {
				scalar `ll1' = `ll0'
				scalar `df1' = `df0'
			}

		}
		if "`lr'" == "" {

quietly `version' `cmdname' `depvar' `curr' if `touse' `cmdrest'

		}
	}

quietly `version' `cmdname' `depvar' `curr' if `touse' `cmdrest'

	if `k' == `k0' {
		di as txt ///
"{p2col :p < `prfmt'}for all terms in model{p_end}"
	}
	di in smcl as txt "{p2colreset}{...}"
end

program ForSel
	args pe hier lr lock version cmdname depvar termlist touse cmdrest

	TermMacros term k curr : `lock' : `termlist'
	local curr `term0' // is empty if `"`lock'"' == ""

	if "`lr'" != "" {
		local LRtest "LR test"
	}

	di in smcl as txt "{p2colset 0 23 32 2}{...}"
	if "`lock'" == "" {
		di as txt "{p2col :`LRtest'}begin with empty model{p_end}"
	}
	else	di as txt "{p2col :`LRtest'}begin with term 1 model{p_end}"

	if "`lr'" != "" {
		// fit the empty model
		quietly `version' `cmdname' `depvar' if `touse' `cmdrest'
		tempname ll0 df0 ll1 df1
		GetLR `ll0' `df0'
	}

	local start 1
	local pefmt : display %6.4f `pe'
	local done 0
	while !`done' {
		local add_i 0
		local p_i 2
		if "`hier'" != "" {
			local last `start'
		}
		else	local last `k'
		forval i = `start'/`last' {

quietly `version' `cmdname' `depvar' `curr' `term`i'' if `touse' `cmdrest'

			if "`lr'" != "" {
				quietly LRtest `ll0' `df0'
			}
			else	quietly mim: testparm `term`i''
			if r(p) < `p_i' {
				local p_i = r(p)
				local add_i `i'
				if "`lr'" != "" {
					GetLR `ll1' `df1'
				}
			}
		}
		if `p_i' < `pe' {
			local p : display %6.4f `p_i'
			di as txt ///
"{p2col :p = {res:`p'} <{space 2}`pefmt'}" ///
"adding{space 2}{res:`term`add_i''}{p_end}"
			local curr `curr' `term`add_i''
			if "`hier'" != "" {
				local ++start
				if `start' > `k' {
					local done 1
				}
			}
			else {
				local term`add_i' `term`k''
				local term`k'
				local --k
			}
		}
		else {
			if "`hier'" != "" {
				local p : display %6.4f `p_i'
				di as txt ///
"{p2col :p = {res:`p'} >= `pefmt'}testing {res:`term`add_i''}{p_end}"
			}
			local done 1
		}
		if "`lr'" != "" {
			scalar `ll0' = `ll1'
			scalar `df0' = `df1'
		}
	}

	if "`curr'" == "`term0'" {
		di as txt ///
"{p2col :p >= `pefmt'}for all terms in model{p_end}"
	}

quietly `version' `cmdname' `depvar' `curr' if `touse' `cmdrest'

	di in smcl as txt "{p2colreset}{...}"
end

program ForStep
	args pr pe lr lock version cmdname depvar termlist touse cmdrest

	TermMacros term k curr : `lock' : `termlist'
	local curr `term0'

	if "`lr'" != "" {
		local LRtest "LR test"
	}

	di in smcl as txt "{p2colset 0 23 32 2}{...}"
	if "`lock'" == "" {
		di as txt "{p2col :`LRtest'}begin with empty model{p_end}"
	}
	else	di as txt "{p2col :`LRtest'}begin with term 1 model{p_end}"

	if "`lr'" != "" {
		// fit the empty model
		quietly `version' `cmdname' `depvar' `curr' if `touse' `cmdrest'
		tempname ll0 df0 ll1 df1
		GetLR `ll0' `df0'
	}

	local prfmt : display %6.4f `pr'
	local pefmt : display %6.4f `pe'
	local done 0
	local k0 `k'
	local k 0
	local kp1  1
	local first 1
	while !`done' {
		// forward step
		local add_i 0
		local p_i 2
		forval i = `kp1'/`k0' {

quietly `version' `cmdname' `depvar' `curr' `term`i'' if `touse' `cmdrest'

			if "`lr'" != "" {
				quietly LRtest `ll0' `df0'
			}
			else	quietly mim: testparm `term`i''
			if r(p) < `p_i' {
				local p_i = r(p)
				local add_i `i'
				if "`lr'" != "" {
					GetLR `ll1' `df1'
				}
			}
		}
		if `p_i' < `pe' {
			local p : display %6.4f `p_i'
			di as txt ///
"{p2col :p = {res:`p'} <{space 2}`pefmt'}" ///
"adding{space 3}{res:`term`add_i''}{p_end}"
			local curr `curr' `term`add_i''
			if "`hier'" != "" {
				local ++start
			}
			else {
				local tmp `term`kp1''
				local term`kp1' `term`add_i''
				local term`add_i' `tmp'
				local ++k
				local ++kp1
			}
			if `first' & "`lr'" != "" {
				scalar `ll0' = `ll1'
				scalar `df0' = `df1'
			}
		}
		else {
			if "`lr'" != "" {
				scalar `ll1' = `ll0'
				scalar `df1' = `df0'
			}
			local done 1
		}

		if `first' {
			local first 0
			continue
		}

		if "`lr'" == "" {

quietly `version' `cmdname' `depvar' `curr' if `touse' `cmdrest'

		}

		// backward step
		local drop_i 0
		local p_i 0
		forval i = 1/`k' {
			if "`lr'" != "" {

local curr1 : subinstr local curr "`term`i''" "", word
quietly `version' `cmdname' `depvar' `curr1' if `touse' `cmdrest'

				quietly LRtest `ll1' `df1'
				
			}
			else	quietly mim: testparm `term`i''
			if r(p) > `p_i' {
				local p_i = r(p)
				local drop_i `i'
				if "`lr'" != "" {
					GetLR `ll0' `df0'
				}
			}
		}
		if `p_i' >= `pr' {
			local p : display %6.4f `p_i'
			di as txt ///
"{p2col :p = {res:`p'} >= `prfmt'}removing {res:`term`drop_i''}{p_end}"
			local newcurr : list curr - term`k'
			local curr : ///
			subinstr local newcurr "`term`drop_i''" "`term`k''", word
			local tmp `term`k''
			local term`k' `term`drop_i''
			local term`drop_i' `tmp'
			local --k
			local --kp1
			local done 0
		}
		else {
			if "`lr'" != "" {
				scalar `ll0' = `ll1'
				scalar `df0' = `df1'
			}
		}
	}

	if "`curr'" == "`term0'" {
		di as txt ///
"{p2col :p >= `pefmt'}for all terms in model{p_end}"
	}

quietly `version' `cmdname' `depvar' `curr' if `touse' `cmdrest'

	di in smcl as txt "{p2colreset}{...}"
end

// Syntax: <c_depvar> <c_terms> : <touse> <cmdname> "[weight]" : <termlist>
//
// Parse the <termlist>, removing observations with missing values, and
// collinear variables.
program ParseTerms
	_on_colon_parse `0'
	local c_depvar : word 1 of `s(before)'
	local c_terms  : word 2 of `s(before)'
	_on_colon_parse `s(after)'
	local touse    : word 1 of `s(before)'
	local cmdname  : word 2 of `s(before)'
	local wgt      : word 3 of `s(before)'
	local constant : word 4 of `s(before)'
	local termlist `"`s(after)'"'

	local stcmds streg stcox
	local is_st : list cmdname in stcmds

	// there is no <depvar> for -stcox- and -streg-,
	// otherwise it is required
	if !`is_st' {
		gettoken depvar termlist : termlist, bind match(par)
		if "`par'" != "" {
			di as err "depvar cannot be part of a group"
			exit 198
		}
		unab depvar : `depvar'
		if "`cmdname'" != "intreg" {
			markout `touse' `depvar'
		}
		if "`cmdname'" == "intreg" {
			gettoken depvar2 termlist : termlist, bind match(par)
			if "`par'" != "" {
				di as err "depvar cannot be part of a group"
				exit 198
			}
			unab depvar2 : `depvar2'
			if "`cmdname'" != "intreg" {
				markout `touse' `depvar2'
			}
			local depvar `depvar' `depvar2'
		}
	}
	local k 0
	while `"`:list retok termlist'"' != "" {
		local ++k
		gettoken term termlist : termlist, bind match(par)
		if "`par'" == "" {
			unab term : `term'
			if `:word count `term'' != 1 {
				gettoken term rest : term
				local termlist `"`rest' `termlist'"'
			}
		}
		markout `touse' `term'
		quietly _rmcoll `term' if `touse' `wgt', `constant'
		local term`k' `r(varlist)'
		local xvars0 `xvars0' `term`k''
	}
	if `k' == 0 {
		di as err "no independent variables"
		exit 198
	}
	quietly _rmcoll `xvars0' if `touse' `wgt', `constant'
	local dups0 : list dups xvars0
	local xvars `r(varlist)'
	local colvar : list xvars0 - xvars
	if `"`colvar'"' != "" {
		local colvar : word 1 of `colvar'
		di as err "between-term collinearity, variable `colvar'"
		exit 459
	}

	forval i = 1/`k' {
		local dups : list term`i' & dups0
		if "`dups'" != "" {
			local term`i' : list term`i' - dups
			local dups0 : list dups0 - dups
		}
		if "`term`i''" != "" {
			local terms `"`terms' (`term`i'')"'
		}
	}

	// saved results
	c_local `c_depvar' `depvar'
	c_local `c_terms' `"`:list retok terms'"'
end

// Syntax: <c_stub> <c_k> <c_curr> : <termlist>
//
// Build local macros for the caller that contain each individual term, how
// many terms there are, and a list of all the current term variables.
program TermMacros
	_on_colon_parse `0'
	local c_stub : word 1 of `s(before)'
	local c_k    : word 2 of `s(before)'
	local c_curr : word 3 of `s(before)'
	_on_colon_parse `s(after)'
	local lock `s(before)'
	local termlist `"`s(after)'"'

	local k 0
	while `"`termlist'"' != "" {
		if "`lock'" != "" {
			local lock
		}
		else	local ++k
		gettoken term termlist : termlist, bind match(par)
		c_local `c_stub'`k' `term'
		local curr `"`curr' `term'"'
	}
	c_local `c_k' `k'
	c_local `c_curr' `"`:list retok curr'"'
end

program CheckProps
	args cmdname lr
	local props : properties `cmdname'
	local swlist sw swml
	local swprop : list swlist & props
	if "`swprop'" == "" { 
		di as err "`cmdname' is not supported by stepwise"
		exit 199
	}
	if "`lr'" != "" {
		local swlist swml
		if `"`:list swlist & props'"' == "" {
			di as err ///
			"`cmdname' does not allow the lr option of stepwise"
			exit 199
		}
	}
end

program Check4Robust, sclass
	gettoken lr 0 : 0
	if ("`lr'" == "") {
		syntax [fw pw aw iw] [, noConstant * ]
		sreturn local constant `constant'
		exit
	}
	syntax [fw pw aw iw] [, Robust CLuster(passthru) vce(string)	///
		noConstant * ]

	local lvce : length local vce
	if "`weight'" == "pweight" | "`robust'`cluster'`svy'" != "" ///
	 | `"`vce'"' == substr("robust",1,max(1,`lvce')) {
		if "`svy'" != "" {
			di as err "option `lr' is not allowed with svy"
		}
		else	di as err ///
"option `lr' is not allowed with pweights, robust, or cluster()"
		exit 198
	}
	sreturn local constant `constant'
end

program LRtest, rclass
	args ll1 df1
	tempname ll0 df0
	GetLR `ll0' `df0'
	return scalar p = chiprob(abs(`df1' - `df0'), abs(2*(`ll1'-`ll0')))
end

program GetLR
	args ll df
	capture confirm number `e(ll)'
	if c(rc) {
		di as err ///
"option lr requires that e(ll) contains the " ///
"log likelihood value for the model fit"
		exit 322
	}
	capture {
		confirm integer number `e(df_m)'
		assert e(df_m) >= 0
	}
	if c(rc) {
		di as err ///
"option lr requires that e(df_m) contains the " ///
"model degress of freedom"
		exit 322
	}
	scalar `ll' = e(ll)
	scalar `df' = e(df_m)
end

exit

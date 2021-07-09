* ************************************************************************************* *
*                                                                                       *
*   goprobit                                                                            *
*   Version 1.1 - last revised September 05, 2006                                       *
*                                                                                       *
*   Author: Stefan Boes, boes@sts.unizh.ch                                              *
*                                                                                       *
*                                                                                       *
* ************************************************************************************* *
*                                                                                       *
*                                                                                       *
*   goprobit is a user-written procedure to estimate generalized ordered probit models  *
*   in Stata. It is a rewritten version of Vincent Fu's and Richard Williams' gologit   *
*   routines that assumes normally instead of logistically distributed error terms.     *
*   The current version of Richard Williams' gologit2 allows to estimate the            *
*   generalized ordered probit model using the link(probit) option and therefore        *
*   produces results equivalent to goprobit.                                            *
*                                                                                       *
*                                                                                       *
* ************************************************************************************* *



program define goprobit, eclass sortpreserve
	version 8
	syntax [varlist(default=none)] [if] [in]				///
		[pweight fweight iweight]					///
		[, Robust CLuster(varname) Level(integer `c(level)')		///
		Pl Pl2(varlist) NPl NPl2(varlist)				///
		Constraints(string) SCore(passthru)	* ]


	* Replay results if that is all that is requested ****************************** *

	if replay() {
		if "`e(cmd)'" != "goprobit" {
			display as error "goprobit was not the last " ///
				"estimation command"
			exit 301
		}
		if _by() {
			display as error "You cannot use the by command " ///
				"when replaying gologit2 results"
			exit 190
		}
		Replay `0'
		exit
	}


	* Syntax checks **************************************************************** *
	if "`cluster'" != "" {
		local clopt cluster(`cluster')
	}

	if "`weight'" != "" {
		tempvar wvar
		quietly gen double `wvar' = `exp' if `touse'
		local wgt "[`weight'=`w']"
	}

	if `level' < 10 | `level' > 99 {
		display as error "Level must be an integer between 10 and 99"
		exit 198
	}

	* Note that only one of pl, pl(), npl, npl() can be specified and
	* npl is set as the default if nothing is specified
	local pl_options = 0
	foreach opt in pl npl pl2 npl2 {
		if "``opt''"!="" local pl_options = `pl_options' + 1
	}
	if `pl_options' == 0 {
		local npl "npl"
	}
	else if `pl_options' > 1 {
		di in red "only one of pl, pl(), npl, npl() can be specified"
		exit 198
	}


	* Select appropriate sample **************************************************** *
	marksample touse


	* Check varlist and pl, npl specifications ************************************* *
	gettoken y x: varlist

	_rmcoll `x' if `touse'
	local x "$S_1"
	local Numx: word count `x'

	if "`npl2'"!="" {
		local nplchek: list local(npl2) - local(x)
		if "`nplchek'"!="" {
			display ""
			display as error ///
				"npl{yellow}(`nplchek'){red} is not a subset of X"
			display ""
			exit 198
		}
	}
	else if "`pl2'"!="" {
		local plchek: list local(pl2) - local(x)
		if "`plchek'"!="" {
			display ""
			display as error ///
				"pl{yellow}(`plchek'){red} is not a subset of X"
			display ""
			exit 198
		}
	}


	* Create equations needed for the model **************************************** *
	tempname Y_Values
	quietly tab `y' if `touse', matrow(`Y_Values')
	matrix `Y_Values' = `Y_Values''
	local J = r(r)
	local Numeqs = `J' - 1


	macro drop dv_*
	forval i = 1/`J' {
		global dv_`i' = `Y_Values'[1, `i']
	}

	local eqs (mleq1:`y'=`x')
	forval i = 2/`Numeqs' {
		local eqs "`eqs' (mleq`i':`x')"
	}


	* Create constraints for parallel lines if requested *************************** *
	parallel_lines, numeqs(`Numeqs') x(`x') ///
		`pl' pl2(`pl2') `npl' npl2(`npl2')
	local plconstraints  `e(plconstraints)'
	local constraints `constraints' `plconstraints'
	local plvars `e(plvars)'
	local nplvars: list local(x) - local(plvars)


	* Get starting values from constant-only oprobit ******************************* *
	tempname b0
	local columnames ""
	quietly oprobit `y' `wgt' if `touse', `robust' `clopt'
	mat `b0' = e(b)
	mat `b0' = -1 * `b0'
	forval i = 1/`Numeqs' {
		local columnames `columnames' mleq`i':_cons
	}
	matrix colnames `b0' = `columnames'
	if e(ll) < . local LL0 = e(ll)
	local crittype = e(crittype)


	* Estimate the final model using ml model ************************************** *
	if ("`constraints'"=="") local lf0 lf0(`Numeqs' `LL0')
	mlopts ml_options, `options'
	ml model lf goprobit_ll `eqs' `wgt' if `touse', 			///
		constraints(`constraints')  `robust'  `clopt'			///
		waldtest(-`Numeqs')  init(`b0')  search(off)  `lf0'		///
		title(Generalized Ordered Probit Estimates) 			///
		collinear  maximize  `score'					///
		`ml_options'

	ereturn local plvars `plvars'
	ereturn local nplvars `nplvars'
	ereturn local xvars `x'
	ereturn scalar k_cat = `J'
	ereturn matrix cat = `Y_Values'

	constraint drop `plconstraints'
	macro drop dv_*

	ereturn local predict "goprobit_p"
	ereturn local cmd goprobit

	local display_options `display_options' level(`level')


	Replay, `display_options'

end



program define parallel_lines, eclass
	syntax [, numeqs(int 1) ///
		x(varlist) pl pl2(varlist) npl npl2(varlist)  ]
	local Numeqs `numeqs'
	local NumConstraints = `Numeqs' - 1
	local x "`x'"

	* ****************************************************************************** *
	* Create the parallel lines constraints if they have been requested.
	* This can be done via either the pl or npl options.

	* 1. If npl is specified without parameters, all beta's are ******************** *
	*    allowed to differ across equations
	if "`npl'"!="" {
		ereturn local plvars ""
		ereturn local plconstraints  ""
		exit
	}

	* 2. If pl is specified without parameters, all beta's are ********************* *
	*    constrained to meet the parallel lines assumption
	else if "`pl'"!="" {
		forval j = 1/`NumConstraints' {
			local k = `j' + 1
			constraint free
			constraint `r(free)' [#`j'=#`k']
			local plconstraints `plconstraints' `r(free)'
		}
		ereturn local plvars "`x'"
		ereturn local plconstraints  "`plconstraints'"
		exit

	}


	* 3. Any vars specified in pl() will be constrained to have equal ************** *
	*    beta's across equations
	*    No further action is needed until constraints generated

	* 4. Vars specified in npl() will not be constrained; ************************** *
	*    those not specified will be

	if "`npl2'"!="" local pl2: list local(x) - local(npl2)

	local Numpl: word count `pl2'
	if `Numpl' > 0 {
		forval j = 1/`NumConstraints' {
			local k = `j' + 1
			constraint free
			constraint `r(free)' [#`j'=#`k']:`pl2'
			local plconstraints `plconstraints' `r(free)'
		}

	}
	ereturn local plvars "`pl2'"
	ereturn local plconstraints  "`plconstraints'"
end



program Replay
	syntax [,   Level(integer `c(level)')  * ]
	local display_options `display_options' level(`level')
	ml display , `display_options'
end



* ************************************************************************************* *
*                                                                                       *
*   regoprob                                                                            *
*   Version 1.0.3 - last revised September 05, 2006                                     *
*                                                                                       *
*   Author: Stefan Boes, boes@sts.unizh.ch                                              *
*                                                                                       *
*   Version 1.0    - initial version                                                    *
*   Version 1.0.1  - revision of help file and predict command                          *
*   Version 1.0.2  - score option deleted                                               *
*   Version 1.0.3  - problems in the predicted probabilities fixed                      *
*   Version 1.0.4  - problems when using mfx fixed, revision of help file               *
*                                                                                       *
* ************************************************************************************* *
*                                                                                       *
*                                                                                       *
*   regoprob is a user-written procedure to estimate random effects generalized         *
*   ordered probit models in Stata. It is a rewritten version of goprobit for panel     *
*   data that assumes normally distributed error terms and individually specific        *
*   effects. The likelihood for each unit is approximated by Gauss-Hermite quadrature.  *
*                                                                                       *
*                                                                                       *
* ************************************************************************************* *


pause on
program define regoprob, eclass sortpreserve
	version 8
	syntax [varlist(default=none)] [if] [in]				///
		[, I(varname) Quadrat(int 12) Level(integer `c(level)')		///
		Pl Pl2(varlist) NPl NPl2(varlist)				///
		Constraints(string) * ]


	* Replay results if that is all that is requested ********************************* *
	if replay() {
		if "`e(cmd)'" != "regoprob" {
			display as error "regoprob was not the last " 		///
				"estimation command"
			exit 301
		}
		if _by() {
			display as error "You cannot use the by command " 	///
				"when replaying regoprob results"
			exit 190
		}
		Replay `0'
		exit
	}


	* Syntax checks ******************************************************************* *
	if "`i'" == "" {
		display as error "i() required"
		exit 198
	}

	if `level' < 10 | `level' > 99 {
		display as error "Level must be an integer between 10 and 99"
		exit 198
	}

	* Note that only one of pl, pl(), npl, npl() can be specified and
	* npl is set as the default if nothing is specified
	local pl_options = 0
	foreach opt in pl npl pl2 npl2 {
		if "``opt''"!="" {
			local pl_options = `pl_options' + 1
		}
	}
	if `pl_options' == 0 {
		 local npl "npl"
	}
	else if `pl_options' > 1 {
		di in red "only one of pl, pl(), npl, npl() can be specified"
		exit 198
	}


	* Select appropriate sample ******************************************************* *
	marksample touse


	* Read y and x from data ********************************************************** *
	gettoken y x: varlist


	* Check variable specification in npl(), pl() ************************************* *
	_rmcoll `x' if `touse'
	local x "$S_1"
	local Numx: word count `x'

	if "`npl2'"!="" {
		local nplchek: list local(npl2) - local(x)
		if "`nplchek'"!="" {
			display ""
			display as error ///
				"npl{yellow}(`nplchek'){red} is not a subset of x"
			display ""
			exit 198
		}
	}
	else if "`pl2'"!="" {
		local plchek: list local(pl2) - local(x)
		if "`plchek'"!="" {
			display ""
			display as error ///
				"pl{yellow}(`plchek'){red} is not a subset of x"
			display ""
			exit 198
		}
	}


	* Get points and weights for Gauss-Hermite quadrature ***************************** *
	tempvar ab we
	ghquadm `quadrat' `ab' `we'


	* Create equations needed for the model ******************************************* *
	tempname Y_Values
	quietly tab `y' if `touse', matrow(`Y_Values')
	matrix `Y_Values' = `Y_Values''
	local J = r(r)
	local Numeqs = `J' - 1
	local eqs (mleq1:`y'=`x')
	local steqs (mleq1:`y'= )
	forval ind = 2/`Numeqs' {
		local eqs "`eqs' (mleq`ind':`x')"
		local steqs "`steqs' /mleq`ind' "
	}


	* Create constraints for parallel lines if requested ****************************** *
	parallel_lines, numeqs(`Numeqs') x(`x') ///
		`pl' pl2(`pl2') `npl' npl2(`npl2')
	local plconstraints  `e(plconstraints)'
	local constraints `constraints' `plconstraints'
	local plvars `e(plvars)'
	local nplvars: list local(x) - local(plvars)


	* Get starting values from goprobit *********************************************** *
	tempname b0 s0
	quietly goprobit `y' if `touse'
	matrix `s0' = e(b)
	matrix `s0' = [`s0', 0.5]

	quietly goprobit `y' `x' if `touse', constraints(`constraints')
	matrix `b0' = e(b)
	matrix `b0' = [`b0', 0.5]
	if e(ll) < . local LL0 = e(ll)
	local crittype = e(crittype)


	* Set up macros for likelihood **************************************************** *
	macro drop S_i S_y S_x S_quad S_ab S_we S_J S_Numeqs dv_*

	global S_i   "`i'"
	global S_y   "`y'"
	global S_x   "`x'"
	global S_quad   "`quadrat'"
	global S_ab   "`ab'"
	global S_we   "`we'"
	global S_J   "`J'"
	global S_Numeqs   "`Numeqs'"

	forval ind = 1/$S_J {
		global dv_`ind' = `Y_Values'[1, `ind']
	}


	* Sort the data ******************************************************************* *
	sort $S_i


	* Estimate the final model using ml model ***************************************** *
	local Numeqsp = `Numeqs' + 1
	if ("`constraints'"=="") local lf0 lf0(`Numeqsp' `LL0')
	mlopts ml_options, `options'

	di in green _n "Fitting constant-only model:"
	ml model d1 regoprob_llc `steqs' /rho if `touse',			///
		init(`s0', copy)  search(off)  					///
		collinear maximize						///
		`ml_options'

	di in green _n "Fitting full model:"
	ml model d1 regoprob_ll `eqs' /rho if `touse', 				///
		waldtest(-`Numeqsp') continue init(`b0', copy)  search(off)	///
		`lf0' constraints(`constraints')				///
		title(Random Effects Generalized Ordered Probit) 		///
		collinear maximize						///
		`ml_options'


	ereturn local plvars `plvars'
	ereturn local nplvars `nplvars'
	ereturn local xvars `x'
	ereturn scalar k_cat = `J'
	ereturn matrix cat = `Y_Values'

	constraint drop `plconstraints'
	macro drop dv_*
	macro drop S_*

	ereturn local predict "regoprob_p"
	ereturn local cmd regoprob

	local display_options `display_options'
	Replay, `display_options'

end




program Replay
	syntax [,   Level(integer `c(level)')  * ]
	local display_options `display_options'
	ml display , `display_options'
end




program define parallel_lines, eclass

	syntax [, numeqs(int 1) ///
		x(varlist) pl pl2(varlist) npl npl2(varlist)  ]

	local Numeqs `numeqs'
	local NumConstraints = `Numeqs' - 1
	local x "`x'"



	* ****************************************************************** *
	* Create the parallel lines constraints if they have been requested. *
	* This can be done via either the pl or npl options.                 *
	* ****************************************************************** *


	* 1. If npl is specified without parameters, all beta's are ******** *
	*    allowed to differ across equations **************************** *

	if "`npl'"!="" {
		ereturn local plvars ""
		ereturn local plconstraints  ""
		exit
	}


	* 2. If pl is specified without parameters, all beta's are ********* *
	*    constrained to meet the parallel lines assumption ************* *
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


	* 3. Any vars specified in pl() will be constrained to have equal ** *
	*    beta's across equations *************************************** *
	*    No further action is needed until constraints generated ******* *


	* 4. Vars specified in npl() will not be constrained; those not **** *
	*    specified will be ********************************************* *
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

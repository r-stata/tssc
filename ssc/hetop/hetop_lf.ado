*! version 3.0 10jul2019, Benjamin R. Shear and sean f. reardon

* likelihood calculations are carried out with data in wide format
* design informed by -oglm- written by Richard Williams

cap program drop hetop_lf
program define hetop_lf
	version 13.1

	// arguments are (meanseqn) [(lnsigmaeqn)] (cut1) [(cut2) (cut3) ...]
	// (lnsigmaeqn) not included for HOMOP model
	// number of cut score equations varies
	// global $fixedsd is already defined
	// globals $FW_1,...,$FW_`numcats' for each category are already defined
	// global $csd is the fixed value for HOMOP common SD

	gettoken lnf rest: 0

	// means
	gettoken mu rest: rest
	
	// standard deviations
	local fixedsd $fixedsd
	if `fixedsd' {
		local sigma = exp($clsd)
	}
	else {
		gettoken lnsigma rest: rest
		local sigma exp(`lnsigma')
	}

	// cut scores
	local j = 0
	foreach kappa in `rest' {
		local j = `j' + 1
		local kappa`j' `kappa'
	}
	local M = `j'		// number of cuts
	local K = `j' + 1	// number of categories

	// likelihood calculations; based on probit
	forv i = 1/`K' {
		tempvar p`i'
	}
	qui gen double `p1' = normal((`kappa1'-`mu')/`sigma')
	forv i = 2/`M' {
		local j = `i'-1
		qui gen double `p`i'' = normal((`kappa`i''-`mu')/`sigma') - ///
							normal((`kappa`j''-`mu')/`sigma')
	}
	qui gen double `p`K'' = 1 - normal((`kappa`M''-`mu')/`sigma')

	local lleqn
	forv i = 1/`K' {
		if `i' == 1 local lleqn "${FW_1} * ln(`p1')"
		if `i' >  1 local lleqn "`lleqn' + ${FW_`i'} * ln(`p`i'')"
	}

	qui replace `lnf' = `lleqn'

end


*! version 0.1.2  2017-04-20
*! Bug when using stcox and icp fixed
* version 0.1.1  16dec2015
version 11


program define robust_binreg
	syntax varlist (min=3)
	tempvar estimates
	quietly poisson `varlist', irr vce(robust)
	quietly predict `estimates'
	binreg `varlist', rr init(`estimates')
end


program define ic
	/* TODO: Choose to see underlying regression */
	syntax varlist (min=3 ts fv) [, referenceA(integer 0) referenceB(integer 0) ///
							exposedA(integer 1) exposedB(integer 1) rrby(str) show]

	local options `", referenceA(`referenceA') referenceB(`referenceB') exposedA(`exposedA') exposedB(`exposedB') `show'"'

	if inlist(lower(`"`rrby'"'), "or", "") {
		icp `options': logistic `varlist', coef
	}
	if lower(`"`rrby'"') == "poisson" {
		icp  `options': poisson `varlist', irr vce(robust)
	}
	if lower(`"`rrby'"') == "binomial" {
		icp  `options': robust_binreg `varlist', rr //init(`estimates')
	}
	if !inlist(lower(`"`rrby'"'), "or", "poisson", "binomial", "") {
		display as error "Not a proper argument for rrby"
		exit
	}
end

!version 2.0.0   02Jun2014
program define gmm_mqg

	version 13.1 

	syntax varlist if , at(name) 	///
		depvar(varlist)		///
		shapevars(varlist) 	///
		lnsvars(varlist)	///
		treat(varlist)		///
		z0parms(string)		///
		z1parms(string)		///
		lns0parms(string)	///
		lns1parms(string)	///
		qparms(string)		///
		qnames(string)		///
		np(real)		///
		touse(varname)		///
		[			///
		fail(varlist)		///
		quantile(numlist)	///
		]

	local nshapevars : word count `shapevars'
	if `nshapevars' < 1 {
		display as err "no shapevars"
		exit 498
	}

	local nlnsvars : word count `lnsvars'
	if `nlnsvars' < 1 {
		display as err "no lnsvars"
		exit 498
	}

	local nquantile : word count `quantile'
	if `nquantile' < 1 {
		display as err "no quantiles"
		exit 498
	}

	local cnames "`qparms' `z0parms' `lns0parms' `z1parms' `lns1parms'" 
	matrix colnames `at' = `cnames' 
	
	tempvar z_0 z_1 lns_0 lns_1 z ez sm2 sy G lns sm2_0 sm2_1
	tempvar mc_z mc_lns 

	quietly {
		matrix score double `z_0'   = `at' , equation(z_0)
		matrix score double `lns_0' = `at' , equation(lns_0)

		matrix score double `z_1'   = `at' , equation(z_1)
		matrix score double `lns_1' = `at' , equation(lns_1)
// needed for quantiles
		generate double `sm2_0' = exp(-2*`lns_0')
// needed for quantiles
		generate double `sm2_1' = exp(-2*`lns_1')

		generate double `z'   = cond(`treat'==0, `z_0', `z_1')
		generate double `lns' = cond(`treat'==0, `lns_0', `lns_1')
// no cond() required
		generate double `sm2' = exp(-2*`lns')
// no cond() required
		generate double `ez'  = exp(-`z')
// no cond() required; sy is scaled y	
		generate double `sy'  = `depvar'*`sm2'*`ez'
// no cond() required
		generate double `G'   = gammap(`sm2',`sy')
		
		if "`fail'" == "" {
			generate double `mc_z'   = (`depvar'*`ez' - 1)*`sm2' 

			generate double `mc_lns' = 			///
			2*`sm2'*(digamma(`sm2') + `z' 			///
			+ 2*`lns' + `depvar'*`ez' - 1 - ln(`depvar'))	
		}
		else {
			generate double `mc_z'   = 			///
			((`fail')*(`depvar'*`ez' - 1)*`sm2' 		///
			+ (1-`fail')*dgammapdx(`sm2',`sy')*`sy'/(1-`G'))

			generate double `mc_lns' = 			///
			((`fail')*(2*`sm2'*(digamma(`sm2') + `z' 	///
			+ 2*`lns' + `depvar'*`ez' - 1 - ln(`depvar')))	///
			+ (1-`fail')*(2*`sm2'*(dgammapda(`sm2',`sy') 	///
			+ dgammapdx(`sm2',`sy')*`depvar'*`ez'))/(1-`G'))
		}

		local mc_z_0   : word 1 of `varlist'
		local mc_lns_0 : word 2 of `varlist'
		local mc_z_1   : word 3 of `varlist'
		local mc_lns_1 : word 4 of `varlist'

		replace `mc_z_0'   = (1-`treat')*`mc_z' if `touse'
		replace `mc_lns_0' = (1-`treat')*`mc_lns' if `touse'

		replace `mc_z_1'   = (`treat')*`mc_z' if `touse'
		replace `mc_lns_1' = (`treat')*`mc_lns' if `touse'

		local i = 1
		foreach qname of local qnames {
			tempvar `qname'_0 `qname'_1 
			matrix score double ``qname'_0' = `at' , 	///
				equation(`qname'_0)
			matrix score double ``qname'_1' = `at' , 	///
				equation(`qname'_1)

			local qvalue : word `i' of `quantile'
			local nmc = 1 + 4 + (`i'-1)*2	
			local mcq_0 : word `nmc' of `varlist'
			replace `mcq_0' = (gammap(`sm2_0',		///
				``qname'_0'*exp(-`z_0'-2*`lns_0')) 	///
				- `qvalue') if `touse'

			local nmc = 1 + 5 + (`i'-1)*2	
			local mcq_1 : word `nmc' of `varlist'
			replace `mcq_1' = (gammap(`sm2_1',		///
				``qname'_1'*exp(-`z_1'-2*`lns_1')) 	///
				- `qvalue') if `touse'

			local ++i
		}
	
	}

end


*! version 1.0.2  09jun2015
program define spreg_p, sortpreserve
	
	version 11.1

	syntax [anything] [if] [in] [, 			   ///
			RForm 				   ///  default
			LImited 			   ///
			FUll  		   		   ///
			NAive				   ///
			xb				   ///
			TOLerance(real .0000001) 	   ///  UNDOCUMENTED
			ITERate(numlist max=1 integer >=0) ///  UNDOCUMENTED
			RFTransform(string)		   ///  
			*				   ///
			]
	
	marksample touse 	// this is not e(sample)
	
	tempvar esample
	qui gen byte `esample' = e(sample)
	
	local tolerance = `tolerance'
	if "`iterate'" == "" local iterate = 100
		
	// parse anything
	
	local words : word count `anything'	
	if (`words'<1 | `words'>3) {
		di "{err}invalid syntax"
		exit 198
	}
	
	// parse predict options
	
	local propt = "`rform' `limited' `full' `naive' `xb'"
	local words : word count `propt'
	
	if `words'==0 {
		if "`e(cmd)'"=="spreg" {
			di "{txt}(option rform assumed)"
			local propt rform
		}
		else {
			di "{txt}(option naive assumed)"
			local propt naive
		}
	}
	
	if `words'>1 {
		di "{err}only one prediction method is allowed"
		exit 198
	}
	
	if ("`e(model)'"=="lr") {
		predict `anything'	// calls ols
	}
	else {
		gettoken type yhat : anything
		qui generate `type' `yhat' = .
		if "`yhat'"=="" local yhat `type'
		mata: SPREG_predict("`yhat'","`touse'","`esample'",	///
			"`propt'",`rftransform')
	}
	
	// label variable
	
	local propt = trim("`propt'")
	
	if "`propt'"=="xb" {
		label var `yhat' "Independent variable prediction"
	}
	if "`propt'"=="naive" {
		label var `yhat' "Naive prediction"
	}
	if "`propt'"=="rform" {
		label var `yhat' "Reduced form prediction"
	}
	if "`propt'"=="limited" {
		label var `yhat' "Limited information prediction"
	}
	if "`propt'"=="full" {
		label var `yhat' "Full information prediction"
	}
	
end

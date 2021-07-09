*! 1.6.0 MLB 12Sep2012

program define propcnsreg_p
        version 9

			/* handle scores */
	syntax [anything] [if] [in] [, SCores var(varname) * ]
    if `"`scores'"' != "" {
        GenScores `0'
        exit
    }


    local myopts "mu LATent EFFect"
    _pred_se "`myopts'" `0'
    if `s(done)'  exit 
    local vtyp `s(typ)'
    local varn `s(varn)'
    local 0    `"`s(rest)'"'
    syntax [if] [in] [, `myopts']

                   /* concatenate switch options together */
    local type "`mu'`latent'`effect'"

    marksample touse

	/* expected value of the dependent variable */
    if ("`type'"=="" | "`type'" == "mu")  {
        if "`type'"=="" {
            di in gr "(option mu assumed)"
        }
        tempvar t1 t2 t3
        qui _predict double `t1' if `touse' , eq(#3)
		qui _predict double `t2' if `touse' , eq(#2)
		qui _predict double `t3' if `touse' , eq(#1)
		qui replace `t1' = `t1' * `t2' + `t3'
        if "`e(title)'" == "ML fit of MIMIC model" | "`e(title)'" == "ML fit of linear regression with a proportionality constrained" {
	        gen `vtyp' `varn' = `t1' if `touse'
	    }
		else if "`e(title)'" == "ML fit of logit regression with a proportionality constrained" {
			gen `vtyp' `varn' = invlogit(`t1') if `touse'
		}
		else { // == poisson
			gen `vtyp' `varn' = exp(`t1') if `touse'
		}
		label var `varn' "predicted value for `e(depvar)'"
		exit
	}
	
	/* latent variable */
	if "`type'" == "latent" {
		_predict `vtyp' `varn' if `touse', eq(#3)
		label var `varn' "predicted value for latent variable"
		exit
	}
	
	/* Effect of latent variable */
	if "`type'" == "effect" {
		_predict `vtyp' `varn' if `touse', eq(#2)
		label var `varn' "predicted effect of the latent variable"
		exit
	}
    
	/* This point should never be reached */
	error 198
end

program GenScores
        version 8.2
        syntax [anything] [if] [in] [, * ]
        marksample touse
        
        _score_spec `anything', `options'
        local varn `s(varlist)'
        if "`s(eqname)'" != "" local eq "eq(`s(eqname)')"
        
        ml score `varn' if `touse', `eq'
end




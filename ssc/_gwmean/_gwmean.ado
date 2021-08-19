*! version 1,   5 March 2021, Gueorgui I. Kolev.
*! Optionally Weighted, Optionally Byable: Arithmetic (the default), Geometric and Harmonic means. 
*! Syntax: egen [type] newvar = wmean(expression) [if] [in] [, BY(varlist) Weights(varname) Arithmetic ///
*!			Geometric Harmonic Label]
*! Arithmetic Mean = Sum(Wi*Xi)/Sum(Wi) is the default.   
*! Geometric Mean = exp{Sum(Wi*log(Xi))/Sum(Wi)}, option Geometric. Applies only to Xi>0. 
*! Harmonic Mean = 1/[Sum(Wi/Xi)/Sum(Wi)],  option Harmonic. Applies only to Xi>0.

program define _gwmean
	version 11, missing
	syntax newvarname =/exp [if] [in] [, BY(varlist) Weights(varname) Arithmetic Geometric Harmonic Label]
	
	if (!missing("`arithmetic'") + !missing("`geometric'") + !missing("`harmonic'"))>1  {
                di as error "You can specify only one of Arithmetic Geometric Harmonic mean"
				di as error "If you do not specify any, the default is Arithmetic mean"
                exit 198
        }
		 
	if (!missing("`geometric'") + !missing("`harmonic'"))>0  {
                di as result "Geometric and Harmonic mean are defined for Xi>0 only."
				di as result "If some Xi<=0, I discard them, and compute on the basis of those Xi>0 only."
         }	

	tempvar touse
	quietly {
		gen byte `touse'=1 `if' `in'
		sort `touse' `by'	
		
		if "`weights'"=="" local weights=1
		
			if "`geometric'" != "" {
        	by `touse' `by': gen  double  `varlist' = sum(log(`exp')*`weights')/sum(!missing(log(`exp'))*`weights') if `touse'==1
			by `touse' `by': replace `varlist' = exp(`varlist'[_N])
			if "`label'" != "" la var `varlist' "Geometric mean of `exp'"
		}
		
		if "`harmonic'" != "" {
			by `touse' `by': gen  double `varlist' = sum(`weights'/max(`exp',0))/sum(!missing(1/max(`exp',0))*`weights') if `touse'==1
			by `touse' `by': replace `varlist' = 1/`varlist'[_N]
			if "`label'" != "" la var `varlist' "Harmonic mean of `exp'"
		}
		
		
		if "`geometric'" == "" &  "`harmonic'" == "" {
        	by `touse' `by': gen double `varlist' = sum((`exp')*`weights')/sum(!missing(`exp')*`weights') if `touse'==1
			by `touse' `by': replace `varlist' = `varlist'[_N]
			if "`label'" != "" la var `varlist' "Arithmetic mean of `exp'"							
		}		
	}	// Closes the Quietly brace.		
	
end

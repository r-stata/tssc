program psacalci, rclass
	version 12.0
	syntax anything [,rmax(real 1.0) delta(real -99.2) beta(real 0)]
	
	tokenize `anything'

	
	local hat_beta=`1'
	local hat_r = `2'
	local tilde_beta=`3'
	local tilde_r=`4'
	local yvar=`5'
	
	
	* Define Scenarios in which this breaks
	
	
	if `rmax'>1  {
	
		di _n
		di as err "The maximum possible R-squared is 1"
		exit 5001
		
	} 
	
	else if `rmax'<`tilde_r'  {
	
		di _n
		di as err "Maximum r-squared provided is less than controlled r-squared"
		exit 5001

	} 
	


* Main Program Arc

	else {
	


	if `delta'~=-99.2 {
		local type = 1
	}
	else {
		local type = 2
	}	

	
	
	gen yvar4533=`yvar'
	
	gen A4533=(`hat_beta'-`tilde_beta')
	gen B4533=(`tilde_r'-`hat_r')*yvar4533
	gen C4533=(`rmax'-`tilde_r')*yvar4533
	
	
	local boundx = ((`tilde_beta'-`beta')^2*B4533^2*A4533+(`tilde_beta'-`beta')*B4533*(B4533^2+A4533^2*B4533))/((`tilde_beta'-`beta')^2*B4533^2*A4533+C4533*A4533*(B4533^2+A^2*B4533))
	local bound: display %11.5f `boundx'

	
	if `delta'>=.999 & `delta'<=1.001 {
	
		local betax=`tilde_beta'-(A4533*C4533)/B4533
		local betat: display %11.5f `betax'
	}
	
	else  {
		

		
		local betax=`tilde_beta'-(sqrt((B4533^2+A4533^2*B4533)*(B4533^2+A4533^2*B4533+4*`delta'*(1-`delta')*(C4533*A4533^2)))-(B4533^2+A4533^2*B4533))/(2*(1-`delta')*B4533*A4533)
		local betat: display %11.5f `betax'
	}
	
	drop A4533 B4533 C4533 yvar4533
	
	if `type'==2 {
	
		di _n as txt ///
		_col(18) "{hline 4} Bound Estimate {hline 4}" _n ///
		_col(1) "{hline 13}{c +}{hline 64}" _n ///
		_col(1) "delta" _col(14) "{c |}" _col(18) as result %11.5f `bound' _n ///
		as txt _col(1) "{hline 13}{c +}{hline 64}" 	
	
		di _n as txt ///
		_col(18) "{hline 4} Inputs from Regressions {hline 4}" _n ///
		_col(14) "{c |}" _col(21) "Coeff." _col(49) "R-Squared" _n ///
		_col(1) "{hline 13}{c +}{hline 64}" _n ///
		_col(1) "Uncontrolled" _col(14) "{c |}" _col(18) as res %12.5f `hat_beta' _col(49) %5.3f `hat_r' _n ///
		_col(1) as txt "Controlled" _col(14) "{c |}" _col(18) as res %12.5f `tilde_beta' _col(49) %5.3f `tilde_r' _n ///
		_col(1) as txt "{hline 13}{c +}{hline 64}" 

		di _n as txt ///
		_col(18) "{hline 4} Other Inputs {hline 4}" _n ///
		_col(1) "{hline 13}{c +}{hline 64}" _n ///
		_col(1) "R_max" _col(14) "{c |}" _col(18) %5.3f `rmax' _n ///
		_col(1) "Beta" _col(14) "{c |}" _col(18) %9.6f `beta' _n ///
		_col(1) "M Controls" _col(14) "{c |}" _col(18) "`mcontrol'"  _n ///
		_col(1) "{hline 13}{c +}{hline 64}"  
		
		di as txt _col(5) "Reported delta matches a treatment effect of " as result `beta' 
		if `boundx'<0 {
			di as txt _col(5) "Warning: Negative delta implies controls move coefficient further from null" 
		}
		
			return scalar output=`boundx'
	* Note Beta At end
	* Not enegative detal
	
	}
	
	else if `type'==1 {
	
	
		di _n as txt ///
		_col(18) "{hline 4} Treatment Effect Estimate {hline 4}" _n ///
		_col(1) "{hline 13}{c +}{hline 64}" _n ///
		_col(1) "beta" _col(14) "{c |}" _col(18) as result %11.5f `betax' _n ///
		as txt _col(1) "{hline 13}{c +}{hline 64}" 	
	
		di _n as txt ///
		_col(18) "{hline 4} Inputs from Regressions {hline 4}" _n ///
		_col(14) "{c |}" _col(21) "Coeff." _col(49) "R-Squared" _n ///
		_col(1) "{hline 13}{c +}{hline 64}" _n ///
		_col(1) "Uncontrolled" _col(14) "{c |}" _col(18) as res %12.5f `hat_beta' _col(49) %5.3f `hat_r' _n ///
		_col(1) as txt "Controlled" _col(14) "{c |}" _col(18) as res %12.5f `tilde_beta' _col(49) %5.3f `tilde_r' _n ///
		_col(1) as txt "{hline 13}{c +}{hline 64}" 

		di _n as txt ///
		_col(18) "{hline 4} Other Inputs {hline 4}" _n ///
		_col(1) "{hline 13}{c +}{hline 64}" _n ///
		_col(1) "R_max" _col(14) "{c |}" _col(18) %5.3f `rmax' _n ///
		_col(1) "Delta" _col(14) "{c |}" _col(18) %5.3f `delta' _n ///
		_col(1) "M Controls" _col(14) "{c |}" _col(18) "`mcontrol'"  _n ///
		_col(1) "{hline 13}{c +}{hline 64}"  

		
		if `delta'<0 & `delta'~=-99.2 {
			di as txt _col(5) "Warning: Negative delta not a standard input" 
		}
		
		
		
			return scalar output=`betax'
	}
	
	
	}
	
end
exit




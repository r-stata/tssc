*  Modification of the rreg command to estimate a Huber M-estimator

program define mregress, eclass byable(recall) sort
	version 6, missing
	local options "Level(cilevel)"
	if replay() {
		if "`e(cmd)'"!="mregress" { error 301 }
		if _by() { error 190 }
		syntax [, `options']
	}
	else {
		local cmdline : copy local 0
		syntax varlist(ts) [if] [in] [, `options' /*
			*/ TUne(real 7) /*
			*/ NOConstant ]
		if _by() {
			_byoptnotallowed genwt() `"`genwt'"'
		}


		if `tune' <= 0 {
			di in red "tune() must be positive"
			exit 198
		}

		local toleran=0.001
		local iterate=1000
		tokenize `varlist'
		local lhs "`1'"
		tsunab lhs : `lhs'
		mac shift
		local rhs "`*'"
		*estimates clear

		tempvar res absdev maxd weight y oldw touse
		tempname max scale aa lambda resfin u

		local tune = `tune'*4.685/7
		local log = cond("`log'"=="", "noisily", "*")

		mark `touse' `if' `in'
		markout `touse' `lhs' `rhs'

quietly {

		if "`noconstant'"!="" {
		reg `lhs' `rhs' if `touse', noc 
		}

		else {
		reg `lhs' `rhs' if `touse'
		}

		gen `weight' = 1 if `touse'
		_predict double `res' if `touse', residual
		sum `res' if `touse', detail
		gen double `absdev' = abs(`res'-r(p50)) if `touse'
		gen double `maxd' = 1 if `touse'
		`log' di 

		local it 1
		scalar `max' = 1
		while `max' > 5*`toleran' & `it' <= `iterate' {
			capture drop `oldw'
			rename `weight' `oldw'
			sum `absdev' if `touse', detail
			gen double `weight' = cond( 		/*
			*/	abs(`res')>2*r(p50),     	/* 
			*/	2*r(p50)/abs(`res'), 1 ) 	/*
			*/	if `touse'

			if "`noconstant'"!="" {
			reg `lhs' `rhs' [aw=`weight'] if `touse', noc 
			}

			else {
			reg `lhs' `rhs' [aw=`weight'] if `touse'
			}

			drop `res'
			_predict double `res' if `touse', residual
			sum `res' if `touse', detail
			replace `absdev'= abs(`res'-r(p50)) if `touse'
			replace `maxd'=abs(`weight'-`oldw') if `touse'
			sum `maxd' if `touse', meanonly
			scalar `max' = r(max)
			`log' di in gr "Huber iteration `it':  " /*
				*/ "maximum difference in weights = " /*
				*/ in ye `max'
			local it = `it'+1
		}

		if `max' > 5*`toleran' {
			noi di in blu "Warning: Huber iterations" /*
			*/ " did not converge in `iterate' iterations"
		}

		scalar `max' = 1
		local notyet 1
		while (`max'>1& `it'<=`iterate') | `notyet' {
			local notyet 0
			capture drop `oldw'
			rename `weight' `oldw'
			sum `absdev' if `touse', detail
			scalar `scale' = r(p50)/.6745
			gen double `weight'=`oldw' 
			
			if "`noconstant'"!="" {
			reg `lhs' `rhs' [aw=`weight'] if `touse', noc
			}

			else {
			reg `lhs' `rhs' [aw=`weight'] if `touse'
			}

			drop `res'
			_predict double `res' if `touse', residual
			sum `res' if `touse', detail
			replace `absdev' = abs(`res'-r(p50)) /*
				*/ if `touse'
			replace `maxd'=abs(`weight'-`oldw') if `touse'
			sum `maxd' if `touse', meanonly
			scalar `max' = r(max)
			*/ "maximum difference in weights = " /*
			*/ in ye `max'
			local it = `it'+1
		}

		if `max' > `toleran' {
			noi di in blu _n "Warning: Did not converge" /*
			*/ " in `iterate' iterations"
		}

		replace `absdev' = (1-(1/`tune'^2)* /*
			*/ (`res'/`scale')^2)*(1-(5/`tune'^2)* /* 
			*/ (`res'/`scale')^2) if `touse'
		replace `absdev' = 0 /*
			*/ if abs(`res'/`scale')>`tune' & `touse'
		sum `absdev' if `touse', meanonly
		scalar `aa' = r(mean)
		scalar `lambda' = 1+((e(df_m)+1)/e(N))* /*
			*/ (1-`aa')/`aa'
		drop `absdev' `maxd' `oldw'
		_predict double `y' if `touse'
		replace `y'= `y' + /* 
		*/ (`lambda'*`scale'/`aa')*(`res'/`scale')*`weight' /*
		*/ if `touse'

		if "`noconstant'"!="" {
		reg `y' `rhs' if `touse', dep(`lhs') noc
		}

		else {
		reg `y' `rhs' if `touse', dep(`lhs')
		
		}

		est local ll
		est local ll_0
		est local genwt `genwt'
		est local estat_cmd ""		// reset to empty
		est local predict "rreg_p"
		est local title "Huber M-estimator"
		version 10: ereturn local cmdline `"mregress `cmdline'"'
		est local cmd "mregress"
		global S_E_cmd "`e(cmd)'"	/* double save */

	}

} \\quietly

	if "`e(prefix)'" == "" {
		#delimit ;
		di _n
			in gr "Huber M-estimator"
			in gr _col(56) "Number of obs =" in ye %8.0f e(N) _n
			in gr _col(56) "F(" %3.0f e(df_m) "," %6.0f e(df_r)    
					") =" in ye %8.2f e(F) _n
			in gr _col(56) "Prob > F      =" in ye %8.4f
					fprob(e(df_m), e(df_r), e(F)) _n ; 
		#delimit cr
		local head noheader
	}

	regress, `head' level(`level')

end


exit 


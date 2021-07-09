*! version 1.0.0 Ariel Linden 02sep2014
*! code partially based on signrank version 2.2.8  28sep2004

program define alignedpairs, rclass byable(recall)
	version 13
	syntax varname [=/exp] [if] [in] , [ Level(real 95) ] 

	preserve
	tempname tp tn v unv z adj0 effect nN Calpha lb_1 ub_1 alpha
	tempvar touse diff ranks t zavg

quietly {	
	mark `touse' `if' `in'
	keep if `touse' 	//keeping the touse data eliminates problems with the permutations

		gen double `diff' = `varlist'-(`exp') // if `touse'
		egen double `ranks' = rank(abs(`diff')) //if `touse'
		
/* We do want to OMIT the ranks corresponding to `diff'==0 in the sums.  */

		gen double `t' = sum(cond(`diff'>0,`ranks',0))
		scalar `tp' = `t'[_N]

		replace `t' = sum(cond(`diff'<0,`ranks',0))
		scalar `tn' = `t'[_N]

		replace `t' = sum(cond(`diff'~=0,`ranks'*`ranks',0))
		scalar `v' = `t'[_N]/4
		scalar `z' = (`tp'-`tn')/(2*sqrt(`v'))

		count //if `touse'
		local n = r(N)
		scalar `unv' = `n'*(`n'+1)*(2*`n'+1)/24

		count if `diff' == 0 //& `touse'
		local n0 = r(N)
		scalar `adj0' = -`n0'*(`n0'+1)*(2*`n0'+1)/24

		count if `diff' > 0 //& `touse'
		local np = r(N)
		local nn = `n' - `np' - `n0'
	
		* HL permutations of x = y
		local N = `n' * (`n' + 1) / 2
		set obs `N'
		gen `zavg' = .
		local k = 1 
		local J = 1 
		forval i = 1/`n' {
		forval j = `J'/`n' {
		replace `zavg' = (`diff'[`i'] + `diff'[`j'])/2 in `k++'
		}
		local ++J 
		} 
	
		sort `zavg'
		centile `zavg'
		scalar `effect' = r(c_1)
		scalar `nN' = r(N)	//get n(n+1)/2 for ub_1

		scalar `alpha'=(100-`level')/100
		scalar `Calpha' = round(`n'*(`n'+1)/4 - invnorm(1-`alpha'/2)*(`n'*(`n'+1)*(2*`n'+1)/24)^.5,1)
	
	* set Calfa to 1 for cases when it is 0 (small samples) 
		if `Calpha' <1 {
		scalar `Calpha' = 1
		}
		else {
		scalar `Calpha' = `Calpha'
		}
	
		scalar `lb_1' = round(`zavg'[`Calpha'],.001)
		scalar `ub_1' = round(`zavg'[`nN'-`Calpha'+1],.001)
}
	
	di _n in gr `"Wilcoxon signed-rank test"' _n
	di in smcl in gr `"        sign {c |}      obs   sum ranks    expected"'
	di in smcl in gr "{hline 13}{c +}{hline 33}"
	ditablin positive `np' `tp' (`tp'+`tn')/2
	ditablin negative `nn' `tn' (`tp'+`tn')/2
	ditablin zero     `n0' `n0'*(`n0'+1)/2 `n0'*(`n0'+1)/2 
	di in smcl in gr "{hline 13}{c +}{hline 33}"
	ditablin all `n' `n'*(`n'+1)/2 `n'*(`n'+1)/2 

	if `unv' < 1e7  local vfmt `"%10.2f"' 
	else            local vfmt `"%10.0g"'

	di in smcl in gr _n `"unadjusted variance"' _col(22) ///
	   in ye `vfmt' `unv' _n							///	
	   in gr `"adjustment for ties"' _col(22)			///	
	   in ye `vfmt' `v'-`unv'-`adj0' _n					///
	   in gr `"adjustment for zeros"' _col(22)			///
	   in ye `vfmt' `adj0' _n							///
	   in gr _col(22) "{hline 10}" _n					///
	   in gr `"adjusted variance"' _col(22)				///
	   in ye `vfmt' `v' _n(2)							///
	   in gr `"Ho: `varlist' = `exp'"' _n				///
	   in gr _col(14) `"z = "'							///
	   in ye %7.3f `z' _n								///
	   in gr _col(5) `"Prob > |z| = "'					///
	   in ye %8.4f 2*normprob(-abs(`z')) 

	di _n in gr `"Aligned signed-rank (Hodges-Lehmann) estimate"' _n
	di in smcl in gr `"             {c |}  Estimate   [`level'% Conf. Interval]"'
	di in smcl in gr "{hline 13}{c +}{hline 33}"
	ditablin1 effect `effect' `lb_1' `ub_1'
	di in smcl in gr "{hline 13}{c BT}{hline 33}"
  
	/* return scalars for signrank */
	ret scalar sum_pos = `tp'
	ret scalar sum_neg = `tn'
	ret scalar z = `z'
	ret scalar Var_a = `v'
	ret scalar N_pos = `np'
	ret scalar N_neg = `nn'
	ret scalar N_tie = `n0'
	
	/* return scalars for H-L estimates */
	ret scalar estimate = `effect'
	ret scalar lb_1 = `lb_1'
	ret scalar ub_1 = `ub_1'
	ret scalar hl_obs = `nN'
	restore

end

program define ditablin
        di in smcl in gr %12s `"`1'"' `" {c |}"' in ye	///
                _col(17) %7.0g `2'						///
                _col(26) %10.0g `3'						///
                _col(38) %10.0g `4' 
end

program define ditablin1
        di in smcl in gr %12s `"`1'"' `" {c |}"' in ye	///
                _col(17) %7.3g `2'						///
                _col(26) %10.3g `3'						///
                _col(38) %10.3g `4' 
end

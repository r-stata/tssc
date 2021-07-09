*! mygmm2s 1.0.2 MES/CFB 11aug2008
program mygmm2s, eclass
	version 10.1
/*
  Our standard syntax:
  mygmm2s y, endog(varlist1) inexog(varlist2) exexog(varlist3)  [robust]
  where varlist1 contains endogenous regressors
        varlist2 contains exogenous regressors (included instruments)
        varlist3 contains excluded instruments
  Without robust, efficient GMM is IV. With robust, efficient GMM is 2-step
  efficient GMM, robust to arbitrary heteroskedasticity.
  To accommodate time-series operators in the options, add the "ts"
*/	
	syntax varname(ts) [if] [in] [, endog(varlist ts) inexog(varlist ts) ///
		 exexog(varlist ts) robust ]

	local depvar `varlist'

/*
   marksample handles the variables in `varlist' automatically, but not the
   variables listed in the options `endog', `inexog' and so on. -markout- sets
   `touse' to 0 for any observations where the variables listed are missing.
*/
	marksample touse
	markout `touse' `endog' `inexog' `exexog'

// These are the local macros that our Stata program will use
	tempname b V omega

// Call the Mata routine. All results will be waiting for us in "r()" macros afterwards.

	mata: m_mygmm2s("`depvar'", "`endog'", "`inexog'", /// 
	                "`exexog'", "`touse'", "`robust'")

// Move the basic results from r() macros into Stata matrices.
	mat `b' = r(beta)
	mat `V' = r(V)
	mat `omega' = r(omega)
// Prepare row/col names.
// Our convention is that regressors are [endog   included exog]
// and instruments are                   [excluded exog  included exog]
// Constant is added by default and is the last column.
	local vnames `endog' `inexog' _cons
	matrix rownames `V' = `vnames'
	matrix colnames `V' = `vnames'
	matrix colnames `b' = `vnames'
	local vnames2 `exexog' `inexog' _cons
	matrix rownames `omega' = `vnames2'
	matrix colnames `omega' = `vnames2'

// We need the number of observations before we post our results.
	local N = r(N)
	ereturn post `b' `V', depname(`depvar') obs(`N') esample(`touse')

// Store remaining estimation results as e() macros accessible to the user.
	ereturn matrix omega `omega'
	ereturn local depvar = "`depvar'"
	ereturn scalar N = r(N)
	ereturn scalar j = r(j)
	ereturn scalar L = r(L)
	ereturn scalar K = r(K)
	if "`robust'" != "" {
	    ereturn local vcetype "Robust"
	}

	display _newline "Two-step GMM results" _col(60) "Number of obs = " e(N)
	ereturn display
	display "Sargan-Hansen J statistic: " %7.3f e(j)
	display "Chi-sq(" %3.0f e(L)-e(K) "  )       P-val = " ///  
	        %5.4f chiprob(e(L)-e(K), e(j)) _newline

end

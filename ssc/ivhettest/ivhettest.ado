*! ivhettest 1.1.9  15Aug2013
*! author mes
* Implements Pagan-Hall (1983) heteroskedasticity tests for IV plus related statistics.
* Notation largely follows White (1982).
* psi are indicators hypothesized to be related to heteroskedasticity
* Z are instruments (L of them) and X are regressors (K of them)
* 1.1.1   Added trap to catch IV estimated using old-style regress syntax
* 1.1.2   Partially removed phsym option
* 1.1.3   Added statement of Ho in output
* 1.1.4   Added iv cross-products as explicit option and changed default behaviour to ivlev
* 1.1.5   Added trap to catch usage after ivreg2 with fwl
* 1.1.6   Refined trap to catch usage of fwl with just _cons
* 1.1.7   Re-refined trap to catch usage of partial as well as fwl
* 1.1.8   Fixed bug in re-refined [sic] trap
* 1.1.9   Fixed bug in handling varnames that had "_cons" in them

program define ivhettest, rclass
	version 7.0
	local version 1.1.9

	syntax [varlist(default=none)] [if] [in] [, ivlev ivsq ivcp fitlev fitsq /*
		*/ ph phnorm phsym nr2 bpg all ] 

	if "`e(cmd)'" != "ivreg" & "`e(cmd)'" != "ivreg2" & "`e(cmd)'" != "ivreg28" /*
		*/ & "`e(cmd)'" != "ivreg29" & "`e(cmd)'" != "ivgmm0" & "`e(cmd)'" != "regress" {
		error 301
	}
	if "`e(fwl1)'`e(partial)'" != "" | "`e(fwlcons)'`e(partialcons)'"=="1" {
di in r "ivhettest not allowed after ivreg2 with partial (previously fwl) option"
		error 499
	}

	tempvar  touse N e e2 e3 e4 e2md sigma sigma2 sigma4 mu3 mu4 one
	tempname G D B1 B2 B3 B4 B Binv H regest
	tempname psipsi XhXh XhXhinv

	if "`e(cmd)'" == "regress" | "`e(instd)'" =="" {
		if "`e(cmd)'" =="regress" & "`e(model)'"=="iv" {
di in r "ivhettest not applicable after IV estimated using regress"
di in r "Use ivreg or ivreg2 instead"
			error 197
		}
		if "`ph'`phnorm'`phsym'" != "" {
			di in r "Pagan-Hall test not applicable to OLS"
			error 197
		}
		if "`all'" != "" {
			local nr2 "nr2"
			local bpg "bpg"
		}
		if "`nr2'`bpg'" == "" {
			local nr2 "nr2"
		}
	}
	else {
		if "`all'" != "" {
			local ph "ph"
			local phnorm "phnorm"
			local nr2 "nr2"
			local bpg "bpg"
		}
		if "`ph'`phnorm'`phsym'`nr2'`bpg'" == "" {
			local ph "ph"
		}
	}

	local oneopt "`ivlev'`ivsq'`ivcp'`fitlev'`fitsq'"
	if length("`oneopt'") > 6 | /*
		*/ ( "`oneopt'" != "" & "`varlist'" != "") {
di in r "Incompatible choice of options; may specify one set of indicators only"
		error 197
	}

* Default is ivlev (Breusch-Pagan-Godfrey formulation)
	if "`ivlev'`ivsq'`ivcp'`fitlev'`fitsq'`varlist'" == "" {
		local ivlev "ivlev"
	}

	if "`e(wtype)'" != "" {
di in r "Weights not allowed in current implementation"
		error 197
	}


	tempname b
	mat `b' = e(b)
	local cn : colnames `b'
	local cn_ct = colsof(`b')
	tokenize `cn'
* `hc' is hascons flag, =1 if regressors include constant
	local hc = ("``cn_ct''"=="_cons")
	if `hc' {
		local xvars_ct = `cn_ct'-1
		forvalues i=1/`xvars_ct' {
			local xvars "`xvars' ``i''"
		}
	}
	else {
		local xvars_ct = `cn_ct'
		local xvars "`cn'"
	}

	if "`e(cmd)'" != "regress" {
		local insts "`e(insts)'"
	}
	else {
		local insts "`xvars'"
		local ph
		local phnorm
		local phsym
	}
	gen byte `touse' = e(sample)
	scalar `N' = e(N)
	gen byte `one' = 1

* Fetch residuals and generate squares, sigma2, 3rd & 4th moments, etc.
	qui predict double `e' if `touse', res
	qui gen double `e2' = `e' * `e'
	qui sum `e2' if `touse', meanonly
	scalar `sigma2'=r(mean)
	qui gen double `e2md' = `e2'-`sigma2'
	scalar `sigma'=sqrt(`sigma2')
	qui gen double `e3'=`e'^3
	qui sum `e3' if `touse', meanonly
	scalar `mu3'=r(mean)
	scalar `sigma4'=`sigma2'^2
	qui gen double `e4'=`e'^4
	qui sum `e4' if `touse', meanonly
	scalar `mu4'=r(mean)

* User-supplied varlist
	if "`varlist'" != "" {
		tokenize `varlist'
		local i = 1
		local nrvars : word count `varlist' 
		while `i' <= `nrvars' {
			tempvar vn
			qui gen double `vn' = ``i''
			local psi "`psi' `vn'" 
			local i = `i' + 1
			}
		qui _rmcoll `psi'
		local psi `r(varlist)'
	}

* ivlev - psi is all instruments in levels, a la Breusch-Pagan/Godfrey/Cook-Weisberg
* ivsq -  psi is all instruments in levels and squares
* ivcp -  psi is all instruments in levels, squares and cross-products
	if "`ivlev'`ivsq'" != "" {
		tokenize `insts'
		local i = 1
		local nrvars : word count `insts' 
		while `i' <= `nrvars' {
			tempvar vn
			qui gen double `vn' = ``i''
			local psi "`psi' `vn'" 
			if "`ivsq'" != "" {
				tempvar vnsq
				qui gen double `vnsq' = `vn'^2
				local psi "`psi' `vnsq'" 
			}
			local i = `i' + 1
		}
		qui _rmcoll `psi'
		local psi `r(varlist)'
	}

	if "`ivcp'" != "" {
		local insts1 "`one' `insts'" 
		tokenize `insts1'
		local i = 1
		local nrvars : word count `insts1' 
		while `i' <= `nrvars' {
			local j = `i' 
			while `j' <= `nrvars' {
				tempvar prod 
				qui gen double `prod' = ``i'' * ``j''
				local psi "`psi' `prod'" 
				local j = `j' + 1
			}
			local i = `i' + 1
        	}
* Now get rid of the `one' column from psi
		tokenize `psi'
		mac shift
		local psi `*'
		qui _rmcoll `psi'
		local psi `r(varlist)'
	}

* Generate Xu, regressors * error.
* Constant included if present.
	tokenize `xvars'
	local i = 1
	while `i' <= `xvars_ct' {
		tempvar y
		qui gen double `y' = ``i'' * `e'
		local Xu "`Xu' `y'"
		local i = `i' + 1
	}
	if `hc' {
		local Xu "`Xu' `e'"
	}

* Generate Xhats = predicted values of regressors (=actual if exogenous)
* Don't include constant (yet)
	tokenize `xvars'
	local i = 1
	while `i' <= `xvars_ct' {
		local insts : subinstr local insts "``i''" "``i''" , /*
			*/ word count(local isiv)
		if `isiv'==1 {
			local Xhat "`Xhat' ``i''"
		}
		else {
			estimates hold `regest'
			qui regress ``i'' `insts' if `touse'
			tempvar xh
			qui predict double `xh' if `touse', xb
			estimates unhold `regest'
			local Xhat "`Xhat' `xh'"
		}
		local i = `i' + 1
	}

* Code for "predicted" values "yhat"=xhat*Bhat (NOT x*Bhat)
* fitlev is "yhat", fitsq is ["yhat" "yhat"^2]
	if "`fitlev'`fitsq'" != "" {
		local cn "`Xhat'"
		mat `b' = e(b)
		if `hc' {
			local cn "`cn' _cons"
		}
		matrix colnames `b' = `cn'
		tempvar yhat yhat2
		matrix score double `yhat' = `b' if `touse'
		if "`fitlev'" != "" {
			local psi "`yhat'"
		}
		else {
			qui gen double `yhat2'=`yhat'^2
			local psi "`yhat' `yhat2'"
		}
	}

* NOW add the one column to Xhat if it belongs there, and then inverse of cross-product matrix
* NB: sigma^2 * this matrix = standard (non-robust) IV covariance matrix.
	if `hc' {
		local Xhat "`Xhat' `one'"
	}
	qui mat accum `XhXh' = `Xhat', nocons
	mat `XhXhinv' = syminv(`XhXh')

* Put psi in mean-deviation form
	tokenize `psi'
	local i = 1
	local nrvars : word count `psi' 
	while `i' <= `nrvars' {
		qui sum ``i'' if `touse', meanonly
		qui replace ``i'' = ``i'' - r(mean)
		local i = `i' + 1
       	}

* Count psi for degrees of freedom of test
	local p : word count `psi'
	return scalar df = `p'

* White formulation for Pagan-Hall, kurtosis-robust and White's general IV test
* White's formula is in terms of ASYMPTOTIC covariances etc., so formulation is
*   in terms of sample means, i.e., divide through by 1/N.
*   In particular, rather than X'X we have X'X/N and 
*   rather than inv(X'X) we have N*inv(X'X)

* D is White's D-hat_n.
* NB: In expression for D, psi need not be in mean-deviation form; see White (1980), p. 823.
	qui mat accum `D' = `e2md' `psi' if `touse', nocons
	mat `D' = `D'[2...,1] * 1/`N'

* psipsi is cross-product psi'psi
	qui mat accum `psipsi' = `psi' if `touse', nocons

	if "`ph'`phnorm'`phsym'" != "" {
* G needed only for Pagan-Hall tests
		qui mat accum `G' = `psi' `Xu' if `touse', nocons
		mat `G' = `G'[1..`p', `p'+1...] * 1/`N'
* B4 covariance matrix needed only for Pagan-Hall tests
		mat `B4' = 4*`sigma2'*`G'*(`N'*`XhXhinv')*`G''
	}

* Pagan-Hall Theorem 8.ii - assumed normality
* Breusch-Pagan/Godfrey/Cook-Weisberg - normality and system cov is homoskedastic
	if "`phnorm'`bpg'" != "" {
		mat `B1' = 1/`N'*2*`sigma4'*`psipsi'
		if "`phnorm'" != "" {
			mat `B' = `B1' + `B4'
			mat `Binv' = syminv(`B')
			mat `H' = `N' * `D'' * `Binv' * `D'
			return scalar phnorm = `H'[1,1]
			return scalar phnormp = chiprob(return(df),return(phnorm))
		}
		if "`bpg'" != "" {
			mat `B' = `B1'
			mat `Binv' = syminv(`B')
			mat `H' = `N' * `D'' * `Binv' * `D'
			return scalar bpg = `H'[1,1]
			return scalar bpgp = chiprob(return(df),return(bpg))
		}
	}

* Pagan-Hall full test, Pagan-Hall with symmetric errors, and White/Koenker nR2 test
	if "`ph'`phsym'`nr2'" != "" {
		mat `B1' = 1/`N'*(`mu4'-`sigma4')*`psipsi'
		if "`ph'" != "" {
			qui mat accum `B2' = `psi' `Xhat' if `touse', nocons
			mat `B2' = `B2'[1..`p',`p'+1...] * 1/`N'
			mat `B2' = -2 * `mu3' * `B2' * (`N'*`XhXhinv') * `G''
			mat `B3' = `B2''
			mat `B' = `B1' + `B2' + `B3' + `B4'
			mat `Binv' = syminv(`B')
			mat `H' = `N' * `D'' * `Binv' * `D'
			return scalar ph = `H'[1,1]
			return scalar php = chiprob(return(df),return(ph))
		}
		if "`phsym'" != "" {
* Zero skewness (symmetric error), but possible non-normality
			mat `B' = `B1' + `B4'
			mat `Binv' = syminv(`B')
			mat `H' = `N' * `D'' * `Binv' * `D'
			return scalar phsym = `H'[1,1]
			return scalar phsymp = chiprob(return(df),return(phsym))
		}
		if "`nr2'" != "" {
			mat `B' = `B1'
			mat `Binv' = syminv(`B')
			mat `H' = `N' * `D'' * `Binv' * `D'
			return scalar nr2 = `H'[1,1]
			return scalar nr2p = chiprob(return(df),return(nr2))
		}
	}

* Display results
	if "`e(command)'" == "regress" {
		local cmd "OLS"
		local ivs "regressors"
		local fit "fitted value (X*beta-hat)"
	}
	else if "`e(instd)'"=="" {
		local cmd "OLS"
		local ivs "IVs"
		local fit "fitted value (X*beta-hat)"
	}
	else {
		local cmd "IV"
		local ivs "IVs"
		local fit "fitted value (X-hat*beta-hat)"
	}
	if "`varlist'" != "" {
di in g "`cmd' heteroskedasticity test(s) using user-supplied indicator variables"
	}
	if "`ivlev'" != "" {
di in g "`cmd' heteroskedasticity test(s) using levels of `ivs' only"
	}
	if "`ivsq'" != "" {
di in g "`cmd' heteroskedasticity test(s) using levels and squares of `ivs'"
	}
	if "`fitlev'" != "" {
di in g "`cmd' heteroskedasticity test(s) using `fit'"
	}
	if "`fitsq'" != "" {
di in g "`cmd' heteroskedasticity test(s) using `fit' & its square"
	}
	if "`ivcp'" != "" {
di in g "`cmd' heteroskedasticity test(s) using levels and cross products of all `ivs'"
	}
di in g "Ho: Disturbance is homoskedastic"
	if "`ph'" != "" {
		di in g "    Pagan-Hall general test statistic   : "   /*
		*/ in y %7.3f return(ph) /* 
		*/ in g "  Chi-sq(" return(df)  ") P-value = " /*
		*/ in y %5.4f return(php)
	}
	if "`phsym'" != "" {
		di in g "    Pagan-Hall test w/assumed symmetry  : "   /*
		*/ in y %7.3f return(phsym) /* 
		*/ in g "  Chi-sq(" return(df)  ") P-value = " /*
		*/ in y %5.4f return(phsymp)
	}
	if "`phnorm'" != "" {
		di in g "    Pagan-Hall test w/assumed normality : "   /*
		*/ in y %7.3f return(phnorm) /* 
		*/ in g "  Chi-sq(" return(df)  ") P-value = " /*
		*/ in y %5.4f return(phnormp)
	}
	if "`nr2'" != "" {
		di in g "    White/Koenker nR2 test statistic    : "   /*
		*/ in y %7.3f return(nr2) /* 
		*/ in g "  Chi-sq(" return(df)  ") P-value = " /*
		*/ in y %5.4f return(nr2p)
	}
	if "`bpg'" != "" {
		di in g "    Breusch-Pagan/Godfrey/Cook-Weisberg : "   /*
		*/ in y %7.3f return(bpg) /* 
		*/ in g "  Chi-sq(" return(df)  ") P-value = " /*
		*/ in y %5.4f return(bpgp)
	}

end

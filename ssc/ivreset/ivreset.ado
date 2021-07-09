*! ivreset 1.0.08  4Feb2007
*! author mes
* Z are instruments (L of them) and X are regressors (K of them)
* 1.0.04  Fixed small bug in check for xtmodel
*         Fixed dof check in xtivreg2
* 1.0.05  Changed rescaling so that squares, cubes, etc are created then rescaled
* 1.0.06  Removed rescaling, switched to -orthog-
*         Removed support for official ivreg
*         Fixed small bug in failed cstat reporting
* 1.0.07  Added trap to catch usage after ivreg2 with fwl
* 1.0.08  Refined trap

program define ivreset, rclass sortpreserve
	version 8.0
	local version 1.0.8

	syntax [, POLYnomial(integer 2) RForm cstat small] 

	if "`e(cmd)'" != "ivreg2" & "`e(cmd)'" != "regress" & /*
			*/	"`e(cmd)'" != "ivreg3" & "`e(cmd)'" != "xtivreg2" {
		error 301
	}

	if "`e(cmd)'" == "xtivreg2" & "`e(xtmodel)'" ~= "fe" {
		error 301
	}

	if "`e(fwlcons)'" != "" {
di in r "ivreset not allowed after ivreg2 with fwl option"
		error 499
	}

	if "`cstat'" != "" {
* Check that ivreg2 is installed when cstat option is requested
		capture findfile ivreg2.ado
		if _rc==601 {
di as err "Error: installed ivreg2 required for cstat option"
			error 601
		}
	}

	tempvar  touse N yhat yhat2 yhat3 yhat4
	tempname regest b

* Default is to use Pesaran-Smith optimal forecast of y
	if "`rform'" == "" {
		local msg0 "Ramsey/Pesaran-Taylor RESET test"
		local msg2 "fitted value of y (X-hat*beta-hat)"
	}
	else {
		local msg0 "Ramsey/Pagan-Hall RESET test"
		local msg2 "reduced form prediction of y"
	}

	if "`cstat'" == "" {
		local msg3 "Wald"
	}
	else {
		local msg3 "C (GMM-distance)"
	}

	if "`e(vcetype)'"=="Robust" {
		local robust "robust"
		local msg3h "heteroskedastic-"
	}	

	if "`e(clustvar)'"~="" {
		local clopt "cluster(`e(clustvar)')"
		local msg3c "cluster-"
	}

	if "`e(bw)'"~="" {
		local bwopt "bw(`e(bw)')"
		local kernopt "kernel(`e(kernel)')"
		local msg3a "autocorrelation-"
	}

	if "`e(wtype)'" != "" {
		local wtexp `"[`e(wtype)'`e(wexp)']"'
	}

	gen `touse'=e(sample)

	mat `b' = e(b)
	local rhs : colnames `b'
	local rhsct : word count `rhs'
	local depvar "`e(depvar)'"
	local df_m = e(df_m)

	if "`e(cmd)'" != "regress" {
* Block for all IV commands
		local endo "`e(instd)'"
		local insts "`e(insts)'"
		foreach vn of local rhs {
			local tempvlist : subinstr local insts "`vn'" "`vn'" , /*
				*/ word count(local isiv)
			if `isiv'==1 {
				local inexog "`inexog' `vn'"
			}
		}
		foreach vn of local insts {
			local tempvlist : subinstr local rhs "`vn'" "`vn'" , /*
				*/ word count(local isregressor)
			if `isregressor'==0 {
				local exexog "`exexog' `vn'"
			}
		}
	* If endo is empty, it's OLS or HOLS, and if so, ignore exexog as well
		if "`endo'"=="" {
			local exexog
		}
		if e(cons)~=1 {
			local consflag 0
			local consopt "nocons"
		}
		else {
			local consflag 1
		}
	}
	else {
* Block for simple regress
		local endo
		local exexog
		local inexog : subinstr local rhs "_cons" "", word count(local consflag)
		if `consflag'==0 {
			local consopt "nocons"
		}
	}

* If no endogenous regressors, it's just a simple RESET test
	if "`endo'" == "" {
		local msg0 "Ramsey RESET test"
		local msg2 "fitted value of y (X*beta-hat)"
	}

* Demeaning block for xtivreg2
	if "`e(cmd)'" == "xtivreg2" {
		preserve
		tempvar ivar T_i depvar2
		qui gen double `depvar2' = `depvar'
		qui gen `ivar' = `e(ivar)'
		sort `ivar' `touse'
		qui by `ivar' `touse': gen long `T_i' = _N if _n==_N & `touse'
		qui count if `T_i' < .
* N_g minus 1 is additional degrees of freedom absorbed by the extra dummies
		local N_g=r(N)
		local allvars "`depvar' `inexog' `endo' `exexog'"		
		qui foreach var of local allvars {
			tempname `var'_m
			by `ivar' `touse' : gen double ``var'_m'=sum(`var')/_N if `touse'
			by `ivar' `touse' : replace    ``var'_m'=``var'_m'[_N] if `touse' & _n<_N
			by `ivar' `touse' : replace `var'=`var'-``var'_m'[_N]           if `touse'
		}
* Small degrees of freedom = N minus #regressors minus #fixed effects (+constant)
* Large = N minus #fixed effects
		qui sum `depvar' if `touse'
		local N=r(N)
* Use only large dof, not small. Subtract full number of fixed effects `N_g'
		local dof = `N' - `N_g'
* nocons not part of xtopts - caught below
		local xtopts "dofminus(`N_g')"
	}
		
	if "`rform'" == "" {
* Code for Pesaran-Smith test using "predicted" values "yhat"=xhat*Bhat (NOT x*Bhat)
* Generate predicted values of endog regressors
* In special case of no endog regressors (OLS or HOLS), exexog has also been set to empty
* and yhat is just the usual OLS/HOLS yhat
		foreach vn of local endo {
			capture _estimates hold `regest', restore
			qui regress `vn' `inexog' `exexog' `wtexp' if `touse', `consopt'
			tempvar xh
			qui predict double `xh' if `touse', xb
			capture _estimates unhold `regest'
			local endohat "`endohat' `xh'"
		}
		local rhshat "`endohat' `inexog'"
		mat `b' = e(b)
		if `consflag' {
			local rhshat "`rhshat' _cons"
		}
		matrix colnames `b' = `rhshat'
		matrix score double `yhat' = `b' if `touse'
	}
	
	if "`rform'" != "" {
* Code for Pagan-Hall test using reduced form predictions
* In special case of no endog regressors (OLS or HOLS), exexog has also been set to empty
* and yhat is just the usual OLS/HOLS yhat
		capture _estimates hold `regest', restore
		qui regress `depvar' `inexog' `exexog' `wtexp', `consopt'
		qui predict double `yhat', xb
		capture _estimates unhold `regest'
	}

* Add mean back to yhat if xtivreg2
	qui if "`e(cmd)'" == "xtivreg2" {
		tempname depvar_m
		by `ivar' `touse' : gen double `depvar_m'=sum(`depvar2')/_N if `touse'
		by `ivar' `touse' : replace    `depvar_m'=`depvar_m'[_N] if `touse' & _n<_N
		by `ivar' `touse' : replace `yhat'  =`yhat'  +`depvar_m'[_N] if `touse'
	}

* Generate squares, and cube/4th powers if requested.  Always need yhat^2.
* Orthogonalize if order>3.
	qui gen double `yhat2'=`yhat'^2
	if `polynomial'==2 {
		local yhats "`yhat2'"
		local msg1 "square of "
	}
	if `polynomial'==3 {
		tempname yhat2o yhat3o
		qui gen double `yhat3'=`yhat'^3
		orthog `yhat2' `yhat3' if `touse', gen(`yhat2o' `yhat3o')
		qui replace `yhat2'=`yhat2o'
		qui replace `yhat3'=`yhat3o'
		local yhats "`yhat2' `yhat3'"
		local msg1 "square and cube of "
	}
	if `polynomial'==4 {
		tempname yhat2o yhat3o yhat4o
		qui gen double `yhat3'=`yhat'^3
		qui gen double `yhat4'=`yhat'^4
		orthog `yhat2' `yhat3' `yhat4' if `touse', gen(`yhat2o' `yhat3o' `yhat4o')
		qui replace `yhat2'=`yhat2o'
		qui replace `yhat3'=`yhat3o'
		qui replace `yhat4'=`yhat4o'
		local yhats "`yhat2' `yhat3' `yhat4'"
		local msg1 "square, cube and 4th power of "
	}

* Demean yhats
	if "`e(cmd)'" == "xtivreg2" {
		qui foreach var of local yhats {
			tempname `var'_m
			by `ivar' `touse' : gen double ``var'_m'=sum(`var')/_N if `touse'
			by `ivar' `touse' : replace ``var'_m'=``var'_m'[_N] if `touse' & _n<_N
			by `ivar' `touse' : replace `var'=`var'-``var'_m'[_N] if `touse'
		}
	}

* Artificial regression test (default)
	if "`cstat'"=="" {
		capture _estimates hold `regest', restore
		if "`endo'" != "" {
			capture ivreg2 `depvar' `inexog' `yhats' (`endo'=`exexog') `wtexp' if `touse', /*
				*/	`small' `xtopts' `robust' `clopt' `bwopt' `kernopt' `consopt'
		}
		else {
* No endogenous regressors, so ignore excluded exog (if any) as well
			capture ivreg2 `depvar' `inexog' `yhats' `wtexp' if `touse', /*
				*/	`small' `xtopts' `robust' `clopt' `bwopt' `kernopt' `consopt'
		}
		if "`e(cmd)'" == "xtivreg2" {
			local df_aug = (`N_g'+e(df_m)-(`polynomial'-1))
		}
		else {
			local df_aug = (e(df_m)-(`polynomial'-1))
		}
		if `df_aug' < `df_m' {
di as err "Error - collinearities in augmented regression equation."
di as err "If using higher order polynomials, try reducing the order."
			error 103
		}
		else {
			capture test `yhats'
			return scalar df=r(df)
			return scalar p=r(p)
			if "`small'" == "" {
				return scalar chi2=r(chi2)
			}
			else {
				return scalar F=r(F)
				return scalar df_r=r(df_r)
			}
		}
		capture _estimates unhold `regest'
	}

* Cstat test (GMM distance)
	if "`cstat'" != "" {
		capture _estimates hold `regest', restore
* If endo is empty, so is exexog and it's just an LM test
		qui ivreg2 `depvar' `inexog' (`endo'=`exexog' `yhats') `wtexp' if `touse', /*
			*/	orthog(`yhats') `small' `xtopts' `robust' `clopt' `bwopt' `kernopt' `consopt'
		if e(cstat) > 0 & e(cstat) < . {
			tempname cstat
				scalar `cstat'=e(cstat)
				return scalar df=e(cstatdf)
				return scalar p=e(cstatp)
			if "`small'" == "" {
				return scalar chi2=`cstat'
			}
			else {
				return scalar df_r=e(Fdf2)-return(df)
				return scalar F=`cstat'/return(df)*return(df_r)/e(N)
			}
		}
		capture _estimates unhold `regest'
	}

di in g "`msg0'"
di in g "Test uses `msg1'`msg2'"
di in g "Ho: E(y|X) is linear in X"

	if return(chi2)~=. | return(F)~=. {
		if "`small'"=="" {
di in g "`msg3' test statistic: "   /*
		*/ _col(35) in g "Chi-sq(" return(df)  ") = " /*
		*/ in y %5.2f return(chi2) /* 
		*/ _col(55) in g "P-value = " /*
		*/ in y %5.4f return(p)
		}
		else {
di in g "`msg3' test statistic: "   /*
		*/ _col(35) in g "F(" return(df) "," return(df_r)  ") = " /*
		*/ in y %5.2f return(F) /* 
		*/ _col(55) in g "P-value = " /*
		*/ in y %5.4f return(p)
		}
		if "`msg3h'`msg3c'`msg3a'" ~= "" {
di in g "Test is `msg3h'`msg3c'`msg3a'robust"
		}
	}
	else {
di as err "Error in estimating augmented equation - statistic not reported"
	}

end

*! ivendog V1.0.7  29may2007
*! authors C F Baum, Steve Stillman, Mark Schaffer
* Builds on dmexog V1.4.1
* 1.0.0  : changes vs. dmexog: reports D-W-H stat as well as W-H stat;
*          different algorithm (3 regressions max); fixes bug in testing subset of
*          endogenous regressors (inconsistent estimate of sigma-sq); handles weights
*          (verified by comparison with -hausman- and -ivreg2-);
*          won't accept robust/cluster.
*          TO DO - check for collinearities in original IV estimation.
* 1.0.1  : removed extraneous W-H chi-sq stat; fixed degrees of freedom;
*          added -small- option so that chi-sq stat uses finite-sample sigma-sq
* 1.0.2  : added -quietly-s to stop noisy reporting of missing values
* 1.0.3  : remove 5.00.04 check to enable use in Stata 9
* 1.0.4  : clarified error messages for ivreg2
* 1.0.5  : added fwl support
* 1.0.6  : added support for fwl of cons only
* 1.0.7  : disable use after ivreg2 with svy prefix

* dmexog notes:
* Ref: Davidson & MacKinnon, Estimation and Inference in Econometrics, p.239
* V1.2   : mod to disable robust, aweight, iweight per VLW
* V1.35  : correction for inst list handling
* V1.3.6 : adds support for xtivreg, fe 
* V1.3.7 : add generalized test for ivreg, per D-M p 241-242
* V1.3.9 : subinstr needs word option to prevent mangling vnames
* V1.3.10: parallel generalized test for xtivreg, allow ts ops in 
*          ivreg endog list; xtreg can't cope with that
* V1.4.0 : remove xtivreg code, enable use after ivreg2,
*		   propagate robust, cluster options from ivreg/ivreg2
* V1.4.1 : fix predict with pweights, disable after ivreg2,gmm, revise output

program define ivendog, rclass
	version 7.0
	local version 1.0.6
	syntax [anything] [, SMall ]
	local xrhsvars `anything'

	if "`e(cmd)'" ~= "ivreg" & "`e(cmd)'" ~= "ivreg2" & "`e(cmd)'" ~= "ivreg3" {
		di in r "ivendog works only after ivreg, ivreg2; use dmexogxt after xtivreg"
		error 301
	}
	if "`e(model)'" != "iv"	{
		di in red "tests not valid in OLS or GMM context: use ivreg2 orthog() or hausman"
		exit 198
	}
	if "`e(vcetype)'" == "Robust" {	
		di in red "test not valid with robust covariance estimators: use ivreg2 orthog() or hausman"	
		exit 198	
	}
	if "`e(wtype)'" == "pweight" {	
		di in red "test not valid with pweights"	
		exit 198	
	}
	if "`e(prefix)'" == "svy" {	
		di in red "test not valid with svy"	
		exit 198	
	}

	tempname touse depvar inst incrhs nin b bdiag rhsvars i regest weight
	tempname ivrss rivrss rssu rssr Qstar
	tempvar ivres ivres2 rivres rivres2

			/* mark sample */
	gen byte `touse' = e(sample)
			/* dependent variable */
	local depvar `e(depvar)'
   			/* instrument list */
	local inst `e(insts)'
			/* included RHS endog list */
	local incrhs `e(instd)'
	local nendog : word count `e(instd)'
			/* get regressorlist of original model; should check for
			collinearity between included/excluded exog */

    	mat `b' = e(b)
	mat `bdiag' = diag(`b')
* Number of regressors in original model
	local L = rowsof(`bdiag') - diag0cnt(`bdiag')
	local N = e(N)
    	local rhsvars : colnames `b'
    	local rhsvars : subinstr local rhsvars "_cons" "", word count(local hascons)
* for ivreg, if no constant in original model, exclude from aux regr
        if `hascons' == 0 {local noc = "noc"}
			/* get weights setting of original model */
	local weight ""
	if "`e(wexp)'" != "" {
                local weight "[`e(wtype)'`e(wexp)']"
        }
* 1.3.7: check if xrhsvars is populated, if so validate entries
	local ninc 0
	local rem 0
	if "`xrhsvars'" ~= "" {
		local nexog : word count `xrhsvars'
		local rem = `nendog' - `nexog'
		local nincrhs `incrhs'
			foreach v of local xrhsvars {
* should make ts operators case-insensitive (per VLW)
				local nincrhs: subinstr local nincrhs "`v'" "", word count(local zap)
				if `zap' ~= 1 {
					di in r _n "Error: `v' is not an endogenous variable"
					exit 198
				}
			}
* remove nincrhs from rhsvars if rem>0 and load xrhsvars in incrhs
			if `rem' > 0 {
				foreach v of local nincrhs {
					local rhsvars: subinstr local rhsvars "`v'" "", word
				}
			local incrhs `xrhsvars'
			}
* incrhs now contains the pruned list of vars assumed exogenous
* nincrhs contains the remaining included endogenous
* rhsvars contains all regressors
			local ninc : word count `incrhs'
		}

	if "`e(fwlcons)'"~= "" {
* Partial-out fwl block
		preserve
		tempname fwl_resid
		if e(fwlcons)==0 {
			local fwlnocons "nocons"
		}
* Alway nocons after partialling-out
		local noc "noc"
		if "`e(fwl1)'" ~= "" {
			local fwl1 `e(fwl1)'
		}
		else {
			local fwl1 `e(fwl)'
		}
		estimates hold `regest'

		foreach var of varlist `depvar' `incrhs' `nincrhs' `inst' {
			qui regress `var' `fwl1' if `touse', `fwlnocons'
			qui predict double `fwl_resid' if `touse', resid
			qui replace `var' = `fwl_resid'
			drop `fwl_resid'
		}
		mat `b'=diag(e(b))
		local fwl_ct = colsof(`b')-diag0cnt(`b')
		local L = `L' + `fwl_ct'
		estimates unhold `regest'
	}
	else {
		local fwl_ct = 0
	}

* Degrees of freedom of test = number of tested variables
	local df : word count `incrhs'
	local df_r = `N'-`L'-`df'

* RSS and residuals of unrestricted IV regression
	scalar `ivrss' = e(rss)
	qui predict double `ivres' if `touse', res

	estimates hold `regest'

* Sargan regression for unrestricted IV regression, to obtain RSSU*
	qui regress `ivres' `inst' `weight' if `touse', `noc'
	scalar `rssu'=e(rss)

* Do restricted IV regression (=OLS if `nincrhs' is empty)
	qui reg `depvar' `rhsvars' `nincrhs' (`rhsvars' `inst') `weight' if `touse', `noc'
* RSS and residuals of restricted IV/OLS regression
	scalar `rivrss' = e(rss)
	qui predict double `rivres' if `touse', res

* Sargan regression for restricted IV/OLS, to obtain RSSR*
	qui regress `rivres' `incrhs' `inst' `weight'  if `touse', `noc'
	scalar `rssr'=e(rss)

	estimates unhold `regest'

* Numerator of statistic
	scalar `Qstar' = (`rivrss' - `rssr') - (`ivrss' - `rssu')

	if "`small'" == "" {
		return scalar DWH  =`Qstar' / (`rivrss'/`N')
		}
	else {
		return scalar DWH  =`Qstar' / (`rivrss'/(`N'-`L'))
		}
	return scalar DWHp = chiprob(`df',return(DWH))
	return scalar WHF  = (`Qstar'/`df')/((`rivrss' - `Qstar')/`df_r')
	return scalar WHFp = Ftail(`df',`df_r',return(WHF))

	return scalar df=`df'
	return scalar df_r=`df_r'

	di
	di in gr "Tests of endogeneity of: " in ye "`incrhs'"
	if return(df)==1 {
		di in gr "H0: Regressor is exogenous"
		}
	else {
		di in gr "H0: Regressors are exogenous"
	}
	di in gr "    Wu-Hausman F test: "   /*
		*/ 	_col(39) in ye %9.5f return(WHF) in gr            /* 
		*/ 	in gr "  F(" in ye return(df) in gr "," in ye return(df_r) /*
		*/ 	in gr ")" _col(62) "P-value = " in ye %6.5f return(WHFp)
	di in gr "    Durbin-Wu-Hausman chi-sq test: "   /*
		*/ 	_col(39) in ye %9.5f return(DWH) in gr            /* 
		*/ 	in gr "  Chi-sq(" in ye return(df) /*
		*/ 	in gr ")" _col(62) "P-value = " in ye %6.5f return(DWHp)

end
exit

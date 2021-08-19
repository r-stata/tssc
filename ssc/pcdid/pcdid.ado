//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// Code version (v1.01): Feb 15, 2021 (v1.0: Feb 09,2021)												   ///
/// list of ado files: pcdid.ado, grtestsub.ado, pdd.ado												   ///
/// This code implements the PCDID estimator by Marc K. Chan and Simon Kwok,                               ///
/// "The PCDID Approach: Difference-in-Differences when Trends are Potentially Unparallel and Stochastic", ///
/// also previously circulated as "Policy Evaluation with Interactive Fixed Effects"                       ///
/// For more details, visit https://sites.google.com/site/marcchanecon/									   ///
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
program define pcdid, eclass
	version 14
	syntax varlist(numeric ts fv) [if] [, Alpha Fproxy(integer 0) Stationary Kmax(integer 10) NWlag(integer -1) PDall TReatlist(string)]
	marksample touse
	gettoken depvar rhsvars: varlist
	gettoken treated indeps: rhsvars
	gettoken indep1: indeps
	_fv_check_depvar `depvar'
	
	if `fproxy' > 0 {
		scalar factnum = `fproxy'
		scalar factnum0 = -1
		scalar factnum1 = -1
	}
	
	if "`Alpha'" == "" {
		scalar alphastat = 0
		scalar alphastatse = 0
		scalar alphastatz = 0
		scalar alphastatp = 0
	}
	
	scalar kmax = `kmax' + 1			/* set maximum possible factors */
	scalar kmaxall = `kmax'
	
	if "`stationary'" != "" {
		scalar jmax = 0
	}
	else {
		scalar jmax = 1			/* set maximum possible integration order */	
	}
	
// 	if "`treat'" != "" {
// 		local alpha = ""
// 	}

	cap drop checkvar
	gen checkvar = inlist(`treated',0,1)
	quietly summarize checkvar
	if (r(mean)!=1) {
		disp "Fatal error: " "`treated'" " is not a binary variable"
		exit
	}
	cap drop checkvar

	cap drop fproxy*			/* drop factor proxy variables in advance */
	quietly xtset
	local id = r(panelvar)
	local time = r(timevar)
	
	/****************************************************************/
	/****************************************************************/
	/* Start of pcdidmg procedure below */
	/* variable, scalar and matrix names are all global: may store them as locals instead */

	preserve
	quietly keep if `touse'
	
	quietly xtsum `id'
	scalar T = r(Tbar)		/* store sample length as T */	
	quietly keep if `id'==r(min)
	quietly keep `time'
	quietly save tindex_pcdid,replace		/* save time index from the selected sample */
	restore
	
	preserve
	quietly keep if `treated'==1 & `touse' 
	if "`treatlist'" != "" {				/* additional treated unit restriction by option */
		quietly keep if `treatlist'
	}
	quietly xtsum `id'	
	
	if r(n) == 1 {
		local treatid = r(min)			/* if only one treated unit, use pcdid-basic */
		local alpha = ""
	}
	else {
		local treatid = -99999
	}
	restore
	

	preserve
	
	quietly keep if `treated'==0 & `touse'			/* select control panel */
	quietly xtreg `depvar' `indeps', fe		
	quietly predict ycresid, e				/* obtains control residual (including FE) */

	/* process the residuals from control units and perform pca */
	keep `id' `time' ycresid
	egen idnew = group(`id')
	quietly xtset idnew `time'
	quietly xtsum idnew
	scalar Nc = r(n)
	quietly save ycresid_pcdid, replace			/* save control residuals for gr test */

	if "`alpha'" != "" {
		/* compute simple average of control unit residuals (for alpha test only) */
		collapse (mean) ycresid,by(`time')
		rename ycresid ycresidmean
		quietly save ycresidmean_pcdid,replace
		quietly use ycresid_pcdid,clear
	}

	/* construct the uhatc matrix by looping */
	forval i= 1/`=scalar(Nc)' {
		if(`i'==1){
		mkmat ycresid if idnew==`i', matrix(uhatc)
		mat colnames uhatc=r`i'
		}
		else{
			mkmat ycresid if idnew==`i', matrix(uhatctmp)
			mat colnames uhatctmp=r`i'
			mat uhatc = uhatc , uhatctmp
		}
	}
	mat uhatc = uhatc'
	
	*reshape wide ycresid, i(id) j(time)		/* reshape command is slower: not use for compute uhatc */
	*drop id
	*scalar Nc = _N
	*mkmat *, matrix(uhatc)
	mat mattmp = uhatc/sqrt(T)
	matrix S = mattmp * mattmp'
	quietly pcamat S, n(1) covariance components(`=scalar(min(`=scalar(T)',`=scalar(Nc)',30))')		/* option n(1) does not matter */
	
	mat W = e(L)
	mat Fhat = uhatc' * W / Nc
	clear
	quietly svmat Fhat, names(fproxy)			/* store factor proxy as variables */
	quietly merge 1:1 _n using tindex_pcdid
	quietly drop _merge
	quietly save fproxy,replace

	if `fproxy' == 0 {
		/* run grtestsub for integration order 1, and then run grtestsub for integration order 0 */
		grtestsub
		if (jmax==1){
			scalar factnum1 = factnum			/* save number of factors (integration order=1) */
			scalar kmax = kmax - factnum
			use ycresid_pcdid,clear
			quietly merge n:1 `time' using fproxy
			quietly drop _merge
			rename ycresid ycresid1
			quietly xtreg ycresid1 fproxy1-fproxy`=scalar(factnum1)', fe					/* use FE estimator on control panel */
			quietly predict ycresid, e							/* obtains control residual (including FE) */
			/* construct the uhatc matrix by looping (copy the code above) */
			forval i= 1/`=scalar(Nc)' {
				if(`i'==1){
				mkmat ycresid if idnew==`i', matrix(uhatc)
				mat colnames uhatc=r`i'
				}
				else{
					mkmat ycresid if idnew==`i', matrix(uhatctmp)
					mat colnames uhatctmp=r`i'
					mat uhatc = uhatc , uhatctmp
				}
			}
			mat uhatc = uhatc'
			mat mattmp = uhatc/sqrt(T)
			matrix S = mattmp * mattmp'
			quietly pcamat S, n(1) covariance components(`=scalar(min(`=scalar(T)',`=scalar(Nc)',30))')		/* option n(1) does not matter */
			grtestsub
			scalar factnum0 = factnum			/* save number of factors (integration order=0) */
			scalar factnum = factnum0 + factnum1	
		}
		else{
			scalar factnum0 = factnum
			scalar factnum1 = 0
		}
	}

	restore
	
	/* perform pcdid regression on control units (for prediction in postestimation only) */
	if ("`pdall'" != "") {
		preserve
		quietly keep if `treated'==0 & `touse'
		quietly merge n:1 `time' using fproxy
		quietly drop _merge
		sort `id' `time'	
		egen idnew = group(`id')
		
		forval i= 1/`=scalar(Nc)' {
			quietly reg `depvar' `indeps' fproxy1-fproxy`=scalar(factnum)' if idnew==`i'
				if(`i'==1){
					mat matc = e(b)
					mat rownames matc=r`i'
				}
				else{
					mat matctmp = e(b)
					mat rownames matctmp=r`i'
					mat matc = matc \ matctmp
				}
		}
		restore
	}
	else{				/* v1.01: void v1.0, see below for initialization of matc */
	}	

	
	preserve

	/* merge data of treated units with factor proxies and simple mean of control residuals */
	quietly keep if `treated'==1 & `touse'
	if "`treatlist'" != "" {				/* additional treated unit restriction by option */
		quietly keep if `treatlist'
	}	
	quietly merge n:1 `time' using fproxy
	quietly drop _merge
	sort `id' `time'	
	
	if "`alpha'" != "" {
		quietly merge n:1 `time' using ycresidmean_pcdid
		quietly drop _merge
		sort `id' `time'
	}

	/* store number of treated units as N, and then generate a sequential id variable for looping */
	quietly xtsum `id'
	scalar N = r(n)
	egen idnew = group(`id')

	if "`alpha'" != "" {
		/* compute pcdidmg for alpha statistic only */
		forval i= 1/`=N' {
			quietly reg `depvar' `indeps' ycresidmean if idnew==`i'
				if(`i'==1){
					mat mata = _b[ycresidmean]
					mat rownames mata = r`i'
				}
				else{
					mat matatmp = _b[ycresidmean]
					mat rownames matatmp = r`i'
					mat mata = mata \ matatmp
				}
		}
		/* compute alpha statistic and its standard error */
		scalar alphastat = 0
		forval i= 1/`=scalar(N)' {
				scalar alphastat = alphastat + mata[`i',1]
		}
		scalar alphastat = alphastat / `=N'
		scalar alphastatse = 0
		forval i= 1/`=scalar(N)' {
				scalar alphastatse = alphastatse + (mata[`i',1] - alphastat)^2
		}
		scalar alphastatse = ( alphastatse / ( `=N' * (`=N'-1) ) )^0.5
		scalar alphastatz = (`=scalar(alphastat)'-1)/`=scalar(alphastatse)'
		scalar alphastatp = 2*(1- normal(abs(`=scalar(alphastatz)')))
	}
	else{
		mat mata = J(`=scalar(N)',1,0)
	}
	
	/* Compute PCDID-MG estimator */
	if `treatid' == -99999 {
	
		/* compute pcdid estimate for each treated unit, and store the estimates into a vector (N_E by number of regressors (including constant)) */
		forval i= 1/`=N' {
			quietly reg `depvar' `indeps' fproxy1-fproxy`=scalar(factnum)' if idnew==`i'
				if(`i'==1){
					mat matb = e(b)
					mat rownames matb = r`i'
				}
				else{
					mat matbtmp = e(b)
					mat rownames matbtmp = r`i'
					mat matb = matb \ matbtmp
				}
		}

		/* store number of regressors (including constant) as scalar K */
		scalar K = colsof(matb)

		/* compute pcdidmg estimate and also compute the effective number of treated units (may be smaller than N_E if some regressors are dropped in some treated units due to lack of variation */
		/* matc v1.01: fix v1.0 bug about initialization */
		if ("`pdall'" == "") {
			mat matc = J(`=scalar(Nc)',`=scalar(K)',0)
		}
		mat bmgc= J(1,`=K',0)
		mat bmg = J(1,`=K',0)
		forval j = 1/`=scalar(K)' {
			scalar count = 0
			forval i= 1/`=scalar(N)' {
				if(matb[`i',`j'] != 0){
					mat bmg[1,`j'] = bmg[1,`j'] + matb[`i',`j']
					scalar count = count + 1
				}
			}
			if (count > 0){
				mat bmg[1,`j'] = bmg[1,`j'] / count
			}
			else{
				mat bmg[1,`j'] = 0
			}
			mat bmgc[1,`j'] = count
		}

		/* compute pcdidmg variance estimate */
		mat bmgse = J(1,`=K',0)		
		forval j = 1/`=scalar(K)' {
			forval i= 1/`=scalar(N)' {
				if(matb[`i',`j'] != 0){
					mat bmgse[1,`j'] = bmgse[1,`j'] + ( matb[`i',`j'] - bmg[1,`j'] )^2
				}
			}
			if (bmgc[1,`j'] > 1){
				mat bmgse[1,`j'] = ( bmgse[1,`j'] / ( bmgc[1,`j'] * (bmgc[1,`j']-1) ) )
			}
			else{
				mat bmgse[1,`j'] = 99980001
			}
		}		
		/* store the variances as a diagonal matrix: this is required for "ereturn display" */
		mat bmgv = diag(bmgse)

		/* transfer variable names to new matrices */
		local names : colnames matb
		matrix colnames bmg = `names'
		matrix colnames bmgc = `names'
		matrix colnames bmgv = `names'
		matrix rownames bmgv = `names'
		*mat list bmg
		*mat list bmgv
		*ereturn scalar N_g = `=N'		/* only available in stata e-class program, not in do files */
		ereturn post bmg bmgv, depname(`depvar') esample(`touse')			/* post the estimate and vaiance matrix as "stored results" */

		ereturn local         cmd   "pcdid"
		ereturn scalar Ne = `=scalar(N)'
		ereturn scalar Nc = `=scalar(Nc)'
		ereturn scalar T  = `=scalar(T)'
		ereturn scalar NeT = `=scalar(N)'*`=scalar(T)'
		ereturn scalar NcT = `=scalar(Nc)'*`=scalar(T)'
		ereturn scalar nobs =  (`=scalar(N)'+`=scalar(Nc)')*`=scalar(T)'
		ereturn scalar factnum = `=scalar(factnum)'
		ereturn scalar factnum0 = `=scalar(factnum0)'
		ereturn scalar factnum1 = `=scalar(factnum1)'
		ereturn matrix bmgc = bmgc, copy		/* the effective number of treated units for each coefficient */
		ereturn scalar alphastat = `=scalar(alphastat)'
		ereturn scalar alphastatse = `=scalar(alphastatse)'
		ereturn scalar alphastatz = `=scalar(alphastatz)'
		ereturn scalar alphastatp = `=scalar(alphastatp)'
		ereturn scalar kmax = `=scalar(kmaxall)'
		
		*PCDID-MG regression
		disp 
		disp as text "PCDID: Principal    Components              Number of obs           = " as result %8.0g e(nobs)
		disp as text "       Diff-in-Diff Regression              Number of groups        = " as result %8.0g e(Ne) + e(Nc)
		disp as text "      (by CK, *PCDID Approach*)             (Treated = " as result %7.0g e(Ne) as text ")"
		disp as text "                                            (Control = " as result %7.0g e(Nc) as text ")"
		disp as text "                                            Obs per group           = " as result %8.0g e(T)
		disp as text "Method: Mean-Group (PCDID-MG)               Number of factors used  = " as result %8.0g e(factnum)
		disp 
				
		ereturn display					/* display the stored results for PCDID-MG in a standard regression table format */
		disp as text "# of treated groups in computing the MG coefficient on `indep1' = " as result `=bmgc[1,1]'		
	}
	
	/* compute PCDID-base estimator */
	else {
		quietly xtset `id' `time'
		if (`nwlag' == -1) {
			scalar nwlag = int(`=scalar(T)'^0.25)
		}
		else {
			scalar nwlag = `nwlag'
		}		
		quietly newey `depvar' `indeps' fproxy1-fproxy`=scalar(factnum)' if `id'==`treatid', lag(`=scalar(nwlag)')
		mat matb = e(b)
		/* matc v1.01: fix v1.0 bug about initialization */
		scalar K = colsof(matb)		
		if ("`pdall'" == "") {
			mat matc = J(`=scalar(Nc)',`=scalar(K)',0)
		}	
		
		ereturn local         cmd   "pcdid"
		ereturn scalar Ne = 1
		ereturn scalar Nc = `=scalar(Nc)'
		ereturn scalar T  = `=scalar(T)'
		ereturn scalar NeT = 1*`=scalar(T)'
		ereturn scalar NcT = `=scalar(Nc)'*`=scalar(T)'
		ereturn scalar nobs =  (1+`=scalar(Nc)')*`=scalar(T)'
		ereturn scalar factnum = `=scalar(factnum)'
		ereturn scalar factnum0 = `=scalar(factnum0)'
		ereturn scalar factnum1 = `=scalar(factnum1)'
		ereturn scalar alphastat = `=scalar(alphastat)'
		ereturn scalar alphastatse = `=scalar(alphastatse)'
		ereturn scalar alphastatz = `=scalar(alphastatz)'
		ereturn scalar alphastatp = `=scalar(alphastatp)'
		ereturn scalar kmax = `=scalar(kmaxall)'
		ereturn scalar nwlag = `=scalar(nwlag)'
		
		disp 
		disp as text "PCDID: Principal    Components              Number of obs           = " as result %8.0g e(nobs)
		disp as text "       Diff-in-Diff Regression              Number of groups        = " as result %8.0g e(Ne) + e(Nc)
		disp as text "      (by CK, *PCDID Approach*)             (Treated = " as result %7.0g e(Ne) as text ")"
		disp as text "                                            (Control = " as result %7.0g e(Nc) as text ")"
		disp as text "                                            Obs per group           = " as result %8.0g e(T)
		disp as text "Method: Basic (PCDID-basic)                 Number of factors used  = " as result %8.0g e(factnum)
		disp as text "                                            Number of NW lags used  = " as result %8.0g e(nwlag)		
		ereturn display
	}
	
	if `fproxy' == 0 {
		disp 	
		disp as text "Number of factors determined by a recursive procedure:"
		disp as text "    I(0) factors  = " as result `=scalar(factnum0)'
		if "`stationary'" != "" {
			disp as text "    I(1) factors  = " as result `=scalar(factnum1)' as text "  (all factors assumed stationary)"
		}
		else {
			disp as text "    I(1) factors  = " as result `=scalar(factnum1)'
		}
		disp as text "    Maximum factors set by user = " as result `=scalar(kmaxall)'
	}	
	if "`alpha'" != "" {	
		disp	
		disp as text "Parallel trend alpha test (Ho: alpha = 1, Ha: alpha != 1):"
		disp as text "    Alpha statistic = " as result %11.4g `=scalar(alphastat)'  as text "       Std. Err.  = " as result %11.4g `=scalar(alphastatse)'
		disp as text "    z               = " as result %11.4g `=scalar(alphastatz)'  as text "       P>|z|      = " as result %11.4g `=scalar(alphastatp)'
	}

	/* clean up workspace: erase intermediate files */
	/* note that the global scalar and matrix objects remain in memory */
	ereturn local		  id       "`id'"
	ereturn local		  time     "`time'"
	ereturn local         depvar   "`depvar'"
	ereturn local         treatvar "`treated'"
	ereturn local         indeps   "`indeps'"
	ereturn matrix		  mata  mata, copy
	ereturn matrix		  matb  matb, copy
	ereturn matrix		  matc  matc, copy
	if "`treatlist'" != "" {				
		ereturn local		  treatlist  "`treatlist'"
		ereturn scalar		  treatlistnum = 1
	}
	else {
		ereturn local 		  treatlist  ""
		ereturn scalar		  treatlistnum = 0
	}
	
 	if "`alpha'" != "" {
		use fproxy,clear
		quietly merge 1:1 `time' using ycresidmean_pcdid
		quietly drop _merge
		order `time'
		quietly save,replace
 		erase ycresidmean_pcdid.dta
 	}
	erase ycresid_pcdid.dta
	erase tindex_pcdid.dta	

	restore


end program pcdid



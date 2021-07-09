*! Timothy Neal -- 17/10/16
*! This is the third public version of xtcce, used to conduct a number of versions of Pesaran's Common Correlated Effects approach. 
*! If there are any questions, issues, or comparatibility problems with this procedure, please email tjrneal@gmail.com. 
*! I acknowledge the help of the command xtmg by Markus Eberhardt when setting up the display of the preliminary panel statistics.  
*! List of changes for the third version:
*!	- Fixes a bug that occasionally occured when 2SLS or GMM models were run. Please rerun all results if these were used in your research.
*! List of changes for the second version:
*!	- Corrects the estimation results from the option "pooled". Please rerun all results if this option was selected in your research.
*! 	- Allows the user to save the residuals.

program define xtcce, eclass prop(xt)
	version 11
	*! Parses ivregress syntax 
	_iv_parse `0'
	local Y `s(lhs)'
	local endo `s(endog)'
	local Xs `s(exog)'
	local instr `s(inst)'
	local 0 `s(zero)'

	syntax [if] [in] [, COV(string) ALAGS(integer -2) DYNAMIC GMM POOLED FULL WEIGHTED RES(string)]
	qui{	
	*! Mark the sample that is usable, identify the panel and time variable, and calculate other panel statistics.
	marksample touse
	xtset
	local ivar `r(panelvar)'
	local tvar `r(timevar)'
	sort `ivar' `tvar'
	quie levels `ivar' if `touse', local(ids)
	global iis "`ids'"
	quie count if `touse'
	local is=wordcount("$iis")
	count if `touse' 
	local n = r(N)
	
	*! Determine the title
	if "`endo'" == "" & "`dynamic'" != "" { // DCCE MG
		if ("`pooled'" != "") local title "Dynamic Common Correlated Effects Estimation - Pooled OLS"
		else local title "Dynamic Common Correlated Effects Estimation - Mean Group OLS"
	} 
	else if "`endo'" == "" { // CCE MG
		if ("`pooled'" != "") local title "Common Correlated Effects Estimation - Pooled OLS"
		else local title "Common Correlated Effects Estimation - Mean Group OLS"
	} 
	else if "`dynamic'" != "" & "`gmm'" != "" { // DCCE-GMM MG
		if ("`pooled'" != "") local title "Dynamic Common Correlated Effects Estimation - Pooled GMM"
		else local title "Dynamic Common Correlated Effects Estimation - Mean Group GMM (HAC)"
	}
	else if "`gmm'" != "" { // CCE-GMM MG
		if ("`pooled'" != "") local title "Common Correlated Effects Estimation - Pooled GMM"
		else local title "Common Correlated Effects Estimation - Mean Group GMM (HAC)"
	}
	else if "`dynamic'" != "" { // DCCE-2SLS MG
		if ("`pooled'" != "") local title "Dynamic Common Correlated Effects Estimation - Pooled 2SLS"		
		else local title "Dynamic Common Correlated Effects Estimation - Mean Group 2SLS"	
	}
	else { // CCE-2SLS MG
		if ("`pooled'" != "") local title "Common Correlated Effects Estimation - Pooled 2SLS"
		else local title "Common Correlated Effects Estimation - Mean Group 2SLS"
	}

	*! Create a list of vars that have the time averages, for inclusion in later regression.
	local i = 1
	foreach x in `Y' `Xs' `endo' `cov' {
		if (!strpos("`x'", ".")) {
			tempvar tm`i' hold
			gen `hold' = `x'
			bysort `tvar': egen `tm`i''`x'_csa = mean(`hold') if `touse'
			sort `ivar' `tvar'
			drop `hold'
			local tmeanlist "`tmeanlist' `tm`i''`x'_csa"
			local tmeanlistnames "`tmeanlistnames' `x'_csa"
			local i = `i' + 1
		}
	}
	*! Determine the number of lags to the cross-section averages to use
	if "`dynamic'" != "" {
		if (`alags' < 0) local alags1 = round((`n'/`is')^(1/3))
		else local alags1 = `alags'
	}	
	*! Find m and also set up a name macro
	if "`dynamic'" != "" {
			tsunab dylist: `endo' `Xs' l(`alags1'/0).(`tmeanlist')
			local m=wordcount("`dylist'") + 1
			// Modifying the names list so that the local macro jargon doesn't come up in the results table
			local i = 1
			local names `dylist' constant
			foreach x in `Y' `endo' `Xs' `cov' {
				local names = subinstr("`names'","`tm`i''","",.)
				local i = `i' + 1
			}
	}
	else {
			local m=wordcount("`Xs' `endo' `tmeanlist'") + 1
			local names `endo' `Xs' `tmeanlistnames' constant
	}
	
	if "`res'" != "" {
		tempvar resid
		gen `res' = .
	}
		

	
	*! Part 2: Pooled Regression
	if "`pooled'" != "" {
		if ("`endo'" == "" & "`dynamic'" != "") regress `Y' `Xs' i.`ivar' i.`ivar'#c.(l(`alags1'/0).(`tmeanlist')) if `touse' // DCCE Pooled
		else if ("`endo'" == "") regress `Y' `Xs' i.`ivar' i.`ivar'#c.(`tmeanlist') if `touse' // CCE Pooled
		else if ("`dynamic'" != "" & "`gmm'" != "") ivregress gmm `Y' `Xs' i.`ivar' i.`ivar'#c.(l(`alags1'/0).(`tmeanlist')) (`endo' = `instr') if `touse' // DCCE-GMM Pooled
		else if ("`gmm'" != "") ivregress gmm `Y' `Xs' i.`ivar' i.`ivar'#c.(`tmeanlist') (`endo' = `instr') if `touse' // CCE-GMM Pooled
		else if ("`dynamic'" != "") ivregress 2sls `Y' `Xs' i.`ivar' i.`ivar'#c.(l(`alags1'/0).(`tmeanlist')) (`endo' = `instr') if `touse' // DCCE-2sls Pooled
		else ivregress 2sls `Y' `Xs' i.`ivar' i.`ivar'#c.(`tmeanlist') (`endo' = `instr') if `touse' // CCE-2SLS Pooled
		matrix bavg = e(b)
		matrix vce = e(V)	
		
		// Save residuals (if specified)
		if "`res'" != "" {
			predict `resid', residuals 
			replace `res' = `resid' if `touse'
			drop `resid'
		}
	}
	else { // Part 3: Mean Group Regression
		mata: setup(`m')
				
		qui foreach i of global iis {		
			tempvar tvar2
			// Regressions
			if ("`endo'" == "" & "`dynamic'" != "") regress `Y' `Xs' l(`alags1'/0).(`tmeanlist') if `ivar' == `i' & `touse' // DCCE MG
			else if ("`endo'" == "") regress `Y' `Xs' `tmeanlist' if `ivar' == `i' & `touse' // CCE MG
			else if "`dynamic'" != "" & "`gmm'" != "" { // DCCE-GMM MG
				gen `tvar2' = `tvar' if `ivar'==`i'
				tsset `tvar2'
				ivregress gmm `Y' `Xs' l(`alags1'/0).(`tmeanlist') (`endo' = `instr') if `ivar' == `i' & `touse', wmatrix(hac bartlett opt)
				xtset `ivar' `tvar'
			}
			else if "`gmm'" != "" { // CCE-GMM MG
				gen `tvar2' = `tvar' if `ivar'==`i'
				tsset `tvar2'
				ivregress gmm `Y' `Xs' `tmeanlist' (`endo' = `instr') if `ivar' == `i' & `touse', wmatrix(hac bartlett opt)		
				xtset `ivar' `tvar'
			}
			else if ("`dynamic'" != "") ivregress 2sls `Y' `Xs' l(`alags1'/0).(`tmeanlist') (`endo' = `instr') if `ivar' == `i' & `touse' // DCCE-2SLS MG
			else ivregress 2sls `Y' `Xs' `tmeanlist' (`endo' = `instr') if `ivar' == `i' & `touse' // CCE-2SLS MG

			// Save residuals (if specified)
			if "`res'" != "" {
				predict `resid', residuals 
				replace `res' = `resid' if `ivar' == `i' & `touse'
				drop `resid'
			}
			
			// Display the individual results if specified
			local nind = e(N)
			if "`full'" != "" {
				//count if `touse' & `ivar' == `i'
				noi display ""
				noi display ""
				noi display "`title'"
				noi display ""
				noi display in gr "Results for panel unit: `i'			" in gr "	Observations: `nind'" 
				noi ereturn display
			}
			
			// Save results
			mata: saveresults(`nind')
		}
		mata: meanresults(`is', "`weighted'")
	}
	
	// Averaging of the results
	if ("`pooled'" == "") local obies = obsv
	else local obies = e(N)
	
	if ("`pooled'" == "") matrix colnames bavg = `names'
	if ("`pooled'" == "") matrix rownames vce = `names'
	if ("`pooled'" == "") matrix colnames vce = `names'
	if ("`pooled'" == "") matrix colnames fullb = `names'
	ereturn post bavg vce, depname("`Y'") esample(`touse') obs(`obies')
	
	// Ereturn storing
	if ("`pooled'" == "") mata: poste()
	ereturn local tvar "`tvar'"
	ereturn local ivar "`ivar'"
	ereturn local cmd "xtcce"
	if ("`pooled'" != "") ereturn local title "Pooled Estimation"
	else if ("`weighted'" != "") ereturn local title "Weighted mean group estimation"
	else ereturn local title "Mean group estimation"
	if ("`pooled'" == "") ereturn matrix bfull = fullb
	ereturn scalar N_g = `is'
	
	capture test `Xs' `endo', min constant
	if (_rc == 0) {
		ereturn scalar chi2 = r(chi2)
		ereturn scalar df_m = r(df)
	}
	else est scalar df_m = 0
	ereturn local chi2type "Wald"

	noi { // Display Results
		display ""
		display ""
		display "`title'" 
		
	// Preliminary stats
	_crcphdr
	
	// Display the main regression results	
	ereturn display
	
	// Postscripts
	display "The suffix _csa is used to denote the cross section average of the preceding variable." 
	if ("`weighted'" != "" & "`pooled'" == "") display in gr "The mean group estimates have been weighted by the standard errors of the individual coefficients."
	else if ("`pooled'" == "") display in gr "The mean group estimates are unweighted."
	if ("`dynamic'" != "") {
		if ("`endo'" != "") display in gr "Instruments for endogenous vars: `Xs' `instr' l(`alags1'/0).(`tmeanlistnames') constant" 
	}
	else {
		if ("`endo'" != "") display in gr "Instruments for endogenous vars: `Xs' `instr' `tmeanlistnames' constant" 
	}
	}
	}
end

mata:
void setup (real scalar m) {
	external real matrix fullresults, nind, fullse
	fullresults = J(1,m,0)
	nind = J(1,1,0)
	fullse = J(1,m,0)
}
void saveresults (real scalar n) {
	external real matrix fullresults, nind, fullse
	b = st_matrix("e(b)")
	fullresults = fullresults \ b
	nind = nind \ n
	eV = sqrt(diagonal(st_matrix("e(V)")))'
	fullse = fullse \ eV
}
void meanresults (real scalar is, string weighted) {
	external real matrix fullresults, fullse, nind
	obs = sum(nind)
	bfull = fullresults[| 2,1 \ .,.|]
	fullse2 = 1 :/ fullse[|2,1 \ .,.|]
	if (weighted != "") {
		bmean = colsum(bfull :* fullse2) :/ colsum(fullse2)
	}
	else {
		bmean = mean(bfull)
	}
	tmp = bfull - J(is,1,1)#(bmean)
	v = tmp' * tmp / (is*(is-1))
	st_matrix("nind2", nind2)
	st_matrix("bavg", bmean)
	st_matrix("vce", v)
	st_matrix("fullb", bfull)
	st_numscalar("obsv",obs)
}
void poste () {
	external real matrix nind
	nind2 = nind[| 2,1 \ .,.|]
	g1 = min(nind2)
	g2 = mean(nind2)
	g3 = max(nind2)
	st_numscalar("e(g_min)",g1)
	st_numscalar("e(g_avg)",g2)
	st_numscalar("e(g_max)",g3)
}
end

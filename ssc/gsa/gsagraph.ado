program define gsagraph

	version  9
	syntax varlist [if] [in], [TAU(numlist >0)] [TSTAT(numlist)] [CORrelation] [FRACtional] [QUADratic] [LOWEss] [nplots(int 5)] [SCATTER]

	*	COUNTING NUMBER OF THE VARIABLES
	local nvar = 0
	foreach var in `varlist' {
		local nvar = `nvar' + 1
	}
	local nvar_sub1 = `nvar'-1	
	local nvar_sub2 = `nvar'-2
	
	
	*	ERROR MESSAGES
	if `nplots' > 10 {							/* ADDED IN V18 */
		local nplots = 10
		display ""
		display as text "Maximum number of nplots is 10. The first 10 variables are ploted."
	}
	
	if `nplots' > `nvar_sub2' {					/* ADDED IN V18 */
		local nplots = `nvar_sub2'
		display ""
		display as text "Maximum # of nplots (or the default value of 5) is larger than the # of covariates in the model. All covariates will be plotted."
	}	
	
	gettoken y rhs : varlist
	gettoken t X :rhs	
	tokenize `X'
	
	if "`tau'" != "" {							/* ADDED IN V16 */
		local qoi_lab "tau"
		local qoi_val `tau'
	}
	else {
		local qoi_lab "t-value"
		local qoi_val `tstat'
	}

	if "`print'" != "noprint" & "`fractional'" == "" & "`quadratic'" == "" & "`lowess'" == "" {			/* ADDED IN V21 */
		local fractional "fractional"
		display as text "Graph option is not selected. Contour is drawn with fractional polynomial."
		display ""
	}
	
	if "`fractional'" != "" {
		local graphtype "fpfit"
		noisily display "Contour is drawn with fractional polynomial."
	}
	if "`quadratic'" != "" {
		local graphtype "qfit"
		noisily display "Contour is drawn with quadratic prediction."
	}
	if "`lowess'" != "" {
		local graphtype "lowess"
		noisily display "Contour is drawn with lowess smoothing."
	}
	
	if "`correlation'" != "" {
		local vars "gsa_rho_res_yu gsa_rho_res_tu"
		local ytitle "Partial Correlation for Outcome"
		local xtitle "Partial Correlation for Assignment"
		local xycrd "rho_res"
	}
	else {
		local vars "gsa_partial_rsq_y gsa_partial_rsq_t"
		local ytitle "Partial R-sq for Outcome"
		local xtitle "Partial R-sq for Assignment"
		local xycrd "partial_rsq"
	}

	forvalues k = 0/`nplots' {
		local xcrd`k' = abs(gsa_`xycrd'_tx[`k'])
		local ycrd`k' = abs(gsa_`xycrd'_yx[`k'])
		if `xcrd`k'' >1 {
			local xcrd`k' = 1
		}
		if `ycrd`k'' >1 {
			local ycrd`k' = 1
		}	
	}
		
	*	SCATTER OPTION	
	if "`scatter'" != "" {							/* ADDED IN V16 */
		local gsa_scatter "(scatter `vars' `if', mcolor(midblue) msize(small) msymbol(circle_hollow) mlcolor(midblue) mlwidth(vvvthin))"
	}

	forvalues np = 1/`nplots' {
		local gsa_crd`np' "(scatteri `ycrd`np'' `xcrd`np'' "``np''", mcolor(edkblue) msize(medsmall) msymbol(plus) mlabsize(small) mlabcolor(emidblue)) "
	}
		
	twoway (`graphtype' `vars' `if', lcolor(midblue) lwidth(thin)) `gsa_scatter' `gsa_crd1' `gsa_crd2' `gsa_crd3' `gsa_crd4' `gsa_crd5' `gsa_crd6' `gsa_crd7' `gsa_crd8' `gsa_crd9' `gsa_crd10' ///
	, ytitle(`ytitle') xtitle(`xtitle') legend(order(1 "GSA Bound: `qoi_lab' = `qoi_val'"))


end

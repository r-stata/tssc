*capture program drop isa_graph

program define isa_graph

	version  9
	syntax varlist, [TAU(numlist >0)] [TSTAT(numlist >0)] [nplots(int 5)]
	marksample touse

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
	
	if "`tau'" != "" {							/* ADDED IN V16 */
		local qoi_lab "tau"
		local qoi_val `tau'
	}
	else {
		local qoi_lab "t-value"
		local qoi_val `tstat'
	}
	
	local vars "isa_partial_rsq_y isa_partial_rsq_t"
	local ytitle "Partial R-sq for Outcome"
	local xtitle "Partial R-sq for Assignment"

	forvalues k = 0/`nplots' {
		local xcrd`k' = abs(isa_partial_rsq_tx[`k'])
		local ycrd`k' = abs(isa_partial_rsq_yx[`k'])
		local isa_plotvar`k' = isa_plotvar[`k']
		if `xcrd`k'' >1 {
			local xcrd`k' = 1
		}
		if `ycrd`k'' >1 {
			local ycrd`k' = 1
		}	
	}

	forvalues np = 1/`nplots' {
		local isa_crd`np' "(scatteri `ycrd`np'' `xcrd`np'' "`isa_plotvar`np''", mcolor(edkblue) msize(medsmall) msymbol(plus) mlabsize(small) mlabcolor(emidblue)) "
	}
		
	twoway (line `vars', sort lcolor(midblue) lwidth(thin)) `isa_crd1' `isa_crd2' `isa_crd3' `isa_crd4' `isa_crd5' `isa_crd6' `isa_crd7' `isa_crd8' `isa_crd9' `isa_crd10' ///
	, ytitle(`ytitle') xtitle(`xtitle') legend(order(1 "ISA Bound: `qoi_lab' = `qoi_val'"))


end

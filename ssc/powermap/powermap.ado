********************************************************************************
*  -powermap-
*
*  Cristhian Pulido
*  Department of Economics, University of Sussex 
*  E-mail:  c.pulido@sussex.ac.uk
********************************************************************************

*! version 1.0 01jul2020

capture program drop powermap
program define powermap
version 13

syntax, [n(integer -1)]       ///
		[POWer(real -1)]      ///
		 mde(real)            ///
		 MEthod(str)          ///
		 rho(real)            ///
		 sd(real)             ///
        [ROunds(integer 20)]  ///
		[PTreat(real .5)]     ///
		[ALPha(real .05)]     ///
		[ONEsided]            ///
		[SAVing(str)]

*--------------------------- Start program -------------------------------------

* Preserve the current data
preserve

quietly{

	* Error messages
	cap assert (`n'==-1 & `power'!=-1) | (`n'!=-1 & `power'==-1)
	if _rc { 
		di in red "n() and power() cannot be combined"
		exit 198 
	}
	
	
	if (`n'!=-1 & `power'==-1) {
		cap assert `n' >= 1
		if _rc { 
			di in red "n() must be positive and greater than 1"
			exit 198 
		}
	}
	
	if (`n'==-1 & `power'!=-1) {
		cap assert `power' > 0 & `power' < 1
		if _rc { 
			di in red "power() must be between 0 and 1"
			exit 198 
		}
	}
		
	cap assert "`method'" == "post" | "`method'" == "change" | "`method'" == "ancova"
	if _rc { 
		di in red "method(`method') not valid"
		exit 198 
	}
	
	cap assert `rounds' >= 1
	if _rc { 
		di in red "rounds() must be at least 1"
		exit 198 
	}
	
	cap assert `rho' >= -1 & `rho' <= 1
	if _rc { 
		di in red "rho() must be between -1 and 1"
		exit 198 
	}
	
	cap assert `ptreat' >= 0 & `ptreat' <= 1
	if _rc { 
		di in red "ptreat() must be between 0 and 1"
		exit 198 
	}
	
	cap assert `alpha' > 0 & `alpha' < 1
	if _rc { 
		di in red "alpha() must be between 0 and 1"
		exit 198 
	}
		
	*******************************************
	*  1. Power heat map for a given sample   *
	*******************************************
	
	if (`n'!=-1 & `power'==-1) {
	
		* Other in-program locals
		local per_alpha=`alpha'*100
		local pertreat=`ptreat'*100

		* Create dataset with all the possible combinations of pre-post rounds
		drop _all
		tempfile powermap
		set obs `rounds'
		gen pre_r=_n
		gen post_r=_n
		fillin pre_r post_r
		drop _fillin
		
		* Generate variables for the "saving" option
		gen double Power=.
		gen method=""
		gen mde=.
		gen n_t_round=.
		gen n_c_round=.
		gen n_round=.
		gen n_total=.
		gen double rho=.
		gen sd=.
		gen ptreat=.
		gen alpha=.
		gen test=""
	
		* Loop over all the pre-post combinations
		forval pre_r_pc=1/`rounds' { 
			forval post_r_pc=1/`rounds' { 
			
				* Define sample sizes per group
				if "`method'"=="post" {
					local n_t_round=round((`ptreat'*`n')/`post_r_pc')
					local n_c_round=round(((1-`ptreat')*`n')/`post_r_pc')
				}
				
				else if "`method'"=="change" | "`method'"=="ancova" {
					local n_t_round=round((`ptreat'*`n')/(`pre_r_pc'+`post_r_pc'))
					local n_c_round=round(((1-`ptreat')*`n')/(`pre_r_pc'+`post_r_pc'))
				}
					
				* Estimate power for the given parameters
			
				// One-sided test
				if "`onesided'"=="" {
					qui sampsi 0 `mde',   ///
						m(`method')       ///
						pre(`pre_r_pc')   ///
						post(`post_r_pc') ///
						n1(`n_t_round')   ///
						n2(`n_c_round')   ///
						r0(`rho')         ///
						r1(`rho')         ///
						sd(`sd')          ///
						alpha(`alpha')
				
					replace Power=r(power) if pre_r==`pre_r_pc' & post_r==`post_r_pc'
					replace n_round=r(N_1)+r(N_2) if pre_r==`pre_r_pc' & post_r==`post_r_pc'
					replace test="two-sided" 
					local test "two-sided"
					
					if "`method'"=="post" {
						replace n_total=n_round*(`post_r_pc') if pre_r==`pre_r_pc' & post_r==`post_r_pc'
					}
					else if "`method'"=="change" | "`method'"=="ancova" {
						replace n_total=n_round*(`pre_r_pc'+`post_r_pc') if pre_r==`pre_r_pc' & post_r==`post_r_pc'
					}				 
				}
				
				// Two-sided test
				else if "`onesided'"!="" {
					qui sampsi 0 `mde',   ///
						m(`method')       ///
						pre(`pre_r_pc')   ///
						post(`post_r_pc') ///
						n1(`n_t_round')   ///
						n2(`n_c_round')   ///
						r0(`rho')         ///
						r1(`rho')         ///
						sd(`sd')          ///
						alpha(`alpha')    ///
						onesided
				
					replace Power=r(power) if pre_r==`pre_r_pc' & post_r==`post_r_pc'
					replace n_total=(r(N_1)+r(N_2))*(`pre_r_pc'+`post_r_pc') if pre_r==`pre_r_pc' & post_r==`post_r_pc'
					replace test="one-sided"
					local test "one-sided"	
					
					if "`method'"=="post" {
						replace n_total=n_round*(`post_r_pc') if pre_r==`pre_r_pc' & post_r==`post_r_pc'
					}
					else if "`method'"=="change" | "`method'"=="ancova" {
						replace n_total=n_round*(`pre_r_pc'+`post_r_pc') if pre_r==`pre_r_pc' & post_r==`post_r_pc'
					}					 
				}

				* Replace additional variables for the -saving- option
				foreach var in method rho mde n_t_round n_c_round sd alpha ptreat {
					cap replace `var'="``var''" if pre_r==`pre_r_pc' & post_r==`post_r_pc'
					cap replace `var'=``var''   if pre_r==`pre_r_pc' & post_r==`post_r_pc'
				}
			}
		}
		
		* Generate heatmap in Stata using the -heatplot- command
		if `rounds'<=20 {
			heatplot Power pre_r post_r,                                         ///
					 plotregion(lcolor(white) lwidth(tiny) margin(zero))         ///
					 keyl(, subtitle(, size(small)) bmargin(left) format(%9.2f)) ///
					 colors(#F8696B #FFEB84 #63BE7B, reverse)                    ///
					 levels(20) 												 ///
					 backfill 													 ///
					 xlabel(1(1)`rounds', labsize(small)) 					     ///
					 ylabel(1(1)`rounds', nogrid labsize(small)) 			     ///
					 xtitle("Post-treatment rounds", height(4) size(small)) 	 ///
					 ytitle("Pre-treatment rounds", height(6.25) size(small))    ///
					 ysize(4.5) xsize(5.75) scale(.9) 							 ///
					 title("Power Heatmap", size(medium) margin(bottom)) 	     ///
					 note("Method: `method' * N = `n' * MDE = `mde' * ρ = 0`rho' * % treatment = `pertreat'% * Test = `test' * α = `per_alpha'%", margin(top))
		}			 
		else if `rounds'>20 & `rounds'<=40 {
			heatplot Power pre_r post_r,                                         ///
					 plotregion(lcolor(white) lwidth(tiny) margin(zero))         ///
					 keyl(, subtitle(, size(small)) bmargin(left) format(%9.2f)) ///
					 colors(#F8696B #FFEB84 #63BE7B, reverse)                    ///
					 levels(20) 												 ///
					 backfill 													 ///
					 xlabel(1(2)`rounds', labsize(small)) 					     ///
					 ylabel(1(2)`rounds', nogrid labsize(small)) 			     ///
					 xtitle("Post-treatment rounds", height(4) size(small)) 	 ///
					 ytitle("Pre-treatment rounds", height(6.25) size(small))    ///
					 ysize(4.5) xsize(5.75) scale(.9) 							 ///
					 title("Power Heatmap", size(medium) margin(bottom)) 	     ///
					 note("Method: `method' * N = `n' * MDE = `mde' * ρ = 0`rho' * % treatment = `pertreat'% * Test = `test'", margin(top))
		}
		else if `rounds'>40 & `rounds'<=50 {
			heatplot Power pre_r post_r,                                         ///
					 plotregion(lcolor(white) lwidth(tiny) margin(zero))         ///
					 keyl(, subtitle(, size(small)) bmargin(left) format(%9.2f)) ///
					 colors(#F8696B #FFEB84 #63BE7B, reverse)                    ///
					 levels(20) 												 ///
					 backfill 													 ///
					 xlabel(1(3)`rounds', labsize(small)) 					     ///
					 ylabel(1(3)`rounds', nogrid labsize(small)) 			     ///
					 xtitle("Post-treatment rounds", height(4) size(small)) 	 ///
					 ytitle("Pre-treatment rounds", height(6.25) size(small))    ///
					 ysize(4.5) xsize(5.75) scale(.9) 							 ///
					 title("Power Heatmap", size(medium) margin(bottom)) 	     ///
					 note("Method: `method' * N = `n' * MDE = `mde' * ρ = 0`rho' * % treatment = `pertreat'% * Test = `test'", margin(top))
			}
		else if `rounds'>50 {
			local lab_spec=round(`rounds'/15)
			heatplot Power pre_r post_r,                                         ///
					 plotregion(lcolor(white) lwidth(tiny) margin(zero))         ///
					 keyl(, subtitle(, size(small)) bmargin(left) format(%9.2f)) ///
					 colors(#F8696B #FFEB84 #63BE7B, reverse)                    ///
					 levels(20) 												 ///
					 backfill 													 ///
					 xlabel(1(`lab_spec')`rounds', labsize(small))               ///
					 ylabel(1(`lab_spec')`rounds', nogrid labsize(small))        ///
					 xtitle("Post-treatment rounds", height(4) size(small)) 	 ///
					 ytitle("Pre-treatment rounds", height(6.25) size(small))    ///
					 ysize(4.5) xsize(5.75) scale(.9) 							 ///
					 title("Power Heatmap", size(medium) margin(bottom)) 	     ///
					 note("Method: `method' * N = `n' * MDE = `mde' * ρ = 0`rho' * % treatment = `pertreat'% * Test = `test'", margin(top))
			}
		
		* Save power calculations data (if saving option was selected)
		if "`saving'"!="" {
			rename (*_r Power) (*_rounds power)
			label var pre_r "# of pre-treatment rounds"
			label var post_r "# of post-treatment rounds"
			label var power "Statistical power"
			label var method "Estimation method (post/change/ancova)"		
			label var mde "Minimum detectable effect"
			label var n_t_round "Cross sectional sample (treatment group)"		
			label var n_c_round "Cross sectional sample (control group)"
			label var n_round "Total cross-sectional sample"
			label var n_total "Total sample size"
			label var rho "Constant serial correlation of the outcome variable"		
			label var sd "Standard deviation of the outcome variable"
			label var ptreat "% of total sample allocated to treatment group"		
			label var alpha "Significance level"
			label var test "Test type (one/two sided)"		
			
			save "`saving'", replace
		}
	}
	
	*******************************************
	*  2. Sample heat map for a given power   *
	*******************************************
	
	if (`n'==-1 & `power'!=-1) {
	
		* Other in-program locals
		local per_alpha=`alpha'*100
		local pertreat=`ptreat'*100
		local ratio_treat=`ptreat'/(1-`ptreat')
		local per_power=`power'*100

		* Create dataset with all the possible combinations of pre-post rounds
		drop _all
		tempfile samplemap
		set obs `rounds'
		gen pre_r=_n
		gen post_r=_n
		fillin pre_r post_r
		drop _fillin
		
		* Generate variables for the "saving" option
		gen double power=.
		gen method=""
		gen mde=.
		gen n_t_round=.
		gen n_c_round=.
		gen n_round=.
		gen Sample=.
		gen double rho=.
		gen sd=.
		gen ptreat=.
		gen alpha=.
		gen test=""
	
		* Loop over all the pre-post combinations
		forval pre_r_pc=1/`rounds' { 
			forval post_r_pc=1/`rounds' { 
				
				* Estimate sample size for the given parameters
				
				// One-sided test
				if "`onesided'"=="" {
					qui sampsi 0 `mde',   ///
						m(`method')       ///
						pre(`pre_r_pc')   ///
						post(`post_r_pc') ///
						r0(`rho')         ///
						r1(`rho')         ///
						sd(`sd')          ///
						alpha(`alpha')    ///
						power(`power')    ///
						ratio(`ratio_treat')

					replace power=r(power) if pre_r==`pre_r_pc' & post_r==`post_r_pc'
					replace n_t_round=r(N_2) if pre_r==`pre_r_pc' & post_r==`post_r_pc'
					replace n_c_round=r(N_1) if pre_r==`pre_r_pc' & post_r==`post_r_pc'
					replace n_round=n_t_round+n_c_round if pre_r==`pre_r_pc' & post_r==`post_r_pc'
					replace test="two-sided" 
					local test "two-sided" 
					
					if "`method'"=="post" {
						replace Sample=n_round*(`post_r_pc') if pre_r==`pre_r_pc' & post_r==`post_r_pc'
					}
					else if "`method'"=="change" | "`method'"=="ancova" {
						replace Sample=n_round*(`pre_r_pc'+`post_r_pc') if pre_r==`pre_r_pc' & post_r==`post_r_pc'
					}	
				}
				
				// Two-sided test
				else if "`onesided'"!="" {
					qui sampsi 0 `mde',   ///
						m(`method')       ///
						pre(`pre_r_pc')   ///
						post(`post_r_pc') ///
						r0(`rho')         ///
						r1(`rho')         ///
						sd(`sd')          ///
						alpha(`alpha')    ///
						power(`power')   ///
						ratio(`ratio_treat') ///
						onesided
				
					replace power=r(power) if pre_r==`pre_r_pc' & post_r==`post_r_pc'
					replace n_t_round=r(N_2) if pre_r==`pre_r_pc' & post_r==`post_r_pc'
					replace n_c_round=r(N_1) if pre_r==`pre_r_pc' & post_r==`post_r_pc'
					replace n_round=n_t_round+n_c_round if pre_r==`pre_r_pc' & post_r==`post_r_pc'
					replace test="two-sided" 
					local test "two-sided" 
					
					if "`method'"=="post" {
						replace Sample=n_round*(`post_r_pc') if pre_r==`pre_r_pc' & post_r==`post_r_pc'
					}
					else if "`method'"=="change" | "`method'"=="ancova" {
						replace Sample=n_round*(`pre_r_pc'+`post_r_pc') if pre_r==`pre_r_pc' & post_r==`post_r_pc'
					}	
				}

				* Replace additional variables for the -saving- option
				foreach var in method rho mde n_t_round n_c_round sd alpha ptreat {
					cap replace `var'="``var''"   if pre_r==`pre_r_pc' & post_r==`post_r_pc'
					cap replace `var'=``var''   if pre_r==`pre_r_pc' & post_r==`post_r_pc'
				}
			}
		}

		* Generate heatmap in Stata using the -heatplot- command
		if `rounds'<=20 {
			heatplot Sample pre_r post_r,  										 ///
					 plotregion(lcolor(white) lwidth(tiny) margin(zero))         ///
					 keyl(, subtitle(, size(small)) bmargin(left) format(%9.0f)) ///
					 colors(#F8696B #FFEB84 #63BE7B)                             ///
					 levels(20)  												 ///
					 backfill 													 ///
					 xlabel(1(1)`rounds', labsize(small)) 					     ///
					 ylabel(1(1)`rounds', nogrid labsize(small)) 			     ///
					 xtitle("Post-treatment rounds", height(4) size(small)) 	 ///
					 ytitle("Pre-treatment rounds", height(6.25) size(small))    ///
					 ysize(4.5) xsize(5.75) scale(.9) 							 ///
					 title("Sample Heatmap", size(medium) margin(bottom)) 	     ///
					 note("Method: `method' * Power = `per_power'% * MDE = `mde' * ρ = 0`rho' * % treatment = `pertreat'% * Test = `test' * α = `per_alpha'%", margin(top))
		}			 
		else if `rounds'>20 & `rounds'<=40 {
			heatplot Sample pre_r post_r,                                        ///
					 plotregion(lcolor(white) lwidth(tiny) margin(zero))         ///
					 keyl(, subtitle(, size(small)) bmargin(left) format(%9.0f)) ///
					 colors(#F8696B #FFEB84 #63BE7B)                   			 ///
					 levels(20) 												 ///
					 backfill 													 ///
					 xlabel(1(2)`rounds', labsize(small)) 					     ///
					 ylabel(1(2)`rounds', nogrid labsize(small)) 			     ///
					 xtitle("Post-treatment rounds", height(4) size(small)) 	 ///
					 ytitle("Pre-treatment rounds", height(6.25) size(small))    ///
					 ysize(4.5) xsize(5.75) scale(.9) 							 ///
					 title("Sample Heatmap", size(medium) margin(bottom)) 	     ///
					 note("Method: `method' * Power = `per_power'% * MDE = `mde' * ρ = 0`rho' * % treatment = `pertreat'% * Test = `test' * α = `per_alpha'%", margin(top))
		}
		else if `rounds'>40 & `rounds'<=50 {
			heatplot Sample pre_r post_r,                                        ///
					 plotregion(lcolor(white) lwidth(tiny) margin(zero))         ///
					 keyl(, subtitle(, size(small)) bmargin(left) format(%9.0f)) ///
					 colors(#F8696B #FFEB84 #63BE7B)                             ///
					 levels(20) 												 ///
					 backfill 													 ///
					 xlabel(1(3)`rounds', labsize(small)) 					     ///
					 ylabel(1(3)`rounds', nogrid labsize(small)) 			     ///
					 xtitle("Post-treatment rounds", height(4) size(small)) 	 ///
					 ytitle("Pre-treatment rounds", height(6.25) size(small))    ///
					 ysize(4.5) xsize(5.75) scale(.9) 							 ///
					 title("Sample Heatmap", size(medium) margin(bottom)) 	     ///
					 note("Method: `method' * Power = `per_power'% * MDE = `mde' * ρ = 0`rho' * % treatment = `pertreat'% * Test = `test' * α = `per_alpha'%", margin(top))
		}
		else if `rounds'>50 {
			local lab_spec=round(`rounds'/15)
			heatplot Sample pre_r post_r,                                        ///
					 plotregion(lcolor(white) lwidth(tiny) margin(zero))         ///
					 keyl(, subtitle(, size(small)) bmargin(left) format(%9.0f)) ///
					 colors(#F8696B #FFEB84 #63BE7B)                             ///
					 levels(20) 												 ///
					 backfill 													 ///
					 xlabel(1(`lab_spec')`rounds', labsize(small))               ///
					 ylabel(1(`lab_spec')`rounds', nogrid labsize(small))        ///
					 xtitle("Post-treatment rounds", height(4) size(small)) 	 ///
					 ytitle("Pre-treatment rounds", height(6.25) size(small))    ///
					 ysize(4.5) xsize(5.75) scale(.9) 							 ///
					 title("Sample Heatmap", size(medium) margin(bottom)) 	     ///
					 note("Method: `method' * Power = `per_power'% * MDE = `mde' * ρ = 0`rho' * % treatment = `pertreat'% * Test = `test' * α = `per_alpha'%", margin(top))
		}
		
		* Save power calculations data (if saving option was selected)
		if "`saving'"!="" {
			rename (*_r Sample) (*_rounds n_total)
			label var pre_r "# of pre-treatment rounds"
			label var post_r "# of post-treatment rounds"
			label var power "Statistical power"
			label var method "Estimation method (post/change/ancova)"		
			label var mde "Minimum detectable effect"
			label var n_t_round "Cross sectional sample (treatment group)"		
			label var n_c_round "Cross sectional sample (control group)"
			label var n_round "Total cross-sectional sample"
			label var n_total "Total sample size"	
			label var rho "Constant serial correlation of the outcome variable"		
			label var sd "Standard deviation of the outcome variable"
			label var ptreat "% of total sample allocated to treatment group"		
			label var alpha "Significance level"
			label var test "Test type (one/two sided)"		
			
			save "`saving'", replace
		}
	}
}
restore
end
*---------------------------- End program --------------------------------------

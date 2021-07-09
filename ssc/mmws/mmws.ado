*! 1.21 Ariel Linden 18Feb2017 // Fixed bug in IPTW for multiple treatments 
*! 1.20 Ariel Linden 22Jan2017 // Added tlevel option; cleaned up common support code; changed figure to show only values within common support when common is specified
*! 1.10 Ariel Linden 31Dec2014 //added IPTW option
*! 1.00 Ariel Linden 06June2014

program mmws, rclass
version 13.0

	/* obtain settings */
	syntax varlist(min=1 max=1 numeric) [if] [in], 			/// treatment variable
	PScore(varlist min=1 numeric) 		           	  		/// propensity score provided by user
	[ NSTRata(numlist min=1 int)							/// if user wants mmws to provide strata
	STRata(varlist min=1 numeric)		       				/// if user provides strata
	ORDinal                                   				/// if ordinal treatments
	TLEVel(numlist min=1 max=1 int)							/// if ordinal, which level was used for predicting pscore
	NOMinal													///	if nominal treatments
	ATT				       									///	if average treatment effect on the treated (binary treatments only)
	IPTW													/// adds IPTW as an option
	COMMon		                                			/// common support 
	FIGure													/// histogram of pscore distribution(s)
	REPLace PREfix(str) *]
	
	gettoken treat : varlist 
	
quietly { 
		marksample touse 
		count if `touse' 
		if r(N) == 0 error 2000
		local N = r(N) 
		replace `touse' = -`touse'
	
	
		/* drop program variables if option "replace" is chosen */
		
		if "`replace'" != "" {
			local mmws : char _dta[`prefix'_mmws] 
			if "`mmws'" != "" {
				foreach v of local mmws { 
					capture drop `v' 
				}
			}
		}
	
		if "`common'" != "" {
		local supp if `prefix'_support == 1
		local supp1 & `prefix'_support == 1
		} 
	
	
*********************************
***** Binary treatments *********
*********************************	
	if "`ordinal'`nominal'" == "" {
	
		* Data verification *
		tabulate `treat' if `touse' 
		if r(r) != 2 { 
			di as err "With a binary treatment, `treat' must have exactly two values (coded 0 or 1)."
		exit 420  
		} 
		else if r(r) == 2 { 
			capture assert inlist(`treat', 0, 1) if `touse' 
			if _rc { 
			di as err "With a binary treatment, `treat' must be coded as either 0 or 1."
		exit 450 
			}
		}

		local Npscore : word count `pscore'
		if `Npscore' > 1 {
			di as err "With binary treatments, only one pscore can be specified"
			exit 198
		}
		
		local Nstrata : word count `nstrata'
		if `Nstrata' > 1 {
			di as err "With binary treatments, only one Nstrata can be specified"
			exit 198
		}
	
		* Common support *
		gen `prefix'_support = 1 if `touse'
		label var `prefix'_support "common support"
		sum `pscore' if `treat' ==0 & `touse', meanonly
		replace `prefix'_support = 0 if `pscore' <r(min) & `treat'==1 & `touse'
		sum `pscore' if `treat' ==1 & `touse', meanonly
		replace `prefix'_support = 0 if `pscore' >r(max) & `treat'==0 & `touse'
	
		* Test for strata vs nstrata and generate 5 quantiles if nstrata not specified *
		if ("`strata'" != "") & ("`nstrata'" != "") {
			di as err "Either strata or nstrata may be specified, but not both"
			exit 198
		}
		
		if ("`strata'" == "") & ("`nstrata'" != "") {
			local `nstrata'
		}
		else if ("`strata'" == "") & ("`nstrata'" == "") local nstrata = 5   
	
		* If common
		if ("`strata'" == "") & ("`common'" != "") 	{
			xtile `prefix'_strata = `pscore' if `touse' `supp1', nq(`nstrata')
		}
		* If no common
		else if ("`strata'" == "") & ("`common'" == "") 	{
			xtile `prefix'_strata = `pscore' if `touse', nq(`nstrata')
		}
		else if ("`strata'" != "") {
		clonevar `prefix'_strata = `strata' if `touse'
		}
	
	
		* get min/max support for later use in graphs
		sum `pscore' if `prefix'_support==1 & `touse', meanonly
		local suppmin = r(min)
		local suppmax = r(max)
		ret scalar suppmin = `suppmin'
		ret scalar suppmax = `suppmax'
		
		
		* Get overall sample size and treatment proportions *

		if ("`common'" != "") 	{
			count if `touse' `supp1' 								// Overall N
			local Ntot = r(N) 
			count if `treat'==1 `supp1' & `touse'					// N for treated group
			local Ntreat = r(N) 
			local treatprop = `Ntreat' / `Ntot'						// Proportion treated in sample (Pr=Z1) 
			count if `treat'==0 `supp1' & `touse'					// N for non-treated group
			local Ncontrol = r(N) 	
			local controlprop = `Ncontrol' / `Ntot'					// Proportion non-treated in sample (Pr=Z0) 
		}
		else {
			count if `touse'		 								// Overall N
			local Ntot = r(N) 
			count if `treat'==1 & `touse'							// N for treated group
			local Ntreat = r(N) 
			local treatprop = `Ntreat' / `Ntot'						// Proportion treated in sample (Pr=Z1) 
			count if `treat'==0 & `touse'							// N for non-treated group
			local Ncontrol = r(N) 	
			local controlprop = `Ncontrol' / `Ntot'					// Proportion non-treated in sample (Pr=Z0) 
		}
	
		* Generate ATT weights *
		if "`att'" != "" {

			gen `prefix'_mmws =. if `touse'
			label var `prefix'_mmws "ATT weights for binary treatment"

			local propatt = (1 - `treatprop') / `treatprop'
	
			if ("`common'" != "") 	{
				levelsof `prefix'_strata if `touse' `supp1' , local(levels)
					foreach st of local levels {
						count if `prefix'_strata==`st' & `treat'==1 `supp1' & `touse'
						local ntreat = r(N)
						count if `prefix'_strata==`st' & `treat'==0 `supp1' & `touse'
						local ncont = r(N)
						local mmwc = (`ntreat' / `ncont') * `propatt'
						replace `prefix'_mmws = `mmwc' if `prefix'_strata==`st' & `treat'==0 & `touse'
						replace `prefix'_mmws = 1  if `prefix'_strata==`st' & `treat'==1 & `touse'
						replace `prefix'_mmws = 0 if `prefix'_support != 1 & "`common'" != "" & `touse'
					}
			}
			else { // not common
				levelsof `prefix'_strata if `touse', local(levels)
					foreach st of local levels {
						count if `prefix'_strata==`st' & `treat'==1 & `touse'
						local ntreat = r(N)
						count if `prefix'_strata==`st' & `treat'==0 & `touse'
						local ncont = r(N)
						local mmwc = (`ntreat' / `ncont') * `propatt'
						replace `prefix'_mmws = `mmwc' if `prefix'_strata==`st' & `treat'==0 & `touse'
						replace `prefix'_mmws = 1  if `prefix'_strata==`st' & `treat'==1 & `touse'
					}
			} 
		
			* Generate IPTW weights for ATT
			if "`iptw'" != "" & "`att'" != "" {
				gen `prefix'_iptw = cond(`treat'==1, 1, `pscore' /(1- `pscore'))  if `touse'
				replace `prefix'_iptw = 0 if `prefix'_support != 1 & "`common'" != "" & `touse'
				label var `prefix'_iptw "IPTW (ATT) weights for binary treatment"
			}
	
			local mmws `prefix'_support `prefix'_strata `prefix'_mmws `prefix'_iptw
			char def _dta[`prefix'_mmws] "`mmws'" 

		} //end if att
	
	
		* Generate ATE Weights *
		else if "`att'" == "" { 
	
			gen `prefix'_mmws =. if `touse'
			label var `prefix'_mmws "ATE weights for binary treatment"
	
			if ("`common'" != "") 	{
				levelsof `prefix'_strata if `touse' `supp1', local(levels)
					foreach st of local levels {
						count if `prefix'_strata==`st' `supp1' & `touse'
						local ntot = r(N)
						count if `prefix'_strata==`st' & `treat'==1 `supp1' & `touse'
						local ntreat = r(N)
						count if `prefix'_strata==`st' & `treat'==0 `supp1' & `touse'
						local ncont = r(N)
						local mmwt = (`ntot' / `ntreat') * `treatprop'
						local mmwc = (`ntot' / `ncont') * `controlprop'
		
						replace `prefix'_mmws = `mmwc' if `prefix'_strata==`st' & `treat'==0 & `touse'
						replace `prefix'_mmws = `mmwt'  if `prefix'_strata==`st' & `treat'==1 & `touse'
						replace `prefix'_mmws = 0 if `prefix'_support !=1 & "`common'" != "" & `touse'			
					}
			} // end common
			else {
				levelsof `prefix'_strata if `touse', local(levels)
					foreach st of local levels {
						count if `prefix'_strata==`st' & `touse'
						local ntot = r(N)
						count if `prefix'_strata==`st' & `treat'==1 & `touse'
						local ntreat = r(N)
						count if `prefix'_strata==`st' & `treat'==0 & `touse'
						local ncont = r(N)
						local mmwt = (`ntot' / `ntreat') * `treatprop'
						local mmwc = (`ntot' / `ncont') * `controlprop'
		
						replace `prefix'_mmws = `mmwc' if `prefix'_strata==`st' & `treat'==0 & `touse'
						replace `prefix'_mmws = `mmwt'  if `prefix'_strata==`st' & `treat'==1 & `touse'
					}
			} // end not common

		} // end ATE
		
		* Generate IPTW weights for ATE
		if "`iptw'" != "" & "`att'" == "" {
	
			gen `prefix'_iptw = cond(`treat'==1, 1/`pscore', 1/(1- `pscore'))  if `touse'
			replace `prefix'_iptw = 0 if `prefix'_support !=1 & "`common'" != "" & `touse'
			label var `prefix'_iptw "IPTW (ATE) weights for binary treatment"
		}
		
		local mmws `prefix'_support `prefix'_strata `prefix'_mmws `prefix'_iptw
		char def _dta[`prefix'_mmws] "`mmws'" 
	
		
		* figure on or off common support *
		if ("`figure'" != "") {
			if ("`figure'" != "") {
				histogram `pscore' `supp', dens by(`treat', cols(1) legend(off)) xline(`suppmin' `suppmax') xla(0(.20)1) kdensity
			}
			else {
				histogram `pscore', dens by(`treat', cols(1) legend(off)) xline(`suppmin' `suppmax') xla(0(.20)1) kdensity
			}
		} //end fig	
	
	}	// Closing bracket for binary treatments

**********************************
***** Ordinal treatments *********
**********************************	
    if ("`ordinal'" != "") & ("`nominal'" != "") {
		di as err "Either ordinal or nominal options can be specified, but not both"
		exit 198
    }
	
	if ("`ordinal'" != "") {
 	
		* Data verification *
		tabulate `treat' if `touse' 
		if r(r) < 3 { 
			di as err "With an ordinal treatment, `treat' must have more than two values."
			exit 420  
		} 
	
		* Verify there is a matching number of pscores and nstrata defined, then generate strata *
		local Npscore : word count `pscore'
			if `Npscore' > 1 {
			di as err "With ordinal treatments, only one pscore can be specified"
			exit 198
		}
		
		local Nstrata : word count `nstrata'
			if `Nstrata' > 1 {
			di as err "With ordinal treatments, only one Nstrata can be specified"
			exit 198
		}
	
		* Common support - for ordinal -- default is lowest treatment level in data *
		if ("`tlevel'" == "") {
		sum `treat' if `touse', meanonly
		local tlevel = r(min)						// use the lowest treatment level as guide for support 
		}
				
		gen `prefix'_support = 1 if `touse'
		label var `prefix'_support "common support"
		sum `pscore' if `treat' == `tlevel' & `touse', meanonly
		replace `prefix'_support = 0 if (`pscore' < r(min) | `pscore' > r(max)) & `touse'
		
	
		* Test for strata vs nstrata and generate 5 quantiles if nstrata not specified *
		if ("`strata'" != "") & ("`nstrata'" != "") {
			di as err "Either strata or nstrata may be specified, but not both"
			exit 198
		}
		
		if ("`strata'" == "") & ("`nstrata'" != "") {
			local `nstrata'
		}
		else if ("`strata'" == "") & ("`nstrata'" == "") local nstrata = 5   

		* If common
		if ("`strata'" == "") & ("`common'" != "") 	{
			xtile `prefix'_strata = `pscore' if `touse' `supp1', nq(`nstrata')
		}
		* If no common
		else if ("`strata'" == "") & ("`common'" == "") 	{
			xtile `prefix'_strata = `pscore' if `touse', nq(`nstrata')
		}
		else if ("`strata'" != "") {
		clonevar `prefix'_strata = `strata' if `touse'
		}
	
		* get min/max support for later use in graphs
		sum `pscore' if `prefix'_support==1 & `touse', meanonly
		local suppmin = r(min)
		local suppmax = r(max)
		ret scalar suppmin = `suppmin'
		ret scalar suppmax = `suppmax'
		
	
		if ("`common'" != "") 	{
			count if `touse' `supp1' 
			local Nall = r(N)										// Total N of sample
		}
		else {
			count if `touse'  
			local Nall = r(N)										// Total N of sample
		}
		
		* Generate weights *
		gen `prefix'_mmws =. if `touse'
		label var `prefix'_mmws "weights for ordinal treatments"
	
		if ("`common'" != "") 	{
			levelsof `treat' if `touse' `supp1', local(treatment)
				foreach i of local treatment {
					count if `treat'==`i' `supp1' & `touse'			
					local ntreat = r(N)																// N for each treatment category
					local treatprop = `ntreat' / `Nall'												// Proportion of treated in sample (Pr=Z)
					levelsof `prefix'_strata if `touse' `supp1', local(stratae)
						foreach s of local stratae {			 
							count if `prefix'_strata==`s' `supp1' & `touse'			
							local jstrata = r(N)													// N in each strata
							count if `prefix'_strata==`s' & `treat' == `i' `supp1'	& `touse'
							local n_ij = r(N)														// N in treatment/strata cell

				replace `prefix'_mmws = (`jstrata' / `n_ij' ) * `treatprop' if `prefix'_strata == `s' & `treat' == `i' & `touse' `supp1'
				replace `prefix'_mmws = 0 if `prefix'_support !=1 & "`common'" != "" & `touse'
						}
			}
		} // end commom
		else {
			levelsof `treat' if `touse', local(treatment)
				foreach i of local treatment {
					count if `treat'==`i' & `touse'			
					local ntreat = r(N)																// N for each treatment category
					local treatprop = `ntreat' / `Nall'												// Proportion of treated in sample (Pr=Z)
					levelsof `prefix'_strata if `touse', local(stratae)
						foreach s of local stratae {			 
							count if `prefix'_strata==`s' & `touse'			
							local jstrata = r(N)													// N in each strata
							count if `prefix'_strata==`s' & `treat' == `i' & `touse'
							local n_ij = r(N)														// N in treatment/strata cell

				replace `prefix'_mmws = (`jstrata' / `n_ij' ) * `treatprop' if `prefix'_strata == `s' & `treat' == `i' & `touse'
				}
			}
		} // end no common
		
			
		* Generate IPTW weights for ATE
		if ("`iptw'" != "") {
			gen `prefix'_iptw = 1/`pscore' if `touse'
			replace `prefix'_iptw = 0 if `prefix'_support !=1 & "`common'" != "" & `touse'
			label var `prefix'_iptw "IPTW weights for ordinal treatment"
		}
	
		local mmws `prefix'_support `prefix'_strata `prefix'_mmws `prefix'_iptw
		char def _dta[`prefix'_mmws] "`mmws'" 
		
		* figure on or off common support *
		if ("`figure'" != "") {
			if ("`common'" != "") {
				histogram `pscore' `supp', dens by(`treat', cols(1) legend(off)) xline(`suppmin' `suppmax') xla(0(.20)1) kdensity
			}
			else {
				histogram `pscore', dens by(`treat', cols(1) legend(off)) xline(`suppmin' `suppmax') xla(0(.20)1) kdensity
			}
		} // end fig
		
	} // Closing bracket for ordinal treatments

**********************************
***** Nominal treatments ****
**********************************	
    if ("`ordinal'" != "") & ("`nominal'" != "") {
		di as err "Either ordinal or nominal options can be specified, but not both"
		exit 198
    }
	
	if ("`nominal'" != "") {

		* Data verification *
		tabulate `treat' if `touse' 
		if r(r) < 3 { 
			di as err "With a nominal treatment, `treat' must have more than two values."
			exit 420  
		} 
	
		* Verify there is a matching number of pscores and nstrata defined, then generate strata *
		local Npscore : word count `pscore'
		
		tabulate `treat' if `touse'
		if r(r) != `Npscore' {
			di as err "For nominal treatments, there should be one pscore for each treatment level"
		exit 198
		}

		if ("`strata'" != "") & ("`nstrata'" != "") {
			di as err "Either strata or nstrata may be specified, but not both"
		exit 198
		}
		
		local Nstrata : word count `nstrata'
		if `Nstrata' != `Npscore' &  `Nstrata' !=0 & `touse' {
			di as err "For nominal treatments, there should be one stratification specified for each pscore"
			exit 198
		}

		local Nstratae : word count `strata'
		if `Nstratae' != `Npscore' &  `Nstratae' !=0 & `touse' {
			di as err "For nominal treatments, there should be one stratification specified for each pscore"
			exit 198
		}

		* Common support *
		gen `prefix'_support = 1 if `touse'
		label var `prefix'_support "common support"
		levelsof `treat', local(levels)
			foreach tr of local levels {
			foreach p of varlist `pscore' {
			sum `p' if `treat' ==`tr' & `touse', meanonly
			replace `prefix'_support = 0 if (`p'<r(min) | `p'>r(max)) & `treat' !=`tr' & `touse'
			}
		}
	
		* Test for strata vs nstrata *
		if ("`strata'" != "") & ("`nstrata'" == "") {
			forval i = 1/`Nstratae' {
			local n : word `i' of `strata'
			clonevar `prefix'_strata`i' = `n' if `touse'
			local bag `bag' `prefix'_strata`i'
			}
		}

		* Generate strata using nstrata *
		if ("`nstrata'" != "") & ("`strata'" == ""){
			if ("`common'" != "") {
				forval i = 1/`Npscore' {
					local v : word `i' of `pscore'
					local n : word `i' of `nstrata'
					xtile `prefix'_strata`i' = `v' if `touse' `supp1', nq(`n')
					local bag `bag' `prefix'_strata`i' 
				}
			} //if common
			else  {
				forval i = 1/`Npscore' {
					local v : word `i' of `pscore'
					local n : word `i' of `nstrata'
					xtile `prefix'_strata`i' = `v' if `touse', nq(`n')
					local bag `bag' `prefix'_strata`i' 
				}
			} //if not common
		} // end nstrata with specified # strata 	
		else if ("`nstrata'" == "") & ("`strata'" == "") {
			if ("`common'" != "") {
				forval i = 1/`Npscore' {
					local v : word `i' of `pscore'
					xtile `prefix'_strata`i' = `v' if `touse' `supp1', nq(5)
					local bag `bag' `prefix'_strata`i'
				}
			} // if common
			else {
				forval i = 1/`Npscore' {
					local v : word `i' of `pscore'
					xtile `prefix'_strata`i' = `v' if `touse', nq(5)
					local bag `bag' `prefix'_strata`i'
				}
			} //if not common
		} // end nstrata with default (5) strata

		* get min/max support for later use in graphs
		forval i = 1/`Npscore' {
			local v : word `i' of `pscore'
			sum `v' if `prefix'_support==1 & `touse', meanonly
			local suppmin`i' = r(min)
			local suppmax`i' = r(max)
			ret scalar suppmin`i' = `suppmin`i''
			ret scalar suppmax`i' = `suppmax`i''
		}
		  
		* Generate weights *
		levelsof `treat' if `touse', local(treatment)								
		matrix input A = (`treatment')																	// generate matrix of treatment for parallel reference

		gen `prefix'_mmws =. if `touse'
		label var `prefix'_mmws "weights for nominal treatments"

		
		* common
		if ("`common'" != "") {
			local T=1	
			foreach s of varlist `prefix'_strata* {														// loop over each Strata
				local tr=el("A",1,`T')																	// map strata to treatment level derived above
		
				tab `s' if `touse' `supp1', matcell(f)													// get counts in each strata and generate matrix
				local sN = r(N)

				tab `s' if `treat'== `tr' `supp1' & `touse', matcell(f1)								// get counts in each strata/treatment and generate matrix
				local stN = r(N)

				local treatprop = `stN' / `sN'															// get proportion of treated within each strata (Pr=Z)
 
				matrix C = J(`=rowsof(f)' ,`=colsof(f)',0)												// generate a new matrix with weights for each strata/treatment
					forvalues i = 1/`=rowsof(f)' {
						forvalues j = 1/`=colsof(f)' {
						matrix C[`i',`j']= f[`i',`j']/f1[`i',`j'] * `treatprop'
						}
					}
				replace `prefix'_mmws = C[`s', 1] if `treat'==`tr'	& `touse'							// put weights in data file
				replace `prefix'_mmws = 0 if `prefix'_support != 1 & "`common'" != "" & `touse'
			local T=`T'+1
			} //close foreach s
		} //close common -- yes
		else {
			local T=1	
			foreach s of varlist `prefix'_strata* {														// loop over each Strata
				local tr=el("A",1,`T')																	// map strata to treatment level derived above
		
				tab `s' if `touse', matcell(f)															// get counts in each strata and generate matrix
				local sN = r(N)

				tab `s' if `treat'== `tr' & `touse', matcell(f1)										// get counts in each strata/treatment and generate matrix
				local stN = r(N)

				local treatprop = `stN' / `sN'															// get proportion of treated within each strata (Pr=Z)
 
				matrix C = J(`=rowsof(f)' ,`=colsof(f)',0)												// generate a new matrix with weights for each strata/treatment
					forvalues i = 1/`=rowsof(f)' {
						forvalues j = 1/`=colsof(f)' {
						matrix C[`i',`j']= f[`i',`j']/f1[`i',`j'] * `treatprop'
						}
					}
				replace `prefix'_mmws = C[`s', 1] if `treat'==`tr'	& `touse'							// put weights in data file
			local T=`T'+1
			} //close foreach s
		} // close common -- no
		
		* Generate IPTW weights for ATE
		if "`iptw'" != "" {
		gen `prefix'_iptw = . if `touse'
		label var `prefix'_iptw "IPTW weights for nominal treatment"
		
		tabulate `treat' if `touse'
		local trcount = r(r) 		
		
		forvalues x = 1/`trcount' {
			local tr=el("A",1,`x')																		// get treatment level value derived in levelsof above
			local v: word `x' of `pscore'																// get position of respective pscore
			replace `prefix'_iptw = 1/`v' if `treat' == `tr' & `touse'									// compute iptw based on respective treatment and pscore
		}	
		replace `prefix'_iptw = 0 if `prefix'_support !=1 & "`common'" != "" & `touse'
		}
	
		local mmws `prefix'_support `bag' `prefix'_mmws `prefix'_iptw
		char def _dta[`prefix'_mmws] "`mmws'" 

		* figure on or off common support *
		if ("`figure'" != "") {
			if ("`common'" != "") {
				forval i = 1/`Npscore' {
					local v : word `i' of `pscore'
					local fig fig`i'
					histogram `v' `supp', dens by(`treat', cols(1) legend(off)) xline(`suppmin`i'' `suppmax`i'') xla(0(.20)1) name(`fig', replace) nodraw kdensity 
					local figname `figname' `fig'	
				}
			}	
			else {
				forval i = 1/`Npscore' {
					local v : word `i' of `pscore'
					local fig fig`i'
					histogram `v', dens by(`treat', cols(1) legend(off)) xline(`suppmin`i'' `suppmax`i'') xla(0(.20)1) name(`fig', replace) nodraw kdensity 
					local figname `figname' `fig'	
				}
			}	
			graph combine `figname', altshrink name(combined, replace)
		} // end fig 
	
	
	} // Closing bracket for nominal treatments

} // Closing bracket for quietly

end

*! igeiset v 3
*! Pablo Mitnik
*!
*! Set estimates IGEs and computes appropriate confidence intervals. i.e. Imbens and Manski's (2004) and Nevo and Rosen's (2012)
*! confidence intervals for partially identified parameters
*!
*! Last updated Feb. 2019

program igeset, eclass

	version 13
	syntax varlist (min=2 max=2) [if] [in] [fw pw iw], insts(varlist fv) ige(string) [exvars(varlist fv) ci(string) gmm igmm Cluster(varlist) Level(cilevel) TECHnique(string) show]	
     
	/*1. Process and check inputs*/
	
	local cvar : word 1 of `varlist'
	local pvar : word 2 of `varlist'
	
	if "`ci'"=="" loca ci im
	
	if "`ige'" != "igeg" & "`ige'" != "igee" {
		di as error "ige option may only be igeg or igee"
		exit 198
	}
	
	if "`ci'" != "im" & "`ci'" != "nr" & "`ci'" != "imnr" {
		di as error "citype option may only be im or nr or imnr"
		exit 198
	}	
	
	if "`ige'"=="igeg" & "`technique'" != "" {
		di as error "option technique() can only be specified with option ige(igee)"
		exit 198
	}
	
	if "`ige'"=="igeg" {
		if "`gmm'"=="" {
			local est 2sls
			if "`igmm'"!="" {
				di as error "option igmm can only be specified with an gmm estimator"
				exit 198
			}
		}
		else if "`gmm'"!="" local est gmm
	}
	
	else if "`ige'"=="igee" local est gmm
	
	if `"`exp'"' != "" local wgt `"[`weight' `exp']"'
	else local wgt
	
	if "`ige'" == "igeg" local cmd regress
	else if "`ige'" == "igee" local cmd poisson
	
	if "`show'"=="" local mod qui
	else if "`show'"!="" local mod noi
	
	if "`ige'"=="igeg" local fullvar `pvar'
	else if "`ige'"=="igee" local fullvar `cvar':`pvar'
	
	marksample touse
	markout `touse' `cvar' `pvar' `exvars' `insts1' `cluster'
		
	/*2. Estimate upper bound*/
	
	if "`ige'"=="igee" | ("`ige'"=="igeg" & "`est'"=="gmm") {
	
		if "`cluster'" == "" local wmatrix robust
		else if "`cluster'" != "" local wmatrix cluster `cluster'
		local wm wmatrix(`wmatrix')	
		local clus
	}
	else if "`ige'"=="igeg" & "`est'"=="2sls" {
		local wm
		if "`cluster'" == "" local vce vce(robust)
		else if "`cluster'" != "" local vce vce(cluster `cluster')
	}		

	if "`technique'" != "" local tech technique(`technique')
	else if "`technique'" == "" {
		local tech
		if "`ige'"=="igee" local technique gn
	}
	
	if "`igmm'"!="" local gmmest igmm
	else if "`igmm'"=="" local gmmest
	
	if "`level'"=="" local lev
	else if "`level'"!="" local lev level(`level')
	
	`mod' iv`cmd' `est' `cvar' `exvars' (`pvar'  = `insts') `wgt' if `touse', `wm' `clus' `vce' `tech' `gmmest' `lev'
	
	tempname sub_pe sub_se 
	scalar `sub_pe' = _b[`fullvar']
	scalar `sub_se' = _se[`fullvar']
	
	local N_ub = e(N)
	
	/*3. Estimate lower bound*/
	
	if "`cluster'" == ""       `mod' `cmd' `cvar' `pvar' `exvars' `wgt' if `touse', robust `lev'
	else if "`cluster'" != ""  `mod' `cmd' `cvar' `pvar' `exvars' `wgt' if `touse', cluster(`cluster') `lev'
	
	tempname slb_pe slb_se 
	scalar `slb_pe' = _b[`fullvar']
	scalar `slb_se' = _se[`fullvar']
	
	local N_lb = e(N)
	
	if `N_lb' != `N_ub' {
		di as error "something went wrong, sample sizes do not match across the lower and upper bound models" /*debugging / just-in-case last check*/
		exit 198
	}
	
	local n = `N_lb'
	
	/*4. Compute confidence intervals*/
	
	if "`ci'"=="im" | "`ci'"=="imnr"  {
	
		/*Relative width*/

		global RW = (`sub_pe'  - `slb_pe') / max(`slb_se', `sub_se') 

		/*Compute c */

		tempvar Y 
		gen `Y' = 0
		qui replace `Y' = `level'/100 in 1
		qui nl igeset @ `Y', parameters(c) initial(c 1.64)
		tempname c ci_im_lb ci_im_ub
		scalar `c' = _b[_cons]		
		scalar `ci_im_lb' = `slb_pe' - `c' * `slb_se'
		scalar `ci_im_ub' = `sub_pe' + `c' * `sub_se'
	}
	
	if "`ci'"=="nr" | "`ci'"=="imnr"  {
	      
	      	tempname deltan pn k ci_nr_lb ci_nr_ub
	 	scalar `deltan' = `sub_pe' - `slb_pe'
		scalar `pn' = 1 - normal(ln(`n') * `deltan') * (1 - (`level'/100))
		scalar `k' = invnormal(`pn')
		
		scalar `ci_nr_lb' = `slb_pe' - `k' * `slb_se'
		scalar `ci_nr_ub' = `sub_pe' + `k' * `sub_se'	
		
	}    	

	/*5. ereturn and display results*/
	
	ereturn post

	if "`ige'"=="igeg" local rige IGE of geometric mean
	else if "`ige'"=="igee" local rige IGE of expectation
	
	ereturn scalar N = `n'
	
	ereturn scalar pe_lb = `slb_pe'
	ereturn scalar pe_ub = `sub_pe'

	if "`ci'"=="im" | "`ci'"=="imnr" {
		ereturn scalar ci_im_lb = `ci_im_lb'
		ereturn scalar ci_im_ub = `ci_im_ub' 
		ereturn scalar c = `c'
		 
	}
	if "`ci'"=="nr" | "`ci'"=="imnr" {
		ereturn scalar ci_nr_lb = `ci_nr_lb'
		ereturn scalar ci_nr_ub = `ci_nr_ub' 		
		ereturn scalar k = `k'
	}
	
	ereturn scalar confidence_level = `level'	
	
	if "`technique'"!="" ereturn local technique "`technique'"
	if "`cluster'"!="" ereturn local clustvar "`cluster'"
	if "`wgt'"!="" {
		ereturn local wtype "`weight'"
		ereturn local wexp "`exp'"
	}
	if "`est'"=="gmm" {
		if "`igmm'"=="" ereturn local gmmestimator "twostep"
		else if "`igmm'"!="" ereturn local gmmestimator "igmm"
	}
	ereturn local estimator "`est'"
	if "`exvars'"!= "" ereturn local exvars "`exvars'"
	ereturn local insts "`insts'"
	ereturn local pvar "`pvar'"
	ereturn local cvar "`cvar'"
	ereturn local ci "`ci'"
	ereturn local ige "`ige'"
	ereturn local cmd "igeset"		

	di as txt "{hline 70}"
	di as text "Partially identified `rige'"
	di as text ""
	di as text _col(6) "Set estimate" _col(31) as res %6.5f `slb_pe' _col(39) as res "- " %6.5f `sub_pe'
	if "`ci'"=="im" | "`ci'"=="imnr" di as text _col(6) "`level'% IM Conf. interval" _col(31) as res %6.5f `ci_im_lb' _col(39) as res "- " %6.5f `ci_im_ub'
	if "`ci'"=="nr" | "`ci'"=="imnr" di as text _col(6) "`level'% NR Conf. interval" _col(31) as res %6.5f `ci_nr_lb' _col(39) as res "- " %6.5f `ci_nr_ub'
	di as txt "{hline 70}"	
	if "`ci'"=="im" {
		di as txt "Notes:"
		di as txt "{p 0 2 0 60}The confidence interval is Imbens and Manski's (2004) confidence interval for a partially-identified parameter{p_end}"
		di as txt "{p 0 2 0 60}Uupper-bound estimate obtained with these instruments: `insts'{p_end}"
	}
	if "`ci'"=="nr" {
		di as txt "Notes:"
		di as txt "{p 0 2 0 60}The confidence interval is Nevo and Rosen's (2004: Sec. IV) confidence interval for a partially-identified parameter{p_end}"
		di as txt "{p 0 2 0 60}Uupper-bound estimate obtained with these instruments: `insts'{p_end}"
	}
	if "`ci'"=="imnr" {
		di as txt "Notes:"
		di as txt "{p 0 2 0 60}The IM and NR confidence intervals are Imbens and Manski's (2004) and Nevo and Rosen's (2012: Sec. IV) confidence intervals for a partially-identified parameter, respectively{p_end}"
		di as txt "{p 0 2 0 60}Uupper-bound estimate obtained with these instruments: `insts'{p_end}"	
	}
	
	di as txt ""

end

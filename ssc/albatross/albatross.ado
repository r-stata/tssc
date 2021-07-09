****ALBAtross plot .ado file****

*Uses Stata version 11.0
*Written by Sean Harrison, last updated 16/01/2017

capture program drop albatross
program define albatross
	set more off
	version 11
	*Macro drop, or global macros will persist after a failure
	macro drop small medium large ceiling range* ALBA*
	syntax varlist(min=3 max=3) [if] [in] , type(string) [by(varlist max=1) r(varlist max=1) sr(numlist max=1) BASEline(varlist max=1) SPROportion(numlist max=1) ///
	SBASEline(numlist max=1) sd(varlist max=1) sd1(varlist max=1) sd2(varlist max=1) ssd(numlist max=1) ssd1(numlist max=1) ssd2(numlist max=1) rr(varlist max=1) ///
	or(varlist max=1) CONtours(numlist min=1 max=3) TItle(string asis) SUBtitle(string asis) noGRaph ADjust noNOtes EFFect FIShers STOUFfers RAnge(varlist max=1) COLor tails(varlist max=1) ONEtailed] 
	tokenize `varlist'
	args n p e
	if "`contours'" !="" {
		tokenize `contours'
		global small `1'
		global medium `2'
		global large `3'
		global cons = 3
		if "$large" == "" {
			global large `2'
			global cons = 2
		}			
		if "$medium" == "" {
			global medium = `1'
			global large = `1'
			global cons = 1
		}
		if $small <= 0 {
			dis as err "Contours may not be negative or zero"
			exit
		}
		if $medium <= 0 {
			dis as err "Contours may not be negative or zero"
			exit
		}	
		if $large <= 0 {
			dis as err "Contours may not be negative or zero"
			exit
		}
		if ($small <= 1 | $medium <= 1 | $large <= 1) & ("`type'" == "OR" | "`type'" == "RR") {
			dis as err "Contours may not be less than or equal to 1 if using RRs and ORs"
			exit
		}
	}
	else {
		global cons = 3
	}
	
	*Drop the variables from existing ALBAtross plots
	foreach var in _P_graph _N_graph _N_adjusted _TOUSE {
		capture drop `var'
	}
	capture drop _EST_*
	capture drop _ALBA_*
	
	*Mark the sample
	mark _ALBA_TOUSE `if' `in'
	qui replace _ALBA_TOUSE = . if `n'==. | `p'==. | `e'==.	

********************************************************************************	
	**Check if variable input correct**
********************************************************************************	
	
	*Check if type() has been specifed correctly:
	if "`type'" != "mean" & "`type'" != "proportion" & "`type'" != "correlation" & "`type'" != "beta" & "`type'" != "md" & "`type'" != "smd" & "`type'" != "rr" & "`type'" != "or" {
		dis as err "type() incorrectly specified: use one of [Mean Proportion Correlation Beta MD SMD RR OR]"
		exit
	}
	
	*Check if N, P and E have been specified correctly:
	qui sum `n' if _ALBA_TOUSE == 1
	local studies_n = r(N)
	if r(min) < 1 {
		dis as err "All values of N must be above 1"
		exit
	}
	qui sum `p' if _ALBA_TOUSE == 1
	local studies_p = r(N)
	if `studies_p' == 0 {
		dis as err "No P values detected"
		exit
	}
	else if r(min) <=0 | r(max) > 1 {
		dis as err "All P values must be more than 0 and less than or equal to 1"
		exit
	}
	if "`tails'" != "" {
		qui sum `p' if _ALBA_TOUSE == 1 & `tails' == 1
		if r(max) == 1 {
			dis as err "One-Tailed P values must be less than 1"
			exit
		}
	}
	
	qui count if `e' > 0 & `e'<. & _ALBA_TOUSE == 1
	local e_n = r(N)
	qui count if `e' < 0 & _ALBA_TOUSE == 1
	local e_n = `e_n' + r(N)
	if `e_n' < `studies_p' { 
		dis as err "Not all studies have an effect direction; use positive numbers for positive effect directions and negative numbers for negative effect directions"
		exit
	}
	if `e_n' > `studies_p' { 
		dis as err "There are more studies with effect directions than studies with both N (number of participants) and P (P values)"
		exit
	}
	
	if "`sbaseline'" !="" {
		if `sbaseline'<=0 | `sbaseline'>=1 {
			dis as err "Sbaseline cannot be outside the range 0 to 1"
			exit
		}
	}
	
	if "`sr'" !="" {
		if `sr'==0 {
			dis as err "Sr cannot be 0"
			exit
		}
	}
	
	if "`ssd'" !="" {
		if `ssd'<=0 {
			dis as err "SSD cannot be less than or equal to 0"
			exit
		}
	}
	
	if "`ssd1'" !="" {
		if `ssd1'<=0 {
			dis as err "SSD1 cannot be less than or equal to 0"
			exit
		}
	}		

	if "`ssd2'" !="" {
		if `ssd2'<=0 {
			dis as err "SSD2 cannot be less than or equal to 0"
			exit
		}
	}
	
	if "$small" != ""{
		if $small==0 {
			dis as err "Contours cannot be 0"
			exit
		}
	}		

	if "$medium" != ""{
		if $medium==0 {
			dis as err "Contours cannot be 0"
			exit
		}
	}	
	
	if "$large" != ""{
		if $large==0 {
			dis as err "Contours cannot be 0"
			exit
		}
	}
	
	*SDs cannot have negative values
	foreach var in `sd' `sd1' `sd2' {
		if "`var'" != "" {
			qui sum `var' if _ALBA_TOUSE == 1
			if r(min)<=0 {
				dis as err "Standard deviations cannot be equal to or less than 0"
				exit
			}
		}
	}	
	
	*Baselines cannot have values outside 0-1
	foreach var in `baseline' {
		if "`var'" != "" {
			qui sum `var' if _ALBA_TOUSE == 1
			if r(min)<=0 | r(max)>=1 {
				dis as err "Baselines cannot be outside the range 0 to 1"
				exit
			}
		}
	}	
	
	*Check that additional info has been supplied
	
	*Means need SD or SSD
	if "`type'" == "mean" & "`sd'" == "" & "`ssd'" == "" {
		dis as err "SD or standardised SD (sSD) must be defined in options if using means"
		exit
	}
	
	*MDs need SD or SD1 & SD2 or SSD
	if "`type'" == "md" & "`sd'" == "" & ("`sd1'" == "" | "`sd2'"=="") & "`ssd'" == "" & ("`ssd1'" == "" | "`ssd2'"=="") {
		dis as err "SD, standardised SD (sSD), SD1 and SD2, or SSD1 and SSD2 must be defined in options when using mean differences"
		exit
	}
	
	*RRs and ORs need baseline variable or standardised baseline (assumed to be true in all studies)
	if ("`type'" == "rr" | "`type'" == "or") & "`baseline'" == "" & "`sbaseline'" == "" {
		dis as err "Baseline risk variable or standard baseline risk must be defined in options when using risk ratios or odds ratios"
		exit
	}

	*Standard baseline risk will be mean of baseline risk if not specified
	if  ("`type'" == "rr" | "`type'" == "or") & "`sbaseline'" == "" { 
		qui sum `baseline' if _ALBA_TOUSE == 1
		local sbaseline = r(mean)
	}	
	
	*Baseline needs to be estimated from sbaseline if baseline not specified
	if "`baseline'" == "" & ("`type'" == "rr" | "`type'" == "or") {
		qui gen _ALBA_baseline = `sbaseline'
		local baseline = "_ALBA_baseline"
	}
	
	*Standard r (ratio) will be assumed to be 1 unless specified
	if ("`type'" == "md" | "`type'" == "smd" |  "`type'" == "rr" | "`type'" == "or") & "`sr'" == "" {
		local sr = 1
	}
	
	*r will be assumed to be 1 in all studies unless specified otherwise in sr()
	if "`r'"=="" & ("`type'" == "md" | "`type'" == "smd" |  "`type'" == "rr" | "`type'" == "or") {
		qui gen _ALBA_r = `sr'
		local r = "_ALBA_r"
	}	
	
	*Sproportion will be assume to be 0.5 unless specified in sproportion()
	if "`sproportion'" == "" & "`type'" == "proportion" {
		local sproportion = 0.5
	}
	
	*SSD will be weighted mean of SD variable (or mean of SD1 and SD2 or SSD1 and SSD2) if not specified in ssd() or ssd1() and ssd2()
	if "`type'" == "md" & "`ssd'" == "" & "`ssd1'" == "" & "`ssd2'"=="" {
		*If the SD variable is specified, take the SSD from that
		if "`sd'" != "" {
			qui gen _ALBA_sd = `n'*`sd'^2
			qui sum _ALBA_sd if _ALBA_TOUSE == 1
			local n_sd2 = r(sum)
			qui sum `n' if _ALBA_TOUSE == 1
			local ssd = sqrt(`n_sd2'/r(sum))
			qui drop _ALBA_sd
		}
		*If the SD variable is NOT specified then assume SD1 and SD2 variable are specified, and the R variable is not specified - generate ssd1 and ssd2
		else if "`sd'" == "" & "`r'" == "" {
			qui gen _ALBA_sd1 = `n'*`sd1'^2/2
			qui sum _ALBA_sd1 if _ALBA_TOUSE == 1
			local n_sd2_1 = r(sum)
			qui sum `n' if _ALBA_TOUSE == 1
			local ssd1 = sqrt((`n_sd2_1')*2/r(sum))
			qui drop _ALBA_sd1
			
			qui gen _ALBA_sd2 = `n'*`sd2'^2/2
			qui sum _ALBA_sd2 if _ALBA_TOUSE == 1
			local n_sd2_2 = r(sum)			
			qui sum `n' if _ALBA_TOUSE == 1
			local ssd2 = sqrt((`n_sd2_2')*2/r(sum))
			qui drop _ALBA_sd2
		}
		*If the SD variable is NOT specified then assume SD1 and SD2 variables are specified, and the R variable IS specified (as above if not) - generate ssd1 and ssd2
		else {
			qui gen _ALBA_sd1 = `r'*`n'*`sd1'^2/(`r'+1)
			qui sum _ALBA_sd1 if _ALBA_TOUSE == 1
			local n_sd2_1 = r(sum)
			qui sum `n' if _ALBA_TOUSE == 1
			local ssd1 = sqrt((`n_sd2_1')*(`r'+1)/r(sum))
			qui drop _ALBA_sd1
			
			qui gen _ALBA_sd2 = `n'*`sd2'^2/(`r'+1)
			qui sum _ALBA_sd2 if _ALBA_TOUSE == 1
			local n_sd2_2 = r(sum)			
			qui sum `n' if _ALBA_TOUSE == 1
			local ssd2 = sqrt((`n_sd2_2')*(`r'+1)/r(sum))
			qui drop _ALBA_sd2
		}
	}
	
	*And for Means
	if "`type'" == "mean" & "`ssd'" == "" {
		qui gen _ALBA_sd = `n'*`sd'^2
		qui sum _ALBA_sd if _ALBA_TOUSE == 1
		local n_sd2 = r(sum)
		qui sum `n' if _ALBA_TOUSE == 1
		local ssd = sqrt(`n_sd2'/r(sum))
		qui drop _ALBA_sd
	}
	
	*Generate estimates of RR and OR (if not suppled); assume some values might be missing and run through all and replace estimates with actual values if there
	if "`type'" == "rr" {
		rr_estimation `n' `p' `e' , r(`r') sr(`sr') baseline(`baseline') sbaseline(`sbaseline')
		if "`rr'" != "" {
			qui replace _ALBA_rr = `rr' if `rr' != .
		}
		local rr "_ALBA_rr"
	}
	if "`type'" == "or" {
		or_estimation `n' `p' `e' , r(`r') sr(`sr') baseline(`baseline') sbaseline(`sbaseline')
		if "`or'" != "" {
			qui replace _ALBA_or = `or' if `or' != .
		}
		local or "_ALBA_or"
	}
	
	*Generate Z value for study P values (z)
	qui gen _ALBA_z = invnormal(`p'/2) if _ALBA_TOUSE == 1
	*For one-tailed P values convert to 2-tailed
	if "`tails'" != "" {
		qui replace _ALBA_z = invnormal(`p') if _ALBA_TOUSE == 1 & `tails' == 1 & `p'<=0.5
		qui replace _ALBA_z = -invnormal(1-`p') if _ALBA_TOUSE == 1 & `tails' == 1 & `p'>0.5	
	}
	qui replace _ALBA_z = -_ALBA_z if `e'<0
	
	*Tails don't have to be specified; generate an ALBA variable for tails if onetailed is specified but tails are not
	*Assume all P values are one-tailed
	if "`onetailed'" == "onetailed" {
		if "`tails'" == "" {
			qui gen _ALBA_tails = 1 if _ALBA_TOUSE == 1
			local tails = "_ALBA_tails"
		}
	}
	
	*Generate estimates of small, medium and large for the contours (if not specified)
	if "$small" == "" {
		specify_`type' `n' `p' `e' , r(`r') sd(`sd') sd1(`sd1') sd2(`sd2') sr(`sr') ssd(`ssd') ssd1(`ssd1') ssd2(`ssd2') sbaseline(`sbaseline') baseline(`baseline') sproportion(`sproportion') rr(`rr') or(`or')
	}
	*Adjustment of original number of participants
	if "`adjust'" == "adjust" & ("`type'" == "mean" | "`type'" == "md" | "`type'" == "smd" | "`type'" == "rr" |"`type'" == "or") {
		ALBA_adjustment_`type' `n' `p' `e' , sd(`sd') sd1(`sd1') sd2(`sd2') ssd(`ssd') ssd1(`ssd1') ssd2(`ssd2') baseline(`baseline') sbaseline(`sbaseline') r(`r') sr(`sr') rr(`rr') or(`or')
		local n "_ALBA_N_adjusted"
	}
********************************************************************************	
	**Checks complete**
********************************************************************************	
	
********************************************************************************	
	**Effect contour equation generation**
********************************************************************************
	
	*Generate the effect contour equations for the specifed type
	*Contour effect values generated from data if small/medium/large values not supplied
	
	*Calculate largest scaled P value for smallest P to set x-axis range
	qui sum _ALBA_z if _ALBA_TOUSE == 1
	*Convert Z to two-tailed P to find smallest P (if it happens to be one-tailed >0.5)
	if r(max)>=abs(r(min)) {
		local smallest_p = 2*normal(-r(max))
	}
	else {
		local smallest_p = 2*normal(r(min))
	}
	global ceiling = ceil(log10((1/`smallest_p')))
	global ceiling = ceil($ceiling)
	
	*Find the upper limit of the y-axis
	qui sum `n' if _ALBA_TOUSE == 1
	local max_participants = r(max)
	foreach val in 10000000 5000000 2000000 1000000 500000 200000 100000 50000 20000 10000 5000 2000 1000 500 200 100 {
		if `max_participants'<(`val'-5) {
			global most_participants = `val'
		}
	}
	
	*Generate the local effect contour equations
	program_`type', small($small) medium($medium) large($large) ssd(`ssd') ssd1(`ssd1') ssd2(`ssd2') sr(`sr') sbaseline(`sbaseline') sproportion(`sproportion') 


	
********************************************************************************
   **Effect contour equations created**
********************************************************************************	
	
********************************************************************************	
	**Data rescaling**
********************************************************************************	
	
	*Data needs to be rescaled to fit graph
	qui gen _ALBA_P_data = log10(1/(2*normal(-abs(_ALBA_z)))) if _ALBA_TOUSE == 1
	qui replace _ALBA_P_data = -_ALBA_P_data if `e'<0 & _ALBA_TOUSE == 1
	if "`tails'" != "" {
		qui replace _ALBA_P_data = -_ALBA_P_data if `tails' == 1 & `p' > 0.5 & _ALBA_TOUSE == 1	
	}
	qui gen _ALBA_N_data = log10(`n')^2 if _ALBA_TOUSE == 1
	
	*For the one-tailed graph, just halve all the P values in the calculation
	*Note: as the P values are all directional this is fine
	if "'onetailed'" =="onetailed" {
		qui replace _ALBA_P_data = log10(1/(normal(-abs(_ALBA_z))))-0.3 if _ALBA_TOUSE == 1
		qui replace _ALBA_P_data = -_ALBA_P_data if `e'<0 & _ALBA_TOUSE == 1
		qui replace _ALBA_P_data = -_ALBA_P_data if `tails' == 1 & `p' > 0.5 & _ALBA_TOUSE == 1	
	}
	
********************************************************************************	
	**Data rescaling complete**
********************************************************************************

********************************************************************************	
	**Fisher's and Stouffer's**
********************************************************************************			

*Fisher's combination Chi squared test stat is -2*sum(ln(pi)) with 2k degrees of freedom
if "`fishers'" != "" {
	qui gen _ALBA_P_left = normal(-_ALBA_z) if _ALBA_TOUSE == 1
	qui gen _ALBA_P_right = normal(_ALBA_z) if _ALBA_TOUSE == 1
	qui replace _ALBA_P_left = ln(_ALBA_P_left) if _ALBA_TOUSE == 1
	qui replace _ALBA_P_right = ln(_ALBA_P_right) if _ALBA_TOUSE == 1	
	qui sum _ALBA_P_left if _ALBA_TOUSE == 1
	local k = r(N)*2
	local sum = -2*r(sum)
	local chi_left = 1-chi2(`k',`sum')

	qui sum _ALBA_P_right
	local k = r(N)*2
	local sum = -2*r(sum)
	local chi_right = 1-chi2(`k',`sum')
	dis "Fisher's method (left): " %9.3e `chi_left'
	dis "Fisher's method (right): " %9.3e `chi_right'
	drop _ALBA_P_left _ALBA_P_right
}

if "`stouffers'" != "" {
	qui gen _ALBA_P_left = -_ALBA_z if _ALBA_TOUSE == 1
	qui gen _ALBA_P_right = _ALBA_z if _ALBA_TOUSE == 1
	qui sum _ALBA_P_left if _ALBA_TOUSE == 1
	local k = sqrt(r(N))
	local sum = r(sum)
	local p_left = normal(`sum'/`k')

	qui sum _ALBA_P_right
	local k = sqrt(r(N))
	local sum = r(sum)
	local p_right = normal(`sum'/`k')
	dis "Stouffer's method (left): " %9.3e `p_left'
	dis "Stouffer's method (right): " %9.3e `p_right'
	drop _ALBA_P_left _ALBA_P_right
}


********************************************************************************	
	**End of Fisher's and Stouffer's**
********************************************************************************	

********************************************************************************	
	**Exit if nograph specified**
********************************************************************************	

	*Exit if nograph option specified
	if "`graph'" == "nograph" {
		dis "**Nograph specified, no graph produced**"
		foreach var in _ALBA_z _ALBA_rr _ALBA_or _ALBA_r _ALBA_baseline _ALBA_tails {
			capture drop `var'
		}
		foreach var in _P_data _N_data {
			rename _ALBA`var' `var'
		}
		capture rename _ALBA_N_adjusted _N_adjusted
		if "`adjust'" != "adjust" {
			capture drop _N_adjusted
		}
		rename _P_data _P_graph
		rename _N_data _N_graph
		rename _ALBA_TOUSE _TOUSE
		
		if "`effect'" != "effect" {
			capture drop _EST_*
		}
		
		*Format all standardised local variables
		foreach var in ssd ssd1 ssd2 sbaseline sr sproportion {
			if "``var''" != "" {
				local `var' = round(``var'',0.01)
			}
		}
		
		*Message detailing adjustments (if any)		
		if "`adjust'" == "adjust" {
			if "`type'" == "mean" {
				if "`ssd'" !="" & "`sd'"!="" {
					dis "***Number of participants adjusted for a standard deviation of `ssd'***"
				}
			}
			if "`type'" == "md" {
				if "`sd'" !="" & "`sd1'" == "" {
					dis "***Number of participants adjusted for a pooled standard deviation of `ssd'***"
				}
				if "`sd1'" !="" {
					dis "***Number of participants adjusted for a standard deviation of `ssd1' in exposed and `ssd2' in unexposed***"
				}
			}
			if "`type'" == "smd" {
				if "`sr'" !="" {
					dis "***Number of participants adjusted for a ratio of group sizes (r) of `sr'***"
				}
			}
			if "`type'" == "rr" {
				if "`sr'" !="" {
					if "`sbaseline'" !="" {
						dis "***Number of participants adjusted for a baseline risk of `sbaseline' and a ratio of group sizes (r) of `sr'***"
					}
					else {
						dis "***Number of participants adjusted for a ratio of group sizes (r) of `sr'***"
					}
				}
				if "`sbaseline'" !="" & "`sr'"==""  {
					dis "***Number of participants adjusted for a baseline risk of `sbaseline'***"
				}
			}
			if "`type'" == "or" {
				if "`sr'" !="" {
					if "`sbaseline'" !="" {
						dis "***Number of participants adjusted for a baseline risk of `sbaseline' and a ratio of group sizes (r) of `sr'***"
					}
					else {
						dis "***Number of participants adjusted for a ratio of group sizes (r) of `sr'***"
					}
				}
				if "`sbaseline'" !="" & "`sr'"=="" {
					dis "***Number of participants adjusted for a baseline risk of `sbaseline'***"
				}
			}
		}	
		macro drop small medium large ceiling range* ALBA*	
		exit
	}

********************************************************************************	
	**End of nograph specified**
********************************************************************************		

********************************************************************************	
	**Define the two-tailed axes labels**
********************************************************************************	

	*Graph
	*Need to know the maximum value on x-axis, and thus how many labels it needs (from $ceiling)
	local max_xlabel = $ceiling
	
	*Define the X axis label (`"`xlabel'"')
	local space = " "
	local quote = char(34)
	local xlabel "-1.3 `quote'0.05`quote' 0 `quote'1`quote' 1.3 `quote'0.05`quote'"
	local add = 0
	if "`onetailed'" == "onetailed" {
		local xlabel "-1 `quote'0.05`quote' 0 `quote'0.5`quote' 1 `quote'0.95`quote'"
		local add = -0.3
	}
	
	*Xline (Basic)
	local xline "-2 -1.3 0 1.3 2"
	if "`onetailed'" == "onetailed" {
		local xline "-2.3 -1 0 1 2.3"
	}
	
	*P values 10^-2 to 10^-5
	if `max_xlabel'>=2 & `max_xlabel' <= 5 {

	*Positive section
		forvalues num = 2 (1) `max_xlabel' {
			local p_g = 1/10^`num'
			if "`onetailed'" == "onetailed" {
				local p_g = 1-1/10^`num'
			}
			local num2 = `num'+1
			local num3 = `num'+`add'
			local p_g: dis %`num2'.`num'f `p_g'
			local xlab`num' " `num3' `quote'`p_g'`quote'"
			local xlabel "`xlabel'`xlab`num''"
		}
	*Negative selection
		forvalues num = 2 (1) `max_xlabel' {
			local p_g = 1/10^`num'
			local num2 = `num'+1
			local num3 = `num'+`add'
			local p_g: dis %`num2'.`num'f `p_g'
			local xlab`num' "-`num3' `quote'`p_g'`quote' "
			local xlabel "`xlab`num''`xlabel'"
		}
	*Xline
		local xline "-1.3 0 1.3"
		if "`onetailed'" == "onetailed" {
			local xline "-1 0 1"
		}
		forvalues num = 2 (1) `max_xlabel' {
			local num3 = `num'+`add'
			local xline "`xline' `num3'"
		}
		forvalues num = 2 (1) `max_xlabel' {
			local num3 = `num'+`add'
			local xline "-`num3' `xline'"
		}
	}
	
	*P values 10^-5 to 10^-10
	else if `max_xlabel'>5 & `max_xlabel' <= 10 {
	local xlabel "0 `quote'1`quote'"
	if "`onetailed'" == "onetailed" {
		local xlabel "0 `quote'0.5`quote'"
	}

	*Positive section
	forvalues num = 2 (1) 4 {
			local p_g = 1/10^`num'
			if "`onetailed'" == "onetailed" {
				local p_g = 1-1/10^`num'
			}
			local num2 = `num'+1
			local num3 = `num'+`add'
			local p_g: dis %`num2'.`num'f `p_g'
			local xlab`num' " `num3' `quote'`p_g'`quote'"
			local xlabel "`xlabel'`xlab`num''"
		}
		forvalues num = 5 (1) `max_xlabel' {
			local p_g = "10^-`num'"
			if "`onetailed'" == "onetailed" {
				local p_g = "1-10^-`num'"
			}
			local num3 = `num'+`add'
			local xlab`num' " `num3' `quote'`p_g'`quote'"
			local xlabel "`xlabel'`xlab`num''"
		}
	
	*Negative selection
		forvalues num = 2 (1) 4 {
			local p_g = 1/10^`num'
			local num2 = `num'+1
			local num3 = `num'+`add'
			local p_g: dis %`num2'.`num'f `p_g'
			local xlab`num' "-`num3' `quote'`p_g'`quote' "
			local xlabel "`xlab`num''`xlabel'"
		}
		forvalues num = 5 (1) `max_xlabel' {
			local p_g = "10^-`num'"
			local num3 = `num'+`add'
			local xlab`num' "-`num3' `quote'`p_g'`quote' "
			local xlabel "`xlabel'`xlab`num''"
		}
	*Xline
		local xline "0"
		forvalues num = 2 (1) 4 {
			local num3 = `num'+`add'
			local xline "`xline' `num3'"
		}
		forvalues num = 5 (1) `max_xlabel' {
			local num3 = `num'+`add'
			local xline "`xline' `num3'"
		}	
		forvalues num = 2 (1) 4 {
			local num3 = `num'+`add'
			local xline "-`num3' `xline'"
		}
		forvalues num = 5 (1) `max_xlabel' {
			local num3 = `num'+`add'
			local xline "-`num3' `xline'"
		}
	}
	
	*P values 10^-10 to 10^-20	
	else if `max_xlabel'>10 & `max_xlabel' <= 20 {
	local xlabel "0 `quote'1`quote'"
	if "`onetailed'" == "onetailed" {
		local xlabel "0 `quote'0.5`quote'"
	}
	
	*Positive section
		forvalues num = 2 (2) 4 {
			local p_g = 1/10^`num'
			if "`onetailed'" == "onetailed" {
				local p_g = 1-1/10^`num'
			}
			local num2 = `num'+1
			local num3 = `num'+`add'
			local p_g: dis %`num2'.`num'f `p_g'
			local xlab`num' " `num3' `quote'`p_g'`quote'"
			local xlabel "`xlabel'`xlab`num''"
		}
		forvalues num = 6 (2) `max_xlabel' {
			local p_g = "10^-`num'"
			if "`onetailed'" == "onetailed" {
				local p_g = "1-10^-`num'"
			}
			local num3 = `num'+`add'
			local xlab`num' " `num3' `quote'`p_g'`quote'"
			local xlabel "`xlabel'`xlab`num''"
		}
	
	*Negative selection
		forvalues num = 2 (2) 4 {
			local p_g = 1/10^`num'
			local num2 = `num'+1
			local num3 = `num'+`add'
			local p_g: dis %`num2'.`num'f `p_g'
			local xlab`num' "-`num3' `quote'`p_g'`quote' "
			local xlabel "`xlab`num''`xlabel'"
		}
		forvalues num = 6 (2) `max_xlabel' {
			local p_g = "10^-`num'"
			local num3 = `num'+`add'
			local xlab`num' "-`num3' `quote'`p_g'`quote' "
			local xlabel "`xlabel'`xlab`num''"
		}
	*Xline
		local xline "0"
		forvalues num = 2 (2) 4 {
			local num3 = `num'+`add'
			local xline "`xline' `num3'"
		}
		forvalues num = 6 (2) `max_xlabel' {
			local num3 = `num'+`add'
			local xline "`xline' `num3'"
		}
		forvalues num = 2 (2) 4 {
			local num3 = `num'+`add'
			local xline "-`num3' `xline'"
		}		
		forvalues num = 6 (2) `max_xlabel' {
			local num3 = `num'+`add'
			local xline "-`num3' `xline'"
		}
	}

	*P values 10^-20 to 10^-40	(note: 10^-38 is the smallest number Stata can handle with doubles (usual for decimals))
	else if `max_xlabel'>20 & `max_xlabel'<=40 {
	local xlabel "0 `quote'1`quote'"
	if "`onetailed'" == "onetailed" {
		local xlabel "0 `quote'0.5`quote'"
	}
	
	*Positive section
		forvalues num = 4 (4) `max_xlabel' {
			local p_g = "10^-`num'"
			if "`onetailed'" == "onetailed" {
				local p_g = "1-10^-`num'"
			}
			local num3 = `num'+`add'
			local xlab`num' " `num3' `quote'`p_g'`quote'"
			local xlabel "`xlabel'`xlab`num''"
		}
	
	*Negative selection
		forvalues num = 4 (4) `max_xlabel' {
			local p_g = "10^-`num'"
			local num3 = `num'+`add'
			local xlab`num' "-`num3' `quote'`p_g'`quote' "
			local xlabel "`xlabel'`xlab`num''"
		}
	*Xline
		local xline "0"
		forvalues num = 4 (4) `max_xlabel'  {
			local num3 = `num'+`add'
			local xline "`xline' `num3'"
		}
		forvalues num = 4 (4) `max_xlabel' {
			local num3 = `num'+`add'
			local xline "-`num3' `xline'"
		}
	}

	*P values 10^-40 and beyond
	else if `max_xlabel'>40 {
	local xlabel "0 `quote'1`quote'"
	if "`onetailed'" == "onetailed" {
		local xlabel "0 `quote'0.5`quote'"
	}
	
	*Positive section
		forvalues num = 5 (5) `max_xlabel' {
			local p_g = "10^-`num'"
			if "`onetailed'" == "onetailed" {
				local p_g = "1-10^-`num'"
			}
			local num3 = `num'+`add'
			local xlab`num' " `num3' `quote'`p_g'`quote'"
			local xlabel "`xlabel'`xlab`num''"
		}
	
	*Negative selection
		forvalues num = 5 (5) `max_xlabel' {
			local p_g = "10^-`num'"
			local num3 = `num'+`add'1
			local xlab`num' "-`num3' `quote'`p_g'`quote' "
			local xlabel "`xlabel'`xlab`num''"
		}
	*Xline
		local xline "0"
		forvalues num = 5 (5) `max_xlabel' {
			local num3 = `num'+`add'
			local xline "`xline' `num3'"
		}
		forvalues num = 5 (5) `max_xlabel' {
			local num3 = `num'+`add'
			local xline "-`num3' `xline'"
		}
	}	

	
********************************************************************************
***Y axis labels***
********************************************************************************

	*Define the Y axis label (`"`ylabel'"')
	local max_ylabel = log10($most_participants)^2
	local ylabel "0 `quote'1`quote' 1 `quote'10`quote' 4 `quote'100`quote'"
	local yline "1 4"
	if `max_ylabel'>=4 & `max_ylabel'<7 {
		local label_add " 5.29 `quote'200`quote'"
		local ylabel "`ylabel'`label_add'"
		local yline "`yline' 5.29"
	}
	if `max_ylabel'>=7 & `max_ylabel' < 24 {
		local label_add " 7.28 `quote'500`quote'"
		local ylabel "`ylabel'`label_add'"
		local yline "`yline' 7.28"
	}
	if `max_ylabel'>=8 {
		local label_add " 9 `quote'1,000`quote'"
		local ylabel "`ylabel'`label_add'"
		local yline "`yline' 9"
	}
	if `max_ylabel'>=10 & `max_ylabel'<13 {
		local label_add " 10.9 `quote'2,000`quote'"
		local ylabel "`ylabel'`label_add'"
		local yline "`yline' 10.9"
	}	
	if `max_ylabel'>=13 & `max_ylabel'<24 {
		local label_add " 13.68 `quote'5,000`quote'"
		local ylabel "`ylabel'`label_add'"
		local yline "`yline' 13.68"
	}
	if `max_ylabel'>=15 {
		local label_add " 16 `quote'10,000`quote'"
		local ylabel "`ylabel'`label_add'"
		local yline "`yline' 16"
	}
	if `max_ylabel'>=18 & `max_ylabel'<21 {
		local label_add " 18.5 `quote'20,000`quote'"
		local ylabel "`ylabel'`label_add'"
		local yline "`yline' 18.5"
	}	
	if `max_ylabel'>=21 & `max_ylabel'<35 {
		local label_add " 22.08 `quote'50,000`quote'"
		local ylabel "`ylabel'`label_add'"
		local yline "`yline' 22.08"
	}
	if `max_ylabel'>=24 {
		local label_add " 25 `quote'100,000`quote'"
		local ylabel "`ylabel'`label_add'"
		local yline "`yline' 25"
	}
	if `max_ylabel'>=27 & `max_ylabel'<32 {
		local label_add " 28.1 `quote'200,000`quote'"
		local ylabel "`ylabel'`label_add'"
		local yline "`yline' 28.1"
	}		
	if `max_ylabel'>=32 & `max_ylabel'<35 {
		local label_add " 32.5 `quote'500,000`quote'"
		local ylabel "`ylabel'`label_add'"
		local yline "`yline' 32.5"
	}
	if `max_ylabel'>=35 {
		local label_add " 36 `quote'1,000,000`quote'"
		local ylabel "`ylabel'`label_add'"
		local yline "`yline' 36"
	}
	
	if `max_ylabel'>=38 & `max_ylabel'<43 {
		local label_add " 39.7 `quote'2,000,000`quote'"
		local ylabel "`ylabel'`label_add'"
		local yline "`yline' 39.7"
	}		
	if `max_ylabel'>=43 & `max_ylabel'<48 {
		local label_add " 44.88 `quote'5,000,000`quote'"
		local ylabel "`ylabel'`label_add'"
		local yline "`yline' 44.88"
	}
	if `max_ylabel'>=48 {
		local label_add " 49 `quote'10,000,000`quote'"
		local ylabel "`ylabel'`label_add'"
		local yline "`yline' 49"
	}	
	
********************************************************************************	
	**End of define the axes labels**
********************************************************************************		

********************************************************************************	
	**Formatting and notes**
********************************************************************************	
	
	*Format small/medium/large to have a 0 in front (so .3 to 0.3)
	if $small<1 & $small >=0 {
		global small: dis %3.2f $small
	}
	
	if $medium<1 & $medium >=0 {
		global medium: dis %3.2f $medium
	}
	
	if $large<1 & $large >=0 {
		global large: dis %3.2f $large
	}

	*Format all standardised local variables
	foreach var in ssd ssd1 ssd2 sbaseline sr sproportion {
		if "``var''" != "" {
			local `var' = round(``var'',0.01)
			local `var': dis %3.2f ``var''
		}
	}

	*Add a note to show standardised values used in calculation of effect contours
	*Need to get rid of quotes in strings in IF commands
	if "`notes'" != "nonotes" {
		if "`if'"!="" | "`in'"!="" {
			local if3 = subinstr(`"`if'"',char(34),"",.)	
			local ifin = "Restricted to: `if3'`in'"
		}
		else {
			local ifin = ""
		}
	
		if "`by'"!="" {
			if "`ifin'" != "" {
				local ifin = "`ifin'. Grouped by: `by'"
			}
			else {
				local ifin = "Grouped by: `by'"
			}
		}
	
		if "`type'" == "mean" {
			local note = "Effect contours drawn using a standard deviation of `ssd'"
			if "`adjust'" != "adjust" | "`sd'"=="" { 
				local caption = "`ifin'"
			}
			else {
				local caption = "Effective sample size used (data adjusted for standard deviation). `ifin'"
			}
		}

		if "`type'" == "proportion" {
			local note = "Effect contours drawn using a standard proportion of `sproportion'"
		}	
	
		if "`type'" == "md" {
			if "`sd'" != "" {
				local note = "Effect contours drawn using a pooled standard deviation of `ssd' and ratio of group sizes (r) of `sr'"
				if "`adjust'" != "adjust" { 
					local caption = "`ifin'"
				}
				else if "`r'" != "_ALBA_r" {
					local caption = "Effective sample size used (data adjusted for pooled standard deviation and a ratio of group sizes (r)). `ifin'"
				}
				else {
					local caption = "Effective sample size used (data adjusted for pooled standard deviation). `ifin'"
				}
			}
			else if "`sd1'"!="" & "`sd2'"!="" {
				local note = "Effect contours drawn using a standard deviation of `ssd1' in group 1 and `ssd2' in group 2 and a ratio of group sizes (r) of `sr'"
				if "`adjust'" != "adjust" { 
					local caption = "`ifin'"
				}
				else if "`r'" != "_ALBA_r" {
					local caption = "Effective sample size used (data adjusted for group standard deviations and ratio of group sizes (r)). `ifin'"
				}
				else {
					local caption = "Effective sample size used (data adjusted for group standard deviations). `ifin'"
				}
			}
			else if "`ssd'" != "" & "`sd'"=="" {
				local note = "Effect contours drawn using a pooled standard deviation of `ssd' and a ratio of group sizes (r) of `sr'"
				if "`adjust'" != "adjust" { 
					local caption = "`ifin'"
				}
				else if "`r'" != "_ALBA_r" {
					local caption = "Effective sample size used (data adjusted for ratio of group sizes (r)). `ifin'"
				}
				else {
					local caption = "`ifin'"
				}
			}
			else if "`ssd1'" != "" & "`ssd2'" != "" & "`sd'"=="" {
				local note = "Effect contours drawn using a standard deviation of `ssd1' in group 1 and `ssd2' in group 2 and a ratio of group sizes (r) of `sr'"
				if "`adjust'" != "adjust" { 
					local caption = "`ifin'"
				}
				else if "`r'" != "_ALBA_r" {
					local caption = "Effective sample size used (data adjusted for ratio of group sizes (r)). `ifin'"
				}
				else {
					local caption = "`ifin'"
				}
			}		
		}
	
		if "`type'" == "smd" {
			local note = "Effect contours drawn using a ratio of group sizes (r) of `sr'"
			if "`adjust'" != "adjust" { 
				local caption = "`ifin'"
			}
			else if "`r'" != "_ALBA_r" {
				local caption = "Effective sample size used (data adjusted for ratio of group sizes (r)). `ifin'"
			}
			else {
				local caption = "`ifin'"
			}
		}
	
		if "`type'" == "rr" {
			local note = "Effect contours drawn using a baseline risk of `sbaseline' and a ratio of group sizes (r) of `sr'"
			if "`adjust'" != "adjust" { 
				local caption = "`ifin'"
			}
			else if "`r'" != "_ALBA_r" {
				local caption = "Effective sample size used (data adjusted for baseline risk and ratio of group sizes (r)). `ifin'"
			}
			else {
				local caption = "Effective sample size used (data adjusted for baseline risk). `ifin'"
			}
		}
	
		if "`type'" == "or" {
			local note = "Effect contours drawn using a baseline risk of `sbaseline' and a ratio of group sizes (r) of `sr'"
			if "`adjust'" != "adjust" { 
				local caption = "`ifin'"
			}
			else if "`r'" != "_ALBA_r" {
				local caption = "Effective sample size used (data adjusted for baseline risk and ratio of group sizes (r)). `ifin'"
			}
			else {
				local caption = "Effective sample size used (data adjusted for baseline risk). `ifin'"
			}
		}
	}

	*Format `type' to contain capitals
	if "`type'" == "mean" {
		local type "Mean Difference"
	}
	if "`type'" == "proportion" {
		local type "Proportion Dif."
	}	
	if "`type'" == "correlation" {
		local type "Correlation"
	}
	if "`type'" == "beta" {
		local type "Beta"
	}	
	if "`type'" == "md" {
		local type "MD"
	}
	if "`type'" == "smd" {
		local type "SMD"
	}	
	if "`type'" == "rr" {
		local type "RR"
	}
	if "`type'" == "or" {
		local type "OR"
	}		
	

********************************************************************************	
	**End of formatting and notes**
********************************************************************************		

********************************************************************************	
	**By() and legend**
********************************************************************************	
	*Colors
	if "`color'"!="" {
		local scheme = "s2color"
	}
	else {
		local scheme = "s2mono"
	}
	
	local plus_minus_s = "{&plusmn}"
	local plus_minus_m = "{&plusmn}"
	local plus_minus_l = "{&plusmn}"
	
	if "`type'" == "RR" | "`type'" == "OR" {
		local inverse_s = round(1/$small,0.01)
		local inverse_s: dis %3.2f `inverse_s'
		local inverse_m = round(1/$medium,0.01)
		local inverse_m: dis %3.2f `inverse_m'		
		local inverse_l = round(1/$large,0.01)
		local inverse_l: dis %3.2f `inverse_l'		
		local plus_minus_s = "`inverse_s' | "
		local plus_minus_m = "`inverse_m' | "
		local plus_minus_l = "`inverse_l' | "
	}
	
	*Define groups if by() option selected
	if "`by'"!="" {
		*If the by() group is numeric, convert to string
		capture qui sum `by'
		if r(mean)!=. {
			qui tostring `by', gen(_ALBA_by_group)
			qui replace _ALBA_by_group = "" if _ALBA_by_group == "."
			qui encode _ALBA_by_group if _ALBA_TOUSE == 1, gen(_ALBA_group)
		}
		else {
			qui encode `by' if _ALBA_TOUSE == 1, gen(_ALBA_group)
		}
		qui sum _ALBA_group
		local max_groups = r(max)

		if `"`if'"' == "" {
			local if2 "if"
		}
		else {
			local if2 `"`if' &"'
		}
		local group1 "(scatter _ALBA_N_data _ALBA_P_data if _ALBA_group==1 & _ALBA_TOUSE == 1, mcolor(black) msize(medsmall) msymbol(circle)) "
		local group2 "(scatter _ALBA_N_data _ALBA_P_data if _ALBA_group==2 & _ALBA_TOUSE == 1, mcolor(black) msize(medsmall) msymbol(circle_hollow)) "
		local group3 "(scatter _ALBA_N_data _ALBA_P_data if _ALBA_group==3 & _ALBA_TOUSE == 1, mcolor(gs8) msize(medsmall) msymbol(circle)) "
		local group4 "(scatter _ALBA_N_data _ALBA_P_data if _ALBA_group==4 & _ALBA_TOUSE == 1, mcolor(black) msize(small) msymbol(T)) "
		local group5 "(scatter _ALBA_N_data _ALBA_P_data if _ALBA_group==5 & _ALBA_TOUSE == 1, mcolor(black) msize(small) msymbol(Th)) "
		local group6 "(scatter _ALBA_N_data _ALBA_P_data if _ALBA_group==6 & _ALBA_TOUSE == 1, mcolor(gs8) msize(small) msymbol(T)) "
		local group7 "(scatter _ALBA_N_data _ALBA_P_data if _ALBA_group==7 & _ALBA_TOUSE == 1, mcolor(black) msize(small) msymbol(S)) "
		local group8 "(scatter _ALBA_N_data _ALBA_P_data if _ALBA_group==8 & _ALBA_TOUSE == 1, mcolor(black) msize(small) msymbol(Sh)) "
		local group9 "(scatter _ALBA_N_data _ALBA_P_data if _ALBA_group==9 & _ALBA_TOUSE == 1, mcolor(gs8) msize(small) msymbol(S)) "
		*For colors
		if "`color'" != "" {
			local group1 "(scatter _ALBA_N_data _ALBA_P_data if _ALBA_group==1 & _ALBA_TOUSE == 1, msize(medsmall)) "
			local group2 "(scatter _ALBA_N_data _ALBA_P_data if _ALBA_group==2 & _ALBA_TOUSE == 1, msize(medsmall)) "
			local group3 "(scatter _ALBA_N_data _ALBA_P_data if _ALBA_group==3 & _ALBA_TOUSE == 1, msize(medsmall)) "
			local group4 "(scatter _ALBA_N_data _ALBA_P_data if _ALBA_group==4 & _ALBA_TOUSE == 1, msize(medsmall)) "
			local group5 "(scatter _ALBA_N_data _ALBA_P_data if _ALBA_group==5 & _ALBA_TOUSE == 1, msize(medsmall)) "
			local group6 "(scatter _ALBA_N_data _ALBA_P_data if _ALBA_group==6 & _ALBA_TOUSE == 1, msize(medsmall)) "
			local group7 "(scatter _ALBA_N_data _ALBA_P_data if _ALBA_group==7 & _ALBA_TOUSE == 1, msize(medsmall)) "
			local group8 "(scatter _ALBA_N_data _ALBA_P_data if _ALBA_group==8 & _ALBA_TOUSE == 1, msize(medsmall)) "
			local group9 "(scatter _ALBA_N_data _ALBA_P_data if _ALBA_group==9 & _ALBA_TOUSE == 1, msize(medsmall)) "
		}
		
		if `max_groups'>=2 {
			local scatter "`group1'"
			forvalues num = 2 (1) `max_groups' {
				local scatter "`scatter' `group`num''"
			}
			*The legend (for by() groups)
			local lab_small = `max_groups'+1
			local lab_medium = `max_groups'+2
			local lab_large = `max_groups'+3
			local order "`lab_small' `lab_medium' `lab_large'"
			if $cons == 2 {
				local order "`lab_medium' `lab_large'"
			}
			if $cons == 1 {
				local order "`lab_large'"
			}	
			local group_label ""
			forvalues val = 1 (1) `max_groups' {
				preserve
				qui keep if _ALBA_group == `val'
				local leg`val' = `by'
				restore
				local order_add = `val'
				local order "`order' `order_add'"
				local group_label_add "label(`order_add' `leg`val'')"
				local group_label "`group_label' `group_label_add'"
			}
			local legend "legend(order(`order') label(`lab_small' `quote'`type' = `plus_minus_s'$small`quote') label(`lab_medium' `quote'`type' = `plus_minus_m'$medium`quote') label(`lab_large' `quote'`type' = `plus_minus_l'$large`quote') `group_label' size(vsmall) cols(3))"
			if $cons == 2 {
				local legend "legend(order(`order') label(`lab_medium' `quote'`type' = `plus_minus_m'$medium`quote') label(`lab_large' `quote'`type' = `plus_minus_l'$large`quote') `group_label' size(vsmall) cols(3) holes(3))"
			}
			if $cons == 1 {
				local legend "legend(order(`order')  label(`lab_large' `quote'`type' = `plus_minus_l'$large`quote') `group_label' size(vsmall) cols(3) holes(1 3))"
			}
		}
		else {
			local scatter "(scatter _ALBA_N_data _ALBA_P_data if _ALBA_TOUSE == 1, mcolor(black) msize(medsmall) msymbol(circle))"
			local legend "legend(order(2 3 4) label(2 `quote'`type' = `plus_minus_s'$small`quote') label(3 `quote'`type' = `plus_minus_m'$medium`quote') label(4 `quote'`type' = `plus_minus_l'$large`quote') size(vsmall) cols(3))"
			if $cons == 2 {
				local legend "legend(order(3 4) label(3 `quote'`type' = `plus_minus_m'$medium`quote') label(4 `quote'`type' = `plus_minus_l'$large`quote') `group_label' size(vsmall) cols(3) holes(3))"
			}
			if $cons == 1 {
				local legend "legend(order(4) label(4 `quote'`type' = `plus_minus_l'$large`quote') `group_label' size(vsmall) cols(3) holes(1 3))"
			}
		}
	}
	else {
		if "`color'" != "" { 
			local scatter "(scatter _ALBA_N_data _ALBA_P_data if _ALBA_TOUSE == 1, msize(medsmall) msymbol(circle))"
		}
		else {
			local scatter "(scatter _ALBA_N_data _ALBA_P_data if _ALBA_TOUSE == 1, mcolor(black) msize(medsmall) msymbol(circle))"
		}
		local legend "legend(order(2 3 4) label(2 `quote'`type' = `plus_minus_s'$small`quote') label(3 `quote'`type' = `plus_minus_m'$medium`quote') label(4 `quote'`type' = `plus_minus_l'$large`quote') size(vsmall) cols(3))"
		if $cons == 2 {
			local legend "legend(order(3 4) label(3 `quote'`type' = `plus_minus_s'$small`quote') label(4 `quote'`type' = `plus_minus_m'$medium`quote') size(vsmall) cols(3))"
		}
		if $cons == 1 {
			local legend "legend(order(4) label(4 `quote'`type' = `plus_minus_l'$large`quote') size(vsmall) cols(3))"
		}
	}

	*Studies with a range of P values (e.g. p>0.05) get a line instead of a dot
	*Range works by drawing a line between two P values at the height of the number of participants for each study
	if "`range'" != "" {
		qui egen _ALBA_range_TOUSE = rank(`range') if _ALBA_TOUSE==1, unique
		local lines = ""
		qui sum _ALBA_range_TOUSE
		local max_line_range = r(max)
		local n_line_range = r(N)
		if `n_line_range' != 0 {
			forvalues i = 1/`max_line_range' {
				qui sum `n' if _ALBA_range_TOUSE == `i'
				local n_lines = log10(r(mean))^2
				qui sum `p' if _ALBA_range_TOUSE == `i'
				local p_lines = log10(1/r(mean))			
				qui sum `range' if _ALBA_range_TOUSE == `i'
				local p2_lines = log10(1/r(mean))
				qui sum `e' if _ALBA_range_TOUSE == `i'
				if r(mean)<0 {
					local p_lines = -`p_lines'
					local p2_lines = -`p2_lines'
				}
				if "`tails'" != "" & "`onetailed'" == "onetailed" {
					qui sum `tails' if _ALBA_range_TOUSE == `i'
					if r(mean) == 2 {
						local p_lines = `p_lines'/2
						local p2_lines = `p2_lines'/2
					}
				}
				else if "`tails'" != "" {
					qui sum `tails' if _ALBA_range_TOUSE == `i'
					if r(mean) == 1 {
						local p_lines = `p_lines'*2
						local p2_lines = `p2_lines'*2
					}
				}
				if "`by'" != "" {
					qui sum _ALBA_group if _ALBA_range_TOUSE == `i'
					if r(mean) != 0 & "`color'" == "color" {
						local lll = r(mean)
						local p1 = "navy"
						local p2 = "maroon"
						local p3 = "forest_green"
						local p4 = "dkorange"
						local p5 = "teal"
						local p6 = "cranberry"
						local p7 = "lavender"
						local p8 = "khaki"
						local p9 = "sienna"
						local p10 = "emidblue"
						local p11 = "emerald"
						local p12 = "brown"
						local p13 = "erose"
						local p14 = "gold"
						local p15 = "bluishgray"
						local lcolor = "`p`lll''"
					}
				}
				else {
					local lcolor = "gs6"
				}
				
				local lines = "`lines' (function y=`n_lines', ra(`p_lines' `p2_lines') lcolor(`lcolor') lpattern(solid))"
			}
		}
	
		*Remove from _ALBA_TOUSE so they don't get dots as well
		qui replace _ALBA_TOUSE = . if `range'!=.
		qui drop _ALBA_range_TOUSE
	}
	
	
********************************************************************************	
	**End of by() and legend**
********************************************************************************		

********************************************************************************	
	**Graph**
********************************************************************************	
	
	twoway 	`scatter' ///
	(function $ALBA_small, lpattern(-) lcolor(gs4) ra($range_small_lower $range_small_neg)) ///
	(function $ALBA_medium, lpattern(_) lcolor(gs4) ra($range_medium_lower $range_medium_neg)) /// 
	(function $ALBA_large, lpattern(solid) lcolor(gs4) ra($range_large_lower $range_large_neg)) ///
	(function $ALBA_small, lpattern(-) lcolor(gs4) ra($range_small_pos $range_small_upper)) ///
	(function $ALBA_medium, lpattern(_) lcolor(gs4) ra($range_medium_pos $range_medium_upper)) /// 
	(function $ALBA_large, lpattern(solid) lcolor(gs4) ra($range_large_pos $range_large_upper)) ///
	(function y=0, lpattern(solid) lcolor(gs4) ra($range_large_neg $range_large_pos)) ///
	`lines' ///
	, b1title("Negative Association                               Null                               Positive Association", size(vsmall)) ///
	`legend' ///
	xline(`xline',lcolor(gs14)) xlab(`xlabel', labsize(tiny)) ///
	yline(`yline',lcolor(gs14)) ylab(`ylabel', labsize(tiny)) ///
	xtitle("P value", size(vsmall)) ytitle("Number of participants", size(vsmall)) ///
	scheme(`scheme') title(`title') subtitle(`subtitle') note("`note'", size(vsmall)) caption("`caption'", size(vsmall))

********************************************************************************
*End of graph*
********************************************************************************

********************************************************************************
*Cleanup variables*
********************************************************************************
foreach var in _ALBA_z _ALBA_z_ec _ALBA_by_group _ALBA_group _ALBA_rr _ALBA_or _ALBA_r _ALBA_baseline _ALBA_tails {
	capture drop `var'
}

capture label drop _ALBA_group

rename _ALBA_P_data _P_graph
rename _ALBA_N_data _N_graph
rename _ALBA_TOUSE _TOUSE

if "`adjust'" != "adjust" { 
	capture drop _ALBA_N_adjusted
}
else {
	capture rename _ALBA_N_adjusted _N_adjusted	
}

if "`effect'" != "effect" {
	capture drop _EST_*
}

macro drop small medium large ceiling range* ALBA*	
	
end

********************************************************************************
*End of ALBAtross plot program*
********************************************************************************

********************************************************************************
*Start of specifying small, medium and large effect sizes
********************************************************************************
*Defining programs to create the small/medium/large values for each type
*General program for calculation of small/medium/large
*_ALBA_x = the estimated effect size for each statistical measure
capture program drop finish_define
program define finish_define
	version 13
	args e type
	qui replace _ALBA_x = -abs(_ALBA_x) if `e'<0
	qui sum _ALBA_x, d
	global medium = round(r(p50),0.01)
	global small = round($medium /2,0.01)
	global large = round($medium *1.5,0.01)
	
	*Check if the values are large enough for all types, otherwise use stock values
	if "`type'" == "mean" & $small < 0.15 {
		global small = 0.1
		global medium = 0.25
		global large = 0.5
	}
		if "`type'" == "proportion" & $small < 0.1 {
		global small = 0.05
		global medium = 0.1
		global large = 0.25
	}
		if "`type'" == "correlation" & $small < 0.1 {
		global small = 0.1
		global medium = 0.2
		global large = 0.4
	}
		if "`type'" == "beta" & $small < 0.1 {
		global small = 0.1
		global medium = 0.2
		global large = 0.4
	}
		if "`type'" == "md" & $small < 0.15 {
		global small = 0.1
		global medium = 0.2
		global large = 0.4
	}
		if "`type'" == "smd" & $small < 0.15 {
		global small = 0.1
		global medium = 0.25
		global large = 0.5
	}
	
	*Check if small, med and large are all positive or negative
	*If not, then use mean/2 and mean*1.5 
	if $small/$medium <0 | $medium/$large<0 {
		global small = round(r(p50)/2,0.01)
		global large = round(r(p50)*1.5,0.01)
	}
	
	*Put RRs and ORs to exp scale
	if "`type'" == "rr" | "`type'" == "or" {
		global small = round(exp($small),0.01)
		global medium = round(exp($medium),0.01)
		global large = round(exp($large),0.01)
		qui replace _ALBA_x = exp(_ALBA_x)
	}
	
	if "`type'" == "rr" & $small < 1.2 {
		global small = 1.25
		global medium = 1.5
		global large = 2
	}
	if "`type'" == "or" & $small < 1.2 {
		global small = 1.25
		global medium = 1.5
		global large = 2
	}
	qui rename _ALBA_x _EST_`type'
end

*Simple means	
capture program drop specify_mean
program define specify_mean
	version 13
	syntax varlist, [sd(varlist) sd1(varlist) sd2(varlist) r(varlist) baseline(varlist) ssd(numlist) ssd1(numlist) ssd2(numlist) sbaseline(numlist) sr(numlist) sproportion(numlist) rr(varlist) or(varlist)]
	args n p e
	if "`sd'" != "" {
		qui gen _ALBA_x = sqrt(`sd'^2*_ALBA_z^2/`n') if _ALBA_TOUSE == 1
	}
	else {
		qui gen _ALBA_x = sqrt(`ssd'^2*_ALBA_z^2/`n') if _ALBA_TOUSE == 1
	}
	finish_define `e' mean
end

*Simple proportions	
capture program drop specify_proportion
program define specify_proportion
	version 13
	syntax varlist, [sd(varlist) sd1(varlist) sd2(varlist) r(varlist) baseline(varlist) ssd(numlist) ssd1(numlist) ssd2(numlist) sbaseline(numlist) sr(numlist) sproportion(numlist) rr(varlist) or(varlist)]
	args n p e
	qui gen _ALBA_x = sqrt(`sproportion'*(1-`sproportion')*_ALBA_z^2/`n') if _ALBA_TOUSE == 1
	finish_define `e' proportion
end

*Correlation	
capture program drop specify_correlation
program define specify_correlation
	version 13
	syntax varlist, [sd(varlist) sd1(varlist) sd2(varlist) r(varlist) baseline(varlist) ssd(numlist) ssd1(numlist) ssd2(numlist) sbaseline(numlist) sr(numlist) sproportion(numlist) rr(varlist) or(varlist)]
	args n p e
	qui gen _ALBA_x = sqrt(_ALBA_z^2/(`n'+_ALBA_z^2)) if _ALBA_TOUSE == 1
	finish_define `e' correlation
end

*Linear regression	
capture program drop specify_beta
program define specify_beta
	version 13
	syntax varlist, [sd(varlist) sd1(varlist) sd2(varlist) r(varlist) baseline(varlist) ssd(numlist) ssd1(numlist) ssd2(numlist) sbaseline(numlist) sr(numlist) sproportion(numlist) rr(varlist) or(varlist)]
	args n p e
	qui gen _ALBA_x = sqrt(_ALBA_z^2/(`n'+_ALBA_z^2)) if _ALBA_TOUSE == 1
	finish_define `e' beta
end

*Mean difference	
capture program drop specify_md
program define specify_md
	version 13
	syntax varlist, [sd(varlist) sd1(varlist) sd2(varlist) r(varlist) baseline(varlist) ssd(numlist) ssd1(numlist) ssd2(numlist) sbaseline(numlist) sr(numlist) sproportion(numlist) rr(varlist) or(varlist)]
	args n p e
	*Use SD1 and SD2 if known
	if "`sd1'" !="" & "`sd2'" != "" {
		qui gen _ALBA_x = sqrt((`r'+1)*(`sd1'^2+`r'*`sd2'^2)*_ALBA_z^2/(`r'*`n')) if _ALBA_TOUSE == 1
	}
	*Then SD
	else if "`sd'"!="" {
		qui gen _ALBA_x = sqrt(`sd'^2*(`r'+1)^2*_ALBA_z^2/(`r'*`n')) if _ALBA_TOUSE == 1
	}
	*Then SSD1 and SSD2
	else if "`ssd1'"!="" & "`ssd2'"!="" {
		qui gen _ALBA_x = sqrt((`r'+1)*(`ssd1'^2+`r'*`ssd2'^2)*_ALBA_z^2/(`r'*`n')) if _ALBA_TOUSE == 1
	}
	*Then SSD
	else if "`ssd'"!="" & "`sd'"=="" {
		qui gen _ALBA_x = sqrt(`ssd'^2*(`r'+1)^2*_ALBA_z^2/(`r'*`n')) if _ALBA_TOUSE == 1
	}
	
	finish_define `e' md
end

*SMD	
capture program drop specify_smd
program define specify_smd
	version 13
	syntax varlist, [sd(varlist) sd1(varlist) sd2(varlist) r(varlist) baseline(varlist) ssd(numlist) ssd1(numlist) ssd2(numlist) sbaseline(numlist) sr(numlist) sproportion(numlist) rr(varlist) or(varlist)]
	args n p e
	qui gen _ALBA_x = sqrt(2*(`r'+1)^2*_ALBA_z^2/(2*`r'*`n'-`r'*_ALBA_z^2)) if _ALBA_TOUSE == 1
	finish_define `e' smd
end

*RR	
*Note: RR can't be estimated easily, so RRs are generated and varlist passed here
capture program drop specify_rr
program define specify_rr
	version 13
	syntax varlist, [sd(varlist) sd1(varlist) sd2(varlist) r(varlist) baseline(varlist) ssd(numlist) ssd1(numlist) ssd2(numlist) sbaseline(numlist) sr(numlist) sproportion(numlist) rr(varlist) or(varlist)]
	args n p e
	qui gen _ALBA_x = ln(`rr')
	finish_define `e' rr
end

*OR	
*Note: OR can't be estimated easily, so ORs are generated and varlist passed here
capture program drop specify_or
program define specify_or
	version 13
	syntax varlist, [sd(varlist) sd1(varlist) sd2(varlist) r(varlist) baseline(varlist) ssd(numlist) ssd1(numlist) ssd2(numlist) sbaseline(numlist) sr(numlist) sproportion(numlist) rr(varlist) or(varlist)]
	args n p e
	qui gen _ALBA_x = ln(`or')
	finish_define `e' or
end

********************************************************************************
*End of defining small, medium and large effect sizes
********************************************************************************

********************************************************************************
*Start of contour generation programs
********************************************************************************

*Generating effect contours with ranges for each type
*Simple mean
capture program drop program_mean
program define program_mean
	syntax, small(numlist) medium(numlist) large(numlist) ssd(numlist) [sr(numlist) sbaseline(numlist) sproportion(numlist) ssd1(numlist) ssd2(numlist)]
	global ALBA_small "y=log10(`ssd'^2*invnormal(10^-abs(x)/2)^2/`small'^2)^2"
	global ALBA_medium "y=log10(`ssd'^2*invnormal(10^-abs(x)/2)^2/`medium'^2)^2"
	global ALBA_large "y=log10(`ssd'^2*invnormal(10^-abs(x)/2)^2/`large'^2)^2"
	
	*Ranges are calculated as the largest P value for $most_participants (so rearranged equations where p = foo * n)
	*Ranges replaced by $ceiling if $ceiling is lower
	*Lower range is just negative of upper range
	foreach var in small medium large {
		global range_`var'_upper = -log10(normal(-sqrt($most_participants*``var''^2/`ssd'^2))*2)
		global range_`var'_pos = -log10(normal(-sqrt(``var''^2/`ssd'^2))*2)
		if ${range_`var'_upper} > $ceiling {
			global range_`var'_upper = $ceiling
		}
		global range_`var'_lower = -${range_`var'_upper}
		global range_`var'_neg = -${range_`var'_pos}
	}
end

*Simple proportion
capture program drop program_proportion
program define program_proportion
	syntax, small(numlist) medium(numlist) large(numlist) [ssd(numlist) sr(numlist) sbaseline(numlist) sproportion(numlist) ssd1(numlist) ssd2(numlist)]
	global ALBA_small = "y=log10(`sproportion'*(1-`sproportion')*invnormal(10^-abs(x)/2)^2/`small'^2)^2"
	global ALBA_medium = "y=log10(`sproportion'*(1-`sproportion')*invnormal(10^-abs(x)/2)^2/`medium'^2)^2"
	global ALBA_large = "y=log10(`sproportion'*(1-`sproportion')*invnormal(10^-abs(x)/2)^2/`large'^2)^2"
	
	*Ranges are calculated as the largest P value for $most_participants (so rearranged equations where p = foo * n)
	*Ranges replaced by $ceiling if $ceiling is lower
	*Lower range is just negative of upper range
	foreach var in small medium large {
		global range_`var'_upper = -log10(normal(-sqrt($most_participants*``var''^2/(`sproportion'*(1-`sproportion'))))*2)
		global range_`var'_pos = -log10(normal(-sqrt(``var''^2/(`sproportion'*(1-`sproportion'))))*2)
		if ${range_`var'_upper} > $ceiling {
			global range_`var'_upper = $ceiling
		}
		global range_`var'_lower = -${range_`var'_upper}
		global range_`var'_neg = -${range_`var'_pos}
	}
end

*Correlation
capture program drop program_correlation
program define program_correlation
	syntax, small(numlist) medium(numlist) large(numlist) [ssd(numlist) sr(numlist) sbaseline(numlist) sproportion(numlist) ssd1(numlist) ssd2(numlist)]
	global ALBA_small = "y=log10((1-`small'^2)*invnormal(10^-abs(x)/2)^2/`small'^2)^2"
	global ALBA_medium = "y=log10((1-`medium'^2)*invnormal(10^-abs(x)/2)^2/`medium'^2)^2"
	global ALBA_large= "y=log10((1-`large'^2)*invnormal(10^-abs(x)/2)^2/`large'^2)^2"
	
	*Ranges are calculated as the largest P value for $most_participants (so rearranged equations where p = foo * n)
	*Ranges replaced by $ceiling if $ceiling is lower
	*Lower range is just negative of upper range
	foreach var in small medium large {
		global range_`var'_upper = -log10(normal(-sqrt($most_participants*``var''^2/(1-``var''^2)))*2)
		global range_`var'_pos = -log10(normal(-sqrt(``var''^2/(1-``var''^2)))*2)
		if ${range_`var'_upper} > $ceiling {
			global range_`var'_upper = $ceiling
		}
		global range_`var'_lower = -${range_`var'_upper}
		global range_`var'_neg = -${range_`var'_pos}
	}
end

*Linear regression
capture program drop program_beta
program define program_beta
	syntax, small(numlist) medium(numlist) large(numlist) [ssd(numlist) sr(numlist) sbaseline(numlist) sproportion(numlist) ssd1(numlist) ssd2(numlist)]
	global ALBA_small = "y=log10((1-`small'^2)*invnormal(10^-abs(x)/2)^2/`small'^2)^2"
	global ALBA_medium = "y=log10((1-`medium'^2)*invnormal(10^-abs(x)/2)^2/`medium'^2)^2"
	global ALBA_large= "y=log10((1-`large'^2)*invnormal(10^-abs(x)/2)^2/`large'^2)^2"
	
	*Ranges are calculated as the largest P value for $most_participants (so rearranged equations where p = foo * n)
	*Ranges replaced by $ceiling if $ceiling is lower
	*Lower range is just negative of upper range
	foreach var in small medium large {
		global range_`var'_upper = -log10(normal(-sqrt($most_participants*``var''^2/(1-``var''^2)))*2)
		global range_`var'_pos = -log10(normal(-sqrt(``var''^2/(1-``var''^2)))*2)
		if ${range_`var'_upper} > $ceiling {
			global range_`var'_upper = $ceiling
		}
		global range_`var'_lower = -${range_`var'_upper}
		global range_`var'_neg = -${range_`var'_pos}
	}
end

*MD
capture program drop program_md
program define program_md
	syntax, small(numlist) medium(numlist) large(numlist) sr(numlist) [sbaseline(numlist) sproportion(numlist) ssd(numlist) ssd1(numlist) ssd2(numlist)]
	*First generate the contours with SSD1 and SSD2 if available
	if "`ssd1'" != "" & "`ssd2'" != "" {
		global ALBA_small = "y=log10((`sr'+1)*(`ssd1'^2+`sr'*`ssd2'^2)*invnormal(10^-abs(x)/2)^2/(`sr'*`small'^2))^2"
		global ALBA_medium = "y=log10((`sr'+1)*(`ssd1'^2+`sr'*`ssd2'^2)*invnormal(10^-abs(x)/2)^2/(`sr'*`medium'^2))^2"
		global ALBA_large = "y=log10((`sr'+1)*(`ssd1'^2+`sr'*`ssd2'^2)*invnormal(10^-abs(x)/2)^2/(`sr'*`large'^2))^2"
		
		*Ranges are calculated as the largest P value for $most_participants (so rearranged equations where p = foo * n)
		*Ranges replaced by $ceiling if $ceiling is lower
		*Lower range is just negative of upper range
		foreach var in small medium large {
			global range_`var'_upper = -log10(normal(-sqrt($most_participants*`sr'*``var''^2/((`sr'+1)*(`ssd1'^2+`sr'*`ssd2'^2))))*2)
			global range_`var'_pos = -log10(normal(-sqrt(`sr'*``var''^2/((`sr'+1)*(`ssd1'^2+`sr'*`ssd2'^2))))*2)
			if ${range_`var'_upper} > $ceiling {
				global range_`var'_upper = $ceiling
			}
			global range_`var'_lower = -${range_`var'_upper}
			global range_`var'_neg = -${range_`var'_pos}
		}
	}
	
	*Otherwise use SSD
	else {
		global ALBA_small = "y=log10(`ssd'^2*(`sr'+1)^2*invnormal(10^-abs(x)/2)^2/(`sr'*`small'^2))^2"
		global ALBA_medium = "y=log10(`ssd'^2*(`sr'+1)^2*invnormal(10^-abs(x)/2)^2/(`sr'*`medium'^2))^2"
		global ALBA_large= "y=log10(`ssd'^2*(`sr'+1)^2*invnormal(10^-abs(x)/2)^2/(`sr'*`large'^2))^2"
	
	
		*Ranges are calculated as the largest P value for $most_participants (so rearranged equations where p = foo * n)
		*Ranges replaced by $ceiling if $ceiling is lower
		*Lower range is just negative of upper range
		foreach var in small medium large {
			global range_`var'_upper = -log10(normal(-sqrt($most_participants*`sr'*``var''^2/(`ssd'^2*(`sr'+1)^2)))*2)
			global range_`var'_pos = -log10(normal(-sqrt(`sr'*``var''^2/(`ssd'^2*(`sr'+1)^2)))*2)
			if ${range_`var'_upper} > $ceiling {
				global range_`var'_upper = $ceiling
			}
			global range_`var'_lower = -${range_`var'_upper}
			global range_`var'_neg = -${range_`var'_pos}
		}
	}
end

*SMD
capture program drop program_smd
program define program_smd
	syntax, small(numlist) medium(numlist) large(numlist) sr(numlist) [ssd(numlist) sbaseline(numlist) sproportion(numlist) ssd1(numlist) ssd2(numlist)]
	global ALBA_small = "y=log10((2*(`sr'+1)^2+`sr'*`small'^2)*invnormal(10^-abs(x)/2)^2/(2*`sr'*`small'^2))^2"
	global ALBA_medium = "y=log10((2*(`sr'+1)^2+`sr'*`medium'^2)*invnormal(10^-abs(x)/2)^2/(2*`sr'*`medium'^2))^2"
	global ALBA_large = "y=log10((2*(`sr'+1)^2+`sr'*`large'^2)*invnormal(10^-abs(x)/2)^2/(2*`sr'*`large'^2))^2"
	
	*Ranges are calculated as the largest P value for $most_participants (so rearranged equations where p = foo * n)
	*Ranges replaced by $ceiling if $ceiling is lower
	*Lower range is just negative of upper range
	foreach var in small medium large {
		global range_`var'_upper = -log10(normal(-sqrt($most_participants*2*`sr'*``var''^2/(2*(`sr'+1)^2+`sr'*``var''^2)))*2)
		global range_`var'_pos = -log10(normal(-sqrt(2*`sr'*``var''^2/(2*(`sr'+1)^2+`sr'*``var''^2)))*2)
		if ${range_`var'_upper} > $ceiling {
			global range_`var'_upper = $ceiling
		}
		global range_`var'_lower = -${range_`var'_upper}
		global range_`var'_neg = -${range_`var'_pos}
	}
end

*RR
capture program drop program_rr
program define program_rr
	syntax, small(numlist) medium(numlist) large(numlist) sr(numlist) sbaseline(numlist) [ssd(numlist) sproportion(numlist) ssd1(numlist) ssd2(numlist)]
	global ALBA_small = "y=log10(((`sr'+1)*(`sr'+`small'*(`sr'-`sbaseline'-`sr'*`sbaseline')))*invnormal(10^-abs(x)/2)^2/(`sr'*`small'*`sbaseline'*ln(`small')^2))^2"
	global ALBA_medium = "y=log10(((`sr'+1)*(`sr'+`medium'*(`sr'-`sbaseline'-`sr'*`sbaseline')))*invnormal(10^-abs(x)/2)^2/(`sr'*`medium'*`sbaseline'*ln(`medium')^2))^2"
	global ALBA_large = "y=log10(((`sr'+1)*(`sr'+`large'*(`sr'-`sbaseline'-`sr'*`sbaseline')))*invnormal(10^-abs(x)/2)^2/(`sr'*`large'*`sbaseline'*ln(`large')^2))^2"
	
	*Ranges are calculated as the largest P value for $most_participants (so rearranged equations where p = foo * n)
	*Ranges replaced by $ceiling if $ceiling is lower
	*Lower range is just negative of upper range
	foreach var in small medium large {
		global range_`var'_upper = -log10(normal(-sqrt($most_participants*(`sr'*``var''*`sbaseline'*ln(``var'')^2)/((`sr'+1)*(`sr'+``var''*(`sr'-`sbaseline'-`sr'*`sbaseline')))))*2)
		global range_`var'_pos = -log10(normal(-sqrt((`sr'*``var''*`sbaseline'*ln(``var'')^2)/((`sr'+1)*(`sr'+``var''*(`sr'-`sbaseline'-`sr'*`sbaseline')))))*2)
		if ${range_`var'_upper} > $ceiling {
			global range_`var'_upper = $ceiling
		}
		global range_`var'_lower = -${range_`var'_upper}
		global range_`var'_neg = -${range_`var'_pos}
	}
end

*OR
capture program drop program_or
program define program_or
	syntax, small(numlist) medium(numlist) large(numlist) sr(numlist) sbaseline(numlist) [ssd(numlist) sproportion(numlist) ssd1(numlist) ssd2(numlist)]
	global ALBA_small = "y=log10(((`sr'+1)*((1-`sbaseline'+`small'*`sbaseline')^2+`sr'*`small'))*invnormal(10^-abs(x)/2)^2/(`sr'*`small'*`sbaseline'*(1-`sbaseline')*ln(`small')^2))^2"
	global ALBA_medium = "y=log10(((`sr'+1)*((1-`sbaseline'+`medium'*`sbaseline')^2+`sr'*`medium'))*invnormal(10^-abs(x)/2)^2/(`sr'*`medium'*`sbaseline'*(1-`sbaseline')*ln(`medium')^2))^2"
	global ALBA_large = "y=log10(((`sr'+1)*((1-`sbaseline'+`large'*`sbaseline')^2+`sr'*`large'))*invnormal(10^-abs(x)/2)^2/(`sr'*`large'*`sbaseline'*(1-`sbaseline')*ln(`large')^2))^2"
	
	*Ranges are calculated as the largest P value for $most_participants (so rearranged equations where p = foo * n)
	*Ranges replaced by $ceiling if $ceiling is lower
	*Lower range is just negative of upper range
	foreach var in small medium large {
		global range_`var'_upper = -log10(normal(-sqrt($most_participants*(`sr'*``var''*`sbaseline'*(1-`sbaseline')*ln(``var'')^2)/((`sr'+1)*((1-`sbaseline'+``var''*`sbaseline')^2+`sr'*``var''))))*2)
		global range_`var'_pos = -log10(normal(-sqrt((`sr'*``var''*`sbaseline'*(1-`sbaseline')*ln(``var'')^2)/((`sr'+1)*((1-`sbaseline'+``var''*`sbaseline')^2+`sr'*``var''))))*2)
		if ${range_`var'_upper} > $ceiling {
			global range_`var'_upper = $ceiling
		}
		global range_`var'_lower = -${range_`var'_upper}
		global range_`var'_neg = -${range_`var'_pos}
	}
end

********************************************************************************
*End of programs generating effect contours
********************************************************************************

********************************************************************************
*Start of adjustment programs
********************************************************************************

capture program drop ALBA_adjustment_mean
program define ALBA_adjustment_mean
	syntax varlist [, sd(varlist) sd1(varlist) sd2(varlist) ssd(numlist) ssd1(numlist) ssd2(numlist) baseline(varlist) sbaseline(numlist) r(varlist) sr(numlist) rr(varlist) or(varlist)]
	args n p e
	if "`sd'" != "" {
		qui gen _ALBA_N_adjusted = `n'*`ssd'^2/`sd'^2 if _ALBA_TOUSE == 1
	}
	else {
		qui gen _ALBA_N_adjusted = `n'
	}
end

capture program drop ALBA_adjustment_md
program define ALBA_adjustment_md
	syntax varlist [, sd(varlist) sd1(varlist) sd2(varlist) ssd(numlist) ssd1(numlist) ssd2(numlist) baseline(varlist) sbaseline(numlist) r(varlist) sr(numlist) rr(varlist) or(varlist)]
	args n p e
	*First adjust if SD1 and SD2 are specified
	if "`sd1'"!="" & "`sd2'"!="" & "`ssd1'"!="" & "`ssd2'"!="" {
		qui gen _ALBA_N_adjusted = `r'*`n'*(1+`sr')*(`ssd1'^2*`sr'*`ssd2'^2)/(`sr'*(1+`r')*(`sd1'^2+`r'*`sd2'^2)) if _ALBA_TOUSE == 1
	}
	*Then if the SD is specified
	else if "`sd'"!="" & "`ssd'"!="" {
		qui gen _ALBA_N_adjusted = `r'*`n'*(1+`sr')^2*`ssd'^2/(`sr'*`sd'^2*(1+`r')^2) if _ALBA_TOUSE == 1
	}
	*Then if only the R variable is specified
	else {
		qui gen _ALBA_N_adjusted = `r'*`n'*(1+`sr')^2/(`sr'*(1+`r')^2) if _ALBA_TOUSE == 1
	}
end

capture program drop ALBA_adjustment_smd
program define ALBA_adjustment_smd
	syntax varlist [, sd(varlist) sd1(varlist) sd2(varlist) ssd(numlist) ssd1(numlist) ssd2(numlist) baseline(varlist) sbaseline(numlist) r(varlist) sr(numlist) rr(varlist) or(varlist)]
	args n p e
	qui gen _ALBA_N_adjusted = ((`sr'+1)^2*(2*`r'*`n'-`r'*invnormal(`p'/2)^2)+`sr'*invnormal(`p'/2)^2*(`r'+1)^2)/(2*`sr'*(`r'+1)^2) if _ALBA_TOUSE == 1
end

capture program drop ALBA_adjustment_rr
program define ALBA_adjustment_rr
	syntax varlist, rr(varlist) [, sd(varlist) sd1(varlist) sd2(varlist) ssd(numlist) ssd1(numlist) ssd2(numlist) baseline(varlist) sbaseline(numlist) r(varlist) sr(numlist) or(varlist)]
	args n p e
	qui gen _ALBA_N_adjusted = `r'*`baseline'*`n'*(1+`sr')*(1+`rr'*(`sr'-`sbaseline'-`sbaseline'*`sr'))/(`sr'*`sbaseline'*(1+`r')*(1+`rr'*(`r'-`baseline'-`baseline'*`r'))) if _ALBA_TOUSE == 1
end

capture program drop ALBA_adjustment_or
program define ALBA_adjustment_or
	syntax varlist, or(varlist) [, sd(varlist) sd1(varlist) sd2(varlist) ssd(numlist) ssd1(numlist) ssd2(numlist) baseline(varlist) sbaseline(numlist) r(varlist) sr(numlist) rr(varlist)]
	args n p e
	qui gen _ALBA_N_adjusted = `baseline'*`r'*`n'*(1-`baseline')*(1+`sr')*((1-`sbaseline'+`sbaseline'*`or')^2+`sr'*`or')/(`sbaseline'*`sr'*(1-`sbaseline')*(1+`r')*((1-`baseline'+`baseline'*`or')^2+`r'*`or')) if _ALBA_TOUSE == 1
end

********************************************************************************
*End of adjustment programs
********************************************************************************

********************************************************************************
*Start of programs estimating the RR and OR
********************************************************************************

capture program drop rr_estimation
program define rr_estimation
	syntax varlist [, r(varlist) sr(numlist) baseline(varlist) sbaseline(numlist)]
	args n p e
	local i = 1
	local rr_e = 1
	qui gen _ALBA_rr = .
	qui gen _ALBA_original_sort = _n
	sort _ALBA_TOUSE
	qui sum _ALBA_TOUSE
	local obs_max = r(sum)
	forvalues ob = 1 (1) `obs_max' {
		local estimate = `n'*`r'*`rr_e'*`baseline'*ln(`rr_e')^2-invnormal(`p'/2)^2*(`r'+1)*(1+`rr_e'*(`r'-`baseline'-`r'*`baseline')) in `ob'
		while `estimate' < 0 {
			if `e'<0 in `ob' {
				local rr_e = `rr_e'-0.001
			}
			else {
				local rr_e = `rr_e'+0.001
			}
			local estimate = `n'*`r'*`rr_e'*`baseline'*ln(`rr_e')^2-invnormal(`p'/2)^2*(`r'+1)*(1+`rr_e'*(`r'-`baseline'-`r'*`baseline')) in `ob'
			}
		local rr_e = round(`rr_e',0.01)
		qui replace _ALBA_rr = `rr_e' in `ob'
		local rr_e = 1
	}
	sort _ALBA_original_sort
	drop _ALBA_original_sort
end

capture program drop or_estimation
program define or_estimation
	syntax varlist [, r(varlist) sr(numlist) baseline(varlist) sbaseline(numlist)] 
	args n p e
	local i = 1
	local or_e = 1
	qui gen _ALBA_or = .
	qui gen _ALBA_original_sort = _n
	sort _ALBA_TOUSE
	qui sum _ALBA_TOUSE
	local obs_max = r(sum)
	forvalues ob = 1 (1) `obs_max' {
		local estimate = `n'*`r'*`or_e'*`baseline'*(1-`baseline')*ln(`or_e')^2-invnormal(`p'/2)^2*(`r'+1)*((1-`baseline'+`or_e'*`baseline')^2+`r'*`or_e') in `ob'
		while `estimate' < -0.0001 {
			if `e'<0 in `ob' {
				local or_e = `or_e'-0.001
			}
			else {
				local or_e = `or_e'+0.001
			}
				local estimate = `n'*`r'*`or_e'*`baseline'*(1-`baseline')*ln(`or_e')^2-invnormal(`p'/2)^2*(`r'+1)*((1-`baseline'+`or_e'*`baseline')^2+`r'*`or_e') in `ob'
		}
		local or_e = round(`or_e',0.01)
		qui replace _ALBA_or = `or_e' in `ob'
		local or_e=1
	}
	sort _ALBA_original_sort
	drop _ALBA_original_sort
end

********************************************************************************
*End of estimation of RR and OR
********************************************************************************

********************************************************************************
*End of ado file
********************************************************************************

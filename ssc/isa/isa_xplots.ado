*capture program drop isa_xplots

*********************************************************************
*	PROGRAM FOR BENCHMARK PLOTS MADE BY OMITTING OBSERVED COVARIATES.

program define isa_xplots
	version 9
	syntax varlist [if] [in] [fw aw], [vce(passthru)]

	marksample touse
	
	qui gen isa_partial_rsq_yx = .
	qui gen isa_partial_rsq_tx = .
	qui gen str isa_plotvar =""

	*	COUNTING NUMBER OF VARIABLES
	local num_var2=0
	foreach var in `varlist' {
		local num_var2=`num_var2'+1
	}


	if `num_var2' <= 12	{											/* ADDED IN V26 */
		local iter_xplots = `num_var2'
	}
	else	{
		local iter_xplots = 12
	}

	forvalues k = 3/`iter_xplots' {
		if `num_var2' <= 12	{
			tokenize `varlist'
			local varlist2 = subinword("`varlist'","``k''","",`k')
		}
		else	{													/* ADDED IN V26 */
			local restX_0 `varlist'
			forvalues i9 = 0/9 {
				local j9 = `i9'+1
				gettoken `j9' restX_`j9' : restX_`i9'
			}
			local fst10 `1' `2' `3' `4' `5' `6' `7' `8' `9' `10'
			local fst10_`k' = subinword("`fst10'","``k''","",.)
			local varlist2 `fst10_`k'' `restX_10'
		}
		local k_2 = `k' - 2

		isa_est_woinit `varlist2' if `touse' [`weight'`exp'], alpha(0) delta(0) `vce'
		matrix matB = e(b)
		matrix matV = e(V)
		scalar tau = matB[1,1]
		scalar se = sqrt(matV[1,1])
		scalar t = scalar(tau)/scalar(se)
		scalar tau_diff = scalar(tau) - scalar(tau_o)

		*	ESTIMATING X-OMITTED R-SQ FOR TREATMENT ASSIGNMENT EQ.	
		isa_rsq_treat `varlist2' if `touse' [`weight'`exp'], alpha(0)
		scalar rsq_t_x`k_2' = scalar(rsq_t)
		scalar drop var_t rsq_t
			
		*	ESTIMATING X-OMITTED R-SQ FOR OUTCOME EQ.	
		isa_rsq_outcome `varlist2'
		scalar sigma_sqx = scalar(sigma_sq)
		scalar drop sigma_sq

		*	CALCULATING PARTIAL R-SQUARES for OUTCOME AND TREATMENT EQUATIONS
		scalar partial_rsq_yx`k_2' = abs((sigma_sqo - sigma_sqx)/sigma_sqo)
		scalar partial_rsq_tx`k_2' = abs((rsq_t_x`k_2' - rsq_to)/(1-rsq_to))
		matrix drop matB matV
		replace isa_partial_rsq_yx = scalar(partial_rsq_yx`k_2') if [_n]==`k_2'
		replace isa_partial_rsq_tx = scalar(partial_rsq_tx`k_2') if [_n]==`k_2'
		replace isa_plotvar = "``k-2''" if [_n]==`k_2'
	}
	
end


*! 1.1.1 Ariel Linden 19mar2013 - changed name to rtm_calc
*! 1.1.0 Ariel Linden 16feb2013 - added % RTM to program
*! 1.0.0 Ariel Linden 12feb2013

capture program drop rtm_calc
program define rtm_calc, rclass byable(recall)
	version 11.0
	syntax varlist(min=2 max=2) [if] [in], k(str) m(str) [SEED(str) REPS(str) SIZE(str) LEVel(str) SAVING(str)]

	tokenize `varlist'
	args pretest posttest

	marksample touse
	quietly count if `touse'
	if r(N) == 0 error 2000
	local N = r(N)
		
	tempname mu sd rho var_w var_b zscore_high zscore_low auc_high auc_low normdist_high ///
	normdist_low cstat_high cstat_low rtm_high rtm_low pct_rtm_high pct_rtm_low firstval_high ///
	secondval_high firstval_low secondval_low pooled_sd

	sum `pretest' if `touse'
	scalar `mu' = r(mean)
	scalar `sd' = r(sd)

	corr `pretest' `posttest' if `touse'
	scalar `rho' = r(rho)
	
	// calculate variances and zscores
	scalar `var_w'=(1-`rho')*(`sd'^2)  						//within individual variance
	scalar `var_b'=`rho'*(`sd'^2) 							// between group variance
	scalar `pooled_sd' = sqrt((`var_b' + `var_w'/ `m')) 	//pooled sd
	scalar `zscore_high' = (`k' - `mu') / `pooled_sd' 		// zscore for value above cutoff
	scalar `zscore_low' = (`mu' - `k') / `pooled_sd' 		// zscore for value below cutoff
	
	// area under normal curve
	scalar `auc_high' = 1-normal(`zscore_high') 
	scalar `auc_low' = 1-normal(`zscore_low') 

	// norm dist at z
	scalar `normdist_high' = normalden(`zscore_high') 
	scalar `normdist_low' = normalden(`zscore_low') 

	// c-stats
	scalar `cstat_high' = `normdist_high' / `auc_high' 
	scalar `cstat_low' = `normdist_low' / `auc_low' 

	// RTM effects
	scalar `rtm_high'=(`var_w'/`m')/sqrt(`var_b'+(`var_w'/`m'))*`cstat_high' 
	scalar `rtm_low'=(`var_w'/`m')/sqrt(`var_b'+(`var_w'/`m'))*`cstat_low' 

	// Predicted high values
	scalar `firstval_high' = `mu'+(`cstat_high'*`pooled_sd') 
	scalar `secondval_high' = `mu' +(`cstat_high'* `var_b')/(`pooled_sd') 
	scalar `pct_rtm_high' = `rtm_high' / `firstval_high'
	
	//Predicted low values
	scalar `firstval_low' = `mu'-(`cstat_low'*`pooled_sd') 
	scalar `secondval_low' = `mu'-(`cstat_low'* `var_b')/(`pooled_sd') 
	scalar `pct_rtm_low' = `rtm_low' / `firstval_low'
	
	// returned values
	
	return scalar mu = `mu'
	return scalar sd = `sd'
	return scalar rho = `rho'
	
	ret scalar var_w = `var_w'
	ret scalar var_b = `var_b'
	ret scalar pooled_sd = `pooled_sd'
	ret scalar zscore_high = `zscore_high'
	ret scalar zscore_low = `zscore_low'

	ret scalar auc_high = `auc_high'
	ret scalar auc_low = `auc_low'
	ret scalar normdist_high = `normdist_high'
	ret scalar normdist_low = `normdist_low'
	ret scalar cstat_high = `cstat_high'
	ret scalar cstat_low = `cstat_low'
	ret scalar rtm_high = `rtm_high'
	ret scalar rtm_low = `rtm_low'
	ret scalar pct_rtm_high = `pct_rtm_high'
	ret scalar pct_rtm_low = `pct_rtm_low'
	ret scalar firstval_high = `firstval_high'
	ret scalar secondval_high = `secondval_high'
	ret scalar firstval_low = `firstval_low'
	ret scalar secondval_low = `secondval_low'

	
end

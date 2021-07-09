program define pagetrend, rclass 
*! Author: Hong Il Yoo (h.i.yoo@durham.ac.uk) 
*! HIY 1.0.0 17 January 2015
	version 11
	syntax varlist(numeric min=2) [if] [in] 
	
	*check -rowranks- has been installed already
	capture rowranks 
	if (_rc == 199) {
		di in red "unrecognized command:  rowranks" 
		di as input "rowranks" as text " must be installed before " ///
		   as input "pagetrend" ///
		   as text " can be used."
		di as input "findit pr0046 " as text "to install " ///
		   as input "rowranks" as text "."
		exit 199
	}
	
	*define the estimation sample
	marksample touse
	markout `touse' `varlist'
	
	*count the number of treatments 
	local N_treat : word count `varlist'
	
	*define temporary items
	forvalues k = 1/`N_treat' {
		tempvar rank`k'
		local rankvars `rankvars' `rank`k''
	}
	tempname ranksum output coef N_group Lmat L z p
	
	*count the number of groups
	qui count if `touse'
	scalar `N_group' = r(N)
	
	*use -rowranks- to compute the within-group ranks of treatments
	rowranks `varlist' if `touse', gen(`rankvars') method(mean)
		
	*compute the sum of ranks for each treatment 
	qui tabstat `rankvars' if `touse', stat(sum) save	
	matrix `ranksum' = r(StatTotal)
	
	*compute the sum and mean of ranks to document output 
	qui tabstat `rankvars' if `touse', stats(mean) save 
	matrix `output' = r(StatTotal)'
	mata: st_matrix(st_local("output"),round(st_matrix(st_local("output")),0.0001))
	matrix `output' = `ranksum'', `output'
	matrix rownames `output' = `varlist'
	matrix colnames `output' = "Sum of ranks" "Average rank" 
	
	*compute Page's L statistic
	forvalues k =1/`N_treat' {
		matrix `coef' = nullmat(`coef'), `k'
	}
	matrix `Lmat' = `coef'*`ranksum''
	scalar `L' = `Lmat'[1,1]
	
	*write L as z-score to compute asymptotic p value
	scalar `z' = (`L' - `N_group'*`N_treat'*(`N_treat'+1)^2/4) / ///
				 sqrt(`N_group'*(`N_treat'^3-`N_treat')^2/(144*(`N_treat'-1)))	
	scalar `p' = 1-normal(`z')
	
	*store treatment variable names as local macros
	local k = 0
	foreach v of varlist `varlist' {
		local k = `k' + 1
		local treat`k' `v'
	}
	
	*display results
	di as text " "
	di as text "Page's non-parametric test for ordered alternatives"
	matlist `output', rowtitle(Variable) noblank border format(%12.0g)
	di as text "(Note: " as result scalar(`N_treat') as text " treatments ranked within each of " ///
			   as result scalar(`N_group') as text " groups)"
	di as text ""		   
	di as text "Ho: m1 = m2 = ... = mK	Ha: m1 < m2 < ... < mK"     
	di as text "where mk is the population mean (median) of the kth variable in the table above" 
	di as text ""
	di as text "Page's L statistic = " as result scalar(`L') 
	di as text "Approximate p-value = Pr(Z>z) = " as result %5.4f round(scalar(`p'),0.0001) /// 
	   as text " where z = " as result %-12.4f round(scalar(`z'),0.001) 
	
	*return treatment variables
	forvalues k = 1/`N_treat' {
		return local treat`k' `treat`k''
	}
	
	*return scalars 
	return scalar N_group = `N_group'
	return scalar N_treat = `N_treat'
	return scalar L = `L'
	return scalar z = `z'
	return scalar p = `p'
end


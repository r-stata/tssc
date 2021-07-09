*! 1.0.0 MLB 18Jun2008
program define ftest, rclass
	version 8
	tempname current r21 r22 F p

/// no options allowed
	local all `*'
	local rest : list all - 1
	local rest : list rest - 2
	if "`rest'" != "" {
		di as err "`rest' not allowed"
		exit 198
	}

/// saving current estimation results for restoration after finishing
	capture est store `current'
	local restore !_rc
	
/// Collect information from models
	qui est restore `1'
	if "`e(cmd)'" != "regress" {
		di as err "model `1' is not estimated with regress"
		exit 198
	}
	if "`e(vcetype)'" != "" {
		di as err "`e(vcetype)' vce not allowed"
		exit 198
	}
	local df_m1 = e(df_m)
	local df_r1 = e(df_r)
	local n1 = e(N)
	scalar `r21' = e(r2)
	
	if "`2'" == "" {
		local 2 .
	}
	if "`2'" == "."  {
		qui est restore `current'
	}
	else {
		qui est restore `2'
	}
	if "`e(cmd)'" != "regress" {
		di as err "model `2' is not estimated with regress"
		exit 198
	}
	if "`e(vcetype)'" != "" {
		di as err "`e(vcetype)' vce not allowed"
		exit 198
	}
	local df_m2 = e(df_m)
	local df_r2 = e(df_r)
	local n2 = e(N)
	scalar `r22' = e(r2)

/// test	
	if `n1' != `n2' {
		di as err "models are estimated on different samples"
		exit 198
	}
	
	local df_num = abs(`df_m1' - `df_m2')
	local df_denom = min(`df_r1', `df_r2')
	
	scalar `F' = (abs(`r21' - `r22')/`df_num') / ( (1-max(`r21', `r22')) / `df_denom')
	scalar `p' = Ftail(`df_num', `df_denom', `F')

/// display
	if `df_m1' > `df_m2' {
		di as txt "Assumption: " as result "`2'" as txt " nested in " as result "`1'" _n
	}
	else {
		di as txt "Assumption: " as result "`1'" as txt " nested in " as result "`2'" _n
	}
	di as txt "F(" %3.0f `df_num' ", " %7.0f `df_denom' ") = " as result %9.2f `F'
	di _col(8) as txt "prob > F = " as result %9.4f `p'

/// return results
	return scalar p = `p'
	return scalar df_denom = `df_denom'
	return scalar df_num = `df_num'
	return scalar F = `F'
	
/// clean up	
	if `restore' {
		qui est restore `current'
	}
end

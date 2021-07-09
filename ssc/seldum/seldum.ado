*! Version: 03aug2011 
*! Author: Jean Ries
*! Interpretation of Dummy Variables in Semilogarithmic Regression Models

/*
This program implements the method recommended by: 
van Garderen, K. and Shah, C. (2002). Exact Interpretation of Dummy
Variables in Semilogarithmic Equations. The Econometrics Journal, 5(1):149-159.
*/

program define seldum, rclass
	version 8.2
	syntax varlist(min=1) [, REPlay]

	local vars `varlist'
	
	if !missing("`replay'") {
		di _n as txt "Replaying the results of the semi-logaritmic regression model"
		`e(cmd)'
		di _n
	}
	
	// Estimate p and se(p)
	// Compute t ratios, p values and 95% ci's

	foreach v of local vars {
		local b_`v' = exp(_b[`v'] - 0.5*_se[`v']^2) - 1
		local se_`v' = sqrt(exp(2*_b[`v']) * ( exp(-_se[`v']^2) - exp(-2*_se[`v']^2) ))
		local t_`v' = `b_`v'' / `se_`v''
		local p_`v' = ttail(`e(df_r)', abs(`t_`v''))
		local l95_`v' = `b_`v'' - `se_`v'' * invttail(`e(df_r)',0.025)
		local u95_`v' = `b_`v'' + `se_`v'' * invttail(`e(df_r)',0.025)
	}

	// Print the results

	di as txt "Coefficients for the dummy variables in a semi-logaritmic regression model" _n
	di as txt "The coefficiemts stem from the following model: "
	di as res "`e(cmdline)'" _n

	di  as txt "{hline 13}" "{c TT}" "{hline 64}"
	
	di _col( 1) as txt %12s abbrev("`e(depvar)'", 12) _c
	di _col(14) as txt      "{c |}" _c
	di _col(15) as txt %11s "Coef." _c
	di _col(26) as txt %12s "Std. Err." _c
	di _col(37) as txt %8s  "t" _c
	di _col(46) as txt %10s  "P>|t|" _c
	di _col(58) as txt %21s "[95% Conf. Interval]"    	
	
	di  as txt "{hline 13}" "{c +}" "{hline 64}"

	foreach v of local vars {
		di _col( 1) as txt %12s abbrev("`v'", 12) _c
		di _col(14) as txt "{c |}" _c
		di _col(18) as res %8.0gc `b_`v'' _c
		di _col(30) as res %8.0gc `se_`v'' _c
		di _col(39) as res %8.2fc `t_`v'' _c
		di _col(48) as res %8.3fc `p_`v'' _c
		di _col(59) as res %8.0gc `l95_`v'' _c
		di _col(70) as res %8.0gc `u95_`v'' 
	}                    

	di as txt "{hline 13}" "{c BT}" "{hline 64}" _n

	// Return the results 

	foreach v of local vars {
		return scalar b_`v' = `b_`v''
		return scalar se_`v' = `se_`v'' 
	}
	
end

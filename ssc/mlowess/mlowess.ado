*! 1.0.0 NJC 13 Oct 2006 
program mlowess
	version 8 
	syntax varlist(numeric min=2) [if] [in], [ GENerate(str)  ///
	CYCles(int 3) DRaw(numlist >0 integer) ///
	LOG REPLACE Predict(str) noGRAPH lowess(str asis) ///
	noPTs SCatter(str asis) combine(str asis) OMit(numlist >0 integer) * ]

	quietly {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000 
		local nobs = r(N)
		
		gettoken lhs rhs : varlist
		local LHS : variable label `lhs' 
		if `"`LHS'"' == "" local LHS "`lhs'" 
		local J : word count `rhs'
		if `J' == 1 local cycles 1	// no convergence issue here
		
		if "`replace'" == "" local cnv confirm new var
		else local cnv cap drop

		if "`predict'" != "" `cnv' `predict'
		if "`generate'" != "" {
			forval j = 1/`J' {
				`cnv' `generate'`j'
			}
		}

		numlist "1/`J'" 
		local xlist "`r(numlist)'" 
		
		if "`omit'" != "" {
			if !`: list omit in xlist' {
				di as err "invalid omit(), variable number out of range"
				exit 198
			}
		}

		if "`draw'" != "" {
			if !`: list draw in xlist' {
				di as err "invalid draw(), variable number out of range"
				exit 198
			}
		}
			
		// centre data variables, initialise result variables 
		tokenize `rhs' 
		forval j = 1/`J' {
			tempvar x`j'
			gen double `x`j'' = ``j'' if `touse'
			sum `x`j'', meanonly 
			replace `x`j'' = `x`j'' - r(mean) 
			if `"`: var label ``j'''"' == "" { 
				label var `x`j'' "``j''" 
			}
			else label var `x`j'' `"`: var label ``j'''"' 
			local Rhs `Rhs' `x`j''
		}
		
		tempvar res partres pred
		tempname meany
		sum `lhs' if `touse', meanonly 
		scalar `meany' = r(mean)
		local min = r(min) 
		local max = r(max) 
		gen double `res' = `lhs' - `meany' if `touse'
		gen double `partres' = .
		
		// initialise the fj by linear regression

		regress `res' `Rhs' if `touse', nocons
		forval j = 1/`J' {
			tempvar f`j'
			gen double `f`j'' = _b[`x`j''] * `x`j'' if `touse'
			label var `f`j'' "`lhs' smoothed wrt F(``j'')"
		}	
	
		// backfitting: loop over `cycles' cycles 
		forval c = 1/`cycles' {
			// loop over covariates 
			forval j = 1/`J' {
				// partial residuals (i.e. excluding jth variable)
				replace `partres' = `res' if `touse'
				
				forval i = 1/`J' {
					if `i' != `j' ///
					replace `partres' = `partres' - `f`i''
				}
				
				tempvar new 
				lowess `partres' `x`j'' if `touse', ///
				nograph gen(`new') `lowess' 
				replace `f`j'' = `new' 
				drop `new' 

				sum `f`j'' if `touse', meanonly 
				replace `f`j'' = `f`j'' - r(mean)
			} // end loop covariates 
			
			if "`log'" != "" {	// monitor R^2
				gen double `pred' = `meany' if `touse'
				forval j = 1/`J' { 
					replace `pred' = `pred' + `f`j''
				}
				corr `pred' `lhs' if `touse'
				noi di as res %6.0f `c' %10.6f r(rho)^2
				drop `pred'
			}

		} // end loop cycles 
		
		// final overall predicted and individual smoothed 
		gen double `pred' = `meany' if `touse'
		forval j = 1/`J' { 
			replace `pred' = `pred' + `f`j''
			replace `f`j'' = `f`j'' + `meany'
		}
		corr `pred' `lhs' if `touse'
	}
	
	di _n as res `nobs' "{txt} observations, R-sq = " ///
	as res %6.4f r(rho)^2
	
	if "`graph'" != "nograph" {
/*
	Plot partial residuals y-sum_i(f_j, j != i) and 
	partial predictor, f_j, vs x_j
*/
		tempvar pres
		qui gen `pres' = .
		qui forval j = 1/`J' {
			local dothis 1
			if "`omit'" != "" {
				if `: list j in omit' local dothis 0
			}
			if "`draw'" != "" {
				local dothis 0
				if `: list j in draw' local dothis 1 
			}
			if `dothis' {
				tempfile g
				local l "line `f`j'' ``j''" 
				if "`pts'" != "nopts" {
					replace `pres' = `lhs' - (`pred' - `f`j'')
					local s "scatter `pres' ``j''" 
					local ms = cond(`nobs' < 300, "ms(oh)", "ms(p)") 
				
					`s', `ms' `scatter' ///
					|| `l', ytitle("`LHS'") sort nodraw ///
					ysc(r(`min',`max')) legend(off) `options' saving(`g')
				}
				else {
					`l', ytitle("`LHS'") sort nodraw ///
					ysc(r(`min',`max')) legend(off) `options' saving(`g')
				}			
				local G `"`G' "`g'" "'
			}
		}
		
		graph combine `G', `combine' 
	} 

	// Save new variables as necessary
		
	if "`predict'" != "" {
		`cnv' `predict'
		qui gen `predict' = `pred'
	}
	if "`generate'" != "" {
		forval j = 1/`J' {
			label var `f`j'' "`lhs' smoothed wrt F(``j'')"
			rename `f`j'' `generate'`j'
		}
	}
end

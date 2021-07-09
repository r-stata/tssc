*! 1.0.0 NJC 11 Oct 2006 
program fractileplot 
	version 8 
	syntax varlist(numeric min=2) [if] [in],          ///
	[ a(real 0.5) combine(str asis) CYCles(int 3)     ///
	DRaw(numlist >0 integer) GENerate(str) noGRAPH    ///
	locpoly LOCPOLY2(str asis) LOG lowess(str asis)   ///
	OMit(numlist >0 integer) Predict(str) noPTs       /// 
	REPLACE SCatter(str asis) * ] 

	quietly {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000 
		local nobs = r(N)

		if `"`locpoly'`locpoly2'"' != "" { 
			// will fail if not installed 
			which locpoly 

			if `"`lowess'"' != "" { 
				di as err "must decide between lowess and locpoly" 
				exit 198 
			}
		}	
		
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
			
		// Fs from data variables, initialise result variables 
		tokenize `rhs' 
		forval j = 1/`J' {
			tempvar x`j'
			egen `x`j'' = rank(``j'') if `touse'
			replace `x`j'' = (`x`j'' - `a') / (`nobs' - 2*`a' + 1)
			if `"`: var label ``j'''"' == "" { 
				label var `x`j'' "F(``j'')" 
			}
			else label var `x`j'' `"F(`: var label ``j''')"' 
			local Rhs `Rhs' `x`j''
		}
		
		tempvar res partres pred
		tempname meany
		sum `lhs' if `touse', meanonly 
		scalar `meany' = r(mean)
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

				if `"`locpoly'`locpoly2'"' == "" { 
					lowess `partres' `x`j'' if `touse', ///
					nograph gen(`new') `lowess' 
				}
				else locpoly `partres' `x`j'' if `touse', ///
					at(`x`j'') nograph gen(`new') `locpoly2' 

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
				local l "line `f`j'' `x`j''" 
				if "`pts'" != "nopts" {
					replace `pres' = `lhs' - (`pred' - `f`j'')
					local s "scatter `pres' `x`j''" 
					local ms = cond(`nobs' < 300, "ms(oh)", "ms(p)") 
				
					`s', `ms' `scatter' xla(0(0.25)1) ///
					|| `l', ytitle("`LHS'") sort nodraw ///
					legend(off) `options' saving(`g')
				}
				else {
					`l', xla(0(0.25)1) ytitle("`LHS'") sort ///
					nodraw legend(off) `options' saving(`g')
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

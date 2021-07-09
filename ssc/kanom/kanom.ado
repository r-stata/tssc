*! 1.0 Pablo A. Mitnik,  May 2014 
*! 2.0 Pablo A. Mitnik,  March 2016
*! 2.1 Pablo A. Mitnik,  March 2016
*! 3.0 Pablo A. Mitnik,  July 2016
*!
*! Computes Krippendorff's alpha for nominal variables and two measurements. 
*!
*! This program is a companion to the paper
*!         Mitnik, Pablo and Erin Cumberworth. 2016. "Measuring Social Class Trends with Changing Occupational Classifications: Reliability,
*!                                                    Competing Measurement Strategies, and the 1970-1980 U.S. Classification Divide," 
*!                                                    Stanford Center on Poverty and Inequality Working Paper.

program define kanom, eclass
	version 12
	syntax varlist(max=2 min=2) [, Wvar(varlist max=1) Cvar(varlist max=1) Svar(varlist max=1) NOInf]
	
	qui {	
			
	preserve
	
	/*select relevant sample, read variables*/

	local var1: word 1 of `varlist'
	local var2: word 2 of `varlist'

	foreach var in `var1' `var2' `wvar' `cvar' `svar' {
		drop if `var'>=.
	}	
	
	count
	local N  = r(N)
	
	tempvar w c
	
	/*weight variable*/
	
	if "`wvar'" == "" gen `w' = 1
	else gen `w'=`wvar'
	
	if "`noinf'"=="" {		
	
		/*cluster variable ("observations" in coincidence matrix are never independent)*/

		if "`cvar'" == "" gen `c' = _n
		else gen `c'=`cvar'

		/*strata variable*/
		if "`svar'" == "" local strata 
		else local strata strata(`svar')	

		/*generate coincidence matrix*/

		tempfile half1
		save `half1', replace

		rename (`var1' `var2') (`var2' `var1')
		append using `half1'

		svyset `c' [pw=`w'], `strata'

		svy:tab `var1' `var2', count

		/*compute kalpha from coincidence matrix*/

		scalar totvals = `e(total)'  /*weighted total, which should be equal to 2N*/

		qui tab `var1', nofreq       /*number of different values in var1 and var2*/
		local r = r(r)
		local q = r(r)

		foreach row of numlist 1/`r' {

			/*generate expression equivalent to local  rowsum`row' (totvals * (_b[p`row'1] + _b[p`row'2] + _b[p`row'3] + _b[p`row'4] + _b[p`row'5]) )
			  (for the case with 5 values) but for the general case with any number of values*/

			foreach col of numlist 1/`q' {

				if `col'==1 local bterms  _b[p`row'`col'] 
				else        local bterms `bterms' + _b[p`row'`col']
			}

			local  rowsum`row' (totvals * (`bterms' ))

			local bterms
		}

		/*generate expression equivalent to the kalpha terms for the terms in ( `rowsum1' * (`rowsum1' - 1) + `rowsum2' * (`rowsum2' - 1) + `rowsum3' * (`rowsum3' - 1) + `rowsum4' * (`rowsum4' - 1) + `rowsum5' * (`rowsum5' - 1) )
		  (for the case with 5 values) but for the general case with any number of values*/

		foreach row of numlist 1/`r' {

			local rowsumprod`r' `rowsum`row'' * (`rowsum`row'' - 1) 
			local j=`row'+1
			local kj (kalpha`j': `rowsumprod`r'')
			local kterms `kterms' `kj'
		}


		/*generate expression equivalent to local trace (_b[p11] + _b[p22] + _b[p33] + _b[p44] + _b[p55]) 
		  (for the case with 5 values) but for the general case with any number of values */

		foreach row of numlist 1/`r' {

			if `row'==1 local bterms2 _b[p`row'`row'] 
			else        local bterms2 `bterms2' + _b[p`row'`row']
		}	

		local trace (`bterms2') 

		qui nlcom (kalpha1: ((totvals - 1) *  totvals * `trace')) `kterms', post

		foreach term of numlist 1/`r' {

			local r2=`term'+1

			if `term'==1 local kterms2 _b[kalpha`r2']
			else local kterms2 `kterms2' + _b[kalpha`r2'] 
		}	

		local kterms2 (`kterms2')

		nlcom ( kalpha: (_b[kalpha1] - `kterms2')  / ((totvals - 1) *  totvals - `kterms2') ), post

		/*inference and return results */
		/*computation below matches nlcom output: checked*/
		/*for use of t distribution instead of normal:
		  www.stata.com/manuals13/svy.pdf, section on
		  variance estimation*/

		scalar tval = invttail(e(df_r), 0.025)
		mat b = e(b)
		mat V = e(V)
		scalar pe = b[1,1]
		scalar se = V[1,1]^(1/2)

		scalar lb = pe - tval * se
		scalar ub = pe + tval * se

		foreach testval in 0.67 0.75 0.80 {

			test _b[kalpha]=`testval'
			local sign_kalpha = sign(_b[kalpha] -`testval')
			local pvalue = ttail(r(df_r),`sign_kalpha'*sqrt(r(F)))

			local testvallab = `testval' * 100

			scalar pval_`testvallab'= `pvalue'
		}	
	
	} /*closes if for "`noinf'-=""*/
	
	
	if "`noinf'"!="" {	

		/*generate coincidence matrix*/

		tempfile half1
		save `half1', replace

		rename (`var1' `var2') (`var2' `var1')
		append using `half1'		
		
		tab `var1' `var2' [iw=`w'],  matcell(freq) 
		
		tempfile cont
		save `cont', replace
		
		/*compute kalpha*/
		
		collapse (sum) `w'						
		
		scalar totvals = `w'[1]        /*weighted total, which should be equal to 2N*/
						
		local cols = colsof(freq)
				
		scalar agreements = 0 
		
		foreach i of numlist 1/`cols' {
		
			scalar agreements = agreements + freq[`i', `i']
		}
		
		scalar num1 = (totvals - 1) * agreements
		
		use `cont', clear
		
		tab `var1'  [iw=`w'],  matcell(mfreq) 			
		
		scalar num2 = 0
		
		foreach i of numlist 1/`cols' {
			
			scalar num2 = num2 + (mfreq[`i',1] * (mfreq[`i',1] - 1))
		}
		
		scalar den1 = totvals * (totvals - 1)
		
		scalar den2 = num2
		
		scalar pe = (num1 - num2) / (den1 - den2)
	
	} /*closes if for "`noinf'!=""*/
	
	ereturn clear
	
	if "`noinf'"=="" {	
	
		if "`svar'" != "" eret local svar "`svar'" 
		if "`cvar'" != "" eret local cvar "`cvar'" 
		if "`wvar'" != "" eret local wvar "`wvar'" 
	}	
	eret local var2 "`var2'"
	eret local var1 "`var1'"
	eret local cmd "kanom"	
	
	eret scalar N   = `N'
	eret scalar pe = pe
	if "`noinf'"=="" {	
		eret scalar lb = lb
		eret scalar ub = ub
		eret scalar se = se
		eret scalar p_67 = pval_67
		eret scalar p_75 = pval_75
		eret scalar p_80 = pval_80
	}
	
	/*display results*/
	
	noi di " "
	noi di "Krippendorff's alpha"
	noi di " "
	noi di "   Variable 1: `var1'"
	noi di "   Variable 2: `var2'"
	
	if "`noinf'"=="" {	
		if "`wvar'" != "" noi di "   Weight variable: `wvar'"
		if "`cvar'" != "" noi di "   Cluster variable: `cvar'"
		if "`svar'" != "" noi di "   Stratum variable: `svar'"
	}
	
	noi di ""
	noi di "   Number of observations: `N'"
	
	local pe: di %5.3f pe
	noi di "   Point Estimate: " `pe'
	
	if "`noinf'"=="" {		
	
		local lb: di %5.3f lb
		local ub: di %5.3f ub	
		local p67: di %5.3f pval_67
		local p75: di %5.3f pval_75
		local p80: di %5.3f pval_80			
	
		noi di "   Lower bound: `lb'"
		noi di "   Upper bound: `ub'"
		noi di "   P-value H0 <= 0.67: `p67'"
		noi di "   P-value H0 <= 0.75: `p75'"
		noi di "   P-value H0 <= 0.80:  `p80'"
	}	
		
	} /*qui*/
	
	restore
		
end



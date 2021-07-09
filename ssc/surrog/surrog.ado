//Last version: 2014/02/15 by Malte Hoffmann
program define surrog
version 11.2
mat loadings=e(r_L) /*Loadings Matrix*/
loc numfactors=e(f) /*Number of Factors*/
loc numvars=rowsof(e(r_L)) /*Number of Variables (saved in Rows)*/
loc namesn : word count `names'  /*Number of Variables (saved in Rows)*/


mat b = e(r_L) /*Acquire the names of the variables */
local names : rownames b
loc finvar
loc sortvar
di _dup(41) "-"
di "Surrogate Variables for `numfactors' Factors:"
forvalues i=1/`numfactors'{

	
	loc localmax`i'=0
	loc survar
	
	forvalues j=1/`numvars'{
	
	loc a=abs(loadings[`j',`i'])			
		if `a'>`localmax`i'' {
			loc names_v`j': word `j' of `names'
			loc localmax`i'=abs(loadings[`j',`i'])
			loc survar="`names_v`j''"
		}
	
	}
	loc sortvar "`sortvar' `survar'"
	loc finvar "`finvar' `survar' -> `i';"

	dis "Factor `i': `survar'"
	
} 
di _dup(41) "-"
di "List of surrogate variables:"
dis "`sortvar'"
end




*! version 1.0.0 Juni 7, 2016 @ 17:45:28
*! Merge  by similarity (accoring Levenshtein)
program  sqstrmerge
version 14

	// Parsing
	// -------
	
	gettoken mergetype 0 : 0 

	if !inlist("`mergetype'","1:1","m:1","1:m") {
		display `"{err} sqstrmerge does not support `mergetype'-matches"'
		exit 189
	}
	
	syntax varlist using , ///
	  max(string)  ///
	  [ , INDELcost(passthru)  ///
	  SUBcost(passthru)  ///
	  k(passthru)  ///
	  standard(passthru) ///
	  IGNOREcase  ///
	  ASCIILETTERSonly  ///
	  SOUNDex * ]

	preserve

	quietly {

		ds
		local masterorder `r(varlist)'

		// Create fuzzy varlist
		if `: word count `varlist'' != `: word count `max'' {
			noi display `"{err}number of limits in max() does not match number of keyvars"'
			exit 189
		}
	local i 1
		foreach var of local varlist {
			if `: word `i++' of `max''>0 {
				noi confirm string variable `var' 
				local fuzzylist `fuzzylist' `var'
			}
		}
		local maxlist = subinstr("`max'"," 0 "," ",.)
		
		
		// Create a Metafile for each fuzzyvar
		// -----------------------------------
		
		tempvar  _merge x master
		tempfile this
		
		save `master', replace
		
		local i 1
		foreach var of local fuzzylist {
			tempfile fm_`var' fu_`var' exactmatches_`var' meta_`var'
			local thisvarmax : word `i' of `max'
			
			keep `var'
			bysort `var': keep if _n==1
			save `fm_`var''
			
			use `var' `using', clear
			bysort `var': keep if _n==1
			save `fu_`var''
			
			use `fm_`var'', clear
			merge 1:1 `var' using `fu_`var''
			ren _merge `_merge' 
			
			save `this', replace 
			keep if `_merge' == 3
			gen _`var'_using = `var'
			gen _`var'_distance = 0
			save `exactmatches_`var'', replace
			
			use `this' 
			keep if inlist(`_merge',1,2)
			
			gen _`var'_using = ""
			gen _`var'_distance = .
			forv j = 1/`thisvarmax' {
				egen `x' = sqstrnn(`var') if mi(_`var'_using) ///
				  , by(`_merge')  max(`j') ///
				  `k' `indel' `sub' `standard' `asciilettersonly'  ///
				  `ignorcase' `soundex'  
				
				replace _`var'_using = `x' if mi(_`var'_using)
				replace _`var'_distance = `j' if mi(_`var'_distance) & !mi(`x')
				drop `x'
			}
			keep if `_merge' == 1
			
			// Check uniqueness of approximates ...
			tempvar n mis
			gen byte `mis' = mi(_`var'_using)
			
			capture by `mis' _`var'_using (_`var'_distance), sort:  ///
			  assert _N == 1 if !`mis'
			if _rc {
				by `mis' _`var'_using (_`var'_distance): ///
				  replace _`var'_using = "" if _n >= 2 & !mi(_`var'_using)
				bys `mis' _`var'_using (_`var'_distance): ///
				  replace _`var'_distance = . if _n >= 2 & !mi(_`var'_distance)
			}

			append using `exactmatches_`var''

			save `meta_`var'', replace
			use `master', clear
		}
		
		
		// Merge Meta to Master and Using to Master using meta_vars
		// --------------------------------------------------------
		
	
		foreach var of local fuzzylist {
			tempvar x_`var'

			merge m:1 `var' using `meta_`var'', assert(3)
			drop _merge

			clonevar `x_`var'' = `var'
			replace `var' = _`var'_using if !mi(_`var'_using)
		}
		
		merge `mergetype' `varlist' `using', `options'

		foreach var of local fuzzylist {
			
			replace `var' = `x_`var'' if !mi(`x_`var'')
			order _`var'_using _`var'_distance, last

			noisily tabulate  _`var'_distance _merge, mis
		}
		order `masterorder'

	

	}

restore, not 

	
end
exit





		

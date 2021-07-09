*!revrs v1.0.1 12apr2007
*Author: Kyle C Longest, klongest@email.unc.edu
*Reorders categorical variables and maintains value labels

capture program drop revrs
program define revrs, rclass
version 8.2
syntax varlist(numeric) [, REPLace]
local v `varlist'
unab vars: `v'

if "`replace'"=="" {
	qui foreach var of local vars {
		su `var'
		local `var'max = r(max)
		tempvar revt`var'
		gen `revt`var''= `var' - ``var'max'
		replace `revt`var'' = abs(`revt`var'')
	}

	qui foreach var of local vars {
		tempvar revl
		capture decode `var', g(`revl')
			if _rc == 0 {
			capture sencode `revl', gen(rev`var') gsort(`revt`var'')
			}
			else {
				replace `revt`var'' = `revt`var'' + 1
				rename `revt`var'' rev`var'
			}	
	replace rev`var' = `var' if `var'>``var'max'		
	}
}

if "`replace'" == "replace" {
	qui foreach var of local vars {
		su `var'
		local `var'max = r(max)
		tempvar revt`var'
		gen `revt`var''= `var' - ``var'max'
		replace `revt`var'' = abs(`revt`var'')
	}

	qui foreach var of local vars {
		tempvar revl`var'
		capture decode `var', g(`revl`var'')
		   if _rc==0 {
			sencode `revl`var'', gen(rev`var') gsort(`revt`var'')
			replace rev`var' = `var' if `var'>``var'max'
			drop `var'
			rename rev`var' `var' 
		  }
		   else {
			replace `revt`var'' = `revt`var'' + 1
			replace `revt`var'' = `var' if `var'>``var'max'
			replace `var' = `revt`var''
			}
	}
}
end


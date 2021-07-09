*! version 1.0.0 September 18, 2007 @ 18:19:21
*! clears validation rules characteristics
program define ckvarclear
version 9
	syntax [varlist] [, STUBs(str)]
	if "`varlist'"=="" {
		error 3
		}
	if "`stubs'"=="" {
		local stubs "valid"
		}
	foreach var of local varlist {
		foreach stub of local stubs {
			local chars: char `var'[]
			foreach char of local chars {
				if strpos("`char'","`stub'_")==1 {
					char `var'[`char']
					}
				}
			}
		}
end

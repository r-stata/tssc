*! version 1.0.0 August 24, 2007 @ 10:23:41
*! updates _check chars to _rule chars to match error message etc.
program define ckvarupdate
version 9
	syntax [, stubs(str)]
	unab varlist: *
	if "`stubs'"=="" {
		local stubs "valid"
		}
	foreach var of local varlist {
		foreach stub of local stubs {
			local chars: char `var'[]
			foreach char of local chars {
				if strpos("`char'","_check")==length(`"`stub'"')+1 {
					local theChar : char `var'[`char']
					char `var'[`stub'_rule] `"`macval(theChar)'"'
					char `var'[`char']
					}
				}
			}
		}

end

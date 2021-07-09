*! version 1.0.3 September 17, 2007 @ 17:13:01
*! runs a keep, but ensures that all variables needed for validation (or other char testing) are kept
program define ckkeep, rclass
version 9
	/* 1.0.2 - updated to use _ckneeded for checking dependencies */
	/*       - changed -what()- to -stubs()- to allow many stubs */
	local myname "ckkeep"
	syntax varlist, [listonly stubs(str) caller(str)]
	if "`stubs'"=="" {
		local stubs "valid"
		}
	if "`caller'"=="" {
		local caller "`myname'"
		}
	foreach stub of local stubs {
		capture n _ckneeded `varlist', stubs(`stubs')
		if _rc {
			display as error "`caller': had trouble evaluating needed variables; dataset unchanged."
			exit _rc
			}
		local extras "`extras' `r(extras)'"
		}

	if "`extras'"!=" " {
		display as text "Need to keep the following additional variables to allow characteristic(s)"
		foreach stub of local stubs {
			display as input " `stub'_rule" _continue
			}
		display as text " to keep functioning:"
		display as result "`extras'"
		}
	if "`listonly'"=="" {
		keep `varlist' `extras'
	   }
	return local needed "`varlist' `extras'"
end

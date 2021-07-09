*! version 1.0.0 September 17, 2007 @ 17:12:28
*! finds all variables needed to check a given variable via ckvar
program define _ckneeded, rclass
version 9
	/* not much error checking, because of being a utility */
	/* assumes usage as part of ckvar, so all that is specified are stubs */
	local myname "_ckneeded"
	syntax [varlist], stubs(str) [nolikeerror]
	local allNeeded "`varlist'"
	if "`stubs'"=="" {
		local stubs "valid"
		}
	if "`likeerror'"!="" {
		local capture "capture"
		}
	foreach stub of local stubs {
		foreach var of local allNeeded {
			`capture' _ck4like `var', evalchar(`stub'_rule)
			if `r(islike)' {
				capture n unab like: `r(like)'
				if _rc==111 {
					display as error "`myname': variable " as input "`var'" as error " uses " as input "like `like'" as error " but `like' cannot be found!"
					exit 111
					}
				else {
					error _rc
					}
				local allNeeded: list allNeeded | like
				}
			local nchar : char `var'[`stub'_other_vars_needed]
			if "`nchar'"!="" {
				capture n unab nchar: `nchar'
				if _rc {
					if _rc==111 {
						display as error "`myname': variable " as input "`var'" as error " needs " as input "`nchar'" as error ", but at least one variable from the list"
						display as input "`nchar'"
						display as error "cannot be found!"
						local allNeeded: list allNeeded | nchar
						local extras: list allNeeded - varlist
						return local varlist "`varlist'"
						return local extras "`extras'"
						exit 111
						}
					else {
						error _rc
						}
					}
				local allNeeded: list allNeeded | nchar
				}
			}
		}
	local extras: list allNeeded - varlist
	return local varlist "`varlist'"
	return local extras "`extras'"
end

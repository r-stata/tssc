*! version 1.0.1 September 14, 2007 @ 16:59:50
*! runs a rename, but first checks to see if the variable is used in another variables validation
program define ckrename, rclass
version 9
	/* 1.0.2 - changed the -what()- option to -stubs()- option to match other commands */
	/* 1.0.1 - fixed to run through all variables to find all dependencies... */
	local myname "ckrename"
	syntax anything, [stubs(str) listonly]
	local oldName: word 1 of `anything'
	local newName: word 2 of `anything'
	unab oldName : `oldName', min(1) max(1) name("ckrename:")
	if `"`2'"'=="" {
		display as error "need to have a new name!"
		exit 198
		}
	confirm new var `newName'
	local numNames: word count `anything'
	if `numNames'>2 {
		display as error "`myname': too many variable names specified!"
		exit 198
		}
	if `"`stubs'"'=="" {
		local stubs "valid"
		}

	foreach stub of local stubs {
		foreach var of varlist * {
			local possible
			local theChar : char `var'[`stub'_rule]
			_ck4like `var', evalchar(`stub'_rule) caller(ckrename)
			if `r(islike)' {
				local possible "`r(like)'"
				}
			local theChar : char `var'[`stub'_other_vars_needed]
			unab possible : `possible' `theChar', min(0)
			local foundIt : list oldName in possible
			if `foundIt' {
				local callingVars "`callingVars' `var'"
				}
			}
		}
	local callingVars: list uniq callingVars
	local callingVars: list callingVars - oldName
	if "`callingVars'"!="" {
		display as error "The following variable(s) make use of `oldName' for characteristic(s)"
		foreach stub of local stubs {
			display as input " `stub'_rule" _continue
			}
		display as error " to keep functioning:"
		display as result " `callingVars'"
		display as error "Change the dependencies before renaming!"
		exit 119
		}
	if "`listonly'"=="" {
		rename `oldName' `newName'
		}
	return local callingVars `callingVars'
end

*! version 1.0.0 September 6, 2007 @ 10:24:43
*! manages the 'next' variable when using the -stepthru- option on ckvaredit
program define _ckvarnext
version 9
	capture syntax, allvars(varlist) onevar(varname)
	if !_rc {
		local numVars : word count `allvars'
		local thePos : list posof "`onevar'" in allvars
		if `thePos' < `numVars' {
			local ++thePos
			local onevar : word `thePos' of `allvars'
			}
		/* explicit dependency on ckvaredit dialog names */
		.ckvaredit_dlg.onevar.setstring `onevar'
/* 		char _dta[_onevar_] `onevar' */

		/* 		display as result "found onevar `onevar'" */
		}
end

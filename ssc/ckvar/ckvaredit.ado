*! version 1.0.0 September 6, 2007 @ 09:44:51
*! edits chars for ckvar
program define ckvaredit
version 9
	syntax [varlist] [, STEPthru]

	if "`varlist'"=="" {
		display as result "No variables to edit!"
		exit
		}

	local cntvars : word count `varlist'
	capture n {
		char _dta[_vars_] `varlist'
		char _dta[_stepthru_] `stepthru'
		if `cntvars'==1 | "`stepthru'"!="" {
			local aVar : word 1 of `varlist'
			char _dta[_onevar_] `aVar'
			}
		else {
			char _dta[_onevar_]
			}
		db ckvaredit
		}
	local rc = _rc
	char _dta[_stepthru_]
	char _dta[_onevar_]
	char _dta[_vars_]
	if _rc {
		exit `rc'
		}
end

program define ilses
	version 11
	syntax  varlist(max=1), ses(string)
qui {
local i=0
tempvar cbs_var_nam
tempname cbs_source sesmat
	preserve
	
use `"`c(sysdir_plus)'i\il94ses.dta"', clear
mkmat cbs, matrix(`cbs_source')
mkmat ses, matrix(`sesmat')

restore

di "why?"

capture confirm str variable `varlist'
                if !_rc {
				    destring `varlist', force gen(`cbs_var_nam')
				}
				else {
				    gen `cbs_var_nam'=`varlist'
				}



gen `ses'=.
local endmat=rowsof(`cbs_source')
forvalues i=1 2 to `endmat'  {

	local cb_1=`cbs_source'[`i',1]
	local oc=`sesmat'[`i',1]
	   	   replace `ses'=`oc' if `cbs_var_nam'==`cb_1'
	}

local t=0
}
noi di "`ses' generated using Semyonov, Lewin-Epstein and Mandel’s (2000) SES score"
end

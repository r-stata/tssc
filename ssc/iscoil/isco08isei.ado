program define isco08isei
	version 11
	set matsize 600
	syntax  varlist(max=1), isei(string)
qui {
local i=0
tempvar cbs_var_nam
tempname cbs_source sesmat
	preserve
	
use `"`c(sysdir_plus)'i\isco08isei.dta"', clear
mkmat isco08, matrix(`cbs_source')
mkmat isei, matrix(`sesmat')

restore


capture confirm str variable `varlist'
                if !_rc {
				    destring `varlist', force gen(`cbs_var_nam')
				}
				else {
				    gen `cbs_var_nam'=`varlist'
				}



gen `isei'=.
local endmat=rowsof(`cbs_source')
forvalues i=1 2 to `endmat'  {

	local cb_1=`cbs_source'[`i',1]
	local oc=`sesmat'[`i',1]
	   	   replace `isei'=`oc' if `cbs_var_nam'==`cb_1'
	}

local t=0
}
noi di "`isei' generated using Ganzeboom's (2010) ISEI score"
end

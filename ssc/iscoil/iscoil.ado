program define iscoil
	version 11
	syntax  varlist(max=1), isco(string)
qui {
local i=0
tempvar cbs_var_nam
tempname cbs_source iscomat


	preserve
	
use `"`c(sysdir_plus)'i/il94crosswalk.dta"', clear
levelsof isco08, local(names)
mkmat CBS_occup, matrix(`cbs_source')
mkmat isco, matrix(`iscomat')

restore

levelsof `varlist', local(cbs)
capture confirm str variable `varlist'
                if !_rc {
				    destring `varlist', force gen(`cbs_var_nam')
				}
				else {
				    gen `cbs_var_nam'=`varlist'
				}

				
gen `isco'=.
local endmat=rowsof(`cbs_source')
forvalues i=1 2 to `endmat'  {

	local cb_1=`cbs_source'[`i',1]
	local oc=`iscomat'[`i',1]
	   	   replace `isco'=`oc' if `cbs_var_nam'==`cb_1'
	}

local t=0

levelsof `isco', local(labnum)

foreach nam of local names {
    local t=`t'+1
	local is=`iscomat'[`t',1]
	label define isco08 `is' "`nam'", modify
	label values `isco' isco08 
}
}

noi di "`isco' generated using ISCO08 classification, lables saved as isco08"
end

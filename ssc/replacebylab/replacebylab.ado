*-------------------------------------------------------------------------------
*            
*  REPLACEBYLAB: Stata module to replace values by drawing on value labels  
*  Version 0.8
*  Author(s): Gummer, Tobias 	- GESIS - Leibniz-Institute for the Social Sciences 	
*
*-------------------------------------------------------------------------------

program replacebylab
version 13
syntax varlist [if] [in], LABel(string) SETVALue(numlist) [SUBSTR] [NEWLABel(string)] [DISplay] [DELLAB]

marksample touse, novarlist

* Error messages:

	
quietly {
	foreach var of varlist `varlist' {
		capture confirm string variable `var'
		if _rc {
			local varlab: value label `var'
			if "`varlab'"!="" {
				quietly sum `var'
				local min = r(min)
				local max = r(max)
				forvalues k = `min' / `max' {
					local lab: label `varlab' `k', strict
					local lab: subinstr local lab `"`=char(34)'"' "`=char(32)'",all
					if "`substr'"!=""	{
						if strmatch("`lab'","*`label'*")	{
							if "`display'"=="" {
								replace `var'=`setvalue' if `var'==`k' & `touse'							
							}
							if "`display'"!="" {
								noisily dis as result "`var': substring '`label'' in value label '`lab'' detected."
								noisily replace `var'=`setvalue' if `var'==`k' & `touse'
							}
							if "`newlabel'"!="" {
								label def `varlab' `setvalue' "`newlabel'", modify
							}
							if "`dellab'"!="" {
								lab def `varlab' `k' "", modify
							}
						}
					}
					if "`substr'"==""	{
						if "`lab'"=="`label'"	{
							if "`display'"=="" {
								replace `var'=`setvalue' if `var'==`k' & `touse'							
							}
							if "`display'"!="" {
								noisily dis as result "`var': value label '`label'' detected."
								noisily replace `var'=`setvalue' if `var'==`k' & `touse'
							}							
							if "`newlabel'"!="" {
								label def `varlab' `setvalue' "`newlabel'", modify
							}
							if "`dellab'"!="" {
								lab def `varlab' `k' "", modify
							}							
						}
					}	
				}
			}
		}
	}
}


end
exit

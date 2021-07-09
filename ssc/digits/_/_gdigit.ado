*! version 1.00 copyright Richard J. Atkins 2005
program define _gdigit
	version 7.0

	gettoken type 0 : 0
	gettoken g    0 : 0
	gettoken eqs  0 : 0
	
* Parse command, validate arguments and set defaults
	syntax varname(numeric) [if] [in] [, Digit(numlist min=0 max=1 int <=9 >=-9) Round(numlist min=0 max=1 int <=15 >=0)] 
	if ("`digit'" == "") { local digit=0 } 
	if ("`round'" == "") { local round=15 }

	qui summ `varlist'
	local leftplaces=int(log10(r(max)))
	if (`digit'>`leftplaces') { 
		di in r "Digit 10^`digit' is higher than highest digit at 10^`leftplaces'" 
		exit 459 
	} 
	if (`digit'< -`round') { 
		di in r "Digit 10^`digit' is lower than the current rounding limit of 10^-`round'" 
		exit 459 
	} 
	
	marksample touse

	quietly {
		gen `type' `g'=.
		tempvar asstring

		local strchars = `leftplaces'+`round'+2
		local useformat = "%0" + string(`strchars') + "." + string(`round') + "f"

		gen str`strchars' `asstring' = ""
		replace `asstring' =string(`varlist', "`useformat'") if(.!=`varlist')
		if (`digit'>=0) {
			qui replace `asstring'=substr(`asstring',`leftplaces'+1-`digit',1)
		}
		else {		
			qui replace `asstring'=substr(`asstring',`leftplaces'+2-`digit',1)
		}
		replace `g' = real(`asstring')
		label var `g' "10^`digit' digit of `varlist'"
	}
end


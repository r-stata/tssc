*! v1.0, 21may2017, Jan Helmdag

/*
Abstract: Generate inverse hyperbolic sine (IHS)-transformed variables out of a list of multiple variables
*/

program ihstrans
version 12.0

syntax [varlist(ts)] [if] [in], [Keepusing(varlist)] [Prefix(string)] [Casewise]


*Check for observations
	if "`casewise'"!="" {
	marksample touse, strok
		quietly count if `touse'
		if `r(N)' == 0{
		error 2000
		}
	}
	
*Build new varlist without string variables
foreach var in `varlist' {
	local `var'_fmt: format `var'
	if regexm("``var'_fmt'","s")==0 {
		local varlistnumeric `varlistnumeric' `var'
	}
}
	
*Modify varlist
	if "`keepusing'"!="" {
		local varlistnumeric = regexr("`varlistnumeric'","`keepusing'","")
	}

*Clear varlist of identifiers for panels and time
	capture _xt
		if "`r(tvar)'" == "" {
			local varlistnumeric `varlistnumeric'
		}
		else {
				local varlistnumeric = regexr("`varlistnumeric'","`r(tvar)'","")
		}

		if "`r(ivar)'" == "" {
			local varlistnumeric `varlistnumeric'
		}
		else {
			local varlistnumeric = regexr("`varlistnumeric'","`r(ivar)'","")
		}

*Handle prefix
	if "`prefix'"=="" {
		local pre ihs_
	}
	else {
		local pre `prefix'
	}
		
*Generate variables
	
	*Casewise combination
	if "`casewise'"=="" {	
		foreach var in `varlistnumeric' {
			gen double `pre'`var' = log(`var'+sqrt(`var'^2+1)) `if' `in'
			label var `pre'`var' "IHS trans. values of `var'"
			quietly summ `pre'`var'
			if `r(N)' == 0{
				drop `pre'`var'
			}
		}
	}
	
	*Plain
	else {
		foreach var in `varlistnumeric' {
			gen double `pre'`var' = log(`var'+sqrt(`var'^2+1)) if `touse'
			label var `pre'`var' "IHS trans. values of `var'"
			quietly summ `pre'`var'
			if `r(N)' == 0{
				drop `pre'`var'
			}
		}
	}
end

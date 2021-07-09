*! v1.3.0 8Sep2005
/* added "joint" option to go with metareg.ado v2.3.1 */
program define metareg_pm, rclass
version 7
	syntax varlist [if], xvars(varlist numeric) [ univariable joint(string) ] *
	tokenize `varlist'
	args y wsvar n
	marksample touse
	tempvar xp z zabs
	tempname zi

	foreach x of varlist `xvars' {
		gen `: type `x'' `xp' = `x'[`n'] if `touse'
		drop `x'
		rename `xp' `x'
		}
	
	if "`univariable'" == "" { /* single multiple meta-regression */
		metareg `y' `xvars' if `touse', wsvar(`wsvar') notaucomp `options'

		foreach x of varlist `xvars' {
			scalar `zi' = _b[`x'] / _se[`x']
			return scalar z_`x' = `zi'
			}
		}
	
	else {   /* separate univariable meta-regressions */
		foreach x of varlist `xvars' {
			metareg `y' `x' if `touse', wsvar(`wsvar') notaucomp `options'
			scalar `zi' = _b[`x'] / _se[`x']
			return scalar z_`x' = `zi'
			}
		}


	while "`joint'" != "" {
			gettoken tmp joint : joint, parse("\/|")
			if strpos("\/|", "`tmp'")  {
				continue
				}
			local 0 `tmp'
			syntax varlist
			local j = `j' + 1
			qui test `varlist'
			if "`r(chi2)'" != "" {
				return scalar chi2`j' = r(chi2)
				}
			else {
				return scalar chi2`j' = r(F) * r(df)
				}
			}
		
	
end


	
	

*! fmlogit_pr version 1.00 - Last update: Mar 26, 2012  
*! Authors: Daniele Pacifico (daniele.pacifico@tesoro.it)
*!			Hong il Yoo (h.yoo@unsw.edu.au)
*! 	
*! Note: this program is a modified (and simplified) version of 
*! 	   -fmlogit_p.ado- authored by Maarten L. Buis. 
*!	   The modification has been made to generate hard-coded 
*!		double-precision variables corresponding to class shares.     

program define fmlogit_pr
	version 11.2
	syntax [anything] [if] [in]
	local depvars "`e(depvars)'"
	gettoken ref rest : depvars
	local i = 1
	tempvar denom
	qui gen double `denom' = 1
	foreach eq of local rest {
		tempvar xb`i'
		qui _predict double `xb`i'' `if' `in', xb equation(#`i')
		qui replace `denom' = `denom' + exp(`xb`i'') `if' `in'
		local `i++'
	}
	local j = 1
	foreach var of local anything {
		if `j' == 1 {
			gen double `var' = 1/`denom' `if' `in'
		}
		else {
			gen double `var' = exp(`xb`=`j'- 1'')/`denom' `if' `in'
		}
		local `j++'
	}
end

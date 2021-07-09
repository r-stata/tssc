*! 1.1 Oct 7th Jan Brogger
capture program drop _genv
program define _genv
	version 6.0
	syntax ,   headp(string) [pre(string) restp(string) level(integer 0 ) cmds(string) VERBose]
	
	local head `headp'
	local rest `restp'

	local level=`level'+1
	gettoken var numl : head , parse("()")
	gettoken numl : numl , match(parens)
	numlist "`numl'"
	local numl "`r(numlist)'"
	local  n : word count `numl'

	if "`verbose'"~="" { di "."}


	capture confirm new v `var'
	if _rc == 0 {
		qui generate `var'=.
	}

	local i=1
	while `i'<=`n' {
		local j : word `i' of `numl'
		local this="`var'=`j'"

		if "`rest'"~="" {
			gettoken nhead nrest:rest , match(parens)
			_genv , pre("`pre' `this'") headp("`nhead'") restp("`nrest'") level(`level') `verbose'
		}
		else {
			if "`verbose'"~= "" { di _dup(`level') " " "`pre' `this'" }

			local newobs=_N+1

			qui set obs `newobs'

			tokenize "`pre' `this'"
			while "`1'"~= "" {
				local token "`1'"
				gettoken var valu : token , parse(=)
				gettoken drop valu  : valu , parse(=)

				qui replace `var'=`valu' if _n==_N
				mac shift 1
			}
			
		}
		local i =`i'+1
	}
end


*! version 1.0.1  NJC 24 April 1998
* version 1.0.0  NJC 27 Jan 1998
program define pweibull4 
	version 4.0
	local varlist "req ex max(1)"
	local if "opt"
	local in "opt"
    	#delimit ;
	local options "Symbol(string) noBorder Connect(string)
	YLAbel(string) XLAbel(string) GRid B(real -1) C(real -1) *" ;
        #delimit cr
	parse "`*'"
	
	tempname B C
	if `b' <= 0 | `c' <= 0 {
        	if "$S_2" != "" & "$S_3" != "" {
		        scalar `B' = $S_2
		        scalar `C' = $S_3
	        }
        	else {
			di in r "need to know values of parameters, both positive"
			exit 198
	        }
	}
	else {
        	scalar `B' = `b'
	        scalar `C' = `c'
	}

	if "`symbol'" == "" { local symbol "oi" }
	else { local symbol "`symbol'i" }
	if "`connect'" == "" { local connect ".l" }
	else { local connect "`connect'l" }
	if "`ylabel'" == "" { local ylabel "0,.25,.5,.75,1" }
	if "`xlabel'" == "" { local xlabel "0,.25,.5,.75,1" }
	if "`grid'" != "" { local grid "yli(.25,.5,.75) xli(.25,.5,.75)" }

	tempvar touse F Psubi
	qui {
		gen byte `touse' = cond(`varlist' == .,.,1) `if' `in'
		sort `varlist'
		gen float `F' = 1 - exp(-((`varlist'/`B')^`C')) if `touse'
		gen float `Psubi' = sum(`touse')
		replace `Psubi' = cond(`F' == .,.,(`Psubi'-0.5)/`Psubi'[_N])
	}

	local yl: variable label `varlist'
	if "`yl'" == "" {	local yl "`varlist'" }
	label var `F' "Weibull F[`yl']"
	label var `Psubi' "Empirical P[i] = (i-0.5) / N"
	format `F' `Psubi' %9.2f
	if "`border'" == "" { local bo "border" }

	graph `F' `Psubi' `Psubi', c(`connect') s(`symbol') /*
		*/ ylab(`ylabel') xlab(`xlabel') `bo' `grid' `options'
end

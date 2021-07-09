*! version 1.0.1  NJC 24 April 1998
* version 1.0.0  NJC 27 Jan 1998
program define qweibull4
	version 4.0
	local varlist "req ex max(1)"
	local if "opt"
	local in "opt"
	#delimit ;
	local options "Symbol(string) Connect(string) GRid noBorder
	B(real -1) C(real -1) *" ;
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
	else { local symbol "`symbol'`i" }
	if "`connect'" == "" { local connect ".l" }
	else { local connect "`connect'`l" }

	tempvar y touse x Psubi
	quietly {
        	gen `y' = `varlist'
	    	local yl: variable label `varlist'
    		if "`yl'" == "" { label var `y' "`varlist'"	}
	        else { label var `y' "`yl'" }
        	gen byte `touse' = cond(`varlist' == .,.,1) `if' `in'
		sort `varlist'
		gen float `Psubi' = sum(`touse')
		replace `Psubi' = cond(`touse' == .,.,(`Psubi'-.5)/`Psubi'[_N])
	        gen float `x' = `B' * (-ln(1 - `Psubi'))^(1 / `C')
		label var `x' "inverse Weibull"
		local fmt : format `varlist'
		format `y' `x' `fmt'

        	if "`grid'" != "" {
			parse "5 10 25 50 75 90 95", parse(" ")
			while "`1'" != "" {
		                local wq`1' : di %4.3f /*
                		*/ `B' * (-ln(1 - `1' / 100))^(1 / `C')
		                mac shift
			}
			su `y' if `touse', detail
			local xtl = "`wq50',`wq95',`wq5'"
	        	local xn = "`xtl',`wq25',`wq75',`wq90',`wq10'"
			#delimit ;
			local ytl = string(_result(7)) + "," +
			string(_result(10)) + "," + string(_result(13)) ;
			local yn = "`ytl'" + "," +
			string(_result(8)) + "," + string(_result(9)) + "," +
			string(_result(11)) + "," + string(_result(12)) ;
			noisily graph `y' `x' `x', c(`connect') s(`symbol')
			ylin(`yn') rtic(`yn') rlab(`ytl') xlin(`xn') ttic(`xn')
			tlab(`xtl') `options'
			t1("(Grid lines are 5, 10, 25, 50, 75, 90, and 95 percentiles)")
		        ;
			#delimit cr
       		}
		else {
			if "`border'"=="" { local bo "border"  }
			noisily graph `y' `x' `x', c(`connect') /*
			*/ s(`symbol') `bo' `options'
		}
	}
end

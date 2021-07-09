*! 1.1.0 NJC 10 August 1998
* 1.0.2 NJC 24 April 1998
* 1.0.1  25 April 1997
program define qbeta4 
	version 4.0
	local varlist "req ex max(1)"
	local if "opt"
	local in "opt"
	#delimit ;
	local options "Symbol(string) Connect(string) GRid noBorder
	Alpha(real -1) Beta(real -1) *" ;
	#delimit cr
	parse "`*'"

	tempname a b
	if `alpha' <= 0 | `beta' <= 0 {
        	if "$S_2" != "" & "$S_3" != "" {
			scalar `a' = $S_2
			scalar `b' = $S_3
	        }
        	else {
			di in r "need to know values of parameters, both positive"
			exit 198
		}
	}
	else {
        	scalar `a' = `alpha'
	        scalar `b' = `beta'
	}

	tempvar y touse x

	qui {
        	gen `y' = `varlist'
	    	local yl : variable label `varlist'
    		if "`yl'"=="" { label var `y' "`varlist'" }
	        else { label var `y' "`yl'" }
        	gen byte `touse' = cond(`varlist' == .,.,1) `if' `in'
		sort `varlist'
		gen float `x' = sum(`touse')
		replace `x' = cond(`touse' == .,.,(`x' - .5) / `x'[_N])
	        replace `x' = invfprob(2 * `a', 2 * `b', 1 - `x')
        	replace `x' = `a' * `x' / (`b' + `a' * `x')

		label var `x' "Inverse Beta"
		local fmt : format `varlist'
		format `y' `x' `fmt'

	    	if "`symbol'"=="" { local symbol "oi" }
    		else { local symbol "`symbol'`i" }
	    	if "`connect'"=="" { local connect ".l" }
    		else { local connect "`connect'`l" }

	        if "`grid'" != "" {
			parse "5 10 25 50 75 90 95", parse(" ")
			while "`1'" != "" {
				local q = invfprob(2 * `a', 2 * `b', 1 -  `1' / 100)
				local q = `a' * `q' / (`b' + `a' * `q')
				local bq`1' : di %4.3f  `q'
				mac shift
			}
			local xtl "`bq5',`bq50',`bq95'"
			local xn "`xtl',`bq25',`bq75',`bq10',`bq90'"
			sum `y' if `touse', detail
			local ytl = string(_result(7)) + "," + /*
			*/ string(_result(10)) + "," + string(_result(13))
			local yn = "`ytl'" + "," + /*
		        */ string(_result(8)) + "," + string(_result(9)) + "," + /*
			*/ string(_result(11)) + "," + string(_result(12))

		        #delimit ;
			noi graph `y' `x' `x', c(`connect') s(`symbol')
		        ylin(`yn') rtic(`yn') rlab(`ytl') xlin(`xn') ttic(`xn')
		        tlab(`xtl') `options'
             		t1("(Grid lines are 5, 10, 25, 50, 75, 90, and 95 percentiles)")
		        t2(" ") ;
			#delimit cr
		}
        	else {
			if "`border'" == "" { local bo "border" }
			noi graph `y' `x' `x', c(`connect') s(`symbol') `bo' `options'
	        }
	}
end

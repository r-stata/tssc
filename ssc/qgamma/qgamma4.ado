*! 1.1.2 NJC 24 April 1998
* 1.1.1 NJC 3 March 1998
* 1.1.0 NJC 16 April 1997
program define qgamma4
	version 4.0
	local varlist "req ex max(1)"
	local if "opt"
	local in "opt"
	#delimit ;
	local options "Symbol(string) Connect(string) GRid noBorder
	Alpha(real -1) Beta(real -1) Transform *" ;
	#delimit cr
	parse "`*'"

	tempname a b
	if `alpha' <= 0 | `beta' <= 0 {
        	if "$S_alpha" != "" & "$S_beta" != "" {
			scalar `a' = $S_alpha
			scalar `b' = $S_beta
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
	        gen float `x' = `b' * invgammap(`a',`Psubi')
		label var `x' "inverse gamma"
		local fmt : format `varlist'
		format `y' `x' `fmt'

        	if "`transform'" != "" {
			replace `y' = `varlist'^(1/3)
			replace `x' = `x'^(1/3)
	        }
        	if "`grid'" != "" {
			if "`transform'" == "" {
				parse "5 10 25 50 75 90 95", parse(" ")
                		while "`1'" != "" {
		                	local gq`1' : di %4.3f `b' * invgammap(`a',`1'/100)
					mac shift
		                }
            		}
		        else {
		                parse "5 10 25 50 75 90 95", parse(" ")
                		while "`1'" != "" {
		                    local gq`1' : di %4.3f (`b' * invgammap(`a',`1'/100))^(1/3)
		                    mac shift
                		}
			}
		        su `y' if `touse', detail
		        local xtl = "`gq50',`gq95',`gq5'"
		        local xn = "`xtl',`gq25',`gq75',`gq90',`gq10'"
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

*! 1.0.0 NJC 2 August 2002 
* qnorm version 2.1.9  13jun2000
program define qlognorm, sort
	version 7
	syntax varname [if] [in] [, ml a(real 0.5) /*
	*/ Symbol(string) Connect(string) T1(str) Grid noBorder * ]

	tempvar logvar Z Psubi
	quietly {
		marksample touse 
		capture assert `varlist' > 0 if `touse' 
		if _rc { 
			error 411
		} 	
		
		sort `touse' `varlist'
		gen float `Psubi' = sum(`touse')
		replace `Psubi' = (`Psubi' - `a') / (`Psubi'[_N] - 2 * `a' + 1)
		gen `logvar' = log(`varlist') if `touse' 
		sum `logvar', detail 
		
		if "`ml'" == "" { 
			gen double `Z' = exp(invnorm(`Psubi') * r(sd) + r(mean)) 
		} 
		else { 
			tempname factor 
			scalar `factor' = sqrt((r(N) - 1) / r(N)) 
			gen double `Z' = /* 
			*/ exp(invnorm(`Psubi') * r(sd) * `factor' + r(mean)) 
		} 
		label var `Z' "Inverse lognormal"
		local fmt : format `varlist'
		format `Z' `fmt'

		if "`symbol'" == "" { 
			local symbol "oi" 
		}
		else { local symbol "`symbol'i" }
		if "`t1'" != "" { 
			local t1 t1(`t1') 
		}
		if "`connect'" == "" { 
			local connect ".l" 
		}
		else { local connect "`connect'l" }

		if "`grid'" != "" {
			foreach s in p5 p10 p25 p50 p75 p90 p95 { 
				tempname `s' 
				scalar ``s'' = exp(r(`s')) 
			} 	
			
			#delimit ; 
			
			local ytl = 
			string(`p5') + "," + 
			string(`p50') + "," + 
			string(`p95') ; 
			
			local yn = 
			"`ytl'" + "," + 
			string(`p10') + "," + 
			string(`p25') + "," + 
			string(`p75') + "," + 
			string(`p90') ;
			
			local xtl = 
			string(exp(r(mean))) + "," + 
			string(exp(invnorm(.95) * r(sd) + r(mean))) + "," + 
			string(exp(invnorm(.05) * r(sd) + r(mean))) ; 
			
			local xn = "`xtl'" + "," + 
			string(exp(invnorm(.25) * r(sd) + r(mean))) + "," + 
			string(exp(invnorm(.75) * r(sd) + r(mean))) + "," + 
			string(exp(invnorm(.9) * r(sd) + r(mean))) + "," + 
			string(exp(invnorm(.1) * r(sd) + r(mean))) ; 

			#delimit cr 
			
			local yl "yli(`yn') rti(`yn') rla(`ytl')"
			local xl "xli(`xn') tti(`xn') tla(`xtl')"
			if `"`t1'"' == "" {
				local t1 /* 
	*/ "t1(Grid lines are 5, 10, 25, 50, 75, 90, and 95 percentiles)"
			}
			
			noisily graph `varlist' `Z' `Z', c(`connect') /*
			*/ s(`symbol') /*
			*/ yli(`yn') rti(`yn') rla(`ytl') /*
			*/ xli(`xn') tti(`xn') tla(`xtl') /*
			*/ `options' `t1' t2(" ")
		}
		else {
			if "`border'" == "" { local b "border" }
			noisily graph `varlist' `Z' `Z', c(`connect') /*
			*/ s(`symbol') `b' `options' `t1' 
		}
	} 		
end

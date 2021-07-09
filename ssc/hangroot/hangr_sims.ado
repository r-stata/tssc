*! version 1.5.0 06Sept2011 MLB
program define hangr_sims, rclass
	syntax , x(varname)                           ///
	         w(real)                              ///
			 xl(string)                           ///
			 xr(string)                           ///
             theor(varname)                       /// 
			 hi(string)                           ///
			 nobs(real)                           ///
			 [                                    ///
			 suspended                            ///
			 jittersims(numlist max=1 >0 integer) /// 
			 jitterseed(numlist max=1 >0 integer) /// 
			 spike                                ///
			 bar                                  ///
			 ]
	
	if "`suspended'" != "" local minus "-"
	qui gen `xl' = `x' - .47*`w'
	qui gen `xr' = `x' + .47*`w'
	local min = .
	local max = .
	foreach var of local hi {
		qui replace `var' = `minus'(`theor' - sqrt(`var'*`nobs'*`w'))
		if `"`jittersims'"' != "" {
			sum `var', meanonly
			local min = min(r(min), `min')
			local max = max(r(max), `max')
		}
	}
	if `"`jittersims'"' != "" {
		if "`jitterseed'" != "" set seed `jitterseed'
		local d = (`max' - `min')*`jittersims'/100
		foreach var of local hi {
			qui replace `var' = `var' + `d'*(uniform()-.5)
		}
	}
	foreach var of local hi {
		local simgr`spike'`bar' `"`simgr`spike'`bar'' || pcspike `var' `xl' `var' `xr', lstyle(solid) lcolor(gs10) `simsopt'"' 
	}
	return local simgr`spike'`bar' `simgr`spike'`bar''
end

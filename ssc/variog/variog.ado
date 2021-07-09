*! 3.0.0 NJC 4 March 2005 
* 2.0.0 NJC 20 April 2001 
* 1.0.0 NJC 17 June 1997
program variog
	version 8   
	syntax varname [if] [in] [ , Lags(real 0) LIST Generate(string) * ]

	// check data and options 
	marksample touse  
	qui count if `touse' 
	if r(N) == 0 error 2000 
	
	if "`generate'" != "" confirm new variable `generate'
		
	if `lags' < 0 {
		di as err "lags must be positive"
		exit 198
	}
	local lags = cond(`lags',`lags',int(_N/2))
	local lags = min(`lags', _N-5)
	
	// calculation 
	tempvar lag zdsq gamma zlag npairs 
	local z "`varlist'"

	quietly {
		gen `lag' = _n
		label var `lag' "Lag"
		gen `gamma' = .
		label var `gamma' "Semi-variance"
		gen `zlag' = .
	        gen `zdsq' = .
		gen `npairs' = 0 
		
		forval l = 1/`lags' { 
			replace `zlag' = `z'[_n - `l'] if `touse'[_n-`l'] 
			replace `zdsq' = (`z' - `zlag')^2 if `touse' 
		        su `zdsq', meanonly 
			replace `gamma' = r(mean)/2 in `l'
			replace `npairs' = r(N) in `l' 
		}
	}

	// list if desired 
	if "`list'" == "list" {
		char `lag'[varname] "Lag" 
		char `gamma'[varname] "Semi-variance"
		char `npairs'[varname] "# of pairs" 
		list `lag' `gamma' `npairs' in 1/`lags', ///
			subvarname noobs abb(13) 
	}
	
	// graph 
	local zlab : variable label `z'
	if `"`zlab'"' == "" local zlab "`z'" 
	line `gamma' `lag' if `gamma' < ., ysc(r(0 .)) yla(, ang(h)) ///
		ti(`"Semi-variogram of `zlab'"') `options' 

	// generate if desired 
	if "`generate'" != "" {
	        gen `generate' = `gamma'
		label var `generate' "Semi-variance of `zlab'" 
	}
end

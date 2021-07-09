*! 1.0.0 NJC 4 March 2005 
program variog2, sort 
	version 8   
	syntax varlist(numeric min=3 max=3) [if] [in], Width(numlist max=1 >0) ///
	[ Lags(real 0) LIST Generate(string) * ]

	// check data and options 
	marksample touse  
	qui count if `touse' 
	if r(N) == 0 error 2000 
	local N = r(N) 
	
        if "`generate'" != "" confirm new variable `generate'
		
	if `lags' < 0 {
		di as err "lags must be positive"
		exit 198
	}
	local lags = cond(`lags',`lags',int(_N/2))
	local lags = min(`lags', _N-5)

	// calculation 
	tempvar lag gamma npairs
	tempname zdsq dsq 
	tokenize "`varlist'" 
	args z x y 

	quietly {
		gen `lag' = _n
		label var `lag' "Lag (width `width')"
		gen double `gamma' = 0 
		gen long `npairs' = 0 
		label var `gamma' "Semi-variance"

		replace `touse' = -`touse' 
		sort `touse' 
		forval i = 1/`N' { 
			local I = `i' + 1 
			forval j = `I'/`N' { 
				scalar `zdsq' = (`z'[`i'] - `z'[`j'])^2 
				scalar `dsq' = ///
		sqrt((`y'[`i'] - `y'[`j'])^2 + ((`x'[`i'] - `x'[`j'])^2)) 
				local LAG = ceil(`dsq' / `width') 
				if `LAG' > 0 & `LAG' <= `lags' { 
					replace `npairs' = `npairs' + 1 in `LAG' 
					replace `gamma' = `gamma' + `zdsq' in `LAG' 
				} 
			} 
		}
		replace `gamma' = `gamma' / (2 * `npairs') 
	}

	// list if desired 
	if "`list'" == "list" {
		char `lag'[varname] "Lag" 
		char `gamma'[varname] "Semi-variance"
		char `npairs'[varname] "# of pairs" 
		list `lag' `gamma' `npairs' if `gamma' < ., ///
			subvarname noobs abb(13) 
	}

	// graph 
	local zlab : variable label `z'
	if `"`zlab'"' == "" local zlab "`z'" 
	line `gamma' `lag' if `gamma' < ., ysc(r(0 .)) yla(, ang(h)) ///
		ti(`"Semi-variogram of `zlab'"') `options' 

	// generate if desired 
	qui if "`generate'" != "" {
	        gen `generate' = `gamma' 
		label var `generate' "Semi-variance of `zlab'" 
	}
end

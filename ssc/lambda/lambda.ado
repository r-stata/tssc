*! NJC 1.0.0 19 Nov 2003 
program lambda, rclass
	version 8 
	syntax varlist(min=2 max=2 numeric) [if] [in] [fweight aweight] 
	
	marksample touse 
	qui count if `touse' 
	if r(N) == 0 error 2000 

	tempname cell row col total rowmax colmax sumrowmax sumcolmax 
	
	tab `varlist' [`weight' `exp'] if `touse', matcell(`cell')
	local r = r(r) 
	local c = r(c) 
	
	mat `row' = `cell' * J(`c',1,1) 
	mat `col' = J(1,`r',1) * `cell' 
	mat `total' = J(1,`r',1) * `row'
	
	local maxrow = `row'[1,1] 
	forval i = 2/`r' { 
		local maxrow = max(`maxrow',`row'[`i',1]) 
	} 	
	 
	local maxcol = `col'[1,1] 
	forval j = 2/`c' { 
		local maxcol = max(`maxcol',`col'[1,`j']) 
	} 	
	
	mat `rowmax' = `cell'[1..`r',1] 
	mat `colmax' = `cell'[1,1..`c'] 
	forval i = 1/`r' { 
		forval j = 1/`c' { 
			if `cell'[`i',`j'] > `rowmax'[`i',1] { 
				mat `rowmax'[`i',1] = `cell'[`i',`j'] 
			}
			if `cell'[`i',`j'] > `colmax'[1,`j'] { 
				mat `colmax'[1,`j'] = `cell'[`i',`j'] 
			} 
		}
	} 
	
	mat `sumrowmax' = J(1,`r',1) * `rowmax' 
	mat `sumcolmax' = `colmax' * J(`c',1,1) 

	local a = `sumcolmax'[1,1] - `maxrow'
	local b = `total'[1,1] - `maxrow'
	local c = `sumrowmax'[1,1] - `maxcol'
	local d = `total'[1,1] - `maxcol'
	
	local lambda_a = `a' / `b' 
	di as txt "lambda_a" as res %10.4f `lambda_a' 
	local lambda_b = `c' / `d' 
	di as txt "lambda_b" as res %10.4f `lambda_b' 
	local lambda = (`a' + `c') / (`b' + `d') 
	di as txt "lambda  " as res %10.4f `lambda' 

	return scalar lambda_b = `lambda_b' 
	return scalar lambda_a = `lambda_a' 
	return scalar lambda   = `lambda' 
end 	


version 10 

cap program drop pls

program pls, rclass byable(recall)
	syntax anything(id="Indicator blocks" name=blocks equalok) [if] [in] , ///
	 Adjacent(string) ///
	 [ ModeB(namelist) ///
	 Scheme(string)]
		
		

	/* Parse the specified blocks.
	 * Macros:
	 * 	C`i'				- composite name
	 * 	i`i'				- indicators for composite, by composite index
	 * 	i`C`i''				- indicators for composite, by composite name
	 *	allindicators		- all indicators
	 *	allcomposites		- all composites
	 */

	tokenize `"`blocks'"', parse(" ()=")
	
	scalar inblock = 0
	scalar startblock = 0
	
	// Count of composites
	local j 0
	
	while "`1'"~=""{
		if "`1'"=="(" {
			if inblock{
				di as error "Unexpected ("
				error 197
			}
			scalar inblock = 1
			scalar startblock = 1
			local ++j

		}
		else if inblock{
			if "`1'"==")" {
				if("C`j'"=="" || "i`j'"==""){
					di as error "Incomplete block specification"
					error 197
				}
				else{
					scalar inblock = 0
					local i`C`j'' `i`j''
					local allindicators "`allindicators' `i`j''"
					local allcomposites "`allcomposites' `C`j''"
				}
			}
			else if "`1'"=="=" {
				scalar startblock = 0
			}
			else if startblock {
				if "`C`j''" ~= ""{
					di as error "Missing ="
					error 197
				}
				confirm new variable `1'
				local C`j' `1'
			}
			else{
				foreach var of varlist `1'{
					local i`j' "`i`j'' `var'"
				}
			}
			
		}
		else error 197
		
		macro shift
	}
	
	if inblock{
		di as error "Missing )"
		error 197
	}
	
	/*  End of parsing the blocks */

	/* Parse the inner weight scheme */
	
	if "`scheme'" == "" local scheme  "centroid"
	if ! ("`scheme'" == "centroid" || "`scheme'" == "factor"  || "`scheme'" == "path"){
		di as error "scheme must be either centroid, factor, or path"
		error 198
	}

	
	/*  Set obs to use */
	
	marksample touse, novarlist
	markout `touse'`allindicators'
	
	quietly count if `touse'
	if r(N) == 0 error 2000

	/* Initialize composites with equal weights */
	
	foreach i of numlist 1/`j'{
		quietly egen `C`i'' = rowtotal(`i`i'') if `touse'
		quietly sum `C`i''
		quietly replace `C`i'' = (`C`i''-r(mean))/r(sd)
	}

	/* Parse adjacencies */
	
	tokenize `"`adjacent'"', parse(",")
	
	while "`1'"~=""{
		local 0 `1'
		syntax varlist(min=2)
		
		// Use macros r`var' and c`compositename' to store whether
		// the adjacency is treated as directional in path weighting scheme
		
		local dv: word 1 of `varlist'
		local ivs: list varlist - dv
		local r`dv' `r`dv'' `ivs'
		
		foreach iv in `ivs'{
			local c`iv' `c`iv'' `dv'
		}

		macro shift
		macro shift
	}

	foreach var in `allcomposites'{
		if "`r`var''`c`var''"== ""{
			di as error "Composite `var' is not adjacent to any other composite"
			error 198
		}
		
		
		
		if("`scheme'" == "path"){
			local c`var': list uniq c`var'
			local r`var': list uniq r`var'
			local c`var': list c`var' - r`var'
		}
		else{
			local c`var' `c`var'' `r`var''
			local c`var': list uniq c`var'
			local r`var' ""
		}
	}
	
	/* Verify Mode B specification and create Mode A specification*/
	
	local 0 `modeB'
	syntax [varlist]
	
	local modeA: list allcomposites - modeB
	
		
	/*
     * Start of the PLS weight algorithm
	 */
	 
	scalar converged = 0
	scalar iteration = 0

	while(!converged){
		// Inner estimation. The three commonly used schemes are
		// Centroid: The sign of correlations
		// Factor: The correlations
		// Path: Correlations and regresions
		
		
		// Update the composites as weighted sums of adjacent composites.
		// These are stored as separate temporary variables
		// for computational reasons
		
		foreach var in `allcomposites'{
			
			tempvar t`var'
			
			// Inner estimation with regression weights (path)
			if("`r`var''"!=""){
				quietly regress `var' `r`var'' if `touse'
				quietly predict `t`var'' if `touse'
				
			}
			else quietly generate `t`var'' = 0 if `touse'
			
			// Inner estimation with correlational weights (all schemes)
			foreach var2 in `c`var''{
				quietly correlate `var' `var2'  if `touse'
				matrix define C = r(C)
				if "`scheme'" == "centroid" quietly replace `t`var'' = `t`var'' + `var2' * C[1,2]/abs(C[1,2])  if `touse'
				else quietly replace `t`var'' = `t`var'' + `var2' * C[1,2]  if `touse'
			}
		}

		// Store weights in matrix. These are unscaled and only used for
		// convergence check
		
		matrix define W = 0
		
		// Outer estimation (Mode A)
		
		foreach var in `modeA'{
			quietly replace `var' = 0 if `touse'
			foreach var2 in `i`var''{
				quietly correlate `t`var'' `var2' if `touse'
				matrix define C = r(C)
				matrix define W = W , C[1,2]
				quietly replace `var' = `var' + `var2' * C[1,2]  if `touse'
			}
		}
	
		// Outer estimation (Mode B)
	
		foreach var in `modeB'{
			tempvar tv
			quietly regress `t`var'' `i`var''  if `touse'
			matrix define W = W , e(b)
			quietly predict `tv' if `touse'
			quietly replace `var' = `tv'  if `touse'
			quietly drop `tv'
		}

		// Clean up 
		foreach var in `allcomposites'{
			quietly drop `t`var''
		}
		
		// Standardize the composites
		
		foreach var of varlist `allcomposites'{
			quietly sum `var'
			quietly replace `var' = (`var'-r(mean))/r(sd)
		}
		
		// Convergence check:compare new weights (W) with the weights from previous
		// iteration (Wold).

		if(iteration > 0) scalar converged = mreldif(W, Wold) < 0.00001
		matrix define Wold = W
	
		scalar iteration = iteration +1
				
		// No convergence 
		if(iteration>1000) error 430
	
	}
	 return scalar iterations = iteration
	 
end


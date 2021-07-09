*! NJC 1.0.0 22 March 2005 
program hdquantile, sort 
	version 8 
	syntax varlist(numeric) [if] [in] , [ p(numlist >0 <100 int) ///
	a(real 0.5) Generate(string) by(varlist) Matname(str) * ] 

	// check syntax and observations 
	local nvars : word count `varlist' 

	quietly { 
		marksample touse
		if "`by'" != "" markout `touse' `by', strok 
		count if `touse' 
		if r(N) == 0 error 2000

		local nopts = ("`p'" != "") + ("`generate'" != "") 
		if `nopts' != 1 { 
			di as err "specify either p() or generate()" 
			exit 198 
		} 	
		
		if "`generate'" != "" & `: word count `generate'' != `nvars' { 
			di as err "number of variables in generate() " ///
			"does not match number in varlist" 
			exit 198 
		} 	
		else if "`p'" != "" { 
			if "`by'" != "" & `nvars' > 1 error 191
		} 	
		
		// initialise data structure 			
		tempvar w work group   
		gen double `w' = .  
		gen double `work' = .
	} 	

	// list of probabilities specified: matrix output 
	if "`p'" != "" { 
		tempname mat 
		local nq : word count `p' 
	
		quietly { 
		// one variable: might be -by()- 
		if `nvars' == 1 { 
			bysort `touse' `by' (`varlist') : ///
				gen byte `group' = _n == 1 if `touse' 
			replace `group' = sum(`group')  
			su `group', meanonly 
			local ng = r(max)
			matrix `mat' = J(`ng', `nq', 0)  
		}
		// two or more variables 
		else matrix `mat' = J(`nvars', `nq', 0)  
		
		// loop over quantiles 
		forval j = 1/`nq' { 
			local P : word `j' of `p' 
			local P = `P' / 100
	
			// one variable 
			if `nvars' == 1 { 
				by `touse' `by' : replace `w' = ///
		ibeta((_N + 1) * `P', (_N + 1) * (1 - `P'), _n/_N) -     ///
		ibeta((_N + 1) * `P', (_N + 1) * (1 - `P'), (_n - 1)/_N)  
				by `touse' `by' : replace `work' = ///
					sum(`w' * `varlist') / sum(`w') 
				by `touse' `by' : replace `work' = `work'[_N] 	

				// into matrix 
				forval i = 1/`ng' { 
					su `work' if `group' == `i', meanonly 
					mat `mat'[`i',`j'] = r(mean) 
				}
			} 
			// two or more variables 
			else { 
				forval i = 1/`nvars' {  
					local v : word `i' of `varlist' 
					bysort `touse' (`v') : replace `w' = ///
		ibeta((_N + 1) * `P', (_N + 1) * (1 - `P'), _n/_N) -         ///
		ibeta((_N + 1) * `P', (_N + 1) * (1 - `P'), (_n - 1)/_N)  
					by `touse' : replace `work' = ///
						sum(`w' * `v') / sum(`w') 

					// into matrix 	
					mat `mat'[`i',`j'] = `work'[_N] 
				}
			} 	
		}	
		} // end quietly 
		
		// display matrix 			
		if "`matname'" != "" matrix `matname' = `mat' 
		else { 
			local matname "`mat'" 
			local nohdr "noheader" 
		} 	
		
		// matrix row names 
		// without -by()-, the varlist gives the names 
		if "`by'" == "" matrix rownames `matname' = `varlist' 
		else { 
			// first stab: just the groups 1 up 
			numlist "1/`ng'" 
			matrix rownames `matname' = `r(numlist)' 
			
			// second stab: the values of -by()-
			// 	only if -by()- contains single variable 
			// third stab: the value labels associated with -by() 
			//	only if variable is numeric 
			if `: word count `by'' == 1 { 
				tempvar order 
				gen long `order' = _n 
				local isstr = index("`: type `by''", "str")   
				forval i = 1/`ng' { 
					su `order' if `group' == `i', meanonly 
					local value = `by'[r(min)] 
					local names "`names'`value' "
					if !`isstr' { 
						local labels ///
						"`labels'`: label (`by') `value'' " 
					}	
				}
				capture matrix rownames `matname' = `names' 
				if !`isstr' capture matrix rownames `matname' = `labels' 
			}	
		}	
		
		matrix colnames `matname' = `p' 
		matrix list `matname', `nohdr' `options'
	} 
	// no list specified: as many quantiles as values, 
	// evaluated at (i - a)/(n - 2a + 1) 
	else quietly {
		tempvar P I 
		bysort `touse' `by' : gen byte `group' = _n == 1 if `touse' 
		replace `group' = sum(`group')  
		su `group', meanonly 
		local j1 = _N - r(N) + 1 
		local j2 = _N 
		gen `P' = 1 
		gen `I' = 1 
		
		// loop over variables 
		forval i = 1/`nvars' { 
			local v : word `i' of `varlist' 
			local g : word `i' of `generate' 
			gen `g' = . 
			label var `g' "H-D quantiles of `v'" 
			
			bysort `touse' `group' (`v') : replace `P' = ///
			(_n - `a') / (_N - 2 * `a' + 1)
			by `touse' `group' : replace `I' = _n 
			
			// loop over quantiles 
			forval j = `j1'/`j2' { 
				local p "`P'[`j']" 
				count if `group' == `group'[`j'] 
				local N = r(N) 
				local N1 = r(N) + 1 
				replace `w' = ///
			ibeta(`N1' * `p', `N1' * (1 - `p'), `I'/`N') -   ///
			ibeta(`N1' * `p', `N1' * (1 - `p'), (`I' - 1)/`N')  
			        su `v' [aw=`w'] ///
					if `group' == `group'[`j'], meanonly  
				replace `g' = r(mean) in `j' 	
			} 
		}	
	}	
end 	

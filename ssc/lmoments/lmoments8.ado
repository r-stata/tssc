*! 3.3.0 NJC 20 April 2006
* 3.2.1 NJC 23 November 2004
* 3.2.0 NJC 18 October 2004
* 3.1.0 NJC 27 September 2004  
* 3.0.0 NJC 1 July 2003  
* 2.2.0 NJC 31 March 1999
* 2.1.0 NJC 12 February 1999
* 2.0.2 NJC 8 January 1999
* 2.0.1 NJC 1 September 1998
* 2.0.0 NJC 26 April 1998
* 1.0.0 NJC 17 September 1997
* based on lshape v 2.0.1 PR 06Oct95.
program lmoments8, rclass sort byable(recall)   
        version 8.0
        syntax [varlist] [if] [in] /// 
        [, Matname(str) Format(str) Detail ALLobs variablenames by(varlist) ///
	Generate(str) se SE2(str) lmax(numlist int max=1 >4 <9) * ]

	// lmax() and its consequences undocumented 

	quietly {
		// screen out string variables 
		ds `varlist', has(type numeric) 
		local varlist "`r(varlist)'" 
	
		// what to use 
		if "`allobs'" != "" marksample touse, novarlist 
		else marksample touse 

		count if `touse' 
		if r(N) == 0 error 2000 
		
		// variable(s) or group(s) 
		local ng : word count `varlist'

		// generate() option 
		if "`generate'" != "" { 
			if `ng' > 1 { 
				di as err ///
				"generate() cannot be combined with `ng' variables"
				exit 198 
			}

			if _by() { 
				di as err ///
				"generate() cannot be combined with by: : use by() option"
				exit 198 
			}
			
			local OK n l1 l2 l3 l4 l5 l6 l7 l8 t t3 t4 t5 t6 t7 t8  
			local highest = 4 
			
			foreach g of local generate { 
				local eq = index("`g'", "=") 
				if `eq' == 0 { 
					di as err "generate(): invalid syntax" 
					exit 198
				}
				
				local g1 = substr("`g'", 1, `eq' - 1) 
				confirm new variable `g1' 
				local G `G' `g1' 

				local g2 = substr("`g'", `eq' + 1, .)
				local g2 = subinstr("`g2'", "_", "", 1) 
				if !`: list g2 in OK' { 
					di as err "generate(): `g2' invalid"
					exit 198 
				}
				local g2 = upper("`g2'") 
				
				if length("`g2'") > 1 {
					local digit = real(substr("`g2'",-1,1))
					local highest = max(`highest', `digit')
				}
				
				local S `S' `g2' 
			}	
			
			if `highest' > 4 { 
				if "`lmax'" == "" { 
					di as err "specify lmax()" 
					exit 198 
				}
				else if `highest' > `lmax' { 
					di as err "lmax() and generate() inconsistent"
					exit 198 
				}
			}	
			
			foreach g of local G { 
				generate double `g' = .                  
			}	
		}	
			
		if "`by'" != "" { 
			if `ng' > 1 { 
				di as err ///
				"by() cannot be combined with `ng' variables"
				exit 198 
			}
			
			tempvar group 
			egen `group' = group(`by') if `touse', label 
			su `group', meanonly  
			local ng = r(max) 
		} 	
		else { 
			local group "`touse'"
			tokenize `varlist' 
		}	

		if `ng' > _N {
			preserve 
			set obs `ng'
		}

		tempvar a id n l_1 l_2 l_3 l_4 t t_3 t_4 which
		tempname N d b0 L1 L2 L3 L4 mylbl 

		// various sorts will change the order of observations; 
		// -which- is used to keep track of order of the results 
                gen long `which' = _n
                compress `which'
                
		// n shown as string, to sidestep -tabdisp- format 
		gen `n' = "" 
		label var `n' "n" 
		
		// initialisation 
		foreach s in l_1 l_2 l_3 l_4 t t_3 t_4 { 
			gen double ``s'' = . 
                	label var ``s'' "`s'"
		} 	

		if "`matname'" != ""  mat `matname' = J(`ng',8,0) 

		gen long `id' =  0 
		gen double `a' = .  

		// loop over variables(s) or groups(s) 
		forval i = 1/`ng' {
			// get data and get ranks
			if "`by'" != "" { 
				replace `a' = ///
				cond(`touse' & `group' == `i', `varlist',.) 
			} 	
			else    replace `a' = ``i'' if `touse' 
			
			bysort `touse' (`a') : replace `id' = _n  

			// get b0 b1 b2 b3
			su `a', meanonly
			scalar `b0' = r(mean)
			scalar `N' =  r(N)
			scalar `d' = `N'

			local J = cond("`lmax'" != "", `lmax' - 1, 3) 

			forval j = 1/`J' {
				tempname b`j' 
				scalar `d' = `d' * (`N' - `j')
				replace `a' = `a' * (`id' - `j') if `touse' 
				su `a', meanonly
				scalar `b`j'' = r(sum) / `d'
			}

			// transform to L1 L2 L3 L4 
			scalar `L1' = `b0'
			scalar `L2' = 2 * `b1' - `b0'
			scalar `L3' = 6 * `b2' - 6 * `b1' + `b0'
			scalar `L4' = 20 * `b3' - 30 * `b2' + 12 * `b1' - `b0'

			if "`lmax'" != "" { 
				tempname L5 L6 L7 L8 
				if `lmax' >= 5 {
					scalar `L5' = ///
		70  * `b4' - 140 * `b3' +  90 * `b2' - 20  * `b1' + `b0'
				} 
				if `lmax' >= 6 { 
					scalar `L6' = ///
		252 * `b5' - 630 * `b4' + 560 * `b3' - 210 * `b2' + 30 * `b1' - `b0'
				}
				if `lmax' >= 7 { 
					scalar `L7' = ///
		924 * `b6' - 2772 * `b5' + 3150 * `b4' - 1680 * `b3' + 420 * `b2' - 42 * `b1' + `b0'
				} 
				if `lmax' == 8 { 
					scalar `L8' = ///
		3432 * `b7' - 12012 * `b6' + 16632 * `b5' - 11550 * `b4' + 4200 * `b3' - 756  * `b2' + 56 * `b1' - `b0' 
			        } 
			}	
			
			// put results in variables 
			replace `n' = string(`N') if `which' == `i'
			replace `l_1' = `b0' if `which' == `i'
			replace `l_2' = `L2' if `which' == `i'
			replace `l_3' = `L3' if `which' == `i'
			replace `l_4' = `L4' if `which' == `i'
			replace `t'  = `L2' / `L1' if `which' == `i'
			replace `t_3' = `L3' / `L2' if `which' == `i'
			replace `t_4' = `L4' / `L2' if `which' == `i'

			// generate? 
			if "`generate'" != "" { 
				local j = 1 
				local LOK "N L1 L2 L3 L4 L5 L6 L7 L8" 
				foreach g of local G { 
					local s : word `j' of `S' 
					
					if `:list s in LOK' { 
						replace `g' = ``s'' if `group' == `i' 
					}
					else if "`s'" == "T" { 
						replace `g' = `L2' / `L1' if `group' == `i' 
					}
					else if "`s'" == "T3" { 
						replace `g' = `L3' / `L2' if `group' == `i' 
					}	
					else if "`s'" == "T4" { 
						replace `g' = `L4' / `L2' if `group' == `i' 
					}	
					else if "`s'" == "T5" { 
						replace `g' = `L5' / `L2' if `group' == `i' 
					}
					else if "`s'" == "T6" { 
						replace `g' = `L6' / `L2' if `group' == `i' 
					}
					else if "`s'" == "T7" { 
						replace `g' = `L7' / `L2' if `group' == `i' 
					}
					else if "`s'" == "T8" { 
						replace `g' = `L8' / `L2' if `group' == `i' 
					}
					local ++j 
				}
			}	
			
			// optionally put results in named matrix 
			if "`matname'" != "" {
				mat `matname'[`i',1] = `N'
				mat `matname'[`i',2] = `b0'
				mat `matname'[`i',3] = `L2'
				mat `matname'[`i',4] = `L3'
				mat `matname'[`i',5] = `L4'
				mat `matname'[`i',6] = `L2' / `L1'
				mat `matname'[`i',7] = `L3' / `L2'
				mat `matname'[`i',8] = `L4' / `L2'
			}
			
			// prepare presentation 
			if "`by'" != "" { 
				local V = trim(`"`: label (`group') `i''"')
				local rownames `"`rownames' `"`V'"'"' 
			}
			else { 
				local V = trim(`"`: variable label ``i'''"')  
				if `"`V'"' == "" | "`variablenames'" != "" { 
					local V "``i''" 
				} 	
			}	
			label def `mylbl' `i' `"`V'"', modify 
		} // end loop over variables or groups
	} // end quietly 	

	// prepare more for presentation 
        if "`matname'" != "" {
                mat colnames `matname' = n l_1 l_2 l_3 l4 t t_3 t_4
		if "`by'" != "" { 
			capture mat rownames `matname' = `rownames' 
			if _rc { 
				numlist "1/`ng'" 
				mat rownames `matname' = `r(numlist)' 
			}
		}	
                else mat rownames `matname' = `varlist' 
        }

        label val `which' `mylbl'
	if "`by'" != "" label var `which' "Group" 
	else if "`allobs'" != "" label var `which' "Variable" 
        else label var `which' "n = `r(N)'"

        if "`format'" == "" local format "%9.3f"
	if "`allobs'`by'" != "" local shown "`n'"

	// -tabdisp- of results 
        if "`detail'" != "" {
                tabdisp `which' if `which' <= `ng', ///
                c(`shown' `l_1' `l_2' `l_3' `l_4') `options' f(`format') 
                tabdisp `which' if `which' <= `ng', ///
                c(`t' `t_3' `t_4') `options' f(`format') 
        }
        else {
                tabdisp `which' if `which' <= `ng', ///
                c(`shown' `l_1' `l_2' `t_3' `t_4') `options' f(`format') 
        }

	// returned values 
        ret scalar N = `N'
        ret scalar l_1 = `L1'
        ret scalar l_2 = `L2'
        ret scalar l_3 = `L3'
        ret scalar l_4 = `L4'
	if "`lmax'" != "" { 
		forval j = 5/`lmax' { 
			ret scalar l_`j' = `L`j''
		}
	} 	
        ret scalar t = `L2' / `L1'
        ret scalar t_3 = `L3' / `L2'
        ret scalar t_4 = `L4' / `L2'
	if "`lmax'" != "" { 
		forval j = 5/`lmax' { 
			ret scalar t_`j' = `L`j'' / `L2' 
		}
	} 	
	ret scalar b_1 = `b1' 
	ret scalar b_2 = `b2' 
	ret scalar b_3 = `b3' 
	if "`lmax'" != "" { 
		forval j = 4/`= `lmax' - 1' { 
			ret scalar b_`j' = `b`j''
		}
	} 

	// everything else is standard error code, only applied to 
	// last variable or group examined (usually, the only one) 
	
	if "`se'`se2'" != "" { 
		if `N' < 8 { 
			di as txt "sample size too small for standard errors"
			exit 0 
		} 
		
		tempvar order xixj prod IK JL IL JK 
		tempname V C NN SE 

		// we get obs. range, so we can apply -in- rather than -if- 
		gen long `order' = _n 
		quietly compress `order' 
		su `order' if `a' < ., meanonly 
		local min = r(min)
		local max = r(max) 
		drop `order' 
		
		local v "`varlist'"
		
		// remember that variance matrix is symmetric 
		forval k = 0/3 { 
			forval l = `k'/3 { 
				local args `"`args' "`k' `l'" "'
			}
		} 

		mat `V' = J(4,4,0) 
		gen double `xixj' = 0 
		gen double `prod' = 0
		
		// we start by getting the variance matrix of b0 b1 b2 b3 
		// we want combinations 00 01 02 03 11 12 13 22 23 33
		
		// there may be scope to improve efficiency in 
		// generating variables, but the trade-off may be 
		// with either storage or trickiness 
		
		quietly foreach arg of local args { 
			tokenize `arg' 
			args k l 

			// falling powers; NB that if k or l is 0, 
			// respective -forval- loops not entered 
			
			gen double `IK' = 1 
			forval i = 1/`k' { 
				replace `IK' = `IK' * (`id' - `i') 
			}

			gen double `IL' = 1 
			forval i = 1/`l' { 
				replace `IL' = `IL' * (`id' - `i') 
			}
		
			gen double `JL' = 1 
			forval i = 1/`l' { 
				replace `JL' = `JL' * (`id' - `k' - `i' - 1) 
			}

			gen double `JK' = 1 
			forval i = 1/`k' { 
				replace `JK' = `JK' * (`id' - `l' - `i' - 1) 
			}

			replace `prod' = 0 
			
			scalar `NN' = ///
			exp(lnfact(`N') - lnfact(`N' - `k' - `l' - 2))
	
			// want to work with pairs of order statistics 
			// x_(i) <= x_(j), but we can avoid looping over 
			// both i and j 
			forval i = `min'/`= `max' - 1' { 
				local j "`= `i' + 1'/`max'" 
				replace `xixj' = `v'[`i'] * `v' / `NN' in `j'
				replace `prod' = `prod' + ///
			(`IK'[`i'] * `JL' + `IL'[`i'] * `JK')  * `xixj' in `j' 
			} 	

			su `prod', meanonly 
			mat `V'[`k' + 1,`l' + 1] = r(sum)  
			mat `V'[`l' + 1,`k' + 1] = r(sum)  

			drop `IK' `JL' `IL' `JK' 
		}

		forval k = 1/4 { 
			forval l = 1/4 { 
				local K = `k' - 1
				local L = `l' - 1 
				mat `V'[`k',`l'] = `b`K'' * `b`L'' - `V'[`k',`l'] 
			}
		} 
		
		// now transform to variance matrix of L-moments 
		mat `C' = (1, 0, 0, 0\-1, 2, 0, 0\1, -6, 6, 0\-1, 12, -30, 20) 
		mat `V' = `C' * `V' * (`C')'
		mat rownames `V' = l_1 l_2 l_3 l_4
		mat colnames `V' = l_1 l_2 l_3 l_4
		di as txt _n "Variance matrix of sample L-moments" _c 
		mat li `V', noheader `se2' 
		
		// and vector of standard errors (for t t_3 t_4 also) 
		mat `SE' = J(1,7,0) 
		forval i = 1/4 { 
			mat `SE'[1,`i'] = sqrt(`V'[`i',`i']) 
		}
		
		mat `SE'[1,5] = ///
`V'[2,2]/(`L2' * `L2') + `V'[1,1]/(`L1' * `L1') - 2 * `V'[1,2]/(`L1' * `L2')
		mat `SE'[1,5] = sqrt(`SE'[1,5] * (`L2'/`L1')^2)
		
		mat `SE'[1,6] = ///
`V'[3,3]/(`L3' * `L3') + `V'[2,2]/(`L2' * `L2') - 2 * `V'[2,3]/(`L2' * `L3')
		mat `SE'[1,6] = sqrt(`SE'[1,6] * (`L3'/`L2')^2) 
		
		mat `SE'[1,7] = ///
`V'[4,4]/(`L4' * `L4') + `V'[2,2]/(`L2' * `L2') - 2 * `V'[2,4]/(`L2' * `L4')
		mat `SE'[1,7] = sqrt(`SE'[1,7] * (`L4'/`L2')^2) 
		
		mat colnames `SE' = l_1 l_2 l_3 l_4 t t_3 t_4 
		mat rownames `SE' = "  "
		di as txt _n "Standard errors of sample L-moments and ratios" _c 
		mat li `SE', noheader `se2' 
		
		ret matrix V = `V' 
		ret matrix SE = `SE'
	} // end of standard error code 
end


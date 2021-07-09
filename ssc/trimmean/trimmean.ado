*! 1.6.0 NJC 30 April 2013 
* 1.5.1 NJC 19 April 2013 
* 1.5.0 NJC 14 April 2013 
* 1.4.0 NJC 6 April 2013 
* 1.3.0 NJC 22 March 2013 
* 1.2.0 NJC 22 February 2013 
* 1.1.0 NJC 4 February 2013 
* 1.0.0 NJC 31 January 2013 
program trimmean, rclass sort byable(recall) 
	version 9     
    	syntax varname(numeric) [if] [in] [, Percent(numlist int >=0 <=50 sort) ///
        Number(numlist int >=0 sort) Metric(numlist >=0 sort) Format(str)       ///
	CI Level(cilevel) CEILing Generate(str) Weighted]  

       	quietly { 
		local nopts = ("`percent'" != "") + ("`number'" != "") + ("`metric'" != "") 
		if `nopts' != 1 { 
			di as err "must specify one of percent(), number() or metric()" 
			exit 198 
		} 

		local np : word count `percent' `number' `metric' 
		if `np' > _N { 
			di as err "too many results requested" 
			exit 498
		} 

		if "`generate'" != "" { 
			if _byindex() == 1 {
				confirm new var `generate' 
				gen byte `generate' = . 
			}
		} 

		if "`weighted'" != "" & "`ci'" != "" { 
			di as err "weighted and ci options may not be combined" 
			exit 198 
		} 

		if "`metric'" != "" & "`ci'" != "" { 
			di as err "metric() and ci options may not be combined" 
			exit 198 
		} 

		marksample touse 
		count if `touse'
		if r(N) == 0 error 2000
		local N = r(N) 
		
		if "`number'" != "" { 
			foreach n of local number { 
				if `n' < `N'/2 { 
					local numberok `numberok' `n' 
				}
			}
			local number `numberok' 
			if "`number'" == "" { 
				di as err "number() arguments outside possible range"
				exit 498 
			}
		} 

		replace `touse' = -`touse' 
		local i = 1 
		local y `varlist' 	
		sort `touse' `y' 

		tempname results 
		tempvar out1 out2 out3 

		if "`ci'" != "" { 
			tempname se halfci 
			tempvar copyvar out4 out5 out6  
			clonevar `copyvar' = `y' 
			local P (100 - `level') / 200 
			local k = 6 
			local extras "se lower upper" 
		}
		else local k = 3
		
		matrix `results' = J(`np', `k', .) 

		forval j = 1/`k' { 
			gen `out`j'' = . 
		} 

		local myfcn = cond("`ceiling'" != "", "ceil", "floor") 

		if "`weighted'" != "" { 
			tempvar wt 
			gen double `wt' = . 
		}
		
		if "`number'" != "" { 
		// number() option 
			foreach n of local number { 
				matrix `results'[`i', 1] = `n' 

				local n1 = 1 + `n' 
				local n2 = `N' - `n'   

				capture su `y' in `n1'/`n2', meanonly 
				if _rc == 0 { 
					matrix `results'[`i', 2] = r(N) 
					matrix `results'[`i', 3] = r(mean) 
					return scalar tmean`n' = r(mean) 
				}

				if "`ci'" != "" & r(N) > 2 { 
					// Winsorized SD 

					if `n' >= 1 { 
						replace `copyvar' = `copyvar'[`n1'] in 1/`n' 
						replace `copyvar' = `copyvar'[`n2'] in `=`n2'+1'/`N' 
					}

					su `copyvar' in 1/`N' 
					local df `n2' - `n1'  
					scalar `se' =  r(sd) / (sqrt(`N') * (1 - 2 * `n'/`N'))
					scalar `halfci' =  invttail(`df', `P') * `se'                                    
					matrix `results'[`i', 4] = `se' 
					matrix `results'[`i', 5] = `results'[`i', 3] - `halfci' 
					matrix `results'[`i', 6] = `results'[`i', 3] + `halfci' 
				}

				forval j = 1/`k' { 
					replace `out`j'' = `results'[`i', `j'] in `i'  
				}

				local ++i 
			}
			local what "number" 
			local What "Number   " 
		}

		else if "`percent'" != "" { 
		// percent() option 
			foreach p of local percent { 
				matrix `results'[`i', 1] = `p' 

				if `p' == 50 { 
					if mod(`N', 2) {  
						matrix `results'[`i', 2] = 1   
						matrix `results'[`i', 3] = `y'[(`N' + 1)/2]
						local n1 = (`N' + 1)/2 
						local n2 = `n1' 
					}
					else { 
						matrix `results'[`i', 2] = 2   
						matrix `results'[`i', 3] = (`y'[`N'/2] + `y'[(`N'/2) + 1])/2  
						local n1 = `N'/2 
						local n2 = `n1' + 1 
					}
				} 
				else { 
					local n1 = 1 + `myfcn'(`p' * `N' / 100) 
					local n2 = `N' - `n1' + 1  

					if "`weighted'" != "" { 
	                               		replace `wt' = inrange(_n, `n1' + 1, `n2' - 1) 
						replace `wt' = 1 + floor(`p' * `N'/100) - `p' * `N'/100 in `n1' 
						replace `wt' = 1 + floor(`p' * `N'/100) - `p' * `N'/100 in `n2' 
						su `y' [aw=`wt'] in `n1'/`n2', meanonly 

						// undocumented return of weights that may be fractional 
						c_local njc_trim_minw = `wt'[`n1'] 
					}
					else su `y' in `n1'/`n2', meanonly 

					matrix `results'[`i', 2] = r(N) 
					matrix `results'[`i', 3] = r(mean) 
				}

				return scalar tmean`p' = r(mean) 

				if "`ci'" != "" & `p' < 50  & r(N) > 2 { 
					// Winsorized SD 
					local n11 = `n1' - 1 
					local n21 = `n2' + 1 
					if `p' > 0  & `n11' > 0 { 
						replace `copyvar' = `copyvar'[`n1'] in 1/`n11' 
						replace `copyvar' = `copyvar'[`n2'] in `n21'/`N' 
					}
					su `copyvar' in 1/`N' 
					local df `n2' - `n1'  
					scalar `se' = r(sd) / (sqrt(`N') * (1 - 2 * `n11'/`N'))
					scalar `halfci' =  invttail(`df', `P') * `se'                                       
					matrix `results'[`i', 4] = `se' 
					matrix `results'[`i', 5] = `results'[`i', 3] - `halfci' 
					matrix `results'[`i', 6] = `results'[`i', 3] + `halfci' 
				}

				forval j = 1/`k' { 
					replace `out`j'' = `results'[`i', `j'] in `i' 
				}

				local ++i 
			}
			
			local what "percent" 
			local What "Percent  " 
		}
		else {  
		// metric() option 
	
			tempname median 
			tempvar which 
			gen byte `which' = . 
			if mod(`N', 2) scalar `median' = `y'[(`N' + 1)/2]
			else scalar `median' = (`y'[`N'/2] + `y'[(`N'/2) + 1])/2  

			foreach m of local metric { 
				matrix `results'[`i', 1] = `m' 

				replace `which' = `touse' & (abs(`y' - `median') <= `m') 

				su `y' if `which', meanonly 
				if _rc == 0 { 
					matrix `results'[`i', 2] = r(N) 
					matrix `results'[`i', 3] = r(mean) 
					return scalar tmean`i' = r(mean) 
				}

				forval j = 1/`k' { 
					replace `out`j'' = `results'[`i', `j'] in `i'  
				}

				local ++i 
			}
 	 		local what "deviation" 
			local What "Deviation" 
		}
	}
	
	if "`format'" == "" local format : format `y' 
	matrix colnames `results' = `what' n trim_mean `extras' 

	char `out1'[varname] "`what'" 
	char `out2'[varname] "#" 
	char `out3'[varname] "trimmed mean" 
	if "`metric'" != "" format `out1' `format' 
	else format `out1' %2.0f 
	format `out2' %2.0f 
	format `out3' `format' 	

	if "`ci'" != "" { 
		char `out4'[varname] "s.e." 
		char `out5'[varname] "lower limit" 
		char `out6'[varname] "upper limit"
		format `out4' `out5' `out6' `format' 	
	}

        list `out1' `out2' `out3' `out4' `out5' `out6' in 1/`=`i'-1', ///
	subvarname abbrev(13) sep(0) noobs  	

	return matrix results = `results' 

	if "`generate'" != "" { 
		if "`metric'" != "" replace `generate' = `which' if `touse' 
		else replace `generate' = inrange(_n, `n1', `n2')  if `touse' 
	} 
end
 

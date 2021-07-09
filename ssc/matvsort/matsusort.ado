*! 1.0.0 NJC 24 Sept 2004 
program matsusort 
        version 8.0
	gettoken A 0 : 0, parse(" ") 
	gettoken B 0 : 0, parse(" ,") 
	syntax [ , COLumns DECrease SUmmary(str) ] 
	
	// default: sort rows, on row averages, from r(mean)
	// default columns: sort cols, on col averages, from r(mean)   
	// decrease: decreasing  
	// summary: sets r(somethingelse) 

	if "`summary'" != "" { 
		local nw : word count `summary' 
		if `nw' > 1 { 
			di as err "only one summary measure allowed" 
			exit 198 
		} 	

		local s1 "N mean sum sum_w min max" 
		local s2 "sd Var" 
		local s3 "p1 p5 p10 p25 p50 p75 p90 p95 p99 skewness kurtosis" 

		if `: list summary in s2' { 
			// OK 
		} 	
		else if `: list summary in s1' { 
			local opt "meanonly" 
		} 
		else if `: list summary in s3' { 
			local opt "detail" 
		} 
		else { 
			di "{err:`summary' invalid: see} " ///
			   "{help matsusort:help on matsusort}" 
			exit 198 
		}
	}
	else local summary "mean" 
	
	confirm matrix `A'
	local nr = rowsof(matrix(`A'))  
	local nc = colsof(matrix(`A')) 
	local dec = "`decrease'" != "" 

	// one column & `columns': nothing to do except copy 
	if `nc' == 1 & "`columns'" != "" { 
		matrix `B' = `A' 
		exit 0 
	} 	
	
	// one row & default: nothing to do except copy 
	if `nr' == 1 & "`columns'" == "" { 
		matrix `B' = `A' 
		exit 0 
	} 	
	
	qui { 
		local nv = max(`nr',`nc') 
		if `nv' > _N { 
			preserve 
			set obs `nv' 
		} 	

		tempname C 
		tempvar work su names which 
		gen double `work' = . 
		gen double `su' = . 
		gen `names' = "" 
		gen `which' = _n in 1/`nv' 
		mat `C' = J(`nr', `nc', 1) 
		
		if "`columns'" == "" { 
			local rows : rowfullnames(`A') 
			tokenize `rows' 
			forval i = 1/`nr' {
				replace `names' = `"``i''"' in `i' 
				forval j = 1/`nc' { 
					replace `work' = `A'[`i', `j'] in `j' 
				} 
				su `work' in 1/`nc', `opt' 
				replace `su' = ///
				cond(`dec', -(r(`summary')), r(`summary')) in `i' 
			} 
			sort `su' `which' 
			forval i = 1/`nr' { 
				local newnames `"`newnames' `"`=`names'[`i']'"'"' 
				forval j = 1/`nc' { 
					local k = `which'[`i'] 
					mat `C'[`i',`j'] = `A'[`k',`j'] 
				}
			} 	
			mat rownames `C' = `newnames'
			mat colnames `C' = `: colfullnames(`A')' 
		}
		else {
			local cols : colfullnames(`A') 
			tokenize `cols' 
			forval j = 1/`nc' {
				replace `names' = `"``j''"' in `j' 
				forval i = 1/`nr' { 
					replace `work' = `A'[`i', `j'] in `i' 
				} 
				su `work' in 1/`nr', `opt' 
				replace `su' = ///
				cond(`dec', -(r(`summary')), r(`summary')) in `j' 
			} 
			sort `su' `which' 
			forval j = 1/`nc' { 
				local newnames `"`newnames' `"`=`names'[`j']'"'"' 
				forval i = 1/`nr' { 
					local k = `which'[`j'] 
					mat `C'[`i',`j'] = `A'[`i',`k'] 
				}
			} 
			mat colnames `C' = `newnames'
			mat rownames `C' = `: rowfullnames(`A')'
		}
	}	

	// overwrite only if we got to here without problems 
	mat `B' = `C'    
end


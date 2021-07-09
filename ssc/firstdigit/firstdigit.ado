*! NJC 1.0.1 27 May 2007
*! NJC 1.0.0 22 May 2007
program firstdigit, rclass byable(recall)
	version 9.1 
	syntax varlist(numeric) [if] [in] ///
	[, BY(varname) ALLobs MISSing PERcent ]

	quietly { 
		// what observations to use 
		if "`allobs'" != "" marksample touse, novarlist 
		else marksample touse
		
		if "`by'" != "" & "`missing'" == "" markout `touse' `by', strok 
		
		count if `touse' 
		if r(N) == 0 error 2000

		// variable(s) or group(s) 
		local nv : word count `varlist'

		// by option 
		if "`by'" != "" { 
			if `nv' > 1 { 
				di as err ///
				"by() cannot be combined with `nv' variables"
				exit 198 
			}

			tempname stub
			separate `varlist' if `touse', ///
			by(`by') g(`stub') veryshortlabel `missing' 
			local varlist "`r(varlist)'" 
			local nv : word count `varlist' 
		} 	

		// display preparation and initiation 
		local nam = 0 
		foreach v of local varlist { 
			if "`by'" != "" {
				local nam = ///
				max(`nam', length(`"`: variable label `v''"')) 
			}	
			else local nam = max(`nam', length("`v'")) 
		}	
		local col = min(28, `nam') + 1 
	
		local txt ///
		"       n   chi-sq.  P-value   digit   observed   expected"
		noi di _n as txt "{col `col'}`txt'" 

		local line = `col' - 1 + length("`txt'")
		noi di "{hline `line'}"

		tempvar thisuse 
		gen byte `thisuse' = . 
		local ofmt = cond("`percent'" != "", "%11.2f", "%11.0f") 

		// loop over variables (-separate- results if -by()-) 
		foreach v of local varlist { 
			local which = ///
			cond("`by'" != "", `"`: variable label `v''"', "`v'") 
			local which = abbrev(`"`which'"', `col' - 1) 	
			replace `thisuse' = `touse' & `v' < . 

			mata : fd_work("`v'", "`thisuse'", "`percent'") 
		
			noi di as text `"`which'{col `col'}"'        "`sp'" ///
			       as res %8.0f r(N)                            ///
                               as res %10.2f r(chisq)                       ///
                               as res %9.4f r(p)                            ///
			       as res "       1" `ofmt' r(obs1) %11.2f r(exp1) 		                            
			return scalar obs1 = r(obs1) 
			return scalar exp1 = r(exp1)
 
			noi forval i = 2/9 { 
				di as res "{col `col'}`sp'{space 34}`i'"     ///
				`ofmt' r(obs`i') %11.2f r(exp`i') 
				return scalar obs`i' = r(obs`i') 
				return scalar exp`i' = r(exp`i') 
			}

			return scalar p = r(p) 
			return scalar chisq = r(chisq) 
			return scalar N = r(N) 

			local --nv 
			if `nv' noi di " " 
		}
	}	
end 

mata : 

void fd_work(string scalar varname, 
             string scalar tousename, 
             string scalar percent) 
{ 
	real colvector y, obs, exp 
	real scalar n, i, chisq   
	string scalar name 

        y = st_data(., varname, tousename)    
	n = rows(y) 
	exp = obs = J(9, 1, 0) 

	y = strtoreal(substr(strofreal(y), 1, 1))

	for (i = 1; i <= 9; i++) {
		obs[i] = colsum(y :== i) 
		exp[i] = n * log10(1 + 1/i)
		name = "r(obs" + strofreal(i) + ")"
		st_numscalar(name, 
			percent == "" ? obs[i] : 100 * obs[i] / n) 
		name = "r(exp" + strofreal(i) + ")"
		st_numscalar(name, 
			percent == "" ? exp[i] : 100 * log10(1 + 1/i)) 
	} 

	chisq = colsum(((obs - exp):^2) :/ exp) 
	st_numscalar("r(p)", chi2tail(8, chisq)) 
	st_numscalar("r(chisq)", chisq)
	st_numscalar("r(N)", n)
}  	

end


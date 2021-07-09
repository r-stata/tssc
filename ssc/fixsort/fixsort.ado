*! 2.0.0 NJC 26 October 2010 
* 1.1.0 NJC 3 August 2005 
* 1.0.0 NJC 19 July 2005 
program fixsort 
	version 9 
	syntax varlist [if] [in] , Generate(str) [ Reverse MISSing ] 

	quietly { 
		confirm new var `generate' 
		if `: word count `generate'' != `: word count `varlist'' { 
			di as err "`varlist' and `generate' do not match"
			exit 498 
		}

		tokenize "`generate'" 
		tempvar touse thisuse
		mark `touse' `if' `in' 
		count if `touse' 
		if r(N) == 0 error 2000

		local sortedby : sortedby 
		gen byte `thisuse' = 1  
		local dir = cond("`reverse'" != "", -1, 1) 

		foreach v of local varlist { 
			clonevar `1' = `v' 
			if `"`: var label `v''"' == "" {
				label variable `1' "`v'" 
			}	

			if "`missing'" == "" { 
				replace `thisuse' = `touse' & !missing(`v')
				mata : fixsort("`1'", "`thisuse'", `dir') 
			}
			else mata : fixsort("`1'", "`touse'", `dir') 

			mac shift
		}

		if "`sortedby'" != "" { 
			sort `sortedby'
		}
	}	
end

mata : 

void fixsort(string scalar varname, string scalar touse, numeric scalar dir)	
{ 
	transmorphic vector x
	real scalar n, N 
	N = st_numscalar("c(N)")  
	if (st_isnumvar(varname)) {
		x = st_data(., varname, touse) 
		n = rows(x) 
		st_store((1::n), varname, sort(x, dir)) 
		if (n < N) { 
			x = J((N - n), 1, .) 
			st_store((n+1::N), varname, x) 
		}
	}
	else {
		x = st_sdata(., varname, touse) 
		n = rows(x) 
		st_sstore((1::n), varname, sort(x, dir)) 
		if (n < N) { 
			x = J((N - n), 1, "") 
			st_sstore((n+1::N), varname, x) 
		}
	}
} 

end 


*! 1.1.1 NJC 4 Nov 2006 
* 1.1.0 NJC 12 Oct 2006 
* 1.0.0 NJC 9 Sept 2006 
program nrunsi, sort rclass 
        version 9 
	syntax anything(id="values in sequence") ///
		[, nreps(int 10000) saving(str) ] 
        tokenize "`anything'"
	local nvals : word count `anything' 

	quietly { 
		preserve 
		drop _all 
		set obs `nvals' 

		tempvar values runs freq prob 
		gen `values' = "" 

		forval i = 1/`nvals' { 
			replace `values' = "``i''" in `i' 
		} 	

		count if `values' != `values'[_n-1]   
		local obsruns = r(N)

		gen long `runs' = _n 
		mata: work(`nreps', "`c(seed)'", "`values'", "`freq'") 
		gen double `prob' = `freq' / `nreps' 
	}

	di _n as txt "observed number of values = " as res `nvals'
	di    as txt "observed number of runs   = " as res `obsruns'
	di _n as txt "simulated number of runs in " as res `nreps' ///
	      as txt " shuffles" _c 
	label var `runs' "# of runs" 
	label var `freq' "frequency" 
	label var `prob' "  probability"
	su `runs' if `freq', meanonly 
	tabdisp `runs' if inrange(`runs', `r(min)', `r(max)'), ///
		c(`freq' `prob') 

	su `prob' if `runs' < `obsruns', meanonly 
	return scalar pless = r(sum) 
	di _n as txt "    P(# of runs < " as res `obsruns' ///
	      as txt ") = " %7.5f as res r(sum)  

	su `prob' if `runs' == `obsruns', meanonly
	return scalar psame = r(sum) 
	di as txt "    P(# of runs = " as res `obsruns'    ///
	   as txt ") = " %7.5f as res r(sum)  

	su `prob' if `runs' > `obsruns', meanonly 
	return scalar pmore = r(sum) 
	di as txt "    P(# of runs > " as res `obsruns'    ///
	   as txt ") = " %7.5f as res r(sum)  

	if `"`saving'"' != "" { 
		quietly { 
			clonevar values = `values'
			clonevar runs   = `runs'
			clonevar freq   = `freq' 
			clonevar prob   = `prob' 
			label var prob "probability" 
			sort runs 
			keep values runs freq prob 
		}

		di 
		save `saving' 
	}	
end

mata: 

void work(real scalar nreps, 
	  string scalar seed,  
	  string scalar valuesname, 
	  string scalar freqname) 
{	  
	string colvector values 
	real colvector freq 
	real scalar n, runs
	
	values = st_sdata(., valuesname) 
	n = rows(values) 
	freq = J(n, 1, 0) 
	uniformseed(seed) 

	for(i = 1; i <= nreps; i++) { 
		_jumble(values)
		runs = 1 + sum(values[|1\n-1|] :!= values[|2\n|]) 
		freq[runs] = freq[runs] + 1 
	} 	

	st_addvar("long", freqname) 
	st_store(., freqname, freq) 
}

end 

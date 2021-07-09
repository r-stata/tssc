*! 1.1.1 NJC 4 Nov 2006 
* 1.1.0 NJC 12 Oct 2006 
* 1.0.0 NJC 9 Sept 2006 
program nruns, sort rclass 
        version 9  
	syntax varname [if] [in] [, nreps(int 10000) saving(str) ] 
	marksample touse, strok 

	quietly { 
		count if `touse' 
		if r(N) == 0 error 2000
		local nvals = r(N) 

		tempvar obsno 
		gen long `obsno' = _n 
		su `obsno' if `touse' 
		if r(N) != (r(max) - r(min) + 1) { 
			di as err "data not contiguous" 
			exit 498
		}	

		tempvar runs freq prob 
		replace `touse' = -`touse' 
		sort `touse' `obsno' 
		count if `varlist' != `varlist'[_n-1] & `touse' 
		local obsruns = r(N)

		gen long `runs' = _n

		capture confirm str variable `varlist' 
		if _rc { 
			tempvar values 
			gen `values' = string(`varlist')
		}
		else local values "`varlist'" 

		mata: work(`nreps', "`c(seed)'", `nvals', "`values'", "`freq'") 
		gen double `prob' = `freq' / `nreps' 
	}

	di _n as txt "observed number of items = " as res `nvals'
	di    as txt "observed number of runs  = " as res `obsruns'
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
			clonevar values = `varlist'
			clonevar runs   = `runs'
			clonevar freq   = `freq' 
			clonevar prob   = `prob' 
			label var prob "probability" 
			sort runs 
		}

		preserve 
		keep if `touse' 
		keep values runs freq prob 
		di 
		save `saving' 
	}	
end

mata: 

void work(real scalar nreps, 
	  string scalar seed,  
	  real scalar nvals, 
	  string scalar valuesname, 
	  string scalar freqname) 
{	  
	string colvector values 
	real colvector freq 
	real scalar n, runs
	
	values = st_sdata(., valuesname) 
	n = rows(values) 
	values = values[|1 \ nvals|]
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

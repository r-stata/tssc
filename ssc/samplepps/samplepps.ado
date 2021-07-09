*! version 1.0.1 24june2005  Stephen Jenkins 
*! Draw random sample, proportional to size, of n cases

program define samplepps, rclass sortpreserve
	
	version 8
	syntax newvarname(generate) [if] [in], Size(varname numeric) ///
		Ncases(integer) [ WITHrepl ]

quietly {

	recast byte `varlist'
	replace `varlist' = 0

	marksample touse
	markout `touse' `size'

	count if `touse' 
	local nobs = r(N)
        if `nobs' == 0 { 
		capture drop `varlist'
                di as error "no valid observations"
                error 2000
	}

	tempvar randu ub lb 

	ge `randu' = uniform() if `touse'
	sort `randu' 		// random ordering of clusters

		// with replacement

	if "`withrepl'" != "" {

		ge `ub' = sum(`size') if `touse'
		su `size' if `touse', meanonly
		replace `ub' = `ub'/r(sum) if `touse'
		ge `lb' = 0 in 1
		replace `lb' = `ub'[_n-1] if missing(`lb') & `touse'
		replace `varlist' = 0 if `touse'
		forvalues i = 1/`ncases' {
			local draw = uniform()
			replace `varlist' = `varlist' + 1 	///
				if inrange(`draw',`lb',`ub') & `touse'
		}
	}

		// without replacement

	if "`withrepl'" == "" {

		if (`nobs' < `ncases')  {
			capture drop `varlist'
			di as error "{p 0 0 4}number cases to select "
			di as error "> number of valid obs{p_end}"
			error 197
		}
		su `size' if `touse', meanonly
		local sumsize = r(sum)
		count if (`size'/`sumsize' >= 1/`ncases' & `touse')  
		if `r(N)' > 0 {
			capture drop `varlist'
			di as error "{p 0 0 4}`r(N)' cases have "
			di as error "size/(total size) > 1/(no. cases){p_end}"
			error 197
		}
		ge `ub' = sum(`size') if `touse'
		replace `ub' = `ncases'*`ub'/`sumsize' if `touse'
		ge `lb' = 0 in 1
		replace `lb' = `ub'[_n-1] if missing(`lb') & `touse'
		local draw = uniform()
		local R = 0
		forvalues i = 0/`=`ncases'-1' {
			local pick = `draw' + `R'
			replace `varlist' = 1 	///
				if inrange(`pick',`lb',`ub') & `touse'
			local R = `R' + 1
		}
	}

	replace `varlist' = . if `touse' == 0
	lab var `varlist' "=1:selected case"

	return scalar ncases = `ncases'
	return scalar nobs = `nobs'
	return local sizevar = "`size'"
	return local sample "`varlist'"
	return scalar withrepl = ("`withrepl'" != "")
		

}
end


*! 2.0.0 SPJ September 2006 (port to version 8.2)
*! version 1.0.1 Stephen P. Jenkins, Dec 1998
*! Quantiles, shares of total, and (generalised) Lorenz ordinates 
*! Syntax: sumdist <varname>, ngps(# quantile gps) qgp(name)



program define sumdist, rclass sortpreserve byable(recall)

        version 8.2
 
	 syntax varname(numeric) [aweight fweight] [if] [in] 	///
                [, Ngps(int 10) QGP(name) PVar(string) 		///
		   LVar(string) GLVar(string)   ]

        local inc "`varlist'"

	if (`ngps' <= 0 | `ngps' > 100) {
	  di as error "# quantile groups should be integer in range (0,100]"
	  exit 198
	}       

	tempvar nk vk fik last wi touse qrel meanyk /*
		*/ incsh cuincsh gl qtile 

	if "`qgp'" ~= "" & _bylastcall() confirm new variable `qgp' 
	else tempvar qgp

	if "`pvar'" != "" & _bylastcall()  confirm new variable `pvar' 
	else tempvar pvar

	if "`lvar'" != ""  & _bylastcall() confirm new variable `lvar' 
	else tempvar lvar

	if "`glvar'" != "" & _bylastcall()  confirm new variable `glvar' 
	else tempvar glvar

	if "`weight'" == "" ge `wi' = 1
	else ge `wi' `exp'

	mark `touse' `if' `in'
	markout `touse' `varlist'

	if _by() quietly replace `touse' = 0 if `_byindex' != _byindex()
 
	set more off


quietly {

	count if `inc' < 0 & `touse'
	local ct = _result(1)
	if `ct' > 0 {
		noi di " "
		noi di as txt "Warning: `inc' has `ct' values < 0." _c
		noi di as txt " Used in calculations"
		}
	count if `inc' == 0 & `touse'
	local ct = _result(1)
	if `ct' > 0 {
		noi di " "
		noi di as txt "Warning: `inc' has `ct' values = 0." _c
		noi di as txt " Used in calculations"
		}

	// remove comment out of next line if want to exclude 
	// obs with `inc' < 0 in calculations 
	
*	replace `touse' = 0 if `inc' < 0

	// stop if no valid obs
        qui count if `touse' 
        if r(N) == 0 error 2000 


	sum `inc' [w = `wi'] if `touse', de 
        local sumwi = r(sum_w)
	local N = r(N)
        local meany = r(mean)
	local mediany = r(p50)
	foreach P in 5 10 25 50 75 90 95 { 
		local p`P'  = r(p`P')
	}	

	xtile `qgp' = `inc' [w= `wi'] if `touse', nq(`ngps')

	sort `qgp' `touse' `inc'
	by `qgp': ge `last' = (_n==_N)   if `touse'

	by `qgp': egen double `nk' = sum(`wi') if `touse'
	ge double `vk' = `nk'/`sumwi' if `touse'
	ge double `fik' = `wi'/`nk' if `touse'
	by `qgp': egen double `meanyk' = sum(`fik'*`inc') if `touse'
	sort `qgp' `touse' `inc'
	by `qgp': ge double `qtile' = `inc' if `last' & `touse' & `qgp' < .

	by `qgp': ge double `qrel' = 100 * `qtile'/`mediany'  if `touse'

	ge double `incsh' = 100 * `vk' * `meanyk'/`meany' if `touse' & `last'
	sort `qgp'
	ge double `cuincsh' = sum(`incsh')  if `touse'
	ge double `gl' = `cuincsh'*`meany'/100  if `touse'

	replace `qtile' = . if `qgp' == `ngps'
	replace `qrel' = . if `qgp' == `ngps'

	lab var `qgp' "Quantile group"
	lab var `qtile' "Quantile"
	lab var `qrel' "% of median"
	lab var `incsh' "Share, %"
	lab var `cuincsh' "L(p), %"
	lab var `gl' "GL(p)"

	tempname qs shs qrels
	mat `qs' = J(1,`=`ngps'-1',0)
	mat `qrels' = J(1,`=`ngps'-1',0)
	mat `shs' = J(1,`ngps',0)

	forvalues j = 1/`ngps' {
		sum `incsh' if `touse' & `last' & (`qgp' == `j') , meanonly
		local sh`j' = r(mean)/ 100
		mat `shs'[1,`j'] = r(mean)
		if `j' == 1 {
			local cush`j' = `sh1'
		}
		else {
			local cush`j' = `cush`=`j'-1'' + `sh`j''
		}

		local gl`j' = `meany'*`cush`j''  

		sum `qtile' if `last' & `touse' & (`qgp' == `j') , meanonly
		if `j' < `ngps' {
			local q`j' = r(mean)
			mat `qs'[1,`j'] = r(mean)
		}
		sum `qrel' if `last' & `touse' & (`qgp' == `j') , meanonly
		if `j' < `ngps' {
			local qrel`j' = r(mean) / 100
			mat `qrels'[1,`j'] = r(mean)
		}
	}


        return scalar mean = `meany'
        return scalar sum_w = `sumwi'
        return scalar N = `N'
        return scalar median = `mediany'
	foreach p in 5 10 25 50 75 90 95 {
		return scalar p`p' = `p`p''
	}

	return scalar ngps = `ngps'
	return matrix quantiles = `qs'
	return matrix shares = `shs' 
	return matrix relquantiles = `qrels'


	forvalues j = 1/`ngps'	{
		return scalar sh`j' = `sh`j'' 
		return scalar cush`j' = `cush`j''
		return scalar gl`j' = `gl`j''
		if `j' < `ngps' {
			return scalar q`j' = `q`j'' 
			return scalar qrel`j' = `qrel`j''
		}
	}


	// create variables that might be used for graphs
	ge `pvar' = 0 in 1
	ge `lvar' = 0 in 1
	ge `glvar' = 0 in 1

	forval z = 1/`ngps'  {
		replace `pvar' = `z' / `ngps' in `=`z'+1'
		replace `lvar' =  `cush`z'' in `=`z'+1'
		replace `glvar' = `gl`z'' in `=`z'+1'
	}	


}

	di " "
	di as txt "Distributional summary statistics, `ngps' quantile groups"
	tabdisp `qgp' if `last' & `touse', /*
		*/ c(`qtile' `qrel' `incsh' `cuincsh' `gl') f(%10.3f)
	di in gr "Share = quantile group share of total `inc'; " 
	di in gr "L(p)=cumulative group share; GL(p)=L(p)*mean(`inc')"

end



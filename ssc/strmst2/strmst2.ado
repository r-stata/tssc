/* 10.0 AMC 29sep2019 */

program strmst2, rclass byable(recall)

	version 10

	* confirm that the data are -stset-
	if "`_dta[_dta]'"!="st" {
		disp as error "data not st"
		exit 119
		}

	syntax varlist(max=1 numeric) [if] [in], [tau(numlist > 0 max=1 miss) level(cilevel) ///
								   covariates(varlist min=1 numeric) reference(numlist >= 0 max=1) rmtl] 
								   
	/* mark sample to use in the analysis */
	marksample touse
	local completevars _t _d `varlist' `covariates'
	markout `touse' `completevars'
	quietly count if `touse'==1
	di " "
	di as input "Number of observations for analysis = " r(N)

	
	global arm = "`varlist'"
	global level = `level'
	global tau = "`tau'"
	global covariates = "`covariates'"
	global time = "_t"
	global fail = "_d"
	global reference = "`reference'"
	
	/* determine unique value of the arm variable */
	quietly tab $arm, matrow(matname)
	global narm = rowsof(matname)
	
	* confirm that supplied reference is one of the applicable values
	if "$reference"~="" {
		local okref=0
		forvalues i=1(1)$narm {
			if $reference==el(matname,`i',1) {
				local okref=1
				}
			}
		if `okref'==0 {
			disp as error "error: none of the subjects are in the group with the supplied reference value"
			exit 198
			}
		}

	
	* assign reference arm (if not supplied)
	if "$reference"=="" {
		global reference = el(matname,1,1)
		}	
	
	* list of arms in ascending order
	local armnumlist = ""
	forvalues i=1(1)$narm {
		local armnumlist = "`armnumlist'" + " " + string(el(matname,`i',1))
		}
		
	* list of arms in descending order
	local armnumlistrev = ""
	forvalues i=$narm(-1)1 {
		local armnumlistrev = "`armnumlistrev'" + " " + string(el(matname,`i',1))
		}
		
	* list of arms in descending order, omitting the reference category
	local armnumlistrev_noref = subinstr("`armnumlistrev'","$reference","",.)
	
	/* assign default tau */
	local defaulttau = .
	foreach i of numlist `armnumlist' {
		quietly sum $time if $fail==1 & $arm==`i' & `touse'==1
		local defaulttau = min(r(max), `defaulttau')
		}

	/* assign maximum tau */
	local maxtau = .
	foreach i of numlist `armnumlist' {
		quietly sum $time if $arm==`i' & `touse'==1
		local maxtau = min(r(max), `maxtau')
		}
	local maxtauf = string(`maxtau', "%9.3f")
	
	disp " "
	if "$tau" == "" {
		global tau2 = `defaulttau'
		local tau2f = string($tau2, "%9.3f")
		disp as input "The truncation time, tau, was not specified. Thus, the default tau (the minimum of the"
		disp as input "largest observed event time within each group), `tau2f', is used."
		global tau = `defaulttau'
		}
	else {
		if $tau > `maxtau' {
			disp as error "error: The truncation time, tau, needs to be shorter than or equal to the minimum of the"
			disp as error "largest observed time within each of the groups: `maxtauf'"
			exit 198
			}
		else {
			if $tau > `defaulttau' {
				global tau2 = $tau
				disp in yellow "The truncation time: tau = $tau was specified, but there are no observed events after"
				disp in yellow "tau = $tau in at least one group. Make sure that the size of riskset at tau = $tau is"
				disp in yellow "large enough in each group."
				}
			else {
				global tau2 = $tau
				disp as input "The truncation time: tau = $tau was specified."
				}
			}
		}
		

	*-------------unadjusted analysis
	if "$covariates"=="" {
		foreach i of numlist `armnumlist' {
			preserve
			quietly keep if $arm==`i' & `touse'==1
			rmst1
			matrix rmst`i' = r(outrmst)
			matrix rmtl`i' = r(outrmtl)
			matrix rmst1out`i'=r(output)
			scalar rmstvar`i' = r(rmstvar)
			restore 
			}

		*-------------contrast 1 (RMST difference) ---
		foreach i of numlist `armnumlistrev_noref' {
				scalar rmstdiff10	 = el(rmst`i',1,1) - el(rmst$reference,1,1)
				scalar rmstdiff10se  = sqrt(rmstvar`i' + rmstvar$reference)
				scalar rmstdiff10low = rmstdiff10 - invnorm(1 - (100-$level)/2/100)*rmstdiff10se
				scalar rmstdiff10upp = rmstdiff10 + invnorm(1 - (100-$level)/2/100)*rmstdiff10se
				scalar rmstdiffpval  = (1 - normprob(abs(rmstdiff10 / rmstdiff10se)))*2
				matrix rmstdiffresult`i' = (rmstdiff10, rmstdiff10low, rmstdiff10upp, rmstdiffpval)
				}
			

		*-------------contrast 2 (RMST ratio) ---
		foreach i of numlist `armnumlistrev_noref' {
			scalar rmstlogratio10    = log(el(rmst`i',1,1)) - log(el(rmst$reference,1,1))
			scalar rmstlogratio10se  = sqrt(rmstvar`i'/el(rmst`i',1,1)/el(rmst`i',1,1) + rmstvar$reference/el(rmst$reference,1,1)/el(rmst$reference,1,1))
			scalar rmstlogratio10low = rmstlogratio10 - invnorm(1 - (100-$level)/2/100)*rmstlogratio10se
			scalar rmstlogratio10upp = rmstlogratio10 + invnorm(1 - (100-$level)/2/100)*rmstlogratio10se
			scalar rmstlogratiopval  = (1 - normprob(abs(rmstlogratio10 / rmstlogratio10se)))*2
			matrix rmstratioresult`i' = (exp(rmstlogratio10), exp(rmstlogratio10low), exp(rmstlogratio10upp), rmstlogratiopval)
			}
		

		*-------------contrast 3 (RMTL ratio) ---
		foreach i of numlist `armnumlistrev_noref' {
			scalar rmtllogratio10    = log(el(rmtl`i',1,1)) - log(el(rmtl$reference,1,1))
			scalar rmtllogratio10se  = sqrt(rmstvar`i'/el(rmtl`i',1,1)/el(rmtl`i',1,1) + rmstvar$reference/el(rmtl$reference,1,1)/el(rmtl$reference,1,1))
			scalar rmtllogratio10low = rmtllogratio10 - invnorm(1 - (100-$level)/2/100)*rmtllogratio10se
			scalar rmtllogratio10upp = rmtllogratio10 + invnorm(1 - (100-$level)/2/100)*rmtllogratio10se
			scalar rmtllogratiopval  = (1 - normprob(abs(rmtllogratio10 / rmtllogratio10se)))*2
			matrix rmtlratioresult`i' = (exp(rmtllogratio10), exp(rmtllogratio10low), exp(rmtllogratio10upp), rmtllogratiopval)
			}
			
			
		*----combine results ---
		foreach i of numlist `armnumlistrev_noref' {
			matrix outunadj`i'=(rmstdiffresult`i' \ rmstratioresult`i' \ rmtlratioresult`i' )
			matrix rownames outunadj`i' = RMSTdiff RMSTratio RMTLratio
			matrix colnames outunadj`i' = Estimate Lower$level% Upper$level% P 
			}


		*------display RMST results

			* header
			di _n in gr "Restricted Mean Survival Time (RMST) by arm"
			di in smcl in gr "{hline 9}{c TT}{hline 49}" _n "   Group" _col(10) "{c |}" ///
							 _col(13) "Estimate" _col(25) "Std. Err." _col(40) "[$level% Conf. Interval]"  
			di in smcl in gr "{hline 9}{c +}{hline 49}"
			
			foreach i of numlist `armnumlistrev' {
				di in smcl in gr %8s "arm `i'" " {c |}" in ye ///
					 _col(14) %7.3f el(rmst1out`i',1,1)		///
					 _col(24) %9.3f el(rmst1out`i',1,2)		///
					 _col(37) %9.3f el(rmst1out`i',1,3)		///
					 _col(50) %9.3f el(rmst1out`i',1,4)		
				}
			
			* trailer
			di in smcl in gr "{hline 9}{c BT}{hline 49}"

		*------display RMTL results
		if "`rmtl'"=="rmtl" {
			* header
			di _n in gr "Restricted Mean Time Lost (RMTL) by arm"
			di in smcl in gr "{hline 9}{c TT}{hline 49}" _n "   Group" _col(10) "{c |}" ///
							 _col(13) "Estimate" _col(25) "Std. Err." _col(40) "[$level% Conf. Interval]"  
			di in smcl in gr "{hline 9}{c +}{hline 49}"
			
			foreach i of numlist `armnumlistrev' {
				di in smcl in gr %8s "arm `i'" " {c |}" in ye ///
					 _col(14) %7.3f el(rmst1out`i',2,1)		///
					 _col(24) %9.3f el(rmst1out`i',2,2)		///
					 _col(37) %9.3f el(rmst1out`i',2,3)		///
					 _col(50) %9.3f el(rmst1out`i',2,4)
				}
				 
			* trailer
			di in smcl in gr "{hline 9}{c BT}{hline 49}"
			}
			
		*------display between group contrasts

		foreach i of numlist `armnumlistrev_noref' {
			* header
			di _n in gr "Between-group contrast (arm `i' versus arm $reference) "
			di in smcl in gr "{hline 21}{c TT}{hline 50}" _n "           Contrast" _col(22) "{c |}" ///
							 _col(25) "Estimate"  _col(40) "[$level% Conf. Interval]"  _col(65) "P>|z|" 
			di in smcl in gr "{hline 21}{c +}{hline 50}"
			
			* difference in RMST
			di in smcl in gr %8s "RMST (arm `i' - arm $reference)" " {c |}" in ye ///
				 _col(26) %7.3f el(outunadj`i',1,1)		///
				 _col(37) %9.3f el(outunadj`i',1,2)		///
				 _col(50) %9.3f el(outunadj`i',1,3)		///
				 _col(61) %9.3f el(outunadj`i',1,4)
			
			* Ratio of RMST
			di in smcl in gr %8s "RMST (arm `i' / arm $reference)" " {c |}" in ye ///
				 _col(26) %7.3f el(outunadj`i',2,1)		///
				 _col(37) %9.3f el(outunadj`i',2,2)		///
				 _col(50) %9.3f el(outunadj`i',2,3)		///
				 _col(61) %9.3f el(outunadj`i',2,4)	

		if "`rmtl'"=="rmtl" {
			* Ratio of RMTL
			di in smcl in gr %8s "RMTL (arm `i' / arm $reference)" " {c |}" in ye ///
				 _col(26) %7.3f el(outunadj`i',3,1)		///
				 _col(37) %9.3f el(outunadj`i',3,2)		///
				 _col(50) %9.3f el(outunadj`i',3,3)		///
				 _col(61) %9.3f el(outunadj`i',3,4)	
			}

			* trailer
			di in smcl in gr "{hline 21}{c BT}{hline 50}"
			}
		
		*--------return results ---
		foreach i of numlist `armnumlistrev' {
			return matrix rmstarm`i'=rmst1out`i'
			return scalar rmstvar`i'=rmstvar`i'
			}
		foreach i of numlist `armnumlistrev_noref' {
			return matrix unadjustedresult`i' = outunadj`i'
			}
			return scalar tau = $tau
			return scalar reference = $reference
	}
	

	*-------------adjusted analysis
	if "$covariates"~="" {
		* list in arms in ascending order, excluding the referent
		global armnumlist_noref = subinstr("`armnumlist'","$reference","",.)
		global armlist = ""
		* create dummy variables for each level of the treatment variable
		local armtext = "$arm"
		capture drop _I`armtext'*
		foreach num of numlist $armnumlist_noref {
			quietly g _I`armtext'_`num' = $arm==`num'
			label var _I`armtext'_`num' "$arm==`num'"
			global armlist = "$armlist " + "_I`armtext'_`num'"
			}
		global armnumlist = "`armnumlist'"
		
		noisily disp in white "Note: adjusted analysis may take a few minutes to run..."
		rmst2regRUN `touse'
		local esttype rmtlratio rmstratio rmstdiff
		foreach e of local esttype {
			matrix `e' = r(`e'adj)
			matrix `e'cov = r(`e'cov)
			} 

		*----combine results ---
		matrix combinede = (rmstdiff[2..2,1..1] \ rmstratio[2..2,5..5] \ rmtlratio[2..2,5..5] )
		matrix combinedl = (rmstdiff[2..2,5..5] \ rmstratio[2..2,6..6] \ rmtlratio[2..2,6..6] )
		matrix combinedu = (rmstdiff[2..2,6..6] \ rmstratio[2..2,7..7] \ rmtlratio[2..2,7..7] )
		matrix combinedp = (rmstdiff[2..2,4..4] \ rmstratio[2..2,4..4] \ rmtlratio[2..2,4..4] )
		matrix outadj=combinede, combinedl, combinedu, combinedp
		matrix rownames outadj = RMSTdiff RMSTratio RMTLratio
		matrix colnames outadj = Estimate Lower$level% Upper$level% P 
			

		*------display RMST difference results
			* header
			di _n in gr "Model summary (difference of RMST)"
			di in smcl in gr "{hline 15}{c TT}{hline 60}" _n "        " _col(16) "{c |}" ///
							 _col(20) "Coef." _col(27) "Std. Err." _col(41) "z" _col(46) "P>|z|" _col(54) "[$level% Conf. Interval]"
			di in smcl in gr "{hline 15}{c +}{hline 60}"
				
			* list out parameter estimates
			local npar=rowsof(beta0)
			forvalues p=1(1)`npar' {
				di in smcl in gr %11s word("$covariates2",`p') _col(15) " {c |}" in ye ///
					 _col(18) %7.3f el(rmstdiff,`p',1)	///
					 _col(26) %9.3f el(rmstdiff,`p',2)	///
					 _col(38) %5.2f el(rmstdiff,`p',3)	///
					 _col(46) %5.3f el(rmstdiff,`p',4)	///
					 _col(54) %7.3f el(rmstdiff,`p',5) 	///
					 _col(66) %7.3f el(rmstdiff,`p',6) 
					 
				}
			* trailer
			di in smcl in gr "{hline 15}{c BT}{hline 60}"
			
		*------display RMST and RMTL ratio results
		if "`rmtl'"=="rmtl" {		
			local esttypes rmstratio rmtlratio
			}
		else {
			local esttypes rmstratio
			}
			foreach e of local esttypes {
				* header
				if "`e'"=="rmstratio" {
					di _n in gr "Model summary (ratio of RMST)"
					}
				if "`e'"=="rmtlratio" {
					di _n in gr "Model summary (ratio of time-lost)"
					}
				di in smcl in gr "{hline 15}{c TT}{hline 72}" _n "        " _col(16) "{c |}" ///
								 _col(20) "Coef." _col(27) "Std. Err." _col(41) "z" _col(46) "P>|z|" ///
								 _col(54) "exp(Coef.)" _col(66) "[$level% Conf. Interval]"
				di in smcl in gr "{hline 15}{c +}{hline 72}"
					
				* list out parameter estimates
				local npar=rowsof(beta0)
				forvalues p=1(1)`npar' {
					di in smcl in gr %11s word("$covariates2",`p') _col(15) " {c |}" in ye ///
						 _col(18) %7.3f el(`e',`p',1)	 ///
						 _col(26) %9.3f el(`e',`p',2)	///
						 _col(38) %5.2f el(`e',`p',3)	///
						 _col(46) %5.3f el(`e',`p',4)	///
						 _col(56) %7.3f el(`e',`p',5) 	///
						 _col(65) %7.3f el(`e',`p',6) 	///
						 _col(78) %7.3f el(`e',`p',7) 	
					}
				* trailer
				di in smcl in gr "{hline 15}{c BT}{hline 72}"
			} 

		*----return results
		local esttype rmtlratio rmstratio rmstdiff
		foreach e of local esttype {
			return matrix `e'adj = `e'
			return matrix `e'cov = `e'cov
			}
		return scalar tau = $tau
		return scalar reference = $reference
	}


end	


*-----------------------------------------------------
*--------rmst1 (one-arm)--hidden
*-----------------------------------------------------
program rmst1, rclass

	quietly {

		sts gen surv=s nrisk=n nevent=d
		keep _t surv nrisk nevent
		duplicates drop
		keep if _t < $tau
		sort _t
		count
		local newobs = r(N) + 1
		set obs `newobs'
		replace _t = $tau in `newobs'

		g timediff = _t in 1
		replace timediff = _t - _t[_n-1] if timediff==.
		g areas = timediff in 1
		replace areas = timediff*surv[_n-1] if areas==.
		sum areas
		scalar rmst = r(sum)
		
		g wkvar = 0
		replace wkvar = nevent / (nrisk * (nrisk - nevent)) if nevent<.
		g revareas = areas[`newobs' - _n + 1] if _n < `newobs'
		g revwkvar = wkvar[`newobs' - _n ] if _n < `newobs'
		g temp1 = sum(revareas)^2 *revwkvar
		sum temp1
		scalar rmstvar = r(sum)
		scalar rmstse = sqrt(rmstvar)
		
		matrix outrmst = (rmst, rmstse, rmst - invnorm(1 - (100-$level)/2/100)*rmstse,  rmst + invnorm(1 - (100-$level)/2/100)*rmstse)
		matrix rownames outrmst = rmst
		matrix colnames outrmst = Estimate StdErr Lower$level% Upper$level% 
		matrix outrmtl = ($tau - rmst, rmstse, $tau - rmst - invnorm(1 - (100-$level)/2/100)*rmstse,  $tau - rmst + invnorm(1 - (100-$level)/2/100)*rmstse)
		matrix colnames outrmtl = Estimate StdErr Lower$level% Upper$level% 
		matrix rownames outrmtl = rmtl
		matrix output = (outrmst \ outrmtl)
		
		return matrix outrmst = outrmst
		return matrix outrmtl = outrmtl
		return matrix output = output
		return scalar tau = $tau
		return scalar rmstvar=rmstvar
		
	}
	
end

*-----------------------------------------------------
*--------rmst2reg (Lu)--hidden
*-----------------------------------------------------
* there is one item passed to the program: rmstdiff, rmstratio, or rmtlratio
program rmst2reg, rclass
	
	quietly {
	
		global esttype = "`0'"

		g intercept = 1
		global covariates2 = "intercept $armlist $covariates"
	
		local npar = wordcount("$covariates2")
		
		* create indicator for observed time after tau
		g after = $time >= $tau
		g y0 = min($tau, $time)
		g d0 = $fail
		replace d0=1 if after==1
		
		foreach i of numlist $armnumlist {
			quietly stset y0 if $arm==`i', f(d0=0)
			quietly sts gen surv`i'=s if $arm==`i'
			}
			
		g weights=.
		foreach i of numlist $armnumlist {
			quietly replace weights = d0 / surv`i' if $arm==`i'
			} 

		if "$esttype"=="rmstdiff" {
			glm y0 $covariates2 [iweight=weights], noconstant
			}
			
		if "$esttype"=="rmstratio" {
			glm y0 $covariates2 [iweight=weights], noconstant family(poisson)
			}
			
		if "$esttype"=="rmtlratio" {
			quietly g y0loss = $tau - y0
			replace y0loss = 0 if after==1 	/* for rounding error */
			glm y0loss $covariates2 [iweight=weights], noconstant family(poisson)
			}
		matrix beta0=e(b)
		matrix beta0 = beta0'
		svmat beta0, names(beta0)  
		putmata beta0=beta0, replace omitmissing
		
		* the next set of calculations are done separately by arm
		foreach num of numlist $armnumlist {
		
			preserve
			quietly keep if $arm==`num'
			sort y0
			putmata y0=y0 x=($covariates2), replace omitmissing
			if "$esttype"=="rmstdiff" {
				mata: mata_ediff(y0, x, beta0)
				}
			if "$esttype"=="rmstratio" {
				mata: mata_eratio(y0, x, beta0)
				}
			if "$esttype"=="rmtlratio" {
				putmata y0loss=y0loss, replace omitmissing
				mata: mata_eratio(y0loss, x, beta0)
				} 
			svmat error, names(error) 
			svmat x, names(x)
			forvalues j=1(1)`npar' {
				quietly g score`j' = x`j' * weights * error
				}
			forvalues j=1(1)`npar' {
				quietly g kappa1`j'=0
				quietly g kappa2`j'=0
				quietly g kappa3`j'=0
				}
			quietly count
			local n=r(N)
			forvalues i=1(1)`n'{
				forvalues j=1(1)`npar' {
					quietly replace kappa1`j' = score`j' in `i'
					quietly sum score`j' if y0 >= y0[`i']
					quietly replace kappa2`j' = r(sum) * (1 - d0[`i']) / r(N) in `i'
					forvalues k=1(1)`n' {
						quietly count if y0[`k'] <= y0[`i']
						if r(N) > 0 {
							quietly sum score`j' if y0 >= y0[`k']
							quietly replace kappa3`j' = kappa3`j' + r(sum) * (1 - d0[`k']) / r(N)^2 in `i'
							}
						}
					}
				}
			forvalues j=1(1)`npar' {
				quietly replace kappa1`j' = round(kappa1`j', 0.0001)
				quietly replace kappa2`j' = round(kappa2`j', 0.0001)
				quietly replace kappa3`j' = round(kappa3`j', 0.0001)
				g kappaarm`j'= kappa1`j' + kappa2`j' - kappa3`j'
				}
			putmata kappaarm`num'=(kappaarm*), replace omitmissing
			restore
			}
		
		* back to calculations between arms
		mata: gamma = kappaarm$reference'*kappaarm$reference
		foreach num of numlist $armnumlist_noref {
			mata: gamma = gamma + kappaarm`num''*kappaarm`num'
			}
		mata: st_matrix("gamma", gamma)
		putmata x=($covariates2), replace omitmissing
		
		if "$esttype"=="rmstdiff" {
			mata: mata_Adiff(x)
			}
		if "$esttype"=="rmstratio" | "$esttype"=="rmtlratio" {
			mata: mata_Aratio(x, beta0)
			}
		svmat A, names(A)
		svmat gamma, names(gamma)
		putmata A=(A*) gamma=(gamma*), replace omitmissing
		mata: mata_est(A, gamma, beta0)			
		local zscore = invnorm(1 - (100-$level)/2/100)
		if "$esttype"=="rmstdiff" { 
			mata : st_matrix("cilow", st_matrix("beta0") :- `zscore' :* st_matrix("se0"))
			mata : st_matrix("cihigh", st_matrix("beta0") :+ `zscore' :* st_matrix("se0"))
			}
		if "$esttype"=="rmstratio" | "$esttype"=="rmtlratio" {
			mata : st_matrix("r0", exp(st_matrix("beta0")))
			mata : st_matrix("cilow", exp(st_matrix("beta0") :- `zscore' :* st_matrix("se0")))
			mata : st_matrix("cihigh", exp(st_matrix("beta0") :+ `zscore' :* st_matrix("se0")))
			}
		
		return matrix beta0=beta0
		return matrix se0 = se0
		return matrix z0 = z0 
		return matrix p0 = p0
		return matrix covariance = covariance
		if "$esttype"=="rmstratio" | "$esttype"=="rmtlratio" {
			return matrix r0 = r0
			}
		return matrix cilow = cilow
		return matrix cihigh = cihigh
		
		drop A1 A2 A3 gamma1 gamma2 gamma3
	}

end

*-----------------------------------------------------
*--------rmst2regRUN--run the adjusted analysis
*-----------------------------------------------------
* there is one item passed to the program: touse, the indicator variable for complete data for inclusion in the analysis
program rmst2regRUN, rclass

	local touse = "`0'"

	quietly {
	
		local esttype rmstdiff rmstratio rmtlratio
		foreach e of local esttype {
			preserve
			quietly keep if `touse'==1
			rmst2reg `e'
			restore


			*--------return results ---
			matrix beta0 = r(beta0)
			matrix se0 = r(se0)
			matrix z0 = r(z0)
			matrix p0 = r(p0)
			matrix covariance = r(covariance)
			if "`e'"=="rmstratio" | "`e'"=="rmtlratio" {
				matrix r0 = r(r0)
				}
			matrix cilow = r(cilow)
			matrix cihigh = r(cihigh)
			

			if "`e'"=="rmstdiff" {
				matrix combined = beta0, se0, z0, p0, cilow, cihigh
				matrix roweq combined=""
				matrix rownames combined = $covariates2
				matrix colnames combined = Coefficient StdErr z p Lower$level% Upper$level% 
				}
			
			if "`e'"=="rmstratio" | "`e'"=="rmtlratio" {
				matrix combined = beta0, se0, z0, p0, r0, cilow, cihigh
				matrix roweq combined=""
				matrix rownames combined = $covariates2
				matrix colnames combined = Coefficient StdErr z p exp(Coef) Lower$level% Upper$level% 
				}
			return matrix `e'adj = combined
			
			matrix rownames covariance = $covariates2
			matrix colnames covariance = $covariates2
			return matrix `e'cov = covariance
		}
	}

end


*-----------------------------------------------------
*--------some mata subroutines
*-----------------------------------------------------
mata:
void mata_ediff(real colvector y0,
				real matrix x,
				real colvector beta0) {
	error = round(y0 - x*beta0, 0.0001)
 	st_matrix("error", error)
	st_matrix("x", x)
	}
end
mata:
void mata_eratio(real colvector y0,
				real matrix x,
				real colvector beta0) {
	error = round(y0 - exp(x*beta0),0.0001)
	st_matrix("error", error)
	st_matrix("x", x)
	}
end
mata:
void mata_gamma(real matrix gammabuild,
				real matrix kappaarmi) {
	gamma = gammabuild + kappaarmi'*kappaarmi
	st_matrix("gamma", gamma)
	}
end
mata:
void mata_Adiff (real matrix x) {
	A = x'*x
	st_matrix("A", A)
	}
end
mata:
void mata_Aratio (real matrix x,
				  real colvector beta0) {
	Abuild = x :* exp(x*beta0)
	A = Abuild'*x
	st_matrix("A", A)
	}
end
mata:
void mata_est (real matrix A,
			   real matrix gamma,
			   real colvector beta0) {
	covariance=invsym(A)*gamma*invsym(A)
	varbeta=diagonal(covariance)
	se0 = sqrt(varbeta)
	z0 = beta0 :/ se0
	p0 = chi2tail(1,z0:^2)
	st_matrix("beta0", beta0)
	st_matrix("se0", se0)
	st_matrix("p0", p0)
	st_matrix("z0", z0)
	st_matrix("covariance", covariance)
	}
end

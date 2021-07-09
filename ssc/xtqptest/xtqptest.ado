* Born and Breitung (2016) QP/LM-test for serial correlation
*! Version 1.1.1  06apr2018
* Contact jesse.wursten@kuleuven.be for bug reports/inquiries.

* Changelog
** 06apr2018: Reference to Stata Journal article added.
** 21nov2016: Crucial bug fix! Test was calculating the mean incorrectly if data were unbalanced (due to row-wise deletion in mata).
** 9nov2016: Crucial bug fix! Test would use completely wrong values if data were unbalanced.
** 16sep2016: Thanks to Sebastian Kripfganz for spotting an error.

/*
cap mata mata drop qp_statistic()
cap mata mata drop qp_statistic_unbalanced()

cap mata mata drop lm_statistic()
cap mata mata drop lm_statistic_unbalanced()
*/

program define xtqptest, rclass
	version 12
	preserve
	
	** Technicalities
	syntax [varlist(default=none)] [if] [in], [Lags(numlist integer max=1) ORder(numlist integer max=1) force]
	local p = "`lags'"
	local k = "`order'"
	
	*** Identify test procedure to use
	if "`p'" != "" & "`k'" != "" {
		noisily di as error "Currently you cannot specify both a lags and an order option, please execute command separately."
		exit
	}
	if "`p'" == "" & "`k'" == "" local p = 2
	
	if "`p'" != "" {
		local testFull = "Q(`p')"
		local test = "Q(p)"
	}
	else if "`k'" != "" {
		local testFull = "LM(`k')"
		local test = "LM(k)"
	}
	
	*** Postestimation?
	tempvar residuals
	if "`varlist'" == "" {
		predict `residuals', ue
		local varlist = "`residuals'"
		local postEstimation = "1"
	}
	
	** Fill out sample for mata (we reshape in Mata assuming a rectangular sample)
	tsfill, full
	
	*** Mark out if/in restrictions
	marksample toUse, novarlist

	
	*** Obtain time and panel variables
	qui xtset
	local panelvar = r(panelvar)
	local timevar = r(timevar)
			
	** Print results
	if "`postEstimation'" == "" di as result _newline "Bias-corrected Born and Breitung (2016) `test'-test on variables `varlist'"
	else						di as result _newline "Bias-corrected Born and Breitung (2016) `test'-test as postestimation"
	di as text "Panelvar: `panelvar'"
	di as text "Timevar: `timevar'"
	if "`p'" != ""				di as text "p (lags): `p'"
	if "`k'" != ""				di as text "k (order): `k'"
	di as text "{hline 30}{c TT}{hline 23}{c TT}{hline 16}{c TT}{hline 14}{c TRC}"
	di as text _col(2) %~28s = "Variable"  _col(30) " {c |}" _skip(1) "`test'-stat" _col(45) "p-value" _skip(2) " {c |}" _skip(6) "N" _skip(4) "maxT" " {c |}" %~14s = "balance?" "{c |}" 
	di as text "{hline 30}{c +}{hline 23}{c +}{hline 16}{c +}{hline 14}{c RT}"

	** Calculate statistic
	tempname stat pvalue obsCount
	tempvar t id toUse2
	local j = 1
	foreach var of local varlist {
		*** Clear locals
		local balance = ""
		local errorMessage = ""
		local tooShort = ""
		local minT = ""
		
		*** Obtain number of time and panel units
		qui egen `t' = group(`timevar') if `toUse' == 1 & ~missing(`var')
		sum `t', meanonly
		local timelength = r(max)
		
		qui egen `id' = group(`panelvar') if `toUse' == 1 & ~missing(`var')
		sum `id', meanonly
		
		local panelunits = r(max)
		
		***** Tag empty panels
		qui bysort `panelvar': egen `obsCount' = count(`var')
				
		*** Check balancedness
		local balance = ""
		
		**** Unbalanced
		qui count if ~missing(`var') & `toUse' == 1
		local totalObsUsed = r(N)
		local requiredObs = `timelength'*`panelunits'
		
		if `totalObsUsed' != `requiredObs' 	local balance = "unbalanced"
		
		**** With gaps
		tempvar gap
		qui bysort `panelvar' (`timevar'): gen `gap' = 1 if missing(`var') & ~missing(L.`var', F.`var') & `toUse' == 1
		qui count if `gap' == 1
		if r(N) != 0 local balance = "gaps (error)"
		
		**** Balanced
		if "`balance'" == "" local balance = "balanced"
		if "`force'" != "" & "`balance'" == "" local balance = "unbalanced"
		
		*** Unless force is specified ...
		if "`force'" == "" & "`p'" != "" {	
			* Test if residuals include the fixed effect
			tempvar mean_resid
			qui bysort `panelvar' (`timevar'): egen `mean_resid' = mean(`var') if `toUse' == 1
			qui sum `mean_resid' if `toUse' == 1
			drop `mean_resid'
			if r(sd) < 0.001 | abs(r(max)) < 0.001 | abs(r(min)) < 0.001 {
				*noisily di as error _col(2) %~28s = abbrev("`var'",28) 
				noisily di as error "`var': " _continue
				noisily di as error _col(4) "Residuals do not appear to include the fixed effect."
				noisily di as error _col(4) "This test is made to function with ue = c_i + e_it."
				noisily di as error _col(4) "If you are sure that your residuals do indeed include" _newline _col(4) "the fixed effect (programming bugs happen),"
				noisily di as error _col(4) "specify 'force' to skip this test."
				continue
			}
			
			* Test if T is sufficiently long
			tempvar nonMissing
			qui bysort `panelvar' (`timevar'): egen `nonMissing' = count(`var') if `obsCount' > 0
			sum `nonMissing', meanonly
			local minT = r(min)
			if `minT' <= `p' local tooShort = "tooShort"
			
			drop `nonMissing'
		}
		
		*** Update toUse variable 
		**** Exclude missings for the balanced case
		qui gen `toUse2' = `toUse'
		qui replace `toUse2' = 0 if missing(`var')
		
		**** Make sure unbalanced case performs properly
		qui replace `toUse' = 0 if `obsCount' == 0
		drop `obsCount'
		

		** Calculate statistics
		sort `panelvar' `timevar'

		*** Q(p) test ("upto order")
		if "`test'" == "Q(p)" & "`tooShort'" == "" {
			if "`balance'" == "balanced" mata: qp_statistic("`var'", "`toUse2'", `timelength', `panelunits', `p')
			else if "`balance'" == "unbalanced" mata: qp_statistic_unbalanced("`var'", "`toUse'", `panelunits', `p')
			
			scalar `stat' = round(QP, 0.001)
			scalar `pvalue' = round(pvalue, 0.001)
			
			else if "`balance'" == "gaps (error)" {
				scalar QP = .
				scalar `stat' = .
				scalar pvalue = .
				scalar `pvalue' = .
			}
		}
		
		if "`test'" == "Q(p)" & "`tooShort'" != "" {
			scalar QP = .
			scalar `stat' = .
			scalar pvalue = .
			scalar `pvalue' = .
			local errorMessage "At least one panel is too short, i.e. minT(`minT') <= lags(`p')"
		}
		
		*** LM(k) test ("of order")
		if "`test'" == "LM(k)" {
			if "`balance'" == "balanced" mata: lm_statistic("`var'", "`toUse2'", `panelunits', `k')
			
			else if "`balance'" == "unbalanced" mata: lm_statistic("`var'", "`toUse'", `panelunits', `k')
			
			scalar `stat' = round(LM, 0.001)
			scalar `pvalue' = round(pvalue, 0.001)
			
			else if "`balance'" == "gaps (error)" {
				scalar LM = .
				scalar `stat' = .
				scalar pvalue = .
				scalar `pvalue' = .
			}
		}
		
		** Display results
		if "`postEstimation'" == "1" local var = "Post Estimation"
		if "`errorMessage'" == "" di _col(2) %~28s = abbrev("`var'",28) _col(30)  " {c +}" _skip(3) %4.2f = `stat' _col(46) %4.3f = `pvalue' _col(55) "{c +}" %7.0f = `panelunits' %8.0f = `timelength' " {c +}" %~14s = "`balance'" "{c RT}"
		if "`errorMessage'" != "" di as error _col(2) "`var': `errorMessage'"
		
		** Return matrix, scalars and pvalue
		if "`test'" == "LM(k)" {
			mat lms = (nullmat(stats), LM)
			return scalar lm`j' = LM
		}
		if "`test'" == "Q(p)" {
			mat qps = (nullmat(stats), QP)
			return scalar qp`j' = QP
		}
		
		mat ps = (nullmat(ps), pvalue)
		return scalar pvalue`j' = pvalue
		local j = `j' + 1
		
		drop `toUse2' `t' `id'
	}

	** Notes
	di as text "{hline 30}{c BT}{hline 23}{c BT}{hline 16}{c BT}{hline 14}{c BRC}"
	if "`test'" == "Q(p)" {
		di _col(2) "Notes: Under H0, Q(p) ~ chi2(p)"
		di as txt _col(5) "H0: No serial correlation up to order p."
		di as txt _col(5) "Ha: Some serial correlation up to order p."
	}
	if "`test'" == "LM(k)" {
		di _col(2) "Notes: Under H0, LM(k) ~ N(0,1)"
		di as txt _col(5) "H0: No serial correlation of order k."
		di as txt _col(5) "Ha: Some serial correlation of order k."
	}
	
	** Return
	capture confirm matrix qps
	if _rc == 0	return matrix QP = qps
	capture confirm matrix lms
	if _rc == 0	return matrix LM = lms
	capture confirm matrix ps
	if _rc == 0	return matrix p = ps
	
	restore
end

mata:
	void qp_statistic(string scalar varname, string scalar toUse, real scalar T, real scalar N, real scalar p) {
		real matrix UE, ME, Z, ZMeeMZ, ZMe, innersum_inverse; real scalar n, QP, pvalue, firstcol, lastcol, k
		
		// ue = fe + e (currently we just use e, as it also seems to work)
		// me = e
		UE = rowshape(st_data(., varname, toUse), N)'
		ME = UE :- mean(UE)
		
		// Z
		Z = J(T, p*N, .)
		for(n=1; n<=N; n++) {
			firstcol = 1 + (n-1)*p
			for(k=1; k<=p; k++) {
				Z[., firstcol+k-1] = (J(k, 1, 0)\ME[1..T-k, n]) + (T-k)/(T^2 - T)*UE[.,n]
			}
		}

		// Inner sum
		ZMeeMZ = J(p,p,0)
		ZMe = J(p,1, 0)

		for(n=1; n<=N; n++) {
			firstcol = 1 + (n-1)*p
			lastcol = firstcol + p - 1
			ZMeeMZ = ZMeeMZ + Z[., firstcol..lastcol]' * ME[., n] * ME[., n]' * Z[., firstcol..lastcol]
			ZMe = ZMe + Z[., firstcol..lastcol]' * ME[., n]
		}

		innersum_inverse = invsym(ZMeeMZ - 1/N*ZMe*ZMe')
		
		// Qp-tilde		
		QP = ZMe' * innersum_inverse * ZMe
		pvalue = 1-chi2(p, QP)

		// Store results
		st_numscalar("QP", QP)
		st_numscalar("pvalue", pvalue)
	}
	
	void qp_statistic_unbalanced(string scalar varname, string scalar toUse, real scalar N, real scalar p) {
		real matrix UE, ME, Zi, ZMeeMZ, ZMe, innersum_inverse; real scalar n, QP, pvalue, k; real vector Ti
		
		UE = rowshape(st_data(., varname, toUse), N)'
		Ti = colnonmissing(UE)
		
		ZMeeMZ = J(p,p,0)
		ZMe = J(p,1, 0)
		for(n=1; n<=N; n++) {
			UEi = select(UE[.,n], UE[.,n]:!=.)
			MEi = UEi :- mean(UEi)
			Zi = J(Ti[n], p, .)
			for(k=1; k<=p; k++) {
				Zi[., k] = (J(k, 1, 0)\MEi[1..Ti[n]-k, 1]) + (Ti[n]-k)/(Ti[n]^2 - Ti[n])*UEi
			}
			ZMeeMZ = ZMeeMZ + Zi' * MEi * MEi' * Zi
			ZMe = ZMe + Zi' * MEi
		}
		
		innersum_inverse = invsym(ZMeeMZ - 1/N*ZMe*ZMe')	

		// Qp-tilde		
		QP = ZMe' * innersum_inverse * ZMe
		pvalue = 1-chi2(p, QP)

		// Store results
		st_numscalar("QP", QP)
		st_numscalar("pvalue", pvalue)
	}
end

mata:
	void lm_statistic(string scalar varname, string scalar toUse, real scalar N, real scalar k) {
		UE = rowshape(st_data(., varname, toUse), N)'
		E = J(rows(UE), cols(UE), .)
		for(n=1; n<=N; n++) {
			E[.,n] = UE[.,n] :- mean(UE[.,n])
		}
		
		T = rows(E)
		Ti = colnonmissing(E)
		
		Z = colsum(E[k+1..T, .]:*E[1..T-k, .] + (E[1..T-k, .]:^2):/(Ti:-1))

		// LM-tilde		
		LM = sum(Z)/sqrt(sum(Z:^2) - 1/N*(sum(Z))^2)
		pvalue = 2*(1-normal(abs(LM)))

		// Store results
		st_numscalar("LM", LM)
		st_numscalar("pvalue", pvalue)
	}
end

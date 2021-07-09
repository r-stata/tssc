* Inoue & Solon (2006) IS-test for serial correlation
*! Version 1.1.0 06apr2018
* Contact jesse.wursten@kuleuven.be for bug reports/inquiries.

* Changelog
** 06apr2018: Reference to Stata Journal article added.
** 4jan2017: Set 2 as default lag length again.
** 9nov2016: Crucial bug fix! Test would use completely wrong values if data were unbalanced.

* Known issues
** Max T reported is incorrect for gapped data

program define xtistest, rclass
	version 12
	preserve

	** Technicalities
	** hideerror is only used for monte carlo simulations
	syntax [varlist(default=none)] [if] [in] [, Lags(string) ORIGinal hideerror]
	if "`lags'" == "" local lags = "2"
	
	*** Postestimation?
	tempvar residuals
	if "`varlist'" == "" {
		predict `residuals', e
		local varlist = "`residuals'"
		local postEstimation = "1"
	}
	
	** Mark sample
	*** Gather info to convert long residuals vector into matrix
	tempvar originalObs
	gen byte `originalObs' = 1
	tsfill, full
	
	*** Mark out if/in restrictions
	marksample toUse, novarlist

	
	** Lag selection
	local p = "`lags'"
	if "`p'" == "all" local p_input = ""
	else {
		local p_input = "`p'"
		capture confirm integer number `p_input'
		
		* If they entered a lag number that's not a number or "all"
		if _rc != 0 {
			noisily di as error "Your choice of lags (`lags') does not appear to be either an integer or -all-."
			error 198
		}
	}
	
	** Obtain time and panel variables
	qui xtset
	local panelvar = r(panelvar)
	local timevar = r(timevar)
	
	** Print header
	if "`postEstimation'" == "" di as result _newline "Inoue and Solo (2006) LM-test on variables `varlist'"
	else						di as result _newline "Inoue and Solo (2006) LM-test as postestimation"
	di as text "Panelvar: `panelvar'"
	di as text "Timevar: `timevar'"
	if "`p_input'" != "" di as text "p (lags): `p'"
	di as text "{hline 30}{c TT}{hline 23}{c TT}{hline 16}{c TT}{hline 14}{c TRC}"
	di as text _col(2) %~28s = "Variable"  _col(30) " {c |}" _skip(2) "IS-stat" _skip(4) "p-value" _skip(2) " {c |}" _skip(6) "N" _skip(4) "maxT" " {c |}" %~14s = "balance?" "{c |}" 
	di as text "{hline 30}{c +}{hline 23}{c +}{hline 16}{c +}{hline 14}{c RT}"

	
	** Calculate statistic
	tempname is pvalue
	tempvar t t_ub id toUse2 obsCount

	local j = 0
	foreach var of local varlist {
		*** Clear locals
		local balance = ""
		local errorMessage = ""
		local timelength_ub = ""
	
		*** Obtain number of time and panel units
		**** T
		qui egen `t' = group(`timevar') if `toUse' == 1 & ~missing(`var')
		qui egen `t_ub' = group(`timevar') if `toUse' == 1	// This will be used in Mata when data is unbalanced
		sum `t', meanonly
		local timelength = r(max)
		
		sum `t_ub', meanonly
		local timelength_ub = r(max)
		
		**** N
		***** Obtain number of panel units
		qui egen `id' = group(`panelvar') if `toUse' == 1 & ~missing(`var')
		sum `id', meanonly
		local panelunits = r(max)
				
		***** Drop empty panels
		bysort `panelvar': egen `obsCount' = count(`var')
		
		if "`p_input'" == "" local p = `timelength'
		drop `t' `id' `t_ub'
		
		*** Check balancedness
		**** Unbalanced
		qui count if ~missing(`var') & `toUse' == 1
		local totalObsUsed = r(N)
		local requiredObs = `timelength'*`panelunits'
		
		if `totalObsUsed' != `requiredObs' 	local balance = "unbalanced"
		
		**** With gaps
		tempvar gap
		qui bysort `panelvar' (`timevar'): gen `gap' = 1 if missing(`var') & ~missing(L.`var', F.`var') & `toUse' == 1
		qui count if `gap' == 1
		if r(N) != 0 local balance = "gaps"
		
		**** Balanced
		if "`balance'" == "" local balance = "balanced"
		if "`force'" != "" & "`balance'" == "" local balance = "unbalanced"
		
		*** Check N > dimension
		if "`p_input'" == "" 	local dimension = (`timelength'-2)*(`timelength'-1)/2
		else 					local dimension = `p'*`timelength' - `p'*(`p'+1)/2
		if `dimension' > 0.75*`panelunits' local errorMessage = "N(`panelunits') is close to the dimension of H0(`dimension'), results unreliable. Consider xtqptest."
		if `dimension' > `panelunits' local errorMessage = "N(`panelunits') is smaller than the dimension of H0(`dimension'), results unreliable. Consider xtqptest."
				
		*** Update toUse variable 
		**** Exclude missings for the balanced case
		qui gen `toUse2' = `toUse'
		qui replace `toUse2' = 0 if missing(`var')
		
		**** Make sure unbalanced case performs properly
		qui replace `toUse' = 0 if `obsCount' == 0
		drop `obsCount'
			
		*** Perform calculations in mata
		**** Original
		if "`original'" != "" & "`p_input'" == "" {
			if "`balance'" == "balanced" {
				mata: is_statistic_orig("`var'", "`toUse2'", `timelength', `panelunits')
				scalar `is' = round(IS, 0.001)
				scalar `pvalue' = round(pvalue, 0.001)
			}
			else if "`balance'" != "balanced" {
				scalar `is' = .
				scalar `pvalue' = .
				local errorMessage = "Unbalanced panel cannot be combined with original at the moment."
			}
		}
		else if "`original'" != "" & "`p'" != "`timelength'" {
			scalar `is' = .
			scalar `pvalue' = .
			local errorMessage = "p()-option cannot be combined with original at the moment."
		}
		
		**** Born and Breitung implementation
		else {
			if "`balance'" == "balanced" mata: is_statistic_bb("`var'", "`toUse2'", `timelength', `panelunits', `p')
			else if "`balance'" != "balanced" mata: is_statistic_bb_unbalanced("`var'", "`toUse'", `timelength_ub', `panelunits', `p')

			scalar `is' = round(IS, 0.001)
			scalar `pvalue' = round(pvalue, 0.001)
		}
		
		*** Report results
		if "`postEstimation'" == "1" local var = "Post Estimation"µ
		di as txt _col(2) %~28s = abbrev("`var'",28) _col(30)  " {c +}" _skip(3) %4.2f = `is' _col(46) %4.3f = `pvalue' _col(55) "{c +}" %7.0f = `panelunits' %8.0f = `timelength' " {c +}" %~14s = "`balance'" "{c RT}" 
		if "`errorMessage'" != "" & "`hideerror'" == "" di as error _col(2) "`var': `errorMessage'"
		
		** Prep for return
		mat iss = (nullmat(iss), IS)
		mat ps = (nullmat(ps), pvalue)
		scalar IS`++j' = (IS)
		scalar p`j' = (pvalue)
		
		** Clean up
		qui drop if `originalObs' != 1
		drop `toUse2'
	}

	** Notes
	di as text "{hline 30}{c BT}{hline 23}{c BT}{hline 16}{c BT}{hline 14}{c BRC}"
	if "`p'" == "`timelength'" 	di _col(2) "Notes: Under H0, LM ~ chi2((T-1)(T-2)/2)"
	else						di _col(2) "Notes: Under H0, LM ~ chi2(p*T-p(p+1)/2)"
	di as txt _col(5) "H0: No auto-correlation of any order."
	if "`p_input'" == "" di as txt _col(5) "Ha: Auto-correlation of some order."
	else				 di as txt _col(5) "Ha: Auto-correlation up to order `p'."
	
	** Return
	return matrix IS = iss
	return matrix p = ps
	
	** for MC
	forvalues i = 1/`j' {
		return scalar pvalue`i' = p`i'
		return scalar is`i' = IS`i'
	}
	
	restore
end

mata: 
	void is_statistic_orig(string scalar varname, string scalar toUse, real scalar T, real scalar N) {
		// Define objects
		real matrix E, sigma, sigma2, D, M, V, V2, middleTerm; real colvector smallSigma, vecSigma, lT; real rowvector vec1, vecOne, vec1D; real scalar Dcolumns, sigmaSquared, LM, pvalue, i, IS
		
		// Load residuals and transform to matrix (each column represents residuals of one panel unit i)
		// ei = (e1,1, e1,2 ... e1,T)'
		// E = (e1, e2, ... eN)

		E = rowshape(st_data(., varname, toUse), N)'

		// Dk,T
		sigma = invvech((1 .. T*(T+1)/2)')

		sigma2 = sigma
		_diag(sigma2, -1)
		smallSigma = vech(sigma2[1..T-1, 1..T-1])
		smallSigma = select(smallSigma, smallSigma:>0)
		
		vecSigma = vec(sigma)
		sigma = .
		
		Dcolumns = rows(smallSigma)
		D = J(T^2, (T-1)*(T-2)/2, .)
		for(i=1; i <= Dcolumns; i++) {
			D[.,i] = vecSigma :== smallSigma[i, 1]
		}
		vecSigma = .
		smallSigma = .
		
		// M
		lT = J(T, 1, 1)
		M = I(T) - 1/T * lT*lT'
		
		// sigmahat squared
		sigmaSquared = sum(E:^2) / (N*(T-1))
		
		// V
		V = J(T^2, T^2, 0)
		vecOne = J(T^2, 1, 0)
		for(i = 1; i <= N; i++) {
			V = V + vec(E[.,i]*E[.,i]' - sum(E[.,i]:^2)/(T-1)*M) * (vec(E[.,i]*E[.,i]' - sum(E[.,i]:^2)/(T-1)*M))'
		}
		middleTerm = invsym(D'*V*D/N)
		V = .
		
		// sum of vec(ee - sigmaM)
		vec1 = J(1, T^2, 0)

		for(i = 1; i <= N; i++) {
			vec1 = vec1 + (vec(E[.,i]*E[.,i]' - sigmaSquared*M))'
		}
		vec1D = vec1 * D
		
		// LM
		IS = vec1D * middleTerm * vec1D' / N
		pvalue = 1 - chi2((T-1)*(T-2)/2, IS)
		
		// Store results
		st_numscalar("IS", IS)
		st_numscalar("pvalue", pvalue)
	}
end

mata: 
	void is_statistic_bb(string scalar varname, string scalar toUse, real scalar T, real scalar N, real scalar p) {
		// Define objects
		real matrix E, insideFactor, Si, Sik; real colvector si, selection, selectionCriterion, selectionCriterion2, selectionCriteria, outsideFactor; real scalar count, dimension, IS, pvalue, i, j, sigmaSquared

		// Load residuals and transform to matrix (each column represents residuals of one panel unit i)
		// ei = (e1,1, e1,2 ... e1,T)'
		// E = (e1, e2, ... eN)
		E = rowshape(st_data(., varname, toUse), N)'
		
		// Calculate the sums (outside "single" sum and inside "square" sum)
		if (p == T) dimension = (T-1)*(T-2)/2
		else dimension = p*T - p*(p+1)/2
				
		outsideFactor = J(dimension, 1, 0)
		insideFactor = J(dimension, dimension, 0)
		
		for(i = 1; i <= N; i++) {
			Si = E[., i]*E[., i]'
			Sik = Si[1..T-1, 1..T-1]
			
			sigmaSquared = sum(E[.,i]:^2) / ((T-1))
						
			if (p == T) si = vech_lower(Sik :- sigmaSquared/-T)
			else si = __offdiag(Si, (1..p), 0) :- sigmaSquared/-T
						
			outsideFactor = outsideFactor + si
			insideFactor = insideFactor + si*si'
		}

		IS = outsideFactor'*invsym(insideFactor)*outsideFactor
		pvalue = 1 - chi2(dimension, IS)
		
		// Store results
		st_numscalar("IS", IS)
		st_numscalar("pvalue", pvalue)
	}
end


mata: 
	void is_statistic_bb_unbalanced(string scalar varname, string scalar toUse, real scalar T, real scalar N, real scalar p) {
		// Define objects
		real matrix E, insideFactor, Si, Sik; real colvector si, outsideFactor, obsPerT, dofVector; real scalar dimension, IS, pvalue, i, sigmaSquared, nonMissings, dof

		// Load residuals and transform to matrix (each column represents residuals of one panel unit i)
		// ei = (e1,1, e1,2 ... e1,T)'
		// E = (e1, e2, ... eN)
		E = rowshape(st_data(., varname, toUse), N)'

		// Calculation
		if (p == T) dimension = (T-1)*(T-2)/2
		else dimension = p*T - p*(p+1)/2
				
		outsideFactor = J(dimension, 1, 0)
		insideFactor = J(dimension, dimension, 0)
		
		for(i = 1; i <= N; i++) {
			Si = E[., i]*E[., i]'
			Sik = Si[1..T-1, 1..T-1]
			
			nonMissings = sum(rownonmissing(E[.,i]))
			sigmaSquared = sum(E[.,i]:^2) / (nonMissings-1)
					
			if (p == T) si = vech_lower(Sik :- sigmaSquared/-nonMissings)
			else si = __offdiag(Si, (1..p), 0) :- sigmaSquared/-nonMissings
			
			_editmissing(si, 0)
			outsideFactor = outsideFactor + si
			insideFactor = insideFactor + si*si'
		}
		
		IS = outsideFactor'*invsym(insideFactor)*outsideFactor
		
		// Degrees of freedom = number of correlations actually calculated
		obsPerT = rownonmissing(E)
		if (p == T) dofVector = __offdiag((obsPerT*obsPerT')[1..T-1, 1..T-1], (1..T-2), 0)
		else dofVector = __offdiag(obsPerT*obsPerT', (1..p), 0)
		dof = rows(select(dofVector, dofVector:!=0))
		
		//pvalue = 1 - chi2(dimension, IS)
		pvalue = 1 - chi2(dof, IS)
		
		// Store results
		st_numscalar("IS", IS)
		st_numscalar("pvalue", pvalue)
	}
end

mata:
	transmorphic colvector __offdiag(transmorphic matrix X, real vector L, U) {
		real scalar N, n_L, n_U, NN, ix, i, j
		real matrix ixx
		transmorphic vector res
		
		N = rows(X)
		if (cols(X) != N) {
			errprintf("symmetric matrix required\n")
			exit(198)
		}
		
		n_L = length(L)
		n_U = length(U)
		
		if (n_L==1 & L==0) n_L = 0
		if (n_U==1 & U==0) n_U = 0
		
		if (any(L:>=N) | any(U:>=N)) {
			errprintf("diagonal # must be < matrix dimension\n")
			exit(198)
		}
		
		NN = N*n_L + N*n_U - sum(L) - sum(U)
		
		res = J(NN,1,0)
		ix = 0

		// upper off-diagonals
		for (i=n_U; i>=1; i--) {
			ixx = (1::N-U[i]),(U[i]+1::N)
			for (j=1; j<=rows(ixx); j++) res[++ix] = X[ixx[j,1],ixx[j,2]]
		}
		
		// lower off-diagonals
		for (i=1; i<=n_L; i++) {
			ixx = (L[i]+1::N),(1::N-L[i])
			for (j=1; j<=rows(ixx); j++) res[++ix] = X[ixx[j,1],ixx[j,2]]
		}
		return(res)
	}
end

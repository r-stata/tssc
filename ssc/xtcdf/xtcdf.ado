* Pesaran (2004/2015) CD-test for cross sectional dependence
*! Version 1.0.0 28jul2017
* Contact jesse.wursten@kuleuven.be for bug reports/inquiries.

* Changelog
** 28jul2017: Submitted to SSC

cap mata mata drop flexCorr()
cap mata mata drop prepData()
cap mata mata drop corrMatrix()
cap mata mata drop reshapeWideMata()
cap mata mata drop calcCD()

cap program drop xtcdf
program define xtcdf, rclass
	version 12
	preserve

	* Loop over variables
	syntax varlist
	tempname cd meanObs meanCorr meanAbsCorr pvalue notEnoughJointObs

	* Display some stuff
	qui xtset
	di as result _newline "xtcd test on variables `varlist'"
	di as text "Panelvar: " r(panelvar)
	di as text "Timevar: " r(timevar)
	di as text "{hline 16}{c TT}{hline 38}{c TT}{hline 22}{c TRC}"
	di as text _col(2) "   Variable"  _col(16) " {c |}" _col(20) "CD-test" _col(30) "p-value" _col(40) "average joint T" " {c |}" _col(58) "mean ρ" _col(67) "mean abs(ρ)" _col(73) " {c |}"
	di as text "{hline 16}{c +}{hline 38}{c +}{hline 22}{c RT}"
	
	* Perform xtcd test
	local j = 1
	foreach var of local varlist {
		** Reshape data `var'
		reshapeWide `var'
		
		** Calculate statistics
		mata: calcCD(theData)
		scalar `cd' = round(cd, 0.001)
		scalar `meanObs' = round(meanObs, 0.01)
		scalar `meanCorr' = round(meanCorr, 0.01)
		scalar `meanAbsCorr' = round(meanAbsCorr, 0.01)
		scalar `pvalue' = round(pvalue, 0.001)
		scalar `notEnoughJointObs' = notEnoughJointObs
		
		** Report statistics
		if `notEnoughJointObs' == 1 local errorMessage = `"" `notEnoughJointObs' " combination of panel units ignored (insufficient joint observations)."'
		else if `notEnoughJointObs' > 1 local errorMessage = `"" `notEnoughJointObs' " combinations of panel units ignored (insufficient joint observations)."'
		else local errorMessage = ""
		
		di _col(2) %~14s = abbrev("`var'",14) _col(16)  " {c +}" _col(20) `cd' _col(30) _skip(1) %4.3f = `pvalue' _col(40) %10.2f = `meanObs' _col(55) " {c +}" _skip(2) %3.2f = `meanCorr' _col(67) _skip(3) %3.2f = `meanAbsCorr' _col(78) " {c RT}" _skip(1) as error "`errorMessage'"
		
		** Prep for return
		mat cds = (nullmat(cds), cd)
		mat ps = (nullmat(ps), pvalue)
		
		** Return as scalar (more useful in some cases)
		return scalar cd`j' = cd
		return scalar pvalue`j' = pvalue
		local j = `j' + 1
	}
	
	* Display more stuff
	di as text "{hline 16}{c BT}{hline 38}{c BT}{hline 22}{c BRC}"
	di _col(2) "Notes: Under the null hypothesis of cross-section independence, CD ~ N(0,1)"
	di _col(9) "P-values close to zero indicate data are correlated across panel groups."
	
	* Return stuff
	return matrix CD = cds
	return matrix p = ps
	
	restore
end


cap program drop reshapeWide
program define reshapeWide, rclass
	* Obtain variables to reshape
	syntax varlist
	tsfill, full
	
	* Obtain time and panel variables
	qui xtset
	local panelvar = r(panelvar)
	local timevar = r(timevar)
	
	* Obtain number of time units
	qui duplicates report `panelvar'
	local timelength = r(unique_value)
	
	* Load data in mata and reshape the mata matrix (tsfill, full is crucial)
	mata: theData = reshapeWideMata("`varlist'", `timelength')
end	


mata:
	void calcCD(real matrix theData) {
		// 1. Define objects
		real scalar T, N, counter, i, j; real matrix subData, demeaned; real colvector corrVector, tVector; real rowvector s
		real scalar CD, corr_nr, meanObs, meanCorr, meanAbsCorr, pvalue
		
		// 2. Count number of groups
		N = cols(theData)
		
		// 3. Calculate correlations per pair
		corrVector = J(N*(N-1)/2, 1, .)
		tVector = J(N*(N-1)/2, 1, .)
		counter = 1
		for(i=1; i<=N; i++) {
			for(j=i+1; j<=N; j++) {
				// 3a. Select subdata
				subData = select(theData[., (i, j)], theData[.,i]+theData[.,j] :!= .)
				
				// 3b. Count number of joint observations
				T = rows(subData)
				if (T < 3) {
					corrVector[counter, 1] = 0
					tVector[counter, 1] = 0
					counter++
					continue
				}
				
				// 3c. Calculate correlation
				demeaned = subData - J(T, 1, 1) * colsum(subData)/T
				s = sqrt( 1/(T-1) * colsum(demeaned:^2) )
				corrVector[counter, 1] = 1/(T-1) * colsum(demeaned[.,1]/s[1,1] :* demeaned[.,2]/s[1,2])
				tVector[counter, 1] = T
				counter++
			}
		}
		
		// 4. Calculate CD statistics
		notEnoughJointObs = sum(tVector:==0)
		corr_nr = N*(N-1)/2 - notEnoughJointObs
		CD = sqrt(1/corr_nr)* (sqrt(tVector)' * corrVector)
		pvalue = (1 - normal(abs(CD))) * 2
		
		meanObs = mean(select(tVector, tVector:!=0))
		meanCorr = mean(corrVector)
		meanAbsCorr = mean(abs(corrVector))
		st_numscalar("cd", CD)
		st_numscalar("meanObs", meanObs)
		st_numscalar("meanCorr", meanCorr)
		st_numscalar("meanAbsCorr", meanAbsCorr)
		st_numscalar("pvalue", pvalue)
		st_numscalar("notEnoughJointObs", notEnoughJointObs)
	}
	
	
	// reshapeWideMata reshapes the mata matrix to a wide format (columns are panel units, rows are time periods)
	real matrix reshapeWideMata(string scalar varname, real scalar timelength) {
		real matrix wideData
		
		wideData = st_data(wideData=., varname)
		wideData = rowshape(wideData, timelength)'
		return(wideData)
	}
end

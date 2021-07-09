* pwcorrf
* Version 1.0.2 15th of July 2016
* Faster/more flexible pwcorr command
*
* Bugs: If there are non-varying variables, this might cause issues.
*
* For feedback please email me at jesse.wursten@kuleuven.be


cap mata mata drop flexCorr()
cap mata mata drop reshapeWideMata()

cap program drop pwcorrf
program define pwcorrf, rclass
	version 11
	syntax varlist, [reshape full showt]
	* Load data (reshape if requested)
	** Reshape if option was specified
	if "`reshape'" != ""  {
		*** Identify initial obs
		tempvar originalObs
		gen byte `originalObs' = 1
		
		*** Assert they entered only one variable name
		if wordcount("`varlist'") > 1 {
			di as error "You entered more than one variable name with the reshape option specified."
			di as error "Either reduce to one variable name or remove the reshape option."
			error 666
		}
		
		*** If so, reshape to wide (one variable per panel unit)
		reshapeWide `varlist'
		
		*** And obtain the panel unit names to make the correlations matrix look nicer
		qui local varnames = "$varnames_pwcorr2"
	}
	
	** Else just continue
	else {
		mata: st_view(theData=., ., "`varlist'")
		qui local varnames = "`varlist'"
	}
	
	* Calculate correlations
	mata: flexCorr(theData)
	
	* Clean up matrices if matrix is small
	local cols_pwcorr2 = colsof(corrMatrix)
	matrix rownames corrMatrix = `varnames'
	matrix colnames corrMatrix = `varnames'
	
	matrix rownames tMatrix = `varnames'
	matrix colnames tMatrix = `varnames'

	* Display correlation matrix (in part if huge)
	** Some basic info
	di "Variable(s): `varlist'"
	if "`reshape'" != "" noisily di "Panel var: $panelvar_pwcorr2"
	
	** Full matrix if small table, or option full was specified
	if "`full'" == "full" | `cols_pwcorr2' < 10 {
		mat list corrMatrix
		if "`showt'" != "" mat list tMatrix
	}
	
	
	** First 6 rows and columns if the matrix is too huge (and full wasn't specified)
	else {
		di _newline "Showing first 6x6 correlations." _newline "Refer to r(C) for the full matrix, or specify the option 'full'."
		mat sample_pwcorr2 = corrMatrix[1..6, 1..6]
		mat list sample_pwcorr2
		
		if "`showt'" == "showt" {
			mat samplet_pwcorr2 = tMatrix[1..6, 1..6]
			mat list samplet_pwcorr2
		}
	}
	
	* Return correlation matrix as r(C)
	return matrix C = corrMatrix
	return matrix T = tMatrix
	
	* Restore (remove tsfilled obs)
	if "`reshape'" != "" qui drop if missing(`originalObs')
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
	qui levelsof `panelvar', local(varnames)
	global varnames_pwcorr2 = "`varnames'"
	global panelvar_pwcorr2 = "`panelvar'"
	
	* Obtain number of time units
	qui duplicates report `panelvar'
	local timelength = r(unique_value)
	
	* Load data in mata and reshape the mata matrix (tsfill, full is crucial)
	mata: theData = reshapeWideMata("`varlist'", `timelength')
end	


mata:
	// flexCorr calculates the correlations and stores them in a vector
	void flexCorr(real matrix theData) {
		// 1. Define objects
		real scalar T, N, counter, i, j; real matrix subData, demeaned; real colvector corrVector, tVector; real rowvector s
		
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
				if (T < 2) {
					corrVector[counter, 1] = .
					tVector[counter, 1] = .
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
		
		// 4. corrMatrix
		corrMatrix = lowertriangle(invvech(corrVector))
		corrMatrix = (J(1, cols(corrMatrix), 0) \ corrMatrix)
		corrMatrix = (corrMatrix, J(rows(corrMatrix), 1, 0))
		_diag(corrMatrix, 1)
		st_matrix("corrMatrix", corrMatrix)
		
		// 5. tMatrix
		tMatrix = lowertriangle(invvech(tVector))
		tMatrix = (J(1, cols(tMatrix), 0) \ tMatrix)
		tMatrix = (tMatrix, J(rows(tMatrix), 1, 0))
		_diag(tMatrix, .)
		st_matrix("tMatrix", tMatrix)
	}
	
	// reshapeWideMata reshapes the mata matrix to a wide format (columns are panel units, rows are time periods)
	real matrix reshapeWideMata(string scalar varname, real scalar timelength) {
		real matrix wideData
		
		wideData = st_data(wideData=., varname)
		wideData = rowshape(wideData, timelength)'
		return(wideData)
	}
end

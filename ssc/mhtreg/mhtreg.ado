/*******************************************************************************
 NOTES:
 
 - the first covariate is the treatment of interest
 - example syntax: mhtexpreg (y1 d1 if sub==1) (y1 d1 if sub==2) (y3 d1 if sub==1) (y3 d1 if sub==2), bootstrap(5000)
 - added error message if moremata package not installed
 - changed specification of cltype option
 - changed the check for missing values
*******************************************************************************/


program mhtreg, rclass sortpreserve
	version 14
    syntax anything, [bootstrap(integer 3000) robust cluster(varname) cltype(integer 0) seed(real -1) replace]
	
	// cltype specifications
	// 1 clustered bootstrap
	// 2 clustered errors in model
	// 3 clustered in both instances
	
	tempvar clus touse_any

	local i=1
	while strlen("`anything'")>0 {
		gettoken eqn`i' anything : anything, parse(" ,[") match(paren)
		if ("`eqn`i''"=="") continue
		gettoken y`i' x`i': eqn`i'
		local x`i' = subinstr("`x`i''"," if ",",",.)
		gettoken x`i' co`i': x`i', parse(",")
		local co`i' = subinstr("`co`i''",",","",.)
		tempvar touse`i'
		gen byte `touse`i''=1
		markout `touse`i'' `y`i'' `x`i'' // missings in variables
		if ("`co`i''"!="") quietly replace `touse`i'' = 0 if !(`co`i'') // if condition
		local y_list = "`y_list' `y`i''"
		local t_list = "`t_list' `touse`i''"
		local n_eq=`i'
		local i = `i'+1
	}
	
	egen `touse_any' = rowmax(`t_list')
	quietly count if `touse_any'==1
	local n = r(N)
	
	// Check whether moremata is installed
	cap which moremata.hlp
	if _rc {
		di as error "mhtreg requires the moremata package. Install by typing ssc install moremata."
		exit
	}

	if (`seed'!=-1) mata: rseed(`seed')

	// In principle, these elements are not necessary anymore with the new syntax. Eliminate them in future version
    mata: excludemat = (.,.,.)
	mata: onlymat = (.,.,.)

	mata: xmat = rbuildPointer(`n_eq')
	mata: ymat = rbuildPointer(`n_eq')
	mata: tomat = rbuildPointer(`n_eq')

	mata: TOA = rbuildTO("`touse_any'", "`touse_any'") // Indicator for all observations that should be considered in the bootstrap

	// If no cluster variable is specified, generate artificial cluster where each obs is its own cluster
	// Note: it's important that the sort command is executed before rbuilding the data matrices
	if ("`cluster'" != "" & `cltype'==0)  local cltype = 3
	if ("`cluster'" != "" & `cltype'!=0)  {
		gen `clus' = `cluster'
	}	
	else {
		gen `clus' = _n
	}
	sort `clus' 
	mata: CLUSTER = rbuildCLUSTER("`clus'","`touse_any'")
	
	forvalues c=1/`n_eq' {
	    mata: Y`c' = rbuildY("`y`c''", "`touse_any'")
		mata: X`c' = rbuildX("`x`c''", "`touse_any'")
		mata: TO`c' = rbuildTO("`touse`c''", "`touse_any'")
		mata: xmat[`c']=&X`c'
		mata: ymat[`c']=&Y`c'
		mata: tomat[`c']=&TO`c'
	}

	mata: sizes = rbuildsizes(`n_eq')


    mata: combo = rbuildcombo(sizes[3])
    mata: numpc = rbuildnumpc(combo)
    mata: select = rbuildselect(onlymat, excludemat, sizes[1], sizes[2], numpc)
	
    mata: results = seidelxusteinmayr(ymat, xmat, tomat, TOA, `n_eq', combo, select, `bootstrap', "`robust'", CLUSTER, `cltype')
    mata: rbuildoutput("results", results)

    matlist results
	
	if "`replace'"=="replace" {
		clear
		svmat results, names(col) 
	}
	return matrix results = results
end

mata:

	 function rbuildPointer(real scalar n_eq) { // returns an matrix of pointers
		pointer(real matrix) rowvector pmat
		pmat = J(1, n_eq, NULL)
		return(pmat)
    }

    function rbuildY(string scalar outcome, string scalar touse) { // returns an X matrix that contains the treatment of interest and a constant
		Y = st_data(., tokens(outcome), touse)
        return(Y)
    }
	
    function rbuildTO(string scalar num, string scalar touse) { // returns an X matrix that contains the treatment of interest and a constant
        TO = st_data(., tokens(num), touse)
        return(TO)
    }

    function rbuildCLUSTER(string scalar cluster, string scalar touse) { // returns a matrix that contains the cluster variable
        CLUSTER = st_data(., tokens(cluster), touse)
        return(CLUSTER)
    }	
	
    function rbuildX(string scalar covars, string scalar touse) { // returns an X matrix that contains the treatment of interest and a constant
        TO = st_data(., tokens(touse), touse)
		if (covars!="") {
			X = st_data(., tokens(covars), touse), J(rows(TO), 1,1)
		}
		else {
			X = J(rows(TO), 1,1)
		}
        return(X)
    }
	
    function rbuildsizes(real scalar n_eq) {
		numg = 1  // nojoint adds all treatments together and runs the test of any treatment versus the control group (0...do joint, 1...no joint)
		numoc = n_eq
        numsub = 1

        return((numoc, numsub, numg))
    }

    function rbuildcombo(real scalar numg){
    	combo = (J(numg,1,0), (1::numg))
        return(combo)
    }
	
    function rbuildnumpc(real matrix combo){
        return(rows(combo))
    }
	
    function rbuildselect(real matrix only, real matrix exclude, real scalar numoc, real scalar numsub, real scalar numpc){
        if (rownonmissing(only) != 0){
            select =rmdarray((numoc, numsub, numpc),0)
            for (r = 1; r <= rows(only); r++){
                i = only[r, 1]
                j = only[r, 2]
                k = only[r, 3]
               rput(1, select, (i,j,k))
            }
        }else{
            select =rmdarray((numoc, numsub, numpc), 1)
        }
        if (rownonmissing(exclude) !=0){
            for (r=1; r <= rows(exclude); r++){
                i = exclude[r, 1]
                j = exclude[r, 2]
                k = exclude[r, 3]
               rput(0, select, (i,j,k))
            }
        }
        return(select)
    }

end

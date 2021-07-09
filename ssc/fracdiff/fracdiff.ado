*! version 1.0.2   24mar2006      C F Baum
* 1.0.0: developed from RATS fracdiff.src, 08sep2000
* 1.0.1: promoted to v8.2, add ts and onepanel
* 1.0.2: correct onepanel logic

program define fracdiff, rclass
	version 8.2

	syntax varlist(ts max=1) [if] [in] , D(real) [GENerate(string)]    

	local generat = cond("`generate'" == "", "fracdiff", "`generate'") 
	capture confirm new variable `generat' 
	if _rc { 
		di in r "`generat' already exists: " _c  
		di in r "specify new variable with generate( ) option"
		exit 110 
	} 

//	qui tsset /* error if not set as time series */ 
			/* get time variables, enable onepanel */
   	marksample touse
*	_ts timevar, sort
    _ts timevar panelvar if `touse', sort onepanel
	markout `touse' `timevar'
	tsreport if `touse', report
	if r(N_gaps) {
		di in red "sample may not contain gaps"
		exit
	}

	tempname stdif enddif endwt j depvar ii kk n count
	tempvar wt
	local depvar `varlist'
//	qui count if `touse'
//	gen long `n' = sum(`touse')
//	qui gen `count' = sum(`touse')
	qui gen `count' = _n if `touse'
    summ `count' if `touse', meanonly
// first 12 obs as starting values 
    local svstart= r(min)
    local svstart1 = `svstart'+1
    local tstart= r(min)+12
    local svend = `tstart'-1
    local tend=r(max)
// di as err "`svstart'  `svend'" 
	qui replace `touse' = 0 in `svstart'/`svend'
	local endwt = `tend' - `tstart' + 1
	qui gen double `wt' = -`d' in `svstart'

	local j 1
// di as err "** `svstart1'  `tend'" 
	forv ii = `svstart1'/`tend' {
		local j = `j'+1
		qui replace `wt' = `wt'[_n-1]*(`j'-1-`d')/`j' in `ii'/`ii'
	}

	qui gen double `generat' = `depvar' if `touse'
// l `generat' if `touse'
// di as err "*** `tstart'  `tend'" 
	forv ii = `tstart'/`tend' {
//		local kk = 1
//		while `kk' <= `ii'-1 {
// calculate number of feasible prior observations
		local maxwt = `ii' - `svstart'	
// di as err "maxwt `maxwt'"
// l `depvar' `generat' if `touse'
		forv kk = 1/`maxwt' {	
			qui replace `generat' = `generat' + ///
			`depvar'[`ii'-`kk']*`wt'[`kk'+`svstart'-1] in `ii'/`ii'
//			local kk = `kk' + 1
		}
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
/*	
// following code works only for first panel
	qui replace `touse' = 0 if `n'<13
	local stdif = 13
	local enddif = r(N)
	local endwt = `enddif'-`stdif'+1
	qui gen `wt' = -`d' in 1/1
	qui replace `wt' =  `wt'[_n-1]*(_n-1-`d')/_n if _n>1 
	qui gen `generat' = `depvar' if `touse'
	local ii = `stdif'
	while `ii' <= `enddif' {
		local kk = 1
		while `kk' <= `ii'-1 {
			qui replace `generat' = `generat' + `depvar'[`ii'-`kk']*`wt'[`kk'] in `ii'/`ii'
			local kk = `kk' + 1
			}
		local ii = `ii' + 1
		}	
*/
	end
	
exit

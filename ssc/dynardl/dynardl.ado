*
*		PROGRAM DYNARDL
*		
*		version 1.0.5
*		4/18/18
*		Soren Jordan and Andrew Q. Philips
*		
*
*		Note: previous versions of this program were titled dynpss
*
* -------------------------------------------------------------------------
* -------------------------------------------------------------------------
* -------------------------------------------------------------------------

capture program drop dynardl
capture program define dynardl , eclass
syntax [varlist] [if] [in], [Lags(string) Diffs(string) LAGDiffs(string) ///
levels(string) forceset(string)  Time(numlist integer > 1) shockval(numlist)  ///
shockvar(varname) range(numlist integer > 1) SAVing(string) 			 ///
sig(numlist integer < 100) ec NOCONstant TRend			 ///
burnin(numlist integer > 1) sims(numlist) graph rarea change expectedval]

version 8
preserve								// we're going to remove existing data

di "-----------------------------------------------"
if "`sig'" != ""	{						// getting the CI's signif
	scalar signif = `sig'
}
else	{
	scalar signif = 95
}
loc sigl = (100-signif)/2
loc sigu = 100-((100-signif)/2)

if "`sims'" != ""	{						// How many sims are desired?
	loc simulations `sims'
}
else	{
	loc simulations 1000
}

if "`shockvar'" == "" | "`shockval'" == ""	{	// check shockval/var
	di in r _n "both shockvar and shockval must be specified"
	exit 198
}

if "`lags'" == ""	{
	di in r _n "lags( ) must be specified"
	exit 198
}

if "`range'" != ""	{						// How far to simulate?
	loc range `range'
}
else	{								
	loc range 20
	di ""
	di in y "No range specified; default to t=20"
}

if "`time'" != ""	{						// When to shock?
	loc time `time'
}
else	{
	loc time 10
	di in y "No time of shock specified; default to t=10"
}

if `time' >= `range' {						// Check
	di in r _n "The range of simulation must be longer than the shock time"
	exit 198
} 

if "`burnin'" != ""	{						// burnins
	loc burnin `burnin' 
	di ""
	di in y "Number of burnins: `burnin'"
}
else	{
	loc burnin 20
}
loc brange = `range' + `burnin'
loc btime = `time' + `burnin'

if "`ec'" != ""	{							// ECM or ARDL
	di ""
	di in y "Option ec specified, dependent variable to be run in differences"
}
else	{
	di in y "Dependent variable to be run in levels"
}

* ----------------- Generate L and D as needed ----------------------------- *
loc ldvs ""						// lagged DVs 
loc lnumdvs ""					// vector of dv lag lengths
loc lddvs ""					// lagged-diff DVs
loc ldnumdvs ""					// vector of ld DV lag lengths
loc dsiv ""						// differenced shockvar
loc lsiv ""						// lagged shockvar
loc lnumsiv ""					// vector of shockvar lag lengths
loc ldsiv ""					// lagged-diff shockvar
loc ldnumsiv ""					// vector of ld shockvar lag lengths
loc siv ""						// levels shockvar
loc ivset ""					// levels of other vars
loc divset ""					// differenced other vars
loc livset ""					// lagged other vars
loc ldivset ""					// lagged-diff other vars 


loc n_vars : word count `varlist' // count of vars
forv i = 1/`n_vars' {
	loc varname_`i' : word `i' of `varlist' // localize var name
}


* for the lags ----------
qui if "`lags'" != "" {
	local lagslist : subinstr local lags "," `"" ""', all // local that stops at each comma
	local lagslist `""`lagslist'""'
	loc n_lags : word count `lagslist'	
	if "`n_lags'" != "`n_vars'" {			// does # lag entries == # variables?
		di in r _n "Lag list has `n_lags' entries, but `n_vars' variables specified in [varlist]."
		di in r _n "Add entry for each variable, separated by a comma (missing is '.')"
		exit 198
	}
	local i 1 
	foreach e of local lagslist {			
		foreach j of local e {
			tokenize `j', parse ("/")
			if "`1'" == "0" {				// no lags dealt w/ using levels()
				di in r _n "Specify lag(0) by using the levels( ) command"
				exit 198
			}
			* situation 1: lo/hi range of lags desired
			if "`3'" != "" {
				forv r = `1'/`3' {
					cap drop L`r'_`varname_`i''
					gen L`r'_`varname_`i'' = l`r'.`varname_`i'' 
					if "`i'" == "1" { 
						loc ldvs "`ldvs' L`r'_`varname_`i''" // add to ldv list
						loc lnumdvs "`lnumdvs' `r'"		 	 // lag lengths to list
					}
					else if "`varname_`i''" == "`shockvar'" { 
						loc lsiv "`lsiv' L`r'_`varname_`i''" // add to lag shockset
						loc lnumsiv "`lnumsiv' `r'"		 	 // lag length to list
					}
					else {
						loc livset "`livset' L`r'_`varname_`i''" // else to other varlist
					}
				}
			}
			* situation 2: no lag desired
			else if "`1'" == "." {
				if "`i'" == "1" {							// LDV must be there
					di in r _n "At least 1 lag of the dependent variable must be specified"
					exit 198
				}
			}
			* situation 3: single lag desired
			else {
				cap drop L`1'_`varname_`i''
				gen L`1'_`varname_`i'' = l`1'.`varname_`i''
				if "`i'" == "1" { 
					loc ldvs "`ldvs' L`1'_`varname_`i''" // add to ldv list
					loc lnumdvs "`lnumdvs' `1'"
				}
				else if "`varname_`i''" == "`shockvar'" { 
					loc lsiv "`lsiv' L`1'_`varname_`i''" // add to lag shockset
					loc lnumsiv "`lnumsiv' `1'"
				}
				else {
					loc livset "`livset' L`1'_`varname_`i''" // else add to other varlist
				}
			}
		}
		local i = `i' + 1
	}
}			// close if diffs != .

* For the differences -----
qui if "`diffs'" != ""	{
	local difflist : subinstr local diffs "," `"" ""', all
	local difflist `""`difflist'""'
	loc n_diffs : word count `difflist'
	if "`n_diffs'" != "`n_vars'" {			// does # diff entries == # variables?
		di in r _n "Diff list has `n_diffs' entries, but `n_vars' variables specified in [varlist]."
		di in r _n "Add entry for each variable, separated by a comma (missing is '.')"
		exit 198
	}
	local i 1 
	foreach e of local difflist {
		foreach j of local e {
			tokenize `j', parse("/")
			if "`1'" != "." {
				if "`1'" == "1" {
					cap drop D_`varname_`i''
					gen D_`varname_`i'' = d.`varname_`i''	// create diff
					if "`varname_`i''" == "`shockvar'"	{	// if var == shockvar
						loc dsiv "`dsiv' D_`varname_`i''"
					}
					else	{							// else add to other varlist
						loc divset "`divset' D_`varname_`i''"
					}
				}
				else {
					di in r _n "Variables can only be first-differenced; specify diff = 1"
					exit 198
				}
			}
		}
		local i = `i' + 1
	}											
}										// close if diffs != .

* For the levels -----
qui if "`levels'" != ""	{					// any vars in levels?
	local levellist : subinstr local levels "," `"" ""', all
	local levellist `""`levellist'""'
	loc n_levels : word count `levellist'
	if "`n_levels'" != "`n_vars'" {			// does # levels entries == # variables?
		di in r _n "Levels list has `n_levels' entries, but `n_vars' variables specified in [varlist]."
		di in r _n "Add entry for each variable, separated by a comma (missing is '.')"
		exit 198
	}
	local i 1
	foreach e of local levellist {
		foreach j of local e {
			tokenize `j', parse("/")
			if "`1'" == "." {	
			}
			else {
				cap drop __`varname_`i''
				if "`varname_`i''" == "`shockvar'"	{	// if shock var in levels
					gen __`varname_`i'' = `varname_`i''
					loc siv "`siv' __`varname_`i''"
				}
				else	{						// else add to other varlist
					gen __`varname_`i'' = `varname_`i''
					loc ivset "`ivset' __`varname_`i''"
				}
			}
		}
		local i = `i' + 1
	}
}	

* For the lagged diffs -----
qui if "`lagdiffs'" != "" {
	local ldlist : subinstr local lagdiffs "," `"" ""', all // create local that stops at each comma
	local ldlist `""`ldlist'""'
	loc n_ldiffs : word count `ldlist'
	if "`n_ldiffs'" != "`n_vars'" {
		di in r _n "Lag-diff list has `n_ldiffs' entries, but `n_var' variables specified in [varlist]"
		di in r _n "Add entry for each variable, separated by a comma (missing is '.')"
		exit 198
	}
	local i 1
	foreach e of local ldlist {
		foreach j of local e {
			tokenize `j', parse ("/")
			if "`1'" == "0" {				
				di in r _n "Specify lagdiff = 0 by using the diffs( ) command"
				exit 198
			}
			* situation 1: lo/hi range of ld's desired
			if "`3'" != "" {
				forv r = `1'/`3' {
					cap drop L`r'D_`varname_`i''
					gen L`r'D_`varname_`i'' = l`r'd.`varname_`i'' 
					if "`i'" == "1" { 
						loc lddvs "`lddvs' L`r'D_`varname_`i''" // to lddv list
						loc ldnumdvs "`ldnumdvs' `r'"
					}
					else if "`varname_`i''" == "`shockvar'" { 
						loc ldsiv "`ldsiv' L`r'D_`varname_`i''" // to ld shockset
						loc ldnumsiv "`ldnumsiv' `r'"
					}
					else {
						loc ldivset "`ldivset' L`r'D_`varname_`i''" // to ld varlist
					}
				}
			}
			* situation 2: no lag desired
			else if "`1'" == "." {
			}
			* situation 3: single lag(s) desired
			else {
				cap drop L`1'D_`varname_`i''
				gen L`1'D_`varname_`i'' = l`1'd.`varname_`i''
				if "`i'" == "1" { 
					loc lddvs "`lddvs' L`1'D_`varname_`i''" // to lddv list
					loc ldnumdvs "`ldnumdvs' `1'"
				}
				else if "`varname_`i''" == "`shockvar'" { 
					loc ldsiv "`ldsiv' L`1'D_`varname_`i''" // add to lag shockset
					loc ldnumsiv "`ldnumsiv' `1'"
				}
				else {
					loc ldivset "`ldivset' L`1'D_`varname_`i''" // to ld varlist
				}
			}	
		}
		local i = `i' + 1
	}
}

qui if "`ec'" != ""	{						// make d.Y if error-correction
	cap drop d`varname_1'
	gen d`varname_1' = d.`varname_1'
}

if "`levels'" != "" & "`ec'" != ""	{	// issue warning
	di in y "Option ec specified with variables appearing in levels; are you sure you want this?"
}

qui if "`trend'" != "" {						// linear time trend desired?
	gen Trend = _n
	loc trend "Trend"
	di in y "Deterministic linear trend specified"
} 
if "`noconstant'" != "" {					// suppress constant?
	loc nocon ", noconstant"
	di in y "Suppress constant specified"
}


* ----------------- Estimate Model ----------------------------- *
* ARDL:
if "`ec'" == ""	{
	regress `varname_1' `ldvs' `lddvs' `dsiv' `lsiv' `ldsiv' `siv' `ivset' `divset' `livset' `ldivset' `trend' `nocon'
}
* ECM:
else	{
	regress d`varname_1' `ldvs' `lddvs' `dsiv' `lsiv' `ldsiv' `siv' `ivset' `divset' `livset' `ldivset' `trend' `nocon'
}

* ----------------- Store Values for pssbounds ----------------- *
* keep existing regress ereturns for things like wald tests if ecm. 
* TYPE:
if "`ec'" != "" {
	if "`trend'" != ""	{
		if "`noconstant'" != "" {
			ereturn scalar type = 0			// no crit values available.
		}
		else {
			ereturn scalar type = 5			// unrestricted intercept and trend
		}
	}
	else {
		if "`noconstant'" != "" {
			ereturn scalar type = 1			// no intercept or trend
		}
		else {
			ereturn scalar type = 3			// unrestricted intercept, no trend
		}
	}
* lag list (needed for k and f-test)
foreach var of varlist `ldvs' {
	if substr("`var'",1,2) == "L1" {	
		local lag1list "`var'"
		ereturn scalar ldv_t = _b[`var']/_se[`var']		// tstat on LDV
	}
}
loc k 
foreach var of varlist `lsiv' `livset' {
	if substr("`var'",1,2) == "L1" {				// is it in coint. eq?
		local lag1list "`lag1list' `var'"
		loc k = `k' + 1								// no. of vars
	}
}
ereturn local laglist `lag1list'	// vector of l.y + l.x1 + l.x2...
ereturn scalar k = `k'		// # of indep vars appearing in lagged levels	
ereturn local cmd dynardl
}

* ----------------- Obtain Means and Things for Below -------------------- *
mat B = e(b)								// betas
mat V = e(V)								// VCV matrix

scalar sigma2 = e(rmse)^2					// sigma squared
scalar dfsig = e(df_r)						// residual d.f.
scalar length = e(rank)						// rank of matrix

* if forceset is not missing, permanently set to forceset value.
if "`forceset'" !=  ""	{
	local forcesetlist : subinstr local forceset "," `"" ""', all
	local forcesetlist `""`forcesetlist'""'
	local n_fslist : word count `forcesetlist'
	if "`n_fslist'" != "`n_vars'" {			// does # levels entries == # variables?
		di in r _n "Forceset list has `n_fslist' entries, but `n_vars' variables specified in [varlist]."
		di in r _n "Add entry for each variable, separated by a comma (missing is '.')"
		exit 198
	}
	local i 1
	foreach e of local forcesetlist {
		foreach j of local e {
			tokenize `j', parse("/")
			loc var : word `i' of `varlist' 	// localize variable name
			if "`i'" == "1" & "`1'" != "." {
				di in r _n "Lagged DV cannot be forceset. Set to '.'"
				exit 198
			}
			if "`1'" != "." {
				scalar _`var'_mean = `1'
			}
			else { 							// if forceset val is ".", just use means.
				su `varname_`i'' if e(sample), meanonly
				scalar _`var'_mean = r(mean)
			}
		}
		local i = `i' + 1
	}
}	
else	{									// if not, will just use means
	qui foreach var in `varlist'	{
		su `var' if e(sample), meanonly
		scalar _`var'_mean = r(mean)		// grab means of levels	
	}
}	


* ----------------- Create Posterior Draws ------------------------------- *
* draw posterior betas (and constant if applicable)
if "`noconstant'" != "" {
	qui drawnorm `ldvs' `lddvs' `dsiv' `lsiv' `ldsiv' `siv' `ivset' `divset' `livset' `ldivset' `trend' , n(`simulations') cov(V) means(B) clear
	* place vars in posterior beta's (PB) matrix:
	mkmat `ldvs' `lddvs' `dsiv' `lsiv' `ldsiv' `siv' `ivset' `divset' `livset' `ldivset' `trend' , matrix(PB)
}
else {
	qui drawnorm `ldvs' `lddvs' `dsiv' `lsiv' `ldsiv' `siv' `ivset' `divset' `livset' `ldivset' `trend' const , n(`simulations') cov(V) means(B) clear
	* place vars in posterior beta's (PB) matrix:
	mkmat `ldvs' `lddvs' `dsiv' `lsiv' `ldsiv' `siv' `ivset' `divset' `livset' `ldivset' `trend' const, matrix(PB)
}
* draw sigma-squared from inv chi-2 to constrain to [0-1]:
tempvar Sigma2
qui gen `Sigma2' = sigma2*(dfsig)/invchi2(dfsig,uniform()) 

* ----------------- Values at t = 1 ------------------------------- *
mat set = J(length,1,.)			// container to hold set values  
* parsing routine through regression varlist (and set), 
* splitting out the name and leaving the d, l1, etc., and replaces set
* with their sample mean if L, and 0 if L*D or D.
loc i 1
* lagged DV's always set to sample means, unless constant suppressed:
foreach var in `ldvs' {
	gettoken dynamics name: var, parse("_")
	if "`noconstant'" != "" {
		mat set[`i',1] = 0
	}
	else {
		mat set[`i',1] = `name'_mean
	}
	loc i = `i' + 1 
}
* lagged diff DV's set to 0
foreach var in `lddvs'	{
	mat set[`i',1] = 0
	loc i = `i' + 1 
}
* differenced shocked IV set to 0
foreach var in `dsiv'	{
	mat set[`i',1] = 0
	loc i = `i' + 1 
}
* lagged shocked IV set to sample means
foreach var in `lsiv'	{
	gettoken dynamics name: var, parse("_")
	mat set[`i',1] = `name'_mean
	loc i = `i' + 1 
}
* lagged diff shocked IV set to 0
foreach var in `ldsiv'	{
	mat set[`i',1] = 0
	loc i = `i' + 1 
}
* shocked IV in levels set to means, as are other varlist in levels:
foreach var in `siv' `ivset' {
	gettoken dynamics name: var, parse("_")
	mat set[`i',1] = `name'_mean
	loc i = `i' + 1 
}
* differenced other varlist set to 0
foreach var in `divset'	{
	mat set[`i',1] = 0
	loc i = `i' + 1 
}
* lagged other varlist set to means
foreach var in `livset'	{
	gettoken dynamics name: var, parse("_")
	mat set[`i',1] = `name'_mean
	loc i = `i' + 1 
}
* lagged diff of other varlist set to 0
foreach var in `ldivset' {
	mat set[`i',1] = 0
	loc i = `i' + 1 
}

* trend (if present) set to -burnin s.t. trend = t=0 at t=0
foreach var in `trend' {
	mat set[`i',1] = -`burnin'
	loc i = `i' + 1
}

* constant
if "`noconstant'" != "" {
}
else {
	mat set[`i',1] = 1
}

* Create predicted values ----------------- 
* multiply [s x k] posterior beta matrix by [k x 1] set matrix
tempname PV
mat `PV' = PB*set	
svmat `PV'
* add error into XB: expected values or predicted values:
qui if "`expectedval'" != ""	{
	tempvar tid
	gen `tid' = _n
	expand 1000
	replace `PV' = `PV' + rnormal(0,sqrt(`Sigma2'))
	collapse (mean) `PV' `Sigma2', by(`tid')
}
else	{
	qui replace `PV' = `PV' + rnormal(0,sqrt(`Sigma2')) 
}

* predicted values are obtained: 
if "`graph'" == ""		{
	_pctile `PV', p(`sigl', `sigu')			// grab ll and ul
	scalar ll_1 = r(r1)						// grab values
	scalar ul_1 = r(r2)
}
else	{									// need all these for graph
	_pctile `PV', p(2.5, 5, 12.5, 87.5, 95, 97.5) 
	scalar ll95_1 = r(r1)
	scalar ll90_1 = r(r2)
	scalar ll75_1 = r(r3)
	scalar ul75_1 = r(r4)
	scalar ul90_1 = r(r5)
	scalar ul95_1 = r(r6)
}

* need means of predicted values:
su `PV', meanonly
* if ECM, add PV to sample mean (from set matrix):
if "`ec'" != ""	{
	scalar meanpv_1 = r(mean) + set[1,1]
}
* if LDV, PV is new value
else	{
	scalar meanpv_1 = r(mean)
}

* ----------------- Values at t = 2/brange ------------------------------- *
* loop through all time periods:
di ""
noi di in g "Please wait:"
nois _dots 0, title(dynardl is currently creating `simulations' simulations across `range' time points) reps(`range')
qui forv p = 2/`brange'	{	
	noi _dots `p' 0 
	
	* Set l.DV's to predicted value:
	local w = `p' - 1			// new LDV value is previous LDV value
	loc row = 1					// start at the top of set matrix
	
	foreach lag in `lnumdvs' {
		loc w = `p' - `lag'
		if `w' > 0 {
			mat set[`row',1] = meanpv_`w'
		}
		else {
		}
		loc row = `row' + 1 	// move down set list	
	}
	
	* Set ld.DVs to predicted changes lagged (t - (t-1), t-1 - (t-2)...)
	foreach lagd in `ldnumdvs' {
		loc w = `p' - `lagd' // subtract current time by ld.Y
		if `w' > 1 {
			loc wl = `w' - 1
			mat set[`row',1] = meanpv_`w' - meanpv_`wl' // ld set matrix replaced with value of the difference at w'th lag
		}
		else {
		}
		loc row = `row' + 1
	}
	
	* if t = shocktime	-----------------------------
	if `p' == `btime'	{
		* shock differenced var:
		foreach var in `dsiv'	{
			mat set[`row',1] = `shockval'
			local row = `row' + 1
		}
		foreach var in `lsiv' `ldsiv' {	// get past these...nothing happens
			local row = `row' + 1
		}
		* shock vars in levels:
		foreach var in `siv'	{
			gettoken dynamics name: var, parse("_")
			mat set[`row',1] = `name'_mean + `shockval'
		}
	}
	
	* else if t > shocktime ------------------------------
	else if `p' > `btime'	{
		* differenced var back to 0:
		foreach var in `dsiv'	{
			mat set[`row',1] = 0
			local row = `row' + 1
		}
		
		* lagged var shock:
		foreach lag in `lnumsiv' {
			loc w = `p' - `btime'
			if `w' >= `lag' {
				mat set[`row',1] = _`shockvar'_mean + `shockval'
			}
			else {						// lag remains unchanged
			}
			loc row = `row' + 1
		}
		
		* lagged diff var shock
		foreach lagd in `ldnumsiv' {
			loc w = `p' - `btime' 
			if `w' == `lagd' {
				mat set[`row',1] = `shockval'
			}
			else {
				mat set[`row',1] = 0
			}
			loc row = `row' + 1
		}
		
		/* shock in levels:
		* shockvar already shocked. Don't need to do anything.
		*/
	}
	else	{					// if t < shocktime...nothing happens	
	}
	
	* set trend to t+1, if it exists
	if "`trend'" != "" {
		foreach var in `trend' {
			* if no constant, trend = rowsof(set)
			if "`noconstant'" != "" {
				scalar f = rowsof(set)
			}
			else {	// if not it's 1 less than row total
				scalar f = rowsof(set) - 1
			}
			mat set[f,1] = `p' - `burnin'  // trend = sim time - burnin time
		}
	}

	* create Y = XB + E -----------------------------
	mat `PV' = PB*set
	capture drop `PV'	
	svmat `PV'
	* add error into XB: expected values or predicted values:
	qui if "`expectedval'" != ""	{
		tempvar tid
		gen `tid' = _n
		expand 1000
		replace `PV' = `PV' + rnormal(0,sqrt(`Sigma2'))
		collapse (mean) `PV' `Sigma2', by(`tid')
	}
	else	{
		replace `PV' = `PV' + rnormal(0,sqrt(`Sigma2')) 
	}
	
	* values are obtained: 
	if "`graph'" == ""		{
		_pctile `PV', p(`sigl', `sigu')				// grab ll and ul 
		if "`ec'" != ""	{	// if ECM, add pc'tiles to old predicted values.
			scalar ll_`p' = r(r1) + set[1,1]
			scalar ul_`p' = r(r2) + set[1,1]
		}
		else	{
			scalar ll_`p' = r(r1)					// grab values
			scalar ul_`p' = r(r2)
		}
	}
	else	{										// need all these for graph
		_pctile `PV', p(2.5, 5, 12.5, 87.5, 95, 97.5) 
		if "`ec'" != ""	{ 	// if ECM, add pc'tiles to old predicted values.
			scalar ll95_`p' = r(r1) + set[1,1]
			scalar ll90_`p' = r(r2) + set[1,1]
			scalar ll75_`p' = r(r3) + set[1,1]
			scalar ul75_`p' = r(r4) + set[1,1]
			scalar ul90_`p' = r(r5) + set[1,1]
			scalar ul95_`p' = r(r6) + set[1,1]
		}
		else	{
			scalar ll95_`p' = r(r1)
			scalar ll90_`p' = r(r2)
			scalar ll75_`p' = r(r3)
			scalar ul75_`p' = r(r4)
			scalar ul90_`p' = r(r5)
			scalar ul95_`p' = r(r6)
		}
	}
	
	* need means of predicted values:
	su `PV', meanonly
	* if ECM, PV added to sample mean 
	* (which was saved in set matrix):
	if "`ec'" != ""	{
		scalar meanpv_`p' = r(mean) + set[1,1]
	}
	* if LDV, PV is new predicted value
	else	{
		scalar meanpv_`p' = r(mean)
	}

}				// close time loop

* ----------------- Store Values for Saving or Graphing ----------------- *
loc z = `range' + 1 		// need 1 more row than range.
if "`graph'" == ""	{
	mat sims = J(`z',3,.) 	// empty container of "."'s to hold sims
	loc p = 1
	forv i = `burnin'/`brange'	{
		mat sims[`p',1] = meanpv_`i'
		mat sims[`p',2] = ll_`i'
		mat sims[`p',3] = ul_`i'
		loc p = `p' + 1	
	}
	mat colnames sims = mean ll_ ul_
}
else	{
	mat sims = J(`z',7,.) // empty container of "."'s to hold sims
	loc p = 1
	forv i = `burnin'/`brange'	{
		mat sims[`p',1] = meanpv_`i'
		mat sims[`p',2] = ll95_`i'
		mat sims[`p',3] = ll90_`i'
		mat sims[`p',4] = ll75_`i'
		mat sims[`p',5] = ul75_`i'
		mat sims[`p',6] = ul90_`i'
		mat sims[`p',7] = ul95_`i'
		loc p = `p' + 1
	}
	mat colnames sims = mean ll_95 ll_90 ll_75 ul_75 ul_90 ul_95
}

svmat sims, names(col)
qui keep mean ll_* ul_*
qui drop in 1							// 1st one is technically t = 0
qui keep if mean != .
qui gen time = _n

if "`saving'" != "" {
	noi save `saving'.dta, replace
}
else	{
	noi save dynardl_results.dta, replace
}

qui if "`graph'" != ""	{
	if "`change'" != ""{						// is graph in changes?
		if "`expectedval'" != ""	{
			loc titletype = "Change in Expected Value"
		}
		else	{
			loc titletype = "Change in Predicted Value"
		}
		su mean if time == 1, meanonly
		local pmean = r(mean)
		foreach var of varlist mean ll_95 ll_90 ll_75 ul_75 ul_90 ul_95 {
			gen ch`var' = `var' - `pmean'
		}
		loc st = `time' - 1
		drop in 1/`st'
		replace time = _n
		if "`rarea'" != "" {					// area plot
			twoway rarea chll_95 chul_95 time, color(eltblue) ||		///
			rarea chll_90 chul_90 time, color(ebblue) || 				///
			rarea chll_75 chul_75 time, color(navy) || line chmean time,	///
			lcolor(black) lwidth(thick) legend(off)						///
			yline(0, lwidth(medium) lcolor(black) lpattern(solid))		///
			ytitle("`titletype'") xtitle("Time")
		}
		else {									// line plot
			twoway rspike chll_95 chul_95 time, lcolor(eltblue) lwidth(thin) ///
			|| rspike chll_90 chul_90 time, lcolor(ebblue) lwidth(medthick)  ///
			|| rspike chll_75 chul_75 time, lcolor(navy) lwidth(thick) 		 ///
			||  scatter chmean time, mcolor(dknavy) msymbol(o)			 ///
			yline(0, lwidth(medium) lcolor(black) lpattern(solid))		///
			msize(large) legend(off) ytitle("`titletype'") xtitle("Time")
		}
	}
	else {										// graph in levels
		if "`expectedval'" != ""	{
			loc titletype = "Expected Value"
		}
		else	{
			loc titletype = "Predicted Value"
		}
		if "`rarea'" != ""	{					// area plot
			twoway rarea ll_95 ul_95 time, color(eltblue) ||		///
			rarea ll_90 ul_90 time, color(ebblue) || 				///
			rarea ll_75 ul_75 time, color(navy) || line mean time,	///
			lcolor(black) lwidth(thick) legend(off)					///
			ytitle("`titletype'") xtitle("Time")
		}
		else {									// line plot
			twoway rspike ll_95 ul_95 time, lcolor(eltblue) lwidth(thin) ///
			|| rspike ll_90 ul_90 time, lcolor(ebblue) lwidth(medthick)  ///
			|| rspike ll_75 ul_75 time, lcolor(navy) lwidth(thick) 		 ///
			||  scatter mean time, mcolor(dknavy) msymbol(o)			 ///
			msize(large) legend(off) ytitle("`titletype'") xtitle("Time")
		}
	}
}											// close graph

restore										// restore user data
end

* -------------------------------------------------------------------------

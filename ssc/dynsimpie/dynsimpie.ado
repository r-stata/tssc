*
*		PROGRAM DYNSIMPIE
*		
*		version 1.1
*		September 01, 2015
*		Andrew Q. Philips,
*		Texas A&M University
*		aphilips@pols.tamu.edu
*		people.tamu.edu/~aphilips/
*			   &
*		Amanda Rutherford,
*		Guy D. Whitten
/* -------------------------------------------------------------------------
* -------------------------------------------------------------------------
* -------------------------------------------------------------------------
	If you use dynsimpie, please cite us:

    Philips, Andrew Q., Amanda Rutherford, and Guy D. Whitten. 2015 
	"Dynsimpie: A program to dynamically examine compositional dependent
	variables"
	
	and:

    Philips, Andrew Q., Amanda Rutherford, and Guy D. Whitten. 2015.
	"Dynamic pie: A strategy for modeling trade-offs in compositional
	variables over time." American Journal of Political Science.

*/
* -------------------------------------------------------------------------

capture program drop dynsimpie
capture program define dynsimpie , rclass
syntax [varlist] [if] [in], [ dvs(varlist max = 7) shockvar(varname) 	  ///
Time(numlist integer > 1) SHock(numlist)] 								  ///
[shockvar2(varname) shock2(numlist)] [shockvar3(varname) shock3(numlist)] ///
[dummy(varlist)] [dummyset(numlist)] [sig(numlist integer < 100)]		  ///
[range(numlist integer > 1)] [saving(string)]
	 	 
version 8
marksample touse
preserve

if "`sig'" != ""	{						// getting the CI's signif
	loc signif `sig'
}
else	{
	loc signif 95
}
loc sigl = (100-`signif')/2
loc sigu = 100-((100-`signif')/2)

if "`range'" != ""	{						// How far to simulate?
	loc range `range'
}
else	{
	loc range 20
	di ""
	di in y "No range specified; default to t=20"
}
if "`time'" != ""	{
	loc time `time'
}
else	{
	loc time 10
	di in y "No time of shock specified; default to t=10"
}
loc burnin 50								// burn-ins
loc brange = `range' + `burnin'
loc btime = `time' + `burnin'

if `time' >= `range' {
	di in r _n "The range of simulation must be longer than the shock time"
	exit 198
}
if "`dvs'" == ""	{
	di in r _n "Must specify dependent compositional variables in dvs( )"
	exit 198
}
if "`shockvar'" == ""	{
	di in r _n "A shockvar, not included in [varlist], must be specified"
	exit 198
}
if "`shock'" == ""	{
	di in r _n "A real number shock, must be specified"
	exit 198
}
* ------------------------Generating Variables & Run Model ---------------------
loc lvars 
loc dvars
qui foreach var of varlist `varlist'  {		// get d. and l. indep vars
	tempvar L`var' D`var'
	gen `L`var'' = l.`var'
	gen `D`var'' = d.`var' 
	loc lvars `"`lvars' `L`var''"'
	loc dvars `"`dvars' `D`var''"'
}		

tempvar lagshockvar diffshockvar			// same for the shock variable
qui gen `lagshockvar' = l.`shockvar'
qui gen `diffshockvar' = d.`shockvar'
loc lagshockvariables `"`lagshockvar'"'
loc diffshockvariables `"`diffshockvar'"'
forv i = 2/3	{							// and the additional shocks
	if "`shockvar`i''" != "" {
		tempvar lagshockvar`i' diffshockvar`i'
		qui gen `lagshockvar`i'' = l.`shockvar`i''
		qui gen `diffshockvar`i'' = d.`shockvar`i''
		loc lagshockvariables `"`lagshockvariables' `lagshockvar`i''"'
		loc diffshockvariables `"`diffshockvariables' `diffshockvar`i''"'
	}
}

loc model
loc i 1
qui foreach var of varlist `dvs' {
	tempvar ldepvar`i' ddepvar`i' mdepvar`i'
	gen `ldepvar`i'' = l.`var'				// gen lag DV
	gen `ddepvar`i'' = d.`var'				// gen diff DV
	gen `mdepvar`i'' = `var'				// grab means
	* Get the model
	loc model `"`model' (`ddepvar`i'' `ldepvar`i'' `dvars' `lvars' `diffshockvariables' `lagshockvariables' `dummy')"'
	loc i = `i' + 1
}
loc maxdv = `i'-1							// need the max # of compositions
qui sureg `model'							// run the model and keep sample
qui keep if e(sample)
qui estsimp sureg `model'					// run Clarify
* ------------------------ Scalars and Setx ---------------------
qui setx mean								// set everything to means to start

qui su `lagshockvar', meanonly				// scalars for lagged shock
loc sv = r(mean)
loc vs = `sv' + `shock'
qui forv i = 2/3	{						// and the additional shocks
	if "`shockvar`i''" != "" {
		su `lagshockvar`i'', meanonly
		loc sv`i' = r(mean)
		loc vs`i' = `sv`i'' + `shock`i''
		setx `lagshockvar`i'' mean
		setx `diffshockvar`i'' 0
	}
}

qui setx `diffshockvar' 0					// set differenced shock to 0
qui setx `lagshockvar' mean					// set lag shock to mean

forv i = 1/`maxdv' { 						// set lagged DVs to their means
	 su `mdepvar`i'', meanonly
	 scalar m`i' = r(mean)
	 setx `ldepvar`i'' m`i'
}

qui setx (`dvars') 0						// set diff indep vars to 0
qui setx (`lvars') mean

loc i 1
if "`dummy'" != "" {						// set our dummies, if they exist
	if "`dummyset'" != "" {
		qui foreach var in `dummy' {
			loc m 1
			foreach k of numlist `dummyset' {
				if `m' == `i' {
					setx `var' `k'
				}
				loc m = `m' + 1
			}
			loc i = `i' + 1
		}
	}
	else {
		qui setx(`dummy') 0
	}
}
* ------------------------ Predict Values, t = 1 ----------------------------------
loc preddv
qui forv i = 1/`maxdv' {
	tempvar td`i'log1
	loc preddv `"`preddv' `td`i'log1' "'
}
qui simqi, ev genev(`preddv')				// grab our expected values

loc denominator1
loc i 1
qui foreach var in `dvs' {
	su `mdepvar`i''
	scalar z = r(mean)
	tempvar t`i'log1
	gen `t`i'log1' = z + `td`i'log1'
	su `t`i'log1', meanonly
	scalar m`i' = r(mean)				// these scalars become the new LDV
	loc denominator1 `"`denominator1' + (exp(`t`i'log1'))"' // for below
	loc i = `i' + 1
}
* ------------------------Loop Through Time-------------------------------------
di ""
nois _dots 0, title(Please Wait...Simulation in Progress) reps(`range')
qui forv i = 2/`brange' {
	noi _dots `i' 0
	
	forv x = 1/`maxdv' {
		setx `ldepvar`x'' (m`x')		// set the new value of LDV
	}	
	
	qui setx `lagshockvar' mean	
	qui setx `diffshockvar' 0
		
	if `i' == `btime' {					// we experience the shock at t
		setx `diffshockvar' (`shock')	// shock affects at time t only
		forv l = 2/3	{				// and additional shocks if != ""
			if "`shockvar`l''" != "" {
				setx `diffshockvar`l'' (`shock`l'')
			}
		}
	}
	else if `i' > `btime' {
		setx `diffshockvar' 0			// diff shock back to 0
		setx `lagshockvar' (`vs')		// lag shock now at (mean + shock)
		forv  l = 2/3	{
			if "`shockvar`l''" != ""	{
				setx `diffshockvar`l'' 0
				setx `lagshockvar`l'' (`vs`l'')
			}
		}
	}
	else {
		setx `diffshockvar' 0			// just to be sure
		forv  l = 2/3	{
			if "`shockvar`l''" != ""	{
				setx `diffshockvar`l'' 0
			}
		}
	}
	
	qui setx (`dvars') 0				// just to be sure
	qui setx (`lvars') mean
	
	loc preddv
	qui forv x = 1/`maxdv' {
		tempvar td`x'log`i'
		loc preddv `"`preddv' `td`x'log`i'' "'
	}
	simqi, ev genev(`preddv')			// get new predictions
	loc denominator`i'
	qui forv x = 1/`maxdv' {
		tempvar t`x'log`i'
		gen `t`x'log`i'' = m`x' + `td`x'log`i''	// add them to old predictions
		su `t`x'log`i'', meanonly
		scalar m`x' = r(mean)
		loc denominator`i' `"`denominator`i'' + (exp(`t`x'log`i''))"' // need this for below
	}
}
* ------------------------Un-Transform------------------------------------------
loc keepthese
loc z = `maxdv' + 1
qui forv i = 1/`brange' {
	qui forv m = 1/`maxdv' {
		tempvar var`m'_pie`i'
		gen `var`m'_pie`i'' = (exp(`t`m'log`i''))/(1  `denominator`i'')
		_pctile `var`m'_pie`i'', p(`sigl',`sigu')		// grab CIs for each DV
		gen var`m'_pie_ll_`i' = r(r1)
		gen var`m'_pie_ul_`i' = r(r2)
		loc keepthese `"`keepthese' var`m'_pie_ll_`i' var`m'_pie_ul_`i' "'
	}				  
	tempvar var`z'_pie`i' 					// the un-transformation baseline
	gen `var`z'_pie`i'' = 1/(1  `denominator`i'')	
	_pctile `var`z'_pie`i'', p(`sigl',`sigu')
	gen var`z'_pie_ll_`i' = r(r1)
	gen var`z'_pie_ul_`i' = r(r2)
	loc keepthese `"`keepthese' var`z'_pie_ll_`i' var`z'_pie_ul_`i' "'
}

keep `keepthese'
qui keep in 1
tempvar count 
qui gen `count' = _n

loc reshapevar
loc maxvars = `maxdv' + 1					// get max number of DVs
qui forv i = 1/`maxvars' {
	loc reshapevar `"`reshapevar' var`i'_pie_ll_ var`i'_pie_ul_ "'
}

qui reshape long `reshapevar', j(time) i(`count')
qui drop `count' time
qui drop in 1/`burnin'
qui gen time = _n

qui forv i = 1/`maxvars' {
	gen mid`i' = (var`i'_pie_ll_ + var`i'_pie_ul_)/2
}
order time
di ""
if "`saving'" != "" {
	noi save `saving'.dta, replace
}
else	{
	noi save dynsimpie_results.dta, replace
}

end 										// end
* -----------------------------------------------------------------------------

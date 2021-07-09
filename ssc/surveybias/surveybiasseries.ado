/* suverybiasseries.ado --- 
 * 
 * Filename: suverybiasseries.ado
 * Description: 
*! Author: Kai Arzheimer & Jocelyn Evans
*! 1.4 Aug 07 2015

 * Maintainer: 
 * Compatibility: 
 * 
 */

/* Commentary: 
 * 
 * 
 * 
 */

/* Change log:
 * 
 * 
 */

/* Code: */
 
*! wrapper for surveybias.ado - facilitates
*! estimation of survey bias for a series of polls

program define surveybiasseries
      capture noisily _surveybiasseries `0'
                local rc = _rc
                capture mata: mata drop _surveybiasseries*
                exit `rc'
end

program define _surveybiasseries
version 11
	syntax [if] [in] , [POPVARiables(varlist min=2 max=12)] SAMPLEvariables(varlist min=2 max=12) Nvar(varlist min=1 max=1) GENerate(name min=1 max=1) [MISSasnull] [POPVALues(numlist min=2 max=12 )] [prop] [NUMerical] [DESCriptivenames]

*******************************************
* Deal with sample selection
*******************************************

	marksample touse

*******************************************
* Deal with direct input of pop values
*******************************************

* One of POPVAR oder POPVAL must be present, but
* not both
	
	local popvarlength : length local popvariables
	local popvallength : length local popvalues


	
	if `popvarlength' == 0 & `popvallength' == 0 {
		display as error "You must specify either POPVARiables or POPVALues" _newline
		error 102
		}
	
	if `popvarlength' != 0 & `popvallength' != 0 {
		display as error "Specify one of POPVARiables or POPVALues, but not both" _newline
		error 103
		}


	if `popvallength' ! = 0 {

* OK. Check if POPVALues has been set. If yes, transform
* to temporary POPVARiables
		local popvalnumber : list sizeof popvalues
* Loop over values
		forvalues v = 1/`popvalnumber' {
* Find vth value
			local value : word `v' of `popvalues'
* Value must be strictly positive
			if `value' <= 0 {
				display as error "All population proportions must be strictly positive."
				display as error "If the proportion of some category is very small," _newline
				display as error "the category should be merged with others."
				error 125
				}
* Find new name for temp variable
			tempvar newtemp
* Initialise variable with vth popvalue, append varname to popvalues
			gen `newtemp' = `value'
			local popvariables = "`popvariables' `newtemp'"
			}
		}


	
*******************************************	
* Sanity checks	
*******************************************

* No of SAMPLEvariables must equal number of POPvariables
	local numberofpopvars : list sizeof popvariables
	local numberofsamplevars : list sizeof samplevariables
	
* Case 1: too few samplevariables
	if `numberofsamplevars' < `numberofpopvars' {
		display as error "Number of sample variables is smaller than number of population variables" _newline
		error 102
		}
* Case 2: too few population variables
		if `numberofsamplevars' > `numberofpopvars' {
		display as error "Number of population variables is smaller than number of sample variables" _newline
		error 102
		}

* All variables must be numeric

	confirm numeric variable `popvariables' `samplevariables' `nvar'
	
* Number of cases must not be missing
	capture assert `nvar' != .
	if _rc != 0 {
		qui inspect `nvar'
		local numberofnmissing = _N - r(N)
		display as error "Number of cases must not be missing,"
		display as error "but `nvar' is missing for `numberofnmissing' case(s)" _newline
		error 416
		}

* Sample and population variables should have no missing values
* Though they could optionally be recoded to null
* Option set? Use length of option macro for boolean test
	local misstozero : length local missasnull

* Stub must not be longer than 22 character

	local stublength : length local generate
	if `stublength' > 22  {
		display as error "Stub must not be longer than 22 characters" _newline
		error 498
		}

* Option DESCriptivenames set? If yes, perform sanity checks on length of variables
	local makebettervarnames : length local descriptivenames
	if `makebettervarnames' {
* loop over sample variable names
		foreach sampvarname in `samplevariables' {
			local sampvarlength : length local sampvarname
			if `sampvarlength' + `stublength' + 8 > 32 {
				display as error "Combination of stub and sample variable names too long to form"
				display as error "descriptive names for primes. Try with shorter names or without"
				display as error "the DESCriptivenames option"
				error 498
				}
			}
		}
	
	local allvars  "`popvariables' `samplevariables'"
* Through error after loop so that all problems can be listed first	
	local allvarprobs = 0
	foreach var of varlist `allvars'  {
		capture assert `var' !=.
		if _rc !=0 {
			qui inspect `var'
			local numberofnmissing = _N - r(N)
			if `misstozero'  {
				replace `var' = 0 if `var' == .
				display as text "Warning: missing values of `var' recoded to zero"
				}
			else {
				display as error "Sample/population variables should be complete,"
				display as error "but `var' is missing for `numberofnmissing' case(s)" _newline
				}
			local allvarprobs = `allvarprobs' + 1
			}
		}
	if `allvarprobs' > 0 {
		if `misstozero'  {
			display as error "Warning `allvarprobs' variable(s) with missing values recoded to zero'" _newline
			}
		else {
			display as error "Number of sample/population variables with missing values: `allvarprobs'"
			display "You may set the MISSasnull option to irreversibly recode missing values to zero" _newline
			error 416
			}
		}

* All sample and population variables must be strictly positve
	local nonspositiveprobs = 0
	foreach var of varlist `allvars'  {
		capture assert `var' > 0 if `touse'
		if _rc !=0 {
			local nonspositiveprobs = `nonspositiveprobs' + 1
			di as error "Sample/population variables must be strictly positve, "
			di as error "but variable `var' has values <=0."
			}
		}
	if `nonspositiveprobs' > 0 {
		display as error _newline "If a category is not at all observed in the sample, "
		display as error "try entering it as a small positive fraction (e.g. 10^-6)"
		display as error "or merge it with others." _newline
		display as error "`nonspositiveprobs' sample/population variable(s) whose"
		display as error "values are not strictly positive" _newline
		error 411
		}
	
	

*******************************************
* Sanity checks end here
*******************************************

*******************************************
* Prepare initialisation of new vars	
*******************************************

* Check if new vars can be created
* First, build list of new variables	
* One aprime variable for each category
	forvalues c = 1/`numberofpopvars' {
		if `makebettervarnames' {
			local part : word `c' of `samplevariables'
			local aprimetargetlist `aprimetargetlist' `generate'aprime`part'
			}
		else {
			local aprimetargetlist `aprimetargetlist' `generate'aprime`c'
			}
		}
* Plus one variable for each aprime's SE 
	forvalues c = 1/`numberofpopvars' {
		if `makebettervarnames' {
			local part : word `c' of `samplevariables'
			local seaprimetargetlist `seaprimetargetlist' `generate'seaprime`part'
			}
		else {
			local seaprimetargetlist `seaprimetargetlist' `generate'seaprime`c'
			}
		}	
* B and B_w
	local btargetlist  `generate'b `generate'bw

* Standard erros for B and B_w
	local sebtargetlist `generate'seb `generate'sebw
	
* Chisquares + Pr values
	local chitargetlist  `generate'chi2pr `generate'chi2lr `generate'prp `generate'lrp

* Join targetlists
	local targetlist `aprimetargetlist' `seaprimetargetlist' `btargetlist' `sebtargetlist' `chitargetlist'

* Now, initialise if none of them exists
* newlist will cause loop to fail if variables
* and clean up before exiting
	
	foreach v of newlist `targetlist'  {
		qui gen `v' = .
		}

*******************************************
* Main loop calling Mata helper function 
*******************************************

* Init Matrices and create Mata views on data set

* Population	
	mata: _surveybiasseriesP = .
	mata: st_view(_surveybiasseriesP,.,"`popvariables'")

* Sample	
	mata: _surveybiasseriesS = .
	mata: st_view(_surveybiasseriesS,.,"`samplevariables'")

* Coefficients
	mata: _surveybiasseriesB = .
	mata: st_view(_surveybiasseriesB,.,"`aprimetargetlist' `btargetlist'")
* Standard Errors
	mata: _surveybiasseriesSE = .
	mata: st_view(_surveybiasseriesSE,.,"`seaprimetargetlist' `sebtargetlist'")
* N
	mata: _surveybiasseriesN = .
	mata: st_view(_surveybiasseriesN,.,"`nvar'")
	
* Chisquares and Ps
	mata: _surveybiasseriesChi = .
	mata: st_view(_surveybiasseriesChi,.,"`chitargetlist'")

* Total number of observations in dataset
	qui describe, short
	local totalno = r(N)
	
* Number of included observations
	qui count if `touse' == 1
	local noofobs = r(N)
	if `noofobs' > 10 {
		di "Analysing more than 10 surveys. This could take a while"
		}

* Keep track of surveys
	local thiscase = 0
	
	forvalues case = 1/ `totalno' {

* Honor if/in qualifiers		
		if `touse'[`case'] == 1 {
			di "Analysing survey `++thiscase' of `noofobs'"
			di "(observation `case' of `totalno')"
			capture mata: runsbi(`case')
			if _rc != 0 {
				di as error "An internal function call has failed, probably due to convergence" _newline
				di as error "problems. This is embarrasing." _newline
				di as error "Please contact kai.arzheimer@gmail.com,"
				di as error "preferably attaching a copy of your data/logfile." _newline
				error 499
				}
			}
			
		}
	

	
end


*******************************************
* Helper function for running surveybiasi
* on every included line and storing results
* Function needs to import views
*******************************************

mata:
	void runsbi(real scalar i)
	{

		// import views into function		
		external _surveybiasseriesP , _surveybiasseriesS ,_surveybiasseriesB, _surveybiasseriesSE, _surveybiasseriesN, _surveybiasseriesChi
		// convert population values + sample values + N to strings
		// for calling surveybiasi programmatically
		// prepare call of surveybiasi
		call = "surveybiasi, popval(" + invtokens(strofreal(_surveybiasseriesP[i,])) + ")"
		call = call + " sampleval(" + invtokens(strofreal(_surveybiasseriesS[i,])) + ")"
		call = call + " n(" + invtokens(strofreal(_surveybiasseriesN[i,])) + ")"
		call = call + st_local("prop") + st_local("numerical")
		// call surveybiasi programmatically using macros
		stata(call,1)
		// collect coefficients
		_surveybiasseriesB[i,] = st_matrix("e(b)")
		// collect Variances
		V = st_matrix("e(V)")
		// take square root, transpose, write into variables
		_surveybiasseriesSE[i,] = sqrt(diagonal(V))'
		// Collect Chi-square and P-values
		// +0 required?!?
		_surveybiasseriesChi[i,1] = st_numscalar("e(chi2p)") +0 
		_surveybiasseriesChi[i,2] = st_numscalar("e(chi2lr)") +0 
		_surveybiasseriesChi[i,3] = st_numscalar("e(pp)") +0 
		_surveybiasseriesChi[i,4] = st_numscalar("e(plr)") +0 
		}
	
end



/* suverybiasseries.ado ends here */

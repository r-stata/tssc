*! version 1.1 Oktober 19, 2010 @ 10:38:11 UK
*! Max SD correction for limited scales

* 1.0.0 first version
* 1.0.1 Added functionality for simulation 
* 1.1. Keep option 

program sdlim, byable(recall)
version 11

	syntax varlist [if] [in] [aweight fweight] ///
	  [, by(varname) Limits(numlist ascending integer) SIMulate(string) keep ]
	
	marksample touse

	// Error checks & Defaults
	// -----------------------

	// varlist vs. by specification
	if `: word count `varlist'' > 1 & "`by'" != "" {
		di as error "Option by() restricts varlist to one"
		exit 198
		}
	if "`by'"=="" & "`limits'" == "" {
		di as error "Limits required when by() is empty"
		exit 198
		}
	
	// User-provided MinMax
	if "`limits'" != "" {
		local k: word count `limits'
		local min: word 1 of `limits'
		local max: word `k' of `limits' 
		}
		
	// Default limit for by() specification
	if "`limits'" == "" {
		quietly sum `varlist' if `touse'
		local min = r(min)
		local max = r(max)
		}

	local userweight "[`weight' `exp']"
	

	// Define postfile
	// ---------------

	tempname sdpost
	tempfile sdout
	postfile `sdpost' 					/// 
	  str99 rowname str99 range  		/// 
	  mean sd ieff sd_ieff using `sdout'

	// Rowname-concept
	// ---------------

	if "`by'"=="" {
		local rowtyp `varlist'
		local syntax 0
	}
	else if "`by'" != "" {
		quietly levelsof `by' if `touse', local(rowtyp)
		local syntax 1
	}
	
	// SDMAX
	// -----
	
	if "`simulate'" == "" {

		foreach row of local rowtyp {

			if !`syntax' quietly _SDLIM `row' `userweight' 	/// 
			  if `touse', min(`min') max(`max') 

			else if `syntax' quietly _SDLIM `varlist' `userweight' 	/// 
			  if `touse', min(`min') max(`max') by(`by') k(`row') 

			post `sdpost' ("`r(rowname)'") ("`r(range)'") 	/// 
			  (r(mean)) (r(sd)) (r(ieff)) (r(sdcorr))

		}
	}

	// SIMULATION
	// ----------
	
	else if "`simulate'" != "" {

		// Parse Parameters
		gettoken obs sigma: simulate
		if "`reps'" == "" local reps 200

		// Run simulation
		preserve
		tempname simul
		tempfile simres
		postfile `simul' s m using `simres'
		forv i = 1/`reps' {
			quietly _SDSIM, obs(`obs') range(`min'(1)`max') sigma(`sigma')
			post `simul' (r(sd)) (r(mean))
		}
		postclose `simul'
		use `simres', clear
		quietly reg s m c.m#c.m
		restore

		// Merge to data
		local predict "(_b[_cons]+_b[m]*r(mean)+_b[c.m#c.m]*r(mean)^2)"

		quietly foreach row of local rowtyp {
			if !`syntax' {
				local rowname `row'
				sum `row' `userweight' if `touse'
			}
			else if `syntax' {

				capture confirm numeric variable `by'
				if !_rc {
					local rowname : label (`by') `row' 
					sum `varlist' if `touse' & `by' == `row'
				}
				else {
					local rowname `row' 
					sum `varlist' if `touse' & `by' == "`row'"
				}
			}
			local ieff = `sigma'/`predict'
			local sdcorr = r(sd)*`ieff'
			
			post `sdpost' ("`row'") ("`r(min)' `r(max)'") 	/// 
			  (r(mean)) (r(sd)) (`ieff') (`sdcorr')
		}
	}

	// Display
	// -------
	
	postclose `sdpost'

	if "`keep'" == "" preserve
	
	use `sdout', clear
	label variable rowname "`=cond(`syntax',"Group","Variable")'"
	label variable range "Range"
	label variable mean "Mean"
	label variable sd "Std. Dev."
	label variable ieff "IEFF"
	label variable sd_ieff "SD_IEFF"
		
	if "`simulate'" != "" local flag "{txt} using simulations"
	di _n 								///
	  "{txt}IEFF corrected Standard deviations for limits [{res}`min'{txt}, {res}`max'{txt}]`flag'"
	tabdisp rowname, cellvar(range mean sd ieff sd_ieff) missing

end


// Calculation of SD-MAX
// ---------------------

program _SDLIM, rclass
	syntax varlist [aweight fweight] [if] , min(string) max(string)  /// 
	  [by(string) k(string)]

	marksample touse
	local rowname `varlist'
	
	if "`by'"!="" {
		capture confirm numeric variable `by'
		if !_rc {
			local rowname : label (`by') `k' 
			quietly replace `touse' = 0 if `by' != `k'
		}
		else {
			local rowname `k' 
			quietly replace `touse' = 0 if `by' != "`k'"
		}
	}

	sum `varlist' if `touse' [`weight' `exp']
	local N = r(N)  // <- must be r(N) fow both weights!
	local mean = r(mean)
	local sd = r(sd)
	local obsmin = r(min)
	local obsmax = r(max)
	
	// Maximum Std. Dev. (Kalmijn/Veenhoven 2005: 372)
	local ieff = 1/sqrt((`min'-`mean')*(`mean' - `max')* `N'/(`N'-1)) 
	
	// Corrected standard deviation
	local sdcorr = `sd' * `ieff'
	
	// Overwrite if user options inconsistent
	if (`obsmin'<`min') | (`obsmax' > `max') {
		local sdmax . 
		local sdcorr . 
	}
	
	return local rowname "`rowname'"
	return local range "`obsmin', `obsmax'"
	return scalar sdcorr = `sdcorr'
	return scalar ieff = `ieff'
	return scalar sd = `sd'
	return scalar mean = `mean'
end

// Simulation
// ----------

program _SDSIM, rclass
version 11
	syntax [ , obs(integer 1) sigma(real 1) range(numlist)]
	drop _all
	set obs `obs'

	local recode: subinstr local range " " ",", all
	local last: word count `range'
	local min: word 1 of `range'
	local max: word `last' of `range'

	local mu = runiform()*(`max'-`min')+`min'

	di `sigma'
	
	tempvar z
	gen `z' = recode(round(rnormal(`mu',`sigma'),1),`recode')
	sum `z'
	return scalar mean = r(mean)
	return scalar sd  = r(sd)
end


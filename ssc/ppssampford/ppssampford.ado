*! 0.1.0 jmendelson 14dec14
*Sampford PPS sampling without replacement
/*
Changelog

v0.1.0
-streamlined code slightly
-added item to avoid modifying sort order in main routine

To-do:
-Conduct further testing
-Explore implementation of a non-rejective Sampford algorithm
-Examine possible speed enhancements
-Allow for computation/output of second-order inclusion probabilities
-Ensure does not modify sort order
*/
program ppssampford
version 12.1
syntax [if] [in], SAMPSIZE(varname numeric) OUTname(string) MOS(varname numeric) [STRATA(varname numeric)] [REPlace] [RESCALE] [OUTPOS(string)]
marksample touse
tempvar one tempStrata ID badTarget
tempvar zeros
tempfile tempdata_full tempdata_sampled

if("`replace'"!="") cap drop `outname'						//if "replace" is on, drop previous sampled variable
if("`replace'"!="" & "`outpos'"!="") cap drop `outpos'		//if replace is on and outpos is used, drop previous outpos variable

//First, make sure we have complete data

//MOS should be complete and should be positive for all observations
qui {
	count if `touse'
	loc num1 = r(N)

	markout `touse' `mos'
	count if `touse'
	loc num2a = r(N)
	if("`num1'"!="`num2a'") di as err "Warning: there are some cases with missing MOS, which will be ignored."

	gen byte `zeros' = 1 if(`touse' & `mos'!=0)
	markout `touse' `zeros'
	drop `zeros'
	count if `touse'
	loc num2b = r(N)
	if("`num2a'"!="`num2b'") di as err "Warning: there are some cases with MOS equal to zero, which will be ignored."

	if("`strata'"!="") {
		//If stratification is used, variable should be complete
		count if `touse'
		loc num1 = r(N)
			
		markout `touse' `strata'
		count if `touse'
		loc num3 = r(N)
		if("`num1'"!="`num3'") di as err "Warning: there are some cases with missing strata, which will be ignored."
	}

	//The target sample size for all strata should be positive
	count if `touse'
	loc num1 = r(N)
	gen byte `badTarget' = 1 if(`touse'==1 & `sampsize'>0)
	markout `touse' `badTarget'
	count if `touse'
	loc num2 = r(N)
	if("`num1'"!="`num2'") di as err "Warning: there are some cases in strata with target sample size of 0 or less, which will be ignored."

	gen double `ID' = _n
	cap assert `ID'[_n]!=`ID'[_n+1]
	if(_rc!=0) {
		di as err _n "{error}Program error. Too many observations to uniquely identify."
	}
		
	cap assert `touse'==1
	if(_rc!=0) {
		//If not all cases are to be included in sampling, then save dataset, drop observations that aren't relevant, and run the program on only those valid cases, and merge back in

		save `tempdata_full'
		drop if(`touse'!=1)
		
		cap noi ppssampford, sampsize(`sampsize') mos(`mos') outname(`outname') `=cond("`strata'"=="","","strata(`strata')")' `rescale' `=cond("`outpos'"=="","","outpos(`outpos')")' `replace'

		if (_rc==0) {
			//Sampling was successful, so merge output variable into original dataset
			keep `ID' `outname'	`outpos'	//Keep ID and sampling indicator variable
			save `tempdata_sampled'
			
			drop _all
			use `tempdata_full'
			merge 1:1 `ID' using `tempdata_sampled', nogenerate
			}
		else {
			//sampling was unsuccessful, so restore dataset to previous state and exit
			loc error = _rc
			drop _all
			use `tempdata_full'
			exit `error'
		}
	}
	else {
		//All cases are to be included as observations

		//If no strata variable is specified, assign all cases to the same stratum
		if("`strata'"=="") {
			gen `tempStrata' = 1
			loc strataString "`tempStrata'"
		}
		else {
			loc strataString "`strata'"
		}
		
		//Make sure there are enough available cases
		gen byte `one' = 1
		tempvar numInStrata
		egen `numInStrata' = total(`one'), by(`strataString')
		cap assert `numInStrata'>=`sampsize'
		if(_rc!=0) {
			display as err _n "{error}Some strata have fewer cases available than you are attempting to sample."
			error 459
		}
		drop `numInStrata'

		//Ensure MOS positive, finite
		cap assert `mos'>0 & `mos'<.
		if(_rc!=0) {
			display as err _n "{error}MOS is not in the range (0,infinity)."
			error 459
		}
		
		//target sample size should be uniform within strata
		sort `strataString'
		cap assert (`strataString'[_n]!=`strataString'[_n+1] | `sampsize'[_n]==`sampsize'[_n+1] | _n==_N)
		if(_rc!=0) {
			sort `ID'
			display as err _n "{error}Target sample size (`varlist') in not uniform within stratum"
			error 459
		}
		sort `ID'
		
		tempvar totMOS MOS_share mod_MOS
		egen double `totMOS' = total(`mos'), by(`strataString')
		gen double `MOS_share' = `mos'/`totMOS'
		gen double `mod_MOS' = `MOS_share'*`sampsize'

		//See if any impossible measures of size
		cap assert inrange(`mod_MOS',0,1)
		if(_rc!=0) {
			//some cases have impossible MOS
			if("`rescale'"=="") {
				//rescale option not flagged, so abort
				di as err "Error: Some cases have an MOS that leads to an impossible probability of selection. Consider using 'rescale' option."
				error 459
			}
			else {
				//rescale option is on, so select certainty cases then re-run algorithm on remaining cases
				tempvar select_cert nCertInStrata mod_sampsize

				gen byte `select_cert' = (`mod_MOS'>=1)		//set to 1 for certainty cases, 0 otherwise
				egen `nCertInStrata' = total(`select_cert'), by(`strataString')
				gen `mod_sampsize' = `sampsize' - `nCertInStrata'		//indicates remaining number of cases to select

				ppssampford if(`select_cert'!=1), sampsize(`mod_sampsize') outname(`outname') strata(`strataString') mos(`mos') `=cond("`outpos'"=="","","outpos(`outpos')")' `rescale'
				
				replace `outname' = 1 if(`select_cert'==1)

				if("`outpos'"!="") replace `outpos' = 1 if(`select_cert'==1)

			}
		}
		else {
			//no rescaling is necessary, so go ahead and draw sample
			drawsampfordbystrata, sampsize(`sampsize') outname(`outname') strata(`strataString') mos(`mos') `=cond("`outpos'"=="","","outpos(`outpos')")'
			la var `outname' "`outname': Sample indicator var (1=sampled, 0=not sampled)"
			if("`outpos'"!="") la var `outpos' "`outpos': First order probability of selection"
		}
	}
}
recast byte `outname'
end

//Loops through the strata and conducts sampford sampling on each
program drawsampfordbystrata
syntax, SAMPSIZE(varname numeric) OUTname(string) STRATA(varname numeric) MOS(varlist min=1 max=1) [OUTPOS(string)]
levelsof(`strata'), loc(stratLvls)

tempfile tempdata_full tempdata_samp
tempvar ID totMOS MOS_share

gen double `ID' = _n
//will be unique, given that this was found to be unique in main routine

if("`outpos'"!="") {
	egen double `totMOS' = total(`mos'), by(`strata')
	gen double `MOS_share' = `mos'/`totMOS'
	gen double `outpos' = `MOS_share'*`sampsize'
}

save `tempdata_full'

loc numStrat: word count `stratLvls'
forval i=1/`numStrat' {
	loc l: word `i' of `stratLvls'

	tempfile tempdata_strat`i'
	drop _all
	use `tempdata_full'			//open full dataset
		
	keep if(`strata'==`l')		//restrict to stratum of interest
	cap noi drawsampford_rejective, sampsize(`sampsize') mos(`mos') out(`outname')
	if (_rc!=0) {
		loc error = _rc
		drop _all
		use `tempdata_full'
		exit `error'
	}
	
	keep `ID' `outname'

	if("`i'"=="1") {
		save `tempdata_samp'
	}
	else {
		append using "`tempdata_samp'"
		save `tempdata_samp', replace
	}
}

drop _all
use `tempdata_full'
merge 1:1 `ID' using `tempdata_samp', nogenerate
end


//draws sample from a dataset restricted to one stratum, with uniform sample size indicated and valid MOS
//Uses original multinomial rejective algorithm 
program drawsampford_rejective
syntax, SAMPSIZE(varname numeric) OUTname(string) MOS(varlist min=1 max=1)
tempvar firstCase remainingCases modMOS MOS_share combinedHits
tempname totMOS success

loc targN = `sampsize'[1]	//target N is uniform within stratum

//Calculate modified MOS for subsequent cases
sum `mos'
scalar `totMOS' = r(sum)
gen double `MOS_share' = `mos'/`totMOS'
gen double `modMOS' = `MOS_share'/(1-(`targN')*(`MOS_share'))

scalar `success' = 0

while `=`success'' == 0 {
	cap drop `combinedHits'
	
	//Draw the first case with prob in proportion to MOS
	ppswr, sampsize(1) out(`firstCase') mos(`mos') rep

	//Draw remaining cases with prob according to formula
	ppswr, sampsize(`=`sampsize'-1') out(`remainingCases') mos(`modMOS') rep
	
	//Combine cases, see if end condition met
	gen long `combinedHits' = `firstCase'+`remainingCases'
	
	cap assert `combinedHits'<=1
	if(_rc==0) {
		scalar `success' = 1
	}
}

//success! no duplicates
rename `combinedHits' `outname'

end



//Implements PPS with replacement
//Assumes no stratification
program ppswr
syntax [if] [in], SAMPSIZE(integer) OUTname(string) MOS(varlist min=1 max=1 numeric) [REPlace]
marksample touse
tempfile tempdata_full tempdata_sampled
tempvar totMOS MOS_share cumu_MOSshare numHits cumuHits prevHits ID
tempname randnum
qui {
	if("`replace'"!="") cap drop `outname'		//if "replace" is on, drop previous sampled variable

	cap assert `touse'==1
	if(_rc!=0) {
		//If not all cases are to be included in sampling, then save dataset, drop observations that aren't relevant, and run the program on only those valid cases, and merge back in
		gen double `ID' = _n

		save `tempdata_full'
		drop if(`touse'!=1)
		keep `ID' `mos'
		cap ppswr, sampsize(`sampsize') outname(`outname') mos(`mos') `replace'
		if (_rc==0) {
			//Sampling was successful, so merge output variable into original dataset
			keep `ID' `outname'		//Keep ID and sampling indicator variable
			save `tempdata_sampled'
			
			drop _all
			use `tempdata_full'
			merge 1:1 `ID' using `tempdata_sampled', nogenerate
		}
		else {
			//sampling was unsuccessful, so restore dataset to previous state and exit
			loc error = _rc
			drop _all
			use `tempdata_full'
			exit `error'
		}
	}
	else {
		//No cases to be excluded from sampling, thus we can proceed with PPSWR algorithm
		
		egen `totMOS' = total(`mos')
		gen double `MOS_share' = `mos'/`totMOS'
		gen double `cumu_MOSshare' = .
		replace `cumu_MOSshare' = cond(_n==1,`MOS_share',`MOS_share'+`cumu_MOSshare'[_n-1])
		gen long `cumuHits' = 0

		forval i=1/`sampsize' {
			//Make sure there are no rounding errors that prevent a selection
			loc goodHit ""
			while ("`goodHit'"=="") {
				scalar `randnum' = runiform()
				if(`=`randnum''<`cumu_MOSshare'[_N]) loc goodHit "Y"
			}
			replace `cumuHits' = `cumuHits'+(`=`randnum''<`cumu_MOSshare')
		}

		gen long `prevHits' = `cumuHits'[_n-1]
		replace `prevHits' = 0 in 1

		gen long `numHits' = `cumuHits'-`prevHits'

		rename `numHits' `outname'
	}
}
end

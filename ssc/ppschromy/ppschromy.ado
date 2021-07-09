*! 1.0.2 jmendelson 20dec14
*Chromy PPS sequential random sampling
/*
Changelog

v1.0.2:
fixed bug that occurred when first case has prob of selection equal to 1 due to fractionpart being 0

v1.0.1:
-reprogrammed core logic as to fix floating point rounding issue that could occur with pmr and epsilon probabilities of selection

v1.0.0:
-strata optional
-allows PMR
-allows "if"
-additional testing/debugging prior to public release
-allows replace
-note: "pre" option for debugging/testing purposes and not for public use, therefore not necessarily fully implemented

To-do:
-Examine possible speed enhancements (i.e., avoiding egen)
-Clean up syntactical structure of subroutines
-Consider requiring random seed
-Consider adding additional safeguards against misuse
-Consider 'rescale' option to modify MOS so that it if it's too big, it is scaled down as appropriate
-Possibly create as output vars 1st- and/or 2nd-order inclusion probabilities
*/
program ppschromy, sortpreserve
version 12.1
syntax [if] [in], SAMPSIZE(varname numeric) OUTname(string) SORT(varlist min=1 numeric) [STRATA(varname numeric)] [PREfix(string)] [MOS(varname numeric)] [PMR] [REPlace]
marksample touse
tempvar one numInStrata tempStrata ID badTarget
qui {
	if("`replace'"!="") cap drop `outname'		//if "replace" is on, drop previous sampled variable

	//First, make sure we have complete data
	if("`mos'"!="") {
		//If there's an MOS, it should be complete and should be positive for all observations
		tempvar zeros

		count if `touse'
		loc num1 = r(N)

		markout `touse' `mos'
		count if `touse'
		loc num2a = r(N)
		if("`num1'"!="`num2a'") di as err "Warning: there are some cases with missing MOS, which will be ignored."

		gen byte `zeros' = 1 if(`touse' & `mos'!=0)
		markout `touse' `zeros'
		count if `touse'
		loc num2b = r(N)
		if("`num2a'"!="`num2b'") di as err "Warning: there are some cases with MOS equal to zero, which will be ignored."
	}
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
	
	cap assert `touse'==1
	if(_rc!=0) {
		//If not all cases are to be included in sampling, then save dataset, drop observations that aren't relevant, and run the program on only those valid cases, and merge back in
		tempfile tempdata_full tempdata_sampled

		gen double `ID' = _n
		cap assert `ID'[_n]!=`ID'[_n+1]
		if(_rc!=0) {
			di as err _n "{error}Program error. Too many observations to uniquely identify."
		}
		save `tempdata_full'
		drop if(`touse'!=1)
		cap noi ppschromy, sampsize(`sampsize') outname(`outname') sort(`sort') `=cond("`strata'"=="","","strata(`strata')")' `=cond("`mos'"=="","","mos(`mos')")' `pmr'
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
		//All cases are to be included as observations

		//If sampling WOR is used then make sure there are enough available cases
		if("`pmr'"!="pmr") {
			gen byte `one' = 1
			egen `numInStrata' = total(`one'), by(`strata')
			cap assert `numInStrata'>=`sampsize'
			if(_rc!=0) {
				display as err _n "{error}Some strata have fewer cases available than you are attempting to sample."
				error 459
			}
		}

		//Ensure MOS positive, finite
		if("`mos'"!="") {
			cap assert `mos'>0 & `mos'<.
			if(_rc!=0) {
				display as err _n "{error}MOS is not in the range (0,infinity)."
				error 459
			}
		}
		
		if("`mos'"=="") local sizestring ""
		if("`mos'"!="") local sizestring "size(`mos')"							//create a string that can be used to pass on the optional argument to subroutines
		
		if("`prefix'"=="") local prefixstring ""
		if("`prefix'"!="") local prefixstring "prefix(`prefix')"
		
		//If no strata variable is specified, assign all cases to the same stratum
		if("`strata'"=="") {
			gen `tempStrata' = 1
			loc strataString "`tempStrata'"
		}
		else {
			loc strataString "`strata'"
		}

		//Apply serpentine sorting and then draw sample
		serpsort `sort', strata(`strataString') `prefixstring'
		if("`prefix'"!="") gen double `prefix'_serporder = _n
		chromysample `sampsize', outname(`outname') strata(`strataString') `sizestring' `pmr' `prefixstring'
		if("`prefix'"!="") gen double `prefix'_finalorder = _n
	}
}
end





program serpsort
*Program assumes existence of a strata variable
syntax varlist (min=1), STRATA(varname numeric) [PREfix(string)] 
if("`prefix'"=="") serpsort_main `varlist', strata(`strata')
if("`prefix'"!="") serpsort_main `varlist', strata(`strata') prefix(`prefix')
end





program serpsort_main
tempvar randnum
gen double `randnum' = runiform()
syntax varlist (min=1), STRATA(varname numeric) [PREfix(string)] 
*Only the last variable can be a string; the other vars must be numeric
*"Prefix" optionally saves all the intermediate variables (albeit with slightly confusing prefixes)
/*
My general recursive algorithm:
1. Count the number of vars
2. If one var, sort by strata v1 rand#.  then done
3. If 2+ vars, then do serpsort on all but the last var to determine the ordering for all but the last var.
    Then do two sorts: one where the last var is ascending, and one where it is descending.  Determine if 
	the ordering should be ascending or descending, then assign the final ordering accordingly, and reorder.
*/
local nvar: word count `varlist'
display "`nvar'"
 
if (`nvar'==1) sort `strata' `varlist' `randnum'
if `nvar'>=2 {
	tempvar ordergroup newOrderGroup totOrderGroup minStrataGroup flipGroup temporder1 temporder2 finalorder
	tokenize `varlist'
	local tempcount: word count `varlist'
	local lastitem = "``tempcount''"
	local tempcount = `tempcount' - 1
	local firstitems ""
	forval i=1/`tempcount' {
		local firstitems = "`firstitems'" + " " + "``i''"
	}
	*After these few lines of code, firstitems has all but the last variable; and lastitem is the last variable
	
	sort `randnum'
	if("`prefix'"=="") serpsort_main `firstitems', strata(`strata')
	if("`prefix'"!="") serpsort_main `firstitems', strata(`strata') prefix(`prefix'v`nvar'_)
	
	egen `ordergroup' = group(`strata' `firstitems')
	gen `newOrderGroup' = `ordergroup'[_n]!=`ordergroup'[_n-1]
	gen `totOrderGroup' = 0
	replace `totOrderGroup' = `totOrderGroup'[_n-1]+`newOrderGroup'[_n] if(_n>1)
	egen `minStrataGroup' = min(`totOrderGroup'), by(`strata')
	gen `flipGroup' = mod(`totOrderGroup'+`minStrataGroup',2)

	sort `totOrderGroup' `lastitem' `randnum'
	gen double `temporder1' = _n

	gsort `totOrderGroup' -`lastitem' -`randnum'
	gen double `temporder2' = _n
	
	gen double `finalorder' = `temporder1'
	replace `finalorder' = `temporder2' if(`flipGroup')
	sort `finalorder'
	
	if("`prefix'"!="") {
		foreach v in ordergroup newOrderGroup totOrderGroup minStrataGroup flipGroup temporder1 temporder2 finalorder {
			rename ``v'' `prefix'_serp_`v'
		}
	}

}

if("`prefix'"!="") rename `randnum' `prefix'randnum

end





program chromysample
syntax varlist (min=1 max=1), OUTNAME(string) [PREFIX(string)] STRATA(varname numeric) [SIZE(varlist min=1 max=1)] [PMR]
*Program assumes existence of a strata variable
*The input variable is the number of desired cases per stratum
*Outname is the output variable for whether someone was sampled
*Prefix, optionally, will save the intermediate variables, using that prefix

tempvar nInStrata rand totInStrata one minInStrata strataStart firstInStrata lastInStrata
tempvar obsInStrata temp numOfStrataStart obsInStrataReordered sampled probOfSelection cumuExpectedHits integerPart fractionPart 
tempvar newrand formula1 formula2 comparison1 comparison2 cumuSampled mos totMosInStrata numCertaintyHits totSamp diffFromIntPart
tempname numStrata numStarts

if("`size'"!="") clonevar `mos' = `size'		//if MOS specified, copy to mos
if("`size'"=="") gen byte `mos' = 1				//if MOS not specified, create new one equal to 1

qui: duplicates report `strata'
scalar `numStrata' = r(unique_value)

gen byte `one' = 1
gen `nInStrata' = `varlist'
scalar `numStarts' = 0

//Check to make sure target sample size is uniform within strata
cap assert (`strata'[_n]!=`strata'[_n+1] | `nInStrata'[_n]==`nInStrata'[_n+1] | _n==_N)
if(_rc!=0) {
	display as err _n "{error}Target sample size (`varlist') in not uniform within stratum"
	error 459
}

while `numStrata'!=`numStarts' {
	*This section of code most likely will only run once. It randomly generates a number, then the smallest numbers are the starts within strata.
	*In the unlikely event that two minimum numbers are equal, it will re-run.
	qui: cap drop `rand' `totInStrata' `minInStrata' `strataStart'
	gen `rand' = runiform()
	egen `totInStrata' = total(`one'), by(`strata')
	egen `minInStrata' = min(`rand'), by(`strata')
	gen `strataStart' = (`minInStrata'==`rand')

	count if `strataStart'
	scalar `numStarts' = r(N)
}

gen byte `firstInStrata' = `strata'[_n]!=`strata'[_n-1]
gen byte `lastInStrata' = `strata'[_n]!=`strata'[_n+1]
gen `obsInStrata' = `firstInStrata'
replace `obsInStrata' = `obsInStrata'[_n-1]+1 if(`obsInStrata'!=1)
gen `temp' = `obsInStrata' if(`strataStart')
egen `numOfStrataStart' = min(`temp'), by(`strata')
gen `obsInStrataReordered' = mod(`obsInStrata'-`numOfStrataStart',`totInStrata')

sort `strata' `obsInStrataReordered'

egen `totMosInStrata' = total(`mos'), by(`strata')
gen double `probOfSelection' = `nInStrata'*`mos'/`totMosInStrata'

if("`pmr'"=="") {
	//If probability minimum replacement is not specified (i.e., probabability non-replacement is used), make sure prob of selection is <=100%
	cap assert inrange(`probOfSelection',0,1) if(`probOfSelection'!=.)
	if(_rc!=0) {
		display as err _n "{error}Some cases have a probability of selection higher than 1."
		error 459
	}
}
if("`pmr'"!="") {
	//If probability w/ minimum replacement has been selected, select the int number of hits first
	gen double `numCertaintyHits' = floor(`probOfSelection')
	replace `probOfSelection' = `probOfSelection' - `numCertaintyHits'
	assert inrange(`probOfSelection',0,1) if(`probOfSelection'!=.)
}

gen double `cumuExpectedHits' = `probOfSelection' if(`strataStart'==1)
replace `cumuExpectedHits' = `cumuExpectedHits'[_n-1]+`probOfSelection'[_n] if(!`strataStart')

gen `integerPart' = floor(`cumuExpectedHits')
gen double `fractionPart' = `cumuExpectedHits' - `integerPart'

gen double `newrand' = runiform()

//If Tot[i-1]==Int[i-1], use formula 1
//	If Frac[i]==0 or Frac[i-1]>Frac[i] then Tot[i]=Int[i]
//	Otherwise, Tot[i] = I[i]+1 with adjusted probability: (F[i]-F[i-1])/1-F[i-1]
//
//In other words, this formula is used when case has not yet been picked for the implicit stratum through case i-1
//So, since we've already selected the certainty hits:
//	If strata start then we choose with probability probOfSelection
//	If not strata start
//		If we've hit a boundary or crossed a boundary this round, pick with probability 1
//		If we haven't crossed a boundary, pick with adjusted probability (Frac[i]-Frac[i-1])/(1-Frac(i-1))
gen double `formula1' = cond(`strataStart'==1, ///
								`probOfSelection',	///
								cond(`integerPart'[_n]>`integerPart'[_n-1], ///
									1, ///
									(`fractionPart'[_n]-`fractionPart'[_n-1])/(1-`fractionPart'[_n-1]) ///
									) ///
							)

//If T[i-1]==Int[i-1]+1, use formula 2
//	If Frac[i]=0, then T[i]==I[i]
//	If Frac[i]>Frac[i-1], then T[i]=Int[i]+1
//	Otherwise, Total[i] = Int[i]+1 with probability Frac[i]/Frac[i-1]
//
//Formula 2 is used when when a case has been picked for previous implicit stratum for case i-1
//doesn't matter what it is for strata start, since this always leads to formula1
//If cumu expected hits has not increased, set to 0 (this is a fix for floating point rounding issues for very tiny probabilities of selection relative to MOS)
//	Else, if fraction is now 0, then it is cumu expected hits minus int part
//		If fraction is greater than prev fraction, then it is 0 (since case has been picked for implicit stratum)
//			Otherwise (eg fraction is less than prev fraction, ie case not yet picked for implicit stratum), then adjusted probability - Frac[i]/Frac[i-1]
gen double `formula2' = cond(`cumuExpectedHits'[_n]==`cumuExpectedHits'[_n-1], 0, ///
						cond(`fractionPart'[_n]==0,	///
							`cumuExpectedHits'[_n]-`integerPart'[_n], ///
							cond(`fractionPart'[_n]>`fractionPart'[_n-1], 0, (`fractionPart'[_n]/`fractionPart'[_n-1])) ) )

gen byte `comparison1' = `newrand'<`formula1'
gen byte `comparison2' = `newrand'<`formula2'

//Now, determine whether to use formula1 or formula2 for a cumulative sampled var, depending on whether we're at the integer part or not
//	Use comparison1 if strata start
//	Else, if we're at the prev int part, then add comparison 1
//		else, use formula 2

gen long `cumuSampled' = `comparison1' if (`strataStart')
replace `cumuSampled' = cond(`cumuSampled'[_n-1]==`integerPart'[_n-1],`cumuSampled'[_n-1]+`comparison1'[_n],`cumuSampled'[_n-1]+`comparison2'[_n]) if(!`strataStart')

//Check to make sure cumu sample count is within acceptable range of algorithm
gen byte `diffFromIntPart' = `cumuSampled'-`integerPart'
cap assert inrange(`diffFromIntPart',0,1)
if (_rc!=0) {
	//This shouldn't ever occur, but provides an extra safeguard in case of floating-point arithmetic issues.
	display as err _n "{error}Warning: properties of algorithm violated, probably due to floating-point rounding issues. Please contact program's author with the information necessary to replicate issue if possible and/or if the problem persists."
	error 459
}

gen double `sampled' = `cumuSampled' if(`strataStart')
replace `sampled' = (`cumuSampled'[_n]!=`cumuSampled'[_n-1]) if(!`strataStart')

if("`pmr'"!="") replace `sampled' = `sampled' + `numCertaintyHits'

rename `sampled' `outname'
if("`pmr'"!="") la var `outname' "`outname': Number of case selections via Chromy algorithm with PMR"
if("`pmr'"=="") la var `outname' "`outname': Case sampled via Chromy algorithm with PNR"

//Check to see if right # of cases has been selected
egen `totSamp' = total(`outname'), by(`strata')
cap assert `totSamp'==`nInStrata'
if (_rc!=0) {
	//This shouldn't ever occur, but provides an extra safeguard in case of floating-point arithmetic issues.
	display as err _n "{error}Warning: incorrect number of cases sampled; probably due to floating-point rounding issues. Please contact program's author with the information necessary to replicate issue if possible and/or if the problem persists."
	error 459
}

if("`prefix'"!="") {
	*if a prefix is supplied, saves the intermediate variables
	foreach v in nInStrata rand totInStrata one minInStrata strataStart firstInStrata lastInStrata obsInStrata temp numOfStrataStart obsInStrataReordered probOfSelection cumuExpectedHits integerPart fractionPart newrand formula1 formula2 comparison1 comparison2 cumuSampled {
		rename ``v'' `prefix'_samp_`v'
	}
	if("`pmr'"!="") rename `numCertaintyHits' `prefix'_samp_`v'
}
end

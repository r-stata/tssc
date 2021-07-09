*! version 1.0.0  9may2017  Michael Stepner and Allan Garland, stepner@mit.edu

/* CC0 license information:
To the extent possible under law, the author has dedicated all copyright and related and neighboring rights
to this software to the public domain worldwide. This software is distributed without any warranty.

This code is licensed under the CC0 1.0 Universal license.  The full legal text as well as a
human-readable summary can be accessed at http://creativecommons.org/publicdomain/zero/1.0/
*/

* Why did I include a formal license? Jeff Atwood gives good reasons: https://blog.codinghorror.com/pick-a-license-any-license/

program define calipmatch, sortpreserve rclass
	version 13.0
	syntax [if] [in], GENerate(name) CASEvar(varname numeric) MAXmatches(integer) CALIPERMatch(varlist numeric) CALIPERWidth(numlist >0) [EXACTmatch(varlist)]
		
	* Verify there are same number of caliper vars as caliper widths
	local caliper_var_count : word count `calipermatch'
	local caliper_width_count : word count `caliperwidth'
	if (`caliper_var_count'!=`caliper_width_count') {
		di as error "must specify the same number of caliper widths as caliper matching variables."
		if (`caliper_var_count'<`caliper_width_count') exit 123
		else exit 122
	}
	
	* Verify that all exact matching variables have integer data tyes
	if ("`exactmatch'"!="") {
		foreach var of varlist `exactmatch' {
			cap confirm byte variable `var', exact
			if _rc==0 continue
			cap confirm int variable `var', exact
			if _rc==0 continue
			cap confirm long variable `var', exact
			if _rc==0 continue
			
			di as error "Exact matching variables must have data type {it:byte}, {it:int}, or {it:long}."
			
			cap confirm numeric variable `var', exact
			if _rc==0 di as error "Use the {help recast} command or caliper matching for variable: `var'."
			else di as error "Use the {help destring} command or another method to change the datatype for variable: `var'."
			
			exit 198
		}
	}
	
	* Verify that we can create the new variable specified
	confirm new variable `generate', exact
	
	* Mark the sample with necessary vars non-missing
	marksample touse
	markout `touse' `casevar' `calipermatch' `exactmatch'
	
	* Verify that case/control var is always 0 or 1 in sample
	cap assert `casevar'==0 | `casevar'==1 if `touse'==1
	if _rc==9 {
		di as error "casevar() must always be 0 or 1 in the sample."
		exit 198
	}
	error _rc
	
	* Sort into groups for caliper matching, randomizing order of cases and controls
	tempvar rand
	gen float `rand'=runiform()
	sort `touse' `exactmatch' `casevar' `rand'
	
	* Count the number of total obs and cases in sample
	qui count if `touse'==1
	local insample_total = r(N)
	if (`insample_total'==0) {
		di as error "no observations in sample"
		exit 2000
	}
	
	qui count if `casevar'==1 in `=_N-`insample_total'+1'/`=_N'
	local cases_total = r(N)
	if (`insample_total'==`cases_total') {
		di as error "no control observations in sample"
		exit 2001
	}
	if (`cases_total'==0) {
		di as error "no case observations in sample"
		exit 2001
	}
	
	* Find group boundaries 
	mata: boundaries=find_group_boundaries("`exactmatch'", "`casevar'", `=_N-`insample_total'+1', `=_N')
	
	* Perform matching within each group
	qui gen long `generate'=.
	tempname case_matches
	
	if r(no_matches)==0 {
		mata: _calipmatch(boundaries,"`generate'",`maxmatches',"`calipermatch'","`caliperwidth'")
		qui compress `generate'
		
		matrix `case_matches'=r(matchsuccess)
		matrix `case_matches' = (`cases_total' - `case_matches''* J(rowsof(`case_matches'),1,1)) \ `case_matches'
	}
	else {
		matrix `case_matches'=`cases_total' \ J(`maxmatches', 1, 0)
	}
	
	* Print report on match rate
	local cases_matched = `cases_total'-`case_matches'[1,1]
	local match_rate_print = string(`cases_matched'/`cases_total'*100,"%9.1f")

	di `"`match_rate_print'% match rate."'
	di `"`=string(`cases_matched',"%16.0fc")' out of `=string(`cases_total',"%16.0fc")' cases matched."'
	di ""
	di "Successful matches for each case"
	di "--------------------------------"
	forvalues m=0/`maxmatches' {
		local count=`case_matches'[`m'+1,1]
		local percent=string(`count'/`cases_total'*100,"%9.1f")
		local rownames `rownames' `m'
		
		di "`m' matched control obs: `count' (`percent'%)"
	}
	
	* Return match success rate
	matrix rownames `case_matches' = `rownames'
	matrix colnames `case_matches' = "count"
	
	return clear
	return scalar match_rate = `cases_matched'/`cases_total'
	return scalar cases_matched = `cases_matched'
	return scalar cases_total = `cases_total'
	return matrix matches = `case_matches'

end


version 13.0
set matastrict on

mata:

void _calipmatch(real matrix boundaries, string scalar genvar, real scalar maxmatch, string scalar calipvars, string scalar calipwidth) {

	real scalar matchgrp
	matchgrp = st_varindex(genvar)
	
	real rowvector matchvars
	matchvars = st_varindex(tokens(calipvars))

	real rowvector tolerance
	tolerance = strtoreal(tokens(calipwidth))
	
	real scalar curmatch
	curmatch = 0
	
	real colvector matchsuccess
	matchsuccess = J(maxmatch, 1, 0)
	
	real scalar brow
	real scalar caseobs
	real scalar controlobs
	real scalar casematchcount
	real rowvector matchvals
	real rowvector controlvals
	real matrix matchbounds
	
	for (brow=1; brow<=rows(boundaries); brow++) {
	
		for (caseobs=boundaries[brow,3]; caseobs<=boundaries[brow,4]; caseobs++) {
		
			curmatch++
			casematchcount=0
			_st_store(caseobs, matchgrp, curmatch)
			
			matchvals = st_data(caseobs, matchvars)
			matchbounds = (matchvals-tolerance)\(matchvals+tolerance)
			
			for (controlobs=boundaries[brow,1]; controlobs<=boundaries[brow,2]; controlobs++) {
			
				if (_st_data(controlobs, matchgrp)!=.) continue
				
				controlvals = st_data(controlobs, matchvars)
				
				if (controlvals>=matchbounds[1,.] & controlvals<=matchbounds[2,.]) {
					casematchcount++
					_st_store(controlobs, matchgrp, curmatch)
				}
				
				if (casematchcount==maxmatch) break
			
			}
			
			if (casematchcount==0) {
				curmatch--
				_st_store(caseobs, matchgrp, .)
			}
			else {
				matchsuccess[casematchcount,1] = matchsuccess[casematchcount,1]+1
			}
		
		}
	
	}
	
	stata("return clear")
	st_matrix("r(matchsuccess)",matchsuccess)

}

real matrix find_group_boundaries(string scalar grpvars, string scalar casevar, real scalar startobs, real scalar endobs) {

	real matrix boundaries
	boundaries = (startobs, ., ., .)
	
	real scalar nextcol
	nextcol=2
	
	real scalar currow
	currow=1
	
	real rowvector groupvars
	groupvars = st_varindex(tokens(grpvars))
	
	real scalar casevarnum
	casevarnum = st_varindex(casevar)
	
	real scalar obs
	for (obs=startobs+1; obs<=endobs; obs++) {
		if (st_data(obs, groupvars)!=st_data(obs-1, groupvars)) {
			if (nextcol==4) {
				boundaries[currow,4]=obs-1
				boundaries=boundaries\(obs, ., ., .)
				nextcol=2
				currow=currow+1
			}
			else {  // only one value of casevar in prev group --> skip group
				boundaries[currow,1]=obs
			} 
		}
		else if (_st_data(obs, casevarnum)!=_st_data(obs-1, casevarnum)) {
			boundaries[currow,2]=obs-1
			boundaries[currow,3]=obs
			nextcol=4
		}
	}
	
	stata("return clear")
	st_numscalar("r(no_matches)",0)
	if (nextcol==4) {
		boundaries[currow,nextcol]=endobs
		return (boundaries)
	}
	else {
	
		if (currow>1) return (boundaries[1..rows(boundaries)-1, .])
		else st_numscalar("r(no_matches)",1)
	
	}

}

end

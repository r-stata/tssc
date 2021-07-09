*! NJC 1.1.0 13 May 2004 
* NJC 1.0.0 11 May 2004 
program disjoint, sort 
	version 8 
	syntax varlist(numeric min=2 max=2) [if] [in] ///
		, Generate(str) [ id(varname) ] 

	quietly { 	
		marksample touse
		count if `touse' 
		if r(N) == 0 error 2000 

		capture confirm new var `generate' 
		if _rc { 
			di as err "`generate' invalid new variable name" 
			exit 198 
		} 	
	
		tokenize `varlist' 
		args start end 
		
		cap assert `start' <= `end' if `touse' 
		if _rc { 
			di as err "`start' > `end' within data"
			exit 498
		} 

		foreach v in start end { 
			cap assert ``v'' == floor(``v'') if `touse' 
			if _rc { 
				di as err "``v'' contains non-integer values"
				exit 498
			} 	
		} 	

		tempvar negend max 
		
		// sort on start then on -end; then find maximum so far 
		gen `negend' = -`end'
		gen `max' = . 
		bysort `touse' `id' (`start' `negend') : ///
			replace `max' = max(`end', `max'[_n-1]) 	
		
		// don't use spell if end not a new maximum 
		// (i.e. spell enclosed within another spell) 
		by `touse' `id' : replace `touse' = 0 if `max' == `max'[_n-1]   

		// first stab, without correction for overlap 
		gen `generate' = `end' if `touse'   

                // if each used spell overlaps with next, chop off the overlap 
		bysort `touse' `id' (`start') : ///
			replace `generate' = `start'[_n+1] - 1 ///
			if `end' >= `start'[_n+1] & `touse'
	}		
end 

/* 

Consider spells sorted on start and then on -end: 

	----------------------------------> time 
	
	*******
	******
	****
	 ***
            ******* 
	         ***** 
			***** 

The maximum so far is calculated from the ends. Here it is indicated by M:

	----------------------------------> time 
	
	******M
	******M
	****  M 
	 ***  M 
            ******M 
	         ****M 
			****M 

Ignoring spells which don't mark a new maximum ignores all those which 
are wholly included in other spells.

*/ 
	     

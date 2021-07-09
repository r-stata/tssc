*! version 1.0.3 29apr2015


program define igenerate, sortpreserve
version 12.1

	syntax varlist(numeric max=2 min=1) [if] [in] , Coding(name)  [ GENerate(namelist max=2) Omit(numlist max=2) ia]
	marksample touse
	
	
	* store r() to return it later
	tempname user_r 
	capture _return drop user_r
	_return hold user_r
	
	* Some globals and temporary variables
	tempvar helpvar1
	capture macro drop iavarlist1 iavarlist2		// is there a better solution for this?
	

	
	* Fill or complete generate if not specified by user
	if "`generate'" == "" {
		local generate = "`varlist'"
	}
	
	* check ia-option
	if "`ia'" == "ia" & "`coding'" != "we" & "`coding'" != "weightedeffect" & "`coding'" != "sweeney" {
		dis as error "Option " as input "ia " as error "is allowed only with weighted effect coding / sweeney coding"
		exit 197
		}
	
	* check how many variables are specified, then call the algorithm for single variables in a loop
	local nv: word count `varlist'		// nv = number of variables
	local nn: word count `generate'		// nn = number of names in generate option	
	local no: word count `omit'			// no = number of omited categories
	if `nv' > `nn' {
		dis as error "You must specify as many names in the generate option as variables in varlist"
		exit 103
	}
	if `nv' < `nn' {
		dis as error "You must specify as many names in the generate option as variables in varlist"
		exit 102
	} 	
	if `nv' < `no' {
		dis as error "You specified more than one omitted category in the generate option but you have only one variable"
		exit 123
	}
	
	gettoken var1 var2 : varlist
	gettoken gen1 gen2 : generate
	gettoken omit1 omit2 : omit
		if `no' == 1 & `nv' == 2 {
		local omit2 = `omit1'
		}
		

	* Loop that replaces the arguments varlist, omit and generate and then runs the code that has been written for one variable
	foreach num of numlist 1/`nv' {
		local varlist = "`var`num''"
		local omit = "`omit`num''"
		local generate = "`gen`num''"
		
		
		* HERE starts the code written for one variable
		
		* Check content of Coding; 
		* allowed "d" "dummy" "a" "adjacent" "ra" "reverseadjacent" "e" "effect" "we" "weightedeffect" "sweeney"
		if "`coding'" == "d" | "`coding'" == "dummy" {
			display as text "Dummy coding of `varlist'"
				if  "`omit'" != "" {
					qui sum `varlist' if `varlist' == `omit' & `touse'
						if r(N) < 1 {
							dis as error "Category `omit' cannot be used as the reference category because there are no observations or the category `omit' does not exist at all"
							exit 2000
						}
				}	
			igen_d `varlist' if `touse' , gen(`generate') o(`omit')
		}

		else if "`coding'" == "a" | "`coding'" == "adjacent" {
			display as text "Adjacent coding of `varlist' (forward differences)"
			if  "`omit'" != "" {
					display as error "Option " as input "omit " as error "is not allowed with reversed coding"
					exit 197
			}
			igen_a `varlist' if `touse', gen(`generate') c(forward)
		}
	
		else if "`coding'" == "ra" | "`coding'" == "reverseadjacent" {
			display as text "Reversed adjacent coding of `varlist' (backward differences)"
			if  "`omit'" != "" {
				display as error "Option " as input "omit " as error "is not allowed with reversed adjacent coding"
				exit 197
			}
			igen_a `varlist' if `touse', gen(`generate') c(backward)
		}

		else if "`coding'" == "e" | "`coding'" == "effect" {
			display as text "Effect coding of `varlist'"
				if  "`omit'" != "" {
					qui sum `varlist' if `varlist' == `omit' & `touse'
						if r(N) < 1 {
							dis as error "Category `omit' cannot be used as the reference category because there are no observations or the category `omit' does not exist at all"
							exit 2000
						}
				}	
			igen_e `varlist' if `touse' , gen(`generate') o(`omit') c(asbalanced)
		}
	
		else if "`coding'" == "we" | "`coding'" == "weightedeffect" | "`coding'" == "sweeney" {
			display as text "Weighted effect coding (Sweeney coding) of `varlist'"
			if  "`omit'" != "" {
					qui sum `varlist' if `varlist' == `omit' & `touse'
						if r(N) < 1 {
							dis as error "Category `omit' cannot be used as the reference category because there are no observations or the category `omit' does not exist at all"
							exit 2000
						}
				}	
			if "`ia'" == "" {
				igen_e `varlist' if `touse' , gen(`generate') o(`omit') c(asobserved)
			}
			if "`ia'" == "ia" {
				igen_e `varlist' if `touse' , gen(`generate') o(`omit') c(asobserved) ia(`num')
			}
		}
	
		else {
			dis as error "Option coding incorrectly specified. Coding must be one of the following elements:"
			dis as text "d dummy a adjacent ra reverseadjacent e effect we weightedeffect sweeney"
			dis as error "You typed: " as input "`coding'"
			exit 197	
		}

	}	

	* IF weighted effect coding and ia specified: Generate orthogonal interaction terms
	if "`ia'" == "ia" {
		tokenize "$iavarlist2"
		local nd: word count $iavarlist2		
		foreach var of varlist $iavarlist1 {
			foreach num of numlist 1/`nd' {
				gen ia_`var'_``num'' = `var'*``num''
					label variable ia_`var'_``num'' "`var' X ``num''"
				qui sum ia_`var'_``num'' if `var' == 1 & ``num'' == 1 & `touse'
				local ia_`var'_``num'' = r(N)
				local ialist `ialist' ia_`var'_``num''
			}
		}
		egen helpvar1 = rowmax($iavarlist1 $iavarlist2)		// mark reference cases (they have values < 0)
		qui sum helpvar1 if helpvar1 < 0 & `touse'
		local a = r(N)										// a = frequency in the cell omitted in both sets of dummies
		foreach ia in `ialist' {
			qui replace `ia' = ``ia''/`a' if helpvar1 < 0 & `touse'		// replace ia list for reference observations 
		}
		drop helpvar1
		foreach var in $iavarlist1 {
			foreach num of numlist 1/`nd' {
				qui sum ia_`var'_``num'' if ia_`var'_``num'' < 0 & ``num'' == 1 & `touse' 
					local b = r(N)
				qui replace ia_`var'_``num'' = - `ia_`var'_``num'''/`b' if ia_`var'_``num'' < 0 & ``num'' == 1 & `touse' 
				qui sum ia_`var'_``num'' if ia_`var'_``num'' < 0 & `var' == 1 & `touse'
					local c = r(N)
				qui replace ia_`var'_``num'' = - `ia_`var'_``num'''/`c' if ia_`var'_``num'' < 0 & `var' == 1 & `touse'
			}
		}		
	
	}
	


capture macro drop iavarlist1 iavarlist2
*capture drop helpvar1		// can this be deleted later?
_return restore user_r


end	
	

* Programme for Dummy Coding with or without chosen reference
{
capture program drop igen_d 
program define igen_d, sortpreserve
	syntax varname if, GENerate(name) [Omit(numlist max=1)]
	marksample touse
	dis ""	
	dis as text "Frequency table of `varlist':"
	tab `varlist' if `touse', gen(`generate')		// should this be done quietly later? or with an option to supress it
		local nc = r(r)
		dis ""
	
	if "`omit'" != ""	{		// omitting category if omit has been chosen
		qui levelsof `varlist' if `touse', local(l)
		tokenize `l'
		local i = 0
		while `i' < `nc' {
			local i = `i'+1
			if ``i'' == `omit'	{
				local omitpos = `i'
			}	
		}	
		
		* labeling the variables according to contrast
		local rlab: var l `generate'`omitpos'
		drop `generate'`omitpos'
		if `omitpos' == 1	{
			local varlistbegin = 2
		}
		else {
			local varlistbegin = 1
		}
		if `omitpos' == `nc'	{
			local varlistend = `nc'-1
		}
		else {
			local varlistend = `nc'
		}
		foreach var of varlist `generate'`varlistbegin'-`generate'`varlistend'	{	
			local lab: var l `var'
			label variable `var' "`lab' (vs `rlab')
		}
	}	
	
end	
}



* Program for effect coding
{ 
capture program drop igen_e
program define igen_e, sortpreserve
	syntax varname if, GENerate(name) Contrast(name) [Omit(numlist max=1) ia(numlist max=1)]
	marksample touse
	dis ""
	dis as text "Frequency table of `varlist':"
	tab `varlist' if `touse', gen(`generate')		// should this be done quietly later? or with an option to supress it
	local nc = r(r)
	dis ""
	if "`omit'" == "" {
		qui levelsof `varlist' if `touse', local(l)	 
		tokenize `l'
		local omit = `1'	
	}
	

	qui levelsof `varlist' if `touse', local(l)
	tokenize `l'
	local i = 0
	while `i' < `nc' {
		local i = `i'+1
		if ``i'' == `omit'	{
			local omitpos = `i'
		}	
	}	
	
	drop `generate'`omitpos'
	if `omitpos' == 1	{
		local varlistbegin = 2
	}
	else {
		local varlistbegin = 1
	}
	if `omitpos' == `nc'	{
		local varlistend = `nc'-1
	}
	else {
		local varlistend = `nc'
	}
	foreach var of varlist `generate'`varlistbegin'-`generate'`varlistend'	{
		qui replace `var' = -1 if `varlist' == `omit' & `touse'
		if "`contrast'" == "asobserved" {		// implement weighted effect coding
			qui sum `var' if `var' == 1 & `touse'	
			local a = r(N)
			qui sum `var' if `var' == -1 & `touse'
			local b = r(N)
			qui replace `var' = -`a'/`b' if `var' == -1 & `touse'
			local lab: var l `var'
			label variable `var' "`lab' (vs observed mean)"
			
				* Save list of new variables for later use for building interaction terms
				if "`ia'" == "1" {
					global iavarlist1 $iavarlist1 `var'
				}
				if "`ia'" == "2" {
					global iavarlist2 $iavarlist2 `var'
				}
		}
		else {
			local lab: var l `var'
			label variable `var' "`lab' (vs as balanced mean)"
		}
	}

end
}


* Program for adjacent and reversed adjacent coding
{
capture program drop igen_a
program define igen_a, sortpreserve
	syntax varname if, GENerate(name) Contrast(name)
	marksample touse
	dis ""
	dis as text "Frequency table of `varlist':"
	tab `varlist' if `touse', gen(`generate')		// should this be done quietly later? or with an option to supress it
	local nc = r(r)
	dis ""
	
		* Making a copy of each variable to read labels in later loop
		foreach var of varlist `generate'1-`generate'`nc'	{
		tempvar `var'_
		gen `var'_ = `var'
		local lab: var l `var'
		label var `var'_ "`lab'"
		}
			
	drop `generate'1
	qui levelsof `varlist', local(l)
	tokenize "`l'"
	local i = 0
	foreach var of varlist `generate'2-`generate'`nc' {
		local i = `i'+1
		qui replace `var' = (`nc'-`i')/`nc' if `varlist' <= ``i''
		qui replace `var' = -`i'/`nc' if `varlist' > ``i''
	}
	if "`contrast'" == "backward" {
		local i = 0
		foreach var of varlist `generate'2-`generate'`nc' {
			local i = `i'+1
			qui replace `var' = `var'*-1
			local lab: var l `var'
			local labc: var l `generate'`i'_
			label variable `var' "`lab' vs `labc'"
		}
	}
	if "`contrast'" == "forward" {
		local i = 0
		foreach var of varlist `generate'2-`generate'`nc' {
			local i = `i'+1
			local lab: var l `var'
			local labc: var l `generate'`i'_
			label variable `var' "`labc' vs `lab'"
		}
	}
	drop `generate'1_-`generate'`nc'_
	
end
}
	
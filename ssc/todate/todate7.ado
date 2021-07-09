*! name change from todate 8 Sept 2005 
*! 1.2.1 NJC 29 July 2003 
* 1.2.0 NJC 4 July 2001 
* 1.1.0 NJC 7 June 2001 
program define todate7 
	version 7.0 
	syntax varlist [if] [in], Pattern(string) Generate(string) /* 
	*/ [ Format(string) Cend(numlist int >200 <=10000 max=1) ]

	* existing and new varlists 
	tokenize `varlist' 
	local nvars : word count `varlist'

	* do before second -syntax- 
	marksample touse, novarlist 

	local 0 "`generate'"
	syntax newvarlist 
	local ngen : word count `varlist' 

	if "`nvars'" != "`ngen'" { 
		di as err "number of new variables not equal to" _c 
		di as err " number of existing variables" 
		exit 198 
	} 
	
	* partial test of format
	if "`format'" != "" { 
		capture display `format' 1 
		if _rc { 
			di as err "invalid format()" 
			exit 120 
		}
	} 

	* parse pattern into m d y h q w elements
	* indulge upper case
	local pattern = lower("`pattern'") 
	local plength = length("`pattern'") 

	forval i = 1 / `plength' { 
		local p = substr("`pattern'",`i',1) 
		if "`p'" == "m" { 
			local mlist "`mlist' `i'" 
		} 
		else if "`p'" == "d" { 
			local dlist "`dlist' `i'" 
		} 
		else if "`p'" == "y" { 
			local ylist "`ylist' `i'" 
		}	
		else if "`p'" == "h" { 
			local hlist "`hlist' `i'"
		}
		else if "`p'" == "q" { 
			local qlist "`qlist' `i'" 
		} 
		else if "`p'" == "w" { 
			local wlist "`wlist' `i'" 
		} 
		else { 
			di as err "invalid pattern" 
			exit 198
		} 
	} 	

	* allow mdy yh yq ym yw permutations
	foreach i in m d y h q w { 
		if "``i'list'" != "" { 
			local ptype "`ptype'`i'" 
			local pels  "`pels' `i'" 
		}
	} 	

	local badtype 1 
	foreach i in yh yq my yw mdy {
		if "`ptype'" == "`i'" { local badtype 0 } 
	}
        if `badtype' { 
		di as err "invalid pattern type: `ptype'" 
		exit 198 
	} 
	if "`ptype'" == "my" { local ptype "ym" } 		

	* contiguous digits will have range == # elements - 1 
	foreach i in `pels' {
		local `i'1 : word 1 of ``i'list' 
		local `i'len : word count ``i'list' 
		local last : word ``i'len' of ``i'list' 
		local range = `last' - ``i'1' 
		local range2 = ``i'len' - 1 
		if `range' != `range2' { 
			di as err "`i' digits not contiguous in pattern" 
			exit 198 
		}
	} 

	* year digits and cend() compatible?  
	if `ylen' != 4 & "`cend'" == "" { 
		di as err "`ylen' digit years: need cend() option?" 
		exit 198 
	} 
	else if `ylen' == 4 & "`cend'" != "" {  
		di as txt "4 digit years: cend() option ignored" 
		local cend 
	} 	
	
	* for each variable in original varlist
	qui forval i = 1 / `nvars' { 
		tempvar strdate datelen touse2 

		* markout separately for each variable 
		gen byte `touse2' = `touse' 
		markout `touse2' ``i'', strok 

		* working string variable copy of date variable 
		gen str1 `strdate' = "" 
		capture confirm string variable ``i'' 
		if _rc { 
			replace `strdate' = string(``i'',"%12.0g") if `touse2'  
		}
		else replace `strdate' = trim(``i'') if `touse2' 
		local v "``i''" 
		local `i' "`strdate'" 

		* how long is date variable? 
		gen `datelen' = length(``i'') 
		su `datelen' if `touse2', meanonly 
		local range = r(max) - r(min) 
		local min = r(min) 
		local max = r(max) 
		
		if `max' != `plength' { 
			noi di as res "`v': " /* 
			*/ as txt "length does not match pattern" 
			continue 
		} 
		
		* range == 0 is no problem 
		if `range' == 1 { /* leading zero needs to be supplied? */ 
			replace `strdate' = "0" + `strdate' /* 
				*/ if `datelen' == `min' & `touse2' 
		} 
		else if `range' >= 2 { /* range of lengths >= 2 => skip this */ 
			noi di as res "`v': " /* 
			*/ as txt "length too variable to handle" 
			continue 
		} 	
		
		* construct month, day, year, half, quarter, week as needed  
		foreach j in `pels' { 
			tempvar `j' 
			gen ``j'' = real(substr(``i'',``j'1',``j'len'))
		} 

		if "`cend'" != "" { 
			local c1 = int(`cend' / 100) 
			local c2 = mod(`cend',100) 
			replace `y' = /* 
			*/ `y' + 100 * cond(`y' <= `c2', `c1', `c1' - 1) 
		} 	

		* generate new variable 
		local newvar : word `i' of `varlist' 
		if "`ptype'" == "mdy" { 
			gen `newvar' = mdy(`m',`d',`y') if `touse2' 
		} 
		else { 
			local o = substr("`ptype'",2,1) 
			gen `newvar' = y`o'(`y',``o'') if `touse2' 
		} 	
		
		if "`format'" != "" { 
			format `format' `newvar' 
		} 	
		
		drop `touse2' 
	} 
end 


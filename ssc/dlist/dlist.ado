*! 1.5.2 NJC 16 May 2011
*! 1.5.1 NJC 4 Sept 2006
*! 1.5.0 NJC 9 Mar 2006
* 1.4.0 NJC 14 Feb 2006
* 1.3.0 NJC 8 Feb 2006
* 1.2.0 NJC 7 Feb 2006 
* 1.1.0 NJC 7 Feb 2006 
* 1.0.0 NJC 7 Feb 2006 
program dlist, byable(recall) 
	version 8.2  
	syntax [varlist] [if] [in] ///
	[, noLabel noObs Name(int 32) Varlabel(int 80) Spaces(int 3) noTRim ]
	
	marksample touse, novarlist 
	qui count if `touse' 
	if r(N) == 0 error 2000 

	// variable name width and variable label width 
	local nam = 0 
	local var = 0 
	foreach v of local varlist { 
		local nam = max(`nam', length("`v'")) 
		local var = max(`var', length(trim(`"`: variable label `v''"')))
	}	

	local nam = min(`name', `nam') 
	local var = min(`varlabel', `var') 
	
	// spaces is number of spaces between columns 
	local col2 = cond(`nam' == 0, 1, `nam' + `spaces' + 1) 
	local col3 = `col2' + cond(`var' == 0, 0, `var' + `spaces' + 1) 
	
	tempvar which 
	gen long `which' = _n 
	qui levels `which' if `touse', local(levels) 

	foreach l of local levels {
		if "`obs'" == "" di _n as txt "`l'."
		else di  
		foreach v of local varlist { 
			if "`label'" != "" | "`: value label `v''" == "" {
				capture confirm numeric variable `v' 
				if _rc == 0 { 
					local show : di `: format `v'' `= `v'[`l']' 
					local show = trim(`"`show'"') 
				}
				else { 
					local show : di `: format `v'' `"`= `v'[`l']'"' 
					if "`trim'" == "" local show = trim(`"`show'"') 
				}	
			}
			else { 
				local show `"`: label (`v') `=`v'[`l']''"'
			}	
				
			di as txt cond(`nam' > 0, abbrev("`v'", `nam'), "") ///
			"{col `col2'}" as txt ///
	cond(`var' > 0, substr(trim(`"`: var label `v''"'), 1, `var'), "") ///
			"{col `col3'}" as res "`show'"   
		}
	}
end 

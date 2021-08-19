*! 1.0.0 NJC 7 March 2021 
program countvalues 
	version 12
 
	syntax [varlist] [if] [in] ,  ///
    VALues(numlist int missingok) ///
	[                             ///           
	variablelabels                ///
    varlabels                     /// 
	sort(string)                  ///
	ROWSPOSitive                  ///
	COLSPOSitive                  ///
	SAVING(str asis)              ///
	SEParator(int 0) *            ///
	]  

	// numeric variables only 	
	quietly ds `varlist', has(type numeric) 
	local varlist `r(varlist)' 
	if "`varlist'" == "" { 
		di "no numeric variables specified" 
		exit 102 
	}

	// any data? 
	marksample touse, novarlist 
	quietly count if `touse'
	if r(N) == 0 error 2000 

	
	// initialize arrays 
	local nc : word count `values'
	tempname counts
	matrix `counts' = J(1, `nc', 0)
	mata : text = J(0, 2, "")
	mata : counts = J(0, `nc', 0) 
	  	
	// do counting 
	local i = 0 
	quietly foreach v of local varlist { 
		local ++i 
		local j = 0 

		local V : variable label `v' 
		if `"`V'"' == "" local V `v' 
		mata : text = text \ ("`v'", `"`V'"')    
		
		foreach x of local values {
			local ++j 
			count if `v' == `x' & `touse'
			matrix `counts'[1, `j'] = r(N)
		}
				
		mata : counts = counts \ st_matrix("`counts'") 
	}

	// select only variables with any positive count? 
	if "`rowspositive'" != "" {  
		mata: text = select(text, rowsum(counts) :> 0)  
		mata: counts = select(counts, rowsum(counts) :> 0) 

		// bail out gracefully if nothing to show 
		mata: st_local("nr", strofreal(rows(counts)))  
		if `nr' == 0 { 
			di "(no such data found)"
			exit 0 
		}   
	}

	// results as temporary dataset, except it can be saved 
	preserve
	drop _all 

	getmata which* = text  
	getmata counts* = counts

	char which1[varname] "name" 
	char which2[varname] "label"

	local toshow = cond("`variablelabels'`varlabels'" != "", 2, 1) 

	local j = 0 
	tokenize "`values'" 
	foreach v of var counts* {
		local ++j  
		char `v'[varname] "``j''"
		label var `v' "``j''"  
	}   

	quietly if "`colspositive'" != "" { 
		foreach v of var counts* { 
			su `v', meanonly 
			if r(sum) == 0 local todrop `todrop' `v' 
		}
		if "`todrop'" != "" drop `todrop'

		capture unab toshow : counts* 
		if "`toshow'" == "" { 
			noisily di "(no such data found)"
			exit 0 
		} 
	} 

    // sorting 
	// indulge upper case 
    // names or any abbreviation: sort on variable names 
    // labels or any abbreviation: sort on variable labels 
	// descending or any abbreviation: descending order 
	// any numeric value: sort on counts of that value 

	if "`sort'" != "" {
		local sort = lower("`sort'")  
		local command "sort " 

		foreach w in `sort' { 
			if "`w'" == substr("descending", 1, length("`w'")) { 
				local command "gsort -" 
				local sort : subinstr local sort "`w'" "" 
			} 

			if "`w'" == substr("labels", 1, length("`w'")) { 
				local tosort which2 
				local sort : subinstr local sort "`w'" "" 
			} 

			if "`w'" == substr("names", 1, length("`w'")) { 
				local tosort which1   
				local sort : subinstr local sort "`w'" "" 
			} 
		}
	} 

	// previous block zapped any "names" or "labels" or "descending" 
	// ignore any second or further elements 
	if trim("`sort'") != "" {
		local sort = real(word("`sort'", 1))  
		local j : list posof "`sort'" in values 
		if `j' == 0 { 
			di "sort(`sort') requested but `sort' not in values(`values')" 
			exit 498 
		}
		local tosort counts`j'  
	}  

	// descending alone: interpreted as work on first column of counts 
    if "`command'" != "" & "`tosort'" == "" { 
		unab counts : counts* 
		local tosort : word 1 of `counts'  
	}  
	// end of parse of sort() option 
  
	`command'`tosort' 

	list which`toshow' counts*, subvarname sep(`separator') noobs `options' 

	if `"`saving'"' != "" save `saving' 	
end 


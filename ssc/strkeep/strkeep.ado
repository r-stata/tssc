*! strkeep v1.1 RChu 05apr2017
program define strkeep
	version 14.0
	syntax varlist(min=1 str) [if] [in] ///
		[, GENerate(name) replace ///generate options
		Alpha LOWERcase UPPERcase Numeric keep(string) ///whitelist options
		STRLower STRUpper ///strlower() and strupper() options
		Sub(string)] //substitution option
	
	*Check generate options*
	if "`generate'"=="" & "`replace'"=="" { //No generate or replace specified
		di in red "strkeep: must specify {opt generate} or {opt replace}"
		error 197
	}
	if "`generate'"!="" & "`replace'"!="" { //Both generate and replace specified
		di in red "strkeep: {opt generate} and {opt replace} are mutually exclusive"
		error 184
	}
	if "`generate'"!="" { //If generate specified
		loc numofvars : list sizeof varlist		
		if `numofvars'==1 { //Only cleaning one variable
			capture conf v `generate'
			if !_rc {
				di in red "strkeep: variable {it:`generate'} already exists, either drop or choose new name"
				error 110
			}
		}
		else { //Cleaning multiple variables
			**Check to make sure stub length is not too long**
			if `=strlen("`generate'")+strlen("`numofvars'")'>32 {
				di in red "strkeep: stub {it:`generate'} too long for `numofvars' new variables"
				error 198
			}
			**Check if all variables for generate are non-existent**
			forv i=1/`numofvars' {
				capture conf v `generate'`i'
				if !_rc {
					di in red "strkeep: variable {it:`generate'`i'} already exists, either drop or choose new stub"
					error 110
				}
			}
		}
	}
	
	*Check strlower/strupper options*
	if "`strlower'"!="" & "`strupper'"!="" {
		di in red "strkeep: {opt strlower} and {opt strupper} may not be specified together"
		error 198
	}
	
	*Check sub option*
	if strlen(`"`sub'"')>1 {
		di in red "strkeep: {opt sub} must be at most one character in length"
		error 198
	}
	
	*Check whitelist options*
	if "`alpha'"=="" & "`lowercase'"=="" & "`uppercase'"=="" ///
		& "`numeric'"=="" & `"`keep'"'=="" { //Nothing to keep
		di in red "strkeep: must specify at least one whitelist option"
		error 197
	}
	
	*Define whitelist option values*
	loc wl_lowercase = "abcdefghijklmnopqrstuvwxyz"
	loc wl_uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	loc wl_alpha = "`wl_lowercase'`wl_uppercase'"
	loc wl_numeric = "0123456789"
	loc wl_keep = `"`keep'"'
	*Define whitelist*
	loc wl = `"`sub'"' //define whitelist, add any sub in
	foreach opt in alpha lowercase uppercase numeric keep {
		if `"``opt''"'!="" { //option specified
			loc wl = `"`wl'`wl_`opt''"' //add to whitelist
		}
	}
	
	*Process varlist*
	loc i = 1
	tempvar new
	tempvar index
	qui g `new' = ""
	qui g `index' = .
	foreach var of var `varlist' {
		qui replace `new' = `var' `if' `in'
		qui replace `index' = indexnot(`new',`"`wl'"')
		qui su `index'
		**Clean var -- the magic!**
		while r(max)!=0 {
			qui replace `new' = substr(`new',1,`index'-1)+`"`sub'"'+substr(`new',`index'+1,.) ///
				if `index'>0 //if need to clean
			qui replace `index' = indexnot(`new',`"`wl'"')
			qui su `index'
		}
		**Perform strlower() or strupper() on new string**
		if "`strlower'"!="" {
			qui replace `new' = strlower(`new')
		}
		if "`strupper'"!="" {
			qui replace `new' = strupper(`new')
		}
		**Save cleaned var**
		if "`generate'"!="" { //generate
			if `numofvars'==1 { //only one var in varlist
				g `generate' = `new'
			}
			else { //multiple vars in varlist
				g `generate'`i++' = `new'
			}
		}
		else { //must be replace
			replace `var' = `new' `if' `in'
		}
	}
	
end

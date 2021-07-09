*! svret 1.0.1 3apr2010 by Julian Reif

* 1.0.1: added backwards compatibility for Stata 8.2. Changed class option to type option

program define svret, nclass
	version 8.2
	syntax [namelist], [long type(name) keep(string) format(string)]
	
	***			
	* Error check the options
	***
	* 1) class (namelist)
	local num : word count `namelist'
	tokenize `namelist'
	forval x = 1/`num' {
		if !inlist("``x''","e","r","s","all") {
			di as error `"`namelist' is an invalid choice"'
			exit 198		
		}
	}
	
	* 2) type
	if !inlist("`type'","scalars","macros","all","") {
		di as error `"`type' is an invalid choice"'
		exit 198		
	}
	
	* 3) keep
	if "`keep'" != "" {
		foreach v of local keep {
			tokenize "`namelist'"
			if `"``v''"' == "" {
				di as error "`v' is not available"
				exit 198
			}
			else if ( "`namelist'"!="" & "`namelist'"!="all" & !inlist("`=substr("`v'",1,1)'","`1'","`2'","`3'","`4'") ) {
				di as error "`v' is a member of `=substr("`v'",1,1)'()"
				exit 198				
			}
		}
	}	

	* 4) format
	if "`format'" != "" { 
		if index("`format'", "s") { 
			di as err "use numeric format in format() option" 
			exit 198 
		} 	
		capture di `format' 12345.67890
		if _rc {
			di as err "format() option invalid"
			exit 198
		}
	}	
	
	****
	* Store the result
	****

	* Clear data
	drop _all
	label drop _all
	qui set obs 1
	
	* Specifying "all" or "" is same as specifiying "e r s"
	if "`namelist'" == "all" | "`namelist'" == "" local namelist "e r s"
	if "`type'" == "" local type "all"
	
	* Store returns
	foreach result in `namelist' {

		* Scalars
		if "`type'" == "all" | "`type'" == "scalars" {
			local scalar_vars : `result'(scalars)
			foreach v of local scalar_vars {
				qui gen `result'_`v' = ``result'(`v')'
				cap confirm integer number ``result'(`v')'
				if _rc!= 0 qui format `result'_`v' `format'
			}
		}

		* Macros
		if "`type'" == "all" | "`type'" == "macros" {		
			local macro_vars : `result'(macros)
			foreach v of local macro_vars {
				qui gen `result'_`v' = `"``result'(`v')'"'
			}
		}
	}

	* Compress data
	qui compress
	
	* Keep requested vars
	if "`keep'"!="" {
		tokenize `keep'
		while "`1'"!="" {
			local var : subinstr local 1 "(" "_"
			local var : subinstr local var ")" ""
			local keep : subinstr local keep "`1'" "`var'"
			macro shift
		}
		keep `keep'
	}
	
	* Reshape long if requested
	if "`long'"!="" {
		
		tempname id
		
		* Determine which variables need formatting (want ints to not have decimals)
		unab all_vars : *
		foreach v of local all_vars {
			local value = `v'[1]
			cap confirm integer number `value'
			if _rc!= 0 local float_vars "`float_vars' `v'" 
		}
		qui cap tostring `float_vars', force replace format(`format')
		if "`format'"!="" local format "%15.0fc"
		qui tostring *, force replace format(`format')
		
		* Do the reshaping
		qui gen `id' = 1
		foreach val in `namelist' {
			qui cap renpfix `val' A`val'
		}
		qui reshape long A, str i(`id') j(variable)
		drop `id'
		foreach val in e r s {
			qui replace variable = subinstr(variable,"`val'_","`val'(",1)
		}
		qui ren A contents
		qui replace variable = variable + ")"
	}
	
end

** EOF

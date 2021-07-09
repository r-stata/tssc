*! version 0.4 13Oct2013

program define partpred
	version 11.1
	syntax newvarname [if] [in] , FOR(varlist fv) [CONS AT(string) REF(string) LEVel(real `c(level)') ///
									CI(namelist min=2 max=2) SE(namelist max=1) EFORM EQ(name)] 
	marksample touse, novarlist

/* Error checks */
* variables in -for- included in model
* constant in model if constant specified

	fvexpand `for' if `touse'
	local forlist `r(varlist)'
	
	if "`eq'" == "" {
		local eq #1
	}
	
	_ms_extract_varlist `forlist', eq(`eq')
	if "`cons'" != "" {
		capture confirm number `:di [`eq'][_cons]'
		if _rc>0 {
			display as error "You have specified the cons option, but there is no constant in the model"
			exit 198
		}
	}
	
	local wordcount: word count `forlist'
	local lastvar: word `wordcount' of `forlist'
	
	
	if "`at'" != "" {
		tokenize `at'
		while "`1'"!="" {
			cap confirm var `2'
			if _rc {
				cap confirm num `2'
				if _rc {
					di in red "invalid at(... `1' `2' ...)"
					exit 198
				}
			}
			_ms_extract_varlist `1', eq(`eq')
			fvexpand `1'
			local 1 `r(varlist)'
			local 1 : subinstr local 1 "." "_", all 
			local 1 : subinstr local 1 "#" "_" , all
			local at_`1' `2'
			mac shift 2
		}
	}

	if "`ref'" != "" {
		tokenize `ref'
		while "`1'"!="" {
			cap confirm var `2'
			if _rc {
				cap confirm num `2'
				if _rc {
					di in red "invalid ref(... `1' `2' ...)"
					exit 198
				}
			}
			fvexpand `1'
			local 1 `r(varlist)'
			local 1 : subinstr local 1 "." "_" , all
			local 1 : subinstr local 1 "#" "_", all 
			local ref_`1' -`2'
			mac shift 2
		}
	}
	
	foreach var in `forlist' {
		local var2 : subinstr local var "." "_", all 
		local var2 : subinstr local var2 "#" "_", all 
		
		if "`at_`var2''" != "" {
			local predictnl_list `predictnl_list' [`eq'][`var']*(`at_`var2'' `ref_`var2'')
		}
		else {
			local predictnl_list `predictnl_list' [`eq'][`var']*(`var' `ref_`var2'') 
		}
		if "`var'" != "`lastvar'" {
			local predictnl_list `predictnl_list' +
		}
	}
	if "`cons'" != "" {
		local predictnl_list [`eq'][_cons] + `predictnl_list' 
	}

	if "`ci'" ! = "" {
		local ciopt ci(`ci')
	}	
	if "`se'" ! = "" {
		local seopt se(`se')
	}

	predictnl double `varlist' = `predictnl_list' if `touse', `ciopt' `seopt'
	
	if "`eform'" != "" {
		qui replace `varlist' = exp(`varlist')  if `touse'
		foreach var in `ci' {
			qui replace `var' = exp(`var')  if `touse'
		}
	}
end

*! 1.1.1 NJC 31 August 2017 
* 1.1.0 NJC 21 August 2017 
* 1.0.0 NJC 4 August 2017 
program extrdate 
	version 12 
	
	gettoken outtype 0 : 0 
	
	// indulge upper case 
	local outtype = lower("`outtype'") 
	
	local OK = 0 
	if inlist("`outtype'", "dow", "doy", "hh", "mm", "ss") {
		local OK = 1 
	}
	else if inlist("`outtype'", "day", "da") {
	    local outtype "day" 
		local OK = 1 
	}
	else if "`outtype'" == substr("halfyear", 1, max(2, length("`outtype'"))) { 
		local outtype "halfyear" 
		local OK = 1 
	}
	else if "`outtype'" == substr("month", 1, max(2, length("`outtype'"))) { 
		local outtype "month" 
		local OK = 1 
	}
	else { 
		foreach d in year quarter week {
			if "`outtype'" == substr("`d'", 1, length("`outtype'"))  { 
				local outtype "`d'"
				local OK = 1 
			}
		}
	}
	
	if `OK' == 0 { 
	    // predictable ambiguities
		if "`outtype'" == "d" { 
			di as err "must specify day, dow, or doy"
			exit 498
		}
		
		if "`outtype'" == "h" { 
			di as err "must specify ha[lfyear] or hh"
			exit 498
		}
		
		if "`outtype'" == "m" { 
			di as err "must specify mm or mo[nth]"
			exit 498
		}
		
		// other errors 
		di as err "`outtype' unrecognised kind of date-time" 
		exit 498 
	} 

	// newvar = 
	gettoken newvar 0 : 0, parse("= ")  
	confirm new var `newvar' 
	gettoken eqs 0 : 0, parse("= ") 
	if "`eqs'" != "=" { 
		di as err "invalid syntax" 
		exit 198
	} 

	/// rest of syntax
	syntax varname(numeric) [if] [in] , ///
	[Dryrun Format(str) varlabel(str)] 

	marksample touse 
	quietly count if `touse' 
	if r(N) == 0 error 2000 
	
    /// check that varlist has a date format 
	local informat : format `varlist' 
	local informat : subinstr local informat "%-" "%", all 
	
	local intype = substr("`informat'", 3, 1)
	if inlist("`outtype'", "hh", "mm", "ss") & !inlist("`intype'", "c", "C") {
		di as err "attempting to extract `outtype' from `informat' variable"
		exit 498
	}
		
	if "`intype'" == "C" local outtype "`outtype'C" 
	local oldvar "`varlist'" 

	/// dry run or for real 	
    if "`dryrun'" != "" { 
		Tryit `touse' `newvar' `oldvar' `intype' `outtype' `format'  
	} 
	else { 
		Doit `touse' `newvar' `oldvar' `intype' `outtype'  
		
	 	if "`varlabel'" == "" { 
			local varlabel : variable label `oldvar' 
			if `"`varlabel'"' == "" local varlabel `oldvar' 
		} 
        	label var `newvar' `"`outtype' from `varlabel'"' 

		if "`format'" != "" format `newvar' `format' 
	} 	
end 

program Tryit 
	args touse newvar oldvar intype outtype format 
	tempvar work toshow nmiss 

	quietly { 
		if inlist("`outtype'", "hh", "hhC", "mm", "mmC", "ss", "ssC") { 
			gen `work' = `outtype'(`oldvar') if `touse' 
		}
		else gen `work' = `outtype'(dof`intype'(`oldvar')) if `touse' 
		gen `toshow' = sum(`touse' & (`work' < .)) 
		gen `nmiss' = sum(`touse' & (`work' == .))  
	}

	local len = max(length("`: char `oldvar'[varname]'"), length("`newvar'")) 
	char `work'[varname] "`newvar'" 

	if "`format'" != "" format `work' `format'  
	list `oldvar' `work' if `touse' & `toshow' <= 5 & `nmiss' <= 20, ///
	subvarname abbrev(`len')

	di _n as txt "{p}note: " ///   
	"`newvar' is not yet a variable in your dataset{p_end}"  

	if `toshow'[_N] == 0 { 
		di _n as txt "{p}all values would be missing: " ///
		"check {stata help datetime}{p_end}" 
	} 
end 

program Doit 
	args touse newvar oldvar intype outtype 
	
	if inlist("`outtype'", "hh", "hhC", "mm", "mmC", "ss", "ssC") { 
			gen `newvar' = `outtype'(`oldvar') if `touse' 
	}
	else gen `newvar' = `outtype'(dof`intype'(`oldvar')) if `touse' 
	
	quietly compress `newvar' 
end 

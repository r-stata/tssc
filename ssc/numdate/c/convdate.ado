*! 1.2.1 NJC 31 August 2017 
* 1.2.0 NJC 17 August 2017 
* 1.1.0 NJC 3 August 2017 
* 1.0.0 NJC 1 August 2017 
program convdate 
	version 12 

	/// get and check wanted date-time type, zapping any hyphens or percents 
	gettoken outtype 0 : 0 
	local outtype : subinstr local outtype "-" "", all 
	local outtype : subinstr local outtype "%" "", all 

	/// -- allowed are any Stata abbreviations 	
	tokenize "tc tC td td tw tm tq th ty" 

	/// -- or (abbreviations of) any longer names 
	///    date() predated daily() 
	local T clock Clock daily date weekly monthly quarterly ///
	halfyearly yearly 

    /// fine to coarse means order out > order in 
    /// coarse to fine means order in > order out 
	local order 1 1 2 2 3 4 5 6 7 

	local OK = 0 

	forval t = 1/9 { 
		if "`outtype'" == "``t''" { 
			local out "`: word `t' of `T''" 
            local nout = `: word `t' of `order'' 
			local OK 1 
			continue, break 
		}
	} 

	if `OK' == 0 { 
		local len = length("`outtype'") 
		tokenize "`T'" 
		forval t = 1/9 {  
			if "`outtype'" == substr("``t''", 1, `len') { 
				local out "``t''" 
            	local nout = `: word `t' of `order'' 
				local OK 1 
				continue, break 
			}
		} 
	}

	if `OK' == 0 { 
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
	[last Format(str) Dryrun varlabel(str)] 

	marksample touse 
	quietly count if `touse' 
	if r(N) == 0 error 2000 
	
    /// if format requested check consistency with date type 
	/// else default format assigned 
	local t = substr("`out'", 1, 1)  
	if "`format'" != "" { 
		/// treat "%-" as if "%" 
		local Format : subinstr local format "%-" "%" 
		if substr("`Format'", 3, 1) != "`t'" { 
			di as err "`format' format does not match `out'" 
			exit 498 
		}
	} 
	else local format %t`t'
	
	/// check that varlist has a date format 
	local informat : format `varlist' 
	local informat : subinstr local informat "%-" "%", all 
	
	local intype = substr("`informat'", 2, 1) 
	if "`intype'" != "t" { 
		di as err "`informat' format does not make date type explicit" 
		exit 498 
	}

	tokenize "c C d d w m q h y" 
    forval t = 1/9 { 
		if substr("`informat'", 3, 1) == "``t''" { 
			local nin = `: word `t' of `order'' 
			continue, break 
		}
	}
	if "`nin'" == "" { 
		di as err "puzzling existing format `informat'?" 
		exit 498 
	}

	if `nout' > `nin' & "`last'" != "" { 
		di as err "{p}warning: " /// 
		          "last option irrelevant as converting fine to coarse{p_end}" 
		/// blank it out 
		local last 	
	} 
			
	local intype = substr("`informat'", 3, 1)
	local oldvar "`varlist'" 
	local last = "`last'" != "" 

	/// dry run or for real 	
    if "`dryrun'" != "" { 
		Tryit `touse' `newvar' `oldvar' `intype' `out' `format' `last' 
	} 
	else { 
		Doit `touse' `newvar' `oldvar' `intype' `out' `format' `last' 
		
		if "`varlabel'" == "" { 
			local varlabel : variable label `oldvar' 
			if `"`varlabel'"' == "" local varlabel `oldvar' 

			if `last' local text "last "            
			label var `newvar' `"`text'`out' date from `varlabel'"' 
		} 
		else label var `newvar' `"`varlabel'"'
	} 	
end 

program Tryit 
	args touse newvar oldvar intype out format last 
	tempvar work toshow nmiss 

	if inlist("`out'", "clock", "Clock") { 
		local vtype "double" 
	} 
	local out = substr("`out'", 1, 1) 
	quietly { 
		gen `vtype' `work' = cond(`last', `oldvar' + 1, `oldvar')  
		replace `work' = `out'ofd(dof`intype'(`work')) if `touse' 
		if `last' replace `work' = `work' - 1 

		gen `toshow' = sum(`touse' & (`work' < .)) 
		gen `nmiss' = sum(`touse' & (`work' == .))  
	}

	format `work' `format' 
	local len = max(length("`: char `oldvar'[varname]'"), length("`newvar'")) 
	char `work'[varname] "`newvar'" 

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
	args touse newvar oldvar intype out format last 
	
	if inlist("`out'", "clock", "Clock") { 
		local vtype "double" 
	} 
	local out = substr("`out'", 1, 1) 

	quietly { 
		gen `vtype' `newvar' = cond(`last', `oldvar' + 1, `oldvar') if `touse' 
		replace `newvar' = `out'ofd(dof`intype'(`newvar')) if `touse'  
		if `last' replace `newvar' = `newvar' - 1 

		if "`out'" == "" compress `newvar' 
	} 

	format `newvar' `format' 
end 

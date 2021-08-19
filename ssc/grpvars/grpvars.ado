*! version 1.3.1  13jul2021	 Gorkem Aksaray <gaksaray@ku.edu.tr>

capture program drop grpvars
program grpvars
	version 12
	
	#delimit ;
	syntax
		[anything(name=arguments id="arguments")]
		[,
		name(namelist local)
		Title(string) Prefix(string) Suffix(string)
		latex tex html ITalic Bold EMspace(numlist min=1 max=1)
		]
	;
	
	gettoken 1 0: arguments
	;
	
	local fnlist	`"
					"add",
					"remove",
					"replace",
					"list",
					"drop",
					"clear",
					"dir"
					"'
	;
	#delimit cr
	
	if inlist("`1'", `fnlist') {
		local fn `1'
		local varlist `0'
	}
	else if "`1'" != "" {
		local fn make
		local varlist `arguments'
	}
	else {
		noi di as err "varlist required"
		exit 100
	}
	local Fn = strproper("`fn'")
	
	// open group(s)
	if "`name'" != "" {
		local grouplist `name'
	}
	else if "$vargroups" != "" {
		local grouplist $vargroups
	}
	
	// collect pre-edit group properties
	foreach group of local grouplist {
		local prevarcount_`group' = wordcount("${`group'}")
		local prefirstvar_`group' = word("${`group'}", 1)
	}
	
	// make or edit group(s)
	if "`fn'" == "make" {
		_groupMake `varlist', name(`name')
		_groupList, name(`name')
	}
	if inlist("`fn'", "add", "remove", "replace") {
		if "`name'" != "" {
			_group`Fn' `varlist', name(`name')
			_groupList, name(`name')
		}
		else {
			_group`Fn' `varlist'
			_groupList
		}
	}
	if "`fn'" == "list" {
		if "`varlist'" != "" {
			noi di as err "varlist not allowed"
			exit 101
		}
		if "`name'" != "" {
			_groupList, name(`name')
		}
		else {
			_groupList
		}
		exit
	}
	if "`fn'" == "drop" {
		if "`varlist'" != "" {
			noi di as err "varlist not allowed"
			exit 101
		}
		if "`name'" != "" {
			_groupDrop, name(`name')
		}
		else {
			_groupClear
			exit
		}
	}
	if "`fn'" == "clear" {
		if "`varlist'" != "" {
			noi di as err "varlist not allowed"
			exit 101
		}
		if "`name'" != "" {
			noi di as err "option {bf:name} not allowed"
			exit 198
		}
		_groupClear
		exit
	}
	if "`fn'" == "dir" {
		if "`varlist'" != "" {
			noi di as err "varlist not allowed"
			exit 101
		}
		if "`name'" != "" {
			noi di as err "option {bf:name} not allowed"
			exit 198
		}
		_groupDir
		exit
	}
	
	// update group(s)
	foreach group of local grouplist {
		
		// collect post-edit group properties
		local postvarcount = wordcount("${`group'}")
		local postfirstvar = word("${`group'}", 1)
		
		*if post-edit group is empty;
		if `postvarcount' == 0 {
			
			// drop group
			macro drop `group'
			
			// remove group from group list
			global vargroups = trim(stritrim(subinword("$vargroups", "`group'", "", .)))
			
			// remove group from reference categories
			global refcat = trim(stritrim(regexr(`"$refcat"', `"`prefirstvar_`group'' ["][^"]+["]"', "")))
		}
		
		* if post-edit group if not empty;
		else if `postvarcount' > 0 {
			
			// add group to group list
			if "$vargroups" == "" {
				global vargroups `group'
			}
			else {
				if trim(subinword("$vargroups", "`group'", "", .)) == trim("$vargroups") {
					global vargroups $vargroups `group'
				}
			}
			
			// add group to reference categories
			if "`title'" != "" {
				_makePrefixSuffix, `tex' `latex' `html' `italic' `bold' emspace(`emspace')
				local reftitle `postfirstvar' "`r(prefix)'`prefix'`title'`suffix'`r(suffix)'"
				
				* if new group;
				if "`prefirstvar_`group''" == "" {
					local refcat $refcat `reftitle'
				}
				
				* if existing group;
				if "`prefirstvar_`group''" != "" {
                    if `"$refcat"' != "" {
                        local refcat = regexr(`"$refcat"', `"`prefirstvar_`group'' ["][^"]+["]"', `"`reftitle'"')
                    }
                    else {
                        local refcat $refcat `reftitle'
                    }
				}
			}
			else if "`title'" == "" {
				
				* if new group;
				if "`prefirstvar_`group''" == "" {
					local refcat $refcat
				}
				
				* if existing group;
				if "`prefirstvar_`group''" != "" {
					local refcat = subinword(`"$refcat"', "`prefirstvar_`group''", "`postfirstvar'", .)
				}
			}
			global refcat = trim(stritrim(`"`refcat'"'))
		}
		*macro list `group'
	}
	
	*macro list vargroups
	*macro list refcat
end

capture program drop _groupMake
program _groupMake
	syntax varlist(min=1 fv ts), name(name local)
	
	global `name' `varlist'
end

capture program drop _groupAdd
program _groupAdd
	syntax varlist(min=1 fv ts) [, name(namelist local)]
	
	if "`name'" != "" {
		local grouplist `name'
	}
	else {
		local grouplist ${vargroups}
	}
	
	foreach group of local grouplist {
		_checkifGroupExists `group', break
		foreach var of local varlist {
			if strpos("${`group'}", "`var'") != 0 {
				di as err "variable {bf:`var'} is already in group {bf:`group'}"
				continue
			}
			global `group' ${`group'} `var'
		}
	}
end

capture program drop _groupRemove
program _groupRemove
	syntax varlist(min=1 fv ts) [, name(namelist local)]
	
	if "`name'" != "" {
		local grouplist `name'
	}
	else {
		local grouplist ${vargroups}
	}
	
	foreach group of local grouplist {
		_checkifGroupExists `group', break
		foreach var of local varlist {
			if "${`group'}" == subinword("${`group'}", "`var'", "", .) {
				di as err "variable {bf:`var'} not found in group {bf:`group'}"
			}
			else {
				global `group' = trim(stritrim(subinword("${`group'}", "`var'", "", .)))
			}
		}
	}
end

capture program drop _groupReplace
program _groupReplace
	syntax anything [, name(namelist local)]
	
	gettoken 1 2 : anything, match(parns) bind
	
	_getVarlist `1'
	local replacedvars = r(varlist)
	_getVarlist `2'
	local addedvars	   = r(varlist)
	
	if "`addedvars'" == "" {
		error 102
		exit 102
	}
	
	if "`name'" != "" {
		local grouplist `name'
	}
	else {
		local grouplist ${vargroups}
	}
	
	qui _groupList, name(`grouplist')
	if "`r(varlist)'" == subinword("`r(varlist)'", "`replacedvars'", "", .) {
		di as err "variable(s) {bf:`replacedvars'} not found in group(s)"
		exit 198
	}
	
	foreach group of local grouplist {
		_checkifGroupExists `group', break
		if "${`group'}" == subinword("${`group'}", "`replacedvars'", "", .) {
			if "`name'" != "" {
				di as err "variable(s) {bf:`replacedvars'} not found in group {bf:`group'}"
			}
		}
		else {
			foreach var of local addedvars {
				if "`replacedvars'" != subinword("`replacedvars'", "`var'", "", .) {
					continue
				}
				if "${`group'}" != subinword("${`group'}", "`var'", "", .) {
					di as txt "(note: variable {bf:`var'} is already in group {bf:`group'})"
					global `group' = trim(stritrim(subinword("${`group'}", "`var'", "", .)))
					continue
				}
			}
			global `group' = trim(stritrim(subinword("${`group'}", "`replacedvars'", "`addedvars'", .)))
		}
	}
end

capture program drop _groupList
program _groupList, rclass
	syntax [, name(namelist local)]
	
	if "`name'" != "" {
		local grouplist `name'
	}
	else {
		local grouplist ${vargroups}
	}
	
	local varlist
	foreach group of local grouplist {
		_checkifGroupExists `group', break
		macro list `group'
		local varlist `varlist' ${`group'}
	}
	
	return local varlist `varlist'
	return scalar k = wordcount("`varlist'")
end

capture program drop _groupDrop
program _groupDrop
	syntax, name(namelist local)
	
	local grouplist `name'
	
	foreach group of local grouplist {
		_checkifGroupExists `group', break
		global `group'
	}
end

capture program drop _groupClear
program _groupClear
	
	foreach group of global vargroups {
		macro drop `group'
	}
	macro drop vargroups
	macro drop refcat
end

capture program drop _groupDir
program _groupDir
	
	if "$vargroups" != "" {
		macro list vargroups
	}
	if `"$refcat"' != "" {
		macro list refcat
	}
end

capture program drop _checkifGroupExists
program _checkifGroupExists
	syntax name(name=group id="group"), break
	
	if "${`group'}" == "" {
		noi di as err "variable group {bf:`group'} not found"
		if "`break'" != "" {
			exit 111
		}
	}
end

capture program drop _makePrefixSuffix
program _makePrefixSuffix, rclass
	syntax [, tex latex html ITalic Bold EMspace(numlist min=1 max=1)]
	
	local prefix
	local suffix
	
	// tex mode
	if ("`tex'" != "" | "`latex'" != "") {
		if "`italic'" != "" {
			local prefix \textit{`prefix'
			local suffix `suffix'}
		}
		if "`bold'" != "" {
			local prefix \textbf{`prefix'
			local suffix `suffix'}
		}
		if "`emspace'" != "" {
			local prefix \hspace{`emspace'em}`prefix'
		}
	}
	
	return local prefix "`prefix'"
	return local suffix "`suffix'"
end

capture program drop _getVarlist
program _getVarlist, rclass
	syntax varlist(min=1 fv ts)
	return local varlist "`varlist'"
end
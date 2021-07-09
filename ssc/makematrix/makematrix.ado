*! NJC 2.0.4 8 June 2006 
*! NJC 2.0.3 14 November 2005 
*! NJC 2.0.2 21 November 2004 
*! NJC 2.0.1 29 August 2003 
*! NJC 2.0.0 27 August 2003 
* matrixof NJC 1.0.1 30 October 2002
* matrixof NJC 1.0.0 26 October 2002
program makematrix
	version 8 
	
	gettoken 0 second : 0, parse(":")
	gettoken colon second : second, parse(":") 
	if `"`second'"' == "" error 198 

	// first part
	// attempt to work-around bizarre bugs arising from spaces
	// in command line 
	tokenize `"`0'"'
	local 0 "`*'" 
        syntax [name(name=matname)] , from(str) ///
	[ cols(varlist) lhs(varlist) rhs(varlist) vector ///
	listwise list LAbel noHeader Format(str) dp(numlist int >=0) ///
	RIGHTjustify * ] 

	local nopts = ("`cols'" != "") + ("`lhs'" != "") + ///
	              ("`rhs'" != "") + ("`vector'" != "") 
	if `nopts' > 1 { 
		di as err "must choose one of cols(), lhs(), rhs(), vector" 
		exit 198 
	} 	

	local nfrom : word count `from'
	local ncols : word count `cols' 
	
	if `nfrom' > 1 & `ncols' > 1 { 
		di as err "choose between multiple from() and multiple cols()"
		exit 198 
	}

	local nformat : word count `format' 
	if `nformat' > 1 { 
		if "`list'" == "" { 
			di as err "multiple formats require list option"
			exit 198 
		} 	
		if `nformat' != `nfrom' { 
			di as err "multiple formats require multiple from()"
			exit 198 
		}
	} 

	if "`format'" != "" & "`dp'" != "" { 
		di as err "choose between format() and dp()" 
		exit 198 
	} 
	
	local ndp : word count `dp' 
	if `ndp' > 1 { 
		if "`list'" == "" { 
			di as err "multiple decimal places require list option"
			exit 198 
		} 	
		if `ndp' != `nfrom' { 
			di as err "multiple decimal places require multiple from()"
			exit 198 
		}
	} 

	if "`dp'" != "" { 
		foreach d of local dp { 
			local w = `d' + 1 
			local format "`format'%`w'.`d'f "
		} 
		local nformat = `ndp' 
	} 	

	if `: word count `options'' { 
		local listopts `options'
	} 	
	
	if "`matname'" == "" { 
		tempname matname 
		local header "noheader" 
	} 
	
	// second part 
	gettoken cmd 0 : second 
	syntax [varlist(ts)] [if] [in] [aweight fweight iweight pweight] [ , * ] 
	
	if "`listwise'" != "" marksample touse, novarlist 
	else { 
		marksample touse, strok 
		if "`cols'" != "" markout `touse' `cols' 
	} 	

	qui count if `touse' 
	if r(N) == 0 error 2000 

	// some commands don't allow a bare comma with no options 
	if `"`options'"' != "" local options `", `options'"' 
	
	// prepare matrix 
	if "`lhs'`rhs'" != "" local rows "`lhs'`rhs'"
	else local rows "`varlist'"
	local nvars : word count `rows'

	if "`cols'" == "" & `nfrom' == 1 {
		if "`vector'" == "" { 
			local cols "`varlist'" 
			local ncols : word count `cols'
		}
	} 	
	else if "`lhs'`rhs'" != "" { 
		local cols "`varlist'" 
	}
	
	local ncols = max(`ncols', `nfrom')
	mat `matname' = J(`nvars',`ncols',.) 
	
	tokenize "`from'" 
	forval j = 1/`nfrom' {
		// if it doesn't contain "(" or "_" then it must be a global
		// includes "e("   : result will be 2 
		// includes "r("   : result will be 2
		// includes "_b"  : result will be 3
		// includes "_se" : result will be 3 
		// global          : result will be 1 
		local g`j' = 1 + ///
		             (index("``j''", "r(") > 0) + ///
		             (index("``j''", "e(") > 0) + ///
			     2 * (index("``j''", "_b") == 1) + ///  
			     2 * (index("``j''", "_se") == 1) 
		local G`j' = substr("$",`g`j'',1) 
	} 	

	// populate matrix 
	local i = 0 
	if `nfrom' > 1 | "`vector'`lhs'`rhs'" != "" { 
		if "`lhs'" != "" | "`rhs'" == "" { 
			foreach v of var `rows' { 
				local ++i
				qui `cmd' `v' `cols' [`weight' `exp'] /// 
					if `touse' `options'  
				forval j = 1 / `ncols' { 
					if "``j''" == "_b" | "``j''" == "_se" { 
						local eval "``j''[`v']" 	
					} 	
					else local eval "`G`j''``j''"
					cap mat `matname'[`i',`j'] = `eval'
				}
			}
		} 	
		else { 	
			foreach v of var `rows' { 
				local ++i
				qui `cmd' `cols' `v' [`weight' `exp'] /// 
					if `touse' `options' 
				forval j = 1 / `ncols' { 
					if "``j''" == "_b" | "``j''" == "_se" {
						local eval "``j''[`v']" 	
					} 	
					else local eval "`G`j''``j''" 
					cap mat `matname'[`i',`j'] = `eval'
				}
			}	
		} 	
	} 	
	else { 
		foreach v of var `rows' { 
			local ++i 
			forval j = 1 / `ncols' { 
				local vj : word `j' of `cols' 
				qui `cmd' `vj' `v' [`weight' `exp'] ///
					if `touse' `options' 
				if "`1'" == "_b" | "`1'" == "_se" { 
					local eval "`1'[`v']" 
				} 	
				else local eval "`G1'`1'" 
				cap mat `matname'[`i',`j'] = `eval'
			}
		} 
	}	

	// matrix margins 
	// attempt to substitute variable labels by variable names
	if "`label'" != "" {
		if "`list'" == "" {
			// periods not allowed unless in time-series operators 
			tempname tempmat 
			mat `tempmat' = J(1,1,1) 
			foreach v of local rows { 
				cap local label : variable label `v' 
				local length = length(trim(`"`label'"')) 
				cap matrix rowname `tempmat' = `label'
				if _rc /// 
				local label : subinstr local label "." "", all
				if `length' <= 32 & `length' > 0 {
					local label = trim(`"`label'"') 
					local Rows `"`Rows' `"`label'"'"' 
				} 
				else local Rows `"`Rows' `v'"'
			} 
		} 	
		else { 
			foreach v of local rows { 
				cap local label : variable label `v' 
				if _rc local label "`v'" 
				local Rows `"`Rows' `"`label'"'"' 
			} 
		} 	
	} 
	else local Rows "`rows'" 
	
	// strip "r(" ")" or "e(" ")"  
	// don't strip "_" from "_b" or "_se"   
	if `nfrom' > 1 | "`vector'`lhs'`rhs'" != "" { 
		forval j = 1/`nfrom' { 
			if `g`j'' == 2 { 
				local `j' : ///
				subinstr local `j' "r(" "", count(local rcount)  
				local `j' : ///
				subinstr local `j' "e(" "", count(local ecount)  
				if `rcount' | `ecount' { 
					local `j' : subinstr local `j' ")" ""
				}	
			}
		}
		local from "`*'" 
	} 	
	
	if `nfrom' > 1 | "`vector'`lhs'`rhs'" != "" local colnames "`from'"
	else local colnames "`cols'" 
	capture mat colnames `matname' = `colnames'

	// EITHER matrix list and exit  
	if "`list'" == "" {
		mat rownames `matname' = `Rows'
		if "`format'" != "" local format "format(`format')" 
		matrix li `matname', `header' `format' `listopts'

		exit 0 
	} 

	// OR list and exit 
	tokenize `colnames' 
	qui forval j = 1/`ncols' { 
		tempvar list`j'
		gen double `list`j'' = . 
		char `list`j''[varname] "``j''" 
		forval i = 1/`nvars' { 
			replace `list`j'' = `matname'[`i',`j'] in `i' 
		}
		local mylist "`mylist'`list`j'' " 
	} 

	if `nformat' > 1 { 
		forval j = 1/`ncols' { 
			format `list`j'' `: word `j' of `format'' 
		}
	} 
	else if `nformat' == 1 format `mylist' `format' 

	tempvar list0 
	qui { 
		gen `list0' = ""
		forval i = 1/`nvars' {
			local Row : word `i' of `Rows' 
			replace `list0' = trim(`"`Row'"') in `i' 
		}
		if "`rightjustify'" == "" { 
			local len = substr("`: type `list0''",4,.) 
			format `list0' %-`len's 
		} 	
		char `list0'[varname] " " 
	} 

	list `list0' `mylist' in 1/`nvars', noobs subvarname `listopts'
end


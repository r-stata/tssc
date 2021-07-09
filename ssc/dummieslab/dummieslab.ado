*! PVK/NJC 1.2.1 30 Aug 2010 //add novarlabel option
* PVK/NJC 1.2.0 19 Sept 2004
* PVK/NJC 1.1.0 13 Sept 2004
* NJC suggestions 10 Sept 2004 
* PVK 1.0 24 Oct 2003

program dummieslab, rclass
	version 8.0
	syntax varname(numeric) [if] [in], ///
	[ from(str asis) to(str asis) ///
	Word(numlist int max=1) Template(str) Truncate(int 0) noVARLABel ] 

	marksample touse
	qui count if `touse'
	if r(N) == 0 error 2000

	if `"`from'`to'"' != "" { 
		if `"`from'"' != ""  & `"`to'"' == "" { 
			di as err "from(), but no to()" 
			exit 198 
		} 
		else if `"`to'"' != "" & `"`from'"' == "" { 
			di as err "to(), but no from()" 
			exit 198 
		} 
		else { 
			local nf : word count `from' 
			local nt : word count `to' 
			if `nf' != `nt' { 
				di as err `"`from' does not match `to'"' 
				exit 198 
			} 
			forval i = 1/`nf' { 
				local from`i' : word `i' of `from' 
				local to`i' : word `i' of `to' 
			}	
			local fromto 1 
		}
	}
	else local fromto 0 

	local haslab : value label `varlist' 
	if "`haslab'" == "" di "{txt:note: }{res:`varlist'}{txt: not labelled}"

	// check -template()- 
	if "`template'" != "" { 
		if !index("`template'", "@") { 
			di as err "template() does not contain @" 
			exit 198 
		}
	}

	qui levels `varlist' if `touse' , loc(levels)

	// LOOP 1: grab labels and create list of new varnames 
	// (exit if problem with varname)
	foreach val of local levels {
		local name : label (`varlist') `val' 
		
		if `"`haslab'"' != "" {
			if "`word'" != "" local name = word(`"`name'"',`word')
			if `fromto' { 
				forval i = 1/`nf' { 
					local name : ///
					subinstr local name `"`from`i''"' `"`to`i''"', all
				} 
			} 	
		}	
		else local name "`varlist'_`val'" 

		local name2 
		forval i = 1/`: length local name' { 
			local ci = substr(`"`name'"',`i',1) 
			if inrange(`"`ci'"',"a","z") | ///
				inrange(`"`ci'"',"A","Z") | ///
				inrange(`"`ci'"',"0","9") | ///
				`"`ci'"' == "_" {   
					local name2 "`name2'`ci'"    
			} 
		} 	
		local name "`name2'" 
			
	        if `truncate' local name = substr("`name'",1,`truncate')

		if "`template'" != "" { 
	      		local name : subinstr local template "@" "`name'", all
		} 	

		confirm new var `name' 
		local names "`names' `name'" 
       	}	

	// check for duplicates
	if "`: list dups local names'" != "" { 
       		di as err "implied variable names contain duplicates"
		exit 498 
	} 	

	// LOOP 2: create new variables 
	local i = 1 
	foreach val of local levels { 
    local name : word `i++' of `names' 
		qui gen byte `name' = `varlist' == `val' if `touse'
		if ("`varlabel'"=="")  label var `name' "`varlist'==`val'"  
	
	} 

	return local names "`names'"
	return local from "`varlist'"  
end


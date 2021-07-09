*! NJC 1.0.1 13 May 2011 
*! NJC 1.0.0 12 May 2011 
program labvalcombine 
	version 8
	gettoken names 0 : 0 , parse(,) 
	syntax [, lblname(str)] 

	foreach name of local names { 
		capture label list `name' 
		if _rc { 
			di as err "value label `name' not found"
			exit _rc 
		}
	}	 

	if `: word count `names'' == 1 { 
		di as err "nothing to do: only one set named"
		// not necessarily an error 
		exit 0 
	} 

	tempfile dofile1 dofile2  
	tempname in out 
	qui label save `names' using `"`dofile1'"' 
	file open `in' using `"`dofile1'"', r
	file open `out' using `"`dofile2'"', w

	file read `in' line
	tokenize `"`line'"'  
	if "`lblname'" == "" local lblname `3' 

	local cmd "label define `lblname'"  
	
	while r(eof) == 0 {
		local line : subinstr local line "`1' `2' `3'" "`cmd'" 
		file write `out' `"`line'"' _n
		file read `in' line
		tokenize `"`line'"'  
	}
	file close `out'
	
	qui do `"`dofile2'"'   
	label list `lblname' 
end 

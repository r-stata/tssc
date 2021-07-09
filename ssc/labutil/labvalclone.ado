*! NJC 1.1.2 22 Nov 2013 
* NJC 1.1.1 3 Nov 2002 
* NJC 1.1.0 1 Nov 2002 
program def labvalclone
	version 7 
	args old new garbage 
	if "`old'" == "" | "`new'" == "" | "`garbage'" != "" { 
		di as err "syntax is: " /* 
		*/ as txt "labvalclone {it:vallblname newvallblname}" 
		exit 198 
	} 
	if "`old'" == "label" | "`old'" == "define" { 
		di as err "won't work if {txt:`old'} is existing value label name" 
		exit 198 
	}	
	capture label list `new' 
	if _rc == 0 { 
		di as err "value labels {txt:`new'} already exist" 
		exit 198
	} 
	
	tempfile file1 file2
	tempname in out 

	qui label save `old' using `"`file1'"' 
	file open `in' using `"`file1'"', r
	file open `out' using `"`file2'"', w
	file read `in' line
	
	* previously "`old'" "`new'", but this was matched whenever the 
	* value label name was a substring of "label" or "define" 
	while r(eof) == 0 {
		local line: subinstr local line " `old' " " `new' "
		file write `out' `"`line'"' _n
		file read `in' line
	}
	file close `out'
	
	qui do `"`file2'"'   
end 

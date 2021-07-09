*! renamed NJC 19 July 2007 
*! NJC 1.1.3 20 July 2004 
* NJC 1.1.2 15 July 2004 
* NJC 1.1.1 15 July 2004 
* NJC 1.1.0 15 July 2004 
* NJC 1.0.0 14 July 2004 
program examples8 
	version 8.2 
	syntax anything(name=cmd) 

	// syntax processing 
	tokenize `cmd' 
	local cmd "`*'" 
	
	// special code for e.g. -examples log()- 
	if index("`cmd'", "()") { 
		local CMD : subinstr local cmd "()" "", all 
		cap findfile  f_`CMD'.ihlp 
		if "`r(fn)'" == "" { 
			di "{txt:help for {bf:{cmd:`cmd'}} not found}"   
			di "{txt:try {stata help functions} or {stata whelp functions}}"  
			exit 0 
		} 
		else { 
			di 
			type "`r(fn)'", smcl 
			exit 0 
		} 	
	} 	
	
	local CMD : subinstr local cmd " " "_", all 

	// will exit if nothing found 
	find_hlp_file `CMD'

	cap findfile "`r(result)'.hlp"
	
	if "`r(fn)'" == "" { 
		di "{txt:help for {bf:{cmd:`cmd'}} not found}"   
		di "{txt:try {stata help contents} or {stata search `cmd'}}"  
		exit 0 
	} 

	// filenames and handles 
	tempname hi ho 
	tempfile file 
	
	// line-by-line processing 
	file open `hi' using "`r(fn)'", r
	file open `ho' using "`file'", w 
	file read `hi' line
	local OK 0 
	local found 0 
	local prevblank 0 
	
	while r(eof) == 0 {
		if index(`"`macval(line)'"', "{title") > 0  { 
			local OK = index(`"`macval(line)'"', "Example") > 0 
			if `OK' local found 1 
		} 
		if `OK' {
			local blank = trim(`"`macval(line)'"') == ""  
			if !`blank' | (`blank' & !`prevblank') { 
				file write `ho' `"`macval(line)'"' _n
			} 	
			local prevblank = `blank' 
		} 
		file read `hi' line
	}
	
	file close `ho'
	if `found' { 
		di as txt " " 
		type "`file'", smcl 
	} 	
end



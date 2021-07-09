*! NJC 1.0.0 27 July 2007 
program filei    
	version 8.2 

 	// syntax can be 
	// + <text> <filename>   create or append 
	// - <text> <filename>   prepend 

	tokenize `"`0'"' 
	if `"`2'"' == "" | `"`4'"' != "" error 198 

	if `"`1'"' == "+" { 
		capture confirm file "`3'"
		local exists = _rc == 0 
		local file "`3'" 
	} 
	else if `"`1'"' == "-" { 
		confirm file "`3'"  
		local file "`3'" 
		local exists 1 
	} 
	else error 198  
		
	tempname ho hi 

	if !`exists' { 
		file open `ho' using "`file'", w 
		file write `ho' `"`2'"' _n
		file close `ho' 
		exit 0                   
	} 
	else {
		if "`1'" == "+" {  
			file open `ho' using "`file'", w append 
			file write `ho' `"`2'"' _n 
			exit 0     
		}                    
		else { 
			tempfile work 
			file open `ho' using `work', w 
			file write `ho' `"`2'"' _n 
			file open `hi' using "`file'", r 
			file read `hi' line 

			while r(eof) == 0  { 
				file write `ho' `"`macval(line)'"' _n 
				file read `hi' line 
			} 
			
			file close _all
			copy `work' "`file'", replace 
		}
	}
end


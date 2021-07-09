  
prog define diagramconnection
	
	version 11
	syntax [using/] , tempfile(str) sign(str) [indent(str)]
	
	
	tempname knot
	file open `knot' using "`tempfile'", write append
	
	//check for string variable type
	cap confirm string variable from
	if _rc == 0 local fromisstring 1
	
	cap confirm string variable to
	if _rc == 0 local toisstring 1
	
	forval i = 1 / `c(N)' {
		
		local next 										// reset
		
		if "`fromisstring'" != "1" & "`toisstring'" != "1" {
			local next : di "`indent'" from[`i'] " `sign' " to[`i']
		}
		else {
			
			// FROM
			// ====
			if "`fromisstring'" == "1" {
				*local next : di "`indent'" `"""' "`from'" `"""' " `sign' " 
				if substr(from[`i'], 1,1) == `"""' {
					local next : di "`indent'"   from[`i']   " `sign' " 
				}
				else local next : di "`indent'"  `"""'   from[`i']   `"""'   " `sign' " 
			}
			else local next : di "`indent'" from[`i'] " `sign' " 
			
			// TO
			// ====
			if "`toisstring'" == "1" {
				if substr(to[`i'], 1,1) == `"""' {
					local next : di `"`next'"'  to[`i']  
				}
				*else local next = `"`next'"' + `"""' + to[`i'] + `"""'
				else local next : di `"`next'"'  `"""'  to[`i']  `"""'
			}
			else local next : di `"`next'"' to[`i'] 
		}
		
		
		file write `knot' `"    `next'"'
		
		capture confirm variable label
		if _rc == 0 {
			local lbl : di label[`i']
		}
		
		capture confirm variable properties
		if _rc == 0 {
			local prp : di properties[`i']
		}
		
		//Stata returns a weird error with combining !missing() function, which
		//made me take this stupid work-around...
		
		*if !missing(label[`i']) {
		if !missing("`lbl'") {
			local details `"label="`lbl'""' 
			
			//add comma
			if !missing(`"`prp'"') {
				local details = `"`details', "'
			}
		}	
		
		if !missing(`"`prp'"') {
			local details = `"`details'"' + `"`prp'"' 
		}

		if !missing(`"`details'"') {
			file write `knot' `"[`details']"'
		}
		
		local details 									// reset
		file write `knot' ";" _n
	}
	
end	


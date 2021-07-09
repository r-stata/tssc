
  
prog define diagramnode
	version 11
	syntax [using/] , tempfile(str)

	tempname knot
	file open `knot' using "`tempfile'", write append
	
	preserve 
	if !missing("`using'") quietly use "`using'", clear
	
	//make sure variable type is not string
	cap confirm string variable from
	if _rc == 0 local fromisstring 1
	
	cap confirm string variable to
	if _rc == 0 local toisstring 1
	
	if "`fromisstring'" != "1" {
		// drop duplicated nodes
		qui duplicates drop from, force
		forval i = 1 / `c(N)' {
			local nme : di from[`i']
			local lblnme : di "`: label (from) `=from[`i']''"

			if !missing("`lblnme'") {
				file write `knot' `"    `nme' [label="`lblnme'"];"' _n
			}	
		}
	}
	
	restore
	
	preserve 
	if !missing("`using'") quietly use "`using'", clear
	
	forval i = 1 / `c(N)' {
		local jump 0									// reset
		local nme2 : di to[`i']
		
		forval j = 1 / `c(N)' {
			local nme : di from[`j']
			if `"`nme'"' == `"`nme2'"' {
				local jump 1
				qui drop if to == to[`j']				// drop observations
			}
		}
		
		if "`jump'" == "0" {
			if "`toisstring'" != "1"  {
				local lblnme : di "`: label (to) `=to[`i']''"
				if !missing("`lblnme'") & "`nme2'" != "." {
					file write `knot' `"    `nme2' [label="`lblnme'"];"' _n
				}	
				qui drop if to == to[`i']					// drop observations
			}	
		}	
	}
	
	restore
end	



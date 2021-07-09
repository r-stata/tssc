*! 1.3.1 NJC 21 Sept 2016 
* 1.3.0 NJC 20 Sept 2016 
* 1.2.0 NJC 16 August 2012 
* 1.1.0 NJC 2 July 2008 
* 1.0.0 NJC 5 May 2003 
program mylabels 
	version 8 
	syntax anything(name=values) , Local(str) ///
	[MYscale(str asis) clean Format(str) PREfix(str) SUFfix(str)]  

	if `"`myscale'"' == "" local myscale "@"                                   
	else if !index(`"`myscale'"',"@") { 
		di as err "myscale() does not contain @"
		exit 198 
	} 	

	capture numlist "`values'" 
	if _rc == 0 local values "`r(numlist)'" 
	

	if "`format'" != "" { 
		capture di `format' 1.2345 
	} 	

	if "`clean'" != "" { 
		foreach v of local values { 
			local val : subinstr local myscale "@" "`v'", all 
			if "`format'" != "" local val : di `format' `val' 

			while length("`val'") > 1 & inlist(substr("`val'", -1, 1), "0", ".", ",") {
				local val = substr("`val'", 1, length("`val'") - 1) 
			} 
			local mylabels `"`mylabels' `v' "`prefix'`val'`suffix'" "' 		
		}
	}
	else { 
		foreach v of local values { 
			local val : subinstr local myscale "@" "(`v')", all 
			local val : di %18.0g `val' 
			if "`format'" != "" local v : di `format' `v' 
			local mylabels `"`mylabels' `val' "`prefix'`v'`suffix'""' 
		}
	}

	di as res `"{p}`mylabels'"' 
	c_local `local' `"`mylabels'"' 
end 	
		

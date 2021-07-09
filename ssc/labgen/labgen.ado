*! 2.0.0 NJC 13 Oct 2008 
*! 1.1.0 NJC 18 July 1996 
*! 1.0.0 Paul Lin on Statalist 7/16/96  
program labgen
	version 8   
	gettoken first 0 : 0, parse(" =") 
	gettoken second 0 : 0, parse(" =") 
	gettoken third 0 : 0, parse(" =") quotes 

	if "`second'" == "=" { 
		local var  `first' 
		local defn `"`third' `0'"' 
	} 
	else if "`third'" == "=" { 
		local type `first' 
		local var  `second' 
		local defn `0' 
	}
	else error 198 
	
	gen `type' `var' = `defn'  

	if length(`"`defn'"') > 80 { 
		label var `var' "(see notes `var')" 
		notes `var' : `defn' 
	} 
	else label var `var' `"`defn'"' 
end

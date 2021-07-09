*! 1.0.0 NJC 13 Oct 2008 
program labreplace 
	version 8   
	gettoken var 0 : 0, parse(" =") 
	gettoken eqs defn : 0, parse(" =") quotes 

	replace `var' = `defn'

	local defn = trim(`"`defn'"') 

	if length(`"`defn'"') > 80 { 
		label var `var' "(see notes `var')" 
		notes `var' : `defn' 
	} 
	else label var `var' `"`defn'"' 
end

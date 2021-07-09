program def safedrop
*! NJC 1.1.0 11 February 2003 	
*! NJC 1.0.0 13 November 2000 	
	version 8.0 
	foreach v of local 0 { 
		unab V : `v' 
		if "`V'" == "`v'" { 
			local OKlist "`OKlist'`v' " 
		} 
		else local badlist "`badlist'`v' " 
	} 
	
	local nb : word count `badlist' 
	if `nb' {
		local names = plural(`nb',"name") 
		di "{p}{txt}incomplete variable `names': {res}`badlist'{p_end}" 
		exit 198 
	} 
	else drop `OKlist' 
end 

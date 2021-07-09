*! 1.0.0 NJC 20 Feb 2009 
program cfvars, rclass 
	version 9 
	args one two

	if `"`one'"' == "" { 
		di as err "nothing to do" 
		exit 498 
	}
	else { 
		if substr("`one'", -4, 4) != ".dta" local one "`one'.dta" 
		qui describe using "`one'", varlist 
		local var1 "`r(varlist)'" 
	} 

	if "`two'" == "" { 
		unab var2 : *                                                
		if "`var2'" == "" { 
			di as err "nothing to compare with" 
			exit 498 
		}
		local two "data in memory" 
		local colour "txt" 
	}
	else { 
		if substr("`two'", -4, 4) != ".dta" local two "`two'.dta" 
		qui describe using "`two'", varlist 
		local var2 "`r(varlist)'" 
		local colour "res" 
	}

	local both : list var1 & var2 
	if "`both'" != "" { 
		di _n as text "both datasets contain" 
		di as res "{p 4 4 2}`both'{p_end}"
		return local both "`both'"
	} 

	local same 1 

	local oneonly : list var1 - var2 
	if "`oneonly'" != "" { 
		local same 0 
		di _n as text "variables only in " as res "`one'"  
		di as res "{p 4 4 2}`oneonly'{p_end}" 
		return local oneonly "`oneonly'" 
	} 

	local twoonly : list var2 - var1 
	if "`twoonly'" != "" { 
		local same 0 
		di _n as text "variables only in " as `colour' "`two'"  
		di as res "{p 4 4 2}`twoonly'{p_end}" 
		return local twoonly "`twoonly'" 
	} 

	return local same `same' 
end 

*! 1.0.1 NJC 10 Sept 2003 
program nicedates, rclass
	version 8.1 
	
	if date(c(born_date), "dmy") < 15957 { 
		di as txt "please update your Stata, which predates 9 Sept 2003" 
		exit 0 
	} 	

	syntax varlist(numeric ts) [if] [in] [ , n(int 5) ] 
	
	marksample touse 
	qui count if `touse' 
	if r(N) == 0 error 2000 

	local nvars : word count `varlist' 
	local t : word `nvars' of `varlist' 
	local fmt : format `t' 

	if index("`fmt'","%td")         local option "d" 
	else if index("`fmt'","%d")     local option "d" 
	else if index("`fmt'","%tw")    local option "w" 
	else if index("`fmt'","%tm")    local option "m" 
	else if index("`fmt'","%tq")    local option "q" 
	else if index("`fmt'","%th")    local option "h" 
	else                            local option "y"
	
	su `t' if `touse', meanonly 
	_tsnatscale `r(min)' `r(max)' `n', `option' 

	if "`r(list)'" != "" local dates "`r(list)'" 
	else                 local dates "`r(min)'(`r(delta)')`r(max)'" 

	di as res "`dates'" 

	return local dates "`dates'" 
	return add 
end 

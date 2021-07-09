program def summdate 
*! 1.2.0 NJC 30 March 2001
	version 6 
	syntax varname(numeric) [if] [in] [aweight fweight] 
	
	qui summ `varlist' `if' `in' [`weight' `exp'] 
	if int(`r(mean)') != `r(mean)' { 
		local round "(rounded)" 
	} 

	local format : format `varlist'
	local l = substr("`format'",2,1) 
	if "`l'" != "d" & "`l'" != "t" { 
		di in r "variable does not have date format"
		exit 198 
	} 	
	
	if int(`r(mean)') != `r(mean)' { 
		local round "(rounded)" 
	}

	local np = cond("`l'" == "d",9,8) 

	di 
	di in g "Number of obs"     _col(24) %`np'.0f in y `r(N)'
	di in g "Mean date `round'" _col(24) `format' in y int(`r(mean)') 
	di in g "Minimum date"      _col(24) `format' in y `r(min)' 
	di in g "Maximum date"      _col(24) `format' in y `r(max)' 
	di in g "SD"                _col(24) %`np'.3f in y `r(sd)' 
end 	


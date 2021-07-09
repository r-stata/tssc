*! 1.1.1 NJC 25 May 2002 
* 1.1.0 NJC 25 Oct 2001 
* 1.0.0 NJC 22 Oct 2001
* mod CFB 08 aug 2006 to rename sq->sqr
program define sqr
	version 7.0
	gettoken cmd 0 : 0, parse(" ,")  
	syntax [varlist(ts default=none)] [fweight aweight iweight] [if] [in] /* 
	*/ [ , Aspectratio(real 1) * ]
	
	local a = `aspectratio' /* height / width */ 
	if `a' > (23063 / 32000) { 
		local h = 23063 
		local w = int(`h' / `a') 
	} 
	else { 
	        local w = 32000 
		local h = int(`w' * `a') 
	}

	`cmd' `varlist' `if' `in' [`weight' `exp'], /* 
	*/ `options' bbox(0,0,`h',`w',923,444,0) 
end


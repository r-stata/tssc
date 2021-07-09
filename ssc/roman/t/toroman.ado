*! 1.0.0 NJC 11 January 2011
program toroman
	version 9 
	syntax varname(numeric) [if] [in] , Generate(str) [lower] 

	quietly { 	
		marksample touse 
		count if `touse' 
		if r(N) == 0 error 2000 
	
		confirm new variable `generate' 

		tempvar work totry 
		gen `work' = `varlist' if `touse' 
		gen byte `totry' = `touse' & `varlist' < 233888 & ///
			`work' == int(`work') & `work' > 0   
		mata : to_roman("`work'", "`generate'", "`totry'")  
		count if (!`totry') & `touse' 
		if "`lower'" != "" { 
			replace `generate' = lower(`generate') 
		} 
	}

	if r(N) { 
		di _n as txt "Problematic input: " 
		list `varlist' if ((!`totry')) & `touse' 
	}		
end 

mata : 

void to_roman(string scalar varname, 
string scalar genname, 
string scalar usename) { 
	string colvector sout, rom 
	real colvector nin, num
	real scalar i 

	nin = st_data(., varname, usename) 
	sout = J(rows(nin), 1, "")  
	rom = ("M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", 
		"IV", "I")' 
	num = (1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1)' 

	for (i = 1; i <= rows(rom); i++) {  
		sout = sout :+ rom[i] :* floor(nin / num[i]) 
		nin = nin :- num[i] :* floor(nin / num[i]) 
	}

	(void) st_addvar(max(strlen(sout)), genname)  
	st_sstore(., genname, usename, sout) 	
}	 
	
end 


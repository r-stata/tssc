*! 2.0.0 NJC 12 January 2011
* 1.1.0 NJC 21 December 2010
* 1.0.0 NJC 20 December 2010
program fromroman
	version 9 
	syntax varname(string) [if] [in] , Generate(str) [re(str)] 

	quietly { 	
		marksample touse, strok 
		count if `touse' 
		if r(N) == 0 error 2000 
	
		confirm new variable `generate' 

		if "`re'" == "" { 
			local re  ^M*(C|CC|CCC|CD|D|DC|DCC|DCCC|CM)?
			local re `re'(X|XX|XXX|XL|L|LX|LXX|LXXX|XC)?
			local re `re'(I|II|III|IV|V|VI|VII|VIII|IX)?$
		}

		tempvar work totry
		gen `work' = upper(subinstr(`varlist', " ", "",.)) if `touse'
		gen byte `totry' = `touse' & regexm(`work', "`re'")  
		mata : from_roman("`work'", "`generate'", "`totry'")  

		replace `generate' = . if `work' != "" & `touse' 
		compress `generate' 
		count if `work' != "" & `touse' 
	}

	if r(N) { 
		di _n as txt "Problematic input: " 
		list `varlist' if `work' != "" & `touse' 
	}		
end 

mata : 

void from_roman(string scalar varname, 
string scalar genname, 
string scalar usename) { 
	string colvector sin, sin2, rom 
	real colvector nout, num 
	real scalar i 

	sin = st_sdata(., varname, usename) 
	nout = J(rows(sin), 1, 0)  
	rom = ("CM", "CD", "XC", "XL", "IX", "IV", "M", "D", "C", "L", 
		"X", "V", "I")' 
	num = (900, 400, 90, 40, 9, 4, 1000, 500, 100, 50, 10, 5, 1)' 

	for (i = 1; i <= rows(rom); i++) {  
		sin2 = subinstr(sin, rom[i], "", .) 
		nout = nout + num[i] * 
			(strlen(sin) - strlen(sin2)) / strlen(rom[i]) 
		sin = sin2                          
	} 

	(void) st_addvar("long", genname) 
	st_store(., genname, usename, nout) 	
	st_sstore(., varname, usename, sin) 
}	 
	
end 


*! 1.1.0 NJC 21 December 2010
*! 1.0.0 NJC 20 December 2010
program romantoarabic
	version 9 
	syntax varname(string) [if] [in] , Generate(str) 

	quietly { 	
		marksample touse, strok 
		count if `touse' 
		if r(N) == 0 error 2000 
	
		confirm new variable `generate' 

		tempvar work totry 
		gen `work' = upper(trim(itrim(`varlist'))) if `touse'
		gen byte `totry' = ///
	`touse' & regexm(`work', "^M*(CM|CD|D?)C*(XC|XL|L?)X*(IX|IV|V?I*)$")  
		gen `generate' = . 
		mata : roman_to_arabic("`work'", "`generate'", "`totry'")  

		count if `work' != "" & `touse' 
		replace `generate' = . if `work' != "" & `touse' 
	}

	if r(N) { 
		di _n as txt "Problematic input: " 
		list `varlist' if `work' != "" & `touse' 
	}		
end 

mata : 

void roman_to_arabic(string scalar varname, 
string scalar genname, 
string scalar usename) { 
	string colvector work 
	real colvector y

	work = st_sdata(., varname, usename) 
	y = J(rows(work), 1, 0)  
	
	y = y + 900 * (strpos(work, "CM") :> 0) 
	work = subinstr(work, "CM", "", .) 
	y = y + 400 * (strpos(work, "CD") :> 0) 
	work = subinstr(work, "CD", "", .) 
	y = y + 90 * (strpos(work, "XC") :> 0) 
	work = subinstr(work, "XC", "", .) 
	y = y + 40 * (strpos(work, "XL") :> 0) 
	work = subinstr(work, "XL", "", .) 
	y = y + 9 * (strpos(work, "IX") :> 0) 
	work = subinstr(work, "IX", "", .) 
	y = y + 4 * (strpos(work, "IV") :> 0) 
	work = subinstr(work, "IV", "", .) 
	
	while (sum(strpos(work, "M"))) { 
		y = y + 1000 * (strpos(work, "M") :> 0) 
		work = subinstr(work, "M", "", 1) 
	} 
	
	while (sum(strpos(work, "D"))) { 
		y = y + 500 * (strpos(work, "D") :> 0) 
		work = subinstr(work, "D", "", 1) 
	} 
	
	while (sum(strpos(work, "C"))) { 
		y = y + 100 * (strpos(work, "C") :> 0) 
		work = subinstr(work, "C", "", 1) 
	} 
	
	while (sum(strpos(work, "L"))) { 
		y = y + 50 * (strpos(work, "L") :> 0) 
		work = subinstr(work, "L", "", 1) 
	} 
	
	while (sum(strpos(work, "X"))) { 
		y = y + 10 * (strpos(work, "X") :> 0) 
		work = subinstr(work, "X", "", 1) 
	} 
	
	while (sum(strpos(work, "V"))) { 
		y = y + 5 * (strpos(work, "V") :> 0) 
		work = subinstr(work, "V", "", 1) 
	}
	
	while (sum(strpos(work, "I"))) { 
		y = y + (strpos(work, "I") :> 0) 
		work = subinstr(work, "I", "", 1) 
	}
	
	st_store(., genname, usename, y) 	
	st_sstore(., varname, usename, work) 
}	 
	
end 


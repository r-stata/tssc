*! 1.1.1 NJC 21 Jan 2009 
*! 1.1.0 NJC 20 Jan 2009 
*! 1.0.0 NJC 19 Jan 2009 
program multencode
	version 9 
	syntax varlist(string) [if] [in] , Generate(str) [ label(str) FORCE ] 

	marksample touse, novarlist 
	qui count if `touse' 
	if r(N) == 0 error 2000 

	if "`label'" == "" local label : word 1 of `varlist' 

	if "`force'" == "" { 
		capture label list `label' 
		if _rc == 0 { 
			di as err "{p}value labels `label' already exist; " ///
			"specify -force()- option to overwrite{p_end}" 
			exit 498 
		}
	}  			 

	local nvars : word count `varlist'
	local mylist "`varlist'" 
	local 0 "`generate'" 
	syntax newvarlist 
	local generate "`varlist'" 
	local ngen : word count `generate'

	if `nvars' != `ngen' { 
		di as err "`nvars' " plural(`nvars', "variable") ///
		"but `ngen' new " plural(`ngen', "name") 
		exit 198 
	}

	if `nvars' == 1 { 
		encode `mylist' if `touse', gen(`generate') label(`label')  
		exit 0 
	}

	mata : def_new_vlbl("`mylist'", "`touse'", "`label'") 

        tokenize "`generate'" 
        local j = 1 
	foreach v of local mylist { 
		encode `v' if `touse', gen(``j'') label(`label') 
		qui compress ``j'' 
		local ++j 
	} 
end 

mata : 

void def_new_vlbl(string scalar varnames, string scalar tousename, string scalar lblname)
{
	string matrix y 
	string colvector vals 
	real scalar j 

	st_sview(y, ., tokens(varnames), tousename) 
	vals = J(0, 1, "") 
	
	for(j = 1; j <= cols(y); j++) { 
		vals = vals \ uniqrows(select(y[,j], y[,j] :!= ""))
	}

	vals = uniqrows(vals)
	st_vlmodify(lblname, (1::rows(vals)), vals) 
}	

end 

*! NJC 1.0.0 5 April 2001 
program def hlpdir
        version 6.0

	if "`1'" == "" | "`2'" != "" { 
		di in r "incorrect syntax"
		exit 198 
	}
	args cmd 
	
	local hlpado = index("`cmd'",".hlp") 
	if `hlpado' { 
		local cmd = substr("`cmd'",1,`hlpado'-1) 
	}	
	
        local init = substr("`cmd'",1,1)
	local sep : dirsep 

	tokenize `"$S_ADO"', parse(";") 

	while `"`1'"' != "" { 
		if `"`1'"' != ";" {
			local 1 : sysdir `1'
			local j = 1 
			while `j' <= 2 { 
				local jj = cond(`j'==1,"", "`init'`sep'")   
				local file `"`1'`jj'`cmd'.hlp"' 
				capture confirm file `"`file'"'
				if _rc == 0 { 
					di                 
					di `"`file':"' 
					dir `"`file'"'
				} 	
				local j = `j' + 1 
			} 	
       		}
		mac shift
        } 	
end


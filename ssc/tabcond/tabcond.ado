program def tabcond, byable(recall)
*! NJC 2.2.0 7 Nov 2002 
	version 7

	* subcommand 
        gettoken cmd 0 : 0, parse(" ") 
        local l = length("`cmd'")

        if `l' == 0 {
        	di "{err}subcommand needed; see help on {help tabcond}" 
 	     	exit 198
        }

        if substr("variables",1,max(1,`l')) == "`cmd'" {
                local cmd "variables"
        }
        else if substr("groups",1,max(1,`l')) == "`cmd'" {
                local cmd "groups"
        }
        else {
                di "{err}illegal {cmd}tabcond {err}subcommand"
                exit 198
        }

	* check syntax 
	if "`cmd'" == "groups" {  
		syntax varname [if] [in] [fw aw iw/], /*
		*/ Cond(str asis) [LISTWISE * ] 
	} 
	else if "`cmd'" == "variables" { 
		syntax varlist [if] [in] [fw aw iw/], /* 
		*/ Cond(str asis) [LISTWISE * ] 
	} 	
	
	local ncols : word count `cond'
	if `ncols' > 5 { 
		di "{err}too many conditions: maximum 5"
		exit 198 
	}	

	if "`cmd'" == "variables" { 
		local cond : subinstr local cond "@" "@", all count(local c) 
		if `c' == 0 { 
			di "{txt}cond(){err} does not contain wildcard {txt}@"
			exit 198 
		}
		
		local nrows : word count `varlist'
		if `nrows' > _N { 
			di "{err}insufficient observations to produce table"
			exit 2001 
		}	
	} 	
	
	* initialise variables 
	if "`listwise'" != "" { 
		marksample touse, novarlist 
	} 
	else { 
		marksample touse, strok 
	} 	

	tempvar rows freq 
	tempname rowlbl 
	gen long `rows' = _n 
	gen double `freq' = 0 
	if "`exp'" == "" { 
		local exp 1 
	} 	

	qui if "`cmd'" == "groups" { 
		tempvar group 
		egen `group' = group(`varlist') if `touse', label 
		su `group', meanonly 
		local nrows = `r(max)' 

		forval i = 1 / `nrows' { 
			local row : label (`group') `i' 
			label def `rowlbl' `i' `"`row'"', modify 
		} 	

		label val `rows' `rowlbl' 
	
		forval j = 1 / `ncols' {
			local `j' : word `j' of `cond'
			tempvar col`j' 
			local cols "`cols' `col`j''" 
			gen double `col`j'' = . 
			label var `col`j'' `"``j''"'
			
			forval i = 1 / `nrows' { 
				replace `freq' = /* 
				*/ `exp' * (`group' == `i') * (``j'') 
				su `freq', meanonly 
				replace `col`j'' = r(sum) in `i' 
			} 	
		}

		_crcslbl `rows' `varlist' 
	}
	
	else qui if "`cmd'" == "variables" {
	
		forval i = 1 / `nrows' {
			local row : word `i' of `varlist' 
			local I : variable label `row'
			if `"`I'"' == "" { 
				local I "`row'"
			}	
			label def `rowlbl' `i' `"`I'"', modify   
		} 	

		label val `rows' `rowlbl' 

		forval j = 1 / `ncols' {
			local `j' : word `j' of `cond'
			tempvar col`j' 
			local cols "`cols' `col`j''" 
			gen double `col`j'' = . 
			label var `col`j'' "``j''" 
			forval i = 1 / `nrows' {
				local row : word `i' of `varlist' 
				local J : subinstr local `j' "@" "`row'", all
				replace `freq' = `exp' * `touse' * (`J') 
				su `freq', meanonly 
				replace `col`j'' = r(sum) in `i' 
			} 	
		}

		label var `rows' "Variable" 
	} 

	tabdisp `rows' in 1 / `nrows', cellvar(`cols') `options' 
end 
	

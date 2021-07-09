*! 1.0.0 NJC 12 Sept 2011 
program longshape 
	version 9.2 
	syntax varlist [if] [in], ///
	Iname(varlist) Jname(name) [Yname(name) yvallab(name) replace] 

	confirm new var `jname' 
	confirm new var _`jname' 
	if "`yname'" == "" local yname "y"
	confirm new var `yname' 

	if "`replace'" == "" & c(changed) { 
		di as err "data in memory have not been saved; specify " ///
		as inp "replace " as err "option to force a replace" 
		exit 198 
	} 

	quietly { 
		marksample touse, novarlist 
		count if `touse' 
		if r(N) == 0 error 2000 

		if "`yvallab'" != "" { 
			capture label li `yvallab' 
			if _rc { 
				di as err "labels `yvallab' not found"  
				exit _rc 
			} 

			tempfile vallabsave 
			label save `yvallab' using "`vallabsave'" 
		} 

		keep if `touse' 
	
		local j = 0 
		local varlist : list sort varlist 
		tempname pre 

		foreach v of local varlist { 
			local label`++j' `: var label `v''
			local names `names' `j' "`v'" 
			rename `v' `pre'`j' 
			if `"`label`j''"' == "" local label`j' `v' 
		}

		reshape long `pre', i(`iname')  

		rename `pre' `yname' 
		rename _j `jname' 

		tempname jlabel 
		label def `jlabel' `names' 
		label val `jname' `jlabel' 
		decode `jname', gen(_`jname') 
	
		su `jname', meanonly 

		forval i = 1/`r(max)' { 
			label define `jname' `i' `"`label`i''"', modify 
		} 

		label val `jname' `jname' 

		if "`yvallab'" != "" { 
			do "`vallabsave'" 
			label val `yname' `yvallab' 
		} 

		order `iname' `jname' _`jname' `yname' 
	}
end  


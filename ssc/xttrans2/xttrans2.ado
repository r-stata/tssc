*! 1.0.1 NJC 15 February 2002 
* 1.0.0 NJC 12 February 2001 
* version 1.0.7  14jan2000
program define xttrans2, rclass sort
	version 6
	syntax varname [if] [in] /*
	*/ [, Freq I(varname) T(varname) matcell(str) matrow(str) matcol(str) prob * ]

	if "`prob'" != "" & "`matcell'" == "" { 
		di in r "matcell() required" 
		exit 198 
	} 
	
	if "`matcell'" != "" { 
		if "`matrow'" == "" { tempname matrow } 
		if "`matcol'" == "" { tempname matcol } 
		local names "matrow(`matrow') matcol(`matcol')"  
		local mc "matcell(`matcell')" 
	} 	
	
	xt_iis `i'
	local ivar "`s(ivar)'"

	xt_tis `t'
	local tvar "`s(timevar)'"

	if "`freq'"!="" {
		local opts "row freq `mc' `names' `options'"
	}
	else	local opts "row nofreq `mc' `names' `options'"

	tempvar touse
	mark `touse' `if' `in'
	markout `touse' `varlist' `ivar' `tvar'

	tempvar was is
	quietly { 
		sort `ivar' `tvar' 
		by `ivar': gen float `was' = `varlist' if _n<_N
		by `ivar': gen float `is'  = `varlist'[_n+1] if _n<_N
		local lbl : var label `varlist'
		if "`lbl'"=="" { 
			local lbl "`varlist'"
		}
		label var `was' "`lbl'"  
		label var `is' "`lbl'"
		by `ivar': replace `touse'=0 if `touse'[_n+1]==0 & _n<_N
	}
	tabulate `was' `is' if `touse', `opts'

	if "`matcell'" != "" { 
		local rows = rowsof(`matcell')
		local cols = colsof(`matcell')
		local i = 1
		while `i' <= `rows' {
		        local thisr = `matrow'[`i',1]
		        local r "`r' `thisr'"
		        local i = `i' + 1
		}
		
		local i = 1
		while `i' <= `cols' {
		        local thisc = `matcol'[1,`i']
		        local c "`c' `thisc'"
		        local i = `i' + 1
		}

		mat rownames `matcell' = `r'
		mat colnames `matcell' = `c'
	} 	

	if "`prob'" != "" { 
		mat `matcell' = /*
		*/ inv(diag(`matcell' * J(`cols',1,1))) * `matcell'
	} 	
 
	ret add
end
exit

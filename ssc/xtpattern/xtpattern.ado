program def xtpattern, sortpreserve   
*! NJC 1.0.2 11 February 2002 
* NJC 1.0.1 29 January 2002 
	version 7 
	syntax [if], Generate(string) 
	marksample touse
	local g "`generate'" 

	qui tsset 
	
	if "`r(panelvar)'" == "" { 
		di as err "no panel variable set"
		exit 198 
	} 
	else local panel "`r(panelvar)'"
	
	local time "`r(timevar)'" 

	capture confirm new variable `g' 
	if _rc { 
		di as err "`g' should be new variable"
		exit 198 
	} 	

	tempvar T occ
	
	qui egen `T' = group(`time') if `touse' 
	
	* update for Stata/SE 11 February 2002 
	local smax = cond("$S_StataSE" == "SE", 244, 80) 

	su `T', meanonly 
	if `r(max)' > `smax' { 
		di as err "number of times > `smax': no variable created"
		exit 198 
	} 
	else local max = `r(max)'
	
	qui gen str1 `g' = "" 
	gen byte `occ' = 0 

	sort `touse' `panel' 
	
	qui forval t = 1/`max' { 
		by `touse' `panel': replace `occ' = sum(`T' == `t') 
		by `touse' `panel': replace `occ' = `occ'[_N] 
		by `touse' `panel': /* 
	*/ replace `g' = `g' + cond(`occ', "1", ".") if `touse'
	}
end 

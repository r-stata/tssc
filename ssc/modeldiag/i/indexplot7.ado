*! renamed NJC 12 February 2003
*! 1.2.3 NJC 4 July 2002 
* 1.2.2 NJC 25 May 2002 
* 1.2.1 NJC 17 May 2002
* 1.2.0 NJC 5 Oct 2001 
* 1.1.0 NJC 3 Oct 2001
* 1.0.0 NJC 1 Oct 2001 
program define indexplot7, sort 
	version 7.0
	#delimit ; 
	syntax [varname(numeric default=none)] [, L1title(str)
	XLAbel(str) YLAbel(str) YLIne(str) Gap(int 4) HIgh(numlist int <26
	min=1 max=1) Connect(str) Symbol(str) LOw(numlist int <26 min=1 max=1)
	Zero(str) Points TItle(str asis) SAving(str) BBox(str) * ] ;   
	#delimit cr 
	
	if "`high'" != "" & "`low'" != "" { 
		if (`high' + `low') > 25 { 
			di as error "too many values to show" 
			exit 198 
		} 
	}	

	* get whatever 
        tempvar whatever z  
	qui predict `whatever' if e(sample), `options' 

	* get index 
	if "`varlist'" != "" { local index "`varlist'" } 
	else { 
		tempvar index 
		gen long `index' = _n 
		label var `index' "observation"
	}	
	
	* determine zero 
	if "`zero'" == "mean" { 
		su `whatever', meanonly 
		gen `z' = r(mean)
	}	
	else if "`zero'" != "" { 
		capture gen `z' = `zero' 
		if _rc { 
			di as err "invalid zero() option" 
			exit _rc 
		} 	
	} 
	else gen `z' = 0 

	* graph preparation 
	if "`high'`low'" != "" { 
		tempvar touse  
		gen byte `touse' = e(sample) 
		sort `touse' `whatever' 
		if "`low'" != "" { 
			qui count if !`touse' 
			local i1 = `r(N)' + 1 
			local i2 = `i' + `low' 
			forval i = `i1'/`i2' { 
				local this = `index'[`i'] 
				local where "`where' `this'" 
			} 
		} 
		if "`high'" != "" { 
			local i1 = _N - `high' + 1 
			local i2 = _N 
			forval i = `i1'/`i2' {
				local this = `index'[`i'] 
				local where "`where' `this'" 
			} 
		}	
		local xlabel "`where'" 
	} 	
	
	if "`ylabel'" == "" { local yla "ylabel" } 
	else if "`ylabel'" != "" { local yla "yla(`ylabel')" }
	
	if "`xlabel'" == "" { local xla "xlabel" } 
	else if "`xlabel'" != "" { local xla "xla(`xlabel')" } 

	if "`yline'" != "" { local yli "yli(`yline')" }

	if "`points'" != "" { 
		local connect ".." 
		if "`symbol'" == "" { local symbol "Oi" } 
		else local symbol "`symbol'i" 
	} 
	
	if "`connect'" == "" { local connect "||" } 
	if "`symbol'" == "" { local symbol "ii" }
	
	if `"`l1title'"' == "" { 
		if substr("`symbol'",1,1) == "i" {
			local lbl : variable label `whatever' 
			
			if "`lbl'" != "" { local l1 "l1(`lbl')" } 
			else if "`options'" == "" { local l1 "l1(predicted)" } 
			else local l1 "l1(`options')" 
		} 	
	} 
	else local l1 `"l1(`l1title')"' 

	if `"`saving'"' != "" { local Saving `"saving(`saving')"' } 
	if `"`bbox'"' != "" { local Bbox `"bbox(`bbox')"' }
 	if `"`title'"' == "" { local title `" "' } 

	* graph
	graph `whatever' `z' `index' if e(sample), `l1' `Saving' /* 
	*/ `xla' `yla' `yli' gap(`gap') c(`connect') sy(`symbol') /* 
	*/ ti(`title') `Bbox'    
end


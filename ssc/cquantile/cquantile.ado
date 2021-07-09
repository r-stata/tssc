*! NJC 1.0.0 1 Nov 2005 
*! code based on qqplot 3.3.3  07mar2005
program cquantile, sort
	version 9 
	capture syntax varlist(numeric min=2 max=2) [if] [in] ///
		, Generate(str asis) 
	if _rc syntax varname(numeric) [if] [in] ///
		, BY(varname) Generate(str asis) 

	local nv : word count `generate' 
	if `nv' != 2 { 
		di as err "need two variable names in generate()" 
		exit 198 
	}	
	confirm new var `generate' 
	tokenize `generate' 
	args g1 g2 

	marksample touse, novarlist 

	qui if "`by'" != "" { 
		tempname stub 
		tab `by' if `touse' 
		if r(r) != 2 { 
			di as err "`r(r)' groups found, 2 required"
			exit 420 
		}	
		separate `varlist' if `touse', ///
			gen(`stub') by(`by') veryshortlabel 
		local varlist "`r(varlist)'" 
	}	
	
	tokenize `varlist'
	tempvar work 
	
	quietly {
		count if `1' < . & `touse' 
		local cnty = r(N) 
		count if `2' < . & `touse' 
		local cntx = r(N)
		if `cntx' == 0 | `cnty' == 0 error 2000
				
		gen `g1' = `1' if `touse'
		gen `work' = `2' if `touse'
		if `cnty' > `cntx' QQp2 `g1' `cnty' `cntx'	
		if `cnty' < `cntx' QQp2 `work' `cntx' `cnty' 	
		QQp1 `g1' `work' `g2'
		_crcslbl `g1' `1'
		_crcslbl `g2' `2'
	}
end

program QQp1 
	version 9
	tempvar YORDER
	quietly {
		sort `1' 
		gen long `YORDER' = _n
		sort `2' 
		gen `3' = `2'[`YORDER']
	}
end

program QQp2 
	version 9   
	tempvar INT FRAC TEMP
	quietly {
		sort `1' 
		gen long `INT' = (_n - 0.5) * `2' / `3' + 0.5
		gen `FRAC' = 0.5 + (_n - 0.5) * `2' / `3' - `INT' 
		gen `TEMP' = (1 - `FRAC') * `1'[`INT'] + `FRAC' * `1'[`INT' + 1]
		replace `1' = `TEMP' 
	}
end

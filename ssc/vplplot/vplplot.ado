*! 1.5.0 NJC 23 January 2001 
* 1.4.0 NJC 10 January 2000 
* 1.3.0 NJC 26 Oct 1998
* 1.2.0 NJC 20 Nov 1997
* 1.1.0 NJC 18 Feb 1997
program define vplplot
	version 6.0
	syntax varlist(min=2 max=3) [if] [in] [ , Diff Ratio Base(str) /* 
	*/ Mean GMean SOrt(str) Connect(str) Gap(int 6) Symbol(str)    /* 
	*/ L1title(str asis) T1title(str asis) PEn(str) KEY1(str asis) /* 
	*/ KEY2(str asis) * ] 
	
	tokenize `varlist'
	args y1 y2 xvar

	local nopts = ("`mean'" != "") + ("`gmean'" != "") /* 
	*/          + ("`xvar'" != "") + ("`sort'" != "") 
	
	if `nopts' > 1 { 
		di in r "invalid syntax" 
		exit 198
	} 	

	if "`diff'" != "" & "`ratio'" != "" { 
		di in r "may not combine diff and ratio options" 
		exit 198 
	} 	

	if "`diff'`ratio'" != "" { 
		if "`base'" != "" { 
			capture confirm number `base'  
			if _rc { di in r "invalid base( )" } 
			local show ": base `base'" 
		} 
		else local base = cond("`diff'" != "", 0, 1) 
		tempvar basevar
	} 	

	if "`gmean'" != "" { 
		capture assert `y1' > 0 & `y2' > 0 `if' `in'
		if _rc { 
			di in r "non-positive values encountered" 
			exit 411 
		} 	
	} 		

	marksample touse

	if "`sort'" != "" {
		tempvar order 
        	gen long `order' = _n
	        gsort - `touse' `sort'
	}

	qui if "`xvar'" == "" {
		tempvar xvar 
		
		if "`mean'" != "" { 
			gen `xvar' = (`y1' + `y2') / 2 if `touse' 
		} 	
		else if "`gmean'" != "" { 
			gen `xvar' = sqrt(`y1' * `y2') if `touse'
		} 	
        	else gen `xvar' = _n if `touse' 
		
		if "`mean'" != "" { 
			label var `xvar' "mean of `y1' and `y2'" 
		}
		else if "`gmean'" != "" { 
			label var `xvar' "geometric mean of `y1' and `y2'" 
		} 
		else if "`sort'" != "" { 
			label var `xvar' "rank on `sort'" 
		} 
		else label var `xvar' "observation number" 
	} 	

	if "`symbol'" == "" { local symbol "Opii" }
	if "`connect'" == "" { local connect "..||" } 
	if "`pen'" == "" { local pen "2344" } 

	if _caller( ) > 6 { 
		if "`diff'`ratio'" != "" {
			if `"`key1'"' == "" { local key1 `"key1(" ")"' } 
			else local key1 `"key1(`key1')"' 
		} 	
		else {
			local s1 = substr("`symbol'",1,1) 
			local s2 = substr("`symbol'",2,1) 
			local p1 = substr("`pen'",1,1)
			local p2 = substr("`pen'",2,1)
			local Y1 : variable label `y1'
			local Y1 = cond(`"`Y1'"' == "", "`y1'", "`Y1'") 
			local Y2 : variable label `y2' 
			local Y2 = cond(`"`Y2'"' == "", "`y2'", "`Y2'") 
			if `"`key1'"' == "" { 
				local key1 `"key1(s(`s1') p(`p1') "`Y1'")"' 
			} 
			else local key1 `"key1(`key1')"' 
			if `"`key2'"' == "" { 
				local key2 `"key2(s(`s2') p(`p2') "`Y2'")"' 
			} 
			else local key2 `"key2(`key2')"' 
		} 	
	}
	else if "`diff'`ratio'" != "" { 
		local t1title " " 
	} 	
 
	if "`diff'" != "" { 
		tempvar diff  
		gen `diff' = `y1' - `y2'
		if `"`l1title'"' == "" { 
			local l1title "difference, `y1' - `y2'`show'" 
		} 	
		local y1 `diff'
	        gen `basevar' = `base' 
		local y2 `basevar' 
        } 
	else if "`ratio'" != "" { 
		tempvar ratio  
		gen `ratio' = `y1' / `y2' 
		if `"`l1title'"' == "" { 
			local l1title "ratio, `y1' / `y2'`show'" 
		} 	
		local y1 `ratio' 
	        gen `basevar' = `base' 
		local y2 `basevar'
	} 	

	graph `y1' `y2' `y1' `y2' `xvar' if `touse', /* 
	*/ c(`connect') sy(`symbol') gap(`gap') l1(`"`l1title'"') pen(`pen') /*
	*/ t1(`"`t1title'"') `key1' `key2' `options'

        if "`sort'" != "" { sort `order' }
end


program define bcoeff
*! 1.2.0 ZW/NJC 20 June 2000 
* 1.1.0 NJC 15 June 2000 
* after deltaco 1.0.5 Z.WANG 16Jun2000
* deltaco 1.0.1 Z.WANG 1May1999
	version 6.0
	syntax varlist(min=2 numeric) [if] [in] /* 
	*/ , by(varlist) Generate(str) /* 
	*/ [ Model(str) Nmin(real 2) dxmin(numlist >=0) /* 
	*/ Se(str) Cons(str) Double MISSing ]

	local model = cond("`model'" == "", "regress", "`model'") 
	if "`dxmin'" == "" { local dxmin = 0 } 

	quietly { 
		marksample touse
		count if `touse' 
		if r(N) == 0 { 
			di in r "no observations" 
			exit 2000 
		}
		
		tokenize `varlist'
		local x1 "`2'" 

		if `"`if'"' != "" { local ifn `" `if'"' } 
		if "`in'" != "" { 
			local ifn = /* 
		*/ cond(trim(`"`ifn'"') == "", " `in'", `"`ifn' `in'"')   
		} 	

		confirm new variable `generate'
		local g "`generate'"
		gen `double' `g' = .
		local lbl `"b[`x1']: `model' `varlist'`ifn', by(`by')"' 
		if length("`lbl'") > 80 { 
			note `g' : `"`lbl'"'
			label var `g' "see notes"
		} 
		else label var `g' `"`lbl'"'  
	
		if "`se'" != "" { 
			confirm new variable `se' 
			gen `double' `se' = .
			local lbl /* 
			*/ `"se[`x1']: `model' `varlist'`ifn', by(`by')"' 
			if length("`lbl'") > 80 { 
				note `se' : `"`lbl'"'
				label var `se' "see notes"
			} 
			else label var `se' `"`lbl'"'  
		} 
		else local nose "*" 
		
		if "`cons'" != "" { 
			confirm new variable `cons' 
			gen `double' `cons' = . 
			local lbl /* 
			*/ `"constant: `model' `varlist'`ifn', by(`by')"'  
			if length("`lbl'") > 80 { 
				note `cons' : `"`lbl'"' 
				label var `cons' "see notes"
			} 
			else label var `cons' `"`lbl'"' 
		} 
		else local nocons "*" 
				
		tempvar xmax xmin group

		sort `touse' `by'
		by `touse' `by': replace `touse' = 0 if _N < `nmin'
		egen `xmax' = max(`x1'), by(`touse' `by')
		egen `xmin' = min(`x1'), by(`touse' `by')
		replace `touse' = 0 if (`xmax' - `xmin') <= `dxmin' 
		
		egen `group' = group(`by') if `touse', `missing'  
		su `group', meanonly  
		local ng = r(max) 
		
	        local i = 1
		while `i' <= `ng' {			
			capture `model' `varlist' if `group' == `i'
			if _rc == 0 { 
				`nose' replace `se' = /* 
				*/ _se[`x1'] if `group' == `i' 
				
      				`nocons' replace `cons' = /* 
				*/ _b[_cons] if `group' == `i' 
				
				replace `g' = _b[`x1'] if `group' == `i' 
			} 
			local i = `i' + 1
		} 	
	}
end


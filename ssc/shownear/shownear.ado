program def shownear
*! NJC 2.0.0 7 Sept 2000 
	version 6.0 
	gettoken var 0 : 0 
	confirm numeric variable `var' 
	
	gettoken val 0 : 0 
	confirm number `val' 
	
	gettoken tol 0 : 0, parse(" ,")  
	if "`tol'" == "if" | "`tol'" == "in" | "`tol'" == "," { 
		local 0 `"`tol' `0'"'  
		local tol 
	}  

	syntax [if] [in] [, sort ]  

	if "`tol'" == "" { local tol "1%" }  
	if substr("`tol'",-1,1) == "%" { /* percent */ 
		local tol = substr("`tol'",1,length("`tol'") - 1) 
		confirm number `tol'
		if `tol' <= 0 { 
			di in r "nonpositive tolerance?" 
			exit 411 
		} 	
		local ul = `val' + abs(`val') * `tol' / 100  
		local ll = `val' - abs(`val') * `tol' / 100  
	} 
	else { /* number */ 
		confirm number `tol'
		if `tol' <= 0 { 
			di in r "nonpositive tolerance?" 
			exit 411 
		} 	
		local ul = `val' + 0.5 * `tol'   
		local ll = `val' - 0.5 * `tol'   
	} 
	
	marksample touse 
	if "`sort'" != "" { sort `touse' `var' } 
	
	l `var' if `touse' & (`var' <=  `ul' ) & (`var' >= `ll') 
end

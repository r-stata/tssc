program def regplot7, sort 
*! renamed 11 February 2003 
*! 1.2.0 NJC 19 Sept 2001 
	version 7.0
	syntax [varlist(max=1 numeric default=none ts)] /* 
	*/ [ , Connect(str) L1title(str) Symbol(str) XLAbel XLAbel(str) /* 
	*/ YLAbel YLabel(str) SOrt TItle(str) BY(varname) * /* 
	*/ SEParate(varname) ]

	* initial checking and picking up what -regress- type command 
	* leaves behind

	if "`e(cmd)'" == "anova" { 
		di as err "regplot not allowed after anova" 
		di as txt "recommendation: try " as inp "anovaplot" 
		exit 498 
	}
	
	if "`e(depvar)'" == "" { 
		di as err "estimates not found" 
		exit 301 
	} 

	local ndepvar : word count `e(depvar)' 
	if `ndepvar' > 1 { 
		di as err "regplot not allowed after `e(cmd)'" 
		exit 498 
	} 	

	if "`varlist'" == "" { 
		tempname b 
		mat `b' = e(b) 
		local x : colnames `b' 
		local x : word 1 of `x' 
	} 
	else local x "`varlist'" 

	local y "`e(depvar)'" 

	if "`separate'" != "" {
		qui tab `separate' if e(sample) 
		if r(r) > 19 { 
			di as error "too many groups in `separate': maximum 19" 
			exit 198 
		}
		local nlines = r(r) 
	}	
	else local nlines = 1 

	* get fit 
        tempvar fit
	qui predict `fit' if e(sample) 

	* this depends on Stata 7 dropping variables with a tempname as stub 
	if "`separate'" != "" { 
		tempname sep 
		qui separate `fit', by(`separate') gen(`sep')
	        unab fits : `sep'* 
		
		* fix variable labels 
		foreach v of varlist `fits' { 
			local label : variable label `v'
			local pos = index(`"`label'"',",") 
			local label = substr(`"`label'"',`pos' + 2,.)
			label variable `v' `"`label'"' 
		} 
	} 
	else local fits "`fit'"

	* set up graph defaults 
	if "`connect'" == "" {
		local c : di _dup(`nlines') "s" 
		local connect ".`c'" 
	}
	
	if "`symbol'" == "" { 
		local nfits : word count `fits' 
		local invis : di _dup(`nfits') "i" 
		if "`separate'" != "" { 
			local symbol "[`separate']`invis'" 
		} 	
		else local symbol "O`invis'" 
	}
	
	if `"`l1title'"' == "" { 
		* strip any time series operators
		tsrevar `y', list 
		local y2 "`r(varlist)'" 
		
		* identify the operator 
		if "`y2'" != "`y'" { 
			local op = substr("`y'",1,index("`y'","`y2'")-1)
		}
		
		local what : variable label `y2'

		* put any operator back again 
		if `"`what'"' == "" { local what "`y'" } 
		else local what "`op'`what'"  
		
		if substr("`symbol'",1,1) == "i" { 
			local l1title "fit for `what'" 
		}
		else local l1title "data and fit for `what'" 
	} 
	
	if "`ylabel'" == "" { local yl "ylabel" } 
	else if "`ylabel'" != "ylabel" { local yl "yla(`ylabel')" }
	
	if "`xlabel'" == "" { local xl "xlabel" } 
	else if "`xlabel'" != "xlabel" { local xl "xla(`xlabel')" } 

	if "`by'" != "" { 
		local byby "by(`by')" 
		sort `by'  
	} 

	if "`title'" == "" { local title " " } 
	
	* graph
	gra `y' `fits' `x' if e(sample), co(`connect') l1(`"`l1title'"') /* 
	*/ ti(`"`title'"') sort `xl' `yl' s(`symbol') `byby' `options'  
end


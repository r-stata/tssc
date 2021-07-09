*! renamed 25 Feb 2003 
*! 2.0.0 NJC 19 Sept 2001 
* 1.0.0 NJC 18 May 1998
program define ovfplot7, sort /* observed vs. fitted */
	version 7.0
	syntax [ , Connect(str) L1title(str) Symbol(str) XLAbel XLAbel(str) /* 
	*/ YLAbel YLabel(str) SOrt TItle(str) BY(varname) PEn(str) Gap(int 4) * /* 
	*/ SEParate(varname) ]

	* initial checking and picking up what -regress- type command 
	* leaves behind
	
	if "`e(depvar)'" == "" { 
		di as err "estimates not found" 
		exit 301 
	} 

	local ndepvar : word count `e(depvar)' 
	if `ndepvar' > 1 { 
		di as err "ovfplot not allowed after `e(cmd)'" 
		exit 498 
	} 	

	if "`separate'" != "" {
		qui tab `separate' if e(sample) 
		if r(r) > 19 { 
			di as error "too many groups in `separate': maximum 19" 
			exit 198 
		}
		local ny = r(r) 
	}	
	else local ny = 1
	
	local y "`e(depvar)'" 

	* get fit 
        tempvar fit
	qui predict `fit' if e(sample) 

	* this depends on Stata 7 dropping variables with a tempname as stub 
	if "`separate'" != "" { 
		tempname sep 
		qui separate `y', by(`separate') gen(`sep')
	        unab ys : `sep'* 
		
		* fix variable labels 
		foreach v of varlist `ys' { 
			local label : variable label `v'
			local pos = index(`"`label'"',",") 
			local label = substr(`"`label'"',`pos' + 2,.)
			label variable `v' `"`label'"' 
		} 
	} 
	else local ys "`y'"

	* set up graph defaults 
	if "`connect'" == "" { 
		local connect : di _dup(`ny') "." 
		local connect "l[-]`connect'" 
	}
	
	if "`symbol'" == "" { 
		if "`separate'" != "" { 
			local symbol : di _dup(`ny') "[`separate']" 
		}
		else local symbol "O" 
		local symbol "i`symbol'" 
	} 
	
	if `"`l1title'"' == "" { 
		local what : variable label `y'
		if `"`what'"' == "" { local what "`y'" } 
		local l1title "`what'" 
	} 
	
	if "`ylabel'" == "" { local yl "ylabel" } 
	else if "`ylabel'" != "ylabel" { local yl "yla(`ylabel')" }
	
	if "`xlabel'" == "" { local xl "xlabel" } 
	else if "`xlabel'" != "xlabel" { local xl "xla(`xlabel')" } 

	if "`by'" != "" { 
		local byby "by(`by')" 
		sort `by' `fit' 
	} 

	if "`title'" == "" { local title " " }
	if "`pen'" == "" { 
		local pen = substr("32456789132456789132",1, `ny' + 1) 
	}	

	* graph
	gra `fit' `ys' `fit' if e(sample), co(`connect') l1(`"`l1title'"') /* 
	*/ ti(`"`title'"') sort `xl' `yl' s(`symbol') `byby' pe(`pen') /*
	*/ gap(`gap') `options'  
end


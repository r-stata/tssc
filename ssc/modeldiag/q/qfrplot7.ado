*! 1.2.0 NJC 17 May 2002
* 1.1.0 NJC 12 Apr 2002 
* 1.0.0 NJC 15 Oct 2001
program define qfrplot7 
	version 7.0
	syntax [ , Symbol(str) BY(varname) Gap(int 5) L1title(str) /* 
	*/ super NORMal GAUSSian SAving(str asis) TItle(str asis) * ] 

	* no by() 
	if "`by'" != "" { 
		di as err "by() not supported" 
		exit 198 
	}	

	* get model results 
	tempvar fit residual 
	quietly { 
		predict `fit' if e(sample) 
		su `fit' if e(sample), meanonly 
		replace `fit' = `fit' - r(mean) 
		predict `residual' if e(sample), res 
		label var `fit' "Fitted - mean" 
		label var `residual' "Residual" 
	}	

	* set up graph defaults 
	if "`symbol'" == "" { 
		if "`super'" == "" { 
			local syf "oi" 
			local syr "pi" 
		}
		else local symbol "op" 
	} 
	else if "`super'" == "" { 
		local symbol = trim("`symbol'") 
		local len = length("`symbol'") 
		local j = 1 
		local acc = 0 /* 1 => accumulate chars */ 
		forval i = 1/`len' { 
			local c = substr("`symbol'",`i',1) 
			if "`c'" == "[" { /* start accumulating */ 
				local t`j' "`c'" 
				local acc = 1 
			}
			else if "`c'" == "]" { /* stop accumulating */ 
				local t`j' "`t`j''`c'" 
				local acc = 0 
				local j = `j' + 1 
			}
			else if `acc' { /* accumulating */ 
				local t`j' "`t`j''`c'"
			}
			else { /* other chars */ 
				local t`j' "`c'" 
				local j = `j' + 1 
			}
		}
		if "`t1'" == "" | "`t2'" == "" { 
			di as err "invalid symbol() option" 
			exit 198 
		}
		else {
			local syf "`t1'i" 
			local syr "`t2'i" 
		}
	}	
	if `"`l1title'"' != "" { local default 0 } 
	else local default 1 

	local norm = cond("`normal'`gaussian'" != "", "norm", "")
	local gauss = cond("`gaussian'" != "", "gauss", "") 
	
	* graph
	if "`super'" == "" { 
		if `"`saving'`title'"' != "" { 
			tempfile savefile 
			local temp ", saving(`savefile')" 
		}	
		
	        gph open `temp' 
		if `default' { local l1title "Quantiles of fitted - mean" } 
	        Q `fit' `residual', `options' l1(`"`l1title'"') sy(`syf') /*
         	*/  gap(`gap') bbox(0,0,23063,15500,923,444,0) `norm' `gauss' 
		if `default' { local l1title "Quantiles of residual" } 
		Q `residual' `fit', `options' l1(`"`l1title'"') sy(`syr') /*
	        */  gap(`gap') bbox(0,16500,23063,32000,923,444,0) `norm' `gauss' 
		gph close 
		
		if "`temp'" != "" { 
			if `"`title'"' != "" { 
				local Title `"ti(`title')"' 
			}
			if `"`saving'"' != "" { 
				local Saving `"sa(`saving')"' 
			} 	
			graph using "`savefile'", `Title' `Saving' 
		}	
	}
	else { 
		if `default' {
			local l1title "Quantiles of fitted - mean and residual" 
		}
		if `"`saving'`title'"' != "" { 
			if `"`saving'"' != "" { 
				local Saving `"saving(`saving')"' 
			} 
			if `"`title'"' != "" { 
				local Title `"ti(`title')"' 
			} 
		}	
	        Q `fit' `residual', `options' l1(`"`l1title'"') sy(`symbol') /* 
		*/ gap(`gap') `norm' `gauss' `Saving' `Title' 
	}
	
end

* modified from -quantil2- STB-61  
program def Q, sort 
	version 7.0
	syntax varlist [, A(real 0.5) noBOrder SOrt Reverse NORM GAUSS * ]
	tokenize `varlist'
	local nvars : word count `varlist'

	* compute (i - a)/(n - 2a + 1) or invnorm() of that 
        marksample touse
	tempvar pp order 
	quietly { 
		if "`norm'" == "" { 
		        bysort `touse' (`1') : gen `pp' = /* 
			*/ (_n - `a') / (_N - 2 * `a' + 1) if `touse' 
	        	label var `pp' "Fraction of the data"
			local defxla "0(0.25)1" 
		} 
		else { 
			local desc = cond("`gauss'" != "", "Gaussian", "normal") 
			bysort `touse' (`1') : gen `pp' = /* 
			*/ invnorm((_n - `a') / (_N - 2 * `a' + 1)) if `touse' 
	        	label var `pp' "Quantiles of standard `desc'"
			local defxla "-2(1)2" 
		} 
		sort `pp' 
        	gen `order' = _n

	        forval i = 1/`nvars' {
        		tempvar y`i'
	        	sort ``i''
	        	gen `y`i'' = ``i''[`order']
			_crcslbl `y`i'' ``i'' 
		        local ylist "`ylist'`y`i'' "
	        }
	}	

	if "`border'" == "" { local border "border" }

	local options : subinstr local options "xla" "xla", count(local hasxla) 
	if !`hasxla' { 	local options `"`options' xla(`defxla')"' }
	local options : subinstr local options "yla" "yla", count(local hasyla) 
	if !`hasyla' { 	local options `"`options' yla"' }
	
	qui if "`reverse'" != "" { replace `pp' = 1 - `pp' } 
	
	gra `ylist' `pp' , `border' sort `options' 
end

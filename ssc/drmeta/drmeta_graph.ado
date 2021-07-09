*! N.Orsini v.1.0.0 3may19

capture program drop drmeta_graph
program drmeta_graph, rclass
version 13
syntax  [anything] [,  ///
  MATKnots(string) Knots(numlist) ///
  Dose(numlist) ///
  EQuation(string) Format(string) ///
  Ref(string) Level(int $S_level) ///
  List scatter eform Gen(string) ///
  addplot(string) plotopts(string) ///
  NOci blup gls * ]
 
	preserve 
	
    _get_gropts , graphopts(`options')
 	local options `"`s(graphopts)'"'
	
	local dn "`e(dm)'"

    if "`format'" == "" 	local format = "%3.2fc"
	else local format = "`format'" 
	
    local cilevel = `level'

	if `level' <10 | `level'>99 { 
			di in red "level() invalid"
			exit 198
	}   
	
		local xname `gen'
		local rcs = 0 

		if "`matknots'" != "" {
		    local rcs = 1
			local colnames : colnames `matknots'
			local rowname : rownames `matknots'
			local nk : word count `colnames' 
			local km1 = `nk' - 1
		
	      forvalues i=1/`nk' {
				local t`i' = `matknots'[1,`i']
			}			
	    }
		
		if "`knots'" != "" {
			local rcs = 1
			local nk : word count `knots' 
			local km1 = `nk' - 1	
		
	        forvalues i=1/`nk' {
				local t`i' : word `i' of `knots'
			}			
		}
		
		if ("`equation'" != "") {
			local km1 : word count `equation' 		
	        forvalues i=1/`km1' {
				local t`i' : word `i' of `equation'
			}			
		}

		local listx ""
		forvalues i=1/`km1' {
				tempname v_`xname'`i'
				qui gen `v_`xname'`i'' = . 
				local listx "`listx' `v_`xname'`i''"

		}	
		
		if (`rcs' == 1) { 
	      forvalues i=1/`nk' {
				tempname _Xm`i'p
				qui gen `_Xm`i'p' = .
			}		
		}
		
		
tempname origx tagobs xb lo hi rr lb ub 

local c = 1
local r = 1

qui gen `tagobs' = 1
qui gen `origx' = .

local dose "`dose' `ref'"

foreach anyx of local dose {
            
		if c(N) < `c++' qui set obs `=c(N)+1'
		
		qui replace `origx' = `anyx' in `r'

		if (`rcs'==1) {

				qui replace `v_`xname'1' = `anyx' in `r'

				local j = 1

				while `j' <= `nk' {
					qui replace `_Xm`j'p' = max(0, `anyx' - `t`j'')
					local j = `j'+1
				}

				local j = 1
				while `j' <= `nk' -2 {
					local jp1 = `j' + 1
					qui replace `v_`xname'`jp1'' = (`_Xm`j'p'^3 - (`_Xm`km1'p'^3)* ///
						(`t`nk''   - `t`j'')/(`t`nk'' - `t`km1'') ///
						+ (`_Xm`nk'p'^3  )*(`t`km1'' - `t`j'')/ ///
						(`t`nk'' - `t`km1'')) / (`t`nk'' - `t1')^2 in `r'				
					local j = `j' + 1
				}
		}
		
		local r = `r' + 1
}


     if ("`equation'" != "") {
		local j = 1
				while `j' <= `km1' {
				
					local rt : subinstr local t`j' "d" "`origx'", all
					local ref`j' : subinstr local t`j' "d" "`ref'", all
					qui replace `v_`xname'`j'' = `rt'	
					local j = `j' + 1
				}
	}
	
	if (`rcs' == 1) { 
				forvalues i=1/`km1' {
					qui su `v_`xname'`i'' if  `origx' == float(`ref'), meanonly
					local ref`i' = r(mean)
				}	
	}

    if ("`addplot'" != "") {
		 local cap : subinstr local addplot "d" "x", all
		 if "`eform'" == "" local addplot_f `"(function `cap', range(`origx') `plotopts')"'
		 else local addplot_f `"(function exp(`cap'), range(`origx') `plotopts' )"'
	}
	
		
	tempvar xb lb ub 
	
		tokenize "`dn'"
		local i = 1
		foreach v of local listx {
			if (`i'<`km1') local lp = "`lp' _b[``i'']*(`v'-`ref`i'')+"
			else local lp = "`lp' _b[``i'']*(`v'-`ref`i'')"
			local i = `i' + 1
		}
		
	qui predictnl `xb' = `lp', ci(`lb' `ub') level(`cilevel') 
	local titley "xb"

	if ("`blup'" != "") {
	
	     local liststudies "`e(id)'"
		 local plotblup ""
				  
		  foreach s of local liststudies {
		  tempvar xbu`s'  
		  tempname getxbu
		  
		  * get the matrix
		  mat `getxbu' = e(xbu`s')
		  local lp ""
		  tokenize "`dn'"
			local i = 1
			foreach v of local listx {
				if (`i'<`km1') local lp = "`lp' `getxbu'[1,`i']*(`v'-`ref`i'')+"
				else local lp = "`lp' `getxbu'[1,`i']*(`v'-`ref`i'')"
			   local i = `i' + 1
			}
 
		 	if "`eform'" == "" qui  gen `xbu`s'' = `lp' 
			else qui gen `xbu`s'' = exp(`lp') 
	 
			local plotblup `"`plotblup' (line `xbu`s'' `origx', sort lc(gs10)) "'

		  }
	
	}
	
		if ("`gls'" != "") {
	
	     local liststudies "`e(id)'"
		 local plotgls ""
				  
		  foreach s of local liststudies {
		  tempvar xbgls`s'  
		  tempname getbs
		  
		  * get the matrix
		  mat `getbs' = e(bs`s')
		  local lp ""
		  tokenize "`dn'"
			local i = 1
			foreach v of local listx {
				if (`i'<`km1') local lp = "`lp' `getbs'[1,`i']*(`v'-`ref`i'')+"
				else local lp = "`lp' `getbs'[1,`i']*(`v'-`ref`i'')"
			   local i = `i' + 1
			}
 
		 	if "`eform'" == "" qui  gen `xbgls`s'' = `lp' 
			else qui gen `xbgls`s'' = exp(`lp') 
	 
			local plotgls `"`plotgls' (line `xbgls`s'' `origx', sort lc(gs10)) "'

		  }
	}

 
	if "`eform'" != "" {
					qui replace `xb' = exp(`xb')
					qui replace `lb' = exp(`lb')
					qui replace `ub' = exp(`ub')
					local logyscale `"yscale(log)"'
					local titley `"exp(xb)"'
	}

	if "`scatter'" != "" {
						tw  (rcap `lb' `ub' `origx', lcolor(black)) ///
						`addplot_f' /// 
						`rcsplot_f' /// 
						(scatter `xb' `origx', mcolor(black)) , ///
						 legend(off) scheme(s1mono) ///
						xtitle("Dose") ytitle("`titley'")  ///
						plotregion(style(none)) ///
						ylabel(#5, angle(horiz) format(%3.1fc)) ///
						xlabel(#7) `logyscale' ///
						`options'
    }
    else {
        local plotci "`lb' `ub'"
		if "`noci'" != "" local plotci ""

/*
		if "`blup'"	!= "" {
		              twoway  `plotblup' ///
					  (line `xb' `plotci' `origx', sort lp(l - -) lc(black black black) ) ///
				     `addplot_f' `rcsplot_f' /// 
					, plotregion(style(none)) legend(off) ytitle("`titley'") xtitle("Dose") ///
						ylabel(#5, angle(horiz) format(%3.1fc)) ///
						xlabel(#7)  `logyscale'  ///
		  			`options'
		}
		if "`gls'" != ""  {
					twoway `plotgls'  ///
					(line `xb' `plotci' `origx', sort lp(l - -) lc(black black black) ) ///
				     `addplot_f' `rcsplot_f' /// 
					, plotregion(style(none)) legend(off) ytitle("`titley'") xtitle("Dose") ///
						ylabel(#5, angle(horiz) format(%3.1fc)) ///
						xlabel(#7)  `logyscale'  ///
					`options'
		}	
*/		
		twoway ///
		`plotblup' ///
		`plotgls'  ///
					(line `xb' `plotci' `origx', sort lp(l - -) lc(black black black) ) ///
				     `addplot_f' `rcsplot_f' /// 
					, plotregion(style(none)) legend(off) ytitle("`titley'") xtitle("Dose") ///
						ylabel(#5, angle(horiz) format(%3.1fc)) ///
						xlabel(#7)  `logyscale'  ///
					`options'
	}
	
	// Save results as variables and matrix
	  local listm ""	
	  qui gen `xname'_x = `origx'

      local listm "`xname'_x"
      forvalues i=1/`km1' {                    
					    qui gen `xname'_t`i' =  `v_`xname'`i''
					    local listm "`listm' `xname'_t`i'"
			}	
			
	  qui gen `xname'_xb = `xb'
	  qui gen `xname'_lb = `lb'
	  qui gen `xname'_ub = `ub'
	  
	  if "`format'" != "" format `xname'_xb `xname'_lb `xname'_ub `format'
	  local listm "`listm' `xname'_xb `xname'_lb `xname'_ub "
       mkmat `listm' , mat(E)
	  if "`list'" != "" {
				tempvar tagdup
				bysort `origx': gen `tagdup' = (_n==1)
				list `listm' if `origx' != . & `tagdup', clean noobs 
	   }
	   return matrix E = E
	  * qui keep if `tagobs' == 1
	   if "`gen'" == "" {
	                     qui drop `listm'
   				 	     qui keep if `tagobs' == 1
		}
end

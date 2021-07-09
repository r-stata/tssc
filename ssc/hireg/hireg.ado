*! version 2.1 22JUL2005
program define hireg
version 8
syntax anything [if] [in] [aw pw iw fw] ,  [Regopts(string asis) NOMiss XI]
 
if "`nomiss'"!=""{
	tokenize `anything', parse("(")
	local depvar "`1'"
	macro shift
	while "`1'" != "" {
 		if "`1'" != "("{
      	     	local 1 = subinstr("`1'",")","",.)
			di 
			local v = "`v' `1'"
  		}
  		macro shift
	}
 
	tokenize `v', parse(" ")
	while "`1'" != ""{
		if index("`1'","i.")==1 | index("`1'","I.")==1{
			local vn = substr("`1'",3,.)
		}
		else {
			local vn = "`1'"
		}
		local vv = "`vv',`vn'"
		macro shift	    
	}
 
	preserve
	di "NoMissing option specified, " _c
	qui count if mi(`depvar'`vv')==1
	di "`r(N)' observations not used."
	qui drop if mi(`depvar'`vv')==1
}

if "`xi'"!="" {
  local xi = "xi:"
}

tokenize `anything', parse("(")
local depvar "`1'"
macro shift

while "`1'" != "" {
  if "`1'" != "("{
       local 1 = subinstr("`1'",")","",.)
		 di 
		 local i = `i' + 1
       di in ye "Model `i': 
       di in gr "   Variables in Model: " in ye "`vl' "
       di in gr "   Adding            : " in ye "`1'" 

       local vl = " `vl' `1'"
      `xi' reg `depvar' `vl' `if' `in' [`weight' `exp'], `regopts'

	    local r2_`i' = `e(r2)'
	    local dfmodel`i' = `e(df_m)'
	    local dfresid`i' = `e(df_r)'
	    local ssmodel`i' = `e(mss)'
	    local ssresid`i' = `e(rss)'
	    local f`i' = `e(F)'
	    
	    local j = 0
	    while `i'>1 & `j'<`i'   {
	        local j = `i' - 1
 	        local fchange`j' = ((`ssmodel`i'' - `ssmodel`j'') / (`dfmodel`i'' - `dfmodel`j'')) * (`dfresid`i'' / `ssresid`i'')
			  local rchange`j' = `r2_`i'' - `r2_`j''
			  local dfnum`j' = `dfmodel`i''-`dfmodel`j''

			  di in gr "R-Square Diff. Model `i' - Model `j' = " in ye %5.3f `rchange`j''  in gr "   F(" `dfnum`j'' ","`dfresid`i'' ") = " in ye %6.3f `fchange`j'' in gr "  p = " in ye %5.3f 1-F(`dfnum`j'',`dfresid`j'',`fchange`j'')
			  local mm = `j'
	        local j = `i' + 1
 	    } 	        
  }
  macro shift
}


di
di 
di in gr "Model" _col(8)  "R2"   _col(15)   " F(df)"  _col(35) "p"   _col(45) "R2 change"  _col(55) " F(df) change"  _col(75) "p"
di _col(4) "1:" in ye  _col(8) %5.3f  `r2_1'    _col(15)  %6.3f `f1' "(" `dfmodel1' "," `dfresid1' ")"  _col(35) %5.3f 1-F(`dfmodel1',`dfresid1',`f1')

forvalues m=1 / `mm'{
  local ii = `m' + 1
  di in gr _col(4) "`ii':"  in ye    _col(8) %5.3f `r2_`ii''  _col(15)  %6.3f `f`ii'' "(" `dfmodel`ii'' "," `dfresid`ii'' ")"  _col(35) %5.3f 1-F(`dfmodel`ii'',`dfresid`ii'',`f`ii'') /*
   */ _col(45) %5.3f `rchange`m''  _col(55) %6.3f `fchange`m'' "(" `dfnum`m'' "," `dfresid`ii'' ")"  _col(75) %5.3f 1-F(`dfnum`m'',`dfresid`m'',`fchange`m'') 
}


if "`nomiss'"!="" {
	restore
}

end

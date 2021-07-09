*! 1.0.0 NJC 9 Sept 2003  
program msplot  
	version 8 
	syntax varlist(numeric min=2) [if] [in] ///
	[, CLSTYle(str) CLPattern(str) CLWidth(str) CLColor(str) /// 
	Bands(passthru) n(passthru) plot(str asis) * ] 
	
	tokenize `varlist' 
	local nvars : word count `varlist'
	local x ``nvars'' 
	local `nvars' 
	local Ylist "`*'"

	marksample touse, novarlist 
	markout `touse' `x' 
	
	foreach y of local Ylist { 
		qui count if `y' < . & `touse' 
		if r(N) == 0 di "{res}`y' {txt}has too few observations" 
		else local ylist "`ylist'`y' " 
	} 

	if "`ylist'" == "" { 
		di as err "no variable has enough observations" 
		exit 2001 
	} 	
	
	local ny : word count `ylist' 

	// in this block, tabs replaced by 4 spaces 
	if `"`clcolor'`clwidth'`clpattern'`clstyle'"' != "" { 
	    forval i = 1/`ny' {
	        local j = 1 
	        foreach o in clcolor clwidth clpattern clstyle { 
	            local carry : word `j' of cc cw cp cs  
	            local prev : word `j++' of C W P S  
	            if `"``o''"' != "" { 
	                local w : word `i' of ``o''
	                if `"`w'"' != "" { 
		             if `"`w'"' == "=" { 
	                         if `"``prev''"' == "" { 
				      local cl`i' `"`cl`i'' `o'(.)"'
				 }      
                        	 else local cl`i' `"`cl`i'' `o'(``prev'')"'
		             } 
		             else if `"`w'"' == ".." | `"`w'"' == "..." { 
	                         local `carry' "yes" 
	                         local cl`i' `"`cl`i'' `o'(``prev'')"' 
		             }
			     else local cl`i' `"`cl`i'' `o'(`w')"' 
	                }   
	                else if "``carry''" != "" & `"``prev''"' != "" { 
		             local cl`i' `"`cl`i'' `o'(``prev'')"' 
	                }    
	                if `"`w'"' != "" & "``carry''" == "" { 
		             local `prev' `"`w'"' 
	                }    
	            }
	        }
	    }
	}                                                                            

	local i = 1 
        foreach y of local ylist { 
		local arg ///
		"`arg' mspline `y' `x' if `touse', `bands' `n' `cl`i'' ||"
		local what `"`: variable label `y''"' 
		if `"`what'"' == "" local what "`y'" 
		local order `"`order' `i++' `"`what'"'"'
	} 	

	if `ny' == 1 { 
		local yti `"yti(`"`: variable label `ylist''"') legend(off)"'  
	} 	
	if `"`yti'"' == "" local yti `"yti("`ylist'")"' 

	twoway `arg'  ///
	`plot'        || ///
	, legend(order(`order')) `yti' `options' 
end 
	

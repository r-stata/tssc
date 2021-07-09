*! 1.0.3 NJC 27 February 2012 
*! 1.0.2 NJC 22 November 2010 
*! 1.0.1 NJC 28 April 2010 
*! 1.0.0 NJC 30 March 2010 
program findname, rclass   
	version 9 

	syntax [varlist] [if] [in]                              ///
	[, INSEnsitive LOCal(str) NOT PLACEholder(str)          /// 
	Alpha Detail INDENT(int 0) Skip(int 2) Varwidth(int 12) ///
	Type(str) all(str asis) any(str asis) Format(str)       ///
	VARLabel VARLabeltext(str asis)                         ///
	VALLabel VALLabelname(str) VALLABELText(str asis)       ///
	Char Charname(str) CHARText(str asis) ]

	// -if- and -in- only affect -any()- and -all()- and -vallabeltext()
	quietly if `"`if'`in'"' != "" { 
		marksample touse, novarlist 
		count if `touse' 
		if r(N) == 0 error 2000 
		local if if `touse' 
		local andif & `touse' 
	}

	// check presentation options
	if !inrange(`varwidth',5,32) {
		di as err "varwidth() should be in the range 5..32"
		exit 198
	}

	if !inrange(`skip',1,10) {
		di as err "skip() should be in the range 1..10"
		exit 198
	}

	// check -type()-
	// We remove allowed type names from the argument. 
	// Whatever remains should be the elements of a numlist. 
	// Note that a numlist may include embedded spaces. 
	// A side-effect is to allow e.g. "1 byte / 80".
	//
	// New over -ds-: indulge e.g. str18, str1-str2 
	if "`type'" != "" {  
		local words "byte int long float double string numeric"
		local numbers : list type - words 
		local numbers : subinstr local numbers "str" "", all 
		local numbers : subinstr local numbers "-" "/", all 
	     
		if `"`numbers'"' != "" {  
			capture numlist `"`numbers'"', integer range(>=1 <=`c(maxstrvarlen)') 
			if _rc { 
				di as err "invalid variable type(s)" 
				exit 198 
			}  
		} 
		
		local type : list type - numbers 
		local type `type' `r(numlist)'
	}  

	// check -any()- or -all()-
	// if condition doesn't work with either a numeric or a string 
	// test variable as input, it is rejected 
	qui if `"`any'"' != "" { 
		tempvar ntest stest 
		local At = cond("`placeholder'" != "","`placeholder'","@") 
		gen `ntest' = 42 
		local cond : subinstr local any "`At'" "`ntest'", all 
		capture local test = `cond' 
		local iserr = _rc 
		gen `stest' = "42" 
		local cond : subinstr local any "`At'" "`stest'", all 
		capture local test = `cond' 
		drop `ntest' `stest' 

		if min(`iserr', _rc) { 
			di as err `"`any' incorrect?"' 
			exit 198
		} 
	}

	qui if `"`all'"' != "" { 
		tempvar ntest stest 
		local At = cond("`placeholder'" != "","`placeholder'","@") 
		gen `ntest' = 42 
		local cond : subinstr local all "`At'" "`ntest'", all 
		capture local test = `cond' 
		local iserr = _rc 
		gen `stest' = "42" 
		local cond : subinstr local all "`At'" "`stest'", all 
		capture local test = `cond' 
		drop `ntest' `stest' 

		if min(`iserr', _rc) { 
			di as err `"`all' incorrect?"' 
			exit 198
		} 
	}

	// preparation 
	local inse = "`insensitive'" != "" 
	tempname found 

	// variable types 
	if "`type'" != "" { 
		foreach v of local varlist {
                	foreach w of local type {
	                	if `"`w'"' == "string" | `"`w'"' == "numeric" { 
        	                	capture confirm `w' variable `v'
	        	                if _rc == 0 { 
                        	    		local vlist `vlist' `v' 
						continue, break 
	                        	}    
	                        }
        	                else {
                	        	local t : type `v' 
                        		if "`t'" == `"str`w'"' | "`t'" == `"`w'"' { 
                            			local vlist `vlist' `v'
						continue, break 
		                        } 
        	                }     
	               } 
        	}
		local varlist `vlist' 
	}

	// variable formats 
	if "`format'" != "" {
		local vlist 
        	foreach v of local varlist { 
                	local fmt : format `v' 
			mata : find_match("`fmt'", "`format'", `inse', "`found'") 
			if `found' { 
               	        	local vlist `vlist' `v' 
		      	} 
	        }
		local varlist `vlist'
	} 

	// condition satisfied by any values? 
	qui if `"`any'"' != "" { 
		local vlist 
		foreach v of local varlist { 
			local cond : subinstr local any "`At'" "`v'", all 
			capture count if `cond' `andif' 
			if _rc == 0 & r(N) > 0 { 
				local vlist `vlist' `v' 
			} 
		}
		local varlist `vlist' 
	}

	// condition satisfied by all values? 
	qui if `"`all'"' != "" { 
		count `if' 
		local N = r(N) 
		local vlist 
		foreach v of local varlist { 
			local cond : subinstr local all "@" "`v'", all 
			capture count if `cond' `andif' 
			if _rc == 0 & r(N) == `N' { 
				local vlist `vlist' `v' 
			} 
		}
		local varlist `vlist' 
	} 

	// variable labels assigned? 
	if "`varlabel'" != "" {
		local vlist 
        	foreach v of local varlist { 
                	local lbl : var label `v' 
	                if `"`lbl'"' != "" { 
                        	local vlist `vlist' `v' 
                	} 
            	}
		local varlist `vlist' 
 	} 

	// variable labels matching patterns? 
	if `"`varlabeltext'"' != "" {
		local vlist 
        	foreach v of local varlist { 
                	local lbl : var label `v' 
			mata : find_match(`"`lbl'"', `"`varlabeltext'"', `inse', "`found'") 
                	if `found' { 
                    		local vlist `vlist' `v' 
                	} 
            	}
		local varlist `vlist' 
        } 

	// value labels assigned? 
	if "`vallabel'" != "" {
		local vlist 
        	foreach v of local varlist { 
                	local lbl : val label `v' 
	                if `"`lbl'"' != "" { 
                        	local vlist `vlist' `v'
                	} 
            	}
		local varlist `vlist' 
 	} 	

	// value label names matching patterns? 
	if "`vallabelname'" != "" {
		local vlist 
        	foreach v of local varlist { 
                	local lbl : val label `v' 
			mata : find_match("`lbl'", "`vallabelname'", `inse', "`found'") 
                	if `found' { 
                    		local vlist `vlist' `v' 
                	} 
            	}
		local varlist `vlist' 
        } 

	// value label text matching patterns? 
	qui if `"`vallabeltext'"' != "" {
		local vlist 
        	foreach v of local varlist { 
                	local lbl : val label `v' 
			if "`lbl'" != "" { 
				levelsof `v' `if', local(levels) 
				foreach l of local levels { 
					local txt : label `lbl' `l', strict 
					mata : find_match(`"`txt'"', `"`vallabeltext'"', `inse', "`found'") 
					if `found' { 
	                        		local vlist `vlist' `v'
			                	continue, break 
                	        	} 
				} 
                	}
	       	}
		local varlist `vlist' 
 	} 

	// characteristics assigned?
	if "`char'" != "" {
		local vlist 
                foreach v of local varlist { 
                	local chr : char `v'[] 
                        if `"`chr'"' != "" { 
                        	local vlist  `vlist' `v'
                    	} 
                }
		local varlist `vlist' 
	}

	// characteristic names match patterns?
	if "`charname'" != "" {
		local vlist 
                foreach v of local varlist { 
                	local chr : char `v'[] 
                    	foreach c of local chr { 
				mata : find_match("`c'", "`charname'", `inse', "`found'") 
				if `found' { 
	                                local vlist `vlist' `v' 
       		                        continue, break 
				} 
                    	}    
		}    
		local varlist `vlist'
        } 

	// characteristic text matches patterns? 
	if `"`chartext'"' != "" {
		local vlist
                foreach v of local varlist { 
                	local chr : char `v'[] 
                    	foreach c of local chr { 
				local txt : char `v'[`c'] 
				mata : find_match(`"`txt'"', `"`chartext'"', `inse', "`found'") 
                        	if `found' { 
					local vlist `vlist' `v' 
       		                        continue, break 
				} 
			} 
		}    
		local varlist `vlist'
 	} 

	if "`not'" != "" {   
		unab all : *  
		local varlist : list all - varlist 
	}

	if "`varlist'" == "" { 
		exit 
	}   
	 
	// presentation
	if "`alpha'" != "" {
		local varlist : list sort varlist 
	}

	if "`detail'" != "" { 
		describe `varlist' 
	}
	else {
		local vlist 
		foreach v of local varlist {
			local vlist `vlist' `= abbrev("`v'",`varwidth')'
		}
		
		DisplayInCols txt `indent' `skip' 0 `vlist'
	}    

	return local varlist `varlist'
	if "`local'" != "" c_local `local' `varlist' 
end

program DisplayInCols /* sty #indent #pad #wid <list>*/
	gettoken sty    0 : 0
	gettoken indent 0 : 0
	gettoken pad    0 : 0
	gettoken wid	0 : 0

	local indent = cond(`indent'==. | `indent'<0, 0, `indent')
	local pad    = cond(`pad'==. | `pad'<1, 2, `pad')
	local wid    = cond(`wid'==. | `wid'<0, 0, `wid')
	
	local n : list sizeof 0
	if `n'==0 { 
		exit
	}

	foreach x of local 0 {
		local wid = max(`wid', length(`"`x'"'))
	}

	local wid = `wid' + `pad'
	local cols = int((`c(linesize)'+1-`indent')/`wid')

	if `cols' < 2 { 
		if `indent' {
			local col "_column(`=`indent'+1')"
		}
		foreach x of local 0 {
			di as `sty' `col' `"`x'"'
		}
		exit
	}
	local lines = `n'/`cols'
	local lines = int(cond(`lines'>int(`lines'), `lines'+1, `lines'))

	/* 
	     1        lines+1      2*lines+1     ...  cols*lines+1
             2        lines+2      2*lines+2     ...  cols*lines+2
             3        lines+3      2*lines+3     ...  cols*lines+3
             ...      ...          ...           ...               ...
             lines    lines+lines  2*lines+lines ...  cols*lines+lines

             1        wid
	*/

	* di "n=`n' cols=`cols' lines=`lines'"
	forvalues i=1(1)`lines' {
		local top = min((`cols')*`lines'+`i', `n')
		local col = `indent' + 1 
		* di "`i'(`lines')`top'"
		forvalues j=`i'(`lines')`top' {
			local x : word `j' of `0'
			di as `sty' _column(`col') "`x'" _c
			local col = `col' + `wid'
		}
		di as `sty'
	}
end

mata: 

void find_match(
string scalar mystring, 
string scalar mypatternlist, 
numeric scalar inse,
string scalar scname)
{
real scalar found, i 
string rowvector mypatterns 

mypatterns = tokens(mypatternlist) 
found = 0 

if (inse) { 
	for(i = 1; i <= length(mypatterns); i++) { 
		if (strmatch(strlower(mystring), strlower(mypatterns[i]))) { 
			found = 1 
			break 
		}
	}
}
else { 
	for(i = 1; i <= length(mypatterns); i++) { 
		if (strmatch(mystring, mypatterns[i])) { 
			found = 1 
			break 
		}
	}	 
}
st_numscalar(scname, found) 
}

end 


program define labcopy
*! NJC 1.0.1 6 April 2000 
* NJC 1.0.0 13 January 2000 
	version 6 
	gettoken vallbl 0 : 0, parse(" ,")  
	capture label list `vallbl' 
	if _rc { 
		di in r "`vallbl' not a value label" 
		exit 498 
	} 	
	
	syntax , [ From(numlist min=1 int) To(numlist min=1 int) /* 
	*/ Swap(numlist min=2 max=2 int) List ] 

	if "`swap'`from'`to'" == "" { 
		di in bl "nothing to do?" 
	}

	if "`swap'" != "" & "`from'`to'" != "" { 
		di in r "may not combine swapping and mapping" 
		exit 198 
	} 	

	local nopts = ("`from'" != "") + ("`to'" != "") 
	if `nopts' == 1 { 
		di in r "from( ) must be combined with to( )"
		exit 198 
	}	

	if "`swap'" != "" { /* swapping */ 
		local i = 1 
		while `i' <= 2 { 
			local n`i' : word `i' of `swap' 
			local l`i' : label `vallbl' `n`i'' 
			if `"`l`i''"' == "`n`i''" { 
				di in r "`vallbl': no value label for `n`i''" 
				exit 498 
			}	
			local i = `i' + 1 
		}	

		di _n `"label def `vallbl' `n1' `"`l2'"' "' _c 
		di `" `n2' `"`l1'"', modify "'
                label def `vallbl' `n1' `"`l2'"' `n2' `"`l1'"', modify  
	} 	

	if "`from'`to'" != "" { /* mapping */  
		local nfrom : word count `from' 
		local nto : word count `to' 

		if `nfrom' != `nto' { 
			di in r "from( ) and to( ) should match one-one" 
			exit 198
		}

		tokenize `from' 
		local i = 1 
		while `i' <= `nfrom' { 
			local l`i' : label `vallbl' ``i'' 
			if `"`l`i''"' == "``i''" { 
				di in r "`vallbl': no value label for ``i''" 
				exit 498 
			}
			local t`i' : word `i' of `to' 
			local args `"`args' `t`i'' `"`l`i''"'"' 
			local i = `i' + 1
		} 

		di _n `"label def `vallbl' `args', modify"'   
		label def `vallbl' `args', modify  
	}	
	
	if "`list'" != "" {
		di 
		label li `vallbl' 
	} 
end 


program define labmap 
*! NJC 1.0.0 12 June 2001 
	version 6 
	gettoken vallbl 0 : 0, parse(" ,") 

	syntax , Values(numlist min=1 int) [ Labels(numlist min=1) /* 
	*/ First(numlist min=1 max=1) Step(numlist min=1 max=1) /* 
	*/ Maximum(numlist min=1 max=1) Add modify nofix /* 
	*/ PREfix(str) POSTfix(str) List ]

	local nvals : word count `values' 
	tokenize `values'
	
	* do labels exist? 
	capture label list `vallbl' 
	local exists = _rc == 0

	* if so, can we change them? 
	if `exists' { 
		if "`add'`modify'" == "" { Onerror 1 } 
		else if "`modify'" == "" { 
			local i = 1 
			while `i' <= `nvals' { 
				local exlabel : label `vallbl' ``i'' 
				if "`exlabel'" != "``i''" { 
					Onerror 2 
				}		
				local i = `i' + 1 
			}
		}	
	} 	

	* correct syntax for new labels? 
	if "`labels'" == "" { 
		if "`first'" == "" | "`step'" == "" { Onerror 3 } 
	} 
	else { 
		if "`first'`step'" != "" { Onerror 3 } 
	} 	
	
	* # of values == # of labels? 
	if "`labels'" != "" { 
		local nlabs : word count `labels' 
		if `nvals' != `nlabs' { Onerror 4 } 
	} 

	* OK to set up -label- arguments 
	local i = 1 
	if "`labels'" != "" {  
		while `i' <= `nvals' { 
			local l : word `i' of `labels' 
		        local largs `"`largs' ``i'' "`prefix'`l'`postfix'""' 
			local i = `i' + 1
		}	
	} 	
	else {
		local l "`first'" 
		local s "`step'" 
		local m "`maximum'" 
		if "`m'" == "" { local m = . }
		
		while `i' <= `nvals' { 
			local largs `"`largs' ``i'' "`prefix'`l'`postfix'""' 
		local l = cond(`l' + `s' <= `m', `l' + `s', mod(`l' + `s', `m')) 
        		local i = `i' + 1 
		} 	 
	}	

	* now change labels 
	label def `vallbl' `largs', `nofix' modify

	* list if desired 
	if "`list'" != "" { 
		di 
		la li `vallbl' 
	}	
	
end 

program define Onerror 
	args code 
	
	if `code' == 1 { 
		di in r "need to specify add or modify option" 
	}
	else if `code' == 2 {
		di in r "need to specify modify option" 
	} 	
	else if `code' == 3 { 
		di in r "must choose between labels() and first() step()"
	}
	else if `code' == 4 { 
		di in r "number of values does not match number of labels"
	} 

	exit 198 
end 

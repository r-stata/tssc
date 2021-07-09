program def seqlist, rclass
*! NJC 1.2.0 4 July 2000 
* NJC 1.1.0 7 June 2000 
* NJC 1.0.0 31 Jan 2000 
	version 6.0 
	gettoken stub 0 : 0, parse(" ,")
	if "`stub'" == "," { 
		local 0 ", `0'" 
		local stub 
	}
	syntax , Copies(int) /* 
	*/ [ Noisily Start(int 1) Prefix Global(str) POSTfix(str) ]
	
	if length("`global'") > 8 { 
		di in r "global name must be <=8 characters" 
		exit 198 
	} 	

	local prefix = "`prefix'" != "" 
	
	local i = 1 
	local j = `start' 
	while `i' <= `copies' { 
		if `prefix' { 
			local newlist "`newlist'`j'`stub'`postfix' " 
		} 
		else local newlist "`newlist'`stub'`j'`postfix' " 
		local i = `i' + 1 
		local j = `j' + 1 
	}
	
	if "`noisily'" != "" { di "`newlist'" }
	if "`global'" != "" { global `global' "`newlist'" } 
	return local list `newlist' 
end 	

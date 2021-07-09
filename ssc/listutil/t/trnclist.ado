program def trnclist, rclass
*! NJC 1.2.0 29 June 2000 
* NJC 1.1.0 7 June 2000 
* NJC 1.0.0 3 March 2000 
	version 6.0 
	gettoken list 0 : 0, parse(",")
	if "`list'" == "" | "`list'" == "," { 
		di in r "nothing in list" 
		exit 198 
	}
	syntax , [ Length(numlist int >0) Number(numlist int >0) /* 
	*/ Global(str) Noisily ]

	if "`length'`number'" == "" { 
		di in r "nothing to do?" 
		exit 198 
	} 
	else if "`length'" != "" & "`number'" != "" { 
		di in r "choose between length( ) and number( ) options" 
		exit 198 
	} 	
	
	if length("`global'") > 8 { 
		di in r "global name must be <=8 characters" 
		exit 198 
	} 

	if "`length'" != "" { 
		if `length' > 80 {  
			di in r "cannot handle word length > 80"
			exit 498 
		}
	} 

	tokenize `list'

	if "`length'" != "" { 
		while "`1'" != "" { 	
			local 1 = substr("`1'",1,`length') 
			local newlist "`newlist'`1' "
			mac shift
		}
	}	
	else { 
		while "`1'" != "" { 	
			local 1 = substr("`1'",1,length("`1'")-`number') 
			local newlist "`newlist'`1' "
			mac shift
		}
	} 	
		
	if "`noisily'" != "" { di "`newlist'" } 
	if "`global'" != "" { global `global' "`newlist'" } 
	return local list `newlist'
end 	
			

*! 2.0.0 NJC 20 February 2005 
* 1.1.0 NJC 15 April 1999 
* 1.0.0 NJC 27 March 1997
// assumes every boundary recorded twice
program numids
	version 8   
	syntax varlist(min=2 max=2) [if] [in], Generate(str)
	
	local nvars : word count `generate' 
	if `nvars' != 2 { 
    		di as err "generate() option must specify two variable names"
	    	exit 198
	}

	confirm new variable `generate'
	
	marksample touse, strok 
	qui count if `touse' 
	if r(N) == 0 error 2000 
	
	tokenize "`varlist'"
	args i j 

	qui count if (mi(`i') & !mi(`j') | (!mi(`i') & mi(`j') 
	if r(N) > 0 { 
		di as err ///
		"warning: `r(N)' observations in which one id is missing"
	} 	
	
	tokenize "`generate'" 
	args gen1 gen2 
	egen `gen1' = group(`i') if `touse' 
	egen `gen2' = group(`j') if `touse' 
end

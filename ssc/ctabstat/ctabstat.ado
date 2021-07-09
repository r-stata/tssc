program def ctabstat
*! NJC 1.1.0 30 June 2000 
	version 6.0 

	syntax varlist(numeric) [if] [in] [aw fw] /* 
	*/ [ , Columns(str) sep * ]

	if "`columns'" == "" { local columns "s" } 
        if "`sep'" == "" { local sep "nosep" } 
		 
	tabstat `varlist' `if' `in' [`weight' `exp'] , /* 
	*/ `options' c(`columns') `sep'    
end 	

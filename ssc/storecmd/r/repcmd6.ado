*! 1.0.1 NJC 6 August 2004                                       
*! 1.0.0 NJC 8 December 1999 with code from Jeroen Weesie's -keyb- 
program def repcmd6
	version 6 
	if "`1'" == "" { error 198 } 
	
	gettoken cmd 0 : 0, parse(" ,")  
	local cmd : char _dta[`cmd']
	if `"`cmd'"' == "" { 
		di in r "no such characteristic" 
		exit 198 
	}	
	
	syntax [, Showonly ] 
        
        if `"$BUF_DISP"' != "" { di in wh `". `*'"' }                
        
        * put the command in the command buffer
        push `cmd'
        
        * execute the command (unless -showonly-) 
        if "`showonly'" == "" { `cmd' } 
end


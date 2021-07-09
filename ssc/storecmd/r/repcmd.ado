*! 1.0.2 NJC 7 December 2005                                       
*! 1.0.1 NJC 6 August 2004                                       
*! 1.0.0 NJC 8 December 1999 with code from Jeroen Weesie's -keyb- 
program def repcmd
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

	if _caller() == 7 { local vv : di "version 7:" } 
	else local vv : di "version " string(_caller()) ", missing :"
	
        * execute the command (unless -showonly-) 
        if "`showonly'" == "" { `vv' `cmd' } 
end


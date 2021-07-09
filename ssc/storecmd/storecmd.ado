*! 1.0.1 NJC 7 December 2005 
*! 1.0.0 NJC 8 December 1999 with code from Jeroen Weesie's -keyb- 
program define storecmd 
        version 6.0
	gettoken cname 0 : 0 
	if `"`0'"' == "" { error 198 } 
        
        if `"$BUF_DISP"' != "" { di in wh `". `0'"' }                

	local cmd `"`0'"' 
	
	* put command in keyboard buffer 
        push `cmd' 

	if _caller() == 7 { local vv : di "version 7:" } 
	else local vv : di "version " string(_caller()) ", missing :"

  	* execute command 
        `vv' `cmd'
	
	* save to characteristic if it worked 
	char _dta[`cname'] `"`cmd'"' 
end


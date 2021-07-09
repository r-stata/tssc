*! 1.0.0 NJC 8 December 1999 with code from Jeroen Weesie's -keyb- 
program define storecmd6 
        version 6.0
	gettoken cname 0 : 0 
	if `"`0'"' == "" { error 198 } 
        
        if `"$BUF_DISP"' != "" { di in wh `". `0'"' }                

	local cmd `"`0'"' 
	
	* put command in keyboard buffer 
        push `cmd' 
  
	* execute command 
        `cmd'
	
	* save to characteristic if it worked 
	char _dta[`cname'] `"`cmd'"' 
end


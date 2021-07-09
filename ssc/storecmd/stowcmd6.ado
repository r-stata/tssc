*! 1.0.0 NJC 10 December 1999 with code from Jeroen Weesie's -keyb- 
program define stowcmd6 
        version 6.0
	gettoken cname 0 : 0 
	if `"`0'"' == "" { error 198 } 
        
        if `"$BUF_DISP"' != "" { 
		di in g "stowed command: " in wh `". `0'"' 
	}                

	local cmd `"`0'"' 
	
	* put command in keyboard buffer 
        push `cmd' 
  
	* save to characteristic 
	char _dta[`cname'] `"`cmd'"' 
end


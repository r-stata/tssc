program def renames
*! NJC 1.2.0 22 November 2000 
* NJC 1.1.0 16 February 2000 
* NJC 1.0.0 25 August 1999 
	version 6
	
	gettoken oldvars 0 : 0 , parse("\,") 
	unab oldvars : `oldvars' 
	local nold : word count `oldvars' 
	
	gettoken punct 0 : 0, parse("\,") 
	if "`punct'" == "\" { 
		syntax newvarlist
		local nnew : word count `varlist'
		if `nold' != `nnew' { 
			di in r "lists unequal in length"
			exit 198 
		}
	} 
	else if "`punct'" == "," { 
		local 0 ", `0'"
		syntax , [ Prefix(str) Suffix(str) Truncate ] 
		if "`prefix'" != "" & "`suffix'" != "" { 
			di in r "prefix( ) and suffix( ) may not be combined" 
			exit 198 
		}
		if "`prefix'`suffix'" == "" { 
			di in r "need either prefix( ) or suffix( )" 
			exit 198 
		}	
		local i = 1 
		while `i' <= `nold' { 
			local old : word `i' of `oldvars'
			local new "`prefix'`old'`suffix'" 
			if "`truncate'" != "" { 
				local new = substr("`new'",1,8) 
			} 
			local varlist "`varlist' `new'" 
			local i = `i' + 1 
		}
		local 0 "`varlist'"
		syntax newvarlist
	} 
	else error 198 
	
	nobreak { 
		local i = 1 
		while `i' <= `nold' { 
			local old : word `i' of `oldvars'
			local new : word `i' of `varlist' 
			rename `old' `new' 
			local i = `i' + 1
		}
	}
end


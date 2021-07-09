*! 1.0.0 NJC 17 January 2003 
program define fedit
	version 8.0 
	gettoken file options : 0, parse(",") 
        discard
	qui findfile "`file'" `options' 
	doedit "`r(fn)'"
        // NJC winexec /vim/vim61/gvim.exe "`r(fn)'" 
end

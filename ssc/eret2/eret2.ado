*! version 1.0.0, Ben Jann, 01dec2004
program define eret2, eclass
	version 8.2

//determine type: local, scalar, or matrix
	gettoken type 0 : 0
	local scalar matrix
	if substr("local",1,max(3,length("`type'")))!="`type'" ///
	 & substr("scalar",1,max(3,length("`type'")))!="`type'" ///
	 & substr("matrix",1,max(3,length("`type'")))!="`type'" {
		di as err "'`type'' not allowed"
		exit 198
	}

//parse replace option
	syntax anything(equalok) [ , replace * ]
	if "`options'"!="" local options ", `options'"
	if "`replace'"=="" {
		gettoken name : anything , parse(" =:")
		capture confirm existence `e(`name')'
		if !_rc {
			di as err "e(`name') already defined"
			exit 110
		}
	}

//return results
	ereturn `type' `anything' `options'
end

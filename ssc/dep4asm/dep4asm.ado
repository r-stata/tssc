*! version 1.0.2 15sep2010 D.Klein

program dep4asm
	**set version**
	if _caller() <11 {
		local vers =_caller()
		dis as txt "this is version " as res "`vers' " ///
		as txt "of Stata; {cmd:dep4asm} " ///
		as txt "is a version 11.0 program and may " ///
		"not work properly"
	}
	else {
		version 11.0	
	}
	**temp vars**
	tempvar id cvar
	**parse arguments**
	syntax varname(numeric) [, DEPendent(name) ///
	CASE(name) ALTernatives(name)]
quietly {	
	capture assert `varlist' ==int(`varlist')
	if _rc {
		dis as err "`varlist': non-integer values " ///
		"not allowed"
		exit 109
	}
	if `"`alternatives'"' !="" confirm new var `alternatives'
	if "`dependent'" =="" {
		local dependent choice
	}
	else confirm new var `dependent'
	if "`case'" !="" {
		confirm new var `case'
		gen `case' =_n
	}
	gen long `id' =_n
	tab `varlist'
	local noc =r(r)
	clonevar `cvar' =`varlist'
	expand =`noc'
	bysort `id': replace `varlist' =_n
	gen `dependent' =0
	bysort `id': replace `dependent' =1 if _n ==`cvar'
	if "`alternatives'" !="" {
		rename `varlist' `alternatives'
		gen `varlist' =`cvar'
	}
}
end

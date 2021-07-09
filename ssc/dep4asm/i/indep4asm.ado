*! version 1.0.1 05aug2010 D.Klein

program indep4asm
	**set version**
	if _caller() <11 {
		local vers =_caller()
		dis as txt "this is version " as res "`vers' " ///
		as txt "of Stata; {cmd:indep4asm} " ///
		as txt "is a version 11.0 program and may " ///
		"not work properly"
	}
	else {
		version 11.0	
	}
	**parse arguments**
	syntax varlist(numeric) ,ALTernatives(varname numeric) ///
	GENerate(namelist)
	confirm new var `generate'
quietly {
	tab `alternatives'
	local noa =r(r)
	local nvars =0
	foreach var of varlist `varlist' {
		local ++nvars
		local old`nvars' ="`var'"
	}
	local nnew =0
	foreach nam of local generate {
		local ++nnew
		local new`nnew' ="`nam'"
	}
	local div =`nvars'/`noa'
	if `div' != ceil(`div') {
		dis as err "too few or too many variables specified"
		exit 499
	}
	if `div' > `nnew' {
		dis as err "option generate(): " ///
		"too few variables"
		exit 499
	}	
	local cnt =0
	forval j =1/`div' {
		gen `new`j'' =.
		forval k =1/`noa' {
			local ++cnt
			replace `new`j'' =`old`cnt'' ///
			if `alternatives' ==`k'
		}
	}
}
end

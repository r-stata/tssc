*! Program to create datasets of descriptive statistics from a list of variables
*! Author: P. Wilner Jeanty
*! Date: August 22, 2011
*! Version 1.00
program define stat2data, byable(recall)
	version 10.0
	syntax varlist(min=1 numeric) [if] [in] [aw fw], SAving(str) [GENerate(namelist) Statistics(str) BY(varname) casewise missing format format2(str)]
    tokenize "`saving'", parse(",") 
	args dfile forc subopts
	local enc "stat"	
	local saving=cond("`subopts'"=="replace", "`dfile', replace", "`dfile'") 
	local begc "tab"
	local forb "median q"
	if "`statistics'"!="" & `:list forb in statistics' {
		di as err "Only one of {bf:median} and {bf:q} can be requested as statistics"
		exit 198
	}	
	local stocalc=cond("`statistics'"=="", "mean", "`statistics'")
	local _locwr "`begc'`enc'"
	preserve
	tempname mstat	
	if "`by'"=="" {
		qui `_locwr' `varlist' `if' `in' `weight', stat(`stocalc') `casewise' `missing' `format' `format2' save
		mat `mstat'=r(StatTotal)'
		local varsn : rownames `mstat'
		local stnames : colnames `mstat'
		_Vnames `stnames', gen(`generate')
		local vnames `s(vnames)'
		mata:_stat2dta()
		order _name
		qui save `saving'
	}
	else {
		qui levelsof `by', local(allv) `missing' // Option missing takes care of missing values in the by variable if by() specified
		local nbv : word count `allv'
		qui `_locwr' `varlist' `if' `in' `weight', by(`by') stat(`stocalc') `casewise' `missing' `format' `format2' save
		local g=1
		foreach z of local allv {
			local val`g' : word `g' of `allv'
			local zn `z'
			if "`missing'"!="" & `z'==. local zn _mis
			tempname mv`zn'
			matrix `mv`zn''=r(Stat`g')'
			matrix `mstat' = (nullmat(`mstat') \ `mv`zn'')
			local ++g
		}
		local varsn : rownames `mstat'
		local stnames : colnames `mstat'
		_Vnames `stnames', gen(`generate')
		local vnames `s(vnames)' // This line is crucial otherwise `s(vnames)' will vanish if not captured right away.
		mata:_stat2dta()
		egen seq=seq(), f(1) to(`nbv') b(`:word count `varlist'')
		gen `by'="`val1'"
		forv i=2/`nbv' {
			qui replace `by'="`val`i''" if seq==`i'
		}
		order `by' _name
		drop seq 
		qui save `saving'  
	}
	label data "Dataset of descriptive statistics"
	di
	di as txt "Requested descriptive statistics saved to dataset: " in ye "`c(pwd)'`c(dirsep)'`dfile'"
	restore
	mata: mata clear
end	
program define _Vnames, sclass
	version 10.0
	syntax anything, [gen(string)] 
	if "`gen'"=="" {
		local vnames ""
		foreach v of local anything {
			local  vnames `vnames' s`v' // if no names specified, form variable names by prefixing each requested statistic with an s
		}
	}
	else local vnames `gen'			
	local nstat : word count `anything'
	if `:word count `vnames'' != `nstat' {
		di as err "Number of names for variables to be generated must equal number of requested statistics"
		exit 198
	}
	sreturn local vnames `"`vnames'"' // compounded quotes crucial here otherwise only the first 244 characters of `vnames' will be copied
end	
version 10.0
mata
	mata set matastrict on
	void _stat2dta() {
		st_dropvar(.)
		smat=st_matrix(st_local("mstat"))		
		st_addobs(rows(smat))
		st_store(., st_addvar("double", tokens(st_local("vnames"))), smat)
		st_sstore(., st_addvar("str12", "_name"), tokens(st_local("varsn"))')
	}	
end

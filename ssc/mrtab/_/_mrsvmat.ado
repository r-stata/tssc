*! version 1.02, Ben Jann, 22jun2004
program define _mrsvmat
	version 8.2
	syntax [ , Stat(name) RTotal CTotal noPercent noLabel clear returnstat ]

	capture confirm matrix r(responses)
	if _rc {
		di as error "Multiple response matrix not found. Use svmrmat directly after mrtab."
		exit 119
	}
	if "`clear'"=="" {
		di as txt "Warning: data in memory will be lost." _n /*
		 */ _col(10) "Press any key to continue, Ctrl-Break to abort."
		set more 0
		more
	}

//Expand stat options
	if `"`stat'"'=="" local stat freq
	else if substr("freq",1,max(1,length("`stat'")))=="`stat'" local stat "freq"
	else if substr("column",1,max(3,length("`stat'")))=="`stat'" local stat "column"
	else if substr("row",1,max(1,length("`stat'")))=="`stat'" local stat "row"
	else if substr("cell",1,max(2,length("`stat'")))=="`stat'" local stat "cell"
	else if substr("rcolumn",1,max(4,length("`stat'")))=="`stat'" local stat "rcolumn"
	else if substr("rcell",1,max(3,length("`stat'")))=="`stat'" local stat "rcell"
	else {
		di as error "invalid token in stat(): `stat'"
		exit 198
	}
	if "`percent'"=="" local percent "*100"
	else local percent

//Add totals and r(responses) to data
	tempname R
	mat `R'=r(responses)
	local Rnames: rownames `R'
	mat `R'=`R'\J(1,rowsof(`R'),1)*`R'
	local Rnames `"`Rnames' T"'
	mat rown `R'=`Rnames'
	local Cnames: colnames `R'
	mat `R'=`R',`R'*J(colsof(`R'),1,1)
	local Cnames `"`Cnames' T"'
	mat coln `R'=`Cnames'
	drop _all
	set more off
	qui svmat `R', n(C)
	local C=colsof(`R')
	ren C`C' T

//Add variables representing response items and labels
	qui gen str1 R = ""
	qui gen str1 L = ""
		if "`r(type)'"=="string" {
			local Rnames `"`r(list)' Total"'
		}
	local N=`r(r)'+1
	forv i=1/`N' {
		local rname : word `i' of `Rnames'
		qui replace R = `"`rname'"' in `i'
		if "`r(type)'"!="string"&"`label'"==""&`"`r(list)'"'!="" {
			local rlname : word `i' of `r(list)' Total
			qui replace L = `"`rlname'"' in `i'
		}
	}
	order R L
	if "`r(type)'"=="string"|"`label'"!=""|`"`r(list)'"'=="" drop L

//Add group lables
	if "`r(c)'"!="" {
		if (`"`label'"'==""&`"`r(bylist)'"'!="")|"`r(bytype)'"=="string" {
			local Cnames `"`r(bylist)' Total"'
		}
		local j 1
		foreach var of var C* T {
			local cname : word `j++' of `Cnames'
			lab var `var' `"`cname'"'
		}
	}

//Calculate statistics
	if "`stat'"=="column" {
		tempname B
		if "`r(c)'"=="" {
			mat `B'=`r(N)'
		}
		else {
			mat `B'=r(cases)
		}
		mat `B'=`B',`r(N)'
		local j 1
		foreach var of var C* T {
			qui replace `var'=`var'/`B'[1,`j++']`percent'
		}
	}
	else if "`stat'"=="row" {
		foreach var of var C* T {
			qui replace `var'=`var'/T`percent'
		}
	}
	else if "`stat'"=="cell" {
		foreach var of var C* T {
			qui replace `var'=`var'/`r(N)'`percent'
		}
	}
	else if "`stat'"=="rcolumn" {
		foreach var of var C* T {
			qui replace `var'=`var'/`var'[`N']`percent'
		}
	}
	else if "`stat'"=="rcell" {
		foreach var of var C* T {
			qui replace `var'=`var'/T[`N']`percent'
		}
	}

//Drop totals
	if "`ctotal'"=="" {
		qui drop in l
	}
	if "`rtotal'"=="" {
		drop T
	}

//Returns
	if "`returnstat'"!="" c_local stat `stat'
end

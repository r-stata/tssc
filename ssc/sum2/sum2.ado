
* sum2 1.0.0 Jan2009 by roywada@hotmail.com

program define sum2, eclass
*program define sum2, eclass by(recall) sortpreserve
version 7.0
/*
syntax [varlist] [using] [if] [in] [pweight aweight iweight] [,	/*
	*/ APpend REPLACE esample drop(string) 				/*
	*/ noDISplay log REGress DETail NODEPendent ]
*/

syntax [, REPLACE]



local _0 `"`0'"'


qui {
	* invisible to Stata 7
	local Version7 ""
	cap local Version7 `c(stata_version)'
	
	if "`Version7'"=="" {
		* it is version 7
		*noi di in yel "limited functions under Stata 7"
	}
	else if `Version7'>=8.2 {
		version 8.2
	}


if "`log'"=="log" & "`detail'"=="detail" {
	noi di in red "cannot choose both {opt det:ail} and {opt log}"
	exit 198
}

if "`log'"~="log" & "`detail'"~="detail" {
	local regress "regress"
}


if "`regress'"=="regress" {
	* check for prior sum2, replace
	foreach var in eqlist {
		if "`e(cmd)'"=="sum2, log" {
			if "`Version7"~="" {
				*eret list
			}
			else {
				*est list
			}
			noi di in red "no regression detected; already replaced with summary"
			exit 198
		}
	}
	
	*** replace varlist with e(b) names
	regList `_0'
	
	local varlist `r(varlist)'
	local eqlist `r(eqlist)'
	
	local varnum `r(varnum)'
	local eqnum `r(eqnum)'
}
else {
	local varnum: word count `varlist'
	local eqnum 0

}

local varlist `"`eqlist' `varlist'"'


* take tempvars out
*tsunab stuff : __00*

macroMinus `varlist', names(varlist) subtract(`stuff')
local varnum: word count `varlist'

* extender
local N=_N
version 7: describe, short
if `r(k)'>`N'+1 & `r(k)'<. {
	set obs `r(k)'
}


if "`drop'"~="" {
	ds `drop'
	local drop `r(varlist)'
	*cap local varlist: list varlist - drop
	macroMinus `varlist', names(varlist) subtract(`drop')
}



if `=_by()'==1 {
	* eliminate -by- variables from varlist
	local drop `_byvars'
	*cap local varlist: list varlist - drop
	macroMinus `varlist', names(varlist) subtract(`drop')
}


*marksample touse
*marksample alluse, noby
*tempvar touse alluse

tempvar touse
*mark `alluse'  `if' `in', noby


* always esample restricted
if `"`if'"'~="" {
	mark `touse' `if' & e(sample)==1 `in'
}
else {
	mark `touse' if e(sample)==1 `in'
}


count if `touse'==1
if `r(N)'==0 {
	noi di in red "no observation left; check your if/in conditionals"
	exit 198
}

*** must take out string variables prior to marking them
local stringList ""
local noobsList ""
local anyObs 0
foreach var in `varlist' {
	sum `var' if `touse' [`weight'`exp'], meanonly
	if r(N)==0 {
		local minus "`var'"
		*cap local varlist: list varlist - minus
		macroMinus `varlist', names(varlist) subtract(`minus')
		
		if "`Version7'"=="" {
			local varlist=subinstr("`varlist'","`minus'","",.)
		}
		
		local type: type `var'
		local check= substr("`type'",1,3)
		
		* display later
		if "`check'"=="str" {
			*noi di in yellow "`var' is string, not included"
			local stringList "`stringList' `var'"
		}
		else {
			*noi di in yellow "`var' has no observation, not included"
			local noobsList "`noobsList' `var'"
		}
	}
	else {
		local anyObs 1
	}
	local varnum: word count `varlist'
}


tempvar name N mean sd min max zeros
tempname ebmat eVmat 
tempvar sum_w Var skewness kurtosis sum p1 p5 p10 p25 p50 p75 p90 p95 p99

local varname ""

foreach var in `varlist' {
	qui sum `var' if `touse' [`weight'`exp'], `detail'
	if r(N)~=0 {
		local varname "`varname' `var'"
		local row=`row'+1
		
		foreach var in mean sd N min max {
			mat ``var'' = nullmat(``var'') \ r(`var')
		}
		mat `zeros' = nullmat(`zeros') \ 0
	}
	if "`detail'"=="detail" & r(N)~=0 {
		foreach var in sum_w Var skewness kurtosis sum p1 p5 p10 p25 p50 p75 p90 p95 p99 {
			mat ``var'' = nullmat(``var'') \ r(`var')
		}
	}
}

* rename them
if "`regress'"=="regress" {
	foreach var in mean sd N min max {
	mat rownames ``var''=`varname'
	mat colnames ``var''=`var'
	}
}
if "`log'"=="log" {
	foreach var in N mean sd min max {
		mat rownames ``var''=`varname'
		mat roweq ``var''=`var'
		mat colnames ``var''=`var'
	}
}
if "`detail'"=="detail" {
	foreach var in N mean sd min max sum_w Var skewness kurtosis sum p1 p5 p10 p25 p50 p75 p90 p95 p99 {
		mat rownames ``var''=`varname'
		mat roweq ``var''=`var'
		mat colnames ``var''=`var'
	}
}

if "`display'"~="nodisplay" & `anyObs'==1 {
	noi sum `varlist' if `touse' [`weight'`exp'], `detail'
}


if `=_by()'==1 {
	* generate column heading when -by- specified
	local cc=1
	local ctitle ""
	
	tokenize `_byvars'
	while "``cc''"~="" {
		
		* should there be `touse' here?
		qui sum ``cc'' if `_byindex' == `=_byindex()' & `touse'
		if r(N)<. {
			local actual`cc' =r(mean)
		}
		else {
			local actual`cc' =.			
		}
		
		* place ctitle in there
		local ctitle "`ctitle' ``cc'' `actual`cc'' "
		local cc=`cc'+1
	}
	
	* replace last if -by- specified
	if `=_byindex()'~=1 & "`replace'"=="replace" {
		local replace ""
	}
}

	* exporting temp matrices	
	if "`regress'"=="regress" {
		mat `ebmat' = `mean'
		mat `eVmat' = `sd'
		
		mat `ebmat'=`ebmat''
		mat `eVmat'=(`eVmat'*`eVmat'')
	}
	else if "`log'"=="log" {
		foreach var in N mean sd min max {
			mat `ebmat' = nullmat(`ebmat') \ ``var'' 
			mat `eVmat' = nullmat(`eVmat') \ `zeros'
		}
		
		* rename eVmat after ebmat
		local colnames: colnames `ebmat'
		local roweq: roweq `ebmat'
		local rownames: rownames `ebmat'
		
		mat colnames `eVmat'=`colnames'		
		mat roweq `eVmat'=`roweq'
		mat rownames `eVmat'=`rownames'
		
		mat `ebmat'=`ebmat''
		mat `eVmat'=(`eVmat'*`eVmat'')
	}
	else if "`detail'"=="detail" {
		foreach var in N mean sd min max sum_w Var skewness kurtosis sum p1 p5 p10 p25 p50 p75 p90 p95 p99 {
			mat `ebmat' = nullmat(`ebmat') \ ``var''
			mat `eVmat' = nullmat(`eVmat') \ `zeros'
		}
		
		* rename eVmat after ebmat
		local colnames: colnames `ebmat'
		local roweq: roweq `ebmat'
		local rownames: rownames `ebmat'
		
		mat colnames `eVmat'=`colnames'		
		mat roweq `eVmat'=`roweq'
		mat rownames `eVmat'=`rownames'
		
		mat `ebmat'=`ebmat''
		mat `eVmat'=(`eVmat'*`eVmat'')
	}
	
	if "`replace'"=="replace" {
		if "`Version7'"=="" {
			est mat mean `ebmat'
			est mat Var `eVmat'
			
			count if `touse'==1
			est scalar N = r(N)
		}
		else {
			eret clear
			mat b=`ebmat'
			mat V=`eVmat'
			mat list b
			eret post b V
			if `"`if'"'~="" {
				gettoken first second: if, parse(" ")
				eret local depvar `"`second'"'
			}
			else {
				eret local depvar `"Summary"'
			}
			eret local cmd "sum2, log"
			
			if "`regress'"=="regress" {
				count if `touse'==1
				eret scalar N = r(N)
			}
		}
	}
	else {
		if "`Version7'"=="" {
			est mat mean `ebmat'
			est mat Var `eVmat'
			
			if "`regress'"=="regress" {
				count if `touse'==1
				est scalar sum_N = r(N)
			}
		}
		else {
			eret mat mean=`ebmat'
			eret mat Var=`eVmat'
			
			if "`regress'"=="regress" {
				count if `touse'==1
				eret scalar sum_N = r(N)
			}
		}
	}

/*
else {
	if `=_by()'==1 {
		noi di in yellow "no observations when variable = something"
	}
	else {
		* `=_by()'~=1, not running by( )
		*noi di in red "no observations"
		error 2000
	}
}
*/

noi di
if `"`stringList'"'~="" {
	noi di in yellow "Following variable is string, not included:  "
	foreach var in `stringList' {
		noi di in yellow "`var'  " _c
	}
	di
}
if `"`noobsList'"'~="" {
	noi di in yellow "Following variable has no observation, not included:  "
	foreach var in `noobsList' {
		noi di in yellow "`var'  " _c
	}
	di
}

} /* qui */
end /* sum2 */



********************************************************************************************


* regList Jan2009 by roywada@hotmail.com

program define regList, rclass
* get the name of equations and variables used in e(b)
	version 7.0
	* [if] [in] ignored:
	syntax [varlist(default=none)] [if] [in] [, NODEPendent *]
	
	* separate potential equation names from variable names
	tempname b b_transpose
	mat `b'=e(b)
	mat `b_transpose' = `b''
	local Names : rowfullnames(`b_transpose')
	local Rows = rowsof(`b_transpose')
	forval num=1/`Rows' {
		local temp : word `num' of `Names'
		tokenize "`temp'", parse(":")
		if "`2'"==":" {
			local eqlist = "`eqlist' `1'"
			local varnames = "`varnames' `3'"
		}
		else {
			local varnames = "`varnames' `temp'"
		}
	}
	
if "`nodependent'"~="nodependent" {
	* indep variables, but the equations names are actually dep variables
	* plus the dep var
	local eqlist `e(depvar)' `eqlist'
	macroUnique `eqlist', names(eqlist) number(eqnum)
	
	* take off numbers from the front (reg3 sometimes slaps them on)
	foreach v in `eqlist' {
		local first = substr(`"`v'"',1,1)
		local test
		cap local test = `first' * 1
		if "`test'"=="`first'" {
			* a number
			local wanted = substr(`"`v'"',2,.)
			local collect "`collect' `wanted'"
		}
		else {
			local collect "`collect' `v'"
		}
	}
	local eqlist `collect'
	macroUnique `eqlist', names(eqlist) number(eqnum)
	
	* repeat
	foreach v in `eqlist' {
		local first = substr(`"`v'"',1,1)
		local test
		cap local test = `first' * 1
		if "`test'"=="`first'" {
			* a number
			local wanted = substr(`"`v'"',2,.)
			local collect "`collect' `wanted'"
		}
		else {
			local collect "`collect' `v'"
		}
	}
	local eqlist `collect'
macroUnique `eqlist', names(eqlist) number(eqnum)
}
	
	
	macroUnique `eqlist', names(eqlist) number(eqnum)
	macroMinus `varnames', names(varlist) number(varnum) subtract(_cons)
	
	return local eqlist `eqlist'
	return local eqnum `eqnum'
	return local varlist `varlist'
	return local varnum `varnum'
	
end /* regList */


********************************************************************************************


* macroUnique Jan2009 by roywada@hotmail.com
program define macroUnique
version 7.0
* gets you unique macro names & number of them (both c_locals)
* could be empty

syntax [anything], names(string) [number(string)]
	local collect ""
	* just holding the place until the loop
	local temp1: word 1 of `anything' 
	local temp2: word 2 of `anything'
	
	local total: word count `anything'
	local cc 1
	local same ""
	while "`temp1'"~="" {
		local temp1: word `cc' of `anything'
		local same ""
		*di "try `temp1' at `cc'"
		local kk=`cc'+1
		local temp2: word `kk' of `anything'
		while "`temp2'"~="" & "`same'"=="" {
			if "`temp1'"=="`temp2'" {
 				*di "`cc' is same as `kk'"
				local same same
			}
			else {
				local kk=`kk'+1
			}
			local temp2: word `kk' of `anything'
		}
		if "`temp1'"~="" & "`temp2'"=="" & "`same'"~="same" {
			*di "accept `temp1' at `cc' before " _c
			local collect "`collect' `temp1'"
		}
		*di "reject `temp1' at `cc'"
		local cc=`cc'+1
	}
	
	c_local `names' `collect'
	if "`number'"~="" {
		c_local `number' : word count `collect'
	}
end


********************************************************************************************


* macroMinus Jan2009 by roywada@hotmail.com
program define macroMinus

* gets you macro names subtracted & number of them (both c_locals)
* could be empty
version 7.0
syntax [anything], names(string) [number(string) subtract(string)]
	local collect ""
	* just holding until the loop
	local temp1: word 1 of `anything' 
	local temp2: word 1 of `subtract'
	
	local total: word count `anything'
	local cc 1
	local same ""
	while "`temp1'"~="" {
		local temp1: word `cc' of `anything'
		local same ""
		*di "try `temp1' at `cc'"
		local kk=1
		local temp2: word `kk' of `subtract'
		while "`temp2'"~="" & "`same'"=="" {
			if "`temp1'"=="`temp2'" {
 				*di "`temp1' is same as `temp2'"
				local same same
			}
			else {
				local kk=`kk'+1
			}
			local temp2: word `kk' of `subtract'
		}
		if "`temp1'"~="" & "`temp2'"=="" & "`same'"~="same" {
			*di "accept `temp1' at `cc' before " _c
			local collect "`collect' `temp1'"
		}
		*di "reject `temp1' at `cc'"
		local cc=`cc'+1
	}
	
	c_local `names' `collect'
	if "`number'"~="" {
		c_local `number' : word count `collect'
	}

end


********************************************************************************************

/* issues:
__00*



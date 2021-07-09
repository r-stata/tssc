
*! version 1.0.2 13oct2009 caplog by roywada@hotmail.com
*! captures a log file, possibly for use with logout or dataout

program define caplog
version 6

local logfile : log

version 7

* invisible to Stata 7
local Version7 ""
cap local Version7 `c(stata_version)'

if "`Version7'"=="" {
	* it is version 7
	local bind ""
	*noi di in yel "limited functions under Stata 7"
}
else if `Version7'>=8.2 {
	version 8.2
	local bind "bind"
}

*qui log query
*if `"`r(status)'"'=="on" {
*	qui log close
*	local filename `"`r(filename)'"'
*}

if `"`logfile'"'~="" {
	di ""
	qui log close
	local filename `"`logfile'"'
}

* embbed to avoid log being open
_caplog `0'

cap log close

*** c_locals coming back
* clickables
if "`tempfile'"~="tempfile" {
	if "`smcl'"=="" {
		local cl_text `"{browse `"`using1'"'}"'
		noi di as txt `"`cl_text'"'
	}
	else {
		local cl_text `"{stata `"view `using1'"':`using1'}"'
		noi di as txt `"`cl_text'"'
	}
}

cap log close

*if `"`filename'"'~="" {
*	log using `"`filename'"', append
*}

end


********************************************************************************************


program define _caplog
version 7

local Version7 ""
cap local Version7 `c(stata_version)'

if "`Version7'"=="" {
	* it is version 7
	local bind ""
	*noi di in yel "limited functions under Stata 7"
}
else if `Version7'>=8.2 {
	version 8.2
	local bind "bind"
}

* encase the colon in file name in quotes, avoiding string function length limits

local behind `"`0'"'
local 0 ""
gettoken front behind: behind, parse(" ,")
local 0 ""
local done 0
while `"`front'"'~="" & `done'==0 {
	if `"`front'"'=="using" {
		
		gettoken rest behind: behind, parse(" ,")
		* strip off quotes
		gettoken first second: rest, parse(" ")
		cap local rest: list clean local(rest)
		
		* take off colon at the end
		local goldfish ""
		if index(`"`rest'"',":")~=0 {
			local end=substr(`"`rest'"',length(`"`rest'"'),length(`"`rest'"'))
			if "`end'"==":" {
				local rest=substr(`"`rest'"',1,`=length(`"`rest'"')-1')
				local goldfish " : "
			}
		}
		
		* colon reattached with a space at the end
		* .txt attached here, SMCL TO BE FIXED LATER
		local rabbit `"""'
		if index(`"`rest'"', ".")==0 {
			local using `"`rabbit'`rest'.txt`rabbit'`goldfish'"'
		}
		else {
			local using `"`rabbit'`rest'`rabbit'`goldfish'"'
		}
		local 0 `"`0' using `using' `behind'"'
		local done 1
	}
	else {
		local 0 `"`0' `front'"'
		gettoken front behind: behind, parse(" ,")
	}
}


gettoken first second : 0, parse(":") `bind' match(par) quotes
local 0 `"`first'"'
while `"`first'"'~=":" & `"`first'"'~="" {
	gettoken first second : second, parse(":") `bind' match(par) quotes
}
if `"`0'"'==":" {
	* colon only when shorthand combined with prefix
	local 0
}
else {
	local _0 `"`0'"'
}

*** shorthand syntax if [using] is missing

syntax using/ [, replace append tempfile text smcl subspace]

if "`smcl'"=="smcl" {
	if index(`"`using'"', ".txt")~=0 {
		local temp=substr(`"`using'"',1,length(`"`using'"')-4)
		local using `"`temp'.smcl"'
	}
}

if "`text'"~="" & "`smcl'"~="" {
	di "cannot choose both {opt text} and {opt smcl}"
	exit 198
}

if "`text'"=="" & "`smcl'"=="" {
	local text "text"
}


cap confirm file `"`using'"'
if !_rc & "`replace'"~="replace" & "`append'"~="append" {
	* it exists
	noi di in red `"`using' exists; specify {opt replace} or {opt append}"'
	exit 198
}

* goes with `second'
if `"`second'"'~="" {
	local _colon ":"
}

qui {
	if "`subspace'"=="subspace" {
		* fix the gaps in the value labels
		ds8
		foreach var in `r(varlist)'{
			local temp : var label `var'
			local temp = subinstr(`"`temp'"'," ","_",.)
			label var `var' `"`temp'"'
		}
	}
}

	* regular stuff
	if `"`using'"'~="" {
		* prefix use using file
		qui log using `"`using'"', `replace' `append' `text' `smcl'
		`second'
	}
	else {
		* prefix use temp file
		qui log using `"`using'"', `replace' `append' `text' `smcl'
		`second'
	}

* clickables
c_local smcl "`smcl'"
c_local using1 `"`using'"'
c_local tempfile `"`tempfile'"'

end


********************************************************************************************


*** ripped from outreg2 Mar 2009
program define ds8
	* get you the list of variable like -ds- does for version 8
	version 7.0
	qui ds
	if "`r(varlist)'"=="" {
		local dsVarlist ""
		foreach var of varlist _all {
			local dsVarlist "`dsVarlist' `var'"
		}
		c_local dsVarlist `dsVarlist'
	}
	else {
		c_local dsVarlist `r(varlist)'
	}
end




/*
* version 1.0.1 May2009 caplog by roywada@hotmail.com
smcl accepted
version control fixed

1.0.2 close the log file at the end to avoid the possibility of it being left open


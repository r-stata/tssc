*realcomImpute Jonathan Bartlett jwb133@googlemail.com
*created 28th July 2010
*email contact updated 18th April 2017
program define realcomImpute
version 11.1
syntax anything using/, [replace] NUMRESPonses(integer) cons(varname) level2id(varname) [level1wgt(varname)] [level2wgt(varname)]
tokenize `anything'
local nvars : word count `anything'
local numauxvars = `nvars'-`numresponses'
if `numauxvars'<0 {
	display "You have specified variable names for fewer variables than the number given in the numresponses option."
}
else {

*find response variable names
local respvars
forvalues i=1(1)`numresponses' {
	local respvars `respvars' `1'
	macro shift
}

*find auxiliary variable names
local auxvars `*'
local numauxvars = `nvars'-`numresponses'

*determine types of response variables - following code used by ice command
tokenize `respvars'
local respvars_withoutprefix
forvalues i=1(1)`numresponses' {
	local prefix = substr("``i''",1,2)
	local therest = substr("``i''",3,.)
	if "`prefix'"=="m." {
		local type`i' = 2
		local respvars_withoutprefix `respvars_withoutprefix' `therest'
	}
	else if "`prefix'"=="o." {
		local type`i' = 3
		local respvars_withoutprefix `respvars_withoutprefix' `therest'
	}
	else {
		local type`i' = 1
		local respvars_withoutprefix `respvars_withoutprefix' ``i''
	}
}

*now perform some checks
*check variables exist
confirm variable `respvars_withoutprefix' `auxvars'

local numobs = _N
*for each response variable, work out if it is level 1 or level 2
tokenize `respvars_withoutprefix'
quietly by `level2id': egen withinlevel2var=sd(`1')
quietly summ withinlevel2var
if r(mean)==0 {
	local lastvarlevel 2
}
else {
	local lastvarlevel 1
}
drop withinlevel2var
forvalues i=2(1)`numresponses' {
	quietly by `level2id': egen withinlevel2var=sd(``i'')
	quietly summ withinlevel2var
	if r(mean)==0 {
		local lastvarlevel 2
	}
	else {
		if `lastvarlevel'==2 {
			di as error "Level 2 response variables must follow level 1 responses - please re-order response variables."
			drop withinlevel2var
			exit 2003
		}
		local lastvarlevel 1
	}
	drop withinlevel2var
}

di "`numresponses' responses: `respvars'"
di "`numauxvars' auxiliary variables: `auxvars'"

*save file ready for REALCOM to load
local stoppos = strpos("`using'",".")
if `stoppos'==0 {
	local savename `using'.txt
}
else {
	local savename `using'
}
file open myFile using `savename', write `replace'
file write myFile "`numresponses'" _n
local numauxvarstotal = `numauxvars'+2
file write myFile "`numauxvarstotal'" _n

file write myFile "`type1'"
forvalues i=2(1)`numresponses' {
	file write myFile _tab
	file write myFile "`type`i''"
}
file write myFile _n

*write variable names
local myvarlist `respvars_withoutprefix' `level2id' `cons' `auxvars'
tokenize `myvarlist'
local myvarlistlength = `numresponses' + 2 + `numauxvars'
file write myFile "`1'"
forvalues i=2(1)`myvarlistlength' {
	file write myFile _tab
	file write myFile "``i''"
}
file write myFile _n

*now write data
forvalues i=1(1)`numobs' {
	if `1'[`i']==. {
		file write myFile (-9.999e+029)
	}
	else {
		file write myFile (`1'[`i'])
	}
	forvalues j=2(1)`myvarlistlength' {
		if ``j''[`i']==. {
			file write myFile _tab (-9.999e+029)
		}
		else {
			file write myFile _tab (``j''[`i'])
		}
	}
	file write myFile _n
}

file close myFile
di "Data saved to","`savename'"

*write weights file (with two columns of 1's if weights not specified)
local stoppos = strpos("`using'",".")
if `stoppos'==0 {
	local weightsname `using'_wts.txt
}
else {
	local core = substr("`using'",1,`stoppos'-1)
	local ext = substr("`using'",`stoppos',length("`using'")-`stoppos'+1)
	local weightsname `core'_wts`ext'
}
*write weights to file
file open myFile using `weightsname', write `replace'
if "`level1wgt'"=="" & "`level2wgt'"=="" {
	forvalues i=1(1)`numobs' {
		file write myFile (1) _tab (1) _n
	}
}
else if "`level1wgt'"!="" & "`level2wgt'"=="" {
	forvalues i=1(1)`numobs' {
		file write myFile (`level1wgt'[`i']) _tab (1) _n
	}
}
else if "`level1wgt'"=="" & "`level2wgt'"!="" {
	forvalues i=1(1)`numobs' {
		file write myFile (1) _tab (`level2wgt'[`i']) _n
	}
}
else {
	forvalues i=1(1)`numobs' {
		file write myFile (`level1wgt'[`i']) _tab (`level2wgt'[`i']) _n
	}
}
file close myFile

}

end

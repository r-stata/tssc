program define estsave, eclass
version 8.2
*! v 2.2 by Michael Blasnik fixes multiple depvar bug?
syntax ,  [ Gen(str) From(str) Label(str) REPlace]
if "`gen'`from'"=="" {
	di as error "Must specify either gen or from"
	exit 198
}

if "`gen'"!="" {
local scalars: e(scalars)
local macros: e(macros)
local matrices: e(matrices)
local functions: e(functions)
local cmd "`e(cmd)'"
noi display as text " Saving estimates from `cmd', generating `gen' "
* assume that functions only contains one function -- e(sample)
if "`replace'"!="" cap drop `gen'
if "`functions'"!="" gen byte `gen'=e(`functions')
else gen byte `gen'=1
local i=1
foreach s of local scalars {
	char `gen'[sname_`i'] "`s'"
	local val: di %18.0g `e(`s')'
	local val=trim("`val'")
	char `gen'[sval_`i'] "`val'"
	local i=`i'+1
}
local i=1
foreach m of local macros {
	char `gen'[mname_`i'] "`m'"
	char `gen'[mval_`i'] "`e(`m')'"
	if "`m'"=="depvar" local depname "`e(`m')'"
	local i=`i'+1
}
tempname Mat
local i=1
foreach M of local matrices {
	mat `Mat'=e(`M')
	local nrows=rowsof(`Mat') 
	local ncols=colsof(`Mat')
	local rnames: rowfullnames(`Mat')
	local cnames: colfullnames(`Mat')
	char `gen'[M`i'name] "`M'"
	char `gen'[M`i'rnames] "`rnames'"
	char `gen'[M`i'cnames] "`cnames'"
	forvalues row=1/`nrows' {
		local rowvals
		forvalues col=1/`ncols' {
			local lval: di %18.0g `Mat'[`row',`col']
			local lval=trim("`lval'")
			local rowvals "`rowvals' `lval'"
		}
		char `gen'[M`i'R`row'] "`rowvals'"
	}
	local i=`i'+1
}
label var `gen' "estsave results: `cmd' `depname' `label'"
}

* else it's restoring
else {

local varlab: var label `from'
local i=1
while "``from'[sname_`i']'" !="" {
	local sname`i': char `from'[sname_`i']
	local sval`i': char `from'[sval_`i']
	if "`sname`i''"=="N" local obspost " obs(`sval`i'') "
	if "`sname`i''"=="df_r" local df_rpost " dof(`sval`i'') "
	local i=`i'+1
}
local scnt=`i'-1
local i=1
while "``from'[mname_`i']'" !="" {
	local mname`i': char `from'[mname_`i']
	local mval`i': char `from'[mval_`i']
	if "`mname`i''"=="depvar" local depnames "`depnames' `mval`i'' "
	if "`mname`i''"=="cmd" local cmdname "`mval`i''"
	local i=`i'+1
}

local depnamecnt: word count `depnames'
if `depnamecnt'==1 local depnamepost " depname(`depnames') "

local maccnt=`i'-1
local i=1
while "``from'[M`i'name]'" !="" {
	local matname`i':char `from'[M`i'name]
	tempname thisrow mat`i'
	local nrows :word count ``from'[M`i'rnames]'
	forvalues row=1/`nrows' {
		matrix input `thisrow'=(``from'[M`i'R`row']')
		matrix `mat`i''=nullmat(`mat`i'')\ `thisrow'
	}
	matrix rownames `mat`i'' = ``from'[M`i'rnames]'
	matrix colnames `mat`i'' = ``from'[M`i'cnames]'
	if "`matname`i''"=="b" local matb "`mat`i''"
	if "`matname`i''"=="V" local matV "`mat`i''"
	local i=`i'+1
}
local matcnt=`i'-1
if "`matb'"!="" & "`matV'"!="" {
tempvar e_sample
qui gen byte `e_sample'=`from'
ereturn post `matb' `matV', esample(`e_sample') `depnamepost' `obspost' `df_rpost'
}
forval i=1(1)`matcnt' {
	if !inlist("`matname`i''","b","V") {
		ereturn matrix `matname`i'' `mat`i''
	}
}
forval i=1(1)`scnt' {
		ereturn scalar `sname`i''=`sval`i''
}
forval i=1(1)`maccnt' {
	if "`mname`i''"!="cmd" {
		ereturn local `mname`i'' "`mval`i''"
	}
}
ereturn local cmd "`cmdname'"
noi di "retrieved estimates from `from' - `varlab'"
cap `cmdname'
if _rc==0 {
`cmdname'
}
else {
ereturn disp
}
}
end




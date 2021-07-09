*! version 1.0.0 18May2009 tabone by roywada@hotmail.com
*! export single or multiple tabulations into various output formats

prog define tabone
version 8
syntax varlist(min=1) using/, [excel word tex replace auto(numlist max=1) NOAUTO dec(numlist max=1)]

* checking the existence
cap which dataout.ado
if _rc~=0 {
	ssc install dataout, replace
}
cap which logout.ado
if _rc~=0 {
	ssc install logout, replace
}

preserve

tempfile mydata
qui save `mydata', replace
foreach var of local varlist {
	qui use `mydata', clear
	cap log close
	logout, clear : tab `var'
	qui drop in 1
	qui sort t1
	qui drop t4
	qui ren t2 `var'
	qui ren t3 `var'594852963
	* check for label stuff
	if `var'[2]=="Freq." {
		qui drop in 1/2
	}
	if `var'[1]=="Freq." {
		qui drop in 1
	}
	qui tempfile mydata`var'
	qui save `mydata`var'', replace
}

qui {

clear
set obs 1
gen str3 t1=""
sort t1
foreach var of local varlist {
	merge t1 using `mydata`var''
	drop _merge
	sort t1
}

tempvar id
gen `id'=_n
forval num=1/`=_N' {
	set obs `=`=_N'+1'
	replace `id'=`num'+.5 in `=_N'
	sort `id'
}

foreach var of local varlist {
	replace `var'="(" + `var'594852963[_n-1] + ")" if `var'=="" &  `var'594852963[_n-1]~=""
}
drop *594852963

ren t1 values
drop in 1
drop `id'

} /* qui */

if "`auto'"=="" & "`dec'"=="" {
	local auto 2
}

local test="`excel'`word'`tex'"
if "`test'"=="" {
	local beg_dot = index(`"`using'"',".")
	if `beg_dot'~=0 {
		local strippedname = substr(`"`using'"',1,`=`beg_dot'-1')
	}
	else {
		local strippedname `"`using'"'
	}
	outsheet using `strippedname'.txt, nonames `replace' noquote
}
else {
	dataout, save(`using') `excel' `word' `tex' `replace' `noauto' auto(`auto') dec(`dec')
}
end
exit

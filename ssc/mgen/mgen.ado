*! version 1.00, Ben Jann, 16mar2004

program define mgen
version 8.2
syntax anything(name=eqlist id="equation list" equalok), In(name) Out(name) [ Common(string) ]
local rownames: rownames(`in')
preserve
drop _all
set more off
qui svmat double `in', name(col)
tokenize `"`eqlist'"'
while `"`1'"'!="" {
	gettoken var: 1, parse("=")
	local newvars "`newvars'`var' "
	capture confirm new v `var'
	if !_rc qui gen double `1'`common'
	else qui replace `1'`common'
	macro shift
}
mkmat `newvars', mat(`out')
matrix rown `out'=`rownames'
mat list `out'
end
exit

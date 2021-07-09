*! soepren.ado 1.0, kohler@wz-berlin.de
program define soepren
version 7.0
syntax varlist, NEWstub(string) Waves(numlist integer)

local nvars: word count `varlist'
local nwaves: word count `waves'
if `nvars' ~= `nwaves' {
	display as error "lists have unequal number of elements"
	exit 198
}

tokenize `waves'
foreach var of varlist `varlist' {
	ren `var' `newstub'`1'
	note `newstub'`1': SOEP-Name `var'
	mac shift
}
end
exit

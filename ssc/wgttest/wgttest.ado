*! version 1.0 08jun2003
*! Ben Jann, ETH Zurich, Switzerland
program define wgttest, byable(recall)
version 8.0
syntax varlist(min=1) [if] [in] , WGT(varlist max=1 numeric) /*
 */ [ CMD(string) PREfix(string) TESTOPT(string) noNOISE *]
if length("`prefix'") > 4 {
	di as err "invalid stub name, name too long ( >4 )"
	exit 198
}
if "`prefix'"=="" local prefix "_I"
if "`cmd'"=="" local cmd "regress"
if "`noise'"=="nonoise" local qui "qui"
marksample touse
markout `touse' `wgt'
tokenize `varlist'
macro shift
while "`1'"!="" {
	qui gen `prefix'`1'X`wgt'=`1'*`wgt' if `touse'
	local varlistXwgt "`varlistXwgt'`prefix'`1'X`wgt' "
	macro shift
}
`qui' `cmd' `varlist' `wgt' `varlistXwgt' if `touse', `options'
test `wgt' `varlistXwgt', `testopt'
if "`varlistXwgt'"!="" drop `varlistXwgt'
end
exit

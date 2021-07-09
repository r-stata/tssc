program define mcenter
version 8
syntax varlist [if] [in],[hl(varlist)] [sd(real 1.0)]
quietly reg `varlist' `if' `in'
marksample touse
foreach var of varlist `varlist'  {
	quietly summarize `var' if `touse'==1
	local n = r(N)
	local m = r(mean)
	local s = sqrt(r(Var)) 
	tempvar `var'
	global var: permname C_`var'
	quietly gen $var =`var'-`m' if `touse'==1
	label var $var "mean centered `var' (`varlist' `if' `in')"
	summarize $var if `touse'==1
}
local hlcount: word count `hl'
if `hlcount' != 0 {
foreach var of varlist `hl'  {
	quietly summarize `var' if `touse'==1
	local n = r(N)
	local m = r(mean)
	local s = sqrt(r(Var)) 
	tempvar `varlo' `varhi'
	global varlo: permname C_`var'lo
	quietly gen $varlo =(`var'-`m') +`s'*`sd' if `touse'==1
	label var $varlo "centered `var' mean + `sd'sd (`varlist' `if' `in')"
	global varhi: permname C_`var'hi
	quietly gen $varhi =(`var'-`m') -`s'*`sd' if `touse'==1
	label var $varhi "centered `var'mean  - `sd'sd (`varlist' `if' `in')"
	summarize $varlo $varhi if `touse'==1
}
}
end

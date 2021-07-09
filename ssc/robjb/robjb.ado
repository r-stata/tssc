
*Wouter Gelade and Vincenzo Verardi
*Version 1.1

cap program drop robjb
program define robjb, rclass


* Robust Jarque-Bera Normality test


version 10.0


if replay()& "`e(cmd)'"=="robjb" {
	ereturn  display
exit
}

syntax varname [if] [in], [Skewness Kurtosis Right level(real 0.95)]
marksample touse
tempname mu sigma TM mc lmc rmc

qui sum `varlist' if `touse'
local n=r(N)
local nw: word count `varlist'
if `level'>=1|`level'<=0 {
di in r "Error: level should be between 0 and 1"
exit 198
}

if "`skewness'"!="" {
matrix `mu'=0
matrix `sigma'=1.25
qui medcouple `varlist' if `touse'
matrix `mc'=e(mc)
matrix `TM'=`n'*(`mc'*invsym(`sigma')*`mc')
local T=`TM'[1,1]
local dof=1
}

else if "`kurtosis'"!="" {
matrix `mu'=(0.199,0.199)
matrix `sigma'=(2.62,-0.0123\-0.0123,2.62)
qui medcouple `varlist' if `touse', no lmc rmc
matrix `mc'=(e(lmc),e(rmc))
matrix `TM'=`n'*((`mc'-`mu')*invsym(`sigma')*(`mc'-`mu')')
local T=`TM'[1,1]
local dof=2
}

else if "`right'"!="" {
matrix `mu'=(0.199)
matrix `sigma'=(2.62)
qui medcouple `varlist' if `touse', no rmc
matrix `mc'=(e(rmc))
matrix `TM'=`n'*((`mc'-`mu')*invsym(`sigma')*(`mc'-`mu')')
local T=`TM'[1,1]
local dof=1
}

else {
matrix `mu'=(0,0.199,0.199)
matrix `sigma'=(1.25,0.323,-0.323\0.323,2.62,-0.0123\-0.323,-0.0123,2.62)
medcouple `varlist' if `touse', lmc rmc
matrix `mc'=(e(mc),e(lmc),e(rmc))
matrix `TM'=`n'*((`mc'-`mu')*invsym(`sigma')*(`mc'-`mu')')
local T=`TM'[1,1]
local dof=3
}

local p=chi2tail(`dof',`T')

di ""
di "Robust Jarque-Bera test, H0: Normality"
di "--------------------------------------"
di ""
di "T=" round(`T',0.001)
di "chi(" `dof' "," `level' ")=" invchi2(`dof',`level')
di "p-value=" round(`p',0.001)


return scalar p = `p'
return scalar dof = `dof'
return scalar chi2 = invchi2(`dof',`level')
return scalar T = `T'
return scalar mc=e(mc)
end

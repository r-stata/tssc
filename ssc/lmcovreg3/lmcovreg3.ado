*! lmcovreg3 V2.0 25/01/2014
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

program lmcovreg3 , rclass
version 11
if "`e(cmd)'" != "reg3" & "`e(cmd)'" != "sureg" {
di
di as err "{bf:lmcovreg3} {cmd:works only after:} {bf:reg3, sureg}"
 exit
 }

di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Breusch-Pagan LM Diagonal Covariance Matrix Test (`e(method)') }}"
di _dup(78) "{bf:{err:=}}"
di as res _col(5) "Ho: Diagonal Disturbance Covariance Matrix (Independent Equations)"
if "`e(cmd)'" == "sureg" {
di as res _col(5) "Ho: Run OLS  -  Ha: Run SUR"
 }
else if "`e(cmd)'" == "reg3" {
di as res _col(5) "Ho: Run OLS  -  Ha: Run 3SLS"
 }
tempname Sig2 Omega
tempvar Time 
qui {
marksample touse
local depvar "`e(depvar)'"
local endog "`e(endog)'"
local exog "`e(exog)'"
markout `touse' `depvar' `endog' `exog' , strok
gen `Time' =_n
tsset `Time'
matrix `Omega'= e(Sigma)
matrix `Sig2' = corr(`Omega')
matrix `Sig2' = `Sig2' * `Sig2''
local cmd `e(cmdline)'
local `e(cmdline)'
local method `e(method)'
local N=e(N)
local eQ=e(k_eq)
local eQ `eQ'
local lmcovdf =`eQ'*(`eQ'-1)/2
local lmcov = (trace(`Sig2')-`eQ')*`N' / 2
local lmcovp= chi2tail(`lmcovdf', abs(`lmcov'))
 }
di
di as txt _col(5) "Lagrange Multiplier Test" _col(30) " = " as res %10.5f `lmcov'
di as txt _col(5) "Degrees of Freedom" _col(30) " = " as res %10.1f `lmcovdf'
di as txt _col(5) "P-Value > Chi2(" `lmcovdf' ")" _col(30) " = " as res %10.5f `lmcovp'
di _dup(78) "{bf:{err:=}}"
qui `cmd'
return scalar lmcov = `lmcov'
return scalar lmcovp= `lmcovp'
return scalar lmcovdf= `lmcovdf'
end

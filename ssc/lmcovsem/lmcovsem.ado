*! lmcovsem V2.0 25/01/2014
*!
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

program lmcovsem , rclass
version 12.1
if "`e(cmd)'" != "sem" {
di
di as err "{bf:lmcovsem} {cmd:works only after:} {bf:sem}"
 exit
 }
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* (SEM-FIML) Breusch-Pagan Diagonal Covariance Matrix LM Test - Method(`e(method)') }}"
di _dup(78) "{bf:{err:=}}"
di as res _col(5) "Ho: Diagonal Disturbance Covariance Matrix (Independent Equations)"
di as res _col(5) "Ho: Run OLS  -  Ha: Run SEM"

tempname E Sig2 Omega Y Yh N K 
tempvar  E Sig2 Time
marksample touse
local depvar "`e(oyvars)'"
local exog "`e(oxvars)'"
markout `touse' `depvar' `exog' , strok
qui {
gen `Time' =_n
tsset `Time'
local eQ : word count `e(oyvars)'
scalar `N'=e(N)
scalar `K'=e(df_bs)
predict `Yh'* if `touse'
mkmat `Yh'* if `touse' , matrix(`Yh')
mkmat `e(oyvars)' if `touse' , matrix(`Y')
matrix `E'=`Y'-`Yh'
matrix `Omega'=(`E''*`E'/`N')
matrix `Sig2' = corr(`Omega')
matrix `Sig2' = `Sig2' * `Sig2''
local cmd `e(cmdline)'
local `e(cmdline)'
local method `e(method)'
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

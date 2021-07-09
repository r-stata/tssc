*! lmanlsur V1.0 28/06/2012
*! Emad Abd Elmessih Shehata
*! Assistant Professor
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email:   emadstat@hotmail.com
*! WebPage:               http://emadstat.110mb.com/stata.htm
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

program define lmanlsur , rclass
version 10
tempname E Sig2 LE Omega BRho rho lmh wald lmg RhoSs N RhoSs
tempvar  E Sig2 RhoS LagE BRho Time DW
marksample touse
qui gen `Time' =_n
qui tsset `Time'
local cmd `e(cmdline)'
local `e(cmdline)'
local Q=e(k_eq)
local N=e(N)
local vars `e(depvar)'
matrix `Omega'= e(Sigma)
qui forvalue i=1/`Q' {
qui predict `E'`i' if `touse' , equation(#`i') res
 }
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* NL-SUR System Autocorrelation Tests}}"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:*** Single Equation Autocorrelation Tests:}"
di as txt "{bf: Ho: No Autocorrelation in eq. #: Pij=0 }"
di

forvalue i=1/`Q' {
qui gen `LagE'`i' =L.`E'`i' if `touse'
qui replace  `LagE'`i'=0 in 1
qui reg `E'`i' L.`E'`i' if `touse' , noconstant
scalar `rho'`i' =(_b[L.`E'`i'])^2
scalar `lmh'`i'=`N'*`rho'`i'
di as txt _col(2) "Eq. `i'" _col(12) ": Harvey LM Test =" _col(20) %8.4f as res `lmh'`i' as txt _col(40) " Rho = " %6.4f as res `rho'`i' as txt _col(55) "P-Value > Chi2(1) "%6.4f as res chi2tail(1,`lmh'`i')
return scalar rho_`i'=`rho'`i'
return scalar lmhp_`i'=chi2tail(1,`lmh'`i')
return scalar lmh_`i'=`lmh'`i'
 }
di _dup(78) "-"
 forvalue i=1/`Q' {
qui gen `DW'`i'=sum((`E'`i'-`E'`i'[_n-1])^2)/sum(`E'`i'*`E'`i') if `touse'
local lmadw`i' `DW'`i'[`N']
di as txt _col(2) "Eq. `i'" _col(12) ": Durbin-Watson DW Test =" _col(20) %8.4f as res `lmadw`i''
return scalar lmadw_`i'=`lmadw`i''
 }
 local i `LagE'*

 forval i=1/`Q' {
 forval j=1/`Q' {
 qui reg `E'`i' `LagE'* if `touse', noconstant
matrix `BRho'`i'`j'=e(b)'
gen `BRho'`i'`j'=`BRho'`i'`j'[`j',1] if `touse'
 }
 }
mkmat `BRho'* in 1 , matrix(`BRho')
mkmat `LagE'* if `touse' , matrix(`LE')
matrix `wald'=`BRho'*inv(`Omega')#(`LE''*`LE')*`BRho''
scalar `lmg'=`wald'[1,1]
local wdf=`Q'^2
qui {
gen double `RhoS' = . if `touse'
scalar `RhoSs' = 0
 forval i=1/`Q' {
replace `RhoS' = (`rho'`i') if `touse'
summ `RhoS' if `touse' , meanonly
replace  `RhoS' = r(mean) if `touse'
summ `RhoS' if `touse' , meanonly
scalar `RhoSs' = `RhoSs' + r(mean)
 }
 }
scalar `lmh'=`N'*`RhoSs'
di _dup(78) "-"
di
di as txt "{bf:*** Overall System NL-SUR Autocorrelation Tests:}"
di as txt "{bf: Ho: No Overall System Autocorrelation: P11 = P22 = PMM = 0}"
di
di as txt _col(2) "- Harvey  LM Test =" _col(33) %9.4f as res `lmh' as txt _col(50) "P-Value > Chi2(`Q')" _col(70) %5.4f as res chi2tail(`Q',`lmh') 
di as txt _col(2) "- Guilkey LM Test =" _col(33) %9.4f as res `lmg' as txt _col(50) "P-Value > Chi2(`wdf')" _col(70) %5.4f as res chi2tail(`wdf',`lmg') 
di _dup(78) "-"
qui `cmd'
return scalar lmgp=chi2tail(`Q',`lmh')
return scalar lmg=`lmg'
return scalar lmhp=chi2tail(`wdf',`lmg')
return scalar lmh=`lmh'
end


*! lmareg3 V1.0 20oct2011
*! Emad Abd Elmessih Shehata
*! Assistant Professor
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage: http://emadstat.110mb.com/stata.htm

program define lmareg3 , rclass
version 10
tempname E Sig2 LE Omega BRho
tempvar  E Sig2 RhoS LagE BRho TIMEN DW
marksample touse
qui gen `TIMEN' =_n if `touse'
qui tsset `TIMEN'
local cmd `e(cmdline)'
local `e(cmdline)'
scalar N=e(N)
scalar Q=e(k_eq)
local N=e(N)
local eQ=Q
local eQ `eQ'
local vars `e(depvar)'
mat `Omega'= e(Sigma)
foreach i of local vars {
qui predict `E'`i' if `touse' , equation(`i') res
 }
di as txt "{bf:{err:=================================================}}"
di as txt "{bf:{err:* System Autocorrelation Tests (`e(method)') }}"
di as txt "{bf:{err:=================================================}}"
di as txt "{bf:*** Single Equation Autocorrelation Tests:}"
di as txt "{bf: Ho: No Autocorrelation in eq. #: Pij=0 }"
di
 foreach i of local vars {
qui gen `LagE'`i' =L.`E'`i' if `touse'
qui replace  `LagE'`i'=0 in 1
qui reg `E'`i' L.`E'`i' if `touse' , noconstant
scalar rho`i' =(_b[L.`E'`i'])^2
scalar lmh`i'=N*rho`i'
di as txt _col(2) "Eq. `i'" _col(12) ": Harvey LM Test =" _col(20) %8.4f as res lmh`i' as txt _col(40) " Rho = " %6.4f as res rho`i' as txt _col(55) "P-Value > Chi2(1) "%6.4f as res chiprob(1,lmh`i')
return scalar rho_`i'=rho`i'
return scalar lmhp_`i'=chiprob(1,lmh`i')
return scalar lmh_`i'=lmh`i'
 }
di _dup(78) "-"
 foreach i of local vars {
qui gen `DW'`i'=sum((`E'`i'-`E'`i'[_n-1])^2)/sum(`E'`i'*`E'`i') if `touse'
local lmadw`i' `DW'`i'[`N']
di as txt _col(2) "Eq. `i'" _col(12) ": Durbin-Watson DW Test =" _col(20) %8.4f as res `lmadw`i''
return scalar lmadw_`i'=`lmadw`i''
 }
 local i `LagE'*
 foreach i of local vars {
 forval j=1/`eQ' {
 qui reg `E'`i' `LagE'* if `touse', noconstant
mat `BRho'`i'`j'=e(b)'
gen `BRho'`i'`j'=`BRho'`i'`j'[`j',1] if `touse'
 }
 }
mkmat `BRho'* in 1 , matrix(`BRho')
mkmat `LagE'* if `touse' , matrix(`LE')
mat wald=`BRho'*inv(`Omega')#(`LE''*`LE')*`BRho''
scalar lmg=wald[1,1]
local wdf=`eQ'^2
qui {
gen double `RhoS' = . if `touse'
scalar RhoSs = 0
foreach i of local vars {
replace `RhoS' = (rho`i') if `touse'
summ `RhoS' if `touse' , meanonly
replace  `RhoS' = r(mean) if `touse'
summ `RhoS' if `touse' , meanonly
scalar RhoSs = RhoSs + r(mean)
 }
 }
scalar lmh=N*RhoSs
di _dup(78) "-"
di as txt "{bf:*** Overall System Autocorrelation Tests:}"
di as txt "{bf: Ho: No Overall System Autocorrelation: P11 = P22 = PMM = 0}"
di
di as txt _col(2) "- Harvey  LM Test =" _col(33) %9.4f as res lmh as txt _col(50) "P-Value > Chi2(`eQ')" _col(70) %5.4f as res chiprob(`eQ',lmh) 
di as txt _col(2) "- Guilkey LM Test =" _col(33) %9.4f as res lmg as txt _col(50) "P-Value > Chi2(`wdf')" _col(70) %5.4f as res chiprob(`wdf',lmg) 
di _dup(78) "-"
qui `cmd'
return scalar lmgp=chiprob(`eQ',lmh)
return scalar lmg=lmg
return scalar lmhp=chiprob(`wdf',lmg)
return scalar lmh=lmh
end

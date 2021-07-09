*! fgtest V1.0 15jan2012
*! Emad Abd Elmessih Shehata
*! Assistant Professor
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage: http://emadstat.110mb.com/stata.htm
program define fgtest, eclass
version 10.0
syntax varlist [if] [in] , [NOCONStant]
tempvar COR DE DF eigVaLn Ev f1 f11 fg ILVal L L1 LDE LVal LVal1 Q R2xx Rx Time 
tempvar U2 Ue VaL1 VaL21 VaLv1 VIFI VIFI X0 XQ Z0 DFF COR CORx
tempname Cr D DCor DFF1 DFF2 Dr Ds eigVaL F MatVIF LVal1 X X0
tempname f1 fg fgF FGFF fgFp fgT ICOR K L L1 LDCor LVal
tempname N RX RY S sd VaL Val VaL1 VaL21 VaLv1 Vec VIF VIFI
tempvar `varlist'
marksample touse
gettoken yvar xvar : varlist
markout `touse' `varlist'
_rmdcoll `varlist' if `touse' , `noconstant'
tsunab xvar : `xvar'
tokenize `xvar'
local xvar `*'
qui cap count if `touse'
qui gen `Time'=_n
qui tsset `Time'
qui gen `X0'=1 if `touse'
qui summ `X0' if `touse'
local N = r(N)
local kx : word count `xvar'
scalar kx=`kx'
qui gen `R2xx'=0 if `touse'
qui gen `Rx'=0 if `touse'
qui gen `VIFI'=0 if `touse'
qui gen `DFF'=0 if `touse'
qui gen `DFF1'=0 if `touse'
qui gen `DFF2'=0 if `touse'
qui gen `fgF'=0 if `touse'
qui gen `fgFp'=0 if `touse'
qui corr `xvar' if `touse'
matrix `COR'=r(C)'
matrix `VIF'=vecdiag(inv(`COR'))'
qui forval i=1/`kx' { 
qui replace `VIFI'=1/`VIF'[`i',1]  in `i'
qui replace `R2xx'=1-1/`VIF'[`i',1] in `i'
 }
qui matrix symeigen `Vec' `eigVaL'=`COR'
qui svmat `eigVaL' , name(`eigVaL')
qui rename `eigVaL'1 `eigVaL'
 mkmat `VIFI' in 1/`kx' , matrix(`VIFI')
 mkmat `R2xx' in 1/`kx' , matrix(`R2xx')
matrix `eigVaL'=`eigVaL''
qui svmat `eigVaL' , name(`eigVaLn')
qui rename `eigVaLn'1 `eigVaLn'
qui summ `eigVaLn' if `touse'
qui corr `xvar' if `touse'
 matrix `COR'=r(C)'
 matrix `VIF'=vecdiag(inv(`COR'))'
qui forval i=1/`kx' { 
qui replace `VIFI'=1/`VIF'[`i',1]  in `i'
qui replace `R2xx'=1-1/`VIF'[`i',1] in `i'
qui replace `Rx'=`R2xx' in `i'
qui replace `DFF'=(`N'-`kx')/(`kx'-1) in `i'
qui replace `DFF1'=(`N'-`kx') in `i'
qui replace `DFF2'=(`kx'-1) in `i'
qui replace `fgF'=`Rx'/(1-`Rx')*`DFF' in `i'
qui replace `fgFp'= fprob(`DFF1', `DFF2', `fgF') in `i'
 }
mkmat `fgF' `DFF1' `DFF2' `fgFp' in 1/`kx' , matrix(`FGFF')
qui forval i=1/`kx' {
qui forval j=1/`kx' {
 tempvar COR`i'`j'
qui gen `COR'`i'`j'=0 if `touse'
 }
 }
 matrix `LDCor'=log(det(`COR'))
 matrix `fg'=-(`N'-1-(((2*`kx')+5)/6))*`LDCor'
 scalar fgdf=0.5*`kx'*(`kx'-1)
 scalar fgchi=`fg'[1,1]
qui forval i=1/`kx' {
qui forval j=1/`kx' {
qui replace `COR'`i'`j'=`COR'[`i',`j']*sqrt((`N'-`kx'))/sqrt(1-`COR'[`i',`j']^2) in `i'
 }
 }
qui forval i=1/`kx' {
qui forval j=1/`kx' {
 mkmat `COR'`i'* in 1/`kx' , matrix(`CORx'`i')
 matrix `CORx'`i'[1,`kx']=`CORx'`i'[1,`kx']'
 }
 }
qui forval i=1/`kx' {
qui forval j=1/`kx' {
 replace `COR'1`j' =  `COR'`i'`j' in `i'
 }
 }
 mkmat `COR'1* in 1/`kx' , matrix(`fgT')
di
di _dup(70) "="
di as txt "{bf:{err:* Farrar-Glauber Multicollinearity Tests}}"
di _dup(70) "="
di as txt _col(3) "Ho: No Multicollinearity - Ha: Multicollinearity"
di
di as txt "{bf:* (1) Farrar-Glauber Multicollinearity Chi2-Test:}"
di as txt _col(5) "Chi2 Test = " as res %9.4f fgchi as txt _col(30) "P-Value > Chi2(" fgdf ") " as res _col(45) %5.4f chi2tail(fgdf,fgchi) "
ereturn scalar fgc=fgchi
di
di as txt "{bf:* (2) Farrar-Glauber Multicollinearity F-Test:}"
matrix rownames `FGFF' = `xvar'
matrix colnames `FGFF' = "F_Test" "DF1" "DF2" "P_Value"
matlist `FGFF', twidth(10) border(all) lines(columns) noblank rowtitle(Variable) format(%8.3f)
ereturn matrix fgf=`FGFF'
di
di as txt "{bf:* (3) Farrar-Glauber Multicollinearity t-Test:}"
matrix rownames `fgT' = `xvar'
matrix colnames `fgT' = `xvar'
matlist `fgT', twidth(8) border(all) lines(columns) noblank rowtitle(Variable) format(%6.3f)
ereturn matrix fgt=`fgT'
end


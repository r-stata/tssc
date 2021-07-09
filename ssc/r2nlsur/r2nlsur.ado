*! r2nlsur V2.0 26/02/2014
*! 
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

program define r2nlsur , rclass
version 11.0

if "`e(cmd)'" != "nlsur" {
di
di as err "{bf:r2nlsur} {cmd:works only after:} {bf:nlsur}"
 exit
 }

tempvar E`var' Yb_Y`var' YMAT R4S SYY Time
tempname Ybv Yb Yv E`var' Yb_Y`var' Sig2 YM RS1 RS2 RS3 RS4 RS5
tempname Y Ev E W Omega IMn Dt YMAT Mat1 Mat2 Mat3 R2Mat Trm RSQ Sig2
tempname SSE1 SSE2 SSE3 SSE4 MSS1 MSS2 MSS3 MSS4 SST1 SST2 SST3 SST4
marksample touse
 qui {
preserve
tempname N K Q DFF DFChi Sig21 v R2_ SY R5 R4 R ADR F Chi PChi PF LSig2 llf
tempname DF1 DF2 DFChi
qui gen `Time' = _n 
qui tsset `Time'
scalar `N'=e(N)
scalar `K'=e(k)
local Q=e(k_eq)
scalar `DFF'=(`Q'*`N'-`K')/(`K'-`Q')
scalar `DFChi'=(`K'-`Q')
scalar `DF1'=`K'-`Q'
scalar `DF2'=`Q'*`N'
scalar `DFChi'=(`K'-`Q')
matrix `Omega'= e(Sigma)
local varlist `e(depvar)'
qui forvalue i=1/`Q' {
 predict `E'`i' if `touse' , equation(#`i') res
 }
foreach var of local varlist {
qui summarize `var' if `touse'
qui gen `Yb_Y'`var' = `var' - `r(mean)' if `touse'
 }
mkmat `E'* if `touse' , matrix(`E')
mkmat `e(depvar)' if `touse' , matrix(`Y')
mkmat `Yb_Y'`var'*   if `touse'  , matrix(`Yb')
svmat `Y' , name(`YMAT')
matrix `Ybv'=vec(`Yb')
matrix `Yv'=vec(`Y')
matrix `Ev'=vec(`E')
matrix `W'=inv(`Omega')#I(`N')
matrix `Sig2'=det(`Omega')
scalar `Sig21'=`Sig2'[1,1]
matrix `SSE1'=det(`E''*`E')
matrix `SSE2'=`Ev''*`W'*`Ev'
matrix `SSE3'=`Ev''*`Ev'
matrix `SST1'=det(`Yb''*`Yb')
matrix `SST2'=`Ybv''*`W'*`Ybv'
matrix `SST3'=`Ybv''*`Ybv'
scalar `v'=1/`N'
matrix `IMn'=J(`N',`N',`v')
matrix `Dt'=I(`N')-`IMn'
forvalues i =1/`Q' {
scalar `R2_'`i'=e(r2_`i')
 }
qui egen `SYY' = varprod(`Yb_Y'`var'*) if `touse'
qui sum `SYY' if `touse' , meanonly
scalar `SY'=r(mean)
matrix `Trm'=trace(inv(`Omega'))*`SY'
scalar `R'5=1-(`Q'/`Trm'[1,1])
qui gen double `R4S' = . if `touse'
scalar `R'4 = 0
qui forvalues i =1/`Q' {
mkmat `YMAT'`i' if `touse' , matrix(`YM')
matrix `Mat1'=`YM''*`Dt'*`YM'
matrix `Mat2'=`Yv''*I(`Q')#`Dt'*`Yv'
scalar `Mat3'=`Mat1'[1,1]/`Mat2'[1,1]
matrix `R2Mat'=`R2_'`i'*`Mat3'
scalar `R4'`i'=`R2Mat'[1,1]
qui replace `R4S' = `R4'`i' if `touse'
qui sum `R4S' if `touse' , meanonly
qui replace  `R4S' = r(mean) if `touse'
scalar `R'4 = `R'4 + r(mean)
 }
qui forvalues i = 1/3 {
matrix `MSS`i''=`SST`i''-`SSE`i''
matrix `R'`i'1=1-(`SSE`i''*inv(`SST`i''))
scalar `R'`i'=`R'`i'1[1,1]
 }
qui forvalues i = 1/5 {
scalar `ADR'`i'=1-(1-`R'`i')*((`Q'*`N'-`Q')/(`Q'*`N'-`K'))
scalar `F'`i'=`R'`i'/(1-`R'`i')*`DFF'
scalar `Chi'`i'= -`N'*(log(1-`R'`i'))
scalar `PChi'`i'= chi2tail(`DFChi', `Chi'`i')
scalar  `PF'`i'= Ftail(`DF1',`DF2', `F'`i')
 }
scalar `LSig2'=log(`Sig21')
scalar `llf'=-(`N'*`Q'/2)*(1+log(2*_pi))-(`N'/2*abs(`LSig2'))
restore
 }
di 
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:* Nonlinear Seemingly Unrelated Regression: Method = (`e(method)')}"
di as txt "{bf:{err:* (NL-SUR) Overall System R2 - Adjusted R2 - F Test - Chi2 Test}}"
di _dup(78) "{bf:{err:=}}"
matrix `RS1'=`R'1,`ADR'1,`F'1,`PF'1,`Chi'1,`PChi'1
matrix `RS2'=`R'2,`ADR'2,`F'2,`PF'2,`Chi'2,`PChi'2
matrix `RS3'=`R'3,`ADR'3,`F'3,`PF'3,`Chi'3,`PChi'3
matrix `RS4'=`R'4,`ADR'4,`F'4,`PF'4,`Chi'4,`PChi'4
matrix `RS5'=`R'5,`ADR'5,`F'5,`PF'5,`Chi'5,`PChi'5
matrix `RSQ'=`RS1' \ `RS2' \ `RS3' \ `RS4' \ `RS5'
mat rownames `RSQ' = Berndt McElroy Judge Dhrymes Greene
mat colnames `RSQ' = R2 Adj_R2 F "P-Value" Chi2 "P-Value"
matlist `RSQ', twidth(8) border(all) lines(columns) rowtitle(Name) format(%10.4f)
di as txt "  Number of Parameters         =" as res _col(35) %10.0f `K'
di as txt "  Number of Equations          =" as res _col(35) %10.0f `Q'
di as txt "  Degrees of Freedom F-Test    =" as res _col(39) "(" `K'-`Q' ", " `Q'*`N' ")"
di as txt "  Degrees of Freedom Chi2-Test =" as res _col(35) %10.0f `DFChi'
di as txt "  Log Determinant of Sigma     =" as res _col(35) %10.4f `LSig2'
di as txt "  Log Likelihood Function      =" as res _col(35) %10.4f `llf'
di _dup(78) "-"
return scalar f_df1 = `DF1'
return scalar f_df2 = `DF2'
return scalar chi_df = `DFChi'
return scalar k=`K'
return scalar k_eq=`Q'
return scalar N=`N'
return scalar lsig2=`LSig2'
return scalar llf=`llf'
return scalar chi_g = `Chi'5
return scalar chi_d = `Chi'4
return scalar chi_b = `Chi'3
return scalar chi_j = `Chi'2
return scalar chi_m = `Chi'1
return scalar f_g = `F'5
return scalar f_d = `F'4
return scalar f_b = `F'3
return scalar f_j = `F'2
return scalar f_m = `F'1
return scalar r2a_g = `ADR'5
return scalar r2a_d = `ADR'4
return scalar r2a_b = `ADR'3
return scalar r2a_j = `ADR'2
return scalar r2a_m = `ADR'1
return scalar r2_g = `R'5
return scalar r2_d = `R'4
return scalar r2_b = `R'3
return scalar r2_j = `R'2
return scalar r2_m = `R'1
end

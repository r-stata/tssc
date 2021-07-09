*! lmcol V1.0 28/09/2012
*! 
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage:               http://emadstat.110mb.com/stata.htm
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

*! Sahra Khaleel A. Mickaiel
*! Professor (PhD Economics)
*! Cairo University - Faculty of Agriculture - Department of Economics - Egypt
*! Email: sahra_atta@hotmail.com
*! WebPage:               http://sahraecon.110mb.com/stata.htm
*! WebPage at IDEAS:      http://ideas.repec.org/f/pmi520.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/pmi520.htm

program define lmcol , eclass
version 11.0
syntax varlist [if] [in] , [NOCONStant coll]
gettoken yvar xvar : varlist
qui marksample touse
qui markout `touse' `varlist' , strok
local both : list yvar & xvar
if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both LHS and RHS Variables}"
di as res " LHS: `yvar'"
di as res " RHS: `xvar'"
 exit
 }
 if "`xvar'"=="" {
di
di as err "  {bf:Independent Variable(s) must be combined with Dependent Variable}"
 exit
 }
tempvar Ci CImax CNmax COR DE DF1 E EE fg fgF fgFp Hat Yh_ML Ue_ML TimeN
tempvar ht ILVal L LDE LE lf Ls LVal LVal1 Yho Yt YY YYm YYv Wio WS X0
tempvar R2oS R2xx Rx SSE Time U U2 Ue VIFI wald weit Wi Yb Yh Yh2
tempname b B b1 b2 Beta Bv Bv1 Bx CNmax Cond COR corr CORr CORx Cov CovC Cr
tempname D DCor Dr Ds DX E E1 EE1 Eg eigVaL F fg FGFF fgT Hat HT M s S
tempname ICOR IPhi J K L LDCor Ls LVal LVal1 M1 M2 MatVIF n OM V v1 Z1 Zo
tempname P Phi Pm q Q q1 q2 Qr Sig2w Sig2 Sig2n Sig2o Sig2o1 VaL Val Yi Z Z0
tempname VaL1 VaL21 VaLv1 Vec VIF VIFI VM VP W W1 Wald We Wi Zr mh SST1 SST2
tempname Wi1 Wio WY X X0 Y Yh Nn N kx DF kb SSEo llf
qui cap count if `touse'
local N = r(N)
qui gen `TimeN'=_n
qui gen `Time'=_n if `touse'
qui tsset `Time'
scalar `Nn'=`N'
qui gen `X0'=1 if `touse'
matrix `X0'= J(`N',1,1)
 if "`coll'"=="" {
_rmcoll `varlist' , `noconstant' `coll' forcedrop
 local varlist "`r(varlist)'"
gettoken yvar xvar : varlist
 }
local kx : word count `xvar'
mkmat `yvar' if `touse' , matrix(`Y')
if "`noconstant'"!="" {
qui mkmat `xvar' if `touse' , matrix(`X')
scalar `DF'=`N'-`kx'
scalar `kb'=`kx'
 }
 else { 
qui mkmat `xvar' `X0' if `touse' , matrix(`X')
scalar `DF'=`N'-`kx'-1
scalar `kb'=`kx'+1
 }
qui gen `Wi'=1 if `touse'
qui gen `weit' = 1 if `touse'
mkmat `Wi' if `touse' , matrix(`Wi')
matrix `Wi'=diag(`Wi')
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Ordinary Least Squares (OLS)}}"
di _dup(78) "{bf:{err:=}}"
matrix `B'=invsym(`X''*`X')*`X''*`Y'
matrix `Ue_ML'=(`Y'-`X'*`B')
matrix `Sig2'=`Ue_ML''*`Ue_ML'/`DF'
matrix `Cov'=`Sig2'*inv(`X''*`X')
qui svmat `Ue_ML' , name(`Ue_ML')
qui rename `Ue_ML'1 `Ue_ML'
matrix `Yh_ML'=`X'*`B'
qui svmat `Yh_ML' , name(`Yh_ML')
qui rename `Yh_ML'1 `Yh_ML'
tempname SSEo Sigo r2bu r2bu_a r2raw r2raw_a R20 f fp wald waldp
tempname r2v r2v_a fv fvp r2h r2h_a fh fhp SSTm SSE1 SST11 SST21 Rho
matrix `SSE'=`Ue_ML''*`Ue_ML'
scalar `SSEo'=`SSE'[1,1]
scalar `Sig2o'=`SSEo'/`DF'
scalar `Sigo'=sqrt(`Sig2o')
matrix `Sig2'=`SSEo'/`DF'
scalar `Sig2n'=`SSEo'/`N'
qui summ `Yh_ML' if `touse' 
local NUM=r(Var)
qui summ `yvar' if `touse' 
local DEN=r(Var)
scalar `r2v'=`NUM'/`DEN'
scalar `r2v_a'=1-((1-`r2v')*(`N'-1)/`DF')
scalar `fv'=`r2v'/(1-`r2v')*(`N'-`kb')/(`kx')
scalar `fvp'=Ftail(`kx', `DF', `fv')
qui correlate `Yh_ML' `yvar' if `touse'
scalar `r2h'=r(rho)*r(rho)
scalar `r2h_a'=1-((1-`r2h')*(`N'-1)/`DF')
scalar `fh'=`r2h'/(1-`r2h')*(`N'-`kb')/(`kx')
scalar `fhp'=Ftail(`kx', `DF', `fh')
matrix `SSE'=`Ue_ML''*`Ue_ML'
local Sig=`Sigo'
qui summ `yvar' if `touse' 
local Yb=r(mean)
qui gen `YYm'=(`yvar'-`Yb')^2 if `touse'
qui summ `YYm' if `touse'
qui scalar `SSTm' = r(sum)
qui gen `YYv'=(`yvar')^2 if `touse'
qui summ `YYv' if `touse'
local SSTv = r(sum)
qui summ `weit' if `touse' 
qui gen `Wi1'=sqrt(`weit'/r(mean)) if `touse'
mkmat `Wi1' if `touse' , matrix(`Wi1')
matrix `P' =diag(`Wi1')
qui gen `Wio'=(`Wi1') if `touse' 
mkmat `Wio' if `touse' , matrix(`Wio')
matrix `Wio'=diag(`Wio')
matrix `Pm' =`Wio'
matrix `IPhi'=`P''*`P'
matrix `Phi'=inv(`P''*`P')
matrix `J'= J(`N',1,1)
matrix `D'=(`J'*`J''*`IPhi')/`N'
matrix `SSE'=`Ue_ML''*`IPhi'*`Ue_ML'
matrix `SST1'=(`Y'-`D'*`Y')'*`IPhi'*(`Y'-`D'*`Y')
matrix `SST2'=(`Y''*`Y')
scalar `SSE1'=`SSE'[1,1]
scalar `SST11'=`SST1'[1,1]
scalar `SST21'=`SST2'[1,1]
scalar `r2bu'=1-`SSE1'/`SST11'
scalar `R20'=`r2bu'
scalar `r2bu_a'=1-((1-`r2bu')*(`N'-1)/`DF')
scalar `r2raw'=1-`SSE1'/`SST21'
scalar `r2raw_a'=1-((1-`r2raw')*(`N'-1)/`DF')
scalar `f'=`r2bu'/(1-`r2bu')*(`N'-`kb')/`kx'
scalar `fp'= Ftail(`kx', `DF', `f')
scalar `wald'=`f'*`kx'
scalar `waldp'=chi2tail(`kx', abs(`wald'))
scalar `llf'=-(`N'/2)*log(2*_pi*`SSEo'/`N')-(`N'/2)
local Nof =`N'
local Dof =`DF'
matrix `B'=`B''
if "`noconstant'"!="" {
matrix colnames `Cov' = `xvar'
matrix rownames `Cov' = `xvar'
matrix colnames `B'   = `xvar'
 }
 else { 
matrix colnames `Cov' = `xvar' _cons
matrix rownames `Cov' = `xvar' _cons
matrix colnames `B'   = `xvar' _cons
 }
yxregeq `yvar' `xvar'
di as txt _col(3) "Sample Size" _col(21) "=" %12.0f as res `N'
ereturn post `B' `Cov' , dep(`yvar') obs(`Nof') dof(`Dof')
qui test `xvar'
scalar `f'=r(F)
scalar `fp'= Ftail(`kx', `DF', `f')
scalar `wald'=`f'*`kx'
scalar `waldp'=chi2tail(`kx', abs(`wald'))
di as txt _col(3) "{cmd:Wald Test}" _col(21) "=" %12.4f as res `wald' _col(37) "|" _col(41) as txt "P-Value > {cmd:Chi2}(" as res `kx' ")" _col(65) "=" %12.4f as res `waldp'
di as txt _col(3) "{cmd:F-Test}" _col(21) "=" %12.4f as res `f' _col(37) "|" _col(41) as txt "P-Value > {cmd:F}(" as res `kx' " , " `DF' ")" _col(65) "=" %12.4f as res `fp'
di as txt _col(2) "(Buse 1973) R2" _col(21) "=" %12.4f as res `r2bu' _col(37) "|" as txt _col(41) "Raw Moments R2" _col(65) "=" %12.4f as res `r2raw'
ereturn scalar r2bu =`r2bu'
ereturn scalar r2bu_a=`r2bu_a'
ereturn scalar f =`f'
ereturn scalar fp=`fp'
ereturn scalar wald =`wald'
ereturn scalar waldp=`waldp'
di as txt _col(2) "(Buse 1973) R2 Adj" _col(21) "=" %12.4f as res `r2bu_a' _col(37) "|" as txt _col(41) "Raw Moments R2 Adj" _col(65) "=" %12.4f as res `r2raw_a'
di as txt _col(3) "Root MSE (Sigma)" _col(21) "=" %12.4f as res `Sigo' as txt _col(37) "|" _col(41) "Log Likelihood Function" _col(65) "=" %12.4f as res `llf'
di _dup(78) "-"
di as txt "- {cmd:R2h}=" %7.4f as res `r2h' _col(17) as txt "{cmd:R2h Adj}=" as res %7.4f `r2h_a' as txt _col(34) "{cmd:F-Test} =" %8.2f as res `fh' _col(51) as txt "P-Value > F(" as res `kx' " , " `DF' ")" _col(72) %5.4f as res `fhp'
di as txt "- {cmd:R2v}=" %7.4f as res `r2v' _col(17) as txt "{cmd:R2v Adj}=" as res %7.4f `r2v_a' as txt _col(34) "{cmd:F-Test} =" %8.2f as res `fv' _col(51) as txt "P-Value > F(" as res `kx' " , " `DF' ")" _col(72) %5.4f as res `fvp'
ereturn scalar r2raw =`r2raw'
ereturn scalar r2raw_a=`r2raw_a'
ereturn scalar llf =`llf'
ereturn scalar sig=`Sigo'
ereturn scalar r2h=`r2h'
ereturn scalar r2h_a=`r2h_a'
ereturn scalar r2v=`r2v'
ereturn scalar r2v_a=`r2v_a'
ereturn scalar fh=`fh'
ereturn scalar fv=`fv'
ereturn scalar fhp=`fhp'
ereturn scalar fvp=`fvp'
ereturn scalar kb=`kb'
ereturn scalar kx=`kx'
ereturn scalar DF=`DF'
ereturn scalar Nn=_N
ereturn display 
matrix `b'=e(b)
matrix `V'=e(V)
matrix `Bx'=e(b)
 if `kx' > 1 {
local N=`Nn'
qui tsset `Time'
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:*** Multicollinearity Diagnostic Tests}}"
di _dup(78) "{bf:{err:=}}"
di
di as txt "{bf:{err:* Correlation Matrix}}"
qui tsset `Time'
tempvar R2xx Rx VIFI DFF DFF1 DFF2 fgF fgFp SH6v LVal eigVaL
tempvar eigVaLn ILVal R2oS CNmax CImax X 
tempname COR VIF Vec eigVaL VIFI R2xx FGFF LDCor fg CORx fgT DCor X
tempname Cond X0 J S Ds Val Cr Dr LVal1 LVal SLv2 SH6v q0 q1 q2 q3 q4 q5 q6
tempname fgdf fgchi dcor1 dfm R2 R2oSs r2th Kcol Krow MaxLv MinLv SumLv SumILv
qui gen `R2xx'=0 if `touse' 
qui gen `Rx'=0 if `touse'
qui gen `VIFI'=0 if `touse' 
qui gen `DFF'=0 if `touse' 
qui gen `DFF1'=0 if `touse' 
qui gen `DFF2'=0 if `touse' 
qui gen `fgF'=0 if `touse' 
qui gen `fgFp'=0 if `touse' 
 corr `xvar' if `touse' 
matrix `COR'=r(C)'
matrix `VIF'=vecdiag(invsym(`COR'))'
qui forvalue i=1/`kx' { 
qui replace `VIFI'=1/`VIF'[`i',1] in `i'
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
qui gen `CNmax'=r(max) if `touse' 
qui replace `CNmax'=`CNmax'/`eigVaLn' if `touse' 
qui gen `CImax'=sqrt(`CNmax') if `touse' 
 mkmat `CNmax' `CImax' in 1/`kx' , matrix(`Cond')
 matrix `Cond' = `eigVaL',`Cond',`VIF',`VIFI',`R2xx'
di as txt "{bf:{err:* Multicollinearity Diagnostic Criteria}}"
 matrix rownames `Cond' = `xvar'
 matrix colnames `Cond' = "Eigenval" "C_Number" "C_Index" "VIF" "1/VIF" "R2_xi,X"
matlist `Cond', twidth(5) border(all) lines(columns) noblank rowtitle(Var) format(%9.4f)
qui corr `xvar' if `touse' 
 matrix `COR'=r(C)'
 matrix `VIF'=vecdiag(invsym(`COR'))'
qui forvalue i=1/`kx' { 
qui replace `VIFI'=1/`VIF'[`i',1] in `i'
qui replace `R2xx'=1-1/`VIF'[`i',1] in `i'
qui replace `Rx'=`R2xx' in `i'
qui replace `DFF'=(`N'-`kx')/(`kx'-1) in `i'
qui replace `DFF1'=(`N'-`kx') in `i'
qui replace `DFF2'=(`kx') in `i'
qui replace `fgF'=`Rx'/(1-`Rx')*`DFF' in `i'
qui replace `fgFp'= Ftail(`DFF1', `DFF2', `fgF') in `i'
 }
mkmat `fgF' `DFF1' `DFF2' `fgFp' in 1/`kx' , matrix(`FGFF')
qui forvalue i=1/`kx' {
qui forvalue j=1/`kx' {
qui cap drop  `COR'`i'`j'
 tempvar COR`i'`j'
qui gen `COR'`i'`j'=0 if `touse' 
 }
 }
 matrix `LDCor'=ln(det(`COR'))
 matrix `fg'=-(`N'-1-(((2*`kx')+5)/6))*`LDCor'
 scalar `fgdf'=0.5*`kx'*(`kx'-1)
 scalar `fgchi'=`fg'[1,1]
qui forvalue i=1/`kx' {
qui forvalue j=1/`kx' {
qui replace `COR'`i'`j'=`COR'[`i',`j']*sqrt((e(N)-`kx'))/sqrt(1-`COR'[`i',`j']^2) in `i'
 }
 }
qui forvalue i=1/`kx' {
qui forvalue j=1/`kx' {
 mkmat `COR'`i'* in 1/`kx' , matrix(`CORx'`i')
 matrix `CORx'`i'[1,`kx']=`CORx'`i'[1,`kx']'
 }
 }
qui forvalue i=1/`kx' {
qui forvalue j=1/`kx' {
 replace `COR'1`j' = `COR'`i'`j' in `i'
 }
 }
 mkmat `COR'1* in 1/`kx' , matrix(`fgT')
di
di as txt "{bf:{err:* Farrar-Glauber Multicollinearity Tests}}"
di as txt _col(3) "Ho: No Multicollinearity - Ha: Multicollinearity"
di _dup(50) "-"
di
di as txt "{bf:* (1) Farrar-Glauber Multicollinearity Chi2-Test:}"
di as txt _col(5) "Chi2 Test = " as res %9.4f `fgchi' as txt _col(30) "P-Value > Chi2(" `fgdf' ") " as res _col(45) %5.4f chi2tail(`fgdf', `fgchi') "
ereturn scalar fgchi = `fgchi'
di
di as txt "{bf:* (2) Farrar-Glauber Multicollinearity F-Test:}"
matrix rownames `FGFF' = `xvar'
matrix colnames `FGFF' = F_Test DF1 DF2 P_Value
matlist `FGFF', twidth(10) border(all) lines(columns) noblank rowtitle(Variable) format(%8.3f)
di
di as txt "{bf:* (3) Farrar-Glauber Multicollinearity t-Test:}"
matrix rownames `fgT' = `xvar'
matrix colnames `fgT' = `xvar'
matlist `fgT', twidth(8) border(all) lines(columns) noblank rowtitle(Variable) format(%6.3f)
qui mkmat `xvar' if `touse' , matrix(`X')
qui corr `xvar' if `touse' 
matrix `COR'=r(C)'
matrix `VIF'=vecdiag(invsym(`COR'))'
qui matrix symeigen `Vec' `eigVaL'=`COR'
matrix `LDCor'=ln(det(`COR'))
matrix `DCor'=det(`COR')
scalar `dcor1'=`DCor'[1,1]
 svmat `X' , name(`X')
local XVars `X'
qui foreach var of local XVars {
qui forvalue i=1/`kx' {
qui const define `i' `var'`i'=0
qui cnsreg `yvar' `X'* if `touse' , constraints(`i')
scalar `dfm'=e(df_m)+1
scalar `R2'`i'=((`dfm'-1)*e(F))/((`dfm'-1)*e(F)+(e(N)-`dfm'))
 }
 }
qui gen double `R2oS' = . if `touse' 
 scalar `R2oSs' = 0
qui forvalue i=1/`kx' {
qui replace `R2oS' = `R2'`i' if `touse' 
qui summ `R2oS' if `touse' , meanonly
qui replace `R2oS' = r(mean) if `touse' 
qui summ `R2oS' if `touse' , meanonly
scalar `R2oSs' = `R2oSs' + r(mean)
 }
 scalar `r2th'=`R20'-(`kx'*`R20'-`R2oSs')
 scalar `Kcol' = colsof(`X')
 scalar `Krow' = rowsof(`X')
 matrix `X0'= J(`N',1,1)
 matrix `J'=`X0'*`X0''
 matrix `S'=(`X''*(I(`Krow')-1/`N'*(`J'))*`X')/(`Krow'-1)
 matrix `Ds'=diag(vecdiag(`S'))*I(`Kcol')
 matrix symeigen `Vec' `Val' = `Ds'
 local ncol=colsof(`Ds')
 local Val `Val'
qui forvalue i = 1/`ncol' {
qui cap matrix `Val'[1,`i'] = sqrt(`Val'[1,`i'])
 }
 matrix `Ds' = `Vec'*diag(`Val')*`Vec''
 matrix `Cr'=invsym(`Ds')*`S'*invsym(`Ds')
 matrix `Dr'=det(`Cr')
 matrix symeigen `Vec' `LVal1' = `COR'
 matrix symeigen `Vec' `LVal' = `Cr'
 matrix `LVal'=`LVal''
qui svmat `LVal' , name(`LVal')
qui rename `LVal'1 `LVal'
qui summ `LVal' if `touse' 
 scalar `MaxLv'=r(max)
 scalar `MinLv'=r(min)
 scalar `SumLv'=r(sum)
qui gen `ILVal'=1/`LVal' if `touse' 
qui summ `ILVal' if `touse' 
 scalar `SumILv'=r(sum)
 matrix `SLv2'=`LVal''*`LVal'
* Gleason-Staelin (1975) *
 scalar `q0'=sqrt((`SLv2'[1,1]-`Kcol')/(`Kcol'*(`Kcol'-1)))
* Heo (1987) *
 scalar `q1'=(1-(`MinLv'/`MaxLv'))^(`Kcol'+2)
 scalar `q2'=1-(`Kcol'/`SumILv')
 scalar `q3'=1-sqrt(`Dr'[1,1])
 scalar `q4'=(`MaxLv'/`Kcol')^(3/2)
 scalar `q5'=(1-`MinLv'/`Kcol')^(5)
 matrix `SH6v'=vecdiag(invsym(`Cr'))'
qui svmat `SH6v' , name(`SH6v')
qui rename `SH6v'1 `SH6v'
qui replace `SH6v'=(1-1/`SH6v')/`Kcol' 
qui summ `SH6v' if `touse' 
scalar `q6'=r(sum)
di
di as txt "{bf:{err:* |X'X| Determinant:}}"
di as txt _col(3) "{bf:|X'X| = 0 Multicollinearity - |X'X| = 1 No Multicollinearity}"
di as txt _col(3) "|X'X| Determinant: " as res _col(28) "(0 < " %5.4f `dcor1' " < 1)"
di _dup(63) "-"
di
di as txt "{bf:{err:* Theil R2 Multicollinearity Effect:}}"
di as txt _col(3) "{bf:R2 = 0 No Multicollinearity - R2 = 1 Multicollinearity}"
di as txt _col(6) "- Theil R2: " as res _col(28) "(0 < " %5.4f `r2th' " < 1)"
di _dup(63) "-"
di
di as txt "{bf:{err:* Multicollinearity Range:}}"
di as txt _col(3) "{bf:Q = 0 No Multicollinearity - Q = 1 Multicollinearity}"
di as txt _col(5) " - Gleason-Staelin Q0: " as res _col(28) "(0 < " %5.4f `q0' " < 1)"
di as txt _col(5) "1- Heo Range Q1: " as res _col(28) "(0 < " %5.4f `q1' " < 1)"
di as txt _col(5) "2- Heo Range Q2: " as res _col(28) "(0 < " %5.4f `q2' " < 1)"
di as txt _col(5) "3- Heo Range Q3: " as res _col(28) "(0 < " %5.4f `q3' " < 1)"
di as txt _col(5) "4- Heo Range Q4: " as res _col(28) "(0 < " %5.4f `q4' " < 1)"
di as txt _col(5) "5- Heo Range Q5: " as res _col(28) "(0 < " %5.4f `q5' " < 1)"
di as txt _col(5) "6- Heo Range Q6: " as res _col(28) "(0 < " %5.4f `q6' " < 1)"
di _dup(78) "-"
ereturn scalar r2th = `r2th'
ereturn scalar q0 = `q0'
ereturn scalar q1 = `q1'
ereturn scalar q2 = `q2'
ereturn scalar q3 = `q3'
ereturn scalar q4 = `q4'
ereturn scalar q5 = `q5'
ereturn scalar q6 = `q6'
 }
qui tsset `TimeN'
end

program define yxregeq
version 10.0
 syntax varlist 
tempvar `varlist'
gettoken yvar xvar : varlist
local LEN=length("`yvar'")
local LEN=`LEN'+3
di "{p 2 `LEN' 5}" as res "{bf:`yvar'}" as txt " = " "
local kx : word count `xvar'
local i=1
 while `i'<=`kx' {
local X : word `i' of `xvar'
 if `i'<`kx' {
di " " as res " {bf:`X'}" _c
di as txt " + " _c
 }
 if `i'==`kx' {
di " " as res "{bf:`X'}"
 }
local i=`i'+1
 }
di "{p_end}"
di as txt "{hline 78}"
end


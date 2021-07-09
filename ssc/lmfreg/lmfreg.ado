*! lmfreg V1.0 14/08/2012
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

program define lmfreg , eclass
version 11.0
syntax [varlist] [if] [in] , [NOCONStant coll]
tempvar E E2 E3 E4 EE ELin ELog ELYh Eo Es Es1 Ev
tempvar ht ILVal L LDE LE LEo lf LnE2 LOGvars logYh LOGyvar LOGYX_
tempvar LY LYh LYh2 R2oS R2xx Rx Si SSE Time U U2 Ue VIFI wald weit Wi
tempvar Wio WS X0 XQ XQX_ Yb Yh Yh2 Yhb Yho Yt YY YYm YYv Yh_ML Ue_ML TimeN
tempname b B b1 b2 Beta Bv Bv1 Bx Cov D DX E E1 EE1 Eg Ew F 
tempname FGFF fgT FLin FLog h HT IPhi J K L M
tempname M1 M2 OM P Phi Pm Q q1 S Sig2w Sig2 Sig2n Sig2o Sig2o1 Sn Sw 
tempname VaL1 VaL21 VaLv1 Vec vh VM VP W Wald We Wi
tempname Wi1 Wio WY X X0 xq XQ Y Yh YhLin Nn N kx DF kb SSEo llf
tempname YhLog Yi Z Z0 Z1 Zo Zr mh SST1 SST2 V v1 Uew Yhw
tempvar `varlist'
gettoken yvar xvar : varlist
qui marksample touse
qui markout `touse' , strok
qui cap count if `touse'
local N = r(N)
scalar `Nn'=`N'
qui gen `X0'=1 if `touse'
matrix `X0'= J(`N',1,1)
qui gen `TimeN'=_n
qui gen `Time'=_n if `touse'
qui tsset `Time'
local both : list yvar & xvar
if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both LHS and RHS Variables}"
di as res " LHS: `yvar'"
di as res " RHS: `xvar'"
 exit
 }
 if "`coll'"=="" {
_rmcoll `xvar' if `touse' , `noconstant' `coll' forcedrop
local xvar "`r(varlist)'"
 }
local kx : word count `xvar'
tsunab xvar : `xvar'
tokenize `xvar'
local xvar `*'
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
di as txt _col(3) "Wald Test" _col(21) "=" %12.4f as res `wald' _col(37) "|" _col(41) as txt "P-Value > Chi2(" as res `kx' ")" _col(65) "=" %12.4f as res `waldp'
di as txt _col(3) "F-Test" _col(21) "=" %12.4f as res `f' _col(37) "|" _col(41) as txt "P-Value > F(" as res `kx' " , " `DF' ")" _col(65) "=" %12.4f as res `fp'
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
local N=`Nn'
qui tsset `Time'
tempvar E E2 Yh logYh LOGyvar LYh ELYh ELin ELog YhLin YhLog FLin FLog Time
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:*** OLS Linear vs Log-Linear Functional Form Tests}}"
di _dup(78) "{bf:{err:=}}"
qui gen `Time'=_n
qui tsset `Time'
qui regress `yvar' `xvar' if `touse' , `noconstant'
tempname SSELin llflin r2lin r2log  YbG SumLY llflog SSELog r2loga boxcox
tempname boxcoxp bmlin bmlinp bmlog bmlogp dmlin dmlinp dmlog dmlogp r2lina
scalar `SSELin'=e(rss)
scalar `llflin'=-(`N'/2)*ln(2*_pi*(`SSELin'/`N'))-(`N'/2)
scalar `r2lin'=e(r2)
qui predict `E' if `touse' , res
qui gen `E2'=`E'*`E' if `touse' 
qui predict `Yh' if `touse' 
qui correlate `Yh' `yvar' if `touse' 
if `r2lin'==. {
scalar `r2lin'=r(rho)*r(rho)
 }
qui gen `logYh'=ln(`Yh') if `touse' 
qui gen `LOGyvar' = ln(`yvar') if `touse' 
qui regress `LOGyvar' `xvar' if `touse' , `noconstant'
scalar `r2log'=e(r2)
qui predict `LYh' if `touse' 
qui correlate `LYh' `LOGyvar' if `touse'
if `r2log'==. {
scalar `r2log'=r(rho)*r(rho)
 }
scalar `SSELog'=e(rss) 
qui summ `LOGyvar' if `touse' 
scalar `YbG'=exp(r(mean))
scalar `SumLY'=r(sum)
scalar `llflog'=-(`N'/2)*ln(2*_pi*(`SSELog'/`N'))-(`N'/2)-`SumLY'
di as res " {bf:(1) R-squared}"
di as txt _col(7) "Linear  R2" _col(36) "=" %10.4f as res `r2lin'
di as txt _col(7) "Log-Log R2" _col(36) "=" %10.4f as res `r2log'
di _dup(75) "-"
di as res " {bf:(2) Log Likelihood Function (LLF)}"
di as txt _col(7) "LLF - Linear" _col(36) "=" as res %10.4f `llflin'
di as txt _col(7) "LLF - Log-Log" _col(36) "=" as res  %10.4f `llflog'
di _dup(75) "-"
di as res " {bf:(3) Antilog R2}"
qui regress `LOGyvar' `xvar' if `touse' , `noconstant'
scalar `SSELog'=e(rss)
qui gen `ELYh'=exp(`LYh') if `touse' 
qui regress `ELYh' `yvar' if `touse' , `noconstant'
scalar `r2lina'=e(r2)
qui regress `logYh' `LOGyvar' if `touse' , `noconstant'
scalar `r2loga'=e(r2)
di as txt _col(7) "Linear  vs Log-Log: R2Lin" _col(36) "=" %10.4f as res `r2lina'
di as txt _col(7) "Log-Log vs Linear : R2log" _col(36) "=" %10.4f as res `r2loga'
di _dup(75) "-"
scalar `boxcox'=e(N)/2*abs(ln((`SSELin'/`YbG'^2)/`SSELog'))
scalar `boxcoxp'=chi2tail(1, abs(`boxcox'))
di as res" {bf:(4) Box-Cox Test}" _col(36) "=" %10.4f as res `boxcox' as txt _col(50) "P-Value > Chi2(1)" _col(70) %5.4f as res `boxcoxp'
di as txt _col(7) "Ho: Choose Log-Log Model - Ha: Choose Linear  Model"
di _dup(75) "-"
di as res " {bf:(5) Bera-McAleer BM Test}"
qui regress `ELYh' `xvar' if `touse' , `noconstant'
qui predict `ELin' if `touse' , res
qui regress `logYh' `xvar' if `touse' , `noconstant'
qui predict `ELog' if `touse' , res
qui regress `yvar' `xvar' `ELog' if `touse' , `noconstant'
qui test `ELog'=0
di as txt _col(7) "Ho: Choose Linear  Model" _col(36) "=" %10.4f as res r(F) as txt _col(50) "P-Value > F(1, " e(df_r) ")" _col(70) %5.4f as res r(p)
scalar `bmlin'=r(F)
scalar `bmlinp'=r(p) 
qui regress `LOGyvar' `xvar' `ELin' if `touse' , `noconstant'
qui test `ELin'=0
di as txt _col(7) "Ho: Choose Log-Log Model" _col(36) "=" %10.4f as res r(F) as txt _col(50) "P-Value > F(1, " e(df_r) ")" _col(70) %5.4f as res r(p) 
scalar `bmlog'=r(F)
scalar `bmlogp'=r(p) 
di _dup(75) "-"
di as res " {bf:(6) Davidson-Mackinnon PE Test}"
qui regress `yvar' `xvar' if `touse' , `noconstant'
qui predict `YhLin' if `touse' 
qui regress `LOGyvar' `xvar' if `touse' , `noconstant'
qui predict `YhLog' if `touse' 
qui gen `FLin'=`YhLin'-exp(`YhLog') if `touse' 
qui gen `FLog'=`YhLog'-ln(`YhLin') if `touse' 
qui regress `yvar' `xvar' `FLog' if `touse' , `noconstant'
qui test `FLog'=0
di as txt _col(7) "Ho: Choose Linear  Model" _col(36) "=" %10.4f as res r(F) as txt _col(50) "P-Value > F(1, " e(df_r) ")" _col(70) %5.4f as res r(p)
scalar `dmlin'=r(F)
scalar `dmlinp'=r(p) 
qui regress `LOGyvar' `xvar' `FLin' if `touse' , `noconstant'
qui test `FLin'=0
di as txt _col(7) "Ho: Choose Log-Log Model" _col(36) "=" %10.4f as res r(F) as txt _col(50) "P-Value > F(1, " e(df_r) ")" _col(70) %5.4f as res r(p) 
scalar `dmlog'=r(F)
scalar `dmlogp'=r(p) 
di _dup(78) "-"
ereturn scalar r2lin=`r2lin'
ereturn scalar llflin=`llflin'
ereturn scalar r2log=`r2log'
ereturn scalar llflog=`llflog'
ereturn scalar r2lina=`r2lina'
ereturn scalar r2loga=`r2loga'
ereturn scalar boxcox=`boxcox'
ereturn scalar boxcoxp=`boxcoxp'
ereturn scalar bmlin=`bmlin'
ereturn scalar bmlinp=`bmlinp'
ereturn scalar bmlog=`bmlog'
ereturn scalar bmlogp=`bmlogp'
ereturn scalar dmlin=`dmlin'
ereturn scalar dmlinp=`dmlinp'
ereturn scalar dmlog=`dmlog'
ereturn scalar dmlogp=`dmlogp'
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


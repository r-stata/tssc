*! reset V2.0 21/06/2012
*! Emad Abd Elmessih Shehata
*! Assistant Professor
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email:   emadstat@hotmail.com
*! WebPage:               http://emadstat.110mb.com/stata.htm
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

program define reset , eclass
version 11.0
syntax [varlist] [if] [in] , [NOCONStant coll]
tempvar E E2 R2oS SSE Time U U2 Ue wald weit Wi
tempvar Wio WS X0 XQ XQX_ Yb Yh Yh2 Yhb Yho Yhr Yt YY YYm YYv Yh_ML Ue_ML TimeN
tempname b B b1 b2 Beta Bv Bv1 Bx Cov D E F IPhi J K M1 M2 P Phi Pm Q S
tempname Sig2w Sig2 Sig2n Sig2o Sig2o1 VP W Wald We Wi Wi1 Wio WY X X0 xq
tempname XQ Y Yh Nn N kx DF kb SSEo llf Z Z0 Z1 Zo SST1 SST2 V 
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
scalar `R20'=`r2bu'
scalar `f'=`R20'/(1-`R20')*(`N'-`kb')/`kx'
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
ereturn scalar R20=`R20'
ereturn display , `level'
matrix `b'=e(b)
matrix `V'=e(V)
matrix `Bx'=e(b)
local N=`Nn'
qui tsset `Time'
tempvar E E2 Yh Yh2 Yh3 Yh4 SSi SCi SLi CLi WL WS XQX_ 
tempname k0 rim
qui tsset `Time'
qui gen `E' =`Ue_ML' if `touse' 
qui gen `Yh'=`Yh_ML' if `touse'
qui gen `E2'=`Ue_ML'^2 if `touse'
qui summ `Yh' if `touse'
scalar YMin = r(min)
scalar YMax = r(max)
qui gen `WL'=_pi*(2*`Yh'-(YMax+YMin))/(YMax-YMin) if `touse' 
qui gen `WS'=2*_pi*(sin(`Yh_ML')^2)-_pi if `touse' 
qui forvalue j =1/`kx' {
qui foreach i of local xvar {
tempvar vn
gen `vn'`j'=`i' if `touse' 
qui cap drop `XQX_'`i'
qui gen `XQX_'`i' = `vn'`j'*`vn'`j' if `touse'
 }
 }
qui regress `E2' `xvar' `XQX_'* if `touse'
local LMW=e(N)*e(r2)
local LMWp= chi2tail(2, abs(`LMW'))
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:*** {bf:{err:RE}}gression {bf:{err:S}}pecification {bf:{err:E}}rror {bf:{err:T}}ests (RESET)}"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf: Ho: Model is Specified  -  Ha: Model is Misspecified}"
di _dup(78) "-"
di as txt "{bf:* Ramsey Specification ResetF Test}"
forvalue i=2/4 {
tempvar Yhrm`i'
qui gen `Yhr'`i'=`Yh'^`i' if `touse' 
if "`noconstant'"!="" {
qui regress `yvar' `xvar' `Yhr'* if `touse' , noconstant noomitted
scalar `k0'=0
 }
else {
qui regress `yvar' `xvar' `Yhr'* if `touse' , noomitted
 scalar `k0'=1
 }
qui predict `Yhrm`i'' if `touse' , xb
qui correlate `Yhrm`i'' `yvar' if `touse' 
scalar `rim'=r(rho)*r(rho)
scalar resetf`i'=(e(N)-e(df_m)-`k0')*(`rim'-`R20')/((`i'-1)*(1-`rim'))
scalar resetf`i'p= Ftail((`i'-1), (e(N)-e(df_m)-1), resetf`i')
scalar resetf`i'df= (e(N)-e(df_m)-1)
 }
di as txt "- Ramsey RESETF1 Test: Y= X Yh2" _col(41) "= " %7.3f as res resetf2 as txt _col(52) "P-Value > F("1 ",  "    resetf2df ") " _col(72) %5.4f as res resetf2p
di as txt "- Ramsey RESETF2 Test: Y= X Yh2 Yh3" _col(41) "= " %7.3f as res resetf3 as txt _col(52) "P-Value > F("2 ",  "    resetf3df ") " _col(72) %5.4f as res resetf3p
di as txt "- Ramsey RESETF3 Test: Y= X Yh2 Yh3 Yh4" _col(41) "= " %7.3f as res resetf4 as txt _col(52) "P-Value > F("3 ",  "    resetf4df ") " _col(72) %5.4f as res resetf4p
di _dup(78) "-"
di as txt "{bf:* DeBenedictis-Giles Specification ResetL Test}"
forvalue i=1/3 {
qui gen `SLi'`i'=sin(`i'*`WL') if `touse'
qui gen `CLi'`i'=sin(`i'*`WL'+_pi/2) if `touse'
if "`noconstant'"!="" {
qui regress `yvar' `xvar' `SLi'* `CLi'* if `touse' , noomitted noconstant
 }
else {
qui regress `yvar' `xvar' `SLi'* `CLi'* if `touse' , noomitted
 }
qui testparm `SLi'* `CLi'*
di as txt "- Debenedictis-Giles ResetL`i' Test" _col(41) "= " %7.3f as res r(F) as txt _col(52) "P-Value > F("r(df) ", "    r(df_r) ")" _col(72) as res %5.4f r(p)
scalar resetl`i'= r(F)
scalar resetl`i'p=r(p)
 }
di _dup(78) "-"
di as txt "{bf:* DeBenedictis-Giles Specification ResetS Test}"
forvalue i=1/3 {
qui gen `SSi'`i'=sin(`i'*`WS')
qui gen `SCi'`i'=sin(`i'*`WS'+_pi/2)
if "`noconstant'"!="" {
qui regress `yvar' `xvar' `SSi'* `SCi'* if `touse' , noomitted noconstant
 }
 else {
qui regress `yvar' `xvar' `SSi'* `SCi'* if `touse' , noomitted
 }
qui testparm `SSi'* `SCi'*
di as txt "- Debenedictis-Giles ResetS`i' Test" _col(41) "= " %7.3f as res r(F) as txt _col(52) "P-Value > F("r(df) ", "    r(df_r) ")" _col(72) as res %5.4f r(p)
scalar resets`i'= r(F)
scalar resets`i'p=r(p)
 }
di _dup(78) "-"
di as txt "{bf:- White Functional Form Test}: E2= X X2" _col(41) "= " %7.3f as res `LMW' as txt _col(52) "P-Value > Chi2(1)   " _col(72) %5.4f as res `LMWp'
di _dup(78) "-"
ereturn scalar resetf1=resetf2
ereturn scalar resetf1p=resetf2p
ereturn scalar resetf2=resetf3
ereturn scalar resetf2p=resetf3p
ereturn scalar resetf3=resetf4
ereturn scalar resetf3p=resetf4p
ereturn scalar lmw=`LMW'
ereturn scalar lmwp=`LMWp'
ereturn scalar resetl1=resetl1
ereturn scalar resetl1p=resetl1p
ereturn scalar resetl2=resetl2
ereturn scalar resetl2p=resetl2p
ereturn scalar resetl3=resetl3
ereturn scalar resetl3p=resetl3p
ereturn scalar resets1=resets1
ereturn scalar resets1p=resets1p
ereturn scalar resets2=resets2
ereturn scalar resets2p=resets2p
ereturn scalar resets3=resets3
ereturn scalar resets3p=resets3p
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


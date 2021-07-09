*! lmharchxt V1.0 06/08/2015
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

program define lmharchxt, eclass 
version 11.2
syntax varlist [if] [in] , id(str) it(str) [coll NOCONStant cross]
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
di as err " {bf:Independent Variable(s) must be combined with Dependent Variable}"
 exit
 }
 if "`coll'"=="" {
_rmcoll `varlist' if `touse' , `noconstant' `coll' forcedrop
 local varlist "`r(varlist)'"
gettoken yvar xvar : varlist
 }
tempvar absE D DE DF1 E dcs TimeN EE Eo Hat ht
tempvar SST Time weit Wi Wio WS X X0 Bo Yh_ML Ue_ML Z
tempvar Xb XB Xo XQ Yb Yh Yh2 Yhb Yho YY YYm YYv X X0 idv itv DF E2 P Q
tempvar Hat ht LDE LE LEo wald Xb XB Yb Yh Yh2 Yhb Yho YY Z LE LEo P Q
tempname b A B Beta Bx Cov D den DF Dim Dx E E1 Y Yh Yh_ML XQX_
tempname F In IPhi J K kb kx llf M N NC NT Ue_ML Sig2 SSE
tempname P Phi Pm Q Sig2 Sig21 Sig2o YYm YYv SSE SSEo SST1 SST2
tempname Vec Vs W W1 W2 Wald We Wi V V1 Wi1 Wio WS WW WY X X0 XB Xg Xo xq
qui xtset `id' `it'
local idv "`r(panelvar)'"
local itv "`r(timevar)'"
scalar `NC'=r(imax)
scalar `NT'= r(tmax)
qui cap count if `touse'
local N = r(N)
qui gen `TimeN'=_n
qui gen `Time'=_n if `touse'
qui tsset `Time'
 if "`coll'"=="" {
_rmcoll `xvar' if `touse' , `noconstant' `coll' forcedrop
local xvar "`r(varlist)'"
 }
qui gen `X0'=1 if `touse' 
qui mkmat `X0' if `touse' , matrix(`X0')
mkmat `yvar' if `touse' , matrix(`Y')
local kx : word count `xvar'
if "`noconstant'"!="" {
qui mkmat `xvar' if `touse' , matrix(`X')
scalar `kb'=`kx'
qui mean `xvar' if `touse' 
 }
 else { 
qui mkmat `xvar' `X0' if `touse' , matrix(`X')
scalar `kb'=`kx'+1
qui mean `xvar' `X0' if `touse' 
 }
scalar `DF'=`N'-`kb'
qui cap drop `Time'
qui gen `Time'=_n if `touse' 
qui tsset `Time'
qui gen `Wi'=1 if `touse' 
qui gen `weit' = 1 if `touse' 
qui summ `weit' if `touse' 
mkmat `Wi' if `touse' , matrix(`Wi')
matrix `Wi'=diag(`Wi')
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Ordinary Least Squares (OLS) Regression}}"
di _dup(78) "{bf:{err:=}}"
matrix `Beta'=invsym(`X''*`X')*`X''*`Y'
matrix `Ue_ML'=(`Y'-`X'*`Beta')
matrix `Sig2'=`Ue_ML''*`Ue_ML'/`DF'
matrix `Cov'=`Sig2'*invsym(`X''*`X')
qui svmat `Ue_ML' , name(`Ue_ML')
qui rename `Ue_ML'1 `Ue_ML'
matrix `Yh_ML'=`X'*`Beta'
qui svmat `Yh_ML' , name(`Yh_ML')
qui rename `Yh_ML'1 `Yh_ML'
 if "`cross'"!="" {
tempvar Yh E Ue_ML Yh_ML Ehat Yhat
qui tab `id' if `touse'
qui local C = r(r)
qui local N = r(N)
qui summ `id' if `touse'
local cMin= r(min)
local cMax= r(max)
local cT = r(N) / `cMax'
qui gen double `Ue_ML'= 0 if `touse'
qui gen double `Yh_ML'= 0 if `touse'
qui forvalues i = `cMin'/`cMax' {
qui regress `yvar' `xvar' if `id' == `i' 
qui cap drop `Ehat'
qui cap drop `Yhat'
qui predict `Ehat' if `id' == `i', resid
qui predict `Yhat' if `id' == `i'
qui replace `Ue_ML' = `Ehat' if `id' == `i'
qui replace `Yh_ML' = `Yhat' if `id' == `i'
 }
qui mkmat `Ue_ML' if `touse' , matrix(`Ue_ML')
qui mkmat `Yh_ML' if `touse' , matrix(`Yh_ML')
 }

tempname SSEo Sigo r2bu r2bu_a r2raw r2raw_a f fp wald waldp 
tempname r2v r2v_a fv fvp r2h r2h_a fh fhp SSTm SSE1 SST11 SST21 Rho
matrix `SSE'=`Ue_ML''*`Ue_ML'
scalar `SSEo'=`SSE'[1,1]
scalar `Sig2o'=`SSEo'/`DF'
scalar `Sigo'=sqrt(`Sig2o')
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
qui gen `Wio'=`Wi1' if `touse' 
mkmat `Wio' if `touse' , matrix(`Wio')
matrix `Wio'=diag(`Wio')
matrix `Pm' =`Wio'
matrix `IPhi'=`P''*`P'
matrix `Phi'=invsym(`P''*`P')
matrix `J'= J(`N',1,1)
matrix `D'=(`J'*`J''*`IPhi')/`N'
matrix `SSE'=`Ue_ML''*`IPhi'*`Ue_ML'
matrix `SST1'=(`Y'-`D'*`Y')'*`IPhi'*(`Y'-`D'*`Y')
matrix `SST2'=(`Y''*`Y')
scalar `SSE1'=`SSE'[1,1]
scalar `SST11'=`SST1'[1,1]
scalar `SST21'=`SST2'[1,1]
scalar `r2bu'=1-`SSE1'/`SST11'
 if `r2bu'< 0 {
scalar `r2bu'=`r2h'
 }
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
matrix `B'=`Beta''
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
di as txt _col(2) "Sample Size" _col(21) "=" %12.0f as res `N' _col(37) "|" _col(41) as txt "Cross Sections Number" _col(65) "=" _col(73) %5.0f as res `NC'
ereturn post `B' `Cov' , dep(`yvar') obs(`Nof') dof(`Dof')
qui test `xvar'
scalar `f'=r(F)
scalar `fp'= Ftail(`kx', `DF', `f')
scalar `wald'=`f'*`kx'
scalar `waldp'=chi2tail(`kx', abs(`wald'))
di as txt _col(2) "{cmd:Wald Test}" _col(21) "=" %12.4f as res `wald' _col(37) "|" _col(41) as txt "P-Value > {cmd:Chi2}(" as res `kx' ")" _col(65) "=" %12.4f as res `waldp'
di as txt _col(2) "{cmd:F-Test}" _col(21) "=" %12.4f as res `f' _col(37) "|" _col(41) as txt "P-Value > {cmd:F}(" as res `kx' " , " `DF' ")" _col(65) "=" %12.4f as res `fp'
di as txt _col(2) "R2  (R-Squared)" _col(21) "=" %12.4f as res `r2bu' _col(37) "|" as txt _col(41) "Raw Moments R2" _col(65) "=" %12.4f as res `r2raw'
ereturn scalar r2bu =`r2bu'
ereturn scalar r2bu_a=`r2bu_a'
ereturn scalar f =`f'
ereturn scalar fp=`fp'
ereturn scalar wald =`wald'
ereturn scalar waldp=`waldp'
di as txt _col(2) "R2a (Adjusted R2)" _col(21) "=" %12.4f as res `r2bu_a' _col(37) "|" as txt _col(41) "Raw Moments R2 Adj" _col(65) "=" %12.4f as res `r2raw_a'
di as txt _col(2) "Root MSE (Sigma)" _col(21) "=" %12.4f as res `Sigo' as txt _col(37) "|" _col(41) "Log Likelihood Function" _col(65) "=" %12.4f as res `llf'
di _dup(78) "-"
di as txt "- {cmd:R2h}=" %7.4f as res `r2h' _col(17) as txt "{cmd:R2h Adj}=" as res %7.4f `r2h_a' as txt _col(34) "{cmd:F-Test} =" %8.2f as res `fh' _col(51) as txt "P-Value > F(" as res `kx' " , " `DF' ")" _col(72) %5.4f as res `fhp'
if `r2v'<1 {
di as txt "- {cmd:R2v}=" %7.4f as res `r2v' _col(17) as txt "{cmd:R2v Adj}=" as res %7.4f `r2v_a' as txt _col(34) "{cmd:F-Test} =" %8.2f as res `fv' _col(51) as txt "P-Value > F(" as res `kx' " , " `DF' ")" _col(72) %5.4f as res `fvp'
ereturn scalar r2v=`r2v'
ereturn scalar r2v_a=`r2v_a'
ereturn scalar fv=`fv'
ereturn scalar fvp=`fvp'
 }
ereturn scalar r2raw =`r2raw'
ereturn scalar r2raw_a=`r2raw_a'
ereturn scalar llf =`llf'
ereturn scalar sig=`Sigo'
ereturn scalar r2h =`r2h'
ereturn scalar r2h_a=`r2h_a'
ereturn scalar fh =`fh'
ereturn scalar fhp=`fhp'
ereturn scalar kb=`kb'
ereturn scalar kx=`kx'
ereturn scalar DF=`DF'
ereturn scalar NC=`NC'
ereturn scalar NT=`NT'
 ereturn display 
matrix `b'=e(b)
matrix `V'=e(V)
local llf=e(llf)
local kb=e(kb)
local kx=e(kx)
local DF=e(DF)
local NC=e(NC)
local NT=e(NT)
qui drop if `yvar'== .
qui replace `Time'=_n if `touse'
qui tsset `Time'
 local N=`N'
tempvar Time E E2 LE
qui gen `E' =`Ue_ML' if `touse'
qui gen `E2'=`Ue_ML'^2 if `touse'
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:*** Panel Data Heteroscedasticity Engle (ARCH) Test}}"
di _dup(78) "{bf:{err:=}}"
di as txt _col(2) "{bf: Ho: Panel Homoscedasticity - Ha: Panel Heteroscedasticity}"
di
tempname lmharch lmharchp
qui gen `Time'=_n if `touse'
qui tsset `Time'
qui cap drop `LE'
qui gen `LE'=L1.`E2' if `touse' 
qui regress `E2' `LE' if `touse' 
scalar `lmharch'=e(r2)*e(N)
scalar `lmharchp'= chi2tail(1, abs(`lmharch'))
di as txt "- Engle LM ARCH Test AR(1): E2 = E2_1" _col(41) "=" as res %9.4f `lmharch' _col(54) as txt "P-Value > Chi2(1)" _col(73) as res %5.4f `lmharchp'
di _dup(78) "-"
ereturn scalar lmharch=`lmharch'
ereturn scalar lmharchp=`lmharchp'
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
local NX : word count `xvar'
local i=1
 while `i'<=`NX' {
local X : word `i' of `xvar'
if `i'<`NX' {
di " " as res " {bf:`X'}" _c
di as txt " + " _c
 }
if `i'==`NX' {
di " " as res "{bf:`X'}"
 }
local i=`i'+1
 }
di "{p_end}"
di as txt "{hline 78}"
end


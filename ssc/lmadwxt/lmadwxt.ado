*! lmadwxt V1.0 07/03/2015
*! 
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

*! Sahra Khaleel A. Mickaiel
*! Professor (PhD Economics)
*! Cairo University - Faculty of Agriculture - Department of Economics - Egypt
*! Email: sahra_atta@hotmail.com
*! WebPage at IDEAS:      http://ideas.repec.org/f/pmi520.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/pmi520.htm

program define lmadwxt, eclass 
version 11.2
syntax varlist [if] [in] , [id(str) it(str) coll NOCONStant cross]
gettoken yvar xvar : varlist
 local sthlp lmadwxt
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
tempvar D DE DF1 DW E e TimeN EE Eo Es Ev Ew ht idv itv LE
tempvar LEo P Q SBB Sig2 SSE SST Time tm U U2 Ue wald weit Wi Wio WS X X0 Bo
tempvar Yb Yh Yh2 Yhb Yt YY YYm YYv Yh_ML Ue_ML Z D DE DF DF1
tempvar DW E e E2 E3 E4 Ea Ea1 EE Eo Es Es1 LDE LE LEo P Q SBB Sig2 SRho SSE
tempvar Yb Yh Yh2 Yhb Yt YY Z A B b Beta Bx Cov D den DF Dim Dx E E1 Eo
tempname Ew F In IPhi J K kb kx llf N NC Nn NT P Phi Pm Q Rho Sig2 Sig21 Sig2o
tempname SST1 SST2 Ue Ue_ML W W1 W2 Wald waldm We Wi Sig2o1 SSE SSEo
tempname V Wi1 Wio WS X X0 Y Yh Yh_ML YYm YYv
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
_rmcoll `varlist' , `noconstant' `coll' forcedrop
 local varlist "`r(varlist)'"
gettoken yvar xvar : varlist
 }
qui gen `X0'=1 if `touse' 
qui mkmat `X0' if `touse' , matrix(`X0')
mkmat `yvar' if `touse' , matrix(`Y')
local kx : word count `xvar'
if "`noconstant'"!="" {
qui mkmat `xvar' if `touse' , matrix(`X')
scalar `kb'=`kx'
scalar `DF'=`N'-`kx'
qui mean `xvar' if `touse' 
 }
 else { 
qui mkmat `xvar' `X0' if `touse' , matrix(`X')
scalar `kb'=`kx'+1
scalar `DF'=`N'-`kx'
qui mean `xvar' `X0' if `touse' 
 }
qui gen `Wi'=1 if `touse' 
qui gen `weit' = 1 if `touse' 
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
matrix `Yh_ML'=`X'*`Beta'
qui svmat `Yh_ML' , name(`Yh_ML')
qui rename `Yh_ML'1 `Yh_ML'
qui svmat `Ue_ML' , name(`Ue_ML')
qui rename `Ue_ML'1 `Ue_ML'
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
di as txt _col(2) "(Buse 1973) R2" _col(21) "=" %12.4f as res `r2bu' _col(37) "|" as txt _col(41) "Raw Moments R2" _col(65) "=" %12.4f as res `r2raw'
ereturn scalar r2bu =`r2bu'
ereturn scalar r2bu_a=`r2bu_a'
ereturn scalar f =`f'
ereturn scalar fp=`fp'
ereturn scalar wald =`wald'
ereturn scalar waldp=`waldp'
di as txt _col(2) "(Buse 1973) R2 Adj" _col(21) "=" %12.4f as res `r2bu_a' _col(37) "|" as txt _col(41) "Raw Moments R2 Adj" _col(65) "=" %12.4f as res `r2raw_a'
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
ereturn scalar Nn=_N
ereturn scalar NC=`NC'
ereturn scalar NT=`NT'
ereturn display 
local NT=`NT'
qui xtset `id' `it'
local NC1=r(imin)
local NC2=r(imax)
qui tsset `Time'
tempname Rho Rhosq Rw1 Rw2 lmadw
qui tsset `Time'
tempvar Ue_ML1
qui gen `Ue_ML1'=L1.`Ue_ML' if `touse'
qui replace `Ue_ML1' = 0 in 1
tempvar EE1 SSE SSE1 E E2 En Obs E E2 Sig2
tempname E B EE1 SSE SSE1 Ro1 Ro2 lmadh
local icc `id'
local i=`id'+1 
qui levelsof `icc' if `touse' , local(levels)
qui foreach i of local levels {
tempname EA`i' EAL`i' 
tempvar SSR1 SSR2 SSW1 SSW2 EA`i' EAL`i'
mkmat `Ue_ML' if `icc'==`i' , matrix(`EA`i'')
qui svmat `EA`i'' , name(`EA`i'')
qui rename `EA`i''1 `EA`i''
qui gen `EAL`i'' =L.`EA`i'' if `touse' 
 }
qui forvalue i = `NC1'/`NC2' {
tempvar SSR1`i' SSR2`i' SSW1`i' SSW2`i'
 gen `SSR1'`i'=`EAL`i''*`EA`i'' if `touse' 
 replace `SSR1'`i'=0 in 1
 gen `SSR2'`i'=`EAL`i''^2 if `touse' 
 replace `SSR2'`i'=0 in 1
 gen `SSW1'`i'=(`EA`i''-`EAL`i'')^2 if `touse' 
 replace `SSW1'`i'=0 in 1
 gen `SSW2'`i'=`EA`i''^2 if `touse'
 }
tempvar Rov1 Rov2 Rwv1 Rwv2
qui egen `Rov1' = rowtotal(`SSR1'*) if `touse' 
qui summ `Rov1' if `touse' 
scalar `Ro1'=r(sum)
qui egen `Rov2' = rowtotal(`SSR2'*) if `touse' 
qui summ `Rov2' if `touse' 
scalar `Ro2'=r(sum)
scalar `Rho' = `Ro1'/`Ro2'
scalar `Rhosq' = `Ro1'^2/`Ro2'^2
qui egen `Rwv1' = rowtotal(`SSW1'*) if `touse' 
qui summ `Rwv1' if `touse' 
scalar `Rw1'=r(sum)
qui egen `Rwv2' = rowtotal(`SSW2'*) if `touse' 
qui summ `Rwv2' if `touse' 
scalar `Rw2'=r(sum)
scalar `lmadw' =`Rw1'/`Rw2'
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:*** Panel Data Autocorrelation Durbin-Watson Test}}"
di _dup(78) "{bf:{err:=}}"
di as txt _col(2) "{bf: Ho: No AR(1) Panel AutoCorrelation - Ha: AR(1) Panel AutoCorrelation}"
di
di as txt "- Panel Rho Value" _col(35) "=" as res %9.4f `Rho'
di as txt "- Durbin-Watson Test" _col(35) "=" as res %9.4f `lmadw' _col(50) "df: ("  `kb'  " , " `N' ")
di _dup(78) "-"
ereturn scalar rho=`Rho'
ereturn scalar lmadw=`lmadw'
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


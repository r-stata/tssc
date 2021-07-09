*! ridgereg V4.0 25/12/2012
*! 
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage:               http://emadstat.110mb.com/stata.htm
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

program define ridgereg , eclass
version 11.0
syntax [varlist] [if] [in] , [Model(str) WVar(str) tolog aux(str) ///
 NOCONStant Level(passthru) DN KR(real 0) Weights(str) diag mfx(str) ///
 predict(str) resid(str) LMCol iter(int 100) TOLerance(real 0.00001) coll]
gettoken yvar xvar : varlist
local sthlp ridgereg
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
 local both : list xvar & aux
 if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both RHS and Auxiliary Variables}"
di as res " RHS: `xvar'"
di as res " AUX: `aux'"
 exit
 }
tempvar _X _Y Ci CImax CNmax COR DE DF1 DX DX_ DY_ E E2 Eo Es Es1 Ev f1 f13
tempvar fg fgF fgFp Hat ht ILVal L LE LEo lf Ls LVal LVal1 R2oS R2xx Rx
tempvar eigVaLn SH6 SH6v Si SLv2 SSE Time U U2 Ue VIFI wald weit Wi Wio X0
tempvar Yb Yh Yh2 Yhb Yho Yho2 Yhr Yt YY YYm YYv Yh_ML Ue_ML TimeN
tempname b B b1 b2 Beta BOLS BOLS1 Bx CNmax Cond COR corr CORr CORx
tempname Cov CovC Cr D DCor Dr Ds DX E E1 Eg eigVaL Eo EP SLS Koi WMTD
tempname Ew F f1 f13d fg FGFF fgT Go GoRY h Hat hjm HT ICOR IDRmk IPhi
tempname J K L LDCor Ls LVal LVal1 M M1 M2 MatVIF N kx DF llf
tempname OM Omega P Phi Pm q Q q1 q2 Qr rid Rmk RX RY s S S11 VP Wald
tempname S12 sd SH6 Sig2 Sig2n Sig2o Sig2o1 SLv2 v2 VaL Val VaL1 VaL21
tempname We Wi Wi1 Wio WY X X0 Xx Y Yh VaLv1 Vec vh VIF VIFI VM Nn
tempname YhLog Yi Z Zo Zr Zz mh f13 SST1 SST2 V v1 kb Kr sqN Ko SSEo
qui cap count if `touse'
local N = r(N)
scalar `Nn'=`N'
qui gen `TimeN'=_n
qui gen `Time'=_n if `touse'
qui tsset `Time'
qui gen `X0'=1 if `touse'
qui matrix `X0'= J(`N',1,1)
if !inlist("`model'", "orr", "grr1", "grr2", "grr3") {
di 
di as err " {bf:model( )} {cmd:must be} {bf:model({it:orr, grr1, grr2, grr3})}"
di in smcl _c "{cmd: see:} {help ridgereg##03:Ridge Model Options}"
di in gr _c " (ridgereg Help):"
exit
 }
if inlist("`model'", "grr1", "grr2", "grr3") & `kr'>0 {
di 
di as err " {bf:kr(#)} {cmd:works only with:} {bf:model(orr)}"
exit
 }
if inlist("`weights'", "x", "xi", "x2", "xi2") & "`wvar'"=="" {
di
di as err " {bf:wvar( )} {cmd:must be combined with:} {bf:weights(x, xi, x2, xi2)}"
exit
 }
 if inlist("`mfx'", "log") {
 if "`tolog'"=="" {
di 
di as err " {bf:tolog} {cmd:must be combined with} {bf:mfx(log)}"
 exit
 }
 } 
if "`mfx'"!="" {
if !inlist("`mfx'", "lin", "log") {
di 
di as err " {bf:mfx( )} {cmd:must be} {bf:mfx({it:lin})} {cmd:for Linear Model, or} {bf:mfx({it:log})} {cmd:for Log-Log Model}"
exit
 }	
 }
local kx : word count `xvar'
if "`tolog'"!="" {
di _dup(45) "-"
di as err " {cmd:** Data Have been Transformed to Log Form **}"
di as txt " {cmd:** `varlist'} "
di _dup(45) "-"
local vlistlog " `varlist' "
_rmcoll `vlistlog' , `noconstant' `coll' forcedrop
qui foreach var of local vlistlog {
tempvar xyind`var'
qui gen `xyind`var''=`var' 
qui replace `var'=ln(`var') 
qui replace `var'=0 if `var'==.
 }
 }

 if "`coll'"=="" {
_rmcoll `varlist' if `touse' , `noconstant' `coll' forcedrop
 local varlist "`r(varlist)'"
 gettoken yvar xvar : varlist
 if "`aux'"!="" {
_rmcoll `aux' , `noconstant' `coll' forcedrop
local aux "`r(varlist)'"
 }
local xvar " `xvar' `aux' "
_rmcoll `xvar' , `noconstant' `coll' forcedrop
local xvar "`r(varlist)'"
 }
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
 local in=`N'/(`N'-`kb')
 if "`dn'"!="" {
 scalar `DF'=`N'
 local in=1
 }
matrix `Wi'=J(`N',1,1)
qui gen `Wi'=1 if `touse'
qui gen `weit' = 1 if `touse'
 if "`weights'"!="" {
 if !inlist("`weights'", "yh",  "abse", "e2", "le2", "yh2", "x", "xi", "x2", "xi2") {
 di
di as err " {bf:weights( )} {cmd:works only with:} {bf:yh}, {bf:yh2}, {bf:abse}, {bf:e2}, {bf:le2}, {bf:x}, {bf:xi}, {bf:x2}, {bf:xi2}"
 di in smcl _c "{cmd: see:} {help `sthlp'##04:Weight Options}"
 di in gr _c " (ridgereg Help):"
 exit
 }
 }
 if "`wvar'"!="" { 
 qui replace `Wi' = (`wvar')^0.5 if `touse'
 }
if "`weights'"!="" {
qui cap drop `Wi'
qui regress `yvar' `xvar' if `touse' , `noconstant'
qui predict `Yho' if `touse' 
qui predict `Eo' if `touse' , resid
qui regress `Yho' `xvar' if `touse' , `noconstant'
qui predict `Wi' if `touse' 
if inlist("`weights'", "yh") {
qui replace `Wi' = 1/(abs(`Wi'))^0.5 if `touse'
local wtitle "Weighted Regression Type: (Yh)    -   Variable: Yh Predicted Value"
 }
if inlist("`weights'", "abse") {
local wtitle "Weighted Regression Type: (absE)  -   Variable: abs(E) Residual Absolute Value"
qui replace `Wi' = 1/(abs(`Eo'))^0.5 if `touse' 
 }
if inlist("`weights'", "e2") {
local wtitle "Weighted Regression Type: (E2)    -   Variable: E^2 Residual Squared"
qui replace `Wi' = 1/(`Eo'^2)^0.5 if `touse'
 }
if inlist("`weights'", "le2") {
local wtitle "Weighted Regression Type: (lE2)   -   Variable: log(E^2) Log Residual Squared"
qui replace `Wi' = 1/ln((`Eo'^2)^0.5) if `touse'
qui replace `Wi' = 0 if `Wi'==.
 }
if inlist("`weights'", "yh2") {
qui cap drop `Wi'
local wtitle "Weighted Regression Type: (Yh2)   -   Variable: Yh^2 Predicted Value Squared"
qui gen `Yho2' = `Yho'^2 if `touse'  
qui regress `Yho2' `xvar' if `touse' , `noconstant'
qui predict `Wi' if `touse' , xb
qui replace `Wi' = 1/(abs(`Wi'))^0.5 if `touse' 
 } 
if inlist("`weights'", "x") {
local wtitle "Weighted Regression Type: (X)     -   Variable: (`wvar')"
qui replace `Wi' = (`wvar')^0.5 if `touse' 
 } 
if inlist("`weights'", "xi") {
local wtitle "Weighted Regression Type: (Xi)    -   Variable: (1/`wvar')"
qui replace `Wi' = 1/(`wvar')^0.5 if `touse' 
 } 
if inlist("`weights'", "x2") {
local wtitle "Weighted Regression Type: (X2)    -   Variable: (`wvar')^2"
qui replace `Wi' = (`wvar')^2 if `touse'
 } 
if inlist("`weights'", "xi2") {
local wtitle "Weighted Regression Type: (Xi2)   -   Variable: (1/`wvar')^2"
qui replace `Wi' = 1/(`wvar')^2 if `touse'
 }
qui replace `weit' =`Wi'^2 if `touse' 
 }
mkmat `Wi' if `touse' , matrix(`Wi')
matrix `Wi'=diag(`Wi')
matrix `Omega'=`Wi''*`Wi'
matrix `Xx'=`X''*`Omega'*`X'
matrix `Zz'=I(`kb')*0
scalar `Kr'=0
mkmat `Wi' if `touse' , matrix(`Wi')
matrix `Wi'=diag(`Wi')
matrix `Omega'=`Wi''*`Wi'
matrix `Xx'=`X''*`Omega'*`X'
matrix `Zz'=I(`kb')*0
scalar `Kr'=`kr'
qui summ `yvar' if `touse'
qui gen `_Y'`yvar' = `yvar' - `r(mean)' if `touse'
qui foreach var of local xvar {
qui summ `var' if `touse'
qui gen `_X'`var' = `var' - `r(mean)' if `touse'
 }
qui gen `Zo'=0 if `touse'
if "`noconstant'"!="" {
qui mkmat `_X'* if `touse' , matrix(`Zr')
 }
 else {
qui mkmat `_X'* `Zo' if `touse' , matrix(`Zr')
 }
if inlist("`model'", "orr") {
local rtitle "{bf:Ordinary Ridge Regression}"
 }
if inlist("`model'", "grr1") {
local rtitle "{bf:Generalized Ridge Regression}"
if "`noconstant'"!="" {
qui tabstat `xvar' if `touse' , statistics( sd ) save
 }
else {
qui tabstat `xvar' `X0' if `touse' , statistics( sd ) save
 }
 matrix `sd'=r(StatTotal)
 scalar `sqN'=sqrt(`N'-1)
 matrix `WMTD'=diag(`sd')*`sqN'
 matrix `Beta'=invsym(`X''*`Omega'*`X')*`X''*`Omega'*`Y'
 matrix `BOLS'=`WMTD''*`Beta'
 matrix `BOLS'=`BOLS''*`BOLS'
 scalar `BOLS1'=`BOLS'[1,1]
 matrix `Sig2o'=`Y'-`X'*`Beta'
 matrix `Sig2o'=(`Sig2o''*`Sig2o')/`DF'
 scalar `Sig2o1'=`Sig2o'[1,1]
 scalar `Kr'=`kx'*`Sig2o1'/`BOLS1'
 }
if inlist("`model'", "grr2") {
local rtitle "{bf:Iterative Generalized Ridge Regression}"
if "`noconstant'"!="" {
qui tabstat `xvar' if `touse' , statistics( sd ) save
 }
else {
qui tabstat `xvar' `X0' if `touse' , statistics( sd ) save
 }
 matrix `sd'=r(StatTotal)
 scalar `sqN'=sqrt(`N'-1)
 matrix `WMTD'=diag(`sd')*`sqN'
 matrix `Beta'=invsym(`X''*`Omega'*`X')*`X''*`Omega'*`Y'
 matrix `BOLS'=`WMTD''*`Beta'
 matrix `BOLS'=`BOLS''*`BOLS'
 scalar `BOLS1'=`BOLS'[1,1]
 matrix `Sig2o'=`Y'-`X'*`Beta'
 matrix `Sig2o'=(`Sig2o''*`Sig2o')/`DF'
 scalar `Sig2o1'=`Sig2o'[1,1]
 scalar `Kr'=`kx'*`Sig2o1'/`BOLS1'
qui forvalue i=1/`iter' { 
 scalar `Ko'=`Kr'
 matrix `rid'=I(`kb')*`Kr'
 matrix `Zz'=diag(vecdiag(`Zr''*`Zr'*`rid'))
 matrix `Beta'=invsym(`X''*`Omega'*`X'+`Zz')*`X''*`Omega'*`Y'
 matrix `BOLS'=`WMTD''*`Beta'
 matrix `BOLS'=`BOLS''*`BOLS'
 scalar `BOLS1'=`BOLS'[1,1]
 tempname K`i' Koi
 scalar `K`i''=`kx'*`Sig2o1'/`BOLS1'
 scalar `Kr'=`K`i''
 if `Kr'==. {
 scalar `Kr'=0
 }
 scalar `Koi'=abs(`Kr'-`Ko')
 if (`Koi' <= `tolerance') {
 continue, break
 }
 }
 }

if inlist("`model'", "grr3") {
local rtitle "{bf:Adaptive Generalized Ridge Regression}"
qui corr `_X'* `_Y'`yvar' if `touse' 
qui matrix `CovC'=r(C)
qui matrix `RY' = `CovC'[`kb' ,1..`kx']
qui matrix `RX' = `CovC'[1..`kx', 1..`kx']
qui matrix symeigen `Vec' `VaL'=`RX'
qui matrix `VaL1' =`VaL''
qui svmat `VaL1' , name(`VaL1')
qui rename `VaL1'1 `VaL1'
qui replace `VaL1'=1/`VaL1' in 1/`kx' 
qui mkmat `VaL1' in 1/`kx' , matrix(`VaLv1')
qui matrix `VaL21' =diag(`VaLv1')
qui matrix `VaL21' = `VaL21'[1..`kx', 1..`kx']
qui matrix `Go'=`Vec'*`VaL21'*`Vec''
qui matrix `GoRY'=`Go'*`RY''
qui matrix `SSE'=1-`RY'*`GoRY'
qui matrix `Sig2'=`SSE'/`DF'
qui matrix `Qr'=`GoRY''*`GoRY'-`Sig2'*trace(`Go')
qui matrix `L'=`Vec''*`RY''
qui svmat `L' , name(`L')
qui rename `L'1 `L'
 scalar `Kr'=0
qui forvalue i=1/`iter' { 
 tempname Ko`i'
 scalar `Ko'=`Kr'
 scalar `Ko`i''=`Kr'
 matrix `rid'=I(`kx')
 matrix `rid'=vecdiag(`rid')*`Kr'
 matrix `f1'=`VaL1'+`rid''
 cap drop `f1'*
 cap drop `f13'*
 svmat `f1' , name(`f1')
 rename `f1'1 `f1'
 gen double `f13'`i'=`f1'^3 in 1/`kx'
 mkmat `f13'`i' in 1/`kx' , matrix(`f13')
 matrix `f13d'=diag(`f13')
 matrix `f13' =`f13d'[1..`kx', 1..`kx']
 matrix `Rmk' =vecdiag(`f13')'
 matrix `IDRmk'=invsym(`f13')
 matrix `Ls'=`L''*`IDRmk'
 matrix `Ls'=(`Ls'*diag(`L'))'
 cap drop `Ls' `lf'
 svmat `Ls' , name(`Ls'`i')
 rename `Ls'`i'1 `Ls'`i'
 summ `Ls'`i' in 1/`kx'
 scalar `SLS'=r(sum)
 gen double `lf'`i'=`L'/`f1' in 1/`kx'
 mkmat `lf'`i' in 1/`kx' , matrix(`lf'`i')
 matrix `lf'`i' =diag(`lf'`i')
 matrix `lf'`i' = `lf'`i'[1..`kx', 1..`kx']
 matrix `lf'`i' = vecdiag(`lf'`i')'
 matrix `F'=`lf'`i''*`lf'`i'-`Qr'
 scalar `K'`i'=`Ko`i''+(0.5*`F'[1,1]/`SLS')
 scalar `Kr'=`K'`i'
 if `Kr'==. {
 scalar `Kr'=0
 }
 scalar `Koi'=abs(`Kr'-`Ko')
 if (`Koi' <= `tolerance') {
 continue, break
 }
 }
 }
matrix `rid'=I(`kb')*`Kr'
matrix `Zz'=diag(vecdiag((`Zr''*`Zr')*`rid'))
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* (OLS) Ridge Regression - {cmd:`rtitle'}}}"
di _dup(78) "{bf:{err:=}}"
matrix `Omega'=`Wi''*`Wi'
matrix `B'=invsym(`X''*`Omega'*`X'+`Zz')*`X''*`Omega'*`Y'
matrix `E'=`Wi'*(`Y'-`X'*`B')
matrix `Sig2'=`E''*`E'/`DF'
if "`ridge'"!="" & `kr' > 0 {
matrix `Xx'=`X''*`Omega'*`X'
matrix `Cov'=`Sig2'*invsym(`Xx'+`Zz')*`Xx'*invsym(`Xx'+`Zz')
 }
else {
matrix `Cov'=`Sig2'*inv(`X''*`Omega'*`X')
 }
tempname SSEo Sigo r2bu r2bu_a r2raw r2raw_a R20 f fp wald waldp
tempname r2v r2v_a fv fvp r2h r2h_a fh fhp SSTm SSE1 SST11 SST21 Rho
matrix `E'=(`Y'-`X'*`B')
matrix `Yh_ML'=`X'*`B'
matrix `Ue_ML'=`E'
qui svmat `Yh_ML' , name(`Yh_ML')
qui svmat `Ue_ML' , name(`Ue_ML')
qui rename `Yh_ML'1 `Yh_ML'
qui rename `Ue_ML'1 `Ue_ML'
matrix `SSE'=`E''*`E'
scalar `SSEo'=`SSE'[1,1]
scalar `Sig2o'=`SSEo'/`DF'
scalar `Sig2n'=`SSEo'/`N'
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
matrix `SSE'=`E''*`E'
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
matrix `SSE'=`E''*`IPhi'*`E'
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
if "`weights'"!="" { 
di as txt _col(1) "{bf:* " "`wtitle'" " *}"
di _dup(78) "-"
 }
di as txt _col(3) "{bf:Ridge k Value}" _col(21) "=" as res %10.5f `Kr' _col(37) "|" _col(41) "`rtitle'"
di _dup(78) "-"
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
ereturn scalar r2h=`r2h'
ereturn scalar r2h_a=`r2h_a'
ereturn scalar fh=`fh'
ereturn scalar fhp=`fhp'
ereturn scalar Kr=`Kr'
ereturn scalar kb=`kb'
ereturn scalar kx=`kx'
ereturn scalar DF=`DF'
ereturn scalar Nn=_N
ereturn scalar R20=`R20'
ereturn display , `level'
matrix `b'=e(b)
matrix `V'=e(V)
matrix `Bx'=e(b)
if "`predict'"!= "" {
cap drop `predict'
qui gen `predict'=`Yh_ML' if `touse' 
label variable `predict' `"Yh_`model' - Prediction"'
 }
if "`resid'"!= "" {
qui cap drop `resid'
qui gen `resid'=`Ue_ML' if `touse'
label variable `resid' `"Ue_`model' - Residual"'
 }

if "`diag'" != "" {
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* OLS Model Selection Diagnostic Criteria - Model= ({bf:{err:`model'}})}}"
di _dup(78) "{bf:{err:=}}"
ereturn scalar aic=`Sig2n'*exp(2*`kb'/`N')
ereturn scalar laic=ln(`Sig2n')+2*`kb'/`N'
ereturn scalar fpe=`Sig2o'*(1+`kb'/`N')
ereturn scalar sc=`Sig2n'*`N'^(`kb'/`N')
ereturn scalar lsc=ln(`Sig2n')+`kb'*ln(`N')/`N'
ereturn scalar hq=`Sig2n'*ln(`N')^(2*`kb'/`N')
ereturn scalar rice=`Sig2n'/(1-2*`kb'/`N')
ereturn scalar shibata=`Sig2n'*(`N'+2*`kb')/`N'
ereturn scalar gcv=`Sig2n'*(1-`kb'/`N')^(-2)
ereturn scalar llf = `llf'
di as txt "- Log Likelihood Function" _col(45) "LLF" _col(60) "=" %12.4f `e(llf)'
di _dup(75) "-"
di as txt "- Akaike Information Criterion" _col(45) "(1974) AIC" _col(60) "=" %12.4f `e(aic)'
di as txt "- Akaike Information Criterion" _col(45) "(1973) Log AIC" _col(60) "=" %12.4f `e(laic)'
di _dup(75) "-"
di as txt "- Schwarz Criterion" _col(45) "(1978) SC" _col(60) "=" %12.4f `e(sc)'
di as txt "- Schwarz Criterion" _col(45) "(1978) Log SC" _col(60) "=" %12.4f `e(lsc)'
di _dup(75) "-"
di as txt "- Amemiya Prediction Criterion" _col(45) "(1969) FPE" _col(60) "=" %12.4f `e(fpe)'
di as txt "- Hannan-Quinn Criterion" _col(45) "(1979) HQ" _col(60) "=" %12.4f `e(hq)'
di as txt "- Rice Criterion" _col(45) "(1984) Rice" _col(60) "=" %12.4f `e(rice)'
di as txt "- Shibata Criterion" _col(45) "(1981) Shibata" _col(60) "=" %12.4f `e(shibata)'
di as txt "- Craven-Wahba Generalized Cross Validation" _col(45) "(1979) GCV" _col(60) "=" %12.4f `e(gcv)'
di _dup(78) "-"
 }

if "`lmcol'"!="" {
 if `kx' > 1 {
local N=`Nn'
qui tsset `Time'
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:*** Multicollinearity Diagnostic Tests - Model= ({bf:{err:`model'}})}}"
di _dup(78) "{bf:{err:=}}"
di
di as txt "{bf:{err:* Correlation Matrix}}"
qui tsset `Time'
tempvar R2xx Rx VIFI DFF DFF1 DFF2 fgF fgFp SH6v LVal eigVaL
tempvar eigVaLn ILVal R2oS CNmax CImax X 
tempname COR VIF Vec eigVaL VIFI R2xx FGFF LDCor fg CORx fgT DCor X
tempname Cond X0 J S Ds Val Cr Dr LVal1 LVal SLv2 SH6v q0 q1 q2 q3 q4 q5 q6
tempname fgdf fgchi dcor1 dfm R2 R2oSs r2th Kcol Krow MaxLv MinLv SumLv SumILv
 corr `xvar' if `touse' 
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
 scalar `q0'=sqrt((`SLv2'[1,1]-`Kcol')/(`Kcol'*(`Kcol'-1)))
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
}

if "`tolog'"!="" {
qui foreach var of local vlistlog {
qui replace `var'= `xyind`var'' 
 }
 }
if inlist("`mfx'", "lin", "log") {
tempname mfxb mfxe mfxlin mfxlog XMB XYMB YMB YMB1
matrix `Bx'=`Bx'[1, 1..`kx']'
qui mean `xvar' if `touse' 
matrix `XMB'=e(b)'
qui summ `yvar' if `touse' 
scalar `YMB1'=r(mean)
matrix `YMB'=J(rowsof(`XMB'),1,`YMB1')
mata: X = st_matrix("`XMB'")
mata: Y = st_matrix("`YMB'")
if inlist("`mfx'", "lin") {
mata: `XYMB'=X:/Y
mata: `XYMB'=st_matrix("`XYMB'",`XYMB')
matrix `mfxb'=`Bx'
matrix `mfxe'=vecdiag(`Bx'*`XYMB'')'
matrix `mfxlin' =`mfxb',`mfxe',`XMB'
matrix rownames `mfxlin' = `xvar'
matrix colnames `mfxlin' = Marginal_Effect(B) Elasticity(Es) Mean
matlist `mfxlin' , title({bf:* Marginal Effect - Elasticity {bf:(Model= {err:`model'})}: {err:Linear} *}) twidth(10) border(all) lines(columns) rowtitle(Variable) format(%18.4f)
ereturn matrix mfxlin=`mfxlin'
 }
if inlist("`mfx'", "log") {
mata: `XYMB'=Y:/X
mata: `XYMB'=st_matrix("`XYMB'",`XYMB')
matrix `mfxe'=`Bx'
matrix `mfxb'=vecdiag(`Bx'*`XYMB'')'
matrix `mfxlog' =`mfxe',`mfxb',`XMB'
matrix rownames `mfxlog' = `xvar'
matrix colnames `mfxlog' = Elasticity(Es) Marginal_Effect(B) Mean
matlist `mfxlog' , title({bf:* Elasticity - Marginal Effect {bf:(Model= {err:`model'})}: {err:Log-Log} *}) twidth(10) border(all) lines(columns) rowtitle(Variable) format(%18.4f)ereturn matrix mfxlog=`mfxlog'
 }
di as txt " Mean of Dependent Variable =" as res _col(30) %12.4f `YMB1' 
 }
qui tsset `TimeN'
qui cap mata: mata drop *
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


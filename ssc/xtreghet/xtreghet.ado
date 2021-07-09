*! xtreghet V2.0 04/04/2013
*!
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage:               http://emadstat.110mb.com/stata.htm
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

program define xtreghet, eclass 
version 11.0
syntax varlist [if] [in] , id(str) it(str) Model(str) [LMHet mhet(str) coll diag tolog NOLog DN ///
 iter(int 100) vce(passthru) tech(str) level(passthru) NOCONStant MFX(str) PREDict(str) resid(str)]
gettoken yvar xvar : varlist
local sthlp xtreghet
qui marksample touse
qui markout `touse' `varlist' `mhet' , strok
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
 local cns `s(constraints)'
 mlopts mlopts, `cns' `vce' `coll' iter(`iter') tech(`tech')
if "`model'"!="" {
if !inlist("`model'", "xtmln", "xtmlh") {
di
di as err "{bf:model( )} {cmd:options:} {bf:xtmln, xtmlh}"
 exit
 }
 }
 if !inlist("`model'", "xtmlh") & "`mhet'"!="" {
di 
di as err " {bf:mhet({it:varlist})} {cmd:must be combined only with} {bf:model({it:xtmlh})}"
 exit
 }
if inlist("`model'", "xtmlh") {
if "`mhet'"=="" {
 local mhet "`xvar'"
 }
 }
 if "`mfx'"!="" {
if !inlist("`mfx'", "lin", "log") {
di 
di as err " {bf:mfx( )} {cmd:must be} {bf:mfx({it:lin})} {cmd:for Linear Model, or} {bf:mfx({it:log})} {cmd:for Log-Log Model}"
 exit
 }
 }
 if inlist("`mfx'", "log") {
 if "`tolog'"=="" {
di 
di as err " {bf:tolog} {cmd:must be combined with} {bf:mfx(log)}"
 exit
 }
 } 
tempvar _X _Y absE Bw D DE DF1 DW E dcs Time TimeN
tempvar EE Eo Ev Ew LYh2 P Q Sig2 SSE SST U U2 Ue weit Wi Wio WS Bo
tempvar Xb XB Xo XQ Yb Yh Yh2 Yhb Yho Yho2 Yt YY YYm YYv Yh_ML Ue_ML Z
tempvar absE Bw D DE DF DF1 DW E E2 E3 E4 ht LDE LE LEo LnE2 LYh2 SRho X X0
tempname A B b Beta Bm Bx Cov D den DF E E1 Eg Eo P Phi Pm q Q
tempname Ew F HQ In IPhi J K kb kbm kx L lf llf lmhs M 
tempname olsin mh N n NC NE Nn NT Y Yh Yh_ML YYm YYv Z
tempname Sig2 Sig21 Sig2b Sig2o Wald waldm We Wi Sig2n
tempname Sig2o1 Sig2u Sig2w sigox Sn SSE SSEo SST1 SST2 Sw Ue_ML 
tempname v V v1 V1 V1s Wi1 Wio WS WW WY X X0 XB Xg Xo xq 

_rmcoll `varlist' if `touse' , `noconstant' forcedrop
 local varlist "`r(varlist)'"
gettoken yvar xvar : varlist
local kmhet=0
 if "`mhet'"!="" {
_rmcoll `mhet' , `noconstant' forcedrop
 local mhet "`r(varlist)'"
local kmhet : word count `mhet'
 }

qui tab `id' if `touse'
local NCNo= r(r)
qui xtset `id' `it'
local idv "`r(panelvar)'"
local itv "`r(timevar)'"
scalar `NC'=r(imax)
scalar `NT'= r(tmax)
mkmat `idv' if `touse' , matrix(idv)
mkmat `itv' if `touse' , matrix(itv)
mata: idv= st_matrix("idv")
mata: itv= st_matrix("itv")
qui cap count if `touse'
local N = r(N)
qui gen `TimeN'=_n
qui gen `Time'=_n if `touse'
qui tsset `Time'
if "`model'"!="" {
if "`tolog'"!="" {
local vlistlog " `varlist' `mhet' "
qui _rmcoll `vlistlog' , `noconstant' `coll' forcedrop
local vlistlog "`r(varlist)'"
di
di _dup(78) "-"
di as err "{bf:** Dependent & Independent Variables}
di as txt " {cmd:** `varlist'} "
di _dup(78) "-" 
di as err "{bf:** Multiplicative Heteroscedasticity Variables}"
di as txt " {cmd:** `mhet'} "
di _dup(78) "-"
qui foreach var of local vlistlog {
tempvar xyind`var'
qui gen `xyind`var''=`var'
qui replace `var'=ln(`var')
qui replace `var'=0 if `var'==.
 }
 }
qui gen `X0'=1 if `touse' 
qui mkmat `X0' if `touse' , matrix(`X0')
mkmat `yvar' if `touse' , matrix(`Y')
local kx : word count `xvar'
if "`noconstant'"!="" {
qui mkmat `xvar' if `touse' , matrix(`X')
scalar `kb'=`kx'
scalar `DF'=`N'-`kx'-`NC'
qui mean `xvar' if `touse' 
 }
 else { 
qui mkmat `xvar' `X0' if `touse' , matrix(`X')
scalar `kb'=`kx'+1
scalar `DF'=`N'-`kx'-`NC'
qui mean `xvar' `X0' if `touse' 
 }
qui mean `yvar' if `touse' 
matrix `Yb'=e(b)'
if "`dn'"!="" {
scalar `DF'=`N'
 }
matrix `Wi'=J(`N',1,1)
qui gen `Wi'=1 if `touse' 
qui gen `weit' = 1 if `touse' 
qui summ `weit' if `touse' 
mkmat `Wi' if `touse' , matrix(`Wi')
matrix `Wi'=diag(`Wi')
if inlist("`model'", "xtmln") {
local MName "MLE1re"
qui tsset `Time'
qui regress `yvar' `xvar' if `touse' , `noconstant'
 matrix `olsin'=e(b),0,0
local initopt init(`olsin', copy) 
 xi: ml model d0 xtreghet_lfn (`yvar': `yvar' = `xvar' , `noconstant') ///
 (Sigu:) (Sige:) if `touse' , `mlopts' contin `nolog' `diparm' `initopt' maximize search(on) title(`MName')
 local COLNAME " `COLNAME'`yvar':_cons Sigu:_cons Sige:_cons"
qui test `xvar'
scalar `waldm'=r(chi2)
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* MLE Random-Effects Panel Data Regression (Normal Distribution)}}"
di _dup(78) "{bf:{err:=}}"
 }
if inlist("`model'", "xtmlh") {
local MName "MLE2het"
qui tsset `Time'
qui regress `yvar' `mhet' if `touse' , noconstant
tempname olshet
matrix `olshet'=e(b)
qui regress `yvar' `xvar' if `touse' , `noconstant'
tempname olsin
matrix `olsin'=e(b),`olshet',0,0
local initopt init(`olsin', copy) 
 xi: ml model d0 xtreghet_lfh (`yvar': `yvar' = `xvar' , `noconstant') ///
(Hetero: `mhet', noconst) (Sigu:) (Sige:) if `touse' , ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize search(on) title(`MName')
local COLNAME " `COLNAME'`yvar':_cons `mhet' Sigu:_cons Sige:_cons"
qui test `xvar'
scalar `waldm'=r(chi2)
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* MLE Random-Effects Panel Data Regression (Normal Distribution)}}"
di as txt "{bf:{err:* Multiplicative Heteroscedasticity}}"
di _dup(78) "{bf:{err:=}}"
 }
scalar `llf'=e(ll)
matrix `Beta'=e(b)
matrix `Cov'= e(V)
matrix `Beta'=`Beta'[1,1..`kb']'
matrix `Bx'=`Beta'[1..`kx', 1..1]
matrix `E'=`Y'-`X'*`Beta'
matrix `Sig2'=`E''*`E'/`DF'
matrix `Cov' = `Cov'[1..`kb', 1..`kb']
matrix `Yh_ML'=`X'*`Beta'
qui svmat `Yh_ML' , name(`Yh_ML')
qui rename `Yh_ML'1 `Yh_ML'
qui gen `Ue_ML' =`yvar'-`Yh_ML' if `touse'
matrix `Bx' =`Beta'[1..`kx', 1..1]
matrix `Ue_ML'=`Y'-`Yh_ML'
matrix `E'=`Ue_ML'
matrix Yh_ML=`Yh_ML'
matrix Ue_ML=`Ue_ML'
tempname SSEo Sigo r2bu r2bu_a r2raw r2raw_a f fp wald waldp
tempname r2v r2v_a fv fvp r2h r2h_a fh fhp SSTm SSE1 SST11 SST21 Rho
matrix `SSE'=`E''*`E'
scalar `SSEo'=`SSE'[1,1]
scalar `Sig2o'=`SSEo'/`DF'
scalar `Sig2n'=`SSEo'/`N'
scalar `Sigo'=sqrt(`Sig2o')
scalar `Sig2'=`SSEo'/`DF'
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
scalar `f'=`r2bu'/(1-`r2bu')*(`N'-`kb')/`kx'
scalar `fp'= Ftail(`kx', `DF', `f')
scalar `wald'=`f'*`kx'
scalar `waldp'=chi2tail(`kx', abs(`wald'))
if `llf' == . {
scalar `llf'=-(`N'/2)*log(2*_pi*`SSEo'/`N')-(`N'/2)
 }
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
di as txt _col(3) "Sample Size" _col(21) "=" %12.0f as res `N' _col(37) "|" _col(41) as txt "Cross Sections Number" _col(65) "=" _col(73) %5.0f as res `NCNo'
if inlist("`model'", "xtmln", "xtmlh") & "`robust'"!="" {
scalar `wald'=`waldm'
scalar `f'=`wald'/`kx'
scalar `r2bu'=(`f'*`kx')/((`f'*`kx')+(`N'-`kx'))
scalar `r2bu_a'=1-((1-`r2bu')*(`N'-1)/`DF')
scalar `fp'= Ftail(`kx', `DF', `f')
scalar `waldp'=chi2tail(`kx', abs(`wald'))
 }
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
ereturn scalar r2h =`r2h'
ereturn scalar r2h_a=`r2h_a'
ereturn scalar fh =`fh'
ereturn scalar fhp=`fhp'
ereturn scalar kmhet=`kmhet'
ereturn scalar kb=`kb'
ereturn scalar kx=`kx'
ereturn scalar DF=`DF'
ereturn scalar Nn=_N
ereturn scalar NC=`NC'
ereturn scalar NT=`NT'
local llf=e(llf)
local kmhet=e(kmhet)
local kb=e(kb)
local kx=e(kx)
local DF=e(DF)
local N=e(Nn)
local NC=e(NC)
local NT=e(NT)
 Display , `level' `robust'
matrix `b'=e(b)
matrix `V'=e(V)
qui replace `Time'=_n if `touse'
qui tsset `Time'
 local N=`N'
qui mkmat `X0' if `touse' , matrix(`X0')
matrix `SSE'=`Ue_ML''*`Ue_ML'
 }
if "`model'"!="" & "`diag'"!= "" {
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Panel Model Selection Diagnostic Criteria - Model= ({bf:{err:`model'}})}}"
di _dup(78) "{bf:{err:=}}"
scalar `kbm'=`kmhet'+`kb'+3
ereturn scalar aic=`Sig2n'*exp(2*`kbm'/`N')
ereturn scalar laic=ln(`Sig2n')+2*`kbm'/`N'
ereturn scalar fpe=`Sig2o'*(1+`kbm'/`N')
ereturn scalar sc=`Sig2n'*`N'^(`kbm'/`N')
ereturn scalar lsc=ln(`Sig2n')+`kbm'*ln(`N')/`N'
ereturn scalar hq=`Sig2n'*ln(`N')^(2*`kbm'/`N')
ereturn scalar rice=`Sig2n'/(1-2*`kbm'/`N')
ereturn scalar shibata=`Sig2n'*(`N'+2*`kbm')/`N'
ereturn scalar gcv=`Sig2n'*(1-`kbm'/`N')^(-2)
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
if "`model'"!="" & "`lmhet'"!= "" {
tempvar Yh Yh2 LYh2 E E2 E3 E4 LnE2 absE time LE ht U2
tempvar Sig2 SigLR SigLM SigW E E2 En cN cT Obs Egh
tempname SigLRs SigLMs SigWs
qui tsset `Time'
qui regress `yvar' `xvar' if `touse' , `noconstant'
qui predict `E' if `touse' , res
qui gen double `E2' = `E'^2 if `touse'
qui summ `E2' if `touse' , meanonly
local Sig2 = r(mean)
qui gen double `SigLR' = . if `touse'
qui gen double `SigLM' = . if `touse'
qui gen double `SigW'  = . if `touse'
local SigLRs = 0
local SigLMs = 0
local SigWs  = 0
qui levelsof `idv' if `touse' , local(levels)
qui foreach l of local levels {
 summ `E2' if `idv' == `l', meanonly
 replace `SigLM'= (r(mean)/`Sig2'-1)^2 if `idv' == `l'
 replace `SigLR'= ln(r(mean))*r(N) if `idv' == `l'
 replace `SigW' = (`Sig2'/r(mean)-1)^2 if `idv' == `l'
 summ `SigLM' if `idv' == `l', meanonly
local SigLMs =`SigLMs'+ r(mean)
 summ `SigLR' if `idv' == `l', meanonly
local SigLRs = `SigLRs' + r(mean)
 summ `SigW' if `idv' == `l', meanonly
local SigWs =`SigWs'+ r(mean)
 }
local dflm= `NC'-1
local dflr= `NC'-1
local dfw = `NC'
tempname lmhglr lmhglrp lmhglm lmhglmp lmhgw lmhgwp
scalar `lmhglr'=`N'*ln(`Sig2')- `SigLRs'
scalar `lmhglrp'= chi2tail(`dflr', abs(`lmhglr'))
scalar `lmhglm'=`NT'/2*(`SigLMs')
scalar `lmhglmp'= chi2tail(`dflm', abs(`lmhglm'))
scalar `lmhgw'=`NT'/2*(`SigWs')
scalar `lmhgwp'= chi2tail(`dfw', abs(`lmhgw'))
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Panel Groupwise Heteroscedasticity Tests}}"
di _dup(78) "{bf:{err:=}}"
di as txt _col(2) "{bf: Ho: Panel Homoscedasticity - Ha: Panel Groupwise Heteroscedasticity}"
di
di as txt "- Lagrange Multiplier LM Test" _col(35) "=" as res %9.4f `lmhglm' as txt _col(50) "P-Value > Chi2(" `dflm' ")" _col(70) %5.4f as res `lmhglmp'
di as txt "- Likelihood Ratio LR Test" _col(35) "=" as res %9.4f `lmhglr' _col(50) as txt "P-Value > Chi2(" `dflr' ")" _col(70) %5.4f as res `lmhglrp'
di as txt "- Wald Test" as res _col(35) "=" as res %9.4f `lmhgw' _col(50) as txt "P-Value > Chi2(" `dfw' ")" _col(70) %5.4f as res `lmhgwp'
di _dup(78) "-"
ereturn scalar lmhglr=`lmhglr'
ereturn scalar lmhglrp=`lmhglrp'
ereturn scalar lmhglm=`lmhglm'
ereturn scalar lmhglmp=`lmhglmp'
ereturn scalar lmhgw=`lmhgw'
ereturn scalar lmhgwp=`lmhgwp'
 }
if "`predict'"!= "" {
qui cap drop `predict'
qui gen `predict' = `Yh_ML' if `touse'
label variable `predict' `"Yh - Prediction"'
 }
if "`resid'"!= "" {
qui cap drop `resid'
qui gen `resid'=`Ue_ML' if `touse'
label variable `resid' `"Eu - Residual"'
 }
if "`tolog'"!="" {
qui foreach var of local vlistlog {
qui replace `var'= `xyind`var'' 
 }
 }
if inlist("`mfx'", "lin", "log") {
tempname mfxb mfxe mfxlin mfxlog XMB XYMB YMB YMB1
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
matrix `mfxb' =`Bx'
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
matlist `mfxlog' , title({bf:* Elasticity - Marginal Effect {bf:(Model= {err:`model'})}: {err:Log-Log} *}) twidth(10) border(all) lines(columns) rowtitle(Variable) format(%18.4f)
ereturn matrix mfxlog=`mfxlog'
 }
di as txt " Mean of Dependent Variable =" as res _col(30) %12.4f `YMB1' 
 }
qui tsset `TimeN'
qui cap mata: mata drop *
qui cap matrix drop Ue_ML Yh_ML itv idv
end

program define Display
version 10.0
 syntax, [Level(int $S_level) robust]
if "`e(title)'"=="MLE1re" {
ml display, level(`level') neq(1) noheader diparm(Sigu, label("Sigu")) ///
 diparm(Sige, label("Sige"))
 }
if "`e(title)'"=="MLE2het" {
ml display, level(`level') neq(2) noheader diparm(Sigu, label("Sigu")) ///
 diparm(Sige, label("Sige"))
 }
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


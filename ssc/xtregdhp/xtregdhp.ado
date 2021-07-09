*! xtregdhp V2.0 04/04/2013
*!
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage:               http://emadstat.110mb.com/stata.htm
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

program define xtregdhp, eclass 
version 11.0
syntax varlist [if] [in] , id(str) it(str) [LMHet coll diag tolog zero MFX(str) ///
level(passthru) NOCONStant PREDict(str) RESid(str) iter(int 100) be fe re]
gettoken yvar xvar : varlist
local sthlp xtregdhp
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
tempvar EE Eo Ev Ew LYh2 P Q Sig2 SSE SST U U2 Ue wald weit Wi Wio WS Bo
tempvar Xb XB Xo XQ Yb Yh Yh2 Yhb Yho Yho2 Yt YY YYm YYv Yh_ML Ue_ML Z
tempvar absE Bw D DE DF DF1 DW E E2 E3 E4 ht LDE LE LEo LnE2 LYh2 X X0
tempname A B b Beta Bm Bx Cov D den DF dfab Dim DVE DVNE Dx E E1 Eg Eo eVec
tempname Ew F gam gam2 HQ In IPhi J K kb Sig2 Sig21 Sig2o kx L llf M Sig2n
tempname N NC NE Nn NT Omega P Phi Pm Q Y Yh Yh_ML YYm YYv
tempname Sig2o1 sigox Sn SSE SSEo SST1 SST2 Sw Ue Ue_ML Vec vh VM VN VP VQ Vs
tempname v V v1 V1 V1s Wi1 Wio WMTD WS WW WY X X0 XB Xg Xo xq W Wald waldm We Wi
 if "`coll'"=="" {
_rmcoll `varlist' if `touse' , `noconstant' `coll' forcedrop
 local varlist "`r(varlist)'"
gettoken yvar xvar : varlist
 }
qui tab `id' if `touse'
local NCNo= r(r)
qui xtset `id' `it'
scalar `NC'=r(imax)
scalar `NT'= r(tmax)
qui cap count if `touse'
local N = r(N)
qui gen `TimeN'=_n
qui gen `Time'=_n if `touse'
qui tsset `Time'
if "`tolog'"!="" {
local vlistlog " `varlist' "
qui _rmcoll `vlistlog' , `noconstant' `coll' forcedrop
local vlistlog "`r(varlist)'"
di _dup(45) "-"
di as err " {cmd:** Data Have been Transformed to Log Form **}"
di as txt " {cmd:** `varlist'} "
di _dup(45) "-"
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
local kx=`kx'+1
scalar `kb'=`kx'
scalar `DF'=`N'-`kx'-`NC'
qui mean `xvar' if `touse' 
 }
 else { 
qui mkmat `xvar' `X0' if `touse' , matrix(`X')
local kx=`kx'+1
scalar `kb'=`kx'+1
scalar `DF'=`N'-`kx'-`NC'
qui mean `xvar' `X0' if `touse' 
 }
qui mean `yvar' if `touse' 
matrix `Yb'=e(b)'
matrix `Wi'=J(`N',1,1)
qui gen `Wi'=1 if `touse' 
qui gen `weit' = 1 if `touse' 
ereturn scalar kb=`kb'
ereturn scalar kx=`kx'
ereturn scalar DF=`DF'
ereturn scalar Nn=`N'
ereturn scalar NC=`NC'
ereturn scalar NT=`NT'
tempvar L_yvar dy dy1 Z0 Eh
tempname ldye12 By Covx Covy Beta0 Beta1 kbd0 xz Bh xy2
qui gen `L_yvar'=L.`yvar' if `touse'
qui replace `L_yvar'=0 if `L_yvar'==.
di 
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Han-Philips (2010) Linear Dynamic Panel Data Regression}}"
di _dup(78) "{bf:{err:=}}"
tempname kbd
scalar `kbd'=`kx'
 if "`noconstant'"!="" {
scalar `kbd'=`kx'-1
 }
qui gen `dy' = D.`yvar'  if `touse'
qui gen `dy1'= L.`dy' if `touse'
qui gen `Z0' = 1  if `touse'
scalar `Beta0' = .
scalar `Beta1' = 0
local j = 1
 while `j' <= `iter' & abs(`Beta1'-`Beta0') > 0.00001 {
 tempvar Y Ys
 scalar `Beta0' = `Beta1'
qui gen `Y' = `yvar' - `Beta0' * L.`yvar' if `touse'
 local varhp
 foreach var of local xvar {
 tempvar dxv
 qui gen `dxv' = `var' - `Beta0' * L.`var' if `touse'
 local varhp "`varhp' `dxv'"
 }
qui xtset `id' `it'
 if "`be'"=="" &"`fe'"=="" & "`mle'"=="" {
qui xtreg `Y' `varhp' if `touse' , re
  }
else {
qui xtreg `Y' `varhp' if `touse' , `fe' `be'
 }
 matrix `Bx' = e(b)
 matrix `Covx'= e(V)
qui gen `Ys' = `yvar' if `touse'
 local k = 1
qui foreach x of local xvar {
 qui replace `Ys' = `Ys' - `Bx'[1,`k'] * `x' if `touse'
 local k = `k' + 1
  }
 qui replace `Z0' = 1 - _b[_cons] if `touse'
 tempvar dy ldy ldy2 Eh ldye ldye1
 qui gen `dy' = D.`Ys' if `touse'
 qui gen `ldy' = L.`dy' if `touse'
 qui gen `ldy2'= 2*`dy'+`ldy' if `touse'
if "`noconstant'"!="" {
 qui matrix accum `xy2' = `ldy' `ldy2' if `touse' , `noconstant'
 }
 else {
 qui matrix accum `xy2' = `ldy' `ldy2' `Z0' if `touse' , `noconstant'
 }
 matrix `By'= `xy2'[2,1]/`xy2'[1,1]
 local  By1 = `By'[1,1]
 qui gen `Eh'= `ldy2' - `By1' * `ldy' if `touse'
 qui gen `ldye' = `ldy' * `Eh' if `touse'
 qui by `id': egen `ldye1' = sum(`ldye') if `touse'
 qui by `id': replace `ldye1' = `ldye1'/sqrt(_N) if `touse'
 qui matrix accum `ldye12' = `ldye1' if `touse' , `noconstant'
 matrix `Covy' = `ldye12'[1,1] / (`xy2'[1,1]^2)
 scalar `Beta1' = `By'[1,1]
 local j = `j' + 1
 }
 matrix `Beta' = `By'[1,1],`Bx'[1,1..`kbd']
 matrix `kbd0' = J(1,`kbd',0)
 matrix `Cov' = `Covy',`kbd0' \ `kbd0'',`Covx'[1..`kbd',1..`kbd']
 tokenize "L.`yvar' `xvar' "
 if "`noconstant'"!="" {
matrix colnames `Cov' = `*'
matrix rownames `Cov' = `*'
matrix colnames `Beta'= `*'
 }
 else { 
matrix colnames `Cov' = `*' _cons
matrix rownames `Cov' = `*' _cons
matrix colnames `Beta'= `*' _cons
 }
ereturn post `Beta' `Cov' , depname("`yvar'")
matrix `Beta'=e(b)
ereturn scalar df_m=`kx'
local kx=`kx'
ereturn scalar kx=`kx'
qui predict `Yh_ML' if `touse' , xb
qui gen `Ue_ML'=`yvar'- `Yh_ML' if `touse'
qui markout `touse' `Yh_ML' `Ue_ML' , strok
matrix `Beta'=e(b)
matrix `Beta'=`Beta'[1,1..`kb']'
matrix `Cov'= e(V)
matrix `Cov' = `Cov'[1..`kb', 1..`kb']
qui mkmat `yvar' if `touse' , matrix(`Y')
if "`noconstant'"!="" {
mkmat `L_yvar' `xvar' if `touse' , matrix(`X')
 }
 else { 
qui mkmat `L_yvar' `xvar' `X0' if `touse' , matrix(`X')
 }
scalar `llf'=e(ll)
qui summ `yvar' if `touse'
local N = r(N)
qui gen `E'=`yvar'-`Yh_ML' if `touse'
qui mkmat `E' if `touse' , matrix(`E')
matrix `Sig2'=`E''*`E'/`DF'
scalar `Sig21'=`Sig2'[1,1]
scalar `sigox'=sqrt(`Sig21')
qui tabulate `id' if `touse' , generate(`dcs')
mkmat `dcs'* if `touse' , matrix(`D')
matrix `P'=`D'*invsym(`D''*`D')*`D''
matrix `Q'=I(`N')-`P'
mkmat `Yh_ML' if `touse'  , matrix(`Yh_ML')
matrix `Ue_ML'=`Q'*(`Y'-`Yh_ML')
matrix `Bx' =`Beta'[1..`kx', 1..1]
tempname SSEo Sigo r2bu r2bu_a r2raw r2raw_a f fp wald waldp
tempname r2v r2v_a fv fvp r2h r2h_a fh fhp SSTm SSE1 SST11 SST21 Rho
matrix `SSE'=`Ue_ML''*`Ue_ML'
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
yxregeq `yvar' `xvar'
di as txt _col(3) "Sample Size" _col(21) "=" %12.0f as res `N' _col(37) "|" _col(41) as txt "Cross Sections Number" _col(65) "=" _col(73) %5.0f as res `NCNo'
local lyx "L.`yvar' "
local lyx "`lyx' L`lag'.`yvar'"
qui test "`lyx'" `xvar'
scalar `wald'=r(chi2)
scalar `f'=`wald'/r(df)
scalar `r2bu'=(`f'*r(df))/((`f'*r(df))+(`N'-r(df)))
scalar `r2bu_a'=1-((1-`r2bu')*(`N'-1)/(`N'-r(df)))
scalar `fp'= Ftail(r(df), `DF'-r(df), `f')
scalar `waldp'=chi2tail(r(df), abs(`wald'))
scalar `Sigo'=`sigox'
scalar `llf'=-(`N'/2)*log(2*_pi*`SSEo'/`N')-(`N'/2)
local kb=`kx'+1
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
ereturn scalar kb=`kb'
ereturn scalar kx=`kx'
ereturn scalar DF=`DF'
ereturn scalar Nn=_N
ereturn scalar NC=`NC'
ereturn scalar NT=`NT'
local llf=e(llf)
local kb=e(kb)
local kx=e(kx)
local DF=e(DF)
local N=e(Nn)
local NC=e(NC)
local NT=e(NT)
ereturn display , `level'
matrix `b'=e(b)
matrix `V'=e(V)
qui tsset `Time'
 local N=`N'
qui mkmat `X0' if `touse' , matrix(`X0')
if "`diag'"!= "" {
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Panel Model Selection Diagnostic Criteria}}"
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

if "`lmhet'"!= "" {
tempvar Yh Yh2 LYh2 E E2 E3 E4 LnE2 absE LE ht U2
qui tsset `Time'
tempvar L_yvar
qui gen `L_yvar'=L.`yvar' if `touse'
qui replace `L_yvar'=0 if `L_yvar'==.
tokenize "L.`yvar' `xvar' "
local xvar `L_yvar' `xvar'
tempvar Sig2 SigLR SigLRs SigLM SigLMs SigW SigWs E E2 EE1 En cN cT Obs Egh
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
qui levelsof `id' if `touse' , local(levels)
qui foreach l of local levels {
 summ `E2' if `id' == `l', meanonly
 replace `SigLM'= (r(mean)/`Sig2'-1)^2 if `id' == `l'
 replace `SigLR'= ln(r(mean))*r(N) if `id' == `l'
 replace `SigW' = (`Sig2'/r(mean)-1)^2 if `id' == `l'
 summ `SigLM' if `id' == `l', meanonly
local SigLMs =`SigLMs'+ r(mean)
 summ `SigLR' if `id' == `l', meanonly
local SigLRs = `SigLRs' + r(mean)
 summ `SigW' if `id' == `l', meanonly
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
gettoken yvar xvar : varlist
tempvar L_yvar
qui gen `L_yvar'=L.`yvar' if `touse'
qui replace `L_yvar'=0 if `L_yvar'==.
tokenize "L.`yvar' `xvar' "
local xvar `L_yvar' `xvar'
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
matrix rownames `mfxlin' = `*'
matrix colnames `mfxlin' = Marginal_Effect(B) Elasticity(Es) Mean
matlist `mfxlin' , title({bf:* Marginal Effect - Elasticity: {err:Linear} *}) twidth(10) border(all) lines(columns) rowtitle(Variable) format(%18.4f)
ereturn matrix mfxlin=`mfxlin'
 }
if inlist("`mfx'", "log") {
mata: `XYMB'=Y:/X
mata: `XYMB'=st_matrix("`XYMB'",`XYMB')
matrix `mfxe'=`Bx'
matrix `mfxb'=vecdiag(`Bx'*`XYMB'')'
matrix `mfxlog' =`mfxe',`mfxb',`XMB'
matrix rownames `mfxlog' = `*'
matrix colnames `mfxlog' = Elasticity(Es) Marginal_Effect(B) Mean
matlist `mfxlog' , title({bf:* Elasticity - Marginal Effect: {err:Log-Log} *}) twidth(10) border(all) lines(columns) rowtitle(Variable) format(%18.4f)
ereturn matrix mfxlog=`mfxlog'
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

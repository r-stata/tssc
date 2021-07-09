*! gs3sls V3.0 03/03/2013
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage:               http://emadstat.110mb.com/stata.htm
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

program define gs3sls , eclass 
 version 11.0
syntax varlist [aw] , WMFile(str) var2(str) [aux(str) zero diag ///
 INV INV2 vce(passthru) stand ols 2sls 3sls sure mvreg TESTs LMSPac ///
 iter(int 100) LMNorm ORDer(int 1) level(passthru) NOCONStant ///
 MFX(str) LMHet coll PREDict(str) RESid(str) tolog EQ(int 1)]
local sthlp gs3sls
if "`var2'"=="" {
di
di as err " {bf:var2({it:varlist})} {cmd:is required:}"
di
di _dup(78) "{bf:{err:-}}"
di as err " {bf:if you have system of 2 Equations:}"
di as err _col(10) "{cmd:Y1 = Y2 X1 X2}"
di as err _col(10) "{cmd:Y2 = Y1 X3 X4}"
di as err " {cmd:Variables of Eq. 1 will be Dep. & Indep. Variables}"
di as err " {cmd:Variables of Eq. 2 will be Dep. & Indep. Variables in option var2( ); i.e,}"
di as err " {bf:gs3sls y1 x1 x2 , wmfile(SPWcs) var2(y2 x3 x4)} eq(1)"
di as err " {bf:gs3sls y1 x1 x2 , wmfile(SPWcs) var2(y2 x3 x4)} eq(2)"
di _dup(78) "{bf:{err:-}}"
exit
 }
 local varlist1 `varlist'
 local varlist2 `var2'
 gettoken yvar xvar  : varlist
 gettoken yvar xvar1 : varlist1
 gettoken endg xvar2 : varlist2
 if "`xvar'"=="" | "`xvar1'"=="" {
di as err "  {bf:Independent Variable(s) must be combined with Dependent Variable}"
 exit
 }
 local both : list yvar & xvar
 if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both LHS & RHS Variables}"
di as res " LHS: `yvar'"
di as res " RHS: `xvar'"
 exit
 } 
 local both : list yvar & xvar1
 if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both LHS1 and RHS1 Variables}"
di as res " LHS1: `yvar'"
di as res " RHS1: `xvar1'"
 exit
 }
 local both : list yvar & endg
 if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both LHS1 and LHS2 Variables}"
di as res " LHS1: `yvar'"
di as res " LHS2: `varlist2'"
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
 local both : list xvar1 & aux
 if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both RHS1 and Auxiliary Variables}"
di as res " RHS1: `xvar1'"
di as res " AUX: `aux'"
 exit
 }
 local both : list xvar2 & aux
 if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both RHS2 and Auxiliary Variables}"
di as res " RHS2: `xvar2'"
di as res " AUX: `aux'"
 exit
 }
 local both : list xvar1 & endg
 if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both RHS1 and LHS2 Variables}"
di as res " RHS1: `xvar1'"
di as res " LHS2: `endg'"
 exit
 }
 if ("`inv'"!="" | "`inv2'"!="" ) & "`stand'"=="" {
di
di as err " {bf:inv, inv2} {cmd:and} {bf:stand} {cmd:must be combined}"
exit
 }
if "`tests'"!="" {
local lmspac "lmspac"
local diag "diag"
local lmhet "lmhet"
local lmnorm "lmnorm"
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
 if inlist(`order',1,2,3,4)==0 {
di 
di as err " {bf:order(#)} {cmd:number must be 1, 2, 3, or 4.}"
 exit
 }
tempvar _X _Y absE Bw D DE DF DF1 DumE E XQX_ EE Eo Es Ev Ew
tempvar Hat ht LE LEo LYh2 P Q Sig2 SSE SST Time U U2 wald weit Wi Wio WS
tempvar Xb XB Xo XQ Yb Yh Yh2 Yhb Yt YY YYm YYv Yh_ML Ue_ML Z X X0
tempname A B b B1 b1 b2 Beta Bm Bt Bv Bx Cov D den DVE Dx E E1
tempname IPhi J K L lf Ls M M1 M2 mh n P Phi Pm Q q1 q2 V1 v1 In Ew F
tempname Sig2 Sig2o Sn SSE SST1 SST2 D WW eVec eigw Xo Sig2n
tempname Vec vh VM VP VQ Vs W W1 W2 Wald We Wi Wi1 Wio WY X XB V kz llf
tempname xq Y Yh Yi YYm YYv Z Z0 Z1 Zo X0 Ue N DF kx kb kb1 kb2 Dim NC NT Nmiss
di
local N=_N
scalar `Dim' = `N'
local MSize= `Dim'
if `c(matsize)' < `MSize' {
di as err " {bf:Current Matrix Size = (`c(matsize)')}"
di as err " {bf:{help matsize##|_new:matsize} must be >= Sample Size" as res " (`MSize')}"
qui set matsize `MSize'
di as res " {bf:matsize increased now to = (`c(matsize)')}"
 }
if "`wmfile'" != "" {
preserve
qui use `"`wmfile'"', clear
qui summ
if `N' !=r(N) {
di
di as err "*** {bf:Spatial Weight Matrix Not Has the Same Data Sample Size}"
 exit
 }
mkmat * , matrix(_WB)
qui egen ROWSUM=rowtotal(*)
qui count if ROWSUM==0
local NN=r(N)
if `NN'==1 {
di as err "*** {bf:Spatial Weight Matrix Has (`NN') Location with No Neighbors}"
 }
else if `NN'>1 {
di as err "*** {bf:Spatial Weight Matrix Has (`NN') Locations with No Neighbors}"
 }
local NROW=rowsof(_WB)
local NCOL=colsof(_WB)
if `NROW'!=`NCOL' {
di as err "*** {bf:Spatial Weight Matrix is not Square}"
 exit
 }
di _dup(78) "{bf:{err:=}}"
if "`stand'"!="" {
di as res "{bf:*** Standardized Weight Matrix: `N'x`N' (Normalized)}"
matrix `Xo'=J(`N',1,1)
matrix WB=_WB*`Xo'*`Xo''
mata: X = st_matrix("_WB")
mata: Y = st_matrix("WB")
mata: _WS=X:/Y 
mata: _WS=st_matrix("_WS",_WS)
mata: _WS = st_matrix("_WS")
 if "`inv'"!="" {
di as res " {bf:*** Inverse Standardized Weight Matrix (1/W)}"
mata: _WS=1:/_WS
mata: _editmissing(_WS, 0)
mata: _WS=st_matrix("_WS",_WS)
 }
 if "`inv2'"!="" {
di as res " {bf:*** Inverse Squared Standardized Weight Matrix (1/W^2)}"
mata: _WS=_WS:*_WS
mata: _WS=1:/_WS
mata: _editmissing(_WS, 0)
mata: _WS=st_matrix("_WS",_WS)
 }
matrix WCS=_WS
 }
else {
di as res "{bf:*** Binary (0/1) Weight Matrix: `N'x`N' (Non Normalized)}"
matrix WCS=_WB
 }
matrix eigenvalues eigw eVec = WCS
qui matrix eigw=eigw'
matrix WMB=WCS
restore
qui cap drop `eigw'
qui svmat eigw , name(`eigw')
qui rename `eigw'1 `eigw'
qui cap confirm numeric var `eigw'
di _dup(78) "{bf:{err:=}}"
 }
ereturn scalar Nn=_N
qui cap count 
local N = r(N)
qui count 
local N = _N
qui mean `varlist'
scalar `Nmiss' = e(N)
if "`zero'"=="" {
if `N' !=`Nmiss' {
di
di as err "*** {bf:Observations have {bf:(" `N'-`Nmiss' ")} Missing Values}"
di as err "*** {bf:You can use {cmd:zero} option to Convert Missing Values to Zero}"
 exit
 }
 }
 if "`zero'"!="" {
tempvar zeromiss
qui foreach var of local varlist {
qui gen `zeromiss'`var'=`var'
qui replace `var'=0 if `var'==.
 }
 }
qui gen `Time'=_n
qui tsset `Time'
 tempvar `varlist'
 local varlist1 "`varlist'"
 local varlist2 "`var2'"
 if "`tolog'"!="" {
di
di as err " {cmd:** Data Have been Transformed to Log Form **}"
di _dup(78) "-" 
di as err "{bf:** Dependent & Independent Variables}
di as txt " {cmd:** `varlist'} "
di _dup(78) "-" 
 if "`var2'"!="" {
di as txt "{bf:** gs3sls Variables - EQ.(2)}"
di as err " {cmd:** `varlist2'} "
di _dup(78) "-"
 }
 local vlistlog " `varlist' `varlist2' "
_rmcoll `vlistlog' , `noconstant' `coll' forcedrop
 local vlistlog "`r(varlist)'"
qui foreach var of local vlistlog {
 tempvar xyind`var'
 gen `xyind`var''=`var'
 replace `var'=ln(`var')
 replace `var'=0 if `var'==.
 }
}
 if "`coll'"=="" {
_rmcoll `varlist' , `noconstant' `coll' forcedrop
 local varlist "`r(varlist)'"
_rmcoll `var2' , `noconstant' `coll' forcedrop
 local varlist2 "`r(varlist)'"
if "`aux'"!="" {
_rmcoll `aux' , `noconstant' `coll' forcedrop
 local aux "`r(varlist)'"
 }
}
 local varlist1 "`varlist'"
 gettoken yvar xvar  : varlist
 gettoken yvar xvar1 : varlist1
 gettoken endg xvar2 : varlist2
mkmat `yvar' , matrix(`Y')
 if "`wmfile'"!="" {
tempname WS1 WS2 WS3 WS4 xyvar
mkmat `yvar' , matrix(`xyvar')
matrix `WS1'= WMB
matrix `WS2'= WMB*WMB
matrix `WS3'= WMB*WMB*WMB
matrix `WS4'= WMB*WMB*WMB*WMB
qui cap drop w1x_*
qui cap drop w2x_*
qui cap drop w3x_*
qui cap drop w4x_*
qui cap drop w1y_*
qui cap drop w2y_*
qui forvalue i = 1/2 {
qui cap drop w`i'y_*
tempname w`i'y_`yvar'
matrix `w`i'y_`yvar'' = `WS`i''*`xyvar'
svmat  `w`i'y_`yvar'' , name(w`i'y_`yvar')
rename  w`i'y_`yvar'1 w`i'y_`yvar'
label variable w`i'y_`yvar' `"AR(`i') `yvar' Spatial Lag"'
 }
qui cap drop w1y_*
qui cap drop w2y_*
tempname xyvar
local ydoy `yvar' `endg'
qui forvalue i = 1/2 {
qui foreach var of local ydoy {
tempname w`i'y_`var'
mkmat `var' , matrix(`var')
matrix `w`i'y_`var'' = `WS`i''*`var'
qui cap svmat  `w`i'y_`var'' , name(w`i'y_`var')
qui cap rename  w`i'y_`var'1 w`i'y_`var'
label variable w`i'y_`var' `"AR(`i') `var' Spatial Lag"'
 }
 }
if "`order'"!="" {
qui forvalue i = 1/`order' {
qui foreach var of local xvar {
qui cap drop w`i'x_`var'
tempname w`i'x_`var'
mkmat `var' , matrix(`xyvar')
matrix `w`i'x_`var'' = `WS`i''*`xyvar'
svmat `w`i'x_`var'' , name(w`i'x_`var')
rename w`i'x_`var'1 w`i'x_`var'
label variable w`i'x_`var' `"AR(`i') `var' Spatial Lag"'
 }
 }
 } 
 }
if "`order'"=="1" {
local zvar w1x_* `aux'
qui cap drop w2x_*
qui cap drop w3x_*
qui cap drop w4x_*
 }
 if "`order'"=="2" {
local zvar w1x_* w2x_* `aux'
qui cap drop w3x_*
qui cap drop w4x_*
 }
 if "`order'"=="3" {
local zvar w1x_* w2x_* w3x_* `aux' 
qui cap drop w4x_*
 }
 if "`order'"=="4" {
local zvar w1x_* w2x_* w3x_* w4x_* `aux' 
 }
unab wyxs1: w1y_`yvar'
unab wyxs2: w1y_`endg'
local SPXvar1 w1y_`yvar' `wyxs2' `endg' `xvar1' `aux'
local SPXvar2 w1y_`endg' `wyxs1' `yvar' `xvar2' `aux'
if "`eq'"=="2" {
local SPXvar `SPXvar2'
 }
else  {
local SPXvar `SPXvar1'
 }
 if "`coll'"=="" {
_rmcoll `zvar' , `noconstant' `coll' forcedrop
 local zvar "`r(varlist)'"
_rmcoll `SPXvar' , `noconstant' `coll' forcedrop
 local SPXvar "`r(varlist)'"
 }
local kx : word count `SPXvar'
local kx2 : word count `xvar'
local kaux : word count `aux'
qui gen `X0'=1
qui mkmat `X0' , matrix(`X0')
local kx : word count `SPXvar'
scalar `kb'=`kx'+1
scalar `DF'=`N'-`kx'
if "`noconstant'"!="" {
qui mkmat `SPXvar' , matrix(`X')
scalar `kb'=`kx'
scalar `kz'=0
qui mean `SPXvar'
 }
 else { 
qui mkmat `SPXvar' `X0' , matrix(`X')
scalar `kb'=`kx'+1
scalar `kz'=1
qui mean `SPXvar' `X0'
 }
matrix `Xb'=e(b)
qui mean `yvar'
matrix `Yb'=e(b)'
qui gen `Wi'=1 
qui gen `weit' = 1 
 if "`weight'" != "" {
qui replace `Wi' `exp' 
local wgt "[`weight'`exp']"
qui replace `Wi' = (`Wi')^0.5
 }
mkmat `Wi' , matrix(`Wi')
matrix `Wi'=diag(`Wi')
scalar `llf'=.
matrix `In'=I(`N')
qui tsset `Time'
ereturn scalar kb=`kb'
ereturn scalar Nn=`N'
noi di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Generalized Spatial Three Stage Least Squares (GS3SLS)}}"
noi di _dup(78) "{bf:{err:=}}"
yxregeq `yvar' `SPXvar1'
yxregeq `endg' `SPXvar2'
 sp3sls1 `yvar' `xvar1' `wgt' , `noconstant' `vce' aux(`aux') `coll' ///
 var2(`var2') order(`order') `ols' `2sls' `3sls' `sure' `mvreg'
di
tempname XB1 XB2 Eu1 Eu2 X3SLS1 X3SLS2 B3SLS1 B3SLS2 X kb DF kbc1 kbc2
if "`eq'"=="2" {
scalar `kb'=e(kb2)
scalar `kbc1'=e(kb1)+1
scalar `kbc2'=e(kb1)+e(kb2)
local `yvar `endg'
matrix `Beta'=e(B3SLS2)
matrix `Beta'=`Beta'[1,1..`kb']'
matrix `Cov'= e(V)
matrix `Cov'=`Cov'[`kbc1'..`kbc2', `kbc1'..`kbc2']
scalar `llf'=e(llf2)
matrix `X'=e(X3SLS2)
local SPXvar `SPXvar2'
matrix `Y'=e(Y2_ML)
 }
else {
scalar `kb'=e(kb1)
matrix `Beta'=e(B3SLS1)
matrix `Beta'=`Beta'[1,1..`kb']'
matrix `Cov'= e(V)
matrix `Cov'=`Cov'[1..`kb', 1..`kb']
scalar `llf'=e(llf1)
matrix `X'=e(X3SLS1)
local SPXvar `SPXvar1' 
matrix `Y'=e(Y1_ML)
 }
scalar `DF'=`N'-`kb'
matrix `Yh_ML'=`X'*`Beta'
qui svmat `Yh_ML' , name(`Yh_ML')
qui rename `Yh_ML'1 `Yh_ML'
qui gen `Ue_ML' =`yvar'-`Yh_ML'
local N=_N
matrix `Ue_ML'=`Y'-`Yh_ML'
matrix `E'=`Ue_ML'
if "`predict'"!= "" {
qui cap drop `predict'
qui gen `predict'=`Yh_ML'
label variable `predict' `"Yh - Prediction"'
 }
if "`resid'"!= "" {
qui cap drop `resid'
qui gen `resid'=`Ue_ML'
label variable `resid' `"Ue - Residual"'
 }
tempname SSE SSEo Sigo Sig2o Sig2n r2bu r2bu_a r2raw r2raw_a f fp wald waldp
tempname r2v r2v_a fv fvp r2h r2h_a fh fhp SSTm SSE1 SST11 SST21 Rho
matrix `SSE'=`E''*`E'
scalar `SSEo'=`SSE'[1,1]
scalar `Sig2o'=`SSEo'/`DF'
scalar `Sig2n'=`SSEo'/`N'
scalar `Sigo'=sqrt(`Sig2o')
qui summ `Yh_ML' 
local NUM=r(Var)
qui summ `yvar' 
local DEN=r(Var)
scalar `r2v'=`NUM'/`DEN'
scalar `r2v_a'=1-((1-`r2v')*(`N'-1)/`DF')
scalar `fv'=`r2v'/(1-`r2v')*(`N'-`kb')/(`kx')
scalar `fvp'=Ftail(`kx', `DF', `fv')
qui correlate `Yh_ML' `yvar' 
scalar `r2h'=r(rho)*r(rho)
scalar `r2h_a'=1-((1-`r2h')*(`N'-1)/`DF')
scalar `fh'=`r2h'/(1-`r2h')*(`N'-`kb')/(`kx')
scalar `fhp'=Ftail(`kx', `DF', `fh')
qui summ `yvar' 
local Yb=r(mean)
qui gen `YYm'=(`yvar'-`Yb')^2
qui summ `YYm'
qui scalar `SSTm' = r(sum)
qui gen `YYv'=(`yvar')^2
qui summ `YYv'
local SSTv = r(sum)
qui summ `weit' 
qui gen `Wi1'=sqrt(`weit'/r(mean))
mkmat `Wi1' , matrix(`Wi1')
matrix `P' =diag(`Wi1')
qui gen `Wio'=(`Wi1') 
mkmat `Wio' , matrix(`Wio')
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
scalar `f'=`r2bu'/(1-`r2bu')*(`N'-`kb')/`kx'
scalar `fp'= Ftail(`kx', `DF', `f')
scalar `wald'=`f'*`kx'
scalar `waldp'=chi2tail(`kx', abs(`wald'))
if `llf' == . {
scalar `llf'=-(`N'/2)*log(2*_pi*`Sig2n')-(`N'/2)
 }
local Nof =`N'
local Dof =`DF'
matrix `B'=`Beta''
if "`noconstant'"!="" {
matrix colnames `Cov' = `SPXvar'
matrix rownames `Cov' = `SPXvar'
matrix colnames `B'   = `SPXvar'
 }
 else { 
matrix colnames `Cov' = `SPXvar' _cons
matrix rownames `Cov' = `SPXvar' _cons
matrix colnames `B'   = `SPXvar' _cons
 }
if "`eq'"=="2" {
yxregeq `endg' `SPXvar2'
 }
else  {
yxregeq `yvar' `SPXvar1'
 }
di as txt _col(3) "Sample Size" _col(21) "=" %12.0f as res `N'
ereturn post `B' `Cov' , dep(`yvar') obs(`Nof') dof(`Dof')
qui test `SPXvar'
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
ereturn scalar kaux=`kaux'
ereturn scalar kb=`kb'
ereturn scalar kx=`kx'
ereturn scalar DF=`DF'
ereturn scalar Nn=_N
ereturn display , `level'
matrix `b'=e(b)
matrix `V'=e(V)
matrix `Cov'=e(V)
matrix `Beta'=e(b)
matrix `Beta'=`Beta'[1,1..`kb']
matrix `Bx'=`Beta'[1,1..`kx']'
qui test _b[w1y_`yvar']=0
scalar `Rho'=_b[w1y_`yvar']
di as txt _col(3) "Rho Value  =" %8.4f as res `Rho' as txt _col(30) "F Test =" %10.3f as res r(F) as txt _col(52) "P-Value > F(" r(df) ", " r(df_r) ")" _col(73) %5.4f as res r(p)
di _dup(78) "-"

if "`diag'"!= "" {
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Model Selection Diagnostic Criteria}}"
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

if "`lmspac'"!= "" {
tempname B0 B1 B2 b2k B3 B4 chi21 chi22 DEN DIM E EI Ein Esp eWe
tempname I m1k m2k m3k m4k MEAN NUM NUM1 NUM2 NUM3 RJ wmat
tempname S0 S1 S2 sd SEI SG0 SG1 TRa1 TRa2 trb TRw2 VI wi wj wMw wMw1
tempname WZ0 Xk NUM Zk m2 m4 b2 M eWe1 wWw2 zWz eWy eWy1 CPX SUM DFr
tempname A xAx xAx2 wWw1 B xBx WY WXb IN M xMx
tempvar WZ0 Vm2 Vm4
matrix `wmat'=_WB
scalar `DFr'=`N'-`kb'
scalar `S1'=0
qui forvalue i = 1/`N' {
qui forvalue j = 1/`N' {
scalar `S1'=`S1'+(`wmat'[`i',`j']+`wmat'[`j',`i'])^2
local j=`j'+1
 }
 }
matrix `zWz'=`X0''*`wmat'*`X0'
scalar `S0'=`zWz'[1,1]
scalar `SG0'=`S0'*2
matrix `WZ0' =`wmat'*`X0'
qui svmat `WZ0' , name(`WZ0')
qui rename `WZ0'1 `WZ0'
qui replace `WZ0'=(`WZ0'+`WZ0')^2 
qui summ `WZ0'
scalar `SG1'=r(sum)
matrix `E'=`Ue_ML'
matrix `eWe'=`E''*`wmat'*`E'
scalar `eWe1'=`eWe'[1,1]
 matrix `CPX'=`X''*`X'
 matrix `A'=inv(`CPX')
 matrix `xAx'=`A'*`X''*`wmat'*`X'
scalar `TRa1'=trace(`xAx')
 matrix `xAx2'=`xAx'*`xAx'
scalar `TRa2'=trace(`xAx2')
 matrix `wWw1'=(`wmat'+`wmat'')*(`wmat'+`wmat'')
 matrix `B'=inv(`CPX')
 matrix `xBx'=`B'*`X''*`wWw1'*`X'
scalar `trb'=trace(`xBx')
scalar `VI'=(`N'^2/(`N'^2*`DFr'*(2+`DFr')))*((`S1'/2)+2*`TRa2'-`trb'-2*`TRa1'^2/`DFr')
scalar `SEI'=sqrt(`VI')
scalar `I'=(`N'/`S0')*`eWe1'/`SSEo'
scalar `EI'=-(`N'*`TRa1')/(`DFr'*`N')
ereturn scalar mi1=(`I'-`EI')/`SEI'
ereturn scalar mi1p=2*(1-normal(abs(e(mi1))))
 matrix `wWw2'=`wmat''*`wmat'+`wmat'*`wmat'
scalar `TRw2'=trace(`wWw2')
 matrix `WY'=`wmat'*`Y'
 matrix `eWy'=`E''*`WY'
scalar `eWy1'=`eWy'[1,1]
 matrix `WXb'=`wmat'*`X'*`Beta''
 matrix `IN'=I(`N')
 matrix `M'=inv(`CPX')
 matrix `xMx'=`IN'-`X'*`M'*`X''
 matrix `wMw'=`WXb''*`xMx'*`WXb'
scalar `wMw1'=`wMw'[1,1]
scalar `RJ'=1/(`TRw2'+`wMw1'/`Sig2o')
ereturn scalar lmerr=((`eWe1'/`Sig2o')^2)/`TRw2'
ereturn scalar lmlag=((`eWy1'/`Sig2o')^2)/(`TRw2'+`wMw1'/`Sig2o') 
ereturn scalar lmerrr=(`eWe1'/`Sig2o'-`TRw2'*`RJ'*(`eWy1'/`Sig2o'))^2/(`TRw2'-`TRw2' *`TRw2'*`RJ')
ereturn scalar lmlagr=(`eWy1'/`Sig2o'-`eWe1'/`Sig2o')^2/((1/`RJ')-`TRw2')
ereturn scalar lmsac1=e(lmerr)+e(lmlagr)
ereturn scalar lmsac2=e(lmlag)+e(lmerrr)
ereturn scalar lmerrp=chi2tail(1, abs(e(lmerr)))
ereturn scalar lmerrrp=chi2tail(1, abs(e(lmerrr)))
ereturn scalar lmlagp=chi2tail(1, abs(e(lmlag)))
ereturn scalar lmlagrp=chi2tail(1, abs(e(lmlagr)))
ereturn scalar lmsac1p=chi2tail(2, abs(e(lmsac1)))
ereturn scalar lmsac2p=chi2tail(2, abs(e(lmsac2)))
scalar `DIM'=rowsof(`wmat')
 matrix `m2'=J(1,1,0)
 matrix `m4'=J(1,1,0)
 matrix `b2'=J(1,1,0)
 matrix `M'=J(1,4,0)
local j=1
 while `j'<=4 {
 tempvar EQsq
qui gen `EQsq' = `Ue_ML'^`j'
qui summ `EQsq' , mean 
 matrix `M'[1,`j'] = r(sum)
local j=`j'+1
 }
qui summ `Ue_ML' , mean
scalar `MEAN'=r(mean)
qui replace `Ue_ML'=`Ue_ML'-`MEAN' 
qui gen `Vm2'=`Ue_ML'^2 
qui summ `Vm2' , mean
 matrix `m2'[1,1]=r(mean)	
scalar `m2k'=r(mean)
qui gen `Vm4'=`Ue_ML'^4
qui summ `Vm4' , mean
 matrix `m4'[1,1]=r(mean)	
scalar `m4k'=r(mean)
 matrix `b2'[1,1]=`m4k'/(`m2k'^2)
 mkmat `Ue_ML' , matrix(`Ue_ML')
scalar `S0'=0
scalar `S1'=0
scalar `S2'=0
local i=1
 while `i'<=`N' {
scalar `wi'=0
scalar `wj'=0
local j=1
 while `j'<=`N' {
scalar `S0'=`S0'+`wmat'[`i',`j']
scalar `S1'=`S1'+(`wmat'[`i',`j']+`wmat'[`j',`i'])^2
scalar `wi'=`wi'+`wmat'[`i',`j']
scalar `wj'=`wj'+`wmat'[`j',`i']
local j=`j'+1
 }
scalar `S2'=`S2'+(`wi'+`wj')^2
local i=`i'+1
 }
scalar `S1'=`S1'/2
scalar `m2k'=`m2'[1,1]
scalar `b2k'=`b2'[1,1]
matrix `Zk'=`Ue_ML'[1...,1]
matrix `Zk'=`Zk''*`wmat'*`Zk'
scalar `Ein'=-1/(`N'-1)
scalar `NUM1'=`N'*((`N'^2-3*`N'+3)*`S1'-(`N'*`S2')+(3*`S0'^2))
scalar `NUM2'=`b2k'*((`N'^2-`N')*`S1'-(2*`N'*`S2')+(6*`S0'^2))
scalar `DEN'=(`N'-1)*(`N'-2)*(`N'-3)*(`S0'^2)
scalar `sd'=sqrt((`NUM1'-`NUM2')/`DEN'-(1/(`N'-1))^2)
ereturn scalar mig=`Zk'[1,1]/(`S0'*`m2k')
ereturn scalar migz=(e(mig)-`Ein')/`sd'
ereturn scalar migp=2*(1-normal(abs(e(migz))))
ereturn scalar mi1z=(e(mi1)-`Ein')/`sd'
scalar `m2k'=`m2'[1,1]
scalar `b2k'=`b2'[1,1]
matrix `Zk'=`Ue_ML'[1...,1]
scalar `SUM'=0
local i=1
 while `i'<=`N' {
local j=1
 while `j'<=`N' {
scalar `SUM'=`SUM'+`wmat'[`i',`j']*(`Zk'[`i',1]-`Zk'[`j',1])^2
local j=`j'+1
 }
local i=`i'+1
 }
scalar `NUM1'=(`N'-1)*`S1'*(`N'^2-3*`N'+3-(`N'-1)*`b2k')
scalar `NUM2'=(1/4)*(`N'-1)*`S2'*(`N'^2+3*`N'-6-(`N'^2-`N'+2)*`b2k')
scalar `NUM3'=(`S0'^2)*(`N'^2-3-((`N'-1)^2)*`b2k')
scalar `DEN'=(`N')*(`N'-2)*(`N'-3)*(`S0'^2)
scalar `sd'=sqrt((`NUM1'-`NUM2'+`NUM3')/`DEN')
ereturn scalar gcg=((`N'-1)*`SUM')/(2*`N'*`S0'*`m2k')
ereturn scalar gcgz=(e(gcg)-1)/`sd'
ereturn scalar gcgp=2*(1-normal(abs(e(gcgz))))
scalar `B0'=((`N'^2)-3*`N'+3)*`S1'-`N'*`S2'+3*(`S0'^2)
scalar `B1'=-(((`N'^2)-`N')*`S1'-2*`N'*`S2'+6*(`S0'^2))
scalar `B2'=-(2*`N'*`S1'-(`N'+3)*`S2'+6*(`S0'^2))
scalar `B3'=4*(`N'-1)*`S1'-2*(`N'+1)*`S2'+8*(`S0'^2)
scalar `B4'=`S1'-`S2'+(`S0'^2)
scalar `m1k'=`M'[1,1]
scalar `m2k'=`M'[1,2]
scalar `m3k'=`M'[1,3]
scalar `m4k'=`M'[1,4]
 matrix `Xk'=`Ue_ML'[1...,1]
 matrix `NUM'=`Xk''*`wmat'*`Xk'
scalar `DEN'=0
local i=1
 while `i'<=`N' {
local j=1
 while `j'<=`N' {
 if `i'!=`j' {
scalar `DEN'=`DEN'+`Xk'[`i',1]*`Xk'[`j',1]
 }
local j=`j'+1
 }
local i=`i'+1
 }
ereturn scalar gog=`NUM'[1,1]/`DEN'
scalar `Esp'=`S0'/(`N'*(`N'-1))
scalar `NUM'=(`B0'*`m2k'^2)+(`B1'*`m4k')+(`B2'*`m1k'^2*`m2k') ///
 +(`B3'*`m1k'*`m3k')+(`B4'*`m1k'^4)
scalar `DEN'=(((`m1k'^2)-`m2k')^2)*`N'*(`N'-1)*(`N'-2)*(`N'-3)
scalar `sd'=(`NUM'/`DEN')-((`Esp')^2)
ereturn scalar gogz=(e(gog)-`Esp')/sqrt(`sd')
ereturn scalar gogp=2*(1-normal(abs(e(gogz))))
scalar `chi21'=invchi2(1,0.95)
scalar `chi22'=invchi2(2,0.95)
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:*** Spatial Aautocorrelation Tests}}"
di _dup(78) "{bf:{err:=}}"
di as txt _col(2) "{bf: Ho: Error has No Spatial AutoCorrelation}"
di as txt _col(2) "{bf: Ha: Error has    Spatial AutoCorrelation}"
di
di as txt "- GLOBAL Moran MI" as res _col(30) "=" %9.4f e(mig) _col(45) as txt "P-Value > Z(" %6.3f e(migz) ")" _col(67) %5.4f as res e(migp)
di as txt "- GLOBAL Geary GC" as res _col(30) "=" %9.4f e(gcg) _col(45) as txt "P-Value > Z(" %5.3f e(gcgz) ")" _col(67) %5.4f as res e(gcgp)
di as txt "- GLOBAL Getis-Ords GO" as res _col(30) "=" %9.4f e(gog) as txt _col(45) "P-Value > Z(" %5.3f e(gogz) ")" _col(67) %5.4f as res e(gogp)
di _dup(78) "-"
di as txt "- Moran MI Error Test" as res _col(30) "=" %9.4f e(mi1) _col(45) as txt "P-Value > Z(" %5.3f e(mi1z) ")" _col(67) %5.4f as res e(mi1p)
di _dup(78) "-"
di as txt "- LM Error (Burridge)" as res _col(30) "=" %9.4f e(lmerr) _col(45) as txt "P-Value > Chi2(1)" _col(67) %5.4f as res e(lmerrp)
di as txt "- LM Error (Robust)" as res _col(30) "=" %9.4f e(lmerrr) _col(45) as txt "P-Value > Chi2(1)" _col(67) %5.4f as res e(lmerrrp)
di _dup(78) "-"
di as txt _col(2) "{bf: Ho: Spatial Lagged Dependent Variable has No Spatial AutoCorrelation}"
di as txt _col(2) "{bf: Ha: Spatial Lagged Dependent Variable has    Spatial AutoCorrelation}"
di
di as txt "- LM Lag (Anselin)" as res _col(30) "=" %9.4f e(lmlag) _col(45) as txt "P-Value > Chi2(1)" _col(67) %5.4f as res e(lmlagp)
di as txt "- LM Lag (Robust)" as res _col(30) "=" %9.4f e(lmlagr) _col(45) as txt "P-Value > Chi2(1)" _col(67) %5.4f as res e(lmlagrp)
di _dup(78) "-"
di as txt _col(2) "{bf: Ho: No General Spatial AutoCorrelation}"
di as txt _col(2) "{bf: Ha:    General Spatial AutoCorrelation}"
di
di as txt "- LM SAC (LMErr+LMLag_R)" as res _col(30) "=" %9.4f e(lmsac2) _col(45) as txt "P-Value > Chi2(2)" _col(67) %5.4f as res e(lmsac2p)
di as txt "- LM SAC (LMLag+LMErr_R)" as res _col(30) "=" %9.4f e(lmsac1) _col(45) as txt "P-Value > Chi2(2)" _col(67) %5.4f as res e(lmsac1p)
di _dup(78) "-"
 }

if "`lmhet'"!= "" {
tempvar Yh Yh2 LYh2 E E2 E3 E4 LnE2 absE time LE ht Ehet Ehet2 DumE EDumE U2
tempname mh vh h Q LMh_cwx lmhmss1 mssdf1 lmhmss1p 
tempname lmhmss2 mssdf2 lmhmss2p dfw0 lmhwh01 lmhwh01p lmhwh02 lmhwh02p dfw1 lmhwh11
tempname lmhwh11p lmhwh12 lmhwh12p dfw2 lmhwh21 lmhwh21p lmhwh22 lmhwh22p lmhharv
tempname lmhharvp lmhwald lmhwaldp lmhhp1 lmhhp1p lmhhp2 lmhhp2p lmhhp3 lmhhp3p lmhgl
tempname lmhglp lmhcw1 cwdf1 lmhcw1p lmhcw2 cwdf2 lmhcw2p lmhq lmhqp
qui tsset `Time'
qui gen `U2' =`Ue_ML'^2/`Sig2n'
qui gen `Yh'=`Yh_ML'
qui gen `Yh2'=`Yh_ML'^2
qui gen `LYh2'=ln(`Yh2')
qui gen `E' =`Ue_ML'
qui gen `E2'=`Ue_ML'^2
qui gen `E3'=`Ue_ML'^3
qui gen `E4'=`Ue_ML'^4
qui gen `LnE2'=ln(`E2')
qui gen `absE'=abs(`E')
qui gen `DumE'=0
qui replace `DumE'=1 if `E' >= 0
qui summ `DumE'
qui gen `EDumE'=`E'*(`DumE'-r(mean))
qui regress `EDumE' `Yh' `Yh2' `wgt' , `noconstant' `vce'
scalar `lmhmss1'=e(N)*e(r2)
scalar `mssdf1'=e(df_m)
scalar `lmhmss1p'=chi2tail(`mssdf1', abs(`lmhmss1'))
qui regress `EDumE' `SPXvar' `wgt' , `noconstant' `vce'
scalar `lmhmss2'=e(N)*e(r2)
scalar `mssdf2'=e(df_m)
scalar `lmhmss2p'=chi2tail(`mssdf2', abs(`lmhmss2'))
local kx =`kx'
qui forvalue j=1/`kx' {
qui foreach i of local SPXvar {
tempvar VN
gen `VN'`j'=`i' 
qui cap drop `XQX_'`i'
 gen `XQX_'`i' = `VN'`j'*`VN'`j'
 }
 }
qui regress `E2' `SPXvar'
scalar `dfw0'=e(df_m)
scalar `lmhwh01'=e(r2)*e(N)
scalar `lmhwh01p'=chi2tail(`dfw0' , abs(`lmhwh01'))
scalar `lmhwh02'=e(mss)/(2*`Sig2n'^2)
scalar `lmhwh02p'=chi2tail(`dfw0' , abs(`lmhwh02'))
qui regress `E2' `SPXvar' `XQX_'*
scalar `dfw1'=e(df_m)
scalar `lmhwh11'=e(r2)*e(N)
scalar `lmhwh11p'=chi2tail(`dfw1' , abs(`lmhwh11'))
scalar `lmhwh12'=e(mss)/(2*`Sig2n'^2)
scalar `lmhwh12p'=chi2tail(`dfw1' , abs(`lmhwh12'))
qui cap drop `VN'*
qui cap drop `XQX_'*
mkmat `SPXvar' , matrix(`VN')
svmat `VN' , names(`VN')
unab WWVN: `VN'*
local ZWvar `WWVN'
qui foreach i of local ZWvar {
qui foreach j of local ZWvar {
if `i' >= `j' {
qui cap drop `XQX_'`i'`j'
qui gen `XQX_'`i'`j' = `i'*`j'
 }
 }
 }
qui cap matrix drop `VN'
qui cap drop `VN'*
qui regress `E2' `SPXvar' `XQX_'*
scalar `dfw2'=e(df_m)
scalar `lmhwh21'=e(r2)*e(N)
scalar `lmhwh21p'=chi2tail(`dfw2' , abs(`lmhwh21'))
scalar `lmhwh22'=e(mss)/(2*`Sig2n'^2)
scalar `lmhwh22p'=chi2tail(`dfw2' , abs(`lmhwh22'))
qui regress `LnE2' `SPXvar'
scalar `lmhharv'=e(mss)/4.9348
scalar `lmhharvp'= chi2tail(2, abs(`lmhharv'))
qui regress `LnE2' `SPXvar'
scalar `lmhwald'=e(mss)/2
scalar `lmhwaldp'=chi2tail(1, abs(`lmhwald'))
qui regress `E2' `Yh'
scalar `lmhhp1'=e(N)*e(r2)
scalar `lmhhp1p'=chi2tail(1, abs(`lmhhp1'))
qui regress `E2' `Yh2'
scalar `lmhhp2'=e(N)*e(r2)
scalar `lmhhp2p'=chi2tail(1, abs(`lmhhp2'))
qui regress `E2' `LYh2'
scalar `lmhhp3'=e(N)*e(r2)
scalar `lmhhp3p'= chi2tail(1, abs(`lmhhp3'))
qui regress `absE' `SPXvar'
scalar `lmhgl'=e(mss)/((1-2/_pi)*`Sig2n')
scalar `lmhglp'=chi2tail(2, abs(`lmhgl'))
qui regress `U2' `Yh'
scalar `lmhcw1'= e(mss)/2
scalar `cwdf1' = e(df_m)
scalar `lmhcw1p'=chi2tail(`cwdf1', abs(`lmhcw1'))
qui regress `U2' `SPXvar'
scalar `lmhcw2'=e(mss)/2
scalar `cwdf2' =e(df_m)
scalar `lmhcw2p'=chi2tail(`cwdf2', abs(`lmhcw2'))
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Heteroscedasticity Tests}}"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf: Ho: Homoscedasticity - Ha: Heteroscedasticity}"
di _dup(78) "-"
qui tsset `Time'
di as txt "- Hall-Pagan LM Test:      E2 = Yh" _col(40) "=" as res %9.4f `lmhhp1' _col(53) as txt " P-Value > Chi2(1)" _col(73) as res %5.4f `lmhhp1p'
di as txt "- Hall-Pagan LM Test:      E2 = Yh2" _col(40) "=" as res %9.4f `lmhhp2' _col(53) as txt " P-Value > Chi2(1)" _col(73) as res %5.4f `lmhhp2p'
di as txt "- Hall-Pagan LM Test:      E2 = LYh2" _col(40) "=" as res %9.4f `lmhhp3' _col(53) as txt " P-Value > Chi2(1)" _col(73) as res %5.4f `lmhhp3p'
di _dup(78) "-"
di as txt "- Harvey LM Test:       LogE2 = X" _col(40) "=" as res %9.4f `lmhharv' _col(53) as txt " P-Value > Chi2(2)" _col(73) as res %5.4f `lmhharvp'
di as txt "- Wald LM Test:         LogE2 = X " _col(40) "=" as res %9.4f `lmhwald' _col(53) as txt " P-Value > Chi2(1)" _col(73) as res %5.4f `lmhwaldp'
di as txt "- Glejser LM Test:        |E| = X" _col(40) "=" as res %9.4f `lmhgl' _col(53) as txt " P-Value > Chi2(2)" _col(73) as res %5.4f `lmhglp'
di _dup(78) "-"
di as txt "- Machado-Santos-Silva Test: Ev=Yh Yh2" _col(40) "=" as res %9.4f `lmhmss1' _col(53) as txt " P-Value > Chi2(" `mssdf1' ")" _col(73) as res %5.4f `lmhmss1p'
di as txt "- Machado-Santos-Silva Test: Ev=X" _col(40) "=" as res %9.4f `lmhmss2' _col(53) as txt " P-Value > Chi2(" `mssdf2' ")" _col(73) as res %5.4f `lmhmss2p'
di _dup(78) "-"
di as txt "- White Test -Koenker(R2): E2 = X" _col(40) "=" as res %9.4f `lmhwh01' _col(53) as txt " P-Value > Chi2(" `dfw0' ")" _col(73) as res %5.4f `lmhwh01p'
di as txt "- White Test -B-P-G (SSR): E2 = X" _col(40) "=" as res %9.4f `lmhwh02' _col(53) as txt " P-Value > Chi2(" `dfw0' ")" _col(73) as res %5.4f `lmhwh02p'
di _dup(78) "-"
di as txt "- White Test -Koenker(R2): E2 = X X2" _col(40) "=" as res %9.4f `lmhwh11' _col(53) as txt " P-Value > Chi2(" `dfw1' ")" _col(73) as res %5.4f `lmhwh11p'
di as txt "- White Test -B-P-G (SSR): E2 = X X2" _col(40) "=" as res %9.4f `lmhwh12' _col(53) as txt " P-Value > Chi2(" `dfw1' ")" _col(73) as res %5.4f `lmhwh12p'
di _dup(78) "-"
di as txt "- White Test -Koenker(R2): E2 = X X2 XX" _col(40) "=" as res %9.4f `lmhwh21' _col(53) as txt " P-Value > Chi2(" `dfw2' ")" _col(73) as res %5.4f `lmhwh21p'
di as txt "- White Test -B-P-G (SSR): E2 = X X2 XX" _col(40) "=" as res %9.4f `lmhwh22' _col(53) as txt " P-Value > Chi2(" `dfw2' ")" _col(73) as res %5.4f `lmhwh22p'
di _dup(78) "-"
di as txt "- Cook-Weisberg LM Test  E2/Sig2 = Yh" _col(40) "=" as res %9.4f `lmhcw1' _col(53) as txt " P-Value > Chi2(" `cwdf1' ")" _col(73) as res %5.4f `lmhcw1p'
di as txt "- Cook-Weisberg LM Test  E2/Sig2 = X" _col(40) "=" as res %9.4f `lmhcw2' _col(53) as txt " P-Value > Chi2(" `cwdf2' ")" _col(73) as res %5.4f `lmhcw2p'
di _dup(78) "-"
di as res "*** Single Variable Tests (E2/Sig2):"
local nx : word count `SPXvar'
tokenize `SPXvar'
local i 1
while `i' <= `nx' {
qui regress `U2' ``i''
ereturn scalar lmhcwx_`i'= e(mss)/2
ereturn scalar lmhcwxp_`i'= chi2tail(1 , abs(e(lmhcwx_`i')))
di as txt "- Cook-Weisberg LM Test: " "``i''" _col(44) "=" as res %9.4f e(lmhcwx_`i') _col(53) as txt " P-Value > Chi2(1)" _col(73) as res %5.4f e(lmhcwxp_`i')
local i =`i'+1
 }
di _dup(78) "-"
di as res "*** Single Variable Tests:"
foreach i of local SPXvar {
qui cap drop `ht'`i'
tempvar `ht'`i'
qui egen `ht'`i' = rank(`i')
qui summ `ht'`i'
scalar `mh' = r(mean)
scalar `vh' = r(Var)
qui summ `ht'`i' [aw=`E'^2] , meanonly
scalar `h' = r(mean)
ereturn scalar lmhq_`i'=(`N'^2/(2*(`N'-1)))*(`h'-`mh')^2/`vh'
ereturn scalar lmhqp_`i'= chi2tail(1, abs(e(lmhq_`i')))
di as txt "- King LM Test: " "`i'" _col(44) "=" as res %9.4f e(lmhq_`i') _col(53) as txt " P-Value > Chi2(1)" _col(73) as res %5.4f e(lmhqp_`i')
 }
ereturn scalar lmhmss1=`lmhmss1'
ereturn scalar mssdf1=`mssdf1'
ereturn scalar lmhmss1p=`lmhmss1p'
ereturn scalar lmhmss2=`lmhmss2'
ereturn scalar mssdf2=`mssdf2'
ereturn scalar lmhmss2p=`lmhmss2p'
ereturn scalar dfw0=`dfw0'
ereturn scalar lmhwh01=`lmhwh01'
ereturn scalar lmhwh01p=`lmhwh01p'
ereturn scalar lmhwh02=`lmhwh02'
ereturn scalar lmhwh02p=`lmhwh02p'
ereturn scalar dfw1=`dfw1'
ereturn scalar lmhwh11=`lmhwh11'
ereturn scalar lmhwh11p=`lmhwh11p'
ereturn scalar lmhwh12=`lmhwh12'
ereturn scalar lmhwh12p=`lmhwh12p'
ereturn scalar dfw2=`dfw2'
ereturn scalar lmhwh21=`lmhwh21'
ereturn scalar lmhwh21p=`lmhwh21p'
ereturn scalar lmhwh22=`lmhwh22'
ereturn scalar lmhwh22p=`lmhwh22p'
ereturn scalar lmhharv=`lmhharv'
ereturn scalar lmhharvp=`lmhharvp'
ereturn scalar lmhwald=`lmhwald'
ereturn scalar lmhwaldp=`lmhwaldp'
ereturn scalar lmhhp1=`lmhhp1'
ereturn scalar lmhhp1p=`lmhhp1p'
ereturn scalar lmhhp2=`lmhhp2'
ereturn scalar lmhhp2p=`lmhhp2p'
ereturn scalar lmhhp3=`lmhhp3'
ereturn scalar lmhhp3p=`lmhhp3p'
ereturn scalar lmhgl=`lmhgl'
ereturn scalar lmhglp=`lmhglp'
ereturn scalar lmhcw1=`lmhcw1'
ereturn scalar cwdf1=`cwdf1'
ereturn scalar lmhcw1p=`lmhcw1p'
ereturn scalar lmhcw2=`lmhcw2'
ereturn scalar cwdf2=`cwdf2'
ereturn scalar lmhcw2p=`lmhcw2p'
 }

if "`lmnorm'"!="" {
tempvar Yh E E1 E2 E3 E4 Es U2 DE LDE LDF1 Yt U Hat 
tempname Hat corr1 corr3 corr4 mpc2 mpc3 mpc4 s uinv q1 uinv2 q2 ECov ECov2 Eb Sk Ku
tempname M2 M3 M4 K2 K3 K4 Ss Kk GK sksd kusd N1 N2 EN S2N SN mean sd small A2 B0 B1
tempname B2 B3 LA Z Rn Lower Upper wsq2 ve lve Skn gn an cn kn vz Ku1 Kun n1 n2 n3 eb2
tempname R2W vb2 svb2 k1 a devsq m2 sdev m3 m4 sqrtb1 b2 g1 g2 stm3b2 S1 S2 S3 S4
tempname b2minus3 sm sms y k2 wk delta alpha yalpha pc1 pc2 pc3 pc4 pcb1 pcb2 sqb1p b2p
qui tsset `Time'
qui gen `Yh'=`Yh_ML'
qui gen `E' =`Ue_ML'
qui gen `E2'=`E'*`E' 
matrix `Hat'=vecdiag(`Wi''*`Wi'*`X'*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''*`Wi')'
svmat `Hat' , name(`Hat')
rename `Hat'1 `Hat'
qui regress `E2' `Hat'
scalar `R2W'=e(r2)
qui summ `E' , det
scalar `Eb'=r(mean)
scalar `Sk'=r(skewness)
scalar `Ku'=r(kurtosis)
qui forvalue i = 1/4 {
qui gen `E'`i'=(`E'-`Eb')^`i' 
qui summ `E'`i'
scalar `S`i''=r(mean)
scalar `pc`i''=r(sum)
 }
mkmat `E'1 `E'2 `E'3 `E'4 , matrix(`ECov')
scalar `M2'=`S2'-`S1'^2
scalar `M3'=`S3'-3*`S1'*`S2'+`S1'^2
scalar `M4'=`S4'-4*`S1'*`S3'+6*`S1'^2*`S2'-3*`S1'^4
scalar `K2'=`N'*`M2'/(`N'-1)
scalar `K3'=`N'^2*`M3'/((`N'-1)*(`N'-2))
scalar `K4'=`N'^2*((`N'+1)*`M4'-3*(`N'-1)*`M2'^2)/((`N'-1)*(`N'-2)*(`N'-3))
scalar `Ss'=`K3'/(`K2'^1.5)
scalar `Kk'=`K4'/(`K2'^2)
scalar `GK'= ((`Sk'^2/6)+((`Ku'-3)^2/24))
ereturn scalar lmnw=`N'*(`R2W'+`GK')
ereturn scalar lmnwp= chi2tail(2, abs(e(lmnw)))
ereturn scalar lmnjb=`N'*((`Sk'^2/6)+((`Ku'-3)^2/24))
ereturn scalar lmnjbp= chi2tail(2, abs(e(lmnjb)))
scalar `sksd'=sqrt(6*`N'*(`N'-1)/((`N'-2)*(`N'+1)*(`N'+3)))
scalar `kusd'=sqrt(24*`N'*(`N'-1)^2/((`N'-3)*(`N'-2)*(`N'+3)*(`N'+5)))
qui gen `DE'=1 if `E'>0
qui replace `DE'=0 if `E' <= 0
qui count if `DE'>0
scalar `N1'=r(N)
scalar `N2'=`N'-r(N)
scalar `EN'=(2*`N1'*`N2')/(`N1'+`N2')+1
scalar `S2N'=(2*`N1'*`N2'*(2*`N1'*`N2'-`N1'-`N2'))/((`N1'+`N2')^2*(`N1'+`N2'-1))
scalar `SN'=sqrt((2*`N1'*`N2'*(2*`N1'*`N2'-`N1'-`N2'))/((`N1'+`N2')^2*(`N1'+`N2'-1)))
qui gen `LDE'= `DE'[_n-1] 
qui replace `LDE'=0 if `DE'==1 in 1
qui gen `LDF1'= 1 if `DE' != `LDE'
qui replace `LDF1'= 1 if `DE' == `LDE' in 1
qui replace `LDF1'= 0 if `LDF1' == .
qui count if `LDF1'>0
scalar `Rn'=r(N)
ereturn scalar lmng=(`Rn'-`EN')/`SN'
ereturn scalar lmngp= chi2tail(2, abs(e(lmng)))
scalar `Lower'=`EN'-1.96*`SN'
scalar `Upper'=`EN'+1.96*`SN'
qui summ `E' 
scalar `mean'=r(mean)
scalar `sd'=r(sd)
scalar `small'= 1e-20
qui gen `Es' =`E'
qui sort `Es'
qui replace `Es'=normal((`Es'-`mean')/`sd') 
qui gen `Yt'=`Es'*(1-`Es'[`N'-_n+1]) 
qui replace `Yt'=`small' if `Yt' < =0
qui replace `Yt'=sum((2*_n-1)*ln(`Yt')) 
scalar `A2'=-`N'-`Yt'[`N']/`N'
scalar `A2'=`A2'*(1+(0.75+2.25/`N')/`N')
scalar `B0'=2.25247+0.000317*exp(29.5/`N')
scalar `B1'=2.16872+0.00243*exp(27.7/`N')
scalar `B2'=0.19135+0.00255*exp(28.3/`N')
scalar `B3'=0.110978+0.00001624*exp(39.04/`N')+0.00476*exp(21.37/`N')
scalar `LA'=ln(`A2')
ereturn scalar lmnad=(`A2')
scalar `Z'=abs(`B0'+`LA'*(`B1'+`LA'*(`B2'+`LA'*`B3')))
ereturn scalar lmnadp= normal(abs(-`Z'))
scalar `wsq2'=-1+sqrt(2*((3*(`N'^2+27*`N'-70)/((`N'-2)*(`N'+5))*((`N'+1)/(`N'+7))*((`N'+3)/(`N'+9)))-1))
scalar `ve'=`Sk'*sqrt((`N'+1)*(`N'+3)/(6*(`N'-2)))/sqrt(2/(`wsq2'-1))
scalar `lve'=ln(`ve'+(`ve'^2+1)^0.5)
scalar `Skn'=`lve'/sqrt(ln(sqrt(`wsq2')))
scalar `gn'=((`N'+5)/(`N'-3))*((`N'+7)/(`N'+1))/(6*(`N'^2+15*`N'-4))
scalar `an'=(`N'-2)*(`N'^2+27*`N'-70)*`gn'
scalar `cn'=(`N'-7)*(`N'^2+2*`N'-5)*`gn'
scalar `kn'=(`N'*`N'^2+37*`N'^2+11*`N'-313)*`gn'/2
scalar `vz'= `cn'*`Sk'^2 +`an'
scalar `Ku1'=(`Ku'-1-`Sk'^2)*`kn'*2
scalar `Kun'=(((`Ku1'/(2*`vz'))^(1/3))-1+1/(9*`vz'))*sqrt(9*`vz')
ereturn scalar lmndh =`Skn'^2 + `Kun'^2
ereturn scalar lmndhp= chi2tail(2, abs(e(lmndh)))
scalar `n1'=sqrt(`N'*(`N'-1))/(`N'-2)
scalar `n2'=3*(`N'-1)/(`N'+1)
scalar `n3'=(`N'^2-1)/((`N'-2)*(`N'-3))
scalar `eb2'=3*(`N'-1)/(`N'+1)
scalar `vb2'=24*`N'*(`N'-2)*(`N'-3)/(((`N'+1)^2)*(`N'+3)*(`N'+5))
scalar `svb2'=sqrt(`vb2')
scalar `k1'=6*(`N'*`N'-5*`N'+2)/((`N'+7)*(`N'+9))*sqrt(6*(`N'+3)*(`N'+5)/(`N'*(`N'-2)*(`N'-3)))
scalar `a'=6+(8/`k1')*(2/`k1'+sqrt(1+4/(`k1'^2)))
scalar `devsq'=`pc1'*`pc1'/`N'
scalar `m2'=(`pc2'-`devsq')/`N'
scalar `sdev'=sqrt(`m2')
scalar `m3'=`pc3'/`N'
scalar `m4'=`pc4'/`N'
scalar `sqrtb1'=`m3'/(`m2'*`sdev')
scalar `b2'=`m4'/`m2'^2
scalar `g1'=`n1'*`sqrtb1'
scalar `g2'=(`b2'-`n2')*`n3'
scalar `stm3b2'=(`b2'-`eb2')/`svb2'
ereturn scalar lmnkz=(1-2/(9*`a')-((1-2/`a')/(1+`stm3b2'*sqrt(2/(`a'-4))))^(1/3))/sqrt(2/(9*`a'))
ereturn scalar lmnkzp=2*(1-normal(abs(e(lmnkz))))
scalar `b2minus3'=`b2'-3
matrix `ECov2'=`ECov''*`ECov'
scalar `sm'=`ECov2'[1,1]
scalar `sms'=1/sqrt(`sm')
matrix `corr1'=`sms'*`ECov2'*`sms'
matrix `corr3'=`corr1'[1,1]^3
matrix `corr4'=`corr1'[1,1]^4
scalar `y'=`sqrtb1'*sqrt((`N'+1)*(`N'+3)/(6*(`N'-2)))
scalar `k2'=3*(`N'^2+27*`N'-70)*(`N'+1)*(`N'+3)/((`N'-2)*(`N'+5)*(`N'+7)*(`N'+9))
scalar `wk'=sqrt(sqrt(2*(`k2'-1))-1)
scalar `delta'=1/sqrt(ln(`wk'))
scalar `alpha'=sqrt(2/(`wk'*`wk'-1))
matrix `yalpha'=`y'/`alpha'
scalar `yalpha'=`yalpha'[1,1]
ereturn scalar lmnsz=`delta'*ln(`yalpha'+sqrt(1+`yalpha'^2))
ereturn scalar lmnszp= 2*(1-normal(abs(e(lmnsz))))
ereturn scalar lmndp=e(lmnsz)^2+e(lmnkz)^2
ereturn scalar lmndpp= chi2tail(2, abs(e(lmndp)))
matrix `uinv'=invsym(`corr3')
matrix `q1'=e(lmnsz)'*`uinv'*e(lmnsz)
ereturn scalar lmnsms=`q1'[1,1]
ereturn scalar lmnsmsp= chi2tail(1, abs(e(lmnsms)))
matrix `uinv2'=invsym(`corr4')
matrix `q2'=e(lmnkz)'*`uinv2'*e(lmnkz)
ereturn scalar lmnsmk=`q2'[1,1]
ereturn scalar lmnsmkp= chi2tail(1, abs(e(lmnsmk)))
matrix `mpc2'=(`pc2'-(`pc1'^2/`N'))/`N'
matrix `mpc3'=(`pc3'-(3/`N'*`pc1'*`pc2')+(2/(`N'^2)*(`pc1'^3)))/`N'
matrix `mpc4'=(`pc4'-(4/`N'*`pc1'*`pc3')+(6/(`N'^2)*(`pc2'*(`pc1'^2)))-(3/(`N'^3)*(`pc1'^4)))/`N'
scalar `pcb1'=`mpc3'[1,1]/`mpc2'[1,1]^1.5
scalar `pcb2'=`mpc4'[1,1]/`mpc2'[1,1]^2
scalar `sqb1p'=`pcb1'^2
scalar `b2p'=`pcb2'
ereturn scalar lmnsvs=`sqb1p'*`N'/6
ereturn scalar lmnsvsp= chi2tail(1, abs(e(lmnsvs)))
ereturn scalar lmnsvk=(`b2p'-3)*sqrt(`N'/24)
ereturn scalar lmnsvkp= 2*(1-normal(abs(e(lmnsvk))))
qui sort `Time'
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Non Normality Tests}}"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf: Ho: Normality - Ha: Non Normality}"
di _dup(78) "-"
di "{bf:*** Non Normality Tests:}
di as txt "- Jarque-Bera LM Test" _col(40) "=" as res %9.4f e(lmnjb) _col(55) as txt "P-Value > Chi2(2) " _col(73) as res %5.4f e(lmnjbp)
di as txt "- White IM Test" _col(40) "=" as res %9.4f e(lmnw) _col(55) as txt "P-Value > Chi2(2) " _col(73) as res %5.4f e(lmnwp)
di as txt "- Doornik-Hansen LM Test" _col(40) "=" as res %9.4f e(lmndh) _col(55) as txt "P-Value > Chi2(2) " _col(73) as res %5.4f e(lmndhp)
di as txt "- Geary LM Test" _col(40) "=" as res %9.4f e(lmng) _col(55) as txt "P-Value > Chi2(2) " _col(73) as res %5.4f e(lmngp)
di as txt "- Anderson-Darling Z Test" _col(40) "=" as res %9.4f e(lmnad) _col(55) as txt "P > Z(" %6.3f `Z' ")" _col(73) as res %5.4f e(lmnadp)
di as txt "- D'Agostino-Pearson LM Test " _col(40) "=" as res %9.4f e(lmndp) _col(55) as txt "P-Value > Chi2(2)" _col(73) as res %5.4f e(lmndpp)
di _dup(78) "-"
di "{bf:*** Skewness Tests:}
di as txt "- Srivastava LM Skewness Test" _col(40) "=" as res %9.4f e(lmnsvs) _col(55) as txt "P-Value > Chi2(1)" _col(73) as res %5.4f e(lmnsvsp)
di as txt "- Small LM Skewness Test" _col(40) "=" as res %9.4f e(lmnsms) _col(55) as txt "P-Value > Chi2(1)" _col(73) as res %5.4f e(lmnsmsp)
di as txt "- Skewness Z Test" _col(40) "=" as res %9.4f e(lmnsz) _col(55) as txt "P-Value > Chi2(1)" _col(73) as res %5.4f e(lmnszp)
di _dup(78) "-"
di "{bf:*** Kurtosis Tests:}
di as txt "- Srivastava  Z Kurtosis Test" _col(40) "=" as res %9.4f e(lmnsvk) _col(55) as txt "P-Value > Z(0,1)" _col(73) as res %5.4f e(lmnsvkp)
di as txt "- Small LM Kurtosis Test" _col(40) "=" as res %9.4f e(lmnsmk) _col(55) as txt "P-Value > Chi2(1)" _col(73) as res %5.4f e(lmnsmkp)
di as txt "- Kurtosis Z Test" _col(40) "=" as res %9.4f e(lmnkz) _col(55) as txt "P-Value > Chi2(1)" _col(73) as res %5.4f e(lmnkzp)
di _dup(78) "-"
di as txt _col(5) "Skewness Coefficient =" _col(28) as res %7.4f `Sk' as txt "   " "  - Standard Deviation = " _col(48) as res %7.4f `sksd'
di as txt _col(5) "Kurtosis Coefficient =" _col(28) as res %7.4f `Ku' as txt "   " "  - Standard Deviation = " _col(48) as res %7.4f `kusd'
di _dup(78) "-"
di as txt _col(5) "Runs Test:" as res " " "(" `Rn' ")" " " as txt "Runs - " as res " " "(" `N1' ")" " " as txt "Positives -" " " as res "(" `N2' ")" " " as txt "Negatives"
di as txt _col(5) "Standard Deviation Runs Sig(k) = " as res %7.4f `SN' " , " as txt "Mean Runs E(k) = " as res %7.4f `EN' 
di as txt _col(5) "95% Conf. Interval [E(k)+/- 1.96* Sig(k)] = (" as res %7.4f `Lower' " , " %7.4f `Upper' " )"
di _dup(78) "-"
 }

if "`tolog'"!="" {
qui foreach var of local vlistlog {
qui replace `var'= `xyind`var'' 
 }
 }
if inlist("`mfx'", "lin", "log") {
tempname mfxb mfxe mfxlin mfxlog XMB XYMB YMB YMB1
qui mean `SPXvar' 
matrix `XMB'=e(b)'
qui summ `yvar' 
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
matrix rownames `mfxlin' = `SPXvar'
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
matrix rownames `mfxlog' = `SPXvar'
matrix colnames `mfxlog' = Elasticity(Es) Marginal_Effect(B) Mean
matlist `mfxlog' , title({bf:* Elasticity - Marginal Effect: {err:Log-Log} *}) twidth(10) border(all) lines(columns) rowtitle(Variable) format(%18.4f)
ereturn matrix mfxlog=`mfxlog'
 }
di as txt " Mean of Dependent Variable =" as res _col(30) %12.4f `YMB1' 
 }
qui cap matrix drop _all
qui cap mata: mata drop *
 if "`zero'"!="" {
qui foreach var of local varlist {
qui replace `var'= `zeromiss'`var' 
 }
 }
qui sort `Time'
end

program define sp3sls1 , eclass byable(onecall)
version 11.0
syntax varlist [aw] , [NOCONStant vce(passthru) var2(str) ///
EQ(int 1) ORDer(int 2) ols 2sls 3sls sure mvreg aux(str) coll]
preserve
tempvar `varlist1'
tempvar `varlist2'
local varlist1 `varlist'
local varlist2 `var2'
gettoken yvar xvar1 : varlist1
gettoken endg xvar2 : varlist2
local xvarx1 : list xvar1 & xvar2
local xvarx2 `"`xvar1' `xvar2'"'
local xvar : list xvarx2-xvarx1
tempvar X0 E1 E2 Es1 Es2 y1 y2 wy1 wy2 Sig2 y yn Time
tempname X0 E1 E2 y1 y2 wy1 wy2 wmat w1x w2x w3x w4x Es1 Es2 Y Ev E W Omega BS
tempname aic sc PF yvar1 endg2 B3SLS1 B3SLS2 YMAT RSQ SSE1 SSE2 SSE3
tempname MSS1 MSS2 Sig Sig21 MSS3 SST1 SST2 SST3 Ybv Yb Yv Yb_Y1 Yb_Y2 Sig2
tempname YM RS1 RS2 RS3 kz k1 k2 Ro ADR F kb21 kb2 K Q DF1 DF2 DFF DFChi LSig2
tempname LLF df1 df2 Chi PChi kb N kb1 kb2 XB1 XB2 Eu1 Eu2 X3SLS1 X3SLS2
scalar `kb'=e(kb)
scalar `N'=e(Nn)
qui gen `Time' =_n 
qui tsset `Time'
matrix `wmat'=WMB
qui cap drop w1x_*
qui cap drop w2x_*
qui cap drop w3x_*
qui cap drop w4x_*
gen `X0'=1
 if "`noconstant'"!="" {
mkmat w1y_`yvar' w1y_`endg' `endg' `xvar1' `aux' , matrix(`X3SLS1')
mkmat w1y_`endg' w1y_`yvar' `yvar' `xvar2' `aux' , matrix(`X3SLS2')
scalar `kz'=0
 } 
else {
mkmat w1y_`yvar' w1y_`endg' `endg' `xvar1' `aux' `X0' , matrix(`X3SLS1')
mkmat w1y_`endg' w1y_`yvar' `yvar' `xvar2' `aux' `X0' , matrix(`X3SLS2')
scalar `kz'=1
 } 
qui foreach var of local xvar {
mkmat `var', matrix(`var')
matrix `w1x' = `wmat'*`var'
matrix `w2x' = `wmat'*`w1x'
matrix `w3x' = `wmat'*`w2x'
matrix `w4x' = `wmat'*`w3x'
svmat  `w1x', name(w1x_`var')
svmat  `w2x', name(w2x_`var')
svmat  `w3x', name(w3x_`var')
svmat  `w4x', name(w4x_`var')
qui cap rename w1x_`var'1 w1x_`var'
qui cap rename w2x_`var'1 w2x_`var'
qui cap rename w3x_`var'1 w3x_`var'
qui cap rename w4x_`var'1 w4x_`var'
 }
local zvar w1x_* w2x_* `aux'
 if "`order'"<="2" {
qui cap drop w3x_*
qui cap drop w4x_*
 }
 if "`order'"=="3" {
local zvar w1x_* w2x_* w3x_* `aux'
qui cap drop w4x_*
 }
 if "`order'"=="4" {
local zvar w1x_* w2x_* w3x_* w4x_* `aux'
 }
 reg3 (`yvar' w1y_`yvar' w1y_`endg' `endg' `xvar1' `aux' , `noconstant') ///
      (`endg' w1y_`endg' w1y_`yvar' `yvar' `xvar2' `aux' , `noconstant') ///
 `wgt' , endog(`yvar' `endg' w1y_`yvar' w1y_`endg') exog(`xvar' `zvar') ///
 small `ols' `2sls' `3sls' `sure' `mvreg' `vce' `noconstant'
matrix `BS'=e(b)
local N=e(N)
scalar `k1'=e(df_m1)
scalar `k2'=e(df_m2)
scalar `kb1'=`k1'+`kz'
scalar `kb2'=`k2'+`kz'
scalar `K'=e(k)
scalar `Q'=2
scalar `DF1'=`k1'+`k2'
scalar `DF2'=`Q'*`N'-(`k1'+`k2')
scalar `DFF'=(`Q'*`N'-`DF1')/`DF1'
scalar `DFChi'=`DF1'
local ks=`kb1'+1
qui forvalue i=1/2 {
tempname r2h`i' r2h_a`i' fth`i' fth`i'p llf`i' aic`i' sc`i' Sig`i' df`i'
scalar `df`i''1=`kb`i''-`kz'
scalar `df`i''2=e(N)-`kb`i''-`kz'
scalar `r2h`i''=e(r2_`i')
scalar `r2h_a`i''=1-((1-e(r2_`i'))*(e(N)-1)/(e(N)-`kb`i''))
scalar `fth`i''=`r2h`i''/(1-`r2h`i'')*(e(N)-`kb`i''-`kz')/(`kb`i''-`kz')
scalar `fth`i'p'=Ftail(`df`i''1, `df`i''2,`fth`i'')
scalar `llf`i''=-(e(N)/2)*log(2*_pi*e(rss_`i')/e(N))-(e(N)/2)
scalar `aic`i''= 2*(`kb`i'')-2*`llf`i''
scalar `sc`i''=(`kb`i'')*ln(e(N))-2*`llf`i''
scalar `Sig`i''=e(rmse_`i')
 }
di as txt "{cmd:EQ1:} R2=" %7.4f as res `r2h1' as txt " - R2 Adj.=" as res %7.4f `r2h_a1' as txt "  F-Test =" _col(42) %9.3f as res `fth1' as txt _col(56) "P-Value> F("`df1'1 ", " `df1'2 ")" %5.3f as res _col(74) `fthp1'
di as txt "   LLF =" as res %10.3f `llf1' _col(22) as txt "AIC =" as res %9.3f `aic1' _col(40) as txt "SC =" as res %9.3f `sc1' _col(56) as txt "Root MSE =" as res %8.4f `Sig1'
di
di as txt "{cmd:EQ2:} R2=" %7.4f as res `r2h2' as txt " - R2 Adj.=" as res %7.4f `r2h_a2' as txt "  F-Test =" _col(42) %9.3f as res `fth2' as txt _col(56) "P-Value> F("`df2'1 ", " `df2'2 ")" %5.3f as res _col(74) `fthp2'
di as txt "   LLF =" as res %10.3f `llf2' _col(22) as txt "AIC =" as res %9.3f `aic2' _col(40) as txt "SC =" as res %9.3f `sc2' _col(56) as txt "Root MSE =" as res %8.4f `Sig2'
di as txt "   Yij = LHS Y(i) in Eq.(j)"
di _dup(78) "{bf:-}"
matrix `B3SLS1'=`BS'[1,1..`kb1']
matrix `B3SLS2'=`BS'[1,`ks'..`kb1'+`kb2']
mkmat `yvar' , matrix(`yvar1')
mkmat `endg' , matrix(`endg2')
matrix `XB1'=`X3SLS1'*`B3SLS1''
matrix `XB2'=`X3SLS2'*`B3SLS2''
matrix `Eu1'=`yvar1'-`XB1'
matrix `Eu2'=`endg2'-`XB2'
local N2N=2*`N'
qui set matsize `N2N'
matrix `E'=`Eu1',`Eu2'
matrix `Omega'=inv(`E''*`E'/`N')
qui summ `yvar'
qui gen `Yb_Y1' = `yvar' - `r(mean)'
qui summ `endg'
qui gen `Yb_Y2' = `endg' - `r(mean)'
mkmat `Yb_Y1' `Yb_Y2' , matrix(`Yb')
matrix `Ybv'=vec(`Yb')
matrix `Y'=`yvar1',`endg2'
matrix `Yv'=vec(`Y')
matrix `Ev'=vec(`E')
matrix `W'=inv((`E''*`E'/`N'))#I(`N')
matrix `Sig2'=det(`Omega')
scalar `Sig21'=`Sig2'[1,1]
matrix `SSE1'=det(`E''*`E')
matrix `SSE2'=`Ev''*`W'*`Ev'
matrix `SSE3'=`Ev''*`Ev'
matrix `SST1'=det(`Yb''*`Yb')
matrix `SST2'=`Ybv''*`W'*`Ybv'
matrix `SST3'=`Ybv''*`Ybv'
qui forvalues i = 1/3 {
tempname Ro`i'
matrix `MSS`i''=`SST`i''-`SSE`i''
matrix R`i'=1-(`SSE`i''*inv(`SST`i''))
scalar `Ro`i''=R`i'[1,1]
 }
qui forvalues i = 1/3 {
tempname ADR`i' F`i' Chi`i' PChi`i' PF`i'
scalar `ADR`i''=1-(1-`Ro`i'')*((`Q'*`N'-`Q')/(`Q'*`N'-`K'))
scalar `F`i''=`Ro`i''/(1-`Ro`i'')*`DFF'
scalar `Chi`i''= -`N'*(log(1-`Ro`i''))
scalar `PChi`i''= chi2tail(`DFChi', `Chi`i'')
scalar `PF`i''= Ftail(`DF1',`DF2', `F`i'')
 }
qui set matsize `N'
qui drop if `yvar' ==.
scalar `LSig2'=log(`Sig21')
scalar `LLF'=-(`N'*`Q'/2)*(1+log(2*_pi))-(`N'/2*abs(`LSig2'))
matrix `RS1'=`Ro1',`ADR1',`F1',`PF1',`Chi1',`PChi1'
matrix `RS2'=`Ro2',`ADR2',`F2',`PF2',`Chi2',`PChi2'
matrix `RS3'=`Ro3',`ADR3',`F3',`PF3',`Chi3',`PChi3'
matrix `RSQ'=`RS1' \ `RS2' \ `RS3'
matrix rownames `RSQ' = Berndt McElroy Judge
matrix colnames `RSQ' = R2 Adj_R2 F "P-Value" Chi2 "P-Value"
matlist `RSQ', title(- Overall System R2 - Adjusted R2 - F Test - Chi2 Test) twidth(8) border(all) lines(columns) rowtitle(Name) format(%8.4f)
di as txt "  Number of Parameters         =" as res _col(35) %10.0f `K'
di as txt "  Number of Equations          =" as res _col(35) %10.0f `Q'
di as txt "  Degrees of Freedom F-Test    =" as res _col(39) "(" `DF1' ", " `DF2' ")"
di as txt "  Degrees of Freedom Chi2-Test =" as res _col(35) %10.0f `DFChi'
di as txt "  Log Determinant of Sigma     =" as res _col(35) %10.4f `LSig2'
di as txt "  Log Likelihood Function      =" as res _col(35) %10.4f `LLF'
di _dup(78) "-"
ereturn scalar f_df1 = `DF1'
ereturn scalar f_df2 = `DF2'
ereturn scalar chi_df = `DFChi'
ereturn scalar lsig2=`LSig2'
ereturn scalar llf=`LLF'
ereturn scalar chi_b = `Chi3'
ereturn scalar chi_j = `Chi2'
ereturn scalar chi_m = `Chi1'
ereturn scalar f_b = `F3'
ereturn scalar f_j = `F2'
ereturn scalar f_m = `F1'
ereturn scalar r2a_b = `ADR3'
ereturn scalar r2a_j = `ADR2'
ereturn scalar r2a_m = `ADR1'
ereturn scalar r2_b = `Ro3'
ereturn scalar r2_j = `Ro2'
ereturn scalar r2_m = `Ro1'
ereturn scalar kb1=`kb1'
ereturn scalar kb2=`kb2'
ereturn scalar llf1=`llf1'
ereturn scalar llf2=`llf2'
ereturn scalar r2h1=`r2h1'
ereturn scalar r2h2=`r2h2'
ereturn matrix B3SLS1=`B3SLS1'
ereturn matrix B3SLS2=`B3SLS2'
ereturn matrix X3SLS1=`X3SLS1'
ereturn matrix X3SLS2=`X3SLS2'
ereturn matrix Y1_ML=`yvar1'
ereturn matrix Y2_ML=`endg2'
restore
end

program define yxregeq
version 10.0
 syntax varlist 
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


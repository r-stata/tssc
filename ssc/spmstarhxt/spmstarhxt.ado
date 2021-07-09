*! spmstarhxt V1.0 15/12/2013
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

program define spmstarhxt, eclass 
 version 11.0
 if replay() {
if "`e(cmd)'"!="spmstarhxt" {
 error 301
 }
 Display `0'
 }
 else {
 Estimate `0'
 }
 end
program define Estimate, eclass
version 11.0
syntax varlist [aw] , nc(str) WMFile(str) [NWmat(int 1) mhet(str) ///
 vce(passthru) stand zero ROBust MFX(str) NOLog LMHet LMSPac diag tobit ///
 iter(int 100) level(passthru) PREDict(str) INV INV2 LL(real 0) coll ///
 RESid(str) tech(str) tolog TESTs DN NOCONStant LMNorm]
local sthlp spmstarhxt
gettoken yvar xvar : varlist
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
 if inlist("`mfx'", "lin") {
 if "`tolog'"!="" {
di 
di as err " {bf:tolog} {cmd:Valid only with} {bf:mfx(log)}"
 exit
 }
 } 

 if "`nwmat'"!="" {
if !inlist("`nwmat'", "1", "2", "3", "4") {
di 
di as err " {bf:nwmat(#)} {cmd:number must be 1, 2, 3, or 4.}"
di
exit
 } 
 } 
tempvar D DE DF1 DumE E dcs XQX_ EE Eo Hat ht idv itv LE LEo P Q Sig2 SSE
tempvar SST Time U U2 Ue wald weit Wi Wio WS X X0 eigw Bo
tempvar Xb XB Xo XQ Yb Yh Yh2 Yhb Yt YY YYm YYv Yh_ML Ue_ML Z
tempname Xb A B Beta BetaSP Bx Cov D den DVE DVNE Dx E E1 F
tempname h Hat IPhi J K L M WS D WW eVec eigw Xo mh olsin
tempname P Phi Pm Q kbm IN xMx Sig2 Sig2o In IRW IRWR WXb SSE SST1 SST2
tempname Vec vh VM VP VQ Vs W W1 W2 Wald We Wi Wi1 Wio WY X X0 XB V
tempname xq Y Yh Yi YYm YYv Z Ue N DF kx kb NC NT Nmiss kz llf rRo kb
tempname Sig21 Dim wmat xAx xAx2 TRa2 wWw1 xBx Sig2n Rostar 
tempname minEig maxEig waldm waldmp waldm_df waldr waldrp waldr_df
di
scalar `N'=_N
scalar `NC'=`nc'
scalar `NT'=int(_N/`NC')
local N=`N'
local NT=`NT'
local NC=`NC'
if "`wmfile'" != "" {
preserve
qui use `"`wmfile'"', clear
qui summ
if `NT' !=int(`N'/r(N)) {
di 
di as err " Cross Section Weight Matrix = " r(N)
di as err " Time Series obs             = " `NT'
di as err " Sample Size (Number of obs) = " `N'
di as res " {bf:(Cross Sections x Time) must be Equal Sample Size}"
di as err " {bf:Spatial Cross Section Weight Matrix Dimension not correct}"
di as err " {bf:Check Correct Number Units, Unequal Time Series not Allowed}"
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
di as res "{bf:*** Standardized Weight Matrix: `N'x`N' - NC=`NC' NT=`NT' (Normalized)}"
matrix `Xo'=J(`NC',1,1)
matrix WB=_WB*`Xo'*`Xo''
mata: X = st_matrix("_WB")
mata: Y = st_matrix("WB")
mata: _WS=X:/Y
mata: _WS=st_matrix("_WS",_WS)
mata: _WS = st_matrix("_WS")
 if "`inv'"!="" {
di as res "{bf:*** Inverse Standardized Weight Matrix (1/W)}"
mata: _WS=1:/_WS
mata: _editmissing(_WS, 0)
mata: _WS=st_matrix("_WS",_WS)
 }
 if "`inv2'"!="" {
di as res "{bf:*** Inverse Squared Standardized Weight Matrix (1/W^2)}"
mata: _WS=_WS:*_WS
mata: _WS=1:/_WS
mata: _editmissing(_WS, 0)
mata: _WS=st_matrix("_WS",_WS)
 }
matrix WCS=_WS
 }
else {
di as res "{bf:*** Binary (0/1) Weight Matrix: `N'x`N' - NC=`NC' NT=`NT' (Non Normalized)}"
matrix WCS=_WB
 }
matrix eigenvalues eigw eVec = WCS
matrix eigw=vecdiag(diag(eigw')#I(`NT'))'
matrix WMB=WCS#I(`NT')
di _dup(78) "{bf:{err:=}}"
restore
qui cap drop `eigw'
qui svmat eigw , name(`eigw')
qui rename `eigw'1 `eigw'
qui cap confirm numeric var `eigw'
 }
ereturn scalar Nn=_N
qui marksample touse
qui cap count 
local N = r(N)
qui count 
local N = _N
qui markout `touse' `varlist' , strok
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
qui cap count 
local N = r(N)
local NC=`nc'
local NT=`N'/`NC'
qui cap drop `idv'
qui cap drop `itv'
qui cap drop `Time'
gen `Time' = _n
gen `idv'= ceil(_n/`NT')
gen `itv'= _n-(`idv'-1)*`NT'
qui xtset `idv' `itv'
scalar `Dim' = `N'
local MSize= `Dim'
if `c(matsize)' < `MSize' {
di as err " {bf:Current Matrix Size = (`c(matsize)')}"
di as err " {bf:{help matsize##|_new:matsize} must be >= Sample Size" as res " (`MSize')}"
qui set matsize `MSize'
di as res " {bf:matsize increased now to = (`c(matsize)')}"
 }
qui marksample touse
markout `touse' `varlist' , strok
 if "`zero'"!="" {
tempvar zeromiss
qui foreach var of local varlist {
qui gen `zeromiss'`var'=`var'
qui replace `var'=0 if `var'==.
 }
 }
if "`mhet'"=="" {
 local mhet "`xvar'"
 }
if "`tolog'"!="" {
local vlistlog " `varlist' `mhet' "
qui _rmcoll `vlistlog' , `noconstant' `coll' forcedrop
local vlistlog "`r(varlist)'"
di _dup(78) "-"
di as err " {cmd:** Data Have been Transformed to Log Form **}"
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
 if "`coll'"=="" {
_rmcoll `varlist' , `noconstant' `coll' forcedrop
 local varlist "`r(varlist)'"
 gettoken yvar xvar : varlist
_rmcoll `mhet' , `noconstant' `coll' forcedrop
 local mhet "`r(varlist)'"
 }
if "`tobit'" != "" {
di _dup(60) "-"
 if "`tolog'"!="" {
 local ll=log(`ll')
 if `ll' == . {
 local ll=0
 }
 }
qui count if `yvar' <= `ll'
di "{cmd:*** `yvar'}" _col(15) "{bf:{err: Lower Limit}}" _col(45) "= " `ll'
di "{cmd:*** `yvar'}" _col(15) "{bf:{err: Left-  Censored Observations}}" _col(45) "= " r(N)
di "{cmd:*** `yvar'}" _col(15) "{bf:{err: Left-UnCensored Observations}}" _col(45) "= " `N'-r(N)
di _dup(60) "-"
 }
local llt=`ll'
scalar spat_llt=`llt'
mkmat `yvar' , matrix(`Y')
qui cap drop w1x_*
qui cap drop w2x_*
qui cap drop w3x_*
qui cap drop w4x_*
qui cap drop w1y_*
local knw=`nwmat'
qui forvalue i=`nwmat'/`nwmat' {
matrix WMB_`i'=WMB
qui cap drop mstar_W`i'
qui gen mstar_W`i'=`eigw'
qui summ `eigw' 
scalar minEig`i'=1/r(min)
scalar maxEig`i'=1/r(max)
qui forvalue i=1/`knw' {
qui foreach var of local xvar {
tempname w`i'x_`var' SL`i'
qui cap drop w`i'x_`var'
qui mkmat `var' , matrix(`var')
qui matrix `w`i'x_`var'' = WMB_`i'*`var'
qui svmat `w`i'x_`var'' , name(w`i'x_`var')
qui rename w`i'x_`var'1 w`i'x_`var'
qui label variable w`i'x_`var' `"AR(`i') `var' Spatial Lag"'
qui cap drop w`i'y_`yvar'
matrix `SL`i'' = WMB_`i'*`Y'
qui svmat `SL`i'' , name(w`i'y_`yvar')
rename w`i'y_`yvar'1 w`i'y_`yvar'
label variable w`i'y_`yvar' `"AR(`i') `yvar' Spatial Lag"'
 }
 }
 }
qui gen `X0'=1
qui mkmat `X0' , matrix(`X0')
qui tabulate `idv' , generate(`dcs')
mkmat `dcs'* , matrix(`D')
matrix `P'=`D'*invsym(`D''*`D')*`D''
matrix `Q'=I(`N')-`P'
local SPXvar `xvar'
 if "`coll'"=="" {
_rmcoll `SPXvar' , `noconstant' `coll' forcedrop
local SPXvar "`r(varlist)'"
 }
local kx : word count `SPXvar'
local kmhet : word count `kmhet'
scalar `kb'=`kx'+1
scalar `DF'=`N'-`kx'-`NC'
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
global spat_kx=`kx'
global spat_kxw=2*`kx'
ereturn scalar df_m=$spat_kx
qui gen `Wi'=1 
qui gen `weit' = 1 
 if "`weight'" != "" {
qui replace `Wi' `exp' 
local wgt "[`weight'`exp']"
qui replace `Wi' = (`Wi')^0.5
 }
_vce_parse , opt(Robust oim opg) argopt(CLuster): `wgt' , `vce'
 local cns `s(constraints)'
 mlopts mlopts, `cns' `vce' `coll' iter(`iter') tech(`tech')
matrix `In'=I(`N')
local N = _N
tempname Bo
global spat_kx=`kx'
ereturn scalar df_m=`kx'
qui forvalue i=1/`kx' {
local var : word `i' of `SPXvar'
local COLNAME "`COLNAME'`yvar':`var' " 
 }
qui regress `yvar' `SPXvar' `wgt' , `noconstant'
global spat_kxw=2*$spat_kx
matrix `Bo'=e(b)
local rmse=e(rmse)
if "`nwmat'"=="1" {
local MName "MSTAR1h"
qui regress `yvar' `mhet' , noconstant
tempname olshet
matrix `olshet'=e(b)
matrix `olsin'=`Bo',`olshet',0,`rmse'
local initopt init(`olsin', copy)  
 ml model lf spmstarhxt1 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Hetero: `mhet', noconst) (Rho1:) (Sigma:) `wgt', `mlopts' contin ///
 `nolog' `diparm' `initopt' maximize title(`MName') search(on) `robust'
local COLNAME " `COLNAME'`yvar':_cons `mhet' Rho1:_cons Sigma:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression  (1 Weight Matrix)}}"
di as txt "{bf:{err:* (m-STAR) Spatial Lag Panel Multiplicative Heteroscedasticity Model}}"
di _dup(78) "{bf:{err:=}}"
matrix `BetaSP'=e(b)
scalar `Rostar'=_b[/Rho1]
qui test [Rho1]_cons
matrix `IRWR' = inv(`In'-_b[/Rho1]*WMB_1)
 }
 if "`nwmat'"=="2" {
local MName "MSTAR2h"
qui regress `yvar' `mhet' , noconstant
tempname olshet
matrix `olshet'=e(b)
matrix `olsin'=`Bo',`olshet',0,0,`rmse'
local initopt init(`olsin', copy)  
 ml model lf spmstarhxt2 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Hetero: `mhet', noconst) (Rho1:) (Rho2:) (Sigma:) `wgt', `mlopts' ///
 contin `nolog' `diparm' `initopt' maximize title(`MName') search(on) `robust'
local COLNAME " `COLNAME'`yvar':_cons `mhet' Rho1:_cons Rho2:_cons Sigma:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression (2 Weight Matrix)}}"
di as txt "{bf:{err:* (m-STAR) Spatial Lag Panel Multiplicative Heteroscedasticity Model}}"
di _dup(78) "{bf:{err:=}}"
matrix `BetaSP'=e(b)
scalar `Rostar'=_b[/Rho1]+_b[/Rho2]
qui test [Rho1]_cons [Rho2]_cons
 matrix `IRWR' = inv(`In'-_b[/Rho1]*WMB_1-_b[/Rho2]*WMB_2)
 }
 if "`nwmat'"=="3" {
local MName "MSTAR3h"
qui regress `yvar' `mhet' , noconstant
tempname olshet
matrix `olshet'=e(b)
matrix `olsin'=`Bo',`olshet',0,0,0,`rmse'
local initopt init(`olsin', copy)  
 ml model lf spmstarhxt3 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Hetero: `mhet', noconst) (Rho1:) (Rho2:) (Rho3:) (Sigma:) `wgt', `mlopts' ///
 contin `nolog' `diparm' `initopt' maximize title(`MName') search(on) `robust'
local COLNAME " `COLNAME'`yvar':_cons `mhet' Rho1:_cons Rho2:_cons Rho3:_cons Sigma:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression (3 Weight Matrix)}}"
di as txt "{bf:{err:* (m-STAR) Spatial Lag Panel Multiplicative Heteroscedasticity Model}}"
di _dup(78) "{bf:{err:=}}"
matrix `BetaSP'=e(b)
scalar `Rostar'=_b[/Rho1]+_b[/Rho2]+_b[/Rho3]
qui test [Rho1]_cons [Rho2]_cons [Rho3]_cons
matrix `IRWR'=inv(`In'-_b[/Rho1]*WMB_1-_b[/Rho2]*WMB_2-_b[/Rho3]*WMB_3)
 }
 if "`nwmat'"=="4" {
local MName "MSTAR4h"
qui regress `yvar' `mhet' , noconstant
tempname olshet
matrix `olshet'=e(b)
matrix `olsin'=`Bo',`olshet',0,0,0,0,`rmse'
local initopt init(`olsin', copy)  
 ml model lf spmstarhxt4 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Hetero: `mhet', noconst) (Rho1:) (Rho2:) (Rho3:) (Rho4:) (Sigma:) `wgt', ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons `mhet' Rho1:_cons Rho2:_cons Rho3:_cons Rho4:_cons Sigma:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* MLE Multiparametric Spatio Temporal AutoRegressive Regression (4 Weight Matrix)}}"
di as txt "{bf:{err:* (m-STAR) Spatial Lag Panel Multiplicative Heteroscedasticity Model}}"
di _dup(78) "{bf:{err:=}}"
matrix `BetaSP'=e(b)
scalar `Rostar'=_b[/Rho1]+_b[/Rho2]+_b[/Rho3]+_b[/Rho4]
qui test [Rho1]_cons [Rho2]_cons [Rho3]_cons [Rho4]_cons
matrix `IRWR'=inv(`In'-_b[/Rho1]*WMB_1-_b[/Rho2]*WMB_2-_b[/Rho3]*WMB_3-_b[/Rho4]*WMB_4)
 }
scalar `waldm'=e(chi2)
scalar `waldmp'=e(p)
scalar `waldm_df'=e(df_m)
scalar `waldr'=r(chi2)
scalar `waldrp'=r(p)
scalar `waldr_df'=r(df)
ereturn repost b=`BetaSP' , rename
matrix `Beta'=e(b)
matrix `Cov'=e(V)
matrix `Beta'=`Beta'[1,1..`kb']'
scalar `llf'=e(ll)
matrix `Cov'=`Cov'[1..`kb', 1..`kb']
matrix `Yh_ML'=`X'*`Beta'
matrix `IRW' = `IRWR'
matrix `Yh_ML'=`IRW'*`Yh_ML'
matrix `Ue_ML'=`Q'*(`Y'-`Yh_ML')
qui svmat `Yh_ML' , name(`Yh_ML')
qui rename `Yh_ML'1 `Yh_ML'
qui svmat `Ue_ML' , name(`Ue_ML')
qui rename `Ue_ML'1 `Ue_ML'
ereturn scalar k_aux=2
local N=_N
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
tempname SSEo Sigo r2bu r2bu_a r2raw r2raw_a f fp wald waldp
tempname r2v r2v_a fv fvp r2h r2h_a fh fhp SSTm SSE1 SST11 SST21 Rho b
matrix `SSE'=`Ue_ML''*`Ue_ML'
scalar `SSEo'=`SSE'[1,1]
scalar `Sig2o'=`SSEo'/`DF'
scalar `Sig2'=`SSEo'/`DF'
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
if "`robust'"!="" {
scalar `wald'=`waldm'
scalar `f'=`wald'/`kx'
scalar `r2bu'=(`f'*`kx')/((`f'*`kx')+(`N'-`kx'))
 if `r2bu'< 0 {
scalar `r2bu'=`r2h'
 }
scalar `r2bu_a'=1-((1-`r2bu')*(`N'-1)/`DF')
scalar `fp'= Ftail(`kx', `DF', `f')
scalar `waldp'=chi2tail(`kx', abs(`wald'))
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
yxregeq `yvar' `SPXvar'
di as txt _col(3) "Sample Size" _col(21) "=" %12.0f as res `N' _col(37) "|" _col(41) as txt "Cross Sections Number" _col(65) "=" _col(73) %5.0f as res `nc'
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
di _dup(78) "-"
di as res "{bf:- Sum of Rho's} = " as res %12.7f `Rostar' _col(34) "{bf:Sum must be < 1 for Stability Condition}" 
ereturn scalar kmhet=`kmhet'
ereturn scalar kb=`kb'
ereturn scalar kx=`kx'
ereturn scalar DF=`DF'
ereturn scalar waldm=`waldm'
ereturn scalar waldmp=`waldmp'
ereturn scalar waldm_df=`waldm_df'
ereturn scalar waldr=`waldr'
ereturn scalar waldrp=`waldrp'
ereturn scalar waldr_df=`waldr_df'
Display , `level' `robust'
matrix `b'=e(b)
matrix `V'=e(V)
matrix `Bx' =`b'[1..1, 1..`kx']'

if "`diag'"!= "" {
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Panel Model Selection Diagnostic Criteria}}"
di _dup(78) "{bf:{err:=}}"
scalar `kbm'=`kmhet'+`kb'
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

if "`lmspac'"!= "" {
tempname B0 B1 B2 b2k B3 B4 chi21 chi22 DEN DIM E EI Ein Esp eWe
tempname I m1k m2k m3k m4k MEAN NUM NUM1 NUM2 NUM3 RJ 
tempname S0 S1 S2 sd SEI SG0 SG1 TRa1 TRa2 trb TRw2 VI wi wj wMw wMw1
tempname WZ0 Xk NUM Zk m2 m4 b2 M eWe1 wWw2 zWz eWy eWy1 CPX SUM DFr
tempvar WZ0 Vm2 Vm4
matrix `wmat'=_WB#I(`NT')
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
 matrix `WXb'=`wmat'*`X'*`Beta'
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
di as txt "{bf:{err:*** Spatial Panel Aautocorrelation Tests}}"
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
tempvar Yh Yh2 LYh2 E E2 E3 E4 LnE2 absE time LE ht DumE EDumE U2
tempname mh vh h Q LMh_cwx lmhmss1 mssdf1 lmhmss1p 
tempname lmhmss2 mssdf2 lmhmss2p dfw0 lmhw01 lmhw01p lmhw02 lmhw02p dfw1 lmhw11
tempname lmhw11p lmhw12 lmhw12p dfw2 lmhw21 lmhw21p lmhw22 lmhw22p lmhharv
tempname lmhharvp lmhwald lmhwaldp lmhhp1 lmhhp1p lmhhp2 lmhhp2p lmhhp3 lmhhp3p lmhgl
tempname lmhglp lmhcw1 cwdf1 lmhcw1p lmhcw2 cwdf2 lmhcw2p lmhq lmhqp
qui tsset `Time'
matrix `SSE'=`Ue_ML''*`Ue_ML'
qui gen `U2' =`Ue_ML'^2/`Sig2n'
qui gen `Yh'=`Yh_ML'
qui gen `Yh2'=`Yh_ML'^2
qui gen `LYh2'=ln(`Yh2')
qui gen `E' =`Ue_ML'
qui gen `E2'=`Ue_ML'^2
qui gen `E3'=`Ue_ML'^3
qui gen `E4'=`Ue_ML'^4
qui gen `LnE2'=log(`E2') 
qui gen `absE'=abs(`E') 
qui gen `DumE'=0 
qui replace `DumE'=1 if `E' >= 0
qui summ `DumE' 
qui gen `EDumE'=`E'*(`DumE'-r(mean)) 
qui regress `EDumE' `Yh' `Yh2' , `noconstant' `vce'
scalar `lmhmss1'=e(N)*e(r2)
scalar `mssdf1'=e(df_m)
scalar `lmhmss1p'=chi2tail(`mssdf1', abs(`lmhmss1'))
qui regress `EDumE' `SPXvar' , `noconstant' `vce'
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
qui regress `E2' `SPXvar' , `noconstant'
scalar `dfw0'=e(df_m)
scalar `lmhw01'=e(r2)*e(N)
scalar `lmhw01p'=chi2tail(`dfw0' , abs(`lmhw01'))
scalar `lmhw02'=e(mss)/(2*`Sig2n'^2)
scalar `lmhw02p'=chi2tail(`dfw0' , abs(`lmhw02'))
qui regress `E2' `SPXvar' `XQX_'* , `noconstant'
scalar `dfw1'=e(df_m)
scalar `lmhw11'=e(r2)*e(N)
scalar `lmhw11p'=chi2tail(`dfw1' , abs(`lmhw11'))
scalar `lmhw12'=e(mss)/(2*`Sig2n'^2)
scalar `lmhw12p'=chi2tail(`dfw1' , abs(`lmhw12'))
qui cap drop `VN'*
qui cap drop `XQX_'*
mkmat `SPXvar' , matrix(`VN')
qui svmat `VN' , names(`VN')
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
qui regress `E2' `SPXvar' `XQX_'* , `noconstant'
scalar `dfw2'=e(df_m)
scalar `lmhw21'=e(r2)*e(N)
scalar `lmhw21p'=chi2tail(`dfw2' , abs(`lmhw21'))
scalar `lmhw22'=e(mss)/(2*`Sig2n'^2)
scalar `lmhw22p'=chi2tail(`dfw2' , abs(`lmhw22'))
qui regress `LnE2' `SPXvar' , `noconstant'
scalar `lmhharv'=e(mss)/4.9348
scalar `lmhharvp'= chi2tail(2, abs(`lmhharv'))
qui regress `LnE2' `SPXvar' , `noconstant'
scalar `lmhwald'=e(mss)/2
scalar `lmhwaldp'=chi2tail(1, abs(`lmhwald'))
qui regress `E2' `Yh' , `noconstant'
scalar `lmhhp1'=e(N)*e(r2)
scalar `lmhhp1p'=chi2tail(1, abs(`lmhhp1'))
qui regress `E2' `Yh2' , `noconstant'
scalar `lmhhp2'=e(N)*e(r2)
scalar `lmhhp2p'=chi2tail(1, abs(`lmhhp2'))
qui regress `E2' `LYh2' , `noconstant'
scalar `lmhhp3'=e(N)*e(r2)
scalar `lmhhp3p'= chi2tail(1, abs(`lmhhp3'))
qui regress `absE' `SPXvar' , `noconstant'
scalar `lmhgl'=e(mss)/((1-2/_pi)*`Sig2n')
scalar `lmhglp'=chi2tail(2, abs(`lmhgl'))
qui regress `U2' `Yh' , `noconstant'
scalar `lmhcw1'= e(mss)/2
scalar `cwdf1' = e(df_m)
scalar `lmhcw1p'=chi2tail(`cwdf1', abs(`lmhcw1'))
qui regress `U2' `SPXvar' , `noconstant'
scalar `lmhcw2'=e(mss)/2
scalar `cwdf2' =e(df_m)
scalar `lmhcw2p'=chi2tail(`cwdf2', abs(`lmhcw2'))
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:*** Panel Heteroscedasticity Tests}}"
di _dup(78) "{bf:{err:=}}"
di as txt _col(2) "{bf: Ho: Panel Homoscedasticity - Ha: Panel Heteroscedasticity}"
di
tempvar Time
tempname lmharch lmharchp lmhbg lmhbgp
qui gen `Time'=_n
qui tsset `Time'
qui cap drop `LE'*
qui gen `LE'1=L1.`E2' 
qui regress `E2' `LE'* 
scalar `lmharch'=e(r2)*e(N)
scalar `lmharchp'= chi2tail(1, abs(`lmharch'))
qui regress `E2' L1.`E2' `SPXvar' , `noconstant'
scalar `lmhbg'=e(r2)*e(N)
scalar `lmhbgp'=chi2tail(1, abs(`lmhbg'))
di as txt "- Engle LM ARCH Test AR(1): E2 = E2_1" _col(41) "=" as res %9.4f `lmharch' _col(54) as txt "P-Value > Chi2(1)" _col(73) as res %5.4f `lmharchp'
di _dup(78) "-"
di as txt "- Hall-Pagan LM Test:   E2 = Yh" _col(41) "=" as res %9.4f `lmhhp1' _col(54) as txt "P-Value > Chi2(1)" _col(73) as res %5.4f `lmhhp1p'
di as txt "- Hall-Pagan LM Test:   E2 = Yh2" _col(41) "=" as res %9.4f `lmhhp2' _col(54) as txt "P-Value > Chi2(1)" _col(73) as res %5.4f `lmhhp2p'
di as txt "- Hall-Pagan LM Test:   E2 = LYh2" _col(41) "=" as res %9.4f `lmhhp3' _col(54) as txt "P-Value > Chi2(1)" _col(73) as res %5.4f `lmhhp3p'
di _dup(78) "-"
di as txt "- Harvey LM Test:    LogE2 = X" _col(41) "=" as res %9.4f `lmhharv' _col(54) as txt "P-Value > Chi2(2)" _col(73) as res %5.4f `lmhharvp'
di as txt "- Wald Test:         LogE2 = X " _col(41) "=" as res %9.4f `lmhwald' _col(54) as txt "P-Value > Chi2(1)" _col(73) as res %5.4f `lmhwaldp'
di as txt "- Glejser LM Test:     |E| = X" _col(41) "=" as res %9.4f `lmhgl' _col(54) as txt "P-Value > Chi2(2)" _col(73) as res %5.4f `lmhglp'
di as txt "- Breusch-Godfrey Test:  E = E_1 X" _col(41) "=" as res %9.4f `lmhbg' _col(54) as txt "P-Value > Chi2(1)" _col(73) as res %5.4f `lmhbgp'
di _dup(78) "-"
di as txt "- Machado-Santos-Silva Test: Ev=Yh Yh2" _col(41) "=" as res %9.4f `lmhmss1' _col(54) as txt "P-Value > Chi2(" `mssdf1' ")" _col(73) as res %5.4f `lmhmss1p'
di as txt "- Machado-Santos-Silva Test: Ev=X" _col(41) "=" as res %9.4f `lmhmss2' _col(54) as txt "P-Value > Chi2(" `mssdf2' ")" _col(73) as res %5.4f `lmhmss2p'
ereturn scalar lmhmss2p= `lmhmss2p'
ereturn scalar lmhmss2= `lmhmss2p'
ereturn scalar lmhmss1p= `lmhmss1p'
ereturn scalar lmhmss1= `lmhmss1'
di _dup(78) "-"
di as txt "- White Test - Koenker(R2): E2 = X" _col(41) "=" as res %9.4f `lmhw01' _col(54) as txt "P-Value > Chi2(" `dfw0' ")" _col(73) as res %5.4f `lmhw01p'
di as txt "- White Test - B-P-G (SSR): E2 = X" _col(41) "=" as res %9.4f `lmhw02' _col(54) as txt "P-Value > Chi2(" `dfw0' ")" _col(73) as res %5.4f `lmhw02p'
di _dup(78) "-"
di as txt "- White Test - Koenker(R2): E2 = X X2" _col(41) "=" as res %9.4f `lmhw11' _col(54) as txt "P-Value > Chi2(" `dfw1' ")" _col(73) as res %5.4f `lmhw11p'
di as txt "- White Test - B-P-G (SSR): E2 = X X2" _col(41) "=" as res %9.4f `lmhw12' _col(54) as txt "P-Value > Chi2(" `dfw1' ")" _col(73) as res %5.4f `lmhw12p'
di _dup(78) "-"
di as txt "- White Test - Koenker(R2): E2 = X X2 XX" _col(41) "=" as res %9.4f `lmhw21' _col(54) as txt "P-Value > Chi2(" `dfw2' ")" _col(73) as res %5.4f `lmhw21p'
di as txt "- White Test - B-P-G (SSR): E2 = X X2 XX" _col(41) "=" as res %9.4f `lmhw22' _col(54) as txt "P-Value > Chi2(" `dfw2' ")" _col(73) as res %5.4f `lmhw22p'
di _dup(78) "-"
di as txt "- Cook-Weisberg LM Test: E2/S2n = Yh" _col(41) "=" as res %9.4f `lmhcw1' _col(54) as txt "P-Value > Chi2(" `cwdf1' ")" _col(73) as res %5.4f `lmhcw1p'
di as txt "- Cook-Weisberg LM Test: E2/S2n = X" _col(41) "=" as res %9.4f `lmhcw2' _col(54) as txt "P-Value > Chi2(" `cwdf2' ")" _col(73) as res %5.4f `lmhcw2p'
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
di _dup(78) "-"
tempvar Sig2 SigLR SigLRs SigLM SigLMs SigW SigWs E E2 EE1 En cN cT Obs Egh
local idv `idv'
qui tsset `Time'
qui regress `yvar' `SPXvar' `wgt' , `noconstant'
qui predict `E' , res
qui gen double `E2' = `E'^2 
qui summ `E2' , meanonly
local Sig2 = r(mean)
qui gen double `SigLR' = . 
qui gen double `SigLM' = . 
qui gen double `SigW'  = . 
local SigLRs = 0
local SigLMs = 0
local SigWs  = 0
qui levelsof `idv' , local(levels)
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
ereturn scalar lmhw01=`lmhw01'
ereturn scalar lmhw01p=`lmhw01p'
ereturn scalar lmhw02=`lmhw02'
ereturn scalar lmhw02p=`lmhw02p'
ereturn scalar lmhw11=`lmhw11'
ereturn scalar lmhw12=`lmhw12'
ereturn scalar lmhw11p=`lmhw11p'
ereturn scalar lmhw12p=`lmhw12p'
ereturn scalar lmhw21=`lmhw21'
ereturn scalar lmhw22=`lmhw22'
ereturn scalar lmhw21p=`lmhw21p'
ereturn scalar lmhw22p=`lmhw22p'
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
ereturn scalar lmhcw1p=`lmhcw1p'
ereturn scalar lmhcw2=`lmhcw2'
ereturn scalar lmhcw2p=`lmhcw2p'
ereturn scalar lmharch=`lmharch'
ereturn scalar lmharchp=`lmharchp'
ereturn scalar lmhbg=`lmhbg'
ereturn scalar lmhbgp=`lmhbgp'
 }

if "`lmnorm'"!= "" {
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
matrix `Hat'=vecdiag(`X'*invsym(`X''*`X')*`X'')'
qui svmat `Hat' , name(`Hat')
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
mkmat `E'1 `E'2 `E'3 `E'4 in 1/`N' , matrix(`ECov')
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
di as txt "{bf:{err:* Panel Non Normality Tests}}"
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
 if "`tests'"!="" {
tempname K B XBM XB E E2 Sig XBs Es Eg Gz Eg3 Eg4
tempname ImR D0 D1 DB DS U3 U4 M1 M2 DB0 XBX SigV SigV2 Yh SigM H kxt
tempvar EXwXw AM SSE YYR R2Raw
scalar `kxt' = `kx'
qui xtset `idv' `itv'
qui xttobit `yvar' `SPXvar' , nolog ll(`llt') `noconstant' `coll'
qui predict `XBX' , xb
local k = `kxt'
qui gen `SigV'=_b[/sigma_e]
qui gen `E'=`yvar'-`XBX' 
qui gen `SigV2'= `SigV'^2 
qui gen `XBs'= `XBX'/`SigV' 
qui gen `Es'= `E'/`SigV' 
qui gen `ImR'=normalden(`XBs')/(1-normal(`XBs')) 
qui replace `ImR'=0 if `ImR' == .
qui gen `D0'=0 
qui gen `D1'=0 
qui replace `D0'=1 if `yvar' == `llt'
qui replace `D1'=1 if `yvar' > `llt'
qui gen `DB' =(`D1'*`Es'-`D0'*`ImR')/`SigV' 
qui gen `DS' =(`D1'*(`Es'^2-1)+`D0'*`ImR'*`XBs')/`SigV' 
qui gen `Eg'=(`D1'*(`yvar'-`XBX')-`D0'*`SigV'*`ImR')/(`SigV2') 
qui foreach var of local SPXvar {
qui gen `EXwXw'`var'=`Eg'*`var' 
 }
qui gen `Gz'=(`D1'*(((`yvar'-`XBX')^2/`SigV2')-1)+`D0'*`XBs'*`ImR')/(2*`SigV2') 
qui gen `Eg3'=`Eg'^3 
qui gen `Eg4'=(`Eg'^4)-3*`Eg'*`Eg' 
qui regress `X0' `EXwXw'* `Eg' `Gz' `Eg3' `Eg4' , noconst
tempname SSE YYR lmnci NR2 
tempvar dfdb dfds B sig XB XBs Es u1 u2 u3 u4
scalar `SSE'=e(rss)
scalar `YYR'=_N
scalar `R2Raw'=1-(`SSE'/`YYR')
scalar `lmnci'=`N'*`R2Raw'
qui tobit `yvar' `SPXvar' , nolog ll(`llt') `noconstant' `coll'
qui predict `dfdb' `dfds' , score
qui gen `sig'=_b[/sigma]
qui predict `XB' , xb
qui gen `XBs'=`XB'/`sig' 
qui gen `Es'=(`yvar'-`XB')/`sig' 
qui replace `ImR'=normalden(`XBs')/(1-normal(`XBs')) 
qui replace `ImR'=0 if `ImR' == .
qui gen `u1'= -`D0'*`ImR' +`D1'*`Es' 
qui gen `u2'= `D0'*`XBs'*`ImR' +`D1'*(`Es'^2 - 1) 
qui gen `u3'= -`D0'*(2+`XBs'^2)*`ImR' +`D1'*`Es'^3 
qui gen `u4'= `D0'*(3*`XBs'+`XBs'^3) *`ImR' +`D1'*(`Es'^4 - 3) 
 tempvar d0 
qui summ `dfdb' 
qui gen `d0'=`dfdb' 
local vlist "`d0'"
local mlist ""
local vlist ""
local mlist ""
local j=1
qui while `j'<=`kx' {
 tempvar d`j' mom`j'
local j=`j'+1
 }
local j=0
 tokenize `SPXvar'
qui while "`1'"~="" {
local j=`j'+1
qui gen `d`j''=`dfdb'*`1' 
qui gen `mom`j''=`u2'*`1' 
local vlist "`vlist' `d`j''"	
local mlist "`mlist' `mom`j''"	
 macro shift
local vlist "`vlist' `dfdb' `dfds'"
 }
local j=1
qui while "`1'"~="" {
local vlist "`vlist' dfdb`j'"
local j=`j'+1
 }
 tempvar const
 gen `const'=1 
local q=0
 while `q'<=4 {
 if `q'==0 {
local j=1
 tokenize `SPXvar'
di 
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:*** Tobit Heteroscedasticity LM Tests}}"
di _dup(78) "{bf:{err:=}}"
di as txt " {bf:Separate LM Tests - Ho: Homoscedasticity}"
 while `j'<=`kx' {
qui regress `const' `mom`j'' `vlist' , noconstant
scalar `NR2'=e(r2)*e(N)
local df=1
di as txt "- LM Test: " "``j''" _col(33) "=" as res %10.4f `NR2' _col(47) as txt "P-Value > Chi2(1)" _col(67) as res %5.4f chi2tail(`df', abs(`NR2'))
local j=`j'+1
 }
 }
 if `q'==1 {
di
di as txt " {bf:Joint LM Test     - Ho: Homoscedasticity}"
qui regress `const' `mlist' `vlist' , noconstant
 }
 if `q'==2 {
di 
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:*** Tobit Non Normality LM Tests}}"
di _dup(78) "{bf:{err:=}}"
di as txt " {bf:LM Test - Ho: No Skewness}"
qui regress `const' `u3' `vlist' , noconstant
 }
 if `q'==3 {
di
di as txt " {bf:LM test - Ho: No Kurtosis}"
qui regress `const' `u4' `vlist' , noconstant
 }
 if `q'==4 {
di
di as txt " {bf:LM Test - Ho: Normality (No Kurtosis, No Skewness)}"
qui regress `const' `u3' `u4' `vlist' , noconstant
 }
scalar `NR2'=e(r2)*e(N)
 if `q'==1 {
local df=`kx'
 }
 if `q'==2 {
local df=1
 }
 if `q'==3 {
local df=1
 }
 if `q'==4 {
local df=2
 }
 if `q'>0 & `q'<4 {
di as txt _col(2) "- LM Test"  _col(33) "=" %10.4f as res `NR2' as txt _col(47) "P-Value > Chi2(" `df' ")" _col(67) as res %5.4f chi2tail(`df', abs(`NR2'))
 }
 if `q' == 4 {
di as txt _col(2) "- Pagan-Vella LM Test" _col(33) "=" %10.4f as res `NR2' as txt _col(47) "P-Value > Chi2(2)" _col(67) as res %5.4f chi2tail(2, abs(`NR2'))
ereturn scalar lmnpv=`NR2'
ereturn scalar lmnpvp=chi2tail(`df', abs(`NR2'))
 }
 if `q'==1 {
scalar phom= chi2tail(`df', abs(`NR2'))
 }
 if `q'==4 {
scalar pnor= chi2tail(`df', abs(`NR2'))
 }
local q=`q'+1
 }
ereturn scalar lmnci=`lmnci'
ereturn scalar lmncip=chi2tail(2, abs(`lmnci'))
di as txt _col(2) "- Chesher-Irish LM Test" _col(33) "=" %10.4f as res e(lmnci) as txt _col(47) "P-Value > Chi2(2)" _col(67) as res %5.4f e(lmncip)
di _dup(78) "-"
 }
if "`tolog'"!="" {
qui foreach var of local vlistlog {
qui replace `var'= `xyind`var'' 
 }
 }
if inlist("`mfx'", "lin", "log") {
tempname XMB XYMB YMB YMB1 SumW TRW TRWS TRWS1 NSumW NTRWS InDirect Direct Total
tempname spmfxb spmfxe InDirectES DirectES TotalES Betaes mfxb mfxe mfxlin mfxlog
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
 }
if inlist("`mfx'", "log") {
mata: `XYMB'=Y:/X
mata: `XYMB'=st_matrix("`XYMB'",`XYMB')
 }
scalar `SumW'=0
local N = `N'
qui forvalues i = 1/`N' {
qui forvalues j = 1/`N' {
scalar `SumW'=`SumW'+(`IRW'[`i',`j'])
scalar j=`j'+1
 }
 }
matrix `TRW'=trace(`IRW')
scalar `TRWS1'=`TRW'[1,1]
scalar `NSumW'=`N'/`SumW'
scalar `NTRWS'=`N'/`TRWS1'
matrix `Total' = `Bx'*`NTRWS'
matrix `Direct'= `Bx'*`NSumW'
matrix `InDirect'= `Total' - `Direct'
matrix `spmfxb' =`Bx',`Total',`Direct',`InDirect',`XMB'
matrix `Betaes' = vecdiag(`Bx'*`XYMB'')'
matrix `TotalES'=vecdiag(`Total'*`XYMB'')'
matrix `DirectES'=vecdiag(`Direct'*`XYMB'')'
matrix `InDirectES'=vecdiag(`InDirect'*`XYMB'')'
matrix `spmfxe' =`Betaes',`TotalES',`DirectES',`InDirectES',`XMB'
matrix rownames `spmfxb'= `SPXvar'
matrix rownames `spmfxe'= `SPXvar'
if inlist("`mfx'", "lin") {
matrix colnames `spmfxb'= Beta(B) Total Direct InDirect Mean
matrix colnames `spmfxe'= Beta(Es) Total Direct InDirect Mean
matlist `spmfxb' , title({bf:* Beta, Total, Direct, and InDirect: {err:Linear: Marginal Effect} *}) twidth(12) border(all) lines(columns) rowtitle(Variable) format(%10.4f)
matlist `spmfxe' , title({bf:* Beta, Total, Direct, and InDirect: {err:Linear: Elasticity} *}) twidth(12) border(all) lines(columns) rowtitle(Variable) format(%10.4f)
ereturn matrix mfxlinb=`spmfxb'
ereturn matrix mfxline=`spmfxe'
 }
if inlist("`mfx'", "log") {
matrix colnames `spmfxb'= Beta(Es) Total Direct InDirect Mean
matrix colnames `spmfxe'= Beta(B) Total Direct InDirect Mean
matlist `spmfxb' , title({bf:* Beta, Total, Direct, and InDirect: {err:Log-Log: Elasticity} *}) twidth(12) border(all) lines(columns) rowtitle(Variable) format(%10.4f)
matlist `spmfxe' , title({bf:* Beta, Total, Direct, and InDirect: {err:Log-Log: Marginal Effect} *}) twidth(12) border(all) lines(columns) rowtitle(Variable) format(%10.4f)
ereturn matrix mfxlogb=`spmfxb'
ereturn matrix mfxloge=`spmfxe'
 }
di as txt " Mean of Dependent Variable =" as res _col(30) %12.4f `YMB1'
 }
matrix drop eigw WCS eVec _WB WMB
qui cap mata: mata drop *
 if "`zero'"!="" {
qui foreach var of local varlist {
qui replace `var'= `zeromiss'`var' 
 }
 }
qui sort `Time'
end

program define Display
version 11.0
syntax, [Level(int $S_level) robust]
if inlist("`e(title)'", "MSTAR1h") {
ml display, level(`level') neq(2) noheader diparm(Rho1, label("Rho1")) ///
          diparm(Sigma, label("Sigma"))
local PARM1 "Rho1"
di as txt " Wald Test [`PARM1'=0]:" _col(35) %9.4f as res e(waldr) as txt _col(52) "P-Value > Chi2(1)" as res _col(70) %5.4f e(waldrp)
di as txt " Acceptable Range for Rho1: " as res %6.4f minEig1 " < Rho1 < " %6.4f maxEig1
 }
if inlist("`e(title)'", "MSTAR2h") {
ml display, level(`level') neq(2) noheader diparm(Rho1, label("Rho1")) ///
 diparm(Rho2, label("Rho2")) diparm(Sigma, label("Sigma"))
local PARM2 "Rho1+Rho2"
di as txt " Wald Test [`PARM2'=0]:" _col(35) %9.4f as res e(waldr) as txt _col(52) "P-Value > Chi2(2)" as res _col(70) %5.4f e(waldrp)
di as txt " Acceptable Range for Rho1: " as res %6.4f minEig1 " < Rho1 < " %6.4f maxEig1 
di as txt " Acceptable Range for Rho2: " as res %6.4f minEig2 " < Rho2 < " %6.4f maxEig2
 }
if inlist("`e(title)'", "MSTAR3h") {
ml display, level(`level') neq(2) noheader diparm(Rho1, label("Rho1")) ///
 diparm(Rho2, label("Rho2")) diparm(Rho3, label("Rho3")) diparm(Sigma, label("Sigma"))
local PARM3 "Rho1+Rho2+Rho3"
di as txt " Wald Test [`PARM3'=0]:" _col(35) %9.4f as res e(waldr) as txt _col(52) "P-Value > Chi2(3)" as res _col(70) %5.4f e(waldrp)
di as txt " Acceptable Range for Rho1: " as res %6.4f minEig1 " < Rho1 < " %6.4f maxEig1 
di as txt " Acceptable Range for Rho2: " as res %6.4f minEig2 " < Rho2 < " %6.4f maxEig2 
di as txt " Acceptable Range for Rho3: " as res %6.4f minEig3 " < Rho3 < " %6.4f maxEig3
 }
if inlist("`e(title)'", "MSTAR4h") {
ml display, level(`level') neq(2) noheader diparm(Rho1, label("Rho1")) ///
 diparm(Rho2, label("Rho2")) diparm(Rho3, label("Rho3")) ///
 diparm(Rho4, label("Rho4")) diparm(Sigma, label("Sigma"))
local PARM4 "Rho1+Rho2+Rho3+Rho4"
di as txt " Wald Test [`PARM4'=0]:" _col(35) %9.4f as res e(waldr) as txt _col(52) "P-Value > Chi2(4)" as res _col(70) %5.4f e(waldrp)
di as txt " Acceptable Range for Rho1: " as res %6.4f minEig1 " < Rho1 < " %6.4f maxEig1 
di as txt " Acceptable Range for Rho2: " as res %6.4f minEig2 " < Rho2 < " %6.4f maxEig2 
di as txt " Acceptable Range for Rho3: " as res %6.4f minEig3 " < Rho3 < " %6.4f maxEig3
di as txt " Acceptable Range for Rho4: " as res %6.4f minEig4 " < Rho4 < " %6.4f maxEig4
 }
di _dup(78) "-"
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

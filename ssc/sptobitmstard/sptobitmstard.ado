*! sptobitmstard V2.0 25/11/2013
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

program define sptobitmstard , eclass 
 version 11.0
 if replay() {
if "`e(cmd)'"!="sptobitmstard" {
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
syntax varlist [aw] , WMFile(str) LL(str) [NWmat(int 1) NOCONStant tolog ///
 INV INV2 vce(passthru) dist(str) stand MFX(str) noLOG ROBust aux(str) ///
 iter(int 100) level(passthru) PREDict(str) RESid(str) tech(str)coll]
gettoken yvar xvar : varlist
local sthlp sptobitmstard
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
 if ("`inv'"!="" | "`inv2'"!="" ) & "`stand'"=="" {
di
di as err " {bf:inv, inv2} {cmd:and} {bf:stand} {cmd:must be combined}"
exit
 }
 if "`dist'"!="" {
if !inlist("`dist'", "norm", "weib") {
di 
di as err " {bf:dist( )} {cmd:must be:}
di as err " {bf:dist({it:norm})} {cmd:for Normal model}"
di as err " {bf:dist({it:weib})} {cmd:for Weibull model}"
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
 if inlist("`mfx'", "log") {
 if "`tolog'"=="" {
di 
di as err " {bf:tolog} {cmd:must be combined with} {bf:mfx(log)}"
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
tempvar Bw D DE DF DF1 E P Q Sig2 SSE SST Time U U2 Ue Ue_ wald weit
tempvar Wi Wio Xb XB Xo XQ Yb Yh Yh2 Yhb Yt YY YYm YYv Yh_ML Ue_ML Z
tempname A B b Beta BetaSP Bx WS Cov D E F IPhi J K  
tempname P Phi Pm Q Sig2 Sig2o SSE SST1 SST2 D WW eVec eigw Xo
tempname In IRW Vec vh W W1 W2 Wald We Wi Wi1 Wio WY X X0 XB V Nmiss kz
tempname Xb Y Yh Yi YYm YYv Z llf Rostar rRo kb Sig21 Dim olsin N DF kx kb
tempname minEig maxEig waldm waldmp waldm_df waldr waldrp waldr_df
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
if "`tolog'"!="" {
local vlistlog " `varlist' "
_rmcoll `vlistlog' , `noconstant' `coll' forcedrop
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
 if "`coll'"=="" {
_rmcoll `varlist' , `noconstant' `coll' forcedrop
 local varlist "`r(varlist)'"
gettoken yvar xvar : varlist
_rmcoll `aux' , `noconstant' `coll' forcedrop
 local aux "`r(varlist)'"
 }
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
local llt=`ll'
scalar spat_llt=`llt'
qui cap drop w1x_*
qui cap drop w2x_*
qui cap drop w3x_*
qui cap drop w4x_*
qui cap drop w1y_*
mkmat `yvar' , matrix(`Y')
 if "`nwmat'"!="" {
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
 }
qui cap confirm numeric var `eigw'
unab zvar: w1x_*
 if "`nwmat'"=="2" {
unab zvar: w1x_* w2x_*
 }
 if "`nwmat'"=="3" {
unab zvar: w1x_* w2x_* w3x_*
 }
 if "`nwmat'"=="4" {
unab zvar: w1x_* w2x_* w3x_* w4x_*
 }
local SPXvar `xvar' `zvar' `aux'
 if "`coll'"=="" {
_rmcoll `SPXvar' , `noconstant' `coll' forcedrop
 local SPXvar "`r(varlist)'"
 }
qui gen `X0'=1
qui mkmat `X0' , matrix(`X0')
local kx : word count `SPXvar'
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
matrix `In'=I(`N')
global spat_kx=`kx'
ereturn scalar df_m=`kx'
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
tempname Bo
qui forvalue i=1/`kx' {
local var : word `i' of `xvar'
local COLNAME "`COLNAME'`yvar':`var' " 
 }
qui regress `yvar' `SPXvar' , `noconstant'
matrix `Bo'=e(b)
local rmse=e(rmse)

if "`nwmat'"=="1" {
if !inlist("`dist'", "weib") {
local MName "MSTAR1n"
 matrix `olsin'=`Bo',0,`rmse'
local initopt init(`olsin', copy) 
 ml model lf sptobitmstard1 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho1:) (Sigma:) `wgt' , `mlopts' contin `nolog' `diparm' ///
 `initopt' maximize title(`MName') search(on) `robust'
local COLNAME " `COLNAME'`yvar':_cons Rho1:_cons Sigma:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Tobit MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
di as txt "{bf:{err:* (m-STAR) Spatial Durbin Normal Model (1 Weight Matrix)}}"
di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`dist'", "weib") {
local MName "MSTAR1w"
 matrix `olsin'=`Bo',0,`rmse'
local initopt init(`olsin', copy) 
 ml model lf sptobitmstard2 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho1:) (Sigma:) `wgt' , `mlopts' contin `nolog' `diparm' ///
 `initopt' maximize title(`MName') search(on) `robust'
local COLNAME " `COLNAME'`yvar':_cons Rho1:_cons Sigma:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Tobit MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
di as txt "{bf:{err:* (m-STAR) Spatial Durbin Weibull Model (1 Weight Matrix)}}"
di _dup(78) "{bf:{err:=}}"
 }
matrix `BetaSP'=e(b)
scalar `Rostar'=_b[/Rho1]
qui test  [Rho1]_cons
matrix `IRW' = inv(`In'-_b[/Rho1]*WMB_1)
 }
if "`nwmat'"=="2" {
if !inlist("`dist'", "weib") {
local MName "MSTAR2n"
 matrix `olsin'=`Bo',0,0,`rmse'
local initopt init(`olsin', copy)  
 ml model lf sptobitmstard3 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho1:) (Rho2:) (Sigma:) `wgt' , `mlopts' contin `nolog' `diparm' ///
 `initopt' maximize title(`MName') search(on) `robust'
local COLNAME " `COLNAME'`yvar':_cons Rho1:_cons Rho2:_cons Sigma:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Tobit MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
di as txt "{bf:{err:* (m-STAR) Spatial Durbin Normal Model (2 Weight Matrix)}}"
di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`dist'", "weib") {
local MName "MSTAR2w"
 matrix `olsin'=`Bo',0,0,`rmse'
local initopt init(`olsin', copy)  
 ml model lf sptobitmstard4 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho1:) (Rho2:) (Sigma:) `wgt' , `mlopts' contin `nolog' `diparm' ///
 `initopt' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons Rho1:_cons Rho2:_cons Sigma:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Tobit MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
di as txt "{bf:{err:* (m-STAR) Spatial Durbin Weibull Model (2 Weight Matrix)}}"
di _dup(78) "{bf:{err:=}}"
 }
matrix `BetaSP'=e(b)
scalar `Rostar'=_b[/Rho1]+_b[/Rho2]
qui test [Rho1]_cons [Rho2]_cons
 matrix `IRW' = inv(`In'-_b[/Rho1]*WMB_1-_b[/Rho2]*WMB_2)
 }
if "`nwmat'"=="3" {
if !inlist("`dist'", "weib") {
local MName "MSTAR3n"
 matrix `olsin'=`Bo',0,0,0,`rmse'
local initopt init(`olsin', copy) 
 ml model lf sptobitmstard5 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho1:) (Rho2:) (Rho3:) (Sigma:) `wgt' , `mlopts' contin `nolog' ///
 `diparm' `initopt' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons Rho1:_cons Rho2:_cons Rho3:_cons Sigma:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Tobit MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
di as txt "{bf:{err:* (m-STAR) Spatial Durbin Normal Model (3 Weight Matrix)}}"
di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`dist'", "weib") {
local MName "MSTAR3w"
 matrix `olsin'=`Bo',0,0,0,`rmse'
local initopt init(`olsin', copy)  
 ml model lf sptobitmstard6 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho1:) (Rho2:) (Rho3:) (Sigma:) `wgt' , `mlopts' contin `nolog' `diparm' ///
 `initopt' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons Rho1:_cons Rho2:_cons Rho3:_cons Sigma:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Tobit MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
di as txt "{bf:{err:* (m-STAR) Spatial Durbin Weibull Model (3 Weight Matrix)}}"
di _dup(78) "{bf:{err:=}}"
 }
matrix `BetaSP'=e(b)
scalar `Rostar'=_b[/Rho1]+_b[/Rho2]+_b[/Rho3]
qui test [Rho1]_cons [Rho2]_cons [Rho3]_cons
matrix `IRW'=inv(`In'-_b[/Rho1]*WMB_1-_b[/Rho2]*WMB_2-_b[/Rho3]*WMB_3)
 }
if "`nwmat'"=="4" {
if !inlist("`dist'", "weib") {
local MName "MSTAR4n"
 matrix `olsin'=`Bo',0,0,0,0,`rmse'
local initopt init(`olsin', copy) 
 ml model lf sptobitmstard7 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho1:) (Rho2:) (Rho3:) (Rho4:) (Sigma:) `wgt' , `mlopts' contin `nolog' ///
 `diparm' `initopt' maximize title(`MName') search(on) `robust'
local COLNAME " `COLNAME'`yvar':_cons Rho1:_cons Rho2:_cons Rho3:_cons Rho4:_cons Sigma:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Tobit MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
di as txt "{bf:{err:* (m-STAR) Spatial Durbin Normal Model (4 Weight Matrix)}}"
di _dup(78) "{bf:{err:=}}"
 }
 if inlist("`dist'", "weib") {
local MName "MSTAR4w"
 matrix `olsin'=`Bo',0,0,0,0,`rmse'
local initopt init(`olsin', copy)  
 ml model lf sptobitmstard8 (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho1:) (Rho2:) (Rho3:) (Rho4:) (Sigma:) `wgt' , `mlopts' contin `nolog' ///
 `diparm' `initopt' maximize title(`MName') search(on) `robust'
local COLNAME " `COLNAME'`yvar':_cons Rho1:_cons Rho2:_cons Rho3:_cons Rho4:_cons Sigma:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Tobit MLE Multiparametric Spatio Temporal AutoRegressive Regression}}"
di as txt "{bf:{err:* (m-STAR) Spatial Durbin Weibull Model (4 Weight Matrix)}}"
di _dup(78) "{bf:{err:=}}"
 }
matrix `BetaSP'=e(b)
scalar `Rostar'=_b[/Rho1]+_b[/Rho2]+_b[/Rho3]+_b[/Rho4]
qui test [Rho1]_cons [Rho2]_cons [Rho3]_cons [Rho4]_cons
matrix `IRW'=inv(`In'-_b[/Rho1]*WMB_1-_b[/Rho2]*WMB_2-_b[/Rho3]*WMB_3-_b[/Rho4]*WMB_4)
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
if !inlist("`dist'", "weib") {
matrix `Yh_ML'=`IRW'*`Yh_ML'
 }
matrix `Ue_ML'=`Y'-`Yh_ML'
qui svmat `Yh_ML' , name(`Yh_ML')
qui rename `Yh_ML'1 `Yh_ML'
qui svmat `Ue_ML' , name(`Ue_ML')
qui rename `Ue_ML'1 `Ue_ML'
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
tempname r2v r2v_a fv fvp r2h r2h_a fh fhp SSTm SSE1 SST11 SST21 Rho
matrix `SSE'=`Ue_ML''*`Ue_ML'
scalar `SSEo'=`SSE'[1,1]
scalar `Sig2o'=`SSEo'/`DF'
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
di as txt _col(3) "Sample Size" _col(21) "=" %12.0f as res `N'
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
di _dup(78) "-"
di as res "{bf:- Sum of Rho's} = " as res %12.7f `Rostar' _col(34) "{bf:Sum must be < 1 for Stability Condition}" 
ereturn scalar kb=`kb'
ereturn scalar kx=`kx'
ereturn scalar DF=`DF'
ereturn scalar waldm=`waldm'
ereturn scalar waldmp=`waldmp'
ereturn scalar waldm_df=`waldm_df'
ereturn scalar waldr=`waldr'
ereturn scalar waldrp=`waldrp'
ereturn scalar waldr_df=`waldr_df'
Display, `level' `robust'
matrix `b'=e(b)
matrix `V'=e(V)
matrix `Cov'=e(V)
matrix `Beta'=e(b)
matrix `Beta'=`Beta'[1,1..`kb']
matrix `Bx'=`Beta'[1,1..`kx']'
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
matrix `Total'= `Bx'*`NTRWS'
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
matlist `spmfxb' , title({bf:* Beta, Total, Direct, and InDirect {bf:(Model= {err:`model'})}: {err:Linear: Marginal Effect} *}) twidth(12) border(all) lines(columns) rowtitle(Variable) format(%10.4f)
matlist `spmfxe' , title({bf:* Beta, Total, Direct, and InDirect {bf:(Model= {err:`model'})}: {err:Linear: Elasticity} *}) twidth(12) border(all) lines(columns) rowtitle(Variable) format(%10.4f)
ereturn matrix mfxlinb=`spmfxb'
ereturn matrix mfxline=`spmfxe'
 }
if inlist("`mfx'", "log") {
matrix colnames `spmfxb'= Beta(Es) Total Direct InDirect Mean
matrix colnames `spmfxe'= Beta(B) Total Direct InDirect Mean
matlist `spmfxb' , title({bf:* Beta, Total, Direct, and InDirect {bf:(Model= {err:`model'})}: {err:Log-Log: Elasticity} *}) twidth(12) border(all) lines(columns) rowtitle(Variable) format(%10.4f)
matlist `spmfxe' , title({bf:* Beta, Total, Direct, and InDirect {bf:(Model= {err:`model'})}: {err:Log-Log: Marginal Effect} *}) twidth(12) border(all) lines(columns) rowtitle(Variable) format(%10.4f)
ereturn matrix mfxlogb=`spmfxb'
ereturn matrix mfxloge=`spmfxe'
 }
di as txt " Mean of Dependent Variable =" as res _col(30) %12.4f `YMB1'
 }
matrix drop eigw WCS eVec _WB WMB
qui cap mata: mata drop *
qui cap drop spat_*
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
if inlist("`e(title)'", "MSTAR1n", "MSTAR1w") {
ml display, level(`level') neq(1) noheader diparm(Rho1, label("Rho1")) ///
   diparm(Sigma, label("Sigma"))
local PARM1 "Rho1"
di as txt " Wald Test [`PARM1'=0]:" _col(35) %9.4f as res e(waldr) as txt _col(52) "P-Value > Chi2(1)" as res _col(70) %5.4f e(waldrp)
di as txt " Acceptable Range for Rho1: " as res %6.4f minEig1 " < Rho1 < " %6.4f maxEig1
 }
if inlist("`e(title)'", "MSTAR2n", "MSTAR2w") {
ml display, level(`level') neq(1) noheader diparm(Rho1, label("Rho1")) ///
 diparm(Rho2, label("Rho2")) diparm(Sigma, label("Sigma"))
local PARM2 "Rho1+Rho2"
di as txt " Wald Test [`PARM2'=0]:" _col(35) %9.4f as res e(waldr) as txt _col(52) "P-Value > Chi2(2)" as res _col(70) %5.4f e(waldrp)
di as txt " Acceptable Range for Rho1: " as res %6.4f minEig1 " < Rho1 < " %6.4f maxEig1 
di as txt " Acceptable Range for Rho2: " as res %6.4f minEig2 " < Rho2 < " %6.4f maxEig2
 }
if inlist("`e(title)'", "MSTAR3n", "MSTAR3w") {
ml display, level(`level') neq(1) noheader diparm(Rho1, label("Rho1")) ///
 diparm(Rho2, label("Rho2")) diparm(Rho3, label("Rho3")) diparm(Sigma, label("Sigma"))
local PARM3 "Rho1+Rho2+Rho3"
di as txt " Wald Test [`PARM3'=0]:" _col(35) %9.4f as res e(waldr) as txt _col(52) "P-Value > Chi2(3)" as res _col(70) %5.4f e(waldrp)
di as txt " Acceptable Range for Rho1: " as res %6.4f minEig1 " < Rho1 < " %6.4f maxEig1 
di as txt " Acceptable Range for Rho2: " as res %6.4f minEig2 " < Rho2 < " %6.4f maxEig2 
di as txt " Acceptable Range for Rho3: " as res %6.4f minEig3 " < Rho3 < " %6.4f maxEig3
 }
if inlist("`e(title)'", "MSTAR4n", "MSTAR4w") {
ml display, level(`level') neq(1) noheader diparm(Rho1, label("Rho1")) ///
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

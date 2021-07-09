*! spautoreg V7.0 20/12/2012
*! 
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage:               http://emadstat.110mb.com/stata.htm
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

program define spautoreg , eclass 
 version 11.2
syntax varlist [aw] , [WMFile(str) Model(str) aux(str) ORDer(int 1) ///
 reset LL(real 0) INV INV2 INLambda(real 0) TWOstep dist(str) stand MFX(str) ///
 noLOG tobit LMIden LMHet LMSPac ROBust HAUSman spar(str) iter(int 100) ///
 INRho(real 0) zero level(passthru) coll PREDict(str) RESid(str) ///
 tech(str) tolog TESTs NOCONStant ols vce(passthru) LMNorm sure 2sls 3sls ///
 grids EQ(int 1) MHET(str) mvreg var2(str) diag impower(int 2) DN HET ]
gettoken yvar xvar : varlist
local varlist1 "`varlist'"
local sthlp spautoreg
local both : list yvar & xvar
if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both LHS and RHS Variables}"
di as res " LHS: `yvar'"
di as res " RHS: `xvar'"
 exit
 }
 if "`xvar'"=="" {
di
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
if "`var2'"!="" {
local varlist2 "`var2'"
 gettoken endg xvar2 : varlist2
 local both : list yvar & endg
 if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both LHS1 and LHS2 Variables}"
di as res " LHS1: `yvar'"
di as res " LHS2: `varlist2'"
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
 local both : list xvar & endg
 if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both RHS1 and LHS2 Variables}"
di as res " RHS1: `xvar1'"
di as res " LHS2: `endg'"
 exit
 }
}
if "`model'"!="" {
if !inlist("`model'", "sar", "sem", "sdm", "sac", "sararml", "gs3slsar", "sarargs") {
if !inlist("`model'", "ivtobit", "sarariv", "gs2sls", "gs2slsar", "gs3sls", "spgmm") {
di
di as err "{bf:model()} {cmd:must be:} {bf:sar, sem, sdm, sac,}"
di as err "{bf:model()} {cmd:must be:} {bf:ivtobit, sararml, sarargs, sarariv}"
di as err "{bf:model()} {cmd:must be:} {bf:spgmm, gs2sls, gs2slsar, gs3sls, gs3slsar}"
di in smcl _c "{cmd: see:} {help `sthlp'##03:Model Options}"
di in gr _c " (spautoreg Help):"
 exit
 }
 }
 }
if inlist("`model'", "sararml", "sarargs", "sarariv") {
if c(version) < 11.2 {
di as err " {bf:model(sararml, sarargs, sarariv)}"
di as txt " {bf:Requires Stata Version 11.2 or above)}"
exit
 }
}
if !inlist("`model'", "gs3sls", "gs3slsar") & "`eq'"=="" {
di
di as err " {bf:eq({it:#})} {cmd:works only with:} {bf:model({it:gs3sls, gs3slsar})}"
exit
 }
if !inlist("`model'", "gs3sls", "gs3slsar") & "`var2'"!="" {
di
di as err " {bf:var2({it:varlist})} {cmd:works only with:} {bf:model({it:gs3sls, gs3slsar})}"
exit
 }
if inlist("`model'", "gs3sls", "gs3slsar") & "`var2'"=="" {
di
di as err " {bf:var2({it:varlist})} {cmd:must be combine with:} {bf:model({it:gs3sls, gs3slsar})}"
di
di _dup(78) "{bf:{err:-}}"
di as err " {bf:if you have system of 2 Equations:}"
di as err _col(10) "{cmd:Y1 = Y2 X1 X2}"
di as err _col(10) "{cmd:Y2 = Y1 X3 X4}"
di as err " {cmd:Variables of Eq. 1 will be Dep. & Indep. Variables}"
di as err " {cmd:Variables of Eq. 2 will be Dep. & Indep. Variables in option var2( ); i.e,}"
di as err " {bf:spautoreg y1 x1 x2 , wmfile(SPWcs) model(gs3sls) var2(y2 x3 x4)} eq(1)"
di as err " {bf:spautoreg y1 x1 x2 , wmfile(SPWcs) model(gs3sls) var2(y2 x3 x4)} eq(2)"
di _dup(78) "{bf:{err:-}}"
exit
 }
 if inlist("`model'", "sem", "sac") & "`noconstant'"!="" {
di
di as err " {bf:noconstant} {cmd:cannot be combined with} {bf:model({it:sem, sac})}"
exit
 }
if !inlist("`model'", "sarariv", "gs2sls", "gs2slsar", "gs3sls", "ivtobit", "gs3slsar") & "`lmiden'"!="" {
di
di as err " {bf:lmiden} {cmd:works only with:} {bf:model({it:sarariv, gs2sls, gs2slsar, gs3sls, gs3slsar, ivtobit})}"
 exit
 }
if "`tests'"!="" {
local lmspac "lmspac"
local diag "diag"
local lmhet "lmhet"
local lmnorm "lmnorm"
local reset "reset"
if inlist("`model'", "sarariv", "gs2sls", "gs2slsar", "gs3sls", "gs3slsar", "ivtobit") {
local lmiden "lmiden"
 }
if inlist("`model'", "gs2sls", "gs2slsar", "sarariv", "ivtobit") {
local hausman "hausman"
 }
 }
if !inlist("`model'", "gs2sls", "gs2slsar", "sarariv", "ivtobit") & "`hausman'"!="" {
di
di as err " {bf:hausman} {cmd:works only with:} {bf:model({it:gs2sls, gs2slsar, ivtobit, sarariv})}"
exit
 }
 if !inlist("`model'", "gs2sls", "gs2slsar", "gs3sls", "gs3slsar", "ivtobit", "sarariv")  & "`lmiden'"!="" {
di
di as err " {bf:lmiden} {cmd:works only with:} {bf:model({it:gs2sls, gs2slsar, gs3sls, gs3slsar, ivtobit, sarariv})}"
exit
 }
 if inlist("`model'", "sem", "sac") & "`robust'"!="" {
di
di as err "{bf:robust} {cmd:cannot be used with} {bf:model({it:`model'})}"
di as err "{bf:robust} {cmd:works only with:} {bf:model({it:sar, sdm})}"
di in smcl _c "{cmd: see:} {help `sthlp'##04:Options}"
di in gr _c " (spautoreg Help):"
 exit
 } 
 if "`dist'"!="" {
if !inlist("`dist'", "norm", "exp", "weib") {
di 
di as err " {bf:dist( )} {cmd:must be:}
di as err " {bf:dist({it:norm})} {cmd:for Normal model}"
di as err " {bf:dist({it:exp})} {cmd:for Exponential model}"
di as err " {bf:dist({it:weib})} {cmd:for Weibull model}"
 exit
 }	
 }
if inlist("`model'", "sar", "sdm") & "`mhet'"!="" & inlist("`dist'", "exp", "weib") {
di 
di as err " {bf:mhet({it:varlist})} {cmd:cannot be used with} {bf:dist({it:`dist'})}"
di as err " {bf:mhet({it:varlist})} {cmd:works only with} {bf:model({it:sar, sdm})} {cmd:and} {bf:dist({it:norm})}"
 exit
 }
if !inlist("`model'", "sar", "sem", "sac", "sdm") & inlist("`dist'", "norm", "exp", "weib") {
di 
di as err " {bf:dist( )} {cmd:works only with} {bf:model({it:sar, sem, sdm, sac})}"
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
 if "`spar'"!="" {
 if !inlist("`spar'", "rho", "lam") {
di 
di as err "{bf:spar( )} {cmd:works only with:} {bf:rho}, {bf:lam}"
di in smcl _c "{cmd: see:} {help `sthlp'##04:Options}"
di in gr _c " (spautoreg Help):"
 exit
 }
 }
 if inlist("`model'", "sem") & "`spar'"=="rho" {
di
di as err " {bf:spar({it:lam})} {cmd:cannot be used with} {bf:model(`model')}"
di as err "{bf:model({it:sar, sdm, sac, sararml, sarargs, sarariv})} {cmd:work with:} {bf:spar({it:rho})} {cmd:for Rho}"
di as err "{bf:model({it:sem, sac, sararml, sarargs, sarariv})} {cmd:work with:} {bf:spar({it:lam})} {cmd:for Lambda}"
exit
 } 
if inlist("`model'", "sar", "sdm") & "`spar'"=="lam" {
di
di as err " {bf:spar({it:lam})} {cmd:cannot be used with} {bf:model(`model')}"
di as err "{bf:model({it:sar, sdm, sac, sararml, sarargs, sarariv})} {cmd:work with:} {bf:spar({it:rho})} {cmd:for Rho}"
di as err "{bf:model({it:sem, sac, sararml, sarargs, sarariv})} {cmd:work with:} {bf:spar({it:lam})} {cmd:for Lambda}"
 exit
 } 
if !inlist("`model'", "sar", "sem", "sdm", "sac", "sararml", "sarargs", "sarariv") {
if inlist("`spar'", "rho", "lam") {
di
di as err " {bf:spar( )} {cmd:cannot be used with} {bf:model(`model')}"
di as err " {bf:spar( )} {cmd:works only with} {bf:model({it:sar, sdm, sac})}"
 exit
 }
}
 if "`model'"=="sararml" {
 if "`het'" != "" {
di
di as err "{bf:het} {cmd:works only with:} {bf: model({it:sarargs, sarariv})}"
di in smcl _c "{cmd: see:} {help `sthlp'##4:Options}"
di in gr _c " (spautoreg Help):"
 exit
 }
 }
 if inlist("`model'", "sarargs", "sarariv") & "`grids'"!="" {
di
di as err "{bf:grids} {cmd:works only with:} {bf: model({it:sararml})}"
di in smcl _c "{cmd: see:} {help `sthlp'##4:Options}"
di in gr _c " (spautoreg Help):"
 exit
 } 
 if inlist(`order',1,2,3,4)==0 {
di 
di as err " {bf:order(#)} {cmd:number must be 1, 2, 3, or 4.}"
 exit
 }
tempvar absE Bw D DE DF DF1 DumE DW E XQX_ EE Eo Es Ev Ew Yh_ML Ue_ML
tempvar Hat ht LE LEo LYh2 P Q Sig2 SSE Yb Yh Yh2 Yhb Yt YY YYm YYv
tempvar SST Time tm U U2 Ue wald weit Wi Wio WS X X0 Xo XQ  Z
tempname Xb A B b B1 b1 B12 B1b B1t b2 BB2 Beta BetaSP Bm Bx R20
tempname Cov Cov1 Cov2s CovC D den DVE DVNE Dx E E1 EE1 Eg Eo Eom Ew F
tempname lmhs M M1 M2 mh nw olsin In IRW SSE SST1 SST2 V1 v1 v2 eigw WW
tempname P Phi Pm q Q Qr q1 q2 s v V1s S11 S12 Sig2 Sig2b Sig2o Sn D Xo J
tempname Vec vh VM VP VQ Vs W W1 W2 Wald We Wi Wi1 Wio WY X X0 V eVec
tempname xq Xx Y Yh Yi YYm YYv Z Z0 Z1 Zo Zr Sw Ue llf IRWR IRWL K L kbd
tempname Sig2o1 Ko Koi rRo rLm kb kb1 kb2 h Hat hjm IPhi kz Yh_ML Ue_ML
tempname minEig maxEig waldm waldmp waldm_df waldr waldrp waldr_df Dim kbm
tempname waldl waldlp waldl_df waldx waldxp waldx_df waldj waldjp waldj_df
tempname N DF kx kb NC NT Nmiss kmhet Sig21 B1B2 V1V2
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
qui foreach var of local varlist {
qui replace `var'=0 if `var'==.
 }
 }
qui gen `Time'=_n
qui tsset `Time'
 if "`tolog'"!="" {
di
di as err " {cmd:** Data Have been Transformed to Log Form **}"
di _dup(78) "-" 
di as err "{bf:** Dependent & Independent Variables}
di as txt " {cmd:** `varlist'} "
di _dup(78) "-" 
 if "`mhet'"!="" {
di as err "{bf:** Multiplicative Heteroscedasticity Variables}"
di as txt " {cmd:** `mhet'} "
di _dup(78) "-"
 }
 if "`var2'"!="" {
di as txt "{bf:** GS3SLS Variables - EQ.(2)}"
di as err " {cmd:** `varlist2'} "
di _dup(78) "-"
 }
 local vlistlog " `varlist' `varlist2' `mhet' "
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
if "`var2'"!="" {
_rmcoll `var2' , `noconstant' `coll' forcedrop
 local varlist2 "`r(varlist)'"
 }
if "`mhet'"!="" {
_rmcoll `mhet' , `noconstant' `coll' forcedrop
 local mhet "`r(varlist)'"
 }
if "`aux'"!="" {
_rmcoll `aux' , `noconstant' `coll' forcedrop
 local aux "`r(varlist)'"
 }
}
 gettoken yvar xvar  : varlist
 gettoken yvar xvar1 : varlist1
 gettoken endg xvar2 : varlist2
 local kmhet : word count `mhet'
 local kaux : word count `aux'
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
 if "`wmfile'"!="" {
tempname WS1 WS2 WS3 WS4 xyvar
mkmat `yvar' , matrix(`xyvar')
matrix `WS1'= WMB
matrix `WS2'= `WS1'*WMB
 if "`order'"=="3" {
matrix `WS3'= `WS2'*WMB
 }
 if "`order'"=="4" {
matrix `WS4'= `WS3'*WMB
 }
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
 if inlist("`model'", "gs2sls", "gs3sls", "gs2slsar", "gs3slsar") {
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

if inlist("`model'", "sarariv", "gs2sls", "gs2slsar", "ivtobit") {
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
}
 if "`coll'"=="" {
_rmcoll `zvar' , `noconstant' `coll' forcedrop
 local zvar "`r(varlist)'"
 }

 if inlist("`model'", "sararml", "sarargs", "sarariv") {
tempname  WB1 WB2 WB3 WB4
matrix `WB1'= _WB
matrix `WB2'= `WB1'*_WB
 if "`order'"=="3" {
matrix `WB3'= `WB2'*_WB
 }
 if "`order'"=="4" {
matrix `WB4'= `WB3'*_WB
 }
qui cap drop w1y_`yvar'
qui mkmat `yvar' , matrix(`yvar')
matrix w1y_`yvar' = `WB1'*`yvar'
qui svmat w1y_`yvar' , name(w1y_`yvar')
qui rename w1y_`yvar'1 w1y_`yvar'
qui label variable w1y_`yvar' `"AR(1) `yvar' Spatial Lag"'

 if "`order'"!="" {
qui local ord order
qui forvalues i = 1/`order' {
qui foreach var of local xvar1 {
qui cap drop w`i'x_`var'
tempname `var' `w`i'x_`var''
qui mkmat `var' , matrix(``var'')
qui matrix `w`i'x_`var'' = `WB`i''*``var''
qui svmat `w`i'x_`var'' , name(w`i'x_`var')
qui rename w`i'x_`var'1 w`i'x_`var'
qui label variable w`i'x_`var' `"AR(`i') `var' Spatial Lag"'
 }
 }
 }
qui tempfile WPMat
qui cap drop _ID
tempvar id
qui svmat _WB , name(__WPMat_)
qui gotoup , id(`id')
qui replace `id' = _n-1
qui replace `id' = _N-1 in 1
qui order `id'
qui outsheet `id' __WPMat_* using `WPMat'.txt, delimiter(" ") nonames nolabel replace
qui gen _ID=_n-1 
qui drop in 1
qui spmat dta WPMat __WPMat_* , id(`id') replace
qui drop __WPMat_*
qui spmat import WPMat using `WPMat'.txt, replace normalize(row)
qui spmat export WPMat using `WPMat'.txt, replace
qui spmat save WPMat using `WPMat'.spmat, replace
qui spmat drop WPMat
qui spmat use WPMat using `WPMat'.spmat
qui erase `WPMat'.txt
qui erase `WPMat'.spmat
 }
qui cap confirm numeric var `eigw'
local kaux : word count `aux'
if inlist("`model'", "gs3sls", "gs3slsar") {
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
 }
if inlist("`model'", "sar", "sem", "sac", "spgmm", "sararml", "sarargs") {
local SPXvar `xvar1' `aux'
 }
if inlist("`model'", "sarariv", "gs2sls", "gs2slsar", "ivtobit") {
unab wyxs: w1y_`yvar'
local SPXvar `wyxs' `xvar1' `aux'
 }
if inlist("`model'", "sdm") {
unab wxxs: w1x_*
local SPXvar `xvar' `wxxs' `aux'
 }
local kx2 : word count `xvar'
 if "`coll'"=="" {
_rmcoll `SPXvar' , `noconstant' `coll' forcedrop
 local SPXvar "`r(varlist)'"
 }
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
if "`dn'"!="" {
local DF=`N'
 }
global spat_kx=`kx'
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
mkmat `Wi' , matrix(`Wi')
matrix `Wi'=diag(`Wi')
scalar `llf'=.
matrix Wi=`Wi'
matrix `In'=I(`N')
if inlist("`model'", "ivtobit") {
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* IV Tobit Spatial Model (IVTobit)}}"
di _dup(78) "{bf:{err:=}}"
 yxregeq `yvar' `SPXvar'
qui ivtobit `yvar' `xvar1' `aux' (w1y_`yvar' = `zvar') `wgt' , ll(`llt') `mle' ///
 `vce' `twostep' `robust' 
scalar `llf'=e(ll)
matrix `Beta'=e(b)
matrix `Beta'=`Beta'[1,1..`kb']'
matrix `Cov'= e(V)
matrix `Cov' = `Cov'[1..`kb', 1..`kb']
scalar `rRo'=`Beta'[1,1]
matrix `Yh_ML'=`X'*`Beta'
 }

if inlist("`model'", "sararml", "sarargs", "sarariv") {
if inlist("`model'", "sararml") {
qui cap spreg ml `yvar' `xvar1' , id(_ID)
if "`e(cmd)'"!="spreg" {
di
di as err " {bf:model(sararml)} {cmd:requires Stata v11.2 and (sppack) module}"
exit
 }
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* MLE - Spatial Lag / Autoregressive Error (SARARML-MLE)}}"
di _dup(78) "{bf:{err:=}}"
 yxregeq `yvar' `SPXvar'
qui spreg ml `yvar' `xvar1' `aux' , id(_ID) dlmat(WPMat) elmat(WPMat) `grids' `noconstant'
 }

if inlist("`model'", "sarargs") {
qui cap spreg gs2sls `yvar' `xvar1' , id(_ID)
if "`e(cmd)'"!="spreg" {
di
di as err " {bf:model(sarargs)} {cmd:requires Stata v11.2 and (sppack) module}"
exit
 }
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Generalized Spatial Lag/Autoregressive Error GS2SLS (SARARGS)}}"
di _dup(78) "{bf:{err:=}}"
 yxregeq `yvar' `SPXvar'
qui spreg gs2sls `yvar' `xvar1' `aux', id(_ID) dlmat(WPMat) elmat(WPMat) `het' `noconstant'
 }

if inlist("`model'", "sarariv") {
qui cap spivreg `yvar' `xvar1' , id(_ID)
if "`e(cmd)'"!="spivreg" {
di
di as err " {bf:model(sarariv)} {cmd:requires Stata v11.2 and (sppack) module}"
exit
 }
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Generalized Spatial Lag/Autoregressive Error IV-GS2SLS (SARARIV)}}"
di _dup(78) "{bf:{err:=}}"
 yxregeq `yvar' `SPXvar'
local MName "MLESARARIV"
qui spivreg `yvar' `xvar1' `aux' (w1y_`yvar' = `zvar') , id(_ID) dlmat(WPMat) ///
 elmat(WPMat) `het' impower(`impower') `noconstant'
 }
scalar `llf'=e(ll)
matrix `Beta'=e(b)
matrix `Beta'=`Beta'[1,1..`kb']'
matrix `Cov'= e(V)
matrix `Cov'= `Cov'[1..`kb', 1..`kb']
scalar `rRo'=[rho]_b[_cons]
scalar `rLm'=[lambda]_b[_cons]
qui test [lambda]_b[_cons]=0
di as txt _col(2) "Lambda Value =" %8.4f as res `rLm' as txt _col(31) "Wald Test =" %9.3f as res r(chi2) as txt _col(54) "P-Value > Chi2(1)" _col(74) as res %5.3f r(p)
qui test [rho]_b[_cons]=0
di as txt _col(2) "Rho    Value =" %8.4f as res `rRo' as txt _col(31) "Wald Test =" %9.3f as res r(chi2) as txt _col(54) "P-Value > Chi2(1)" _col(74) as res %5.3f r(p)
matrix `IRWR' = inv(`In'-`rRo'*WMB)
matrix `IRWL' = inv(`In'-`rLm'*WMB)
matrix `Yh_ML'=`X'*`Beta'
qui cap drop _ID
qui cap spmat drop WPMat
 }

if inlist("`model'", "spgmm") {
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Spatial Autoregressive Generalized Method of Moments (SPGMM)}}"
di _dup(78) "{bf:{err:=}}"
qui cap drop Time
ereturn scalar kb=`kb'
ereturn scalar DF=`DF'
ereturn scalar Nn=`N'
 Model1 `yvar' `SPXvar' `wgt' , `noconstant' ll(`llt') `dn' `tolog' ///
 `robust' aux(`aux') `tobit' `vce' iter(`iter')
scalar `llf'=e(llf)
matrix `Beta'=e(b)
matrix `Cov'= e(V)
matrix `Beta'=`Beta'[1,1..`kb']'
matrix `Cov'=`Cov'[1..`kb', 1..`kb']
matrix `Yh_ML'=`X'*`Beta'
 } 

if inlist("`model'", "gs2sls", "gs2slsar") {
qui tsset `Time'
ereturn scalar Nn=`N'
if inlist("`model'", "gs2sls") {
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Generalized Spatial Two Stage Least Squares (GS2SLS)}}"
di _dup(78) "{bf:{err:=}}"
qui ivregress 2sls `yvar' `xvar1' `aux' (w1y_`yvar'=`xvar1' `zvar') `wgt' , `noconstant'
 }

if inlist("`model'", "gs2slsar") {
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Generalized Spatial Autoregressive Two Stage Least Squares (GS2SLSAR)}}"
di _dup(78) "{bf:{err:=}}"
local Xvar2sls `xvar1' `aux'
qui Model2 `yvar' `xvar1' `aux' , `noconstant' `dn' `coll' aux(`aux') order(`order')
 }
matrix `Beta'=e(b)
matrix `Cov'= e(V)
matrix `Beta'=`Beta'[1,1..`kb']'
matrix `Cov'=`Cov'[1..`kb', 1..`kb']
matrix `Yh_ML'=`X'*`Beta'
 }
 
if inlist("`model'", "gs3sls", "gs3slsar") {
ereturn scalar kb=`kb'
ereturn scalar Nn=`N'
if inlist("`model'", "gs3sls") {
noi di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Generalized Spatial Three Stage Least Squares (GS3SLS)}}"
noi di _dup(78) "{bf:{err:=}}"
yxregeq `yvar' `SPXvar1'
yxregeq `endg' `SPXvar2'
Model3 `yvar' `xvar1' `wgt' , `noconstant' `vce' aux(`aux') ///
 var2(`var2') order(`order') `ols' `2sls' `3sls' `sure' `mvreg' 
 }
if inlist("`model'", "gs3slsar") {
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Generalized Spatial Autoregressive Three Stage Least Squares (GS3SLSAR)}}"
di _dup(78) "{bf:{err:=}}"
di
yxregeq `yvar' `SPXvar1'
yxregeq `endg' `SPXvar2'
Model4 `yvar' `xvar1' `wgt' , `noconstant' `vce' aux(`aux') ///
 var2(`var2') order(`order') `ols' `2sls' `3sls' `sure' `mvreg' 
 }
 tempname XB1 XB2 Eu1 Eu2 X3SLS1 X3SLS2 B3SLS1 B3SLS2 X kb llf R20 DF kbc1 kbc2
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
scalar `R20'=e(r2h2)
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
scalar `R20'=e(r2h1)
matrix `X'=e(X3SLS1)
local SPXvar `SPXvar1'
matrix `Y'=e(Y1_ML)
 }
scalar `DF'=`N'-`kb'
matrix `Yh_ML'=`X'*`Beta'
if "`eq'"=="2" {
yxregeq `endg' `SPXvar2'
 }
if "`eq'"=="1" {
yxregeq `yvar' `SPXvar1'
 }
 }

if inlist("`model'", "sem", "sar", "sdm", "sac") {
tempname Bo olsin
qui regress `yvar' `SPXvar' `wgt' , `noconstant'
matrix `Bo'=e(b)
local rmse=e(rmse)
qui cap macro drop spat_*
qui cap drop spat_*
qui gen double spat_eigw= `eigw'
global spat_kx=`kx'
ereturn scalar df_m=`kx'
global spat_kx : word count `SPXvar'
qui forvalue i=1/$spat_kx {
local var : word `i' of `SPXvar'
local MODEL "`MODEL'(`var':) "
local spat_ARGS "`spat_ARGS' beta`i'" 
 }
 qui forvalue i=1/$spat_kx {
local var : word `i' of `SPXvar'
local COLNAME "`COLNAME'`yvar':`var' " 
 }
if inlist("`model'", "sem", "sac") {
local i=1
qui foreach var of local xvar {
 gen double spat_w1x_`i' = w1x_`var'
local ++i
 }
}

if inlist("`model'", "sem") {
if inlist("`model'", "sem") & !inlist("`dist'", "exp", "weib") & "`mhet'"=="" {
local MName "SEM1n"
matrix `olsin'=`Bo',`inlambda',`rmse'
local initopt init(`olsin', copy) search(on) 
matrix spat_ols=`olsin'[1,1..$spat_kx+2]
local MODEL "`MODEL'(_cons:) (Lambda:) (Sigma:)"
qui global spat_ARGS "`spat_ARGS' beta0 Lambda Sigma"
 ml model lf spautoerrnn `MODEL' `wgt' , ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize search(on) title(`MName')
local COLNAME " `COLNAME'`yvar':_cons Lambda:_cons Sigma:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* MLE Spatial Error Normal Model (SEM)}}"
di _dup(78) "{bf:{err:=}}"
 }

if inlist("`model'", "sem") & inlist("`dist'", "exp") & "`mhet'"=="" {
local MName "SEM1e"
matrix `olsin'=`Bo',`inlambda'
local initopt init(`olsin', copy) 
matrix spat_ols=`olsin'[1,1..$spat_kx+1]
local MODEL "`MODEL'(_cons:) (Lambda:)"
qui global spat_ARGS "`spat_ARGS' beta0 Lambda"
 ml model lf spautoerrne `MODEL' `wgt' , ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize search(on) title(`MName')
local COLNAME " `COLNAME'`yvar':_cons Lambda:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* MLE Spatial Error Exponential Model (SEM)}}"
di _dup(78) "{bf:{err:=}}"
 }

if inlist("`model'", "sem") & inlist("`dist'", "weib") & "`mhet'"=="" {
local MName "SEM1w"
 matrix `olsin'=`Bo',`inlambda',`rmse'
local initopt init(`olsin', copy)  
 matrix spat_ols=`olsin'[1,1..$spat_kx+2]
local MODEL "`MODEL'(_cons:) (Lambda:) (Sigma:)"
qui global spat_ARGS "`spat_ARGS' beta0 Lambda Sigma"
 ml model lf spautoerrnw `MODEL' `wgt' , ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize search(on) title(`MName')
local COLNAME " `COLNAME'`yvar':_cons Lambda:_cons Sigma:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* MLE Spatial Error Weibull Model (SEM)}}"
di _dup(78) "{bf:{err:=}}"
 }
 }

 if inlist("`model'", "sar") {
if inlist("`model'", "sar") & !inlist("`dist'", "exp", "weib") & "`mhet'"=="" {
local MName "SAR1n"
 matrix `olsin'=`Bo',`inrho',`rmse'
local initopt init(`olsin', copy)  
 ml model lf spautolagnn (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho:) (Sigma:) `wgt' , `mlopts' contin `nolog' `diparm' `initopt' ///
 maximize title(`MName') search(on) `robust'
local COLNAME " `COLNAME'`yvar':_cons Rho:_cons Sigma:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* MLE Spatial Lag Normal Model (SAR)}}"
di _dup(78) "{bf:{err:=}}"
 }

if inlist("`model'", "sar") & inlist("`dist'", "exp") & "`mhet'"=="" {
local MName "SAR1e"
 matrix `olsin'=`Bo',`inrho'
local initopt init(`olsin', copy)  
 ml model lf spautolagne (`yvar': `yvar' = `SPXvar' , `noconstant') ///
 (Rho:) `wgt' , `mlopts' contin `nolog' `diparm' `initopt' maximize ///
 title(`MName') search(on) `robust'
local COLNAME " `COLNAME'`yvar':_cons Rho:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* MLE Spatial Lag Exponential Model (SAR)}}"
di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`model'", "sar") & inlist("`dist'", "weib") & "`mhet'"=="" {
local MName "SAR1w"
 matrix `olsin'=`Bo',`inrho',`rmse'
local initopt init(`olsin', copy)  
 ml model lf spautolagnw (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho:) (Sigma:) `wgt' , `mlopts' contin `nolog' `diparm' `initopt' ///
 maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons Rho:_cons Sigma:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* MLE Spatial Lag Weibull Model (SAR)}}"
di _dup(78) "{bf:{err:=}}"
 }

 if "`model'"=="sar" & "`mhet'"!="" {
local MName "SAR1h"
qui regress `yvar' `mhet' , noconstant
tempname olshet
matrix `olshet'=e(b)
matrix `olsin'=`Bo',`olshet',`inrho',`rmse'
local initopt init(`olsin', copy) 
 ml model lf spautolaghm (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Hetero: `mhet', noconst) (Rho:) (Sigma:) `wgt', `mlopts' contin ///
 `nolog' `diparm' `initopt' maximize title(`MName') search(on) `robust'
 local COLNAME " `COLNAME'`yvar':_cons `mhet' Rho:_cons Sigma:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* MLE Spatial Lag Multiplicative Heteroscedasticity}}"
di _dup(78) "{bf:{err:=}}"
 }
matrix `IRWR' = inv(`In'-_b[/Rho]*WMB)
 }

if inlist("`model'", "sdm") {
if inlist("`model'", "sdm") & !inlist("`dist'", "exp", "weib") & "`mhet'"=="" {
local MName "SDM1n"
 matrix `olsin'=`Bo',`inrho',`rmse'
local initopt init(`olsin', copy) 
 ml model lf spautodurnn (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho:) (Sigma:) `wgt' , `mlopts' contin `nolog' `diparm' `initopt' ///
 maximize title(`MName') search(on) `robust'
local COLNAME " `COLNAME'`yvar':_cons Rho:_cons Sigma:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* MLE Spatial Durbin Normal Model (SDM)}}"
di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`model'", "sdm") & inlist("`dist'", "exp") & "`mhet'"=="" {
local MName "SDM1e"
 matrix `olsin'=`Bo',0
local initopt init(`olsin', copy)  
ml model lf spautodurne (`yvar': `yvar' = `SPXvar' , `noconstant' ) (Rho:) `wgt' , ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize title(`MName') search(on) `robust'
local COLNAME " `COLNAME'`yvar':_cons Rho:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* MLE Spatial Durbin Exponential Model (SDM)}}"
di _dup(78) "{bf:{err:=}}"
 }

 if inlist("`model'", "sdm") & inlist("`dist'", "weib") & "`mhet'"=="" {
local MName "SDM1w"
 matrix `olsin'=`Bo',`inrho',`rmse'
local initopt init(`olsin', copy) 
 ml model lf spautodurnw (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Rho:) (Sigma:) `wgt' , `mlopts' contin `nolog' `diparm' `initopt' ///
 maximize title(`MName') search(on) `robust'
local COLNAME " `COLNAME'`yvar':_cons Rho:_cons Sigma:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* MLE Spatial Durbin Weibull Model (SDM)}}"
di _dup(78) "{bf:{err:=}}"
 }

 if "`model'"=="sdm" & "`mhet'"!="" {
local MName "SDM1h"
qui regress `yvar' `mhet' , noconstant
tempname olshet
matrix `olshet'=e(b)
matrix `olsin'=`Bo',`olshet',`inrho',`rmse'
 local initopt init(`olsin', copy) 
 ml model lf spautodurhm (`yvar': `yvar' = `SPXvar' , `noconstant' ) ///
 (Hetero: `mhet', noconst) (Rho:) (Sigma:) `wgt', `mlopts' contin ///
 `nolog' `diparm' `initopt' maximize title(`MName') search(on) `robust'
local COLNAME " `COLNAME'`yvar':_cons `mhet' Rho:_cons Sigma:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* MLE Spatial Durbin Multiplicative Heteroscedasticity}}"
di _dup(78) "{bf:{err:=}}"
 }
matrix `IRWR' = inv(`In'-_b[/Rho]*WMB)
 }

if "`model'"=="sac" {
if inlist("`model'", "sac") & !inlist("`dist'", "exp", "weib") & "`mhet'"=="" {
local MName "SAC1n"
local MODEL "`MODEL'(_cons:) (Rho:) (Lambda:) (Sigma:)"
qui global spat_ARGS "`spat_ARGS' beta0 Rho Lambda Sigma"
 matrix `olsin'=`Bo',`inrho',`inlambda',`rmse'
local initopt init(`olsin', copy)  
 matrix spat_ols=`olsin'[1,1..$spat_kx+3]
 ml model lf spautosacnn `MODEL' `wgt' , ///
`mlopts' contin `nolog' `diparm' `initopt' maximize search(on) title(`MName')
 local COLNAME " `COLNAME'`yvar':_cons Rho:_cons Lambda:_cons Sigma:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* MLE Spatial AutoCorrelation Normal Model (SAC)}}"
di _dup(78) "{bf:{err:=}}"
 }

if inlist("`model'", "sac") & inlist("`dist'", "exp") & "`mhet'"=="" {
local MName "SAC1e"
local MODEL "`MODEL'(_cons:) (Rho:) (Lambda:)"
qui global spat_ARGS "`spat_ARGS' beta0 Rho Lambda"
 matrix `olsin'=`Bo',`inrho',`inlambda'
local initopt init(`olsin', copy) 
 matrix spat_ols=`olsin'[1,1..$spat_kx+2]
 ml model lf spautosacne `MODEL' `wgt' , ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize search(on) title(`MName')
local COLNAME " `COLNAME'`yvar':_cons Rho:_cons Lambda:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* MLE Spatial AutoCorrelation Exponential Model (SAC)}}"
di _dup(78) "{bf:{err:=}}"
 }

if inlist("`model'", "sac") & inlist("`dist'", "weib") & "`mhet'"=="" {
local MName "SAC1w"
local MODEL "`MODEL'(_cons:) (Rho:) (Lambda:) (Sigma:)"
qui global spat_ARGS "`spat_ARGS' beta0 Rho Lambda Sigma"
 matrix `olsin'=`Bo',`inrho',`inlambda',`rmse'
local initopt init(`olsin', copy)  
 matrix spat_ols=`olsin'[1,1..$spat_kx+3]
 ml model lf spautosacnw `MODEL' `wgt' , ///
 `mlopts' contin `nolog' `diparm' `initopt' maximize search(on) title(`MName')
local COLNAME " `COLNAME'`yvar':_cons Rho:_cons Lambda:_cons Sigma:_cons"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* MLE Spatial AutoCorrelation Weibull Model (SAC)}}"
di _dup(78) "{bf:{err:=}}"
 }
matrix `IRWR' = inv(`In'-_b[/Rho]*WMB)
matrix `IRWL' = inv(`In'-_b[/Lambda]*WMB)
 }

scalar `llf'=e(ll)
matrix `BetaSP'=e(b)
matrix `Beta'=`BetaSP'[1,1..`kb']'
matrix `Cov'= e(V)
matrix `Cov'=`Cov'[1..`kb', 1..`kb']
matrix `Yh_ML'=`X'*`Beta'
if inlist("`model'", "sdm") {
qui testparm w1x_*
scalar `waldx'=r(chi2)
scalar `waldxp'=r(p)
scalar `waldx_df'=r(df)
 }
if inlist("`model'", "sac") {
scalar `rLm'=_b[/Lambda]
scalar `rRo'=_b[/Rho]
qui test ([Rho]_b[_cons]=0) ([Lambda]_cons=0)
scalar `waldj'=r(chi2)
scalar `waldjp'=r(p)
scalar `waldj_df'=r(df)
 }
if inlist("`model'", "sem", "sac") {
scalar `rLm'=_b[/Lambda]
qui test [Lambda]_cons
scalar `waldl'=r(chi2)
scalar `waldlp'=r(p)
scalar `waldl_df'=r(df)
 }
if inlist("`model'", "sar", "sdm", "sac") {
scalar `rRo'=_b[/Rho]
qui test [Rho]_b[_cons]
scalar `waldr'=r(chi2)
scalar `waldrp'=r(p)
scalar `waldr_df'=r(df)
 }
ereturn scalar df_m=$spat_kx
if inlist("`model'", "sem", "sac") & "`noconstant'"=="" {
matrix colnames `BetaSP'=`COLNAME'
 } 
ereturn repost b=`BetaSP' , rename
matrix `BetaSP'=e(b)
scalar `waldm'=e(chi2)
scalar `waldmp'=e(p)
scalar `waldm_df'=e(df_m)
ereturn scalar df_m=$spat_kx
ereturn scalar k_aux=2
if inlist("`model'", "sem") & !inlist("`dist'", "exp") {
ereturn scalar k_eq=3
ereturn scalar k_aux=1
 }
if inlist("`model'", "sem") & inlist("`dist'", "exp") {
ereturn scalar k_eq=2
ereturn scalar k_aux=1
 }
if inlist("`model'", "sac") & inlist("`dist'", "exp") {
ereturn scalar k_eq=3
ereturn scalar k_aux=2
 }
if inlist("`model'", "sac") & !inlist("`dist'", "exp") {
ereturn scalar k_eq=4
ereturn scalar k_aux=2
 }
 }
if inlist("`model'", "sar", "sdm", "sac", "sararml", "sarargs", "sarariv") {
matrix `IRW' = `IRWR'
if inlist("`spar'", "lam") {
matrix `IRW' = `IRWL'
 }
matrix `Yh_ML'=`IRW'*`Yh_ML'
 }
if inlist("`model'", "sem") {
matrix `Yh_ML'=`X'*`Beta'
 }
if inlist("`model'", "sar", "sdm", "sac") & inlist("`dist'","exp") {
matrix `Yh_ML'=`X'*`Beta'
 }
qui svmat `Yh_ML' , name(`Yh_ML')
qui rename `Yh_ML'1 `Yh_ML'
qui gen `Ue_ML' =`yvar'-`Yh_ML'
matrix `Ue_ML'=`Y'-`Yh_ML'
matrix `E'=`Ue_ML'
local N=_N
if "`predict'"!= "" {
qui cap drop `predict'
qui gen `predict'=`Yh_ML'
label variable `predict' `"Yh_`model' - Prediction"'
 }
if "`resid'"!= "" {
qui cap drop `resid'
qui gen `resid'=`Ue_ML'
label variable `resid' `"U_`model' - Residual"'
 }
tempname SSEo Sigo r2bu r2bu_a r2raw r2raw_a R20 f fp wald waldp Sig2n
tempname r2v r2v_a fv fvp r2h r2h_a fh fhp SSTm SSE1 SST11 SST21 Rho
matrix `SSE'=`E''*`E'
scalar `SSEo'=`SSE'[1,1]
scalar `Sig2o'=`SSEo'/`DF'
scalar `Sigo'=sqrt(`Sig2o')
scalar `Sig2n'=`SSEo'/`N'
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
scalar `R20'=`r2bu'
scalar `f'=`R20'/(1-`R20')*(`N'-`kb')/`kx'
scalar `fp'= Ftail(`kx', `DF', `f')
scalar `wald'=`f'*`kx'
scalar `waldp'=chi2tail(`kx', abs(`wald'))
if `llf' == . {
scalar `llf'=-(`N'/2)*log(2*_pi*`Sig2n')-(`N'/2)
 }
 if "`weight'"!="" {
tempname Ew SSEw SSEw1 Sig2wn LWi21 LWi2
matrix `Ew'=`Wi'*(`Y'-`X'*`Beta')
matrix `SSEw'=(`Ew''*`Ew')
scalar `SSEw1'=`SSEw'[1,1]
scalar `Sig2wn'=`SSEw1'/`N'
qui gen `LWi2'= 0.5*ln(`Wi'^2)
qui summ `LWi2'
scalar `LWi21'=r(sum)
scalar `llf'=-`N'/2*ln(2*_pi*`Sig2wn')+`LWi21'-(`N'/2)
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
if !inlist("`model'", "gs3sls", "gs3slsar") {
yxregeq `yvar' `SPXvar'
 }
di as txt _col(3) "Sample Size" _col(21) "=" %12.0f as res `N' _col(37) "|" _col(41) as txt "Cross Sections Number" _col(65) "=" _col(73) %5.0f as res `nc'
if !inlist("`model'", "sem", "sar", "sdm", "sac") {
ereturn post `B' `Cov' , dep(`yvar') obs(`Nof') dof(`Dof')
qui test `SPXvar'
scalar `f'=r(F)
scalar `fp'= Ftail(`kx', `DF', `f')
scalar `wald'=`f'*`kx'
scalar `waldp'=chi2tail(`kx', abs(`wald'))
 }
if inlist("`model'", "sar", "sdm") & "`robust'"!="" {
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
ereturn scalar kmhet=`kmhet'
ereturn scalar kb=`kb'
ereturn scalar kx=`kx'
ereturn scalar DF=`DF'
ereturn scalar Nn=_N
ereturn scalar R20=`R20'
if inlist("`model'", "sar", "sem", "sdm", "sac") {
qui cap confirm numeric var `eigw'
qui summ `eigw'
ereturn scalar minEig=1/r(min)
ereturn scalar maxEig=1/r(max)
 }
if inlist("`model'", "sar", "sdm", "sac") {
ereturn scalar waldr=`waldr'
ereturn scalar waldrp=`waldrp'
ereturn scalar waldr_df=`waldr_df'
 }
if inlist("`model'", "sem", "sac") {
ereturn scalar waldl=`waldl'
ereturn scalar waldlp=`waldlp'
ereturn scalar waldl_df=`waldl_df'
 }
if inlist("`model'", "sdm") {
ereturn scalar waldx=`waldx'
ereturn scalar waldxp=`waldxp'
ereturn scalar waldx_df=`waldx_df'
 }
if inlist("`model'", "sac") {
ereturn scalar waldj=`waldj'
ereturn scalar waldjp=`waldjp'
ereturn scalar waldj_df=`waldj_df'
 }
if !inlist("`model'", "sar", "sem", "sac", "sdm") {
ereturn display , `level'
 }
if inlist("`model'", "sar", "sem", "sac", "sdm") {
 Display , `level' `robust'
 }
if "`hausman'"!= "" {
tempname biv2 viv2
matrix `biv2'=e(b)
matrix `viv2'=e(V)
 }
matrix `b'=e(b)
matrix `V'=e(V)
matrix `Cov'=e(V)
matrix `Beta'=e(b)
matrix `Beta'=`Beta'[1,1..`kb']
matrix `Bx'=`Beta'[1,1..`kx']'
if inlist("`model'", "gs2sls", "gs2slsar", "gs3sls", "gs3slsar") {
qui test _b[w1y_`yvar']=0
scalar `Rho'=_b[w1y_`yvar']
di as txt _col(3) "Rho Value  =" %8.4f as res `Rho' as txt _col(30) "F Test =" %10.3f as res r(F) as txt _col(52) "P-Value > F(" r(df) ", " r(df_r) ")" _col(73) %5.4f as res r(p)
di _dup(78) "-"
 }
if inlist("`model'", "gs2sls", "gs2slsar", "ivtobit", "sarariv") {
di as txt "{bf:* Y  = LHS Dependent Variable:}" _col(33) " " 1 " = " "`yvar'"
di as txt "{bf:* Yi = RHS Endogenous Variables:}"_col(33) " " 1 " = " "w1y_`yvar'"
di as txt "{bf:* Xi = RHS Exogenous Vars:}"_col(33) " " `kx2' " = " "`xvar'"
di as txt "{bf:* Z  = Overall Instrumental Variables:}"
qui _rmcoll `xvar1' `zvar' , `noconstant' `coll' forcedrop
local einsts "`r(varlist)'"
local kinst : word count `einsts'
di as txt "   " `kinst' " : " "`einsts'"
di _dup(78) "-"
 }

if "`model'"!="" & "`diag'"!= "" {
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Model Selection Diagnostic Criteria - Model= ({bf:{err:`model'}})}}"
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

if "`model'"!="" & "`lmspac'"!= "" {
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
di as txt "{bf:{err:*** Spatial Aautocorrelation Tests - Model= ({bf:{err:`model'}})}}"
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

if "`model'"!="" & "`lmhet'"!= "" {
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
di as txt "{bf:{err:* Heteroscedasticity Tests - Model= ({bf:{err:`model'}})}}"
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
di _dup(78) "-"
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

if "`model'"!="" & "`lmnorm'"!="" {
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
di as txt "{bf:{err:* Non Normality Tests - Model= ({bf:{err:`model'}})}}"
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

if "`tests'" != "" {
tempname K B XBM XB E CDF PDF E2 Sig XBs Es CDFs PDFs Eg Gz Eg3 Eg4
tempname ImR D0 D1 DB DS U3 U4 M1 M2 DB0 XBX SigV SigV2 Yh SigM H kxt
tempvar EXwXw AM SSE YYR R2Raw
qui tsset `Time'
scalar `kxt' = `kx'
if inlist("`model'", "gs2slsar") {
scalar `kxt' = `kx'-1
 }
qui tobit `yvar' `SPXvar' `wgt' , nolog ll(`llt') `noconstant' `coll'
qui predict `XBX' , xb
local k = `kxt'
qui gen `SigV'=_b[/sigma]
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
qui tobit `yvar' `SPXvar' `wgt' , nolog ll(`llt') `noconstant' `coll'
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
di as txt "{bf:{err:*** Tobit Heteroscedasticity LM Tests Model= ({bf:{err:`model'}})}}"
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
di as txt "{bf:{err:*** Tobit Non Normality LM Tests - Model= ({bf:{err:`model'}})}}"
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

 if "`model'"!="" & "`reset'"!= "" {
tempvar E E2 Yh Yh2 Yh3 Yh4 SSi SCi SLi CLi WL WS XQX_ Yhr
tempname k0 rim
qui tsset `Time'
qui gen `E' =`Ue_ML' 
qui gen `Yh'=`Yh_ML'
qui gen `E2'=`Ue_ML'^2
qui summ `Yh' `wgt'
scalar YMin = r(min)
scalar YMax = r(max)
qui gen `WL'=_pi*(2*`Yh'-(YMax+YMin))/(YMax-YMin) 
qui gen `WS'=2*_pi*(sin(`Yh_ML')^2)-_pi 
qui forvalue j =1/`kx' {
qui foreach i of local SPXvar {
tempvar vn
gen `vn'`j'=`i' 
qui cap drop `XQX_'`i'
qui gen `XQX_'`i' = `vn'`j'*`vn'`j'
 }
 }
qui regress `E2' `SPXvar' `XQX_'*
local LMW=e(N)*e(r2)
local LMWp= chi2tail(2, abs(`LMW'))
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:*** {bf:{err:RE}}gression {bf:{err:S}}pecification {bf:{err:E}}rror {bf:{err:T}}ests (RESET) - Model= ({bf:{err:`model'})}}"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf: Ho: Model is Specified  -  Ha: Model is Misspecified}"
di _dup(78) "-"
di as txt "{bf:* Ramsey Specification ResetF Test}"
forvalue i=2/4 {
tempvar Yhrm`i'
qui gen `Yhr'`i'=`Yh'^`i' 
if "`noconstant'"!="" {
qui regress `yvar' `SPXvar' `Yhr'* , noconstant noomitted
scalar `k0'=0
 }
else {
qui regress `yvar' `SPXvar' `Yhr'* , noomitted
 scalar `k0'=1
 }
qui predict `Yhrm`i'' , xb
qui correlate `Yhrm`i'' `yvar' 
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
qui gen `SLi'`i'=sin(`i'*`WL')
qui gen `CLi'`i'=sin(`i'*`WL'+_pi/2)
if "`noconstant'"!="" {
qui regress `yvar' `SPXvar' `SLi'* `CLi'* , noomitted noconstant
 }
else {
qui regress `yvar' `SPXvar' `SLi'* `CLi'* , noomitted
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
qui regress `yvar' `SPXvar' `SSi'* `SCi'* , noomitted noconstant
 }
 else {
qui regress `yvar' `SPXvar' `SSi'* `SCi'* , noomitted
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
 }
 if "`order'"=="1" {
local zvar w1x_*
 }
 if "`order'"=="2" {
local zvar w1x_* w2x_*
 }
 if "`order'"=="3" {
local zvar w1x_* w2x_* w3x_*
 }
 if "`order'"=="4" {
local zvar w1x_* w2x_* w3x_* w4x_*
 }
 if "`coll'"=="" {
_rmcoll `zvar' , `noconstant' `coll' forcedrop
 local zvar "`r(varlist)'"
 }

if inlist("`model'", "gs2sls", "gs2slsar", "sarariv", "ivtobit") & "`hausman'"!="" {
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:*** Hausman Specification Test {bf:({err:OLS}} vs {bf:{err:IV-2SLS}) - Model (`model')}}"
di
di as txt "{bf: Ho: (Biv) Consistent  * Ha: (Bo) InConsistent}"
di as txt "{bf: LM = (Bo-Biv)'inv(Vo-Viv)*(Bo-Biv)}"
di as txt "{bf: [Low/(High*)] Hausman Test = [Biv/(Bo*)] Model}"
qui tsset `Time'
tempname kxk DFr lmhs1 lmhsp
qui regress `yvar' `SPXvar' `wgt' , `noconstant' `vce' `level'
scalar `kxk' =`kx'
matrix `b1'=e(b)'
matrix `v1'=e(V)
matrix `b1'=`b1'[1..`kxk', 1..1]
matrix `v1'=`v1'[1..`kxk', 1..`kxk']
matrix `b2'=`biv2''
matrix `b2'=`b2'[1..`kxk', 1..1]
matrix `v2'=`viv2'[1..`kxk', 1..`kxk']
matrix `B1B2'=`b2'-`b1'
matrix `V1V2'=`v2'-`v1'
matrix `lmhs'=`B1B2''*invsym(`V1V2')*`B1B2'
scalar `lmhs1'=`lmhs'[1,1]
scalar `lmhsp'= chi2tail(1, abs(`lmhs1'))
di
di as txt " Hausman LM Test " _col(15) "=" %10.5f as res `lmhs1' _col(35) as txt "P-Value > Chi2(1)" _col(55) as res %5.4f as res `lmhsp'
ereturn scalar lmhs=`lmhs1'
ereturn scalar lmhsp= `lmhsp'
di _dup(78) "-"
 }

if inlist("`model'", "gs2sls", "gs2slsar", "gs3sls", "gs3slsar", "ivtobit", "sarariv") & "`lmiden'"!="" {
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:*** Identification Restrictions LM Tests - Model= ({bf:{err:`model'}})}}"
di _dup(78) "{bf:{err:=}}"
di as res "{bf:Ho: Valid Included & Excluded Instruments ; RHS Not Correlated with Error Term}"
di
tempvar uiv
tempname Z DFr
qui ivregress 2sls `yvar' `xvar' (w1y_`yvar' = `zvar') `wgt' , `noconstant'
qui predict `uiv' , res
local insts = e(insts)
mkmat `xvar' , matrix(`Z')
qui cap local kexog=colsof(`Z')
mkmat `xvar' `zvar' , matrix(`Z')
qui cap local kinst=colsof(`Z')
local sgp=`kinst'-`kexog'
qui regress `uiv' `xvar' `zvar' , `noconstant'
local lms=e(N)*e(r2)
scalar `DFr' =e(N)-`kb'
local lmb =`lms'*`DFr'/(e(N)-`lms')
local lmbp= chi2tail(`sgp', abs(`lmb'))
local lmsp= chi2tail(`sgp', abs(`lms'))
di as txt "{bf:** Y  = LHS Dependent Variable}
di as txt "   " 1 " : " "`yvar'"
di as txt "{bf:** Yi = RHS Endogenous Variables}
di as txt "   " 1 " : " "w1y_`yvar'"
di as txt "{bf:** Xi = RHS Included Exogenous Variables}"
di as txt "   " `kexog' " : " "`xvar1'"
di as txt "{bf:** Z  = Overall Exogenous Variables}"
di as txt "   " `kinst' " : " "`insts'"
di
di as txt "- Sargan  LM Test = " as res %9.4f `lms' _col(35) as txt "P-Value > Chi2(" as res `sgp' ")" _col(55) as res %5.4f `lmsp' 
di as txt "- Basmann LM Test = " as res %9.4f `lmb' _col(35) as txt "P-Value > Chi2(" as res `sgp' ")" _col(55) as res %5.4f `lmbp' 
ereturn scalar lmb = `lmb'
ereturn scalar lms = `lms'
ereturn scalar lmbp= chi2tail(`sgp', abs(`lmb'))
ereturn scalar lmsp= chi2tail(`sgp', abs(`lms'))
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
if inlist("`model'", "sar", "sdm", "sac","sararml","sarargs","sarariv") {
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
 }
if !inlist("`model'", "sar", "sdm", "sac","sararml","sarargs","sarariv") {
if inlist("`mfx'", "lin") {
matrix `spmfxb' =`Bx'
matrix `spmfxe'=vecdiag(`Bx'*`XYMB'')'
matrix `mfxlin' =`spmfxb',`spmfxe',`XMB'
mat rownames `mfxlin' = `SPXvar'
mat colnames `mfxlin' = Marginal_Effect(B) Elasticity(Es) Mean
matlist `mfxlin' , title({bf:* Marginal Effect - Elasticity {bf:(Model= {err:`model'})}: {err:Linear} *}) twidth(10) border(all) lines(columns) rowtitle(Variable) format(%18.4f)
ereturn matrix mfxlin=`mfxlin'
 }
if inlist("`mfx'", "log") {
matrix `spmfxe'=`Bx'
matrix `spmfxb'=vecdiag(`Bx'*`XYMB'')'
matrix `mfxlog' =`spmfxe',`spmfxb',`XMB'
matrix rownames `mfxlog' = `SPXvar'
matrix colnames `mfxlog' = Elasticity(Es) Marginal_Effect(B) Mean
matlist `mfxlog' , title({bf:* Elasticity - Marginal Effect {bf:(Model= {err:`model'})}: {err:Log-Log} *}) twidth(10) border(all) lines(columns) rowtitle(Variable) format(%18.4f)
ereturn matrix mfxlog=`mfxlog'
 }
 }
di as txt " Mean of Dependent Variable =" as res _col(30) %12.4f `YMB1'
 }
 }
qui cap matrix drop _all
qui cap mata: mata drop *
qui cap drop spat_*
qui sort `Time'
end

program define Model1 , eclass 
 version 11.0
 syntax varlist [aw iw] , [NOCONStant vce(passthru) DN ///
 ROBust aux(str) tobit coll iter(int 100) tolog LL(str)]
tempvar `varlist'
gettoken yvar xvar : varlist
qui {
preserve
tempvar E E2 SSE Ue_ML X0  varx vary Time varx
tempname E E2 EG EG2 h1 h1t h2 h2t h3 h3t HH11 HH12 HH13 HH21 HH22 HH23 HH31 HH32
tempname HH33 HHy1 HHy2 HHy3 hy hyt MMM Rho RhoGMM SSE SSEs Ug Ug2 Uh Uh2 Uh2m UVh
tempname UVhm UWh UWhm V1 V2 V3 Vh Vh2 Vh2m VWh VWhm W1X W2h W2hm W2X Wh WY WYsv
tempname WYv WX0 XB Z ZZ Uh wmat varx vary X0 X B Beta Cov Sig2
tempname Wi Wi Y var kb N DF
scalar `kb'=e(kb)
scalar `N'=e(Nn)
scalar `DF'=e(DF)
matrix `wmat'=WMB
matrix `Wi'=Wi
qui gen `Time'=_n
qui gen `X0'=1
 if "`tobit'"!="" {
local llt=spat_llt 
qui tobit `yvar' `xvar' `aux' `wgt' , `noconstant' `vce' ll(`llt')
tempvar yhat
qui predict `yhat' , xb
qui gen `E'=`yvar'-`yhat'
 }
else { 
qui regress `yvar' `xvar' `aux' `wgt' , `noconstant' `vce'
 predict `E' , resid
 }
 gen `E2'=`E'^2 
 matrix `wmat'=WMB
 mkmat `E' , mat(`Uh')
matrix `Vh'=`wmat'*`Uh'
matrix `Wh'=`wmat'*`Vh'
 svmat `Uh', name(`Uh')
 svmat `Vh', name(`Vh')
 svmat `Wh', name(`Wh')
 gen `Uh2'=`Uh'1*`Uh'1 
 gen `Vh2'=`Vh'1*`Vh'1 
 gen `UVh'=`Uh'1*`Vh'1 
 gen `VWh'=`Vh'1*`Wh'1 
 gen `W2h'=`Wh'1*`Wh'1 
 gen `UWh'=`Uh'1*`Wh'1 
matrix `MMM'=trace(`wmat''*`wmat')/`N'
 egen `Uh2m' = mean(`Uh2') 
 egen `Vh2m' = mean(`Vh2') 
 egen `UVhm' = mean(`UVh') 
 egen `VWhm' = mean(`VWh') 
 egen `W2hm' = mean(`W2h') 
 egen `UWhm' = mean(`UWh') 
 gen `HH11'=-2*`UVhm' 
 gen `HH12'=`Vh2m' 
 gen `HH13'=-1 
 gen `HH21'=-2*`VWhm' 
 gen `HH22'=`W2hm' 
 gen `HH23'=-trace(`MMM') 
 gen `HH31'=-(`Vh2m'+`UWhm') 
 gen `HH32'=`VWhm' 
 gen `HH33'=0 
 gen `HHy1'=-`Uh2m' 
 gen `HHy2'=-`Vh2m' 
 gen `HHy3'=-`UVhm' 
qui forvalues i = 1/3 {
qui forvalues j = 1/3 {
qui sum `HH`i'`j'' 
tempname h`i'`j'
scalar `h`i'`j''=r(mean)
qui sum `HHy`i''
tempname hy`i' 
scalar `hy`i''=r(mean)
 }
}
matrix `h1t'=`h11',`h21',`h31'
matrix `h2t'=`h12',`h22',`h32'
matrix `h3t'=`h13',`h23',`h33'
matrix `hyt'=`hy1',`hy2',`hy3'
matrix `h1'=`h1t''
matrix `h2'=`h2t''
matrix `h3'=`h3t''
matrix `hy'=`hyt''
matrix `RhoGMM'=`h1',`h2',`h3',`hy'
 svmat `h1', name(`V1')
 svmat `h2', name(`V2')
 svmat `h3', name(`V3')
 svmat `hy', name(`Z')
 rename `V1'1 `V1'
 rename `V2'1 `V2'
 rename `V3'1 `V3'
 rename `Z'1 `Z'
qui nl (`Z'=`V1'*{Rho}+`V2'*{Rho}^2+`V3'*{Sigma2}) , init(Rho 0.5 Sigma2 1) nolog
scalar `Rho'=_b[/Rho]
mkmat `yvar' , matrix(`Y')
matrix `Y'=`Y'-`Rho'*`wmat'*`Y'
mkmat `X0' , matrix(`X0')
matrix `X0'=`X0'-`Rho'*`wmat'*`X0'
qui foreach var of local xvar {
mkmat `var' , matrix(`var')
matrix `var'=`var'-`Rho'*`wmat'*`var'
svmat `var' , name(`varx')
qui cap drop `varx'_`var'
 rename `varx'1 `varx'_`var'
}
if "`noconstant'"!="" {
 mkmat `varx'_* , matrix(`X')
 }
 else { 
 mkmat `varx'_* , matrix(`X')
matrix `X'=`X', `X0'
 }
matrix `Beta'=invsym(`X''*`X')*`X''*`Y'
matrix `E'=(`Y'-`X'*`Beta')
matrix `Sig2'=`E''*`E'/`DF'
matrix `Cov'=`Sig2'*invsym(`X''*`X')
 }
matrix `Beta'=`Beta''
if "`noconstant'"!="" {
matrix colnames `Cov' = `xvar'
matrix rownames `Cov' = `xvar'
matrix colnames `Beta'= `xvar'
 }
 else { 
matrix colnames `Cov' = `xvar' _cons
matrix rownames `Cov' = `xvar' _cons
matrix colnames `Beta'= `xvar' _cons
 }
local Nof =`N'
local Dof =`DF'
matrix `B'=`Beta'
ereturn post `B' `Cov' , dep(`yvar') obs(`Nof') dof(`Dof')
restore
end

program define Model2 , eclass 
 version 11.0
syntax varlist , [NOCONStant DN aux(str) order(int 1) coll]
tempvar `varlist'
gettoken yvar xvar1 : varlist
qui {
preserve
tempname E E2 EG EG2 h1 h1t h2 h2t h3 h3t HH11 HH12 HH13 HH21 HH22 HH23 HH31 HH32
tempname HH33 HHy1 HHy2 HHy3 hy hyt MMM Rho SSE SSEs Ug Ug2 Uh Uh2 Uh2m UVh
tempname UVhm UWh UWhm V1 V2 V3 Vh Vh2 Vh2m VWh VWhm W1X W2h W2hm W2X Wh WY WYsv
tempname WYv WX0 XB Xsv Xv Y Yh YHb Ysv Yv Z Zsv0 Zv0 Uh YHb X0
tempvar E E2 SSE Yh Ys WYs _Cons Yh_ML Y Ue_ML X0 varx vary E Time
tempname WS1 WS2 WS3 WS4 varx vary wmat Wi E kb N 
scalar `kb'=e(kb)
scalar `N'=e(Nn)
matrix `wmat'=WMB
matrix `Wi'=Wi
qui gen `Time' =_n 
qui tsset `Time'
qui cap drop w1x_*
qui cap drop w2x_*
qui cap drop w1y_*
 gen `X0' =1
 mkmat `X0' , mat(`X0')
 matrix `wmat'=WMB
 mkmat `yvar' , matrix(`yvar')
 matrix w1y_`yvar' = `wmat'*`yvar'
 svmat w1y_`yvar' , name(w1y_`yvar')
 rename w1y_`yvar'1 w1y_`yvar'
 svmat `X0', name(`_Cons')
 rename `_Cons'1 `_Cons'
matrix `WS1'= `wmat'
matrix `WS2'= `wmat'*`wmat'
matrix `WS3'= `wmat'*`wmat'*`wmat'
matrix `WS4'= `wmat'*`wmat'*`wmat'*`wmat'
if "`order'"!="" {
qui forvalues i = 1/`order' {
qui foreach var of local xvar1 {
qui cap drop w`i'x_`var'
mkmat `var' , matrix(`var')
matrix w`i'x_`var' = `WS`i''*`var'
svmat w`i'x_`var' , name(w`i'x_`var')
rename w`i'x_`var'1 w`i'x_`var'
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
 if "`coll'"=="" {
_rmcoll `zvar' , `noconstant' `coll' forcedrop
 local zvar "`r(varlist)'"
 }
qui ivregress 2sls `yvar' `xvar1' `aux' (w1y_`yvar'=`xvar1' `zvar') `wgt' , `noconstant' small
qui predict `E' , res
qui gen `E2'=`E'^2 
qui egen `SSE'=sum(`E2') 
qui summ `E2' 
 mkmat `E' , mat(`Uh')
matrix `Vh'=`wmat'*`Uh'
matrix `Wh'=`wmat'*`Vh'
 svmat `Uh', name(`Uh')
 svmat `Vh', name(`Vh')
 svmat `Wh', name(`Wh')
 gen `Uh2'=`Uh'1*`Uh'1 
 gen `Vh2'=`Vh'1*`Vh'1 
 gen `UVh'=`Uh'1*`Vh'1 
 gen `VWh'=`Vh'1*`Wh'1 
 gen `W2h'=`Wh'1*`Wh'1 
 gen `UWh'=`Uh'1*`Wh'1 
matrix `MMM'=trace(`wmat''*`wmat')/_N
 egen `Uh2m' = mean(`Uh2') 
 egen `Vh2m' = mean(`Vh2') 
 egen `UVhm' = mean(`UVh') 
 egen `VWhm' = mean(`VWh') 
 egen `W2hm' = mean(`W2h') 
 egen `UWhm' = mean(`UWh') 
 gen `HH11'=-2*`UVhm' 
 gen `HH12'=`Vh2m' 
 gen `HH13'=-1 
 gen `HH21'=-2*`VWhm' 
 gen `HH22'=`W2hm' 
 gen `HH23'=-trace(`MMM') 
 gen `HH31'=-(`Vh2m'+`UWhm') 
 gen `HH32'=`VWhm' 
 gen `HH33'=0 
 gen `HHy1'=-`Uh2m' 
 gen `HHy2'=-`Vh2m' 
 gen `HHy3'=-`UVhm' 
qui forvalues i = 1/3 {
qui forvalues j = 1/3 {
qui sum `HH`i'`j'' 
tempname h`i'`j'
scalar `h`i'`j''=r(mean)
qui sum `HHy`i''
tempname hy`i' 
scalar `hy`i''=r(mean)
 }
 }
matrix `h1t'=`h11',`h21',`h31'
matrix `h2t'=`h12',`h22',`h32'
matrix `h3t'=`h13',`h23',`h33'
matrix `hyt'=`hy1',`hy2',`hy3'
matrix `h1'=`h1t''
matrix `h2'=`h2t''
matrix `h3'=`h3t''
matrix `hy'=`hyt''
 svmat `h1', name(`V1')
 svmat `h2', name(`V2')
 svmat `h3', name(`V3')
 svmat `hy', name(`Z')
 rename `V1'1 `V1'
 rename `V2'1 `V2'
 rename `V3'1 `V3'
 rename `Z'1 `Z'
qui nl (`Z'=`V1'*{Rho}+`V2'*{Rho}^2+`V3'*{Sigma2}) , init(Rho 0.7 Sigma2 1) nolog
scalar `Rho'=_b[/Rho]
mkmat `yvar' , matrix(`yvar')
matrix `yvar'=`yvar'-`Rho'*`wmat'*`yvar'
 svmat `yvar' , name(`vary')
replace `yvar'=`vary'1
matrix w1y_`yvar'=`wmat'*`yvar'
qui cap drop w1y_`yvar'
 svmat w1y_`yvar' , name(w1y_`yvar')
rename w1y_`yvar'1 w1y_`yvar'
mkmat `X0' , mat(`X0')
matrix `X0'=`X0'-`Rho'*`wmat'*`X0'
tempname _Cons
qui cap drop _Cons
 svmat `X0' , name(`_Cons')
 rename `_Cons'1 _Cons
foreach var of local xvar1 {
mkmat `var' , matrix(`var')
matrix `var'=`var'-`Rho'*`wmat'*`var'
svmat `var' , name(`varx')
qui cap drop `var'
rename `varx'1 `var'
 } 
local `xvar1' `var'*
 }
if "`order'"!="" {
qui forvalues i = 1/`order' {
qui foreach var of local xvar1 {
qui cap drop w`i'x_`var'
matrix w`i'x_`var' = `WS`i''*`var'
svmat w`i'x_`var' , name(w`i'x_`var')
rename w`i'x_`var'1 w`i'x_`var'
 }
 }
 }
 if "`order'"=="1" {
local zvar w1x_* `aux'
qui cap drop w2x_*
qui cap drop w3x_*
qui cap drkp w4x_*
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
 if "`coll'"=="" {
_rmcoll `zvar' , `noconstant' `coll' forcedrop
 local zvar "`r(varlist)'"
 }
if "`noconstant'"!="" {
qui ivregress 2sls `yvar' `xvar1' `aux' (w1y_`yvar' = `xvar1' `aux' `zvar') `wgt' , ///
 noconstant small
 }
 else {
qui ivregress 2sls `yvar' `xvar1' `aux' _Cons (w1y_`yvar'=_Cons `aux' `xvar1' `zvar') ///
 `wgt' , noconstant small
 }
restore
end

program define Model3 , eclass byable(onecall)
version 11.0
syntax varlist [aw iw] , [NOCONStant vce(passthru) var2(str) aux(str) ///
EQ(int 1) ORDer(int 2) ols 2sls 3sls sure mvreg]
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
tempname X0 E1 E2 y1 y2 wy1 wy2 wmat w1x w2x w3x w4x Es1 Es2 Y Ev E W BS
tempname aic sc PF yvar1 endg2 B3SLS1 B3SLS2 YMAT RSQ SSE1 SSE2 SSE3 Omega
tempname MSS1 MSS2 Sig Sig21 MSS3 SST1 SST2 SST3 Ybv Yb Yv Yb_Y1 Yb_Y2 Sig2
tempname YM RS1 RS2 RS3 kz k1 k2 Ro ADR F kb2 K Q DF1 DF2 DFF DFChi LSig2
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
 `wgt', endog(`yvar' `endg' w1y_`yvar' w1y_`endg') exog(`xvar' `zvar') ///
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
di _dup(78) "{bf:-}"
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

program define Model4 , eclass byable(onecall)
version 11.0
syntax varlist [aw iw] , [NOCONStant vce(passthru) var2(str) aux(str) ///
coll EQ(int 1) ORDer(int 2) ols 2sls 3sls sure mvreg]
tempvar `varlist1'
tempvar `varlist2'
local varlist1 `varlist'
local varlist2 `var2'
gettoken yvar xvar1 : varlist1
gettoken endg xvar2 : varlist2
local xvarx1 : list xvar1 & xvar2
local xvarx2 `"`xvar1' `xvar2'"'
local xvar : list xvarx2-xvarx1
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
qui {
tempvar X0 E1 E2 y1 y2 wy1 wy2 Time _cons1 _cons2
tempname X0 E1 E2 y1 y2 wy1 wy2 wmat w1x w2x w3x w4x N X3SLS1 X3SLS2
scalar `N'=e(Nn)
qui gen `Time' =_n 
qui tsset `Time'
qui cap drop w1x_*
qui cap drop w2x_*
qui cap drop w3x_*
qui cap drop w4x_*
matrix `wmat'=WMB
gen `y1'=`yvar'
gen `y2'=`endg'
gen `X0'=1
mkmat `X0', matrix(`X0')
mkmat `yvar' , matrix(`y1')
mkmat `endg' , matrix(`y2')
matrix `wy1' = `wmat'*`y1'
matrix `wy2' = `wmat'*`y2'
svmat  `wy1', name(`wy1')
svmat  `wy2', name(`wy2')
cap rename `wy1'1 `wy1'
cap rename `wy2'1 `wy2'
 if "`noconstant'"!="" {
mkmat `wy1' `wy2' `endg' `xvar1' `aux' , matrix(`X3SLS1')
mkmat `wy2' `wy1' `yvar' `xvar2' `aux' , matrix(`X3SLS2')
 }
else {
mkmat `wy1' `wy2' `endg' `xvar1' `aux' `X0' , matrix(`X3SLS1')
mkmat `wy2' `wy1' `yvar' `xvar2' `aux' `X0' , matrix(`X3SLS2')
 }
tempvar y yn
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
 if "`coll'"=="" {
_rmcoll `zvar' , `noconstant' `coll' forcedrop
 local zvar "`r(varlist)'"
 }
preserve
qui ivregress 2sls `varlist1' `aux' (`wy1' `wy2' `y2'=`xvar' `zvar') `wgt' , `noconstant'
predict `E1' , resid
qui ivregress 2sls `varlist2' `aux' (`wy1' `wy2' `y1'=`xvar' `zvar') `wgt' , `noconstant'
predict `E2' , resid
tempname euh1 euh2
mkmat `E1' , matrix(`euh1')
mkmat `E2' , matrix(`euh2')
qui forval i=1/2 {
tempvar u2h v2h uvh vwh uwh u2hm v2hm uvhm vwhm uwhm E1 E2 Yh_ML1 Yh_ML2
tempvar w2h w2hm rs rs2 E E2 Es
tempvar h11 h12 h13 hy1 h21 h22 h23 hy2 h31 h32 h33 hy3 y yn
tempvar z v1 v2 v3 uh vh wh
tempname MMM vh wh
matrix `vh'=`wmat'*`euh`i''
matrix `wh'=`wmat'*`vh'
svmat `euh`i'', name(`uh')
svmat `vh', name(`vh')
svmat `wh', name(`wh')
cap rename `uh'1 `uh'
cap rename `vh'1 `vh'
cap rename `wh'1 `wh'
gen `u2h'=`uh'*`uh'
gen `v2h'=`vh'*`vh'
gen `uvh'=`uh'*`vh'
gen `vwh'=`vh'*`wh'
gen `w2h'=`wh'*`wh'
gen `uwh'=`uh'*`wh'
matrix `MMM'=trace(`wmat''*`wmat')/`N'
egen `u2hm' = mean(`u2h')
egen `v2hm' = mean(`v2h')
egen `uvhm' = mean(`uvh')
egen `vwhm' = mean(`vwh')
egen `w2hm' = mean(`w2h')
egen `uwhm' = mean(`uwh')
gen `h11'=-2*`uvhm'
gen `h12'=`v2hm'
gen `h13'=-1
gen `h21'=-2*`vwhm'
gen `h22'=`w2hm'
gen `h23'=-trace(`MMM')
gen `h31'=-(`v2hm'+`uwhm')
gen `h32'=`vwhm'
gen `h33'=0
gen `hy1'=-`u2hm'
gen `hy2'=-`v2hm'
gen `hy3'=-`uvhm'
tempvar z v1 v2 v3
collapse `h11' `h12' `h13' `hy1' `h21' `h22' `h23' `hy2' `h31' `h32' `h33' `hy3'
tempname h1 h2 h3 hy
mkmat `h11' `h21' `h31', matrix(`h1')
mkmat `h12' `h22' `h32', matrix(`h2')
mkmat `h13' `h23' `h33', matrix(`h3')
mkmat `hy1' `hy2' `hy3', matrix(`hy')
matrix `h1'=`h1''
matrix `h2'=`h2''
matrix `h3'=`h3''
matrix `hy'=`hy''
svmat `h1', name(`v1')
svmat `h2', name(`v2')
svmat `h3', name(`v3')
svmat `hy', name(`z')
rename `v1'1 `v1'
rename `v2'1 `v2'
rename `v3'1 `v3'
rename `z'1 `z'
qui nl (`z'=`v1'*{Rho}+`v2'*{Rho}^2+`v3'*{Sigma2}) , init(Rho 0.7 Sigma2 1) nolog
scalar Rho`i'=_b[/Rho]
 }
restore
scalar i=1
qui cap drop w1x_*
qui cap drop w2x_*
qui cap drop w3x_*
qui cap drop w4x_*
tempname Rho1 Rho2
scalar `Rho1'=Rho1
scalar `Rho2'=Rho2
tempvar y1 y2 y1n y2n
gen `y1'=`yvar'
gen `y2'=`endg'
gen `y1n'=`endg'
gen `y2n'=`yvar'
qui forvalue i=1/2 {
tempvar Exog`i's_
mkmat `y`i'', matrix(`y`i'')
matrix `y`i''s =`y`i'' -`Rho`i''*`wmat'*`y`i''
svmat  `y`i''s , name(`y`i''s)
rename `y`i''s1  `y`i''s
mkmat  `y`i'n', matrix(`y`i'n')
matrix `y`i'n's =`y`i'n' -`Rho`i''*`wmat'*`y`i'n'
svmat  `y`i'n's , name(`y`i'n's)
rename  `y`i'n's1  `y`i'n's
matrix `X0'`i's  =`X0'  -`Rho`i''*`wmat'*`X0'
svmat  `X0'`i's , name(`X0'`i's)
rename `X0'`i's1 `X0'`i's
qui foreach var of local xvar`i' {
mkmat  `var', matrix(`var')
matrix `var's=`var' -`Rho`i''*`wmat'*`var'
svmat  `var's , name(`var'`i'1)
rename `var'`i'1 `Exog`i's_'`var'
 }
 }
qui foreach var of local xvar {
matrix `w1x'= `wmat'*`var'
matrix `w2x'= `wmat'*`w1x'
matrix `w3x'= `wmat'*`w2x'
matrix `w4x'= `wmat'*`w3x'
svmat  `w1x', name(w1x_`var')
svmat  `w2x', name(w2x_`var')
svmat  `w3x', name(w3x_`var')
svmat  `w4x', name(w4x_`var')
rename w1x_`var'1 w1x_`var'
rename w2x_`var'1 w2x_`var'
rename w3x_`var'1 w3x_`var'
rename w4x_`var'1 w4x_`var'
 }
qui forvalue i=1/2 {
qui forvalue j=1/2 {
tempname `wy`i'`j' wy`i' wys`i'
tempvar  `wy`i'`j' wy`i' wys`i'
mkmat `y`i'', matrix(`y`i'')
matrix `wy`i''=`wmat'*`y`i''
matrix `wys`i''=`wy`i''-`Rho`j''*`wmat'*`wy`i''
svmat  `wys`i'', name(`wy`i'`j'')
rename `wy`i'`j''1 `wy`i'`j''
qui cap matrix drop `y`i''
 }
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
 if "`coll'"=="" {
_rmcoll `zvar' , `noconstant' `coll' forcedrop
 local zvar "`r(varlist)'"
 }
tempname Y y1s y2s
matrix y1s=`y1's
matrix y2s=`y2's
qui foreach var of local xvar {
qui cap matrix drop `var's
qui cap matrix drop `var'
 }
qui cap matrix drop `yvar'
qui cap matrix drop `endg'
preserve
qui cap drop _cons1
qui cap drop _cons2
local N2N=2*`N'
qui set matsize `N2N'
gen `yvar'_1=`y1's
gen `endg'_1=`y1n's
gen `yvar'_2=`y2n's
gen `endg'_2=`y2's
qui rename `X0'1s _cons1
qui gen wy11_`yvar'=`wy11'
qui gen wy21_`endg'=`wy21'
qui foreach var of local xvar1 {
qui replace `var'=`Exog1s_'`var'
 }
local `xvar1' `var'*
qui rename `X0'2s _cons2
qui gen wy12_`yvar'=`wy12'
qui gen wy22_`endg'=`wy22'
qui foreach var of local xvar2 {
qui replace `var'=`Exog2s_'`var'
 }
local `xvar2' `var'*
di
 }
 if "`noconstant'"!="" {
 reg3 (`yvar'_1 wy11_`yvar' wy21_`endg' `endg'_1 `xvar1' `aux' , noconstant) ///
      (`endg'_2 wy22_`endg' wy12_`yvar' `yvar'_2 `xvar2' `aux' , noconstant) , ///
 small `ols' `2sls' `3sls' `sure' `mvreg' `vce' exog(`xvar' `zvar') ///
 endog(wy11_`yvar' wy21_`endg' `endg'_1 wy12_`yvar' wy22_`endg' `yvar'_2) noconstant
 }
 else  {
 reg3 (`yvar'_1 wy11_`yvar' wy21_`endg' `endg'_1 `xvar1' `aux' _cons1 , noconstant) ///
      (`endg'_2 wy22_`endg' wy12_`yvar' `yvar'_2 `xvar2' `aux' _cons2 , noconstant) , ///
 small `ols' `2sls' `3sls' `sure' `mvreg' `vce'  noconstant ///
 exog(_cons1  _cons2 `xvar' `zvar') ///
 endog(wy11_`yvar' wy21_`endg' `endg'_1 wy12_`yvar' wy22_`endg' `yvar'_2)
 }
restore
tempname Omega BS yvar1 endg2 SSE1 SSE2 SSE3 MSS1 MSS2 MSS3 SST1 SST2 SST3 ks
tempname aic sc PF yvar1 endg2 B3SLS1 B3SLS2 y1s y2s YMAT RSQ SSE1 SSE2 SSE3
tempname MSS1 MSS2 Sig Sig21 MSS3 SST1 SST2 SST3 Ybv Yb Yv Yb_Y1 Yb_Y2 Sig2 Y
tempname YM RS1 RS2 RS3 k1 k2 Ro ADR F kb2 K Q DF1 DF2 DFF DFChi LSig2 Ev E
tempname W LLF df1 df2 Chi PChi kb N kb1 kb2 Kx kz XB1 XB2 Eu1 Eu2
scalar `kz'=1
 if "`noconstant'"!="" {
scalar `kz'=0
 }
matrix `BS'=e(b)
local N=e(N)
scalar `k1'=e(df_m1)
scalar `k2'=e(df_m2)
scalar `kb1'=`k1'
scalar `kb2'=`k2'
scalar `K'=e(k)
scalar `Q'=2
scalar `DF1'=`k1'+`k2'-2*`kz'
scalar `DF2'=`Q'*`N'-(`k1'+`k2'-2*`kz')
scalar `DFF'=(`Q'*`N'-`DF1')/`DF1'
scalar `DFChi'=`DF1'
scalar `ks'=`kb1'+1
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
end

 prog def gotoup , rclass
 version 7.0
 syntax [if] [in] [ , id(str) ]
qui cap drop `id'
 local gindlab `"id `varlist' `if' `in'"'
 unab existvar: *
 marksample touse , novarlist strok
 tempvar idsort
qui gen long `idsort'=_n
 if `"`varlist'"'=="" {
 tempvar varlist
qui gen byte `varlist'=1
 }
 sort `touse' `varlist' `idsort'
 tempvar top
qui by `touse' `varlist':gen byte `top'=`touse'&(_n==1)
qui expand 2*`top'
qui drop `top'
qui sort `touse' `varlist' `idsort'
 if `"`id'"'=="" {tempvar id}
 by `touse' `varlist' `idsort':gen byte `id'=_n==2
 lab var `id' `"`gindlab'"'
 gsort `touse' `idsort' -`id'
qui foreach i of var `existvar' {
qui local nobv=1
qui foreach Y of var `varlist' {
qui if "`i'"=="`Y'" {local nobv=0}
 }
qui replace `i'=. if `id'
 }
gsort `idsort' -`id'
end

program define Display
version 11.0
syntax, [Level(int $S_level) robust]
if inlist("`e(title)'" ,"SEM1n", "SEM1w") {
ml display, level(`level') neq(1) noheader diparm(Lambda, label("Lambda")) ///
            diparm(Sigma, label("Sigma"))
di as txt " LR Test SEM vs. OLS (Lambda=0):" _col(33) %9.4f as res e(waldl) as txt _col(45) "P-Value > Chi2(1)" as res _col(65) %5.4f e(waldlp)
di as txt " Acceptable Range for Lambda:" _col(33) as res %9.4f e(minEig) "  < Lambda < " %5.4f e(maxEig)
 }
if inlist("`e(title)'" ,"SEM1e") {
ml display, level(`level') neq(1) noheader diparm(Lambda, label("Lambda"))
di as txt " LR Test SEM vs. OLS (Lambda=0):" _col(33) %9.4f as res e(waldl) as txt _col(45) "P-Value > Chi2(1)" as res _col(65) %5.4f e(waldlp)
di as txt " Acceptable Range for Lambda:" _col(33) as res %9.4f e(minEig) "  < Lambda < " %5.4f e(maxEig)
 }
if inlist("`e(title)'", "SAR1n", "SAR1w") {
ml display, level(`level') neq(1) noheader diparm(Rho, label("Rho")) ///
            diparm(Sigma, label("Sigma"))
if "`robust'"!="" {
di as txt " Wald Test SAR vs. OLS (Rho=0):" _col(33) %9.4f as res e(waldr) as txt _col(45) "P-Value > Chi2(1)" as res _col(65) %5.4f e(waldrp)
 }
 if "`robust'"=="" {
di as txt " LR Test SAR vs. OLS (Rho=0):" _col(33) %9.4f as res e(waldr) as txt _col(45) "P-Value > Chi2(1)" as res _col(65) %5.4f e(waldrp)
 }
di as txt " Acceptable Range for Rho:" _col(33) as res %9.4f e(minEig) "   <  Rho  < " %5.4f e(maxEig)
 }
if inlist("`e(title)'" ,"SAR1e") {
ml display, level(`level') neq(1) noheader diparm(Rho, label("Rho"))
 if "`robust'"!="" {
di as txt " Wald Test SAR vs. OLS (Rho=0):" _col(33) %9.4f as res e(waldr) as txt _col(45) "P-Value > Chi2(1)" as res _col(65) %5.4f e(waldrp)
 }
 if "`robust'"=="" {
di as txt " LR Test SAR vs. OLS (Rho=0):" _col(33) %9.4f as res e(waldr) as txt _col(45) "P-Value > Chi2(1)" as res _col(65) %5.4f e(waldrp)
 }
di as txt " Acceptable Range for Rho:" _col(33) as res %9.4f e(minEig) "   <  Rho  < " %5.4f e(maxEig)
 }
if inlist("`e(title)'" ,"SAR1h") {
ml display, level(`level') neq(2) noheader diparm(Rho, label("Rho")) ///
          diparm(Sigma, label("Sigma"))
 if "`robust'"!="" {
di as txt " Wald Test SAR vs. OLS (Rho=0):" _col(33) %9.4f as res e(waldr) as txt _col(45) "P-Value > Chi2(1)" as res _col(65) %5.4f e(waldrp)
 }
 if "`robust'"=="" {
di as txt " LR Test SAR vs. OLS (Rho=0):" _col(33) %9.4f as res e(waldr) as txt _col(45) "P-Value > Chi2(1)" as res _col(65) %5.4f e(waldrp)
 }
di as txt " Acceptable Range for Rho:" _col(33) as res %9.4f e(minEig) "   <  Rho  < " %5.4f e(maxEig)
 }
if inlist("`e(title)'", "SDM1n", "SDM1w") {
ml display, level(`level') neq(1) noheader diparm(Rho, label("Rho")) ///
          diparm(Sigma, label("Sigma"))
 if "`robust'"!="" {
di as txt " Wald Test SDM vs. OLS (Rho=0):" _col(33) %9.4f as res e(waldr) as txt _col(45) "P-Value > Chi2(1)" as res _col(65) %5.4f e(waldrp)
di as txt " Wald Test (wX's =0):" _col(33) %9.4f as res e(waldx) as txt _col(45) "P-Value > Chi2(" e(waldx_df) ")" as res _col(65) %5.4f e(waldxp)
 }
 if "`robust'"=="" {
di as txt " LR Test SDM vs. OLS (Rho=0):" _col(33) %9.4f as res e(waldr) as txt _col(45) "P-Value > Chi2(1)" as res _col(65) %5.4f e(waldrp)
di as txt " LR Test (wX's =0):" _col(33) %9.4f as res e(waldx) as txt _col(45) "P-Value > Chi2(" e(waldx_df) ")" as res _col(65) %5.4f e(waldxp)
 }
di as txt " Acceptable Range for Rho:" _col(33) as res %9.4f e(minEig) "   <  Rho  < " %5.4f e(maxEig)
 }
if inlist("`e(title)'" ,"SDM1e") {
ml display, level(`level') neq(1) noheader diparm(Rho, label("Rho"))
 if "`robust'"!="" {
di as txt " Wald Test SDM vs. OLS (Rho=0):" _col(33) %9.4f as res e(waldr) as txt _col(45) "P-Value > Chi2(1)" as res _col(65) %5.4f e(waldrp)
di as txt " Wald Test (wX's =0):" _col(33) %9.4f as res e(waldx) as txt _col(45) "P-Value > Chi2(" e(waldx_df) ")" as res _col(65) %5.4f e(waldxp)
 }
 if "`robust'"=="" {
di as txt " LR Test SDM vs. OLS (Rho=0):" _col(33) %9.4f as res e(waldr) as txt _col(45) "P-Value > Chi2(1)" as res _col(65) %5.4f e(waldrp)
di as txt " LR Test (wX's =0):" _col(33) %9.4f as res e(waldx) as txt _col(45) "P-Value > Chi2(" e(waldx_df) ")" as res _col(65) %5.4f e(waldxp)
 }
di as txt " Acceptable Range for Rho:" _col(33) as res %9.4f e(minEig) "   <  Rho  < " %5.4f e(maxEig)
 }
if inlist("`e(title)'" ,"SDM1h") {
ml display, level(`level') neq(2) noheader diparm(Rho, label("Rho")) ///
          diparm(Sigma, label("Sigma"))
 if "`robust'"!="" {
di as txt " Wald Test SDM vs. OLS (Rho=0):" _col(33) %9.4f as res e(waldr) as txt _col(45) "P-Value > Chi2(1)" as res _col(65) %5.4f e(waldrp)
di as txt " Wald Test (wX's =0):" _col(33) %9.4f as res e(waldx) as txt _col(45) "P-Value > Chi2(" e(waldx_df) ")" as res _col(65) %5.4f e(waldxp)
 }
 if "`robust'"=="" {
di as txt " LR Test SDM vs. OLS (Rho=0):" _col(33) %9.4f as res e(waldr) as txt _col(45) "P-Value > Chi2(1)" as res _col(65) %5.4f e(waldrp)
di as txt " LR Test (wX's =0):" _col(33) %9.4f as res e(waldx) as txt _col(45) "P-Value > Chi2(" e(waldx_df) ")" as res _col(65) %5.4f e(waldxp)
 }
di as txt " Acceptable Range for Rho:" _col(33) as res %9.4f e(minEig) "   <  Rho  < " %5.4f e(maxEig)
 }
if inlist("`e(title)'", "SAC1n", "SAC1w") {
ml display, level(`level') neq(1) noheader diparm(Rho, label("Rho")) ///
            diparm(Lambda, label("Lambda")) diparm(Sigma, label("Sigma"))
di as txt " LR Test (Rho=0):" _col(40) %9.4f as res e(waldr) as txt _col(52) "P-Value > Chi2(1)" as res _col(70) %5.4f e(waldrp)
di as txt " LR Test (Lambda=0):" _col(40) %9.4f as res e(waldl) as txt _col(52) "P-Value > Chi2(1)" as res _col(70) %5.4f e(waldlp)
di as txt " LR Test SAC vs. OLS (Rho+Lambda=0):" _col(40) %9.4f as res e(waldj) as txt _col(52) "P-Value > Chi2(2)" as res _col(70) %5.4f e(waldjp) 
di as txt " Acceptable Range for Rho:" _col(40) as res %9.4f e(minEig) _col(52) "<  Rho  < " %5.4f e(maxEig) 
 }
if inlist("`e(title)'" ,"SAC1e") {
ml display, level(`level') neq(1) noheader diparm(Rho, label("Rho")) ///
            diparm(Lambda, label("Lambda"))
di as txt " LR Test (Rho=0):" _col(40) %9.4f as res e(waldr) as txt _col(52) "P-Value > Chi2(1)" as res _col(70) %5.4f e(waldrp)
di as txt " LR Test (Lambda=0):" _col(40) %9.4f as res e(waldl) as txt _col(52) "P-Value > Chi2(1)" as res _col(70) %5.4f e(waldlp)
di as txt " LR Test SAC vs. OLS (Rho+Lambda=0):" _col(40) %9.4f as res e(waldj) as txt _col(52) "P-Value > Chi2(2)" as res _col(70) %5.4f e(waldjp) 
di as txt " Acceptable Range for Rho:" _col(40) as res %9.4f e(minEig) _col(52) "<  Rho  < " %5.4f e(maxEig) 
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


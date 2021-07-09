*! almon V1.0 01/01/2016
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

program define almon , eclass byable(recall)
 version 11.2
 syntax [anything] [if] [in] [aw] , [Model(str) LAG(int 1) DLag(int 1) ///
 Quantile(int 50) ridge(str) KR(real 0) NOCONStant NOLag WVar(varname) ///
 LMNorm LMHet HETcov(str) Weights(str) TESTs mfx(str) LMAuto tune(int 7) ///
 Level(cilevel) TWOstep REST(str) VCE(str) diag LAMp(str) tolog sig DN ///
 PREDict(str) RESid(str) TECHn(str) iter(int 200) TOLerance(real 0.00001) ///
 AR(int 1) ZLag(str) PDL(numlist int >=0) ENDpr(numlist int >=0) CONDition]

qui {
 marksample touse
 markout `touse'
 local sthlp almon
 tempvar Time TimeN
 gen `Time'=_n if `touse'
 tsset `Time'
 local NT1=r(tmin)
 local NT2=r(tmax)
 local varlist `anything'
 gettoken yvar xvar : varlist
 tsunab yvar : `yvar'
 tokenize `yvar'
 local yvar `1'
 macro shift
 local xvar "`xvar' `*'"
 local NYvar "`yvar'"
 local MVar "`xvar'"
 tsrevar `MVar' , list
 local xvar "`MVar'"
 gen `TimeN'=_n 
 tsset `TimeN'
 tsunab NXvar: `MVar'
 tsunab xvar : `MVar'
 local nX: word count `MVar'
 }
 di
 if "`model'"!="" {
 if !inlist("`model'", "als", "arch", "bcox", "gls", "gmm", "ols", "qreg", "rreg") {
di as err " {bf:model( )} {cmd:must be} {bf:model({it:als, arch, bcox, gls, gmm, ols, qreg, rreg})}"
di as err " {bf:model({it:als})}  {cmd:Autoregressive Least Squares (ALS)}"
di as err " {bf:model({it:arch})} {cmd:Autoregressive Conditional Heteroskedasticity (ARCH)}"
di as err " {bf:model({it:bcox})} {cmd:Box-Cox Regression Model (Box-Cox)}"
di as err " {bf:model({it:gls})}  {cmd:Generalized Least Squares (GLS)}"
di as err " {bf:model({it:gmm})}  {cmd:Generalized Method of Moments (GMM)}"
di as err " {bf:model({it:ols})}  {cmd:Ordinary Least Squares (OLS)}"
di as err " {bf:model({it:qreg})} {cmd:Quantile Regression (QREG)}"
di as err " {bf:model({it:rreg})} {cmd:Robust   Regression (RREG)}"
 exit
 }
 }
 if "`xvar'"=="" {
di as err " {bf:Independent Variable(s) must be Combined with Dependent Variable}"
 exit 
 }
 local both : list yvar & xvar
 if "`both'" != "" {
di as err " {bf:{cmd:`both'} cannot be Included in both LHS and RHS Variables}"
di as res " LHS: `yvar'"
di as res " RHS: `xvar'"
 exit
 }
 tsunab RHS : `NXvar'
 _rmcoll `RHS' , `noconstant' forcedrop
 local both "`r(varlist)'"
 local both : list RHS - both
 if "`both'" != "" {
di as err " {bf:{cmd:`both'} cannot be Included more than One in RHS Variables}"
di as res " RHS : `RHS'"
di as res " Coll: `both'"
 exit
 }
 if "`model'"=="" {
 local model "ols"
 }
 if "`tests'"!="" {
 local diag "diag"
 local lmauto "lmauto"
 local lmhet "lmhet"
 local lmnorm "lmnorm"
 } 
 if "`pdl'"=="" {
di as err " {bf:pdl( # )} {cmd:Must be Specified}"
 exit 
 }
 if "`zlag'"=="" {
di as err " {bf:zlag( vars )} {cmd:Must be Specified}"
 exit 
 }
 if "`endpr'"!="" {
 local kEnd : word count `endpr'
 local kZLag : word count `zlag'
 if `kZLag' != `kEnd' {
di as err " {cmd:Number of} {bf:zlag( `kZLag' )} {cmd:must Equal Number of} {bf:endpr( `kEnd' )}"
noi di 
noi di as err " the model must be, i.e," 
noi di as err " almon y l(0/3).x1 , zlag(x1) pdl(2) end(0)" 
noi di as err " almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0)" 
 exit 
 }
qui foreach num of numlist `endpr' {
 local kEnd= `num'
 if `kEnd' > 3 | `kEnd' <0 {
di as err " {bf:endpr( )} {cmd:Endpoint Restriction Range must be} {bf:endpr({it:0, 1, 2, 3})}"
di as err " {bf:endpr({it:0})} {cmd:No Endpoint Polynomial Restrictions}"
di as err " {bf:endpr({it:1})} {cmd:Left Side Endpoint Polynomial Restrictions}"
di as err " {bf:endpr({it:2})} {cmd:Right Side Endpoint Polynomial Restrictions}"
di as err " {bf:endpr({it:3})} {cmd:Left & Right Side Endpoint Restrictions of Polynomial}"
 exit
 }
 }
 }
 if !inlist("`model'", "als", "arch") & `ar' > 1 {
di as err " {bf:ar(#)} {cmd:Valid only with:} {bf:model({it:als, arch})}"
 exit
 }
 if !inlist("`model'", "bcox") & "`lamp'"!="" {
di as err " {bf:lamp( )} {cmd:Valid only with:} {bf:model({it:bcox})}"
 exit
 }
 if "`lamp'"!="" {
 if !inlist("`lamp'", "lhs", "rhs", "alls", "alld") {
di as err " {bf:lamp( )} {cmd:must be} {bf:lamp({it:lhs, rhs, alls, alld})}"
di as err " {bf:lamp({it:lhs})}  {cmd:Power Transformations on (LHS) Left Hand Side Only; default}"
di as err " {bf:lamp({it:rhs})}  {cmd:Power Transformations on (RHS) Right Hand Side Only}"
di as err " {bf:lamp({it:alls})} {cmd:Power Transformations on both (LHS) & (RHS) are the Same}"
di as err " {bf:lamp({it:alld})} {cmd:Power Transformations on both (LHS) & (RHS) are Different}"
 exit
 }
 }
 if inlist("`model'", "bcox") & "`lamp'"=="" {
 local lamp "lhs"
 }
 if inlist("`model'", "gls") & "`wvar'"=="" {
di as err " {bf:wvar({it:varname})} {cmd:must be combined with:} {bf:model({it:gls})}"
 exit
 }
 if inlist("`model'", "rreg") & "`wvar'"!="" {
di as err " {bf:wvar( )} {cmd:not Valid with:} {bf:model({it:rreg})}"
 exit
 }
 if "`weights'"!="" {
 if !inlist("`weights'", "yh", "abse", "e2", "le2", "yh2", "x", "xi", "x2", "xi2") {
di as err " {bf:weights( )} {cmd:works only with:} {bf:yh}, {bf:yh2}, {bf:abse}, {bf:e2}, {bf:le2}, {bf:x}, {bf:xi}, {bf:x2}, {bf:xi2}"
di in smcl _c "{cmd: see:} {help `sthlp'##07:Options}"
di in gr _c " (almon Help):"
 exit
 }
 }
 if inlist("`weights'", "x", "xi", "x2", "xi2") & "`wvar'"=="" {
di as err " {bf:wvar( )} {cmd:must be combined with:} {bf:weights(x, xi, x2, xi2)}"
 exit
 }
 if !inlist("`model'", "gmm") & "`hetcov'"!="" {
di as err " {bf:hetcov( )} {cmd:Valid only with:} {bf:model({it:gmm})}"
 exit
 }
 if "`hetcov'"!="" {
if !inlist("`hetcov'", "white", "nwest", "bart", "trunc", "parzen", "quad", "tukey") {
if !inlist("`hetcov'", "hdun", "hink", "crag", "jack", "tukeyn", "tukeym", "dan", "tent") {
di as err "{bf:hetcov()} {cmd:must be} {bf:({it:bart, crag, dan, hdun, hink, jack, nwest,}}"
di as err _col(19) "{bf:{it:parzen, quad, tent, trunc, tukey, tukeym, tukeyn, white})}"
di in smcl _c "{cmd: see:} {help `sthlp'##05:GMM Options}"
di in gr _c " (almon Help):"
 exit
 }
 }
 }
 if "`mfx'"!="" {
 if !inlist("`mfx'", "lin", "log") {
di as err " {bf:mfx( )} {cmd:must be} {bf:mfx({it:lin})} {cmd:for Linear Model, or} {bf:mfx({it:log})} {cmd:for Log-Log Model}"
 exit
 }
 }
 if inlist("`mfx'", "log") & inlist("`model'", "bcox") {
 if "`tolog'"!="" {
di as err " {bf:model(bcox)} {cmd:Valid only with} {bf:mfx(lin)}"
 exit
 }
 }
 if "`ridge'"!="" {
 if !inlist("`ridge'", "orr", "grr1", "grr2", "grr3") {
di as err " {bf:ridge( )} {cmd:must be} {bf:ridge({it:orr, grr1, grr2, grr3})}"
di in smcl _c "{cmd: see:} {help `sthlp'##06:Ridge Options}"
di in gr _c " (almon Help):"
 exit
 }
 }
 if inlist("`ridge'", "grr1", "grr2", "grr3") & `kr'>0 {
di as err " {bf:kr(#)} {cmd:must be not combined with:} {bf:ridge({it:grr1, grr2, grr3})}"
 exit
 }
 local auto ""
 local distn ""
 local itern ""
 local itern1 ""
 local leveln "level(`level')"
 local nolog ""
 local run "cnsreg"
 local techn ""
 local vcen " vce(`vce') "
 if inlist("`model'", "als") & `ar' == 1 {
 local ModeL "ALS"
 local Mtitle "Autoregressive Least Squares (ALS)"
 }
 if inlist("`model'", "als") & `ar' > 1 {
 local itern "iter(`iter')"
 local itern1 "iter(3)"
 local techn "techn(`techn')"
 local run "arima"
 local ModeL "ALS"
 local auto "ar(1/`ar')"
 local Mtitle "Autoregressive Least Squares (ALS)"
 }
 if inlist("`model'", "arch") {
 local itern "iter(`iter')"
 local itern1 "iter(3)"
 local techn "techn(`techn')"
 local run "arch"
 local auto "arch(1/`ar')"
 local ModeL "ARCH"
 local Mtitle "Autoregressive Conditional Heteroskedasticity (ARCH)"
 }
 if inlist("`model'", "bcox") {
 local itern "iter(`iter')"
 local ModeL "Box-Cox"
 local Mtitle "Box-Cox Regression Model (Box-Cox)"
 }
 if inlist("`model'", "gls") {
 local ModeL "GLS"
 local Mtitle "Generalized Least Squares (GLS)"
 }
 if inlist("`model'", "gmm") {
 local ModeL "GMM"
 local Mtitle "Generalized Method of Moments (GMM)"
 }
 if inlist("`model'", "qreg") {
 local ModeL "QREG"
 local Mtitle "Quantile Regression (QREG)"
 }
 if inlist("`model'", "rreg") {
 local ModeL "RREG"
 local Mtitle "Robust Regression (RREG)"
 }
 if inlist("`model'", "ols") {
 local ModeL "OLS"
 local Mtitle "Ordinary Least Squares (OLS)"
 }
noi di _dup(78) "{bf:{err:=}}"
noi di as txt _col(7) "{bf:{err:*** Shirley Almon Generalized Polynomial Distributed Lag Model ***}}"
noi di _dup(78) "{bf:{err:=}}"
di as err _col(2) "{bf:*** `Mtitle' ***}"
noi di _dup(55) "{bf:{err:-}}"

 if inlist("`model'", "bcox") {
 if !inlist("`lamp'", "rhs", "alls", "alld") {
di as err " {bf:lamp({it:lhs})} {cmd:Power Transformations on (LHS) Left Hand Side Only}"
 }
 if inlist("`lamp'", "rhs") {
di as err " {bf:lamp({it:rhs})} {cmd:Power Transformations on (RHS) Right Hand Side Only}"
 }
 if inlist("`lamp'", "alls") {
di as err " {bf:lamp({it:alls})} {cmd:Power Transformations on (LHS) & (RHS) are the Same}"
 }
 if inlist("`lamp'", "alld") {
di as err " {bf:lamp({it:alld})} {cmd:Power Transformations on (LHS) & (RHS) are Different}"
 }
di
 }
 _rmcoll `NXvar' , `noconstant' forcedrop
 local NXvar "`r(varlist)'"
 _rmcoll `zlag' , `noconstant' forcedrop
 local both "`r(varlist)'"
 local both : list zlag - both
 if "`both'" != "" {
di as err " {bf:{cmd:`both'} Included more than One in Zlag( ) Variables}"
di as res " ZLag: `zlag'"
di as res " Coll: `both'"
 exit
 }
 tsunab RHS : `NXvar'
 tsrevar `RHS' , list
 local RHS "`r(varlist)'"
 _rmcoll `zlag' , `noconstant' forcedrop
 local zlags "`r(varlist)'"
 local both : list zlags - RHS
 if "`both'" != "" {
di as err " {bf:{cmd:`both'} : Not Included in RHS Variables}"
di as res " RHS : `RHS'"
di as res " ZLag: `both'"
 exit
 }

qui { 
tempvar _X _Y _Yy_ _Xx_ _Xu_ absE Ci COR DE DF1 DFF DumE DW DX DX_ DY_ E E1 E12 E2 E2 E3 E4
tempvar Yh_ML Yh_MLo Ue_ML Ue_MLo Yh_MLs Ue_MLs _Wx_ ZoC Zw WLSVar SLSVar
tempvar EDumE EE EE1 eigVaLn ELin ELog ELYh Eo Es Es1 f1 f13 fg fgF fgFp Hat hjm ht ILVal
tempvar L ZBoxL LDE LE LE1 LEo lf LLFs Lms LnE2 LOGvars logYh LOGyvar LVal LVal1 LVR Ea Ea1
tempvar LWi2 LY LYh LYh2 miss R2oS R2xx Rx SBB Si SLv2 SRho SSE U U2 Ue VIFI
tempvar wald Wis Wi1 Wi Wio WS X0 XQ Yb YBox Yh Yh2 Yhb Yho Yho2 Yhr Yhs Yt YY YYm YYv
tempname Zws Yws Aa AIC1 B b1 b2 Bb Beta BOLS BOLS1 Br BsZ Bu Bv Bv1 Bx Cc COR corr CORr Cov CovC
tempname Cr D DCor DF Dr Ds DX E E1 E11 EE1 Eg eigVaL Eo EP Es Es2 Ew F f1 f13 f13d fg FGFF fgT
tempname FLin FLog Go GoRY h Hat HT ICOR IDRmk IPhi it J JDF Jkx Jkxd kb Kk Ko Koi Kr LDCor llf
tempname Lms LVal LVal1 LVR LWi21 M M1 M2 mh n N nw NY OM Omega OmegaG P Phi Phi Pm q Q q1 q2 Qq
tempname Qr R1 R1 rid Rmk Ro1 Roi RX RY s S S11 S12 S2y SC1 sd SE1 SE12 SE2 SEE1 Sig2 Sig2n
tempname Sig2o Sig2o1 Sig2w SLS SLv2 Sn sqN Ss SSEo SST1 SST2 Sw Uew V v1 v2 VaL Val VaL1
tempname VaL21 VaLv1 VCov Vec vh VIF VIFI VM VP vy1 W W1 W1W W2 Wald We Wi Wi1 WMAT WMTD
tempname WY X X0 XQ ZwZ ZoZ Xx Y Yh YhLin YhLog Yhw Yi Yws Z Z0 Z1 Zo Zr Zz b NT Beta1 WiB
tempname restc restA restB Rs Rs1 Rso Rso1 Yh_ML Yh_MLo Ue_ML Ue_MLo Yh_MLs Ue_MLs wald waldp k0

 local k = 0
 local Qw = 0
 local kPDL = 0
 if "`rest'"!="" {
 ereturn local k_autoCns= 0
 cap cnsreg `NYvar' `MVar' , `noconstant' constr(`rest') noomitted
 if e(k_autoCns) != 0 {
noi di as err " {bf:Restrections must be Specified First, i,e:}"
noi di as txt " constraint define 1 x1 + x2 = 1"
 exit
 }
 else {
 `run' `NYvar' `MVar' , `noconstant' `auto' `itern1' `nolog' constr(`rest')
 }
 matrix `restA' = e(Cns)
 matrix `restc' = `restA'
 local krc= colsof(`restc')
 local krc1= `krc'-1
 local krr= rowsof(`restc')
 local Qw1= `krr'
 matrix `Rs' = `restc'[1..`krr', 1..`krc1']
 matrix `Rso'= `restc'[1..`krr', `krc'..`krc']
 local k = `krr'
 }

 preserve
 gen double `_Yy_' = `NYvar' if `touse'
 tsunab yvar: `_Yy_'
 local kx : word count `NXvar'
 forvalue i=1/`kx' {
 local v: word `i' of `NXvar'
 if "`nolag'"=="" {
 gen double `_Xx_'`i' = L1.`v' if `touse'
 }
 else {
 gen double `_Xx_'`i' = `v' if `touse'
 }
 }
 tsunab xvar : `_Xx_'*
 tokenize `xvar'
 local NUXvar "`NXvar'"
 local kx : word count `NUXvar'
noi di as err "- Polynomial Variables:" _col(26) "{cmd:`zlag'}"
noi di as err "- Lag Length:" _col(25) "{cmd:`MVar'}"
noi di as err "- Polynomial Degree:" _col(26) "{bf:{cmd:PDL(`pdl')}}"
noi di as err "- Endpoint Restriction:" _col(26) "{bf:{cmd:End(`endpr')}}"
 local kZLag : word count `zlag'
 local kPDL : word count `pdl'
 tsrevar `NXvar' , list
 local bothL "`r(varlist)'"
 local bothR : list zlag - bothL
 if "`bothR'" != "" {
noi di as err " {bf:{cmd:`bothR'} not Included in RHS Variables}"
noi di as txt " RHS : `bothL'"
noi di as txt " ZLag: `bothR'"
 exit 
 }
 if `kZLag' != `kPDL' {
noi di 
noi di as err " {cmd:Number of} {bf:zlag( `kZLag' )} {cmd:must Equal Number of} {bf:pdl( `kPDL' )}"
noi di 
noi di as err " the model must be, i.e," 
noi di as err " almon y l(0/3).x1 , zlag(x1) pdl(2) end(0)" 
noi di as err " almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0)" 
 exit 
 }
 local j =0
 tempname cmat cmat0 cmatl cmatr cmatlr 
 forvalue i = 1/`kZLag' {
 local kEnd =0
 local VL: word `i' of `MVar'
 local ZL: word `i' of `zlag'
 tsunab xVL : `VL'
 local kVL : word count `xVL'
 local kVL =`kVL'-1
 local kZL : word `i' of `pdl'
 tsrevar `VL' , list
 local VLl "`r(varlist)'"
 if `VLl' != `ZL' {
noi di as err " {bf:Order Variable zlag( `ZL' )} {cmd:must be the same as in RHS} {bf:( `RHS' )} {cmd:List}"
 exit
 }
 if `kVL' <= `kZL' {
noi di 
noi di as err " {bf:Lag Length of Variables ( `ZL' ) = (`kVL')} {cmd:must be Greater than Order of} {bf:pdl(`kZL')}" 
noi di 
noi di as err " the model must be, i.e," 
noi di as err " almon y l(0/3).x1 , zlag(x1) pdl(2) end(0)" 
noi di as err " almon y l(0/3).x1 l(0/3).x2 , zlag(x1 x2) pdl(2 2) end(0 0)" 
 exit
 }
 Poly , rmat(`cmat0') p(`kVL') q(`kZL') ar(`ar') `noconstant' model(`model')
 local kcl= colsof(`cmat0')
 local krr= `kVL'-`kZL'
 local kcr= `kcl'-`krr'-2
 if "`endpr'"!="" {
 local kEnd : word `i' of `endpr'
 if `kEnd' == 1 {
 matrix `cmatl' = `cmat0'[1..1,2..`kcl'],J(1,1,0)
 matrix `cmat'=`cmat0' \ `cmatl'
noi di as err "* `ZL': " "{bf:{cmd:Left Side Endpoint Polynomial Restrictions}}"
 }
 if `kEnd' == 2 {
 matrix `cmatr' = J(1,`krr',0), `cmat0'[1..1,1..`kcr'], J(1,2,0)
 matrix `cmat'=`cmat0' \ `cmatr'
noi di as err "* `ZL': " "{bf:{cmd:Right Side Endpoint Polynomial Restrictions}}"
 }
 if `kEnd' == 3 {
 matrix `cmatl' = `cmat0'[1..1,2..`kcl'],J(1,1,0)
 matrix `cmatr' = J(1,`krr',0), `cmat0'[1..1,1..`kcr'], J(1,2,0)
 matrix `cmat'=`cmat0' \ `cmatl' \ `cmatr'
noi di as err "* `ZL': " "{bf:{cmd:Left & Right Side Endpoint Polynomial Restrictions}}"
 }
 if `kEnd' < 1 {
 matrix `cmat'=`cmat0'
noi di as err "* `ZL': " "{bf:{cmd:No Endpoint Polynomial Restrictions}}"
 }
 }
 else {
 matrix `cmat'=`cmat0'
noi di as err "* `ZL': " "{bf:{cmd:No Endpoint Polynomial Restrictions}}"
 }
 local k = rowsof(`cmat')
 local m1: word `i' of `MVar'
 tsunab MVar1 : `m1'
 tokenize `MVar1'
 `run' `NYvar' `MVar1' , constr(`cmat') `noconstant' `auto' `itern1' `nolog'
 local Qw = `Qw'+`k'
 matrix dispCns , r
 forvalue i = 1/`k' {
 local j =`j'+1
 constraint define `j' `=r(cns`i')'
 } 
 } 

noi di "{cmd:{hline 78}}"
 `run' `NYvar' `MVar' , constr(1-`Qw') `noconstant' `nolog' `auto' `itern1' 
 matrix `restB'= e(Cns)
 matrix `restc' = `restB'
 if "`rest'"!="" {
 matrix `restc' = `restA' \ `restB'
 }
 `run' `NYvar' `MVar' , `noconstant' `nolog' `auto' `itern1' constr(`restc')
 matrix `restc'= e(Cns)
 local Qw= rowsof(`restc')
 matrix dispCns , r
 forvalue i = 1/`Qw' {
 constraint define `i' `=r(cns`i')'
 }
 local krc= colsof(`restc')
 local krc1= `krc'-1
 local krr= rowsof(`restc')
 matrix `Rs' = `restc'[1..`krr', 1..`krc1']
 matrix `Rso'= `restc'[1..`krr', `krc'..`krc']
 local k = `krr'
 keep if `touse'
 mark `miss'
 markout `miss' `yvar' `xvar' `wvar'
 keep if `miss' == 1
 replace `Time'=_n
 tsset `Time'
 count 
 local N=r(N)
 local NT=r(N)
 if "`wvar'"!="" {
 gen double `_Wx_' = `wvar'
 replace `wvar'=`_Wx_'
 }
 if "`tolog'"!="" {
 tempvar xvarexp yvarexp
 gen double `yvarexp'=`yvar'
 replace `yvar'=ln(`yvar')
 if "`wvar'"!="" {
 replace `wvar'=ln(`wvar')
 }
 local vlistlog "`yvar' `xvar' `wvar'"
 _rmcoll `vlistlog' , `noconstant' forcedrop
 local vlistlog "`r(varlist)'"
noi di _dup(78) "-"
noi di as err " {cmd:** Variables Have been Transformed to Log Form **}"
noi di as txt " {cmd:** `NYvar' `NUXvar'} "
 local kvlog: word count `xvar'
 forvalue i=1/`kvlog' {
 local var: word `i' of `xvar'
 replace `var'=ln(`var')
 gen double `xvarexp'_`i'=exp(`var')
 }
 tsunab xvarexp : `xvarexp'_*
 }

 local wgt ""
 gen `X0'=1 
 gen `Wi'=1
 gen `Wi1'= 1
 gen `Wis'= 1
 local WiB =1
 local _Yo "`yvar'"
 local _Zo "`xvar'"
 mkmat `_Yo' , matrix(`Y')
 local k0 =1
 if "`noconstant'"!="" {
 local k0 =0
 mkmat `_Zo' , matrix(`Z')
 }
 else { 
 mkmat `_Zo' `X0' , matrix(`Z')
 }
 local kx=`kx'
 local kb=`kx'+`k0'
 local Jkx=`kx'-`k'
 local Jkb=`kb'-`k'
 local DF=`N'-`Jkb'
 local in=`N'/`DF'
 if "`dn'"!="" {
 local DF=`N'
 local in=1
 }
 local JDF=`DF'

 if "`wvar'"!="" {
 replace `Wi' = (`wvar')^0.5 
 replace `Wis' = `wvar'
 local wtitle "Weighted Variable Type: (X)      -   Variable: (`wvar')"
 if "`weights'"=="" {
 local wgt " [weight = `Wis'] "
 }
 }
 if "`weights'"!="" {
 if !inlist("`weights'", "x", "xi", "x2", "xi2") {
 cap drop `Wi'
 regress `_Yo' `_Zo' , `noconstant'
 predict double `Yho' 
 predict double `Eo' , resid
 regress `Yho' `_Zo' , `noconstant'
 predict double `Wi'
 if inlist("`weights'", "yh") {
 replace `Wi' = abs(`Wi')^0.5 
 local wtitle "Weighted Variable Type: (Yh)     -   Variable: Yh Predicted Value"
 }
 if inlist("`weights'", "abse") {
 local wtitle "Weighted Variable Type: (absE)   -   Variable: abs(E) Residual Absolute Value"
 replace `Wi' = abs(`Eo')^0.5 
 }
 if inlist("`weights'", "e2") {
 local wtitle "Weighted Variable Type: (E2)     -   Variable: E^2 Residual Squared"
 replace `Wi' = (`Eo'^2)^0.5 
 }
 if inlist("`weights'", "yh2") {
 cap drop `Wi'
 local wtitle "Weighted Variable Type: (Yh2)    -   Variable: Yh^2 Predicted Value Squared"
 gen double `Yho2' = `Yho'^2 
 regress `Yho2' `_Zo' , `noconstant'
 predict double `Wi' , xb
 replace `Wi' = abs(`Wi')^0.5 
 } 
 }
 if inlist("`weights'", "x") {
 local wtitle "Weighted Variable Type: (X)      -   Variable: (`wvar')"
 replace `Wi' = (`wvar')^0.5 
 } 
 if inlist("`weights'", "xi") {
 local wtitle "Weighted Variable Type: (Xi)     -   Variable: (1/`wvar')"
 replace `Wi' = 1/(`wvar'^0.5) 
 } 
 if inlist("`weights'", "x2") {
 local wtitle "Weighted Variable Type: (X2)     -   Variable: (`wvar')^2"
 replace `Wi' = (`wvar')
 } 
 if inlist("`weights'", "xi2") {
 local wtitle "Weighted Variable Type: (Xi2)    -   Variable: (1/`wvar')^2"
 replace `Wi' = 1/(`wvar')
 }
 replace `Wi' = 0 if `Wi'==.
 replace `Wis' =`Wi'^2 
 local wgt " [weight = `Wis'] "
 }
 if "`wvar'"!="" | "`weights'"!="" {
 if inlist("`model'", "bcox") {
 local wgt " [iweight = `Wis'] "
 }
 summ `Wi' 
 local WiB =r(mean)
 summ `Wis' 
 replace `Wi1'= sqrt(`Wis'/r(mean)) 
 }
 mkmat `Wi1' , matrix(`Wi1')
 matrix `Wi1' = diag(`Wi1')
 mkmat `Wi' , matrix(`Wi')
 matrix `Wi'= diag(`Wi')
 matrix `Omega'=`Wi''*`Wi'
 matrix `Yws'=`Wi'*`Y'
 matrix `Zws'=`Wi'*`Z'
 matrix `ZoZ'=`Z''*`Z'
 matrix `ZwZ'=`Zws''*`Zws'
 scalar `Kr'=0
 matrix `Zz'=I(`kb')*0
 local kxy =`kx'+1
 gen double `Zo'= `Wi'
 gen `Zw'=.
 local Yw_Zw "`X0' `_Yo' `_Zo'"
 local kXw: word count `Yw_Zw'
 forvalue i=1/`kXw' {
 local v : word `i' of `Yw_Zw'
 replace `Zw' = `v'*`Wi'
 gen double `WLSVar'_`i' = `Zw'
 }
 tsunab ZWLSVar : `WLSVar'_*
 tokenize `ZWLSVar'
 local Zo `1'
 macro shift
 local bXWLS "`*'"
 gettoken _Yw _Zw : bXWLS

 if "`ridge'"!="" {
 scalar `Kr'=`kr'
 local Ro1= 0 
 replace `Zo' = `WiB'
 if inlist("`model'", "als") & `ar' == 1 {
 if "`noconstant'"!="" {
 prais `_Yw' `_Zw' , noconstant rhotype(regress)
 }
 else {
 prais `_Yw' `_Zw' `Zo' , noconstant rhotype(regress)
 }
 local Ro1= e(rho) 
 tempvar WLSVar
 local Yw_Zw "`_Yw' `_Zw'"
 local kXw: word count `Yw_Zw'
 forvalue i=1/`kXw' {
 local v : word `i' of `Yw_Zw'
 replace `Zw' = `v'
 gen double `WLSVar'_`i' = `Zw'-`Ro1'*`Zw'[_n-1] 
 replace `WLSVar'_`i' = `Zw'*sqrt(1-`Ro1'^2) in 1
 }
 tsunab ZWLSVar : `WLSVar'_*
 tokenize `ZWLSVar'
 local _Yw `1'
 macro shift
 local _Zw "`*'"
 tokenize `_Zw'
 replace `Zw' = `WiB'
 replace `Zo' = `Zw'-`Ro1'*`Zw'[_n-1] 
 replace `Zo' = `Zw'*sqrt(1-`Ro1'^2) in 1
 }
 local Zo_Zw "`Zo' `_Zw'"
 local kXw: word count `Zo_Zw'
 forvalue i=1/`kXw' {
 local v : word `i' of `Zo_Zw'
 if "`noconstant'"!="" {
 gen double `SLSVar'_`i' = `v'
 }
 else {
 summ `v'
 gen double `SLSVar'_`i' = `v'  - r(mean)
 }
 }
 tsunab ZSLSVar : `SLSVar'_*
 tokenize `ZSLSVar'
 local ZoC `1'
 macro shift
 local ZSLSVar "`*'"
 if !inlist("`model'", "als") & `ar' == 1 {
 replace `ZoC' = 0
 }
 mkmat `_Yw' , matrix(`Yws')
 if "`noconstant'"!="" {
 mkmat `ZSLSVar' , matrix(`Zr')
 mkmat `_Zw' , matrix(`Zws')
 tabstat `_Zw' , statistics( sd ) save
 }
 else {
 mkmat `ZSLSVar' `ZoC' , matrix(`Zr')
 mkmat `_Zw' `Zo' , matrix(`Zws')
 tabstat `_Zw' `ZoC' , statistics( sd ) save
 }
 if inlist("`ridge'", "orr") {
 local rtitle "{bf:Ordinary Ridge Regression}"
 }
 if inlist("`ridge'", "grr1") {
 local rtitle "{bf:Generalized Ridge Regression}"
 matrix `sd'=r(StatTotal)
 scalar `sqN'=sqrt(`N'-1)
 matrix `WMTD'=diag(`sd')*`sqN'
 matrix `Beta'=invsym(`Zws''*`Zws')*`Zws''*`Yws'
 matrix `BOLS'=`WMTD''*`Beta'
 matrix `BOLS'=`BOLS''*`BOLS'
 scalar `BOLS1'=`BOLS'[1,1]
 matrix `Sig2o'=`Yws'-`Zws'*`Beta'
 matrix `Sig2o'=(`Sig2o''*`Sig2o')/`DF'
 scalar `Sig2o1'=`Sig2o'[1,1]
 scalar `Kr'=`kx'*`Sig2o1'/`BOLS1'
 }
 if inlist("`ridge'", "grr2") {
 local rtitle "{bf:Iterative Generalized Ridge Regression}"
 matrix `sd'=r(StatTotal)
 scalar `sqN'=sqrt(`N'-1)
 matrix `WMTD'=diag(`sd')*`sqN'
 matrix `Beta'=invsym(`Zws''*`Zws')*`Zws''*`Yws'
 matrix `BOLS'=`WMTD''*`Beta'
 matrix `BOLS'=`BOLS''*`BOLS'
 scalar `BOLS1'=`BOLS'[1,1]
 matrix `Sig2o'=`Yws'-`Zws'*`Beta'
 matrix `Sig2o'=(`Sig2o''*`Sig2o')/`DF'
 scalar `Sig2o1'=`Sig2o'[1,1]
 scalar `Kr'=`kx'*`Sig2o1'/`BOLS1'
 forvalue i=1/`iter' { 
 scalar `Ko'=`Kr'
 matrix `rid'=I(`kb')*`Kr'
 matrix `Zz'=diag(vecdiag(`Zr''*`Zr'*`rid'))
 matrix `Beta'=invsym(`Zws''*`Zws'+`Zz')*`Zws''*`Yws'
 matrix `BOLS'=`WMTD''*`Beta'
 matrix `BOLS'=`BOLS''*`BOLS'
 scalar `BOLS1'=`BOLS'[1,1]
 tempname Kit`i' Koi
 scalar `Kit`i''=`kx'*`Sig2o1'/`BOLS1'
 scalar `Kr'=`Kit`i''
 if `Kr'==. {
 scalar `Kr'=0
 }
 scalar `Koi'=abs(`Kr'-`Ko')
 if (`Koi' <= `tolerance') {
 continue, break
 }
 }
 }
 if inlist("`ridge'", "grr3") {
 local rtitle "{bf:Adaptive Generalized Ridge Regression}"
 corr `_Zw' `_Yw'
 matrix `CovC'=r(C)
 matrix `RY' = `CovC'[`kb' ,1..`kx']
 matrix `RX' = `CovC'[1..`kx', 1..`kx']
 matrix symeigen `Vec' `VaL'=`RX'
 matrix `VaL1' =`VaL''
 svmat `VaL1' , name(`VaL1')
 rename `VaL1'1 `VaL1'
 replace `VaL1'=1/`VaL1' in 1/`kx' 
 mkmat `VaL1' in 1/`kx' , matrix(`VaLv1')
 matrix `VaL21' =diag(`VaLv1')
 matrix `VaL21' = `VaL21'[1..`kx', 1..`kx']
 matrix `Go'=`Vec'*`VaL21'*`Vec''
 matrix `GoRY'=`Go'*`RY''
 matrix `SSE'=1-`RY'*`GoRY'
 matrix `Sig2'=`SSE'/`DF'
 matrix `Qr'=`GoRY''*`GoRY'-`Sig2'*trace(`Go')
 matrix `LVR'=`Vec''*`RY''
 svmat `LVR' , name(`LVR')
 rename `LVR'1 `LVR'
 scalar `Kr'=0
 forvalue i=1/`iter' { 
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
 matrix `Lms'=`LVR''*`IDRmk'
 matrix `Lms'=(`Lms'*diag(`LVR'))'
 cap drop `Lms' `lf'
 svmat `Lms' , name(`Lms'`i')
 rename `Lms'`i'1 `Lms'`i'
 summ `Lms'`i' in 1/`kx'
 scalar `SLS'=r(sum)
 gen double `lf'`i'=`LVR'/`f1' in 1/`kx'
 mkmat `lf'`i' in 1/`kx' , matrix(`lf'`i')
 matrix `lf'`i' =diag(`lf'`i')
 matrix `lf'`i' = `lf'`i'[1..`kx', 1..`kx']
 matrix `lf'`i' = vecdiag(`lf'`i')'
 matrix `F'=`lf'`i''*`lf'`i'-`Qr'
 scalar `Kk'`i'=`Ko`i''+(0.5*`F'[1,1]/`SLS')
 scalar `Kr'=`Kk'`i'
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
 }

 if inlist("`model'", "qreg", "rreg") {
 if inlist("`model'", "qreg") {
 qreg `_Yo' `_Zo' `wgt' , nolog `leveln' quantile(`quantile')
 local R2_P = 1 - (e(sum_adev)/e(sum_rdev))
 }
 if inlist("`model'", "rreg") {
 rreg `_Yo' `_Zo' , `itern' nolog `leveln' tune(`tune')
 local R2_P = e(r2)
 }
 matrix `B'=e(b)'
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 matrix `Yh_ML' = (`Z'*`B')
 matrix `Ue_ML' = (`Y'-`Z'*`B')
 }

 if inlist("`model'", "arch") {
 arch `_Yo' `_Zo' `wgt' , `noconstant' nolog `vcen' `techn' `itern' `leveln' `auto' constr(`restc')
 scalar `wald'= e(chi2)
 scalar `waldp'= e(p)
 local LLFs=e(ll)
 matrix `B'=e(b)
 matrix `B' = `B'[1, 1..`kb']'
 matrix `Cov'=e(V)
 matrix `Cov'=`Cov'[1..`kb' ,1..`kb']
 predict double `Ue_ML' , resid
 predict double `Yh_ML' , xb
 mkmat `Ue_ML' , matrix(`Ue_ML')
 mkmat `Yh_ML' , matrix(`Yh_ML')
 }

 if inlist("`model'", "bcox") {
 if inlist("`lamp'", "lhs") {
 boxcox `_Yo' `xvar' `wgt' , model(lhsonly) `noconstant' nolog `itern' `leveln'
 local Lam=_b[theta:_cons]
 gen double `YBox'=(`_Yo'^`Lam'-1)/`Lam'
 tsunab ZBox : `xvar'
 }
 else {
 if inlist("`lamp'", "rhs") {
 boxcox `_Yo' `xvar' `wgt' , model(rhsonly) `noconstant' nolog `itern' `leveln'
 local Lam=_b[lambda:_cons]
 gen double `YBox'=`_Yo'
 local kBox : word count `xvar'
 forvalue i=1/`kBox' {
 local var: word `i' of `xvar'
 gen double `ZBoxL'`i'=(`var'^`Lam'-1)/`Lam'
 }
 }
 if inlist("`lamp'", "alls") {
 boxcox `_Yo' `xvar' `wgt' , model(lambda) `noconstant' nolog `itern' `leveln'
 local Lam=_b[lambda:_cons]
 gen double `YBox'=(`_Yo'^`Lam'-1)/`Lam'
 foreach var of local xvar {
 gen double `ZBoxL'`var'=(`var'^`Lam'-1)/`Lam'
 }
 }
 if inlist("`lamp'", "alld") {
 boxcox `_Yo' `xvar' `wgt' , model(theta) `noconstant' nolog `itern' `leveln'
 local Lam=_b[theta:_cons]
 gen double `YBox'=(`_Yo'^`Lam'-1)/`Lam'
 local Gam=_b[lambda:_cons]
 foreach var of local xvar {
 gen double `ZBoxL'`var'=(`var'^`Gam'-1)/`Gam'
 }
 }
 tsunab ZBox : `ZBoxL'*
 }
 local LLFs=e(ll)
 predict double `Ue_ML' , resid
 predict double `Yhs' , xbt
 predict double `Yh_ML' , yhat
 regress `YBox' `ZBox' `wgt' , `noconstant' `leveln'
 matrix `B'=e(b)'
 matrix `Cov'=e(V)
 scalar `Sig2n'=e(rss)/`DF'
 tempvar Yh_ML Ue_ML Yhs
 predict double `Yhs' , xb
 if inlist("`lamp'", "lhs", "alls", "alld") {
 gen double `Yh_ML'=(`Yhs'*`Lam'+1)^(1/`Lam')
 gen double `Ue_ML' =`_Yo'-`Yh_ML'
 summ `Yh_ML'
 if r(N) ==0 {
 replace `Yh_ML'=`Yhs'
 }
 }
 if inlist("`lamp'", "rhs") {
 gen double `Yh_ML'=(`Yhs'*`Lam'+1)^(1/`Lam')
 gen double `Ue_ML' =`_Yo'-`Yhs'
 summ `Yh_ML'
 if r(N) ==0 {
 replace `Yh_ML'=`Yhs'
 }
 }
 local _Yw "`YBox'"
 local _Zw "`ZBox'"
 mkmat `Ue_ML' , matrix(`Ue_ML')
 mkmat `Yh_ML' , matrix(`Yh_ML')
 if "`ridge'"!="" & `kr' > 0 {
 tempvar SLSVar
 local Zo_Zw "`Zo' `_Zw'"
 local kXw: word count `Zo_Zw'
 forvalue i=1/`kXw' {
 local v : word `i' of `Zo_Zw'
 if "`noconstant'"!="" {
 gen double `SLSVar'_`i' = `v'
 }
 else {
 summ `v'
 gen double `SLSVar'_`i' = `v' - r(mean)
 }
 }
 tsunab ZSLSVar : `SLSVar'_*
 tokenize `ZSLSVar'
 local ZoC `1'
 macro shift
 local ZSLSVar "`*'"
 mkmat `_Yw' , matrix(`Yws')
 if "`noconstant'"!="" {
 mkmat `ZSLSVar' , matrix(`Zr')
 mkmat `_Zw' , matrix(`Zws')
 }
 else {
 mkmat `ZSLSVar' `ZoC' , matrix(`Zr')
 mkmat `_Zw' `Zo' , matrix(`Zws')
 }
 matrix `Zz'=diag(vecdiag((`Zr''*`Zr')*`rid'))
 matrix `ZwZ'=`Zws''*`Zws'
 matrix `B'=invsym(`ZwZ'+`Zz')*`Zws''*`Yws' 
 }
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 tempvar Yh_ML Ue_ML Yhs
 matrix `Yhs'=(`Zws'*`B')
 svmat `Yhs' , name(`Yhs')
 replace `Yhs'= `Yhs'1 
 if inlist("`lamp'", "lhs", "alls", "alld") {
 gen double `Yh_ML'=(`Yhs'*`Lam'+1)^(1/`Lam')
 gen double `Ue_ML' =`_Yo'-`Yh_ML'
 }
 if inlist("`lamp'", "rhs") {
 gen double `Yh_ML'=(`Yhs'*`Lam'+1)^(1/`Lam')
 gen double `Ue_ML' =`_Yo'-`Yhs'
 }
 mkmat `Ue_ML' , matrix(`Ue_ML')
 mkmat `Yh_ML' , matrix(`Yh_ML')
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 if "`ridge'"!="" & `kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')-`Sig2'*invsym(`ZwZ'+`Zz')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 }
 }

 if inlist("`model'", "als") & `ar'>1 {
 arima `_Yo' `_Zo' `wgt' , `noconstant' nolog `vcen' `techn' `itern' `leveln' `auto' ///
 constr(`restc') `condition'
 scalar `wald'= e(chi2)
 scalar `waldp'= e(p)
 local LLFs=e(ll)
 matrix `B'=e(b)
 matrix `B' = `B'[1, 1..`kb']'
 matrix `Cov'=e(V)
 matrix `Cov'=`Cov'[1..`kb' ,1..`kb']
 predict double `Ue_ML' , resid
 predict double `Yh_ML' , xb
 mkmat `Ue_ML' , matrix(`Ue_ML')
 mkmat `Yh_ML' , matrix(`Yh_ML')
 }

 if inlist("`model'", "als") & `ar' == 1 {
 tempname R1 SSEo Ro1 it
 tempvar WLSVar SLSVar ZoC SLSVarC Zw
 scalar `R1'=0
 local iter=`iter'+1
 regress `_Yo' `_Zo' `wgt' , `noconstant' `leveln' `robust'
 scalar `SSEo' = e(rss)
 local LLFs=e(ll)
 if "`twostep'"!="" {
 local iter=2
 }
noi di "{cmd:{hline 78}}"
noi di as txt "{bf:{err:* Beach-Mackinnon AR(1) Autoregressive Maximum Likelihood Estimation}}"
noi di as txt _col(5) "Iteration" _col(21) "Rho" _col(37) "LLF" _col(51) "SSE"
 gen `Zw'=.
 scalar `Ro1' = 2
 forvalue i = 1/`iter' {
 scalar `Ro1'=`R1'
 scalar `it'=`i'-1
noi di as txt _col(5) `it' _col(20) as res %10.6f `R1' _col(35) as res %10.4f `LLFs' _col(50) as res %10.4f `SSEo'
 tempvar WLSVar SLSVar ZoC SLSVarC
 local Yw_Zw "`_Yo' `_Zo'"
 local kXw: word count `Yw_Zw'
 forvalue i=1/`kXw' {
 local v : word `i' of `Yw_Zw'
 replace `Zw' = `v'*`Wi'
 gen double `WLSVar'_`i' = `Zw'-`Ro1'*`Zw'[_n-1] 
 replace `WLSVar'_`i' = `Zw'*sqrt(1-`Ro1'^2) in 1
 }
 tsunab ZWLSVar : `WLSVar'_*
 tokenize `ZWLSVar'
 local _Yw `1'
 macro shift
 local _Zw "`*'"
 tokenize `_Zw'
 replace `Zw' = `WiB'
 replace `Zo' = `Zw'-`Ro1'*`Zw'[_n-1] 
 replace `Zo' = `Zw'*sqrt(1-`Ro1'^2) in 1
 mkmat `_Yw' , matrix(`Yws')
 if "`noconstant'"!="" {
 mkmat `_Zw' , matrix(`Zws')
 }
 else {
 mkmat `_Zw' `Zo' , matrix(`Zws')
 }
 if "`ridge'"!="" & `kr' > 0 {
 tempvar SLSVar
 local Zo_Zw "`Zo' `_Zw'"
 local kXw: word count `Zo_Zw'
 forvalue i=1/`kXw' {
 local v : word `i' of `Zo_Zw'
 if "`noconstant'"!="" {
 gen double `SLSVar'_`i' = `v'
 }
 else {
 summ `v'
 gen double `SLSVar'_`i' = `v' - r(mean)
 }
 }
 tsunab ZSLSVar : `SLSVar'_*
 tokenize `ZSLSVar'
 local ZoC `1'
 macro shift
 local ZSLSVar "`*'"
 if "`noconstant'"!="" {
 mkmat `ZSLSVar' , matrix(`Zr')
 tabstat `_Zw' , statistics( sd ) save
 }
 else {
 mkmat `ZSLSVar' `ZoC' , matrix(`Zr')
 tabstat `_Zw' `ZoC' , statistics( sd ) save
 }
 matrix `rid'=I(`kb')*`Kr'
 matrix `Zz'=diag(vecdiag((`Zr''*`Zr')*`rid'))
 }
 matrix `B'=invsym(`Zws''*`Zws'+`Zz')*`Zws''*`Yws'
 matrix `ZwZ'=`Zws''*`Zws'
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 matrix `Ue_ML'=(`Yws'-`Zws'*`B')
 matrix `Ue_MLs'=(`Yws'-`Zws'*`B')
 matrix `Yh_MLs'=(`Zws'*`B')
 matrix `SSE'=`Ue_ML''*`Ue_ML'
 scalar `SSEo'=`SSE'[1,1]
 scalar `Sig2'=`SSEo'/`DF'
 cap drop `E'
 cap drop `LE1'
 svmat `E' , name(`E')
 replace `E'= `E'1 
 gen double `LE1' =L1.`E'
 replace `LE1'=0 in 1/1
 regress `E' `LE1' , noconstant
 tempvar E1 E2 E12 EE1
 scalar `E11'=`E'^2
 gen double `E2'=`E'^2 
 replace `E2'= 0 in 1/1
 gen double `E1'=L1.`E' 
 gen double `E12'=L1.`E'^2 
 gen double `EE1'=L1.`E'*`E' 
 summ `E2' 
 scalar `SE2'=r(sum)
 summ `E1' 
 scalar `SE1'=r(sum)
 summ `E12' 
 scalar `SE12'=r(sum)
 summ `EE1' 
 scalar `SEE1'=r(sum)
 scalar `Aa'=-(`N'-2)*`SEE1'/((`N'-1)*(`SE12'-`E11'))
 scalar `Bb'=((`N'-1)*`E11'-`N'*`SE12'-`SE2')/((`N'-1)*(`SE12'-`E11'))
 scalar `Cc'=`N'*`SEE1'/((`N'-1)*(`SE12'-`E11'))
 scalar `Ss'=`Bb'-(`Aa'^2/3)
 scalar `Qq'=`Cc'-(`Aa'*`Bb'/3)+(2*`Aa'^3/27)
 scalar `Phi'=acos((`Qq'*27^0.5)/(2*`Ss'*(-`Ss')^0.5))
 scalar `R1'=-(`Aa'/3)-2*(-`Ss'/3)^0.5*cos((`Phi'/3)+(_pi/3))
 scalar `Roi'=abs(`R1'-`Ro1')
 local LLFs=0.5*ln(1-`R1'^2)-(`N'/2)*ln(2*_pi*`SSEo'/`N')-(`N'/2)
 if (`Roi' <= `tolerance') {
 continue, break
 }
 }
 if "`ridge'"!="" & `kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')-`Sig2'*invsym(`ZwZ'+`Zz')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 }
 matrix `Ue_ML'=(`Yws'-`Zws'*`B')
 matrix `Yh_ML'=`Y'-`Ue_ML' 
 } 

 if `iter' == e(ic) {
noi di 
noi di as err " {bf:** Convergence has not Achieved, try to increase number of iterations **}"
 }

 if inlist("`model'", "ols", "gls") {
 matrix `ZwZ'=`Zws''*`Zws'
 matrix `B'=invsym(`Zws''*`Zws'+`Zz')*`Zws''*`Yws'
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 if "`ridge'"!="" & `kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')-`Sig2'*invsym(`ZwZ'+`Zz')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 }
 matrix `Yh_ML'=(`Z'*`B')
 matrix `Ue_ML'=(`Y'-`Z'*`B')
 }

 if inlist("`model'", "gmm") {
 if "`hetcov'"=="" {
 local hetcov "white"
 }
 if inlist("`hetcov'", "crag") { 
noi di as txt "{bf:{err:* Cragg (1983) Auxiliary Variables Regression}}"
 matrix `B'=invsym(`Zws''*`Zws'+`Zz')*`Zws''*`Yws'
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 matrix `Eo'=diag(`E')
 matrix `OM'=`Eo'*`Eo'
 foreach var of local _Zo {
 gen double `XQ'`var' = `var'^2 
 }
 mkmat `XQ'* , matrix(`XQ')
 matrix `Q'=`Z' , `XQ' 
 matrix `Q'=`Wi'*`Q'
 matrix `OmegaG'=`Q'*invsym(`Q''*`OM'*`Q')*`Q''
 matrix `B'=invsym(`Zws''*`OmegaG' *`Zws'+`Zz')*(`Zws''*`OmegaG' *`Yws')
 matrix `B'=`B'+(invsym(`ZwZ')*`Rs''*invsym(`Rs'*invsym(`ZwZ')*`Rs'')*(`Rso'-`Rs'*`B'))
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 if "`ridge'"!="" & `kr' > 0 {
 matrix `Cov'=`Sig2'*(invsym(`ZwZ'+`Zz')-invsym(`ZwZ'+`Zz')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz'))
 }
 else {
 matrix `Cov'=`Sig2'*(invsym(`ZwZ')-invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ'))
 }
 }

 if inlist("`hetcov'", "hdun") { 
noi di as txt "{bf:{err:* Horn-Duncan (1975) Regression}}"
 matrix `HT' = vecdiag(`Zws'*invsym(`Zws''*`Zws')*`Zws'')'
 svmat `HT' , name(`HT')
 gen double `DX'=(1-`HT'1)
 matrix `B'=invsym(`Zws''*`Zws'+`Zz')*`Zws''*`Yws'
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 matrix `Eo'=diag(`E')
 matrix `OM'=vecdiag(`Eo'*`Eo')'
 svmat `OM' , name(`Es2')
 rename `Es2'1 `Es2'
 gen double `OM' =`Es2'/`DX' 
 mkmat `OM' , matrix(`OM')
 matrix `OM'=diag(`OM')
 matrix `OmegaG'=`Zws'*invsym(`Zws''*`OM'*`Zws')*`Zws''
 matrix `B'=invsym(`Zws''*`OmegaG'*`Zws'+`Zz')*`Zws''*`OmegaG'*`Yws'
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 if "`ridge'"!="" & `kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')-`Sig2'*invsym(`ZwZ'+`Zz')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 }
 }
 
 if inlist("`hetcov'", "hink") { 
noi di as txt "{bf:{err:* Hinkley (1977) Method Regression}}"
 matrix `B'=invsym(`Zws''*`Zws'+`Zz')*`Zws''*`Yws'
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 matrix `Eo'=diag(`E')
 matrix `OM'=`Eo'*`Eo'
 if "`ridge'"!="" & `kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')-`Sig2'*invsym(`ZwZ'+`Zz')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`in'*invsym(`Zws''*`Zws')*(`Zws''*`OM'*`Zws')*invsym(`Zws''*`Zws')
 }
 }

 if inlist("`hetcov'", "jack") { 
noi di as txt "{bf:{err:* Jackknife Mackinnon-White (1985) Regression}}"
 tempvar E Eo Yh
 matrix `B'=invsym(`Zws''*`Zws'+`Zz')*`Zws''*`Yws'
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 matrix `Yh'=`Wi1'*(`Z'*`B')
 svmat `Yh' , name(`Yh')
 rename `Yh'1 `Yh'
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 svmat `E' , name(`Eo')
 rename `Eo'1 `Eo'
 matrix `HT' = vecdiag(`Zws'*invsym(`Zws''*`Zws')*`Zws'')'
 svmat `HT' , name(`HT')
 gen double `DX'=(1-`HT'1)
 gen double `Es'=(`Eo'/`DX') 
 gen double `Es2'=(`Eo'/`DX')^2 
 mkmat `Es' , matrix(`Es')
 gen double `OM' =`Es2' 
 mkmat `OM' , matrix(`OM')
 matrix `OM'=diag(`OM')
 gen double `EP'=((`N'-1)/`N')*`Eo'/(1-`HT') 
 gen double `NY'=`Yh'+`EP' 
 mkmat `NY' , matrix(`NY')
 matrix `B'=invsym(`Zws''*`Zws'+`Zz')*(`Zws''*`NY')
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 if "`ridge'"!="" & `kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')-`Sig2'*invsym(`ZwZ'+`Zz')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=((`N'-1)/`N')*invsym(`ZwZ')*(`Zws''*`OM'*`Zws' ///
 -(1/`N')*(`Zws''*`Es'*`Es''*`Zws'))*invsym(`ZwZ')
 }
 }

 if inlist("`hetcov'", "white") {
noi di as err " *** Generalized Method of Moments (GMM) - (White Method) ***"
 matrix `B'=invsym(`Zws''*`Zws'+`Zz')*`Zws''*`Yws'
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 matrix `OM'=diag(`E')
 matrix `OmegaG'=`OM'*`OM'
 if "`ridge'"!="" & `kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')-`Sig2'*invsym(`ZwZ'+`Zz')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=invsym(`Zws''*`Zws')*(`Zws''*`OmegaG'*`Zws')*invsym(`Zws''*`Zws')
 }
 }

 if inlist("`hetcov'", "bart") {
noi di as err " *** Generalized Method of Moments (GMM) - (Bartlett Method) ***"
 local i=1
 local LGm=4*(`N'/100)^(2/9)
 local Li=`i'/(1+`LGm')
 local kw=1-`Li'
 }
 if inlist("`hetcov'", "dan") {
noi di as err " *** Generalized Method of Moments (GMM) - (Daniell Method) ***"
 local i=1
 local LGm=4*(`N'/100)^(2/9)
 local Li=`i'/(1+`LGm')
 local kw=sin(_pi*`Li')/(_pi*`Li')
 }
 if inlist("`hetcov'", "nwest") {
noi di as err " *** Generalized Method of Moments (GMM) - (Newey-West Method) ***"
 local i=1
 local LGm=1
 local Li=`i'/(1+`LGm')
 local kw=1-`Li'
 }
 if inlist("`hetcov'", "parzen") {
noi di as err " *** Generalized Method of Moments (GMM) - (Parzen Method) ***"
 local i=1
 local LGm=4*(`N'/100)^(2/9)
 local Li=`i'/(1+`LGm')
 local kw=1-`Li'
 if (`Li' < 0.05) { 
 local kw=1-6*`Li'^2+6*`Li'^3
 else { 
 local kw=2*(1-`Li')^2
 }
 }
 if (`Li' < 0.5) { 
 local kw=1-6*`Li'^2+6*`Li'^3
 else { 
 local kw=2*(1-`Li')^3
 }
 }
 }
 if inlist("`hetcov'", "quad") {
noi di as err " *** Generalized Method of Moments (GMM) - (Quadratic Spectral Method) ***"
 local i=1
 local LGm=4*(`N'/100)^(2/25)
 local Li=`i'/(1+`LGm')
 local kw=(25/(12*_pi^2*`Li'^2))*(sin(6*_pi*`Li'/5)/(6*_pi*`Li'/5)-sin(6*_pi*`Li'/5+_pi/2))
 }
 if inlist("`hetcov'", "tent") {
noi di as err " *** Generalized Method of Moments (GMM) - (Tent Method) ***"
 local i=1
 local LGm=4*(`N'/100)^(2/9)
 local Li=`i'/(1+`LGm')
 local kw=2*(1-cos(`Li'*`Li'))/(`Li'^2)
 }
 if inlist("`hetcov'", "trunc") {
noi di as err " *** Generalized Method of Moments (GMM) - (Truncated Method) ***"
 local i=1
 local LGm=4*(`N'/100)^(1/4)
 local Li=`i'/(1+`LGm')
 local kw=1-`Li'
 }
 if inlist("`hetcov'", "tukey") {
noi di as err " *** Generalized Method of Moments (GMM) - (Tukey Method) ***"
 local i=1
 local LGm=4*(`N'/100)^(2/25)
 local Li=`i'/(1+`LGm')
 local kw=1-`Li'
 }
 if inlist("`hetcov'", "tukeym") {
noi di as err " *** Generalized Method of Moments (GMM) - (Tukey-Hamming Method) ***"
 local i=1
 local LGm=4*(`N'/100)^(1/4)
 local Li=`i'/(1+`LGm')
 local kw=0.54+0.46*cos(_pi*`Li')
 }
 if inlist("`hetcov'", "tukeyn") {
noi di as err " *** Generalized Method of Moments (GMM) - (Tukey-Hanning Method) ***"
 local i=1
 local LGm=4*(`N'/100)^(1/4)
 local Li=`i'/(1+`LGm')
 local kw=(1+sin((_pi*`Li')+_pi/2))/2
 }

 if !inlist("`hetcov'", "white", "crag", "hink", "hdun", "jack") {
 gen `Z0' = 1 
 replace `Z0' = 0 in 1
 foreach var of local _Zo {
 gen double `XQ'`var' = `var'[_n-1]
 replace `XQ'`var' = 0 in 1
 }
 if "`noconstant'"!="" {
 mkmat `XQ'* , matrix(`M')
 }
 else {
 mkmat `XQ'* `Z0' , matrix(`M')
 }
 matrix `M'=`Wi'*`M'
 matrix `B'=invsym(`Zws''*`Zws'+`Zz')*`Zws''*`Yws'
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 svmat `E' , name(`Eg')
 rename `Eg'1 `Eg'
 gen double `E1'=`Eg'[_n-1] 
 gen double `EE1'=`E1'*`Eg' 
 replace `EE1' = 0 if `EE1'==.
 mkmat `EE1' , matrix(`EE1')
 matrix `OM'=diag(`E')
 matrix `We'=`OM'*`OM'
 matrix `Sw'=`Zws''*`We'*`Zws'
 matrix `We'=diag(`EE1')
 matrix `S11'=`Zws''*`We'*`M'
 matrix `S12'=`M''*`We'*`Zws'
 matrix `Sn'=(`S11'+`S12')*`kw'
 matrix `nw'=(`Sw'+`Sn')*`in'
 matrix `OmegaG'=`Zws'*invsym(`Zws''*`Zws')*`Zws''
 matrix `B'=invsym(`Zws''*`OmegaG' *`Zws'+`Zz')*(`Zws''*`OmegaG' *`Yws')
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 if "`ridge'"!="" & `kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')-`Sig2'*invsym(`ZwZ'+`Zz')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 }
 }
 matrix `Ue_ML' = (`Y'-`Z'*`B')
 matrix `Yh_ML' = (`Z'*`B')
noi di _dup(78) "-"
 }
 
tempvar E Yh
tempname SSEo Sigo r2bu r2bu_a r2raw r2raw_a R20 f fp Phi
tempname r2v r2v_a fv fvp r2h r2h_a fh fhp SSTm SSE1 SST11 SST21 Rho D DJ11 DJ20 DJ22
 if inlist("`model'", "bcox") {
 local wgt " [weight = `Wis'] "
 }
 if "`noconstant'"!="" {
 local Zo ""
 }
 else { 
 local Zo "`Zo'"
 }
 if !inlist("`model'", "arch", "bcox", "qreg") {
 matrix `Ue_ML' = `Wi1'*(`Ue_ML')
 matrix `Yh_ML' = `Wi1'*(`Yh_ML')
 }
 if inlist("`model'", "als") & `ar'>1 {
 matrix `Ue_ML' = `Wi1'*(`Ue_ML')
 matrix `Yh_ML' = `Wi1'*(`Yh_ML')
 }
 matrix `Ue_MLo' = (`Y'-`Z'*`B')
 matrix `Yh_MLo' = (`Z'*`B')
 matrix `U' =`Ue_MLo'
 if inlist("`model'", "als") & `ar' == 1 {
 matrix `U' =`Ue_MLs'
 }
 mata: `Yh_MLo' = st_matrix("`Yh_MLo'")
 mata: `Ue_MLo' = st_matrix("`Ue_MLo'")
 getmata `Yh_MLo' , force replace
 getmata `Ue_MLo' , force replace
 mata: `Yh_ML' = st_matrix("`Yh_ML'")
 mata: `Ue_ML' = st_matrix("`Ue_ML'")
 getmata `Yh_ML' , force replace
 getmata `Ue_ML' , force replace
 mkmat `Yh_ML' , matrix(`Yh_ML')
 mkmat `Ue_ML' , matrix(`Ue_ML')
 gen double `Yh'=`Yh_ML' 
 gen double `E' =`Ue_ML' 
 matrix `SSE'=`U''*`U'
 scalar `SSEo'=`SSE'[1,1]
 scalar `Sig2o'=`SSEo'/`DF'
 scalar `Sig2n'=`SSEo'/`N'
 scalar `Sigo'=sqrt(`Sig2o')
 summ `Yh_MLo' `wgt'
 local NUM=r(Var)
 summ `_Yo' `wgt'
 local DEN=r(Var)
 scalar `r2v'=`NUM'/`DEN'
 scalar `r2v_a'=1-((1-`r2v')*(`N'-1)/`JDF')
 scalar `fv'=`r2v'/(1-`r2v')*(`N'-`Jkb')/(`Jkx')
 scalar `fvp'=Ftail(`Jkx', `JDF', `fv')
 if "`wvar'"!="" | "`weights'"!="" {
 correlate `Yh_MLo' `_Yo' `wgt'
 }
 else {
 correlate `Yh_ML' `_Yo'
 }
 scalar `r2h'=r(rho)*r(rho)
 scalar `r2h_a'=1-((1-`r2h')*(`N'-1)/`JDF')
 scalar `fh'=`r2h'/(1-`r2h')*(`N'-`Jkb')/(`Jkx')
 scalar `fhp'=Ftail(`Jkx', `JDF', `fh')
 matrix `P' =(`Wi1')
 matrix `IPhi'=`P''*`P'
 matrix `Phi'=inv(`P''*`P')
 matrix `J'= J(`N',1,1)
 matrix `DJ11'=(`J'*`J''*`IPhi')
 matrix `DJ20'=(`J''*`IPhi'*`J')
 scalar `DJ22'=`DJ20'[1,1]
 matrix `D'=`DJ11'/`DJ22'
 matrix `SSE'=`U''*`IPhi'*`U'
 if inlist("`model'", "bcox") {
 matrix `SST1'=(`Yws'-`D'*`Yws')'*`IPhi'*(`Yws'-`D'*`Yws')
 matrix `SST2'=(`Yws''*`Yws')
 }
 else {
 matrix `SST1'=(`Y'-`D'*`Y')'*`IPhi'*(`Y'-`D'*`Y')
 matrix `SST2'=(`Y''*`IPhi'*`Y')
 }
 scalar `SSE1'=`SSE'[1,1]
 scalar `SST11'=`SST1'[1,1]
 scalar `SST21'=`SST2'[1,1]
 scalar `r2bu'=1-`SSE1'/`SST11'
 if `r2bu'< 0 {
 scalar `r2bu'=`r2h'
 }
 scalar `r2bu_a'=1-((1-`r2bu')*(`N'-1)/`JDF')
 if inlist("`model'", "qreg", "rreg") {
 local R2_P_a=1-((1-`R2_P')*(`N'-1)/`JDF')
 local f_P=`R2_P'/(1-`R2_P')*(`N'-`Jkb')/`Jkx'
 local f_Pp= Ftail(`Jkx', `JDF', `f_P')
 }
 scalar `r2raw'=1-`SSE1'/`SST21'
 scalar `r2raw_a'=1-((1-`r2raw')*(`N'-1)/`JDF')
 scalar `R20'=`r2bu'
 local fr=`r2raw'/(1-`r2raw')*(`N'-`Jkb')/`Jkb'
 local frp= Ftail(`kx', `DF', `fr')
 if inlist("`model'", "als", "bcox", "gls", "gmm", "ols", "qreg", "rreg") & `ar'==1 {
 scalar `f'=`R20'/(1-`R20')*(`N'-`Jkb')/`Jkx'
 scalar `fp'= Ftail(`Jkx', `JDF', `f')
 scalar `wald'=`f'*`Jkx'
 scalar `waldp'=chi2tail(`Jkx', abs(`wald'))
 }
 if inlist("`model'", "als") & `ar'>1 {
 scalar `wald'= `wald'
 scalar `waldp'= `waldp'
 scalar `f'=`wald'/`Jkx'
 scalar `fp'= Ftail(`Jkx', `JDF', `f')
 }
 if inlist("`model'", "arch") {
 scalar `wald'= `wald'
 scalar `waldp'= `waldp'
 scalar `f'=`wald'/`Jkx'
 scalar `fp'= Ftail(`Jkx', `JDF', `f')
 }
 scalar `llf'=-(`N'/2)*log(2*_pi*`Sig2n')-(`N'/2)
 if "`wvar'"!="" | "`weights'"!="" {
 tempname Ew SSEw SSEw1 Sig2wn LWi21 LWi2
 matrix `Ew'=`Wi1'*(`Y'-`Z'*`B')
 matrix `SSEw'=(`Ew''*`Ew')
 scalar `SSEw1'=`SSEw'[1,1]
 scalar `Sig2n'=`SSEw1'/`N'
 scalar `Sig2o'=`SSEw1'/`JDF'
 scalar `Sigo'=sqrt(`Sig2o')
 gen double `LWi2'= 0.5*ln(`Wi1'^2) 
 summ `LWi2' 
 scalar `LWi21'=r(sum)
 scalar `llf'=-`N'/2*ln(2*_pi*`Sig2n')+`LWi21'-(`N'/2)
 }
 if inlist("`model'", "als", "arch", "bcox") {
 scalar `llf'=`LLFs'
 }
 local Nof =`N'
 local Dof =`JDF'
 matrix `B'=`B''
 if "`noconstant'"!="" {
 matrix colnames `Cov' = `NUXvar'
 matrix rownames `Cov' = `NUXvar' 
 matrix colnames `B'   = `NUXvar'
 }
 else { 
 matrix colnames `Cov' = `NUXvar' _cons
 matrix rownames `Cov' = `NUXvar' _cons
 matrix colnames `B'   = `NUXvar' _cons
 }
 matrix colnames `restc' = `NUXvar' _cons _r
noi di " `NYvar' = `NUXvar'"
noi di _dup(78) "-"
noi di as err "* Restrictions:"
noi constraint dir 
 if "`wvar'"!="" | "`weights'"!="" {
noi di as txt "{hline 78}"
noi di as txt "{bf: * " "`wtitle'" " *}"
 }
 if "`ridge'"!="" {
noi di _dup(78) "-"
noi di as txt "{bf: * Ridge k Value}" _col(21) "=" %10.5f `Kr' _col(37) "|" _col(41) "`rtitle'"
 }
noi di as txt "{hline 78}"
noi di as txt _col(2) "Sample Size" _col(21) "=" %12.0f as res `N' _col(37) "|" as txt _col(41) "Sample Range" _col(65) "=" %7.0f as res `NT1' " - " `NT2'
 ereturn post `B' `Cov' , depname("`NYvar'") obs(`Nof') dof(`Dof') 
noi di as txt _col(2) "{cmd:Wald Test}" _col(21) "=" %12.4f `wald' _col(37) "|" _col(41) "P-Value > {cmd:Chi2}(" `Jkx' ")" _col(65) "=" %12.4f `waldp'
noi di as txt _col(2) "{cmd:F-Test}" _col(21) "=" %12.4f `f' _col(37) "|" _col(41) "P-Value > {cmd:F}(" `Jkx' " , " `JDF' ")" _col(65) "=" %12.4f `fp'
noi di as txt _col(2) "R2  (R-Squared)" _col(21) "=" %12.4f `r2bu' _col(37) "|" _col(41) "Raw Moments R2" _col(65) "=" %12.4f `r2raw'
 ereturn scalar r2bu =`r2bu'
 ereturn scalar r2bu_a=`r2bu_a'
 ereturn scalar f =`f'
 ereturn scalar fp=`fp'
 ereturn scalar wald =`wald'
 ereturn scalar waldp=`waldp'
noi di as txt _col(2) "R2a (Adjusted R2)" _col(21) "=" %12.4f `r2bu_a' _col(37) "|" _col(41) "Raw Moments R2 Adj" _col(65) "=" %12.4f `r2raw_a'
noi di as txt _col(2) "Root MSE (Sigma)" _col(21) "=" %12.4f `Sigo' _col(37) "|" _col(41) "Log Likelihood Function" _col(65) "=" %12.4f `llf'
if inlist("`model'", "als") & `ar' == 1 {
noi di as txt _col(2) "Autoregressive Coefficient (Rho) = " %9.7f as res `R1'
 }
noi di _dup(78) "-"
noi di as txt "- {cmd:R2h}=" %7.4f `r2h' _col(16) "{cmd:R2h Adj}=" %8.4f `r2h_a' _col(34) "{cmd:F-Test} =" %8.2f `fh' _col(51) "P-Value > F(" `Jkx' " , " `JDF' ")" _col(72) %5.4f `fhp'
if `r2v'<1 {
noi di as txt "- {cmd:R2v}=" %7.4f `r2v' _col(16) "{cmd:R2v Adj}=" %8.4f `r2v_a' _col(34) "{cmd:F-Test} =" %8.2f `fv' _col(51) "P-Value > F(" `Jkx' " , " `JDF' ")" _col(72) %5.4f `fvp'
 ereturn scalar r2v=`r2v'
 ereturn scalar r2v_a=`r2v_a'
 ereturn scalar fv=`fv'
 ereturn scalar fvp=`fvp'
 }
 if inlist("`model'", "qreg", "rreg") {
noi di as txt "* {cmd:R2P}=" %7.4f `R2_P' _col(16) "{cmd:R2P Adj}=" %8.4f `R2_P_a' _col(34) "{cmd:F-Test} =" %8.2f `f_P' _col(51) "P-Value > F(" `Jkx' " , " `JDF' ")" _col(72) %5.4f `f_Pp'
 ereturn scalar r2p=`r2v'
 ereturn scalar r2p_a=`r2v_a'
 ereturn scalar fp=`fv'
 ereturn scalar fpp=`fvp'
 }
noi di as txt "- {cmd:R2r}=" %7.4f `r2raw' _col(16) "{cmd:R2r Adj}=" %8.4f `r2raw_a' _col(34) "{cmd:F-Test} =" %8.2f `fr' _col(51) "P-Value > F(" `Jkb' " , " `JDF' ")" _col(72) %5.4f `frp'
 scalar `AIC1'=-2*`llf' + 2* `Jkx'
 scalar `SC1'=-2*`llf' + ln(`N')* `Jkx'
noi di _dup(78) "-"
noi di as txt _col(2) "{cmd:Akaike Criterion AIC }" _col(21) "=" %12.4f as res `AIC1' _col(37) "|" as txt _col(41) "{cmd:Schwarz Criterion SC}" _col(65) "=" %12.4f as res `SC1'
noi di _dup(78) "-"
 forvalue i = 1/`kZLag' {
 local zx: word `i' of `zlag'
 local m1: word `i' of `MVar'
 tsunab MVar1 : `m1'
 test `MVar1' , `noconstant' common 
noi di as txt "- {bf:Joint F-Test Restriction:}" _col(29) "`zx'" _col(41) "= " %9.3f r(F) _col(55) "P > F("r(df) ", "   r(df_r) ") " _col(72) %5.4f r(p)
 }
 ereturn scalar N=_N
 ereturn scalar DF=`DF'
 ereturn scalar JDF=`JDF'
 ereturn scalar Jkx=`Jkx'
 ereturn scalar Jkb=`Jkb'
 ereturn scalar kx=`kx'
 ereturn scalar kb=`kb'
 ereturn scalar r2raw =`r2raw'
 ereturn scalar r2raw_a=`r2raw_a'
 ereturn scalar llf =`llf'
 ereturn scalar sig=`Sigo'
 ereturn scalar r2h=`r2h'
 ereturn scalar r2h_a=`r2h_a'
 ereturn scalar fh=`fh'
 ereturn scalar fhp=`fhp'
 ereturn scalar Kr=`Kr'
 ereturn scalar R20=`R20'
 ereturn matrix restc =`restc'
noi ereturn display , `leveln' first neq(1) 
 matrix `b'=e(b)
 matrix `V'=e(V)
 matrix `Bx'=e(b)
 matrix `restc'=e(restc)
 matrix `Beta'=e(b)
 matrix `VCov'= e(V)
 matrix `VCov'= `VCov'[1..`kx',1..`kx']
 if "`predict'"!= "" {
 putmata `predict'=`Yh_ML' , replace
 }
 if "`resid'"!= "" {
 putmata `resid'=`Ue_ML' , replace
 }

 if inlist("`model'", "als") & `ar' == 1 {
 tempvar Ue_ML1 Yh_ML1 E
 tempname Ue_ML1 Yh_ML1
 matrix `B'=e(b)'
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 svmat `E' , name(`E') 
 matrix `Ue_ML1'=`Wi'*(`Yws'-`Zws'*`B')
 svmat `Ue_ML1' , name(`Ue_ML1')
 rename `Ue_ML1'1 `Ue_ML1'
 replace `Ue_ML1'=`E'1 in 1
 mkmat `Ue_ML1' , matrix(`Ue_ML1')
 matrix `Yh_ML1'=`Y'-`Ue_ML1' 
 svmat `Yh_ML1' , name(`Yh_ML1')
 rename `Yh_ML1'1 `Yh_ML1'
 if "`predict'"!= "" {
 putmata `predict'=`Yh_ML1' , replace
 }
 if "`resid'"!= "" {
 putmata `resid'=`Ue_ML1' , replace
 }
 }

 matrix `B'=`b''
 if "`diag'" != "" {
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:*** {err:Model Selection Diagnostic Criteria} - {bf:(Model= {err:`ModeL'})}}"
noi di _dup(78) "{bf:{err:=}}"
 ereturn scalar aic=`Sig2n'*exp(2*`Jkb'/`N')
 ereturn scalar laic=ln(`Sig2n')+2*`Jkb'/`N'
 ereturn scalar fpe=`Sig2o'*(1+`Jkb'/`N')
 ereturn scalar sc=`Sig2n'*`N'^(`Jkb'/`N')
 ereturn scalar lsc=ln(`Sig2n')+`Jkb'*ln(`N')/`N'
 ereturn scalar hq=`Sig2n'*ln(`N')^(2*`Jkb'/`N')
 ereturn scalar rice=`Sig2n'/(1-2*`Jkb'/`N')
 ereturn scalar shibata=`Sig2n'*(`N'+2*`Jkb')/`N'
 ereturn scalar gcv=`Sig2n'*(1-`Jkb'/`N')^(-2)
 ereturn scalar llf = `llf'
noi di as txt "- Log Likelihood Function" _col(45) "LLF" _col(60) "=" %12.4f `e(llf)'
noi di _dup(75) "-"
noi di as txt "- Akaike Information Criterion" _col(45) "(1974) AIC" _col(60) "=" %12.4f `e(aic)'
noi di as txt "- Akaike Information Criterion" _col(45) "(1973) Log AIC" _col(60) "=" %12.4f `e(laic)'
noi di _dup(75) "-"
noi di as txt "- Schwarz Criterion" _col(45) "(1978) SC" _col(60) "=" %12.4f `e(sc)'
noi di as txt "- Schwarz Criterion" _col(45) "(1978) Log SC" _col(60) "=" %12.4f `e(lsc)'
noi di _dup(75) "-"
noi di as txt "- Amemiya Prediction Criterion" _col(45) "(1969) FPE" _col(60) "=" %12.4f `e(fpe)'
noi di as txt "- Hannan-Quinn Criterion" _col(45) "(1979) HQ" _col(60) "=" %12.4f `e(hq)'
noi di as txt "- Rice Criterion" _col(45) "(1984) Rice" _col(60) "=" %12.4f `e(rice)'
noi di as txt "- Shibata Criterion" _col(45) "(1981) Shibata" _col(60) "=" %12.4f `e(shibata)'
noi di as txt "- Craven-Wahba Generalized Cross Validation" _col(45) "(1979) GCV" _col(60) "=" %12.4f `e(gcv)'
noi di _dup(78) "-"
 }

 if "`lmauto'" != "" {
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:*** {err:Autocorrelation Tests} - {bf:(Model= {err:`ModeL'})}}"
noi di _dup(78) "{bf:{err:-}}"
noi di as txt "{bf: Ho: No Autocorrelation - Ha: Autocorrelation}"
noi di _dup(78) "-"
 tempname S2y SSE Rho BB lmaz lmadw lmabpg lmabgd lmadmk lmabgk lmadmd
 tempname SRhos lmabp SBBs lmalb Po lmadho lmadhop lmahho lmahhop SSEa Pa
 tempname lmawt lmawtp lmawc lmawcp Pa1 lmadha lmadhap lmahha lmahhap lmabw lmakg
 tempvar Yh2 U2 E2 E3 E4 Es Yh E
 tsset `Time'
 gen double `Yh' =`Yh_MLo'
 gen double `E' =`Ue_MLo'
 matrix `Cov'=e(V)
 matrix `vy1' =`Cov'[`dlag'..`dlag', `dlag'..`dlag']
 scalar `S2y'=`vy1'[1,1]
 cap drop `LE'*
 forvalue i=1/`lag' {
 tempvar E`i' EE`i' LE`i' LEo`i' DE`i' LEE`i'
 gen double `E`i''=`E'^`i' 
 gen double `LEo`i''=L`i'.`E' 
 replace `LEo`i''= 0 in 1/`i'
 gen double `LE`i'' =L`i'.`E' 
 gen double `LEE`i''=L`i'.`E'*`E' 
 summ `LEE`i'' 
 scalar `SSE'`i'=r(sum)
 scalar `Rho'`i'=`SSE'`i'/`SSEo'
 scalar `BB'`i'=`Rho'`i'^2/(`N'-`i')
 scalar `lmaz'`i'=`Rho'`i'*sqrt(`N')
 gen double `DW'`i'=sum((`E'-`E'[_n-`i'])^2)/sum(`E'*`E') 
 scalar `lmadw'`i'= `DW'`i'[`N']
 summ `E`i'' 
 scalar `SSE'`i'=r(sum)
 gen double `DE`i''=(`E'-`E'[_n-1])^2 
 summ `DE`i'' 
 scalar `SSE'`i'=r(sum)
 regress `E' `LEo`i'' `_Zo' , `noconstant'
 scalar `lmabpg'`i'=sqrt(e(N)*e(r2))
 tempvar `LEo'`i' `LE'`i'
 gen double `LEo'`i'=L`i'.`E' 
 replace `LEo'`i'= 0 in 1/`i'
 gen double `LE'`i' =L`i'.`E' 
 regress `E' `LE'* `_Zo' , `noconstant'
 scalar `lmabgd'`i'=e(N)*e(r2)
 cap testparm `LE'*
 scalar `lmadmk'`i'=r(F)*`i'
 regress `E' `LEo'* `_Zo' , `noconstant'
 scalar `lmabgk'`i'=e(N)*e(r2)
 cap testparm `LEo'*
 scalar `lmadmd'`i'=r(F)*`i'
 }
 gen double `SBB' = . 
 gen double `SRho'= . 
 scalar `SBBs' = 0
 scalar `SRhos'= 0
 forvalue i=1/`lag' {
 replace `SRho' = `Rho'`i'^2 
 summ `SRho' , meanonly
 replace `SRho' = r(mean) 
 summ `SRho' , meanonly
 scalar `SRhos' = `SRhos' + r(mean)
 scalar `lmabp'`i'=`N'*`SRhos'
 replace `SBB' = `BB'`i' 
 summ `SBB' , meanonly
 replace `SBB' = r(mean) 
 summ `SBB' , meanonly
 scalar `SBBs' = `SBBs' + r(mean)
 scalar `lmalb'`i'=`N'*(`N'+2)*`SBBs'
 }
 regress `E' `LE1' , noconstant
 scalar `Po'= _b[`LE1']
 scalar `lmadho'=`Po'*sqrt(`N'/(1-`N'*`S2y'))
 scalar `lmadhop'= 2*(1-normal(abs(`lmadho')))
 scalar `lmahho'=`Po'^2*(`N'/(1-`N'*`S2y'))
 scalar `lmahhop'= chi2tail(1, abs(`lmahho'))
 cap prais `_Yw' `_Zw' `Zo' , noconstant rhotype(regress) twostep
 scalar `SSEa'=e(rss)
 predict double `Ea' , r
 scalar `Pa'= e(rho)
 scalar `lmawt'=`Pa'/(sqrt((1-`Pa'^2)/`N'))
 scalar `lmawtp'= 2*(1-normal(abs(`lmawt')))
 scalar `lmawc'=`Pa'^2/((1-`Pa'^2)/`N')
 scalar `lmawcp'= chi2tail(1, abs(`lmawc'))
 gen double `Es'=`Ea' - `Po' * L.`Ea' 
 replace `Es'=`Ea' in 1/1
 gen double `Es1'=L1.`Es' 
 regress `Es' `Es1' , noconstant
 scalar `Pa1'= _b[`Es1']
 scalar `lmadha'=`Pa1'*sqrt(`N'/(1-(`N'*((1-(`Pa'^2))/`N'))))
 scalar `lmadhap'= 2*(1-normal(abs(`lmadha')))
 scalar `lmahha'=`Pa1'^2*(`N'/(1-(`N'*((1-(`Pa'^2))/`N'))))
 scalar `lmahhap'= chi2tail(1, abs(`lmahha'))
 if `lmadho' ==. {
noi di as txt "- Durbin  h Test cannot be computed"
 }
 if `lmadho' != . {
noi di as txt "- Durbin  h Test (Lag DepVar)" _col(40) "AR(1)=" %8.4f `lmadho' _col(56) "P-Value >Z(0,1)" _col(73) %5.4f `lmadhop'
 } 
noi di as txt "- Durbin  h Test after ALS(1)" _col(40) "AR(1)=" %8.4f `lmadha' _col(56) "P-Value >Z(0,1)" _col(73) %5.4f `lmadhap'
noi di _dup(78) "-"
noi di as txt "- Harvey LM Test (Lag DepVar)" _col(40) "AR(1)=" %8.4f `lmahho' _col(56) "P-Value >Chi2(1)" _col(73) %5.4f `lmahhop'
noi di as txt "- Harvey LM Test after ALS(1)" _col(40) "AR(1)=" %8.4f `lmahha' _col(56) "P-Value >Chi2(1)" _col(73) %5.4f `lmahhap'
noi di _dup(78) "-"
noi di as txt "- Wald    T Test" _col(40) "AR(1)=" %8.4f `lmawt' _col(56) "P-Value >Z(0,1)" _col(73) %5.4f `lmawtp'
noi di as txt "- Wald Chi2 Test" _col(40) "AR(1)=" %8.4f `lmawc' _col(56) "P-Value >Z(0,1)" _col(73) %5.4f `lmawcp'
noi di _dup(78) "-"
 tsset `Time'
 gen double `DY_' = D.`_Yw' 
 foreach var of local _Zw {
 gen double `DX_'`var' = D.`var' 
 }
 regress `DY_' `DX_'* , noconstant
 scalar `lmabw'=e(rss)/`SSEo'
noi di as txt "- Berenblut-Webb Test" _col(40) "AR(1)=" %8.4f `lmabw' _col(56) "df: ("  `kx'  " , " `N' ")
 cap prais `_Yw' `_Zw' `Zo' , noconstant rhotype(regress) twostep
 scalar `lmakg'=`SSEa'/`SSEo'
noi di as txt "- King Test (MA)" _col(40) "AR(1)=" %8.4f `lmakg' _col(56) "df: ("  `kx'  " , " `N' ")
noi di _dup(78) "-"
 if "`lag'"!="" {
 forvalue i=1/`lag' {
noi di as txt "- Rho Value for Lag(" `i' ")" _col(40) "AR(" `i' ")=" %8.4f `Rho'`i'
 ereturn scalar rho`i'=`Rho'`i'
noi di as txt "- Z Test" _col(40) "AR(" `i' ")=" %8.4f `lmaz'`i' _col(56) "P-Value >Chi2(`i')" _col(73) %5.4f chi2tail(`i', abs(`lmaz'`i'))
 ereturn scalar lmaz`i'=`lmaz'`i'
 ereturn scalar lmazp`i'=chi2tail(`i', abs(`lmaz'`i'))
noi di as txt "- Box-Pierce LM Test" _col(40) "AR(" `i' ")=" %8.4f `lmabp'`i' _col(56) "P-Value >Chi2(`i')" _col(73) %5.4f chi2tail(`i', abs(`lmabp'`i'))
 ereturn scalar lmabp`i'=`lmabp'`i'
 ereturn scalar lmabpp`i'=chi2tail(`i', abs(`lmabp'`i'))
noi di as txt "- Ljung-Box  LM Test" _col(40) "AR(" `i' ")=" %8.4f `lmalb'`i' _col(56) "P-Value >Chi2(`i')" _col(73) %5.4f chi2tail(`i', abs(`lmalb'`i'))
 ereturn scalar lmalb`i'=`lmalb'`i'
 ereturn scalar lmalbp`i'=chi2tail(`i', abs(`lmalb'`i'))
noi di as txt "- Durbin-Watson Test" _col(40) "AR(" `i' ")=" %8.4f `lmadw'`i' _col(56) "df: ("  `kx'  " , " `N' ")
 ereturn scalar lmadw`i'=`lmadw'`i'
noi di as txt "- Von Neumann Ratio Test" _col(40) "AR(" `i' ")=" %8.4f `lmadw'`i'*`N'/(`N'-1) _col(56) "df: ("  `kx'  " , " `N' ")
 ereturn scalar lmavon`i'=`lmadw'`i'*`N'/(`N'-1)
noi di as txt "- Durbin m Test (drop `i' obs)" _col(40) "AR(" `i' ")=" %8.4f `lmadmd'`i' _col(56) "P-Value >Chi2(`i')" _col(73) %5.4f chi2tail(`i', abs(`lmadmd'`i'))
 ereturn scalar lmadmd`i'=`lmadmd'`i'
 ereturn scalar lmadmdp`i'=chi2tail(`i', abs(`lmadmd'`i'))
noi di as txt "- Durbin m Test (keep `i' obs)" _col(40) "AR(" `i' ")=" %8.4f `lmadmk'`i' _col(56) "P-Value >Chi2(`i')" _col(73) %5.4f chi2tail(`i', abs(`lmadmk'`i'))
 ereturn scalar lmadmk`i'=`lmadmk'`i'
 ereturn scalar lmadmkp`i'=chi2tail(`i', abs(`lmadmk'`i'))
noi di as txt "- Breusch-Godfrey LM Test (drop `i' obs)" _col(40) "AR(" `i' ")=" %8.4f `lmabgd'`i' _col(56) "P-Value >Chi2(`i')" _col(73) %5.4f chi2tail(`i', abs(`lmabgd'`i'))
 ereturn scalar lmabgd`i'=`lmabgd'`i'
 ereturn scalar lmabgdp`i'=chi2tail(`i', abs(`lmabgd'`i'))
noi di as txt "- Breusch-Godfrey LM Test (keep `i' obs)" _col(40) "AR(" `i' ")=" %8.4f `lmabgk'`i' _col(56) "P-Value >Chi2(`i')" _col(73) %5.4f chi2tail(`i', abs(`lmabgk'`i'))
 ereturn scalar lmabgk`i'=`lmabgk'`i'
 ereturn scalar lmabgkp`i'=chi2tail(`i', abs(`lmabgk'`i'))
noi di as txt "* Breusch-Pagan-Godfrey LM Test" _col(40) "AR(" `i' ")=" %8.4f `lmabpg'`i' _col(56) "P-Value >Chi2(`i')" _col(73) %5.4f chi2tail(`i', abs(`lmabpg'`i'))
 ereturn scalar lmabpg`i'=`lmabpg'`i'
 ereturn scalar lmabpgp`i'=chi2tail(`i', abs(`lmabpg'`i'))
noi di _dup(78) "-"
 }
 }
 ereturn scalar lmawc=`lmawc'
 ereturn scalar lmawcp= `lmawcp'
 ereturn scalar lmawt=`lmawt'
 ereturn scalar lmawtp= `lmawtp'
 ereturn scalar lmadho= `lmadho'
 ereturn scalar lmadhop= `lmadhop'
 ereturn scalar lmadha= `lmadha'
 ereturn scalar lmadhap= `lmadhap'
 ereturn scalar lmahho= `lmahho'
 ereturn scalar lmahhop= `lmahhop'
 ereturn scalar lmahha= `lmahha'
 ereturn scalar lmahhap= `lmahhap'
 ereturn scalar lmakg=`lmakg'
 ereturn scalar lmabw=`lmabw'
 }

 if "`lmhet'" != "" {
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:*** {err:Heteroscedasticity Tests} - {bf:(Model= {err:`ModeL'})}}"
noi di _dup(78) "{bf:{err:-}}"
noi di as txt "{bf: Ho: Homoscedasticity - Ha: Heteroscedasticity}"
noi di _dup(78) "-"
 tempname Eb2 Eb4 lmhmss1 lmhmss1p mssdf1 lmhmss2 lmhmss2p mssdf2 dfw0
 tempname lmhw01 lmhw01p lmhw02 lmhw02p dfw1 lmhw11 lmhw11p lmhw12 lmhw12p dfw2
 tempname lmhw21 lmhw21p lmhw22 lmhw22p lmhharv lmhharvp lmhwald lmhwaldp lmhhp1
 tempname lmhhp1p lmhhp2 lmhhp2p lmhhp3 lmhhp3p lmhgl lmhglp lmhcw1 cwdf1 lmhcw1p
 tempname lmhcw2 cwdf2 lmhcw2p lmharch lmharchp lmhbg lmhbgp LMh_cwx mh vh h Q
 tempvar Yh2 U2 E2 E3 E4 E Yh
 tsset `Time'
 gen double `Yh' =`Yh_MLo'
 gen double `E' =`Ue_MLo'
 gen double `U2' =`E'^2/`Sig2n' 
 gen double `Yh2'=`Yh'^2 
 gen double `LYh2'=ln(`Yh2') 
 gen double `E2'=`E'^2 
 gen double `E3'=`E'^3 
 gen double `E4'=`E'^4 
 summ `E2' 
 scalar `Eb2'=r(mean)
 summ `E4' 
 scalar `Eb4'=r(mean)
 gen double `LnE2'=log(`E2') 
 gen double `absE'=abs(`E') 
 gen double `DumE'=0 
 replace `DumE'=1 if `E' >= 0
 summ `DumE' 
 gen double `EDumE'=`E'*(`DumE'-r(mean)) 
 regress `EDumE' `Yh' `Yh2' `wgt'
 scalar `lmhmss1'=e(N)*e(r2)
 scalar `lmhmss1p'=chi2tail(e(df_m), abs(`lmhmss1'))
 scalar `mssdf1'=e(df_m)
 regress `EDumE' `_Zo' , `noconstant'
 scalar `lmhmss2'=e(N)*e(r2)
 scalar `lmhmss2p'=chi2tail(e(df_m), abs(`lmhmss2'))
 scalar `mssdf2'=e(df_m)
 cap drop `XQ'*
 local nX : word count `_Zo'
 forvalue i=1/`nX' {
 local v: word `i' of `_Zo'
 gen double `XQ'`i'`i' = `v'*`v' 
 } 
 regress `E2' `_Zo' , `noconstant'
 scalar `dfw0'=e(df_m)
 scalar `lmhw01'=e(r2)*e(N)
 scalar `lmhw01p'= chi2tail(`dfw0' , abs(`lmhw01'))
 scalar `lmhw02'=e(mss)/(2*`Sig2n'^2)
 scalar `lmhw02p'= chi2tail(`dfw0' , abs(`lmhw02'))
 regress `E2' `_Zo' `XQ'* , `noconstant'
 scalar `dfw1'=e(df_m)
 scalar `lmhw11'=e(r2)*e(N)
 scalar `lmhw11p'= chi2tail(`dfw1' , abs(`lmhw11'))
 scalar `lmhw12'=e(mss)/(2*`Sig2n'^2)
 scalar `lmhw12p'= chi2tail(`dfw1' , abs(`lmhw12'))
 cap drop `XQ'*
 forvalue i=1/`nX' {
 forvalue j=1/`nX' {
 local vi: word `i' of `_Zo'
 local vj: word `j' of `_Zo'
 if `i' <= `j' {
 gen double `XQ'`i'`j' = `vi'*`vj' 
 }
 }
 }
 regress `E2' `_Zo' `XQ'* , `noconstant'
 scalar `dfw2'=e(df_m)
 scalar `lmhw21'=e(r2)*e(N)
 scalar `lmhw21p'= chi2tail(`dfw2' , abs(`lmhw21'))
 scalar `lmhw22'=e(mss)/(2*`Sig2n'^2)
 scalar `lmhw22p'= chi2tail(`dfw2' , abs(`lmhw22'))
 regress `LnE2' `_Zo' , `noconstant'
 scalar `lmhharv'=e(mss)/4.9348
 scalar `lmhharvp'= chi2tail(2, abs(`lmhharv'))
 scalar `lmhwald'=e(mss)/2
 scalar `lmhwaldp'= chi2tail(1, abs(`lmhwald'))
 regress `E2' `Yh' 
 scalar `lmhhp1'=e(N)*e(r2)
 scalar `lmhhp1p'= chi2tail(1, abs(`lmhhp1'))
 regress `E2' `Yh2' 
 scalar `lmhhp2'=e(N)*e(r2)
 scalar `lmhhp2p'= chi2tail(1, abs(`lmhhp2'))
 regress `E2' `LYh2' 
 scalar `lmhhp3'=e(N)*e(r2)
 scalar `lmhhp3p'= chi2tail(1, abs(`lmhhp3'))
 regress `absE' `_Zo' , `noconstant'
 scalar `lmhgl'=e(mss)/((1-2/_pi)*`Sig2n')
 scalar `lmhglp'= chi2tail(2, abs(`lmhgl'))
 regress `U2' `Yh' 
 scalar `lmhcw1'= e(mss)/2
 scalar `cwdf1'= e(df_m)
 scalar `lmhcw1p'= chi2tail(`cwdf1', abs(`lmhcw1'))
 regress `U2' `_Zo' , `noconstant'
 scalar `lmhcw2'= e(mss)/2
 scalar `cwdf2'= e(df_m)
 scalar `lmhcw2p'= chi2tail(`cwdf2', abs(`lmhcw2'))
 tsset `Time'
 cap drop `LE'*
 forvalue i = 1/`lag' {
 gen double `LE'`i'=L`i'.`E2' 
 regress `E2' `LE'* 
 scalar `lmharch'`i'=e(r2)*e(N)
 scalar `lmharchp'`i'= chi2tail(`i', abs(`lmharch'`i'))
noi di as txt "- Engle LM ARCH Test AR(`i') E2=E2_1-E2_`i'" _col(40) "=" %9.4f `lmharch'`i' _col(53) " P-Value > Chi2(`i')" _col(73) %5.4f `lmharchp'`i'
 }
 regress `E2' L1.`E2' `_Zo' , `noconstant'
 scalar `lmhbg'=e(r2)*e(N)
 scalar `lmhbgp'= chi2tail(1, abs(`lmhbg'))
noi di _dup(78) "-"
noi di as txt "- Hall-Pagan LM Test:      E2 = Yh" _col(40) "=" %9.4f `lmhhp1' _col(53) " P-Value > Chi2(1)" _col(73) %5.4f `lmhhp1p'
noi di as txt "- Hall-Pagan LM Test:      E2 = Yh2" _col(40) "=" %9.4f `lmhhp2' _col(53) " P-Value > Chi2(1)" _col(73) %5.4f `lmhhp2p'
noi di as txt "- Hall-Pagan LM Test:      E2 = LYh2" _col(40) "=" %9.4f `lmhhp3' _col(53) " P-Value > Chi2(1)" _col(73) %5.4f `lmhhp3p'
noi di _dup(78) "-"
noi di as txt "- Harvey LM Test:       LogE2 = X" _col(40) "=" %9.4f `lmhharv' _col(53) " P-Value > Chi2(2)" _col(73) %5.4f `lmhharvp'
noi di as txt "- Wald LM Test:         LogE2 = X " _col(40) "=" %9.4f `lmhwald' _col(53) " P-Value > Chi2(1)" _col(73) %5.4f `lmhwaldp'
noi di as txt "- Glejser LM Test:        |E| = X" _col(40) "=" %9.4f `lmhgl' _col(53) " P-Value > Chi2(2)" _col(73) %5.4f `lmhglp'
noi di as txt "- Breusch-Godfrey Test:    E2 = E2_1 X" _col(40) "=" %9.4f `lmhbg' _col(53) " P-Value > Chi2(1)" _col(73) %5.4f `lmhbgp'
noi di _dup(78) "-"
noi di as txt "- Machado-Santos-Silva Test: Ev=Yh Yh2" _col(40) "=" %9.4f `lmhmss1' _col(53) " P-Value > Chi2(" `mssdf1' ")" _col(73) %5.4f `lmhmss1p'
noi di as txt "- Machado-Santos-Silva Test: Ev=X" _col(40) "=" %9.4f `lmhmss2' _col(53) " P-Value > Chi2(" `mssdf2' ")" _col(73) %5.4f `lmhmss2p'
noi di _dup(78) "-"
noi di as txt "- White Test -Koenker(R2): E2 = X" _col(40) "=" %9.4f `lmhw01' _col(53) " P-Value > Chi2(" `dfw0' ")" _col(73) %5.4f `lmhw01p'
noi di as txt "- White Test -B-P-G (SSR): E2 = X" _col(40) "=" %9.4f `lmhw02' _col(53) " P-Value > Chi2(" `dfw0' ")" _col(73) %5.4f `lmhw02p'
noi di _dup(78) "-"
noi di as txt "- White Test -Koenker(R2): E2 = X X2" _col(40) "=" %9.4f `lmhw11' _col(53) " P-Value > Chi2(" `dfw1' ")" _col(73) %5.4f `lmhw11p'
noi di as txt "- White Test -B-P-G (SSR): E2 = X X2" _col(40) "=" %9.4f `lmhw12' _col(53) " P-Value > Chi2(" `dfw1' ")" _col(73) %5.4f `lmhw12p'
noi di _dup(78) "-"
noi di as txt "- White Test -Koenker(R2): E2 = X X2 XX" _col(40) "=" %9.4f `lmhw21' _col(53) " P-Value > Chi2(" `dfw2' ")" _col(73) %5.4f `lmhw21p'
noi di as txt "- White Test -B-P-G (SSR): E2 = X X2 XX" _col(40) "=" %9.4f `lmhw22' _col(53) " P-Value > Chi2(" `dfw2' ")" _col(73) %5.4f `lmhw22p'
noi di _dup(78) "-"
noi di as txt "- Cook-Weisberg LM Test  E2/Sig2 = Yh" _col(40) "=" %9.4f `lmhcw1' _col(53) " P-Value > Chi2(" `cwdf1' ")" _col(73) %5.4f `lmhcw1p'
noi di as txt "- Cook-Weisberg LM Test  E2/Sig2 = X" _col(40) "=" %9.4f `lmhcw2' _col(53) " P-Value > Chi2(" `cwdf2' ")" _col(73) %5.4f `lmhcw2p'
noi di _dup(78) "-"
 ereturn scalar lmhw01= `lmhw01'
 ereturn scalar lmhw01p= `lmhw01p'
 ereturn scalar lmhw02= `lmhw02'
 ereturn scalar lmhw02p= `lmhw02p'
 ereturn scalar lmhw11= `lmhw11'
 ereturn scalar lmhw11p= `lmhw11p'
 ereturn scalar lmhw12= `lmhw12'
 ereturn scalar lmhw12p= `lmhw12p'
 ereturn scalar lmhw21= `lmhw21'
 ereturn scalar lmhw21p= `lmhw21p'
 ereturn scalar lmhw22 = `lmhw22'
 ereturn scalar lmhw22p= `lmhw22p'
 ereturn scalar lmhcw1= `lmhcw1'
 ereturn scalar lmhcw1p= `lmhcw1p'
 ereturn scalar lmhcw2= `lmhcw2'
 ereturn scalar lmhcw2p= `lmhcw2p'
 ereturn scalar lmhharv= `lmhharv'
 ereturn scalar lmhharvp= `lmhharvp'
 ereturn scalar lmhwald= `lmhwald'
 ereturn scalar lmhwaldp= `lmhwaldp'
 ereturn scalar lmhgl= `lmhgl'
 ereturn scalar lmhglp= `lmhglp'
 ereturn scalar lmhbg= `lmhbg'
 ereturn scalar lmhmss2p= `lmhmss2p'
 ereturn scalar lmhmss2= `lmhmss2p'
 ereturn scalar lmhmss1p= `lmhmss1p'
 ereturn scalar lmhmss1= `lmhmss1'
 ereturn scalar lmhbgp= `lmhbgp'
 ereturn scalar lmhhp1= `lmhhp1'
 ereturn scalar lmhhp1p= `lmhhp1p'
 ereturn scalar lmhhp2= `lmhhp2'
 ereturn scalar lmhhp2p= `lmhhp2p'
 ereturn scalar lmhhp3= `lmhhp3'
 ereturn scalar lmhhp3p= `lmhhp3p'
 forvalue i = 1/`lag' {
 ereturn scalar lmharchp`i'= `lmharchp'`i'
 ereturn scalar lmharch`i'= `lmharch'`i'
 }
 }

 if "`lmnorm'"!="" {
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:*** {err:Non Normality Tests} - {bf:(Model= {err:`ModeL'})}}"
noi di _dup(78) "{bf:{err:-}}"
noi di as txt "{bf: Ho: Normality - Ha: Non Normality}"
noi di _dup(78) "-"
 tempvar E2 Us1 Us2 Us3 Us4 Es U2 DE LDE LDF1 Yt U Hat E
 tempname Hat corr1 corr3 corr4 mpc2 mpc3 mpc4 s uinv q1 uinv2 q2 ECov ECov2 Eb Sk Ku
 tempname M2 M3 M4 K2 K3 K4 Ss Kk GK sksd kusd N1 N2 EN S2N SN mean sd small A2 B0 B1
 tempname B2 B3 LA Zn Rn Lower Upper wsq2 ve lve Skn gn an cn kn vz Ku1 Kun n1 n2 n3 eb2
 tempname R2W vb2 svb2 k1 a devsq m2 sdev m3 m4 sqrtb1 b2 g1 g2 stm3b2 S1 S2 S3 S4
 tempname b2minus3 sm sms y k2 wk delta alpha yalpha pc1 pc2 pc3 pc4 pcb1 pcb2 sqb1p b2p
 tsset `Time'
 gen double `E' =`Ue_ML'
 gen double `E2'=`E'*`E' 
 regress `_Yw' `_Zw' `Zo' , noconstant
 predict double `Hat' , hat 
 regress `E2' `Hat' 
 scalar `R2W'=e(r2)
 summ `E' , det
 scalar `Eb'=r(mean)
 scalar `Sk'=r(skewness)
 scalar `Ku'=r(kurtosis)
 forvalue i = 1/4 {
 gen double `Us`i''=(`E'-`Eb')^`i' 
 cap summ `Us`i'' 
 scalar `S`i''=r(mean)
 scalar `pc`i''=r(sum)
 }
 mkmat `Us1' `Us2' `Us3' `Us4' , matrix(`ECov')
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
 gen `DE'=1 if `E'>0
 replace `DE'=0 if `E' <= 0
 count if `DE'>0
 scalar `N1'=r(N)
 scalar `N2'=`N'-r(N)
 scalar `EN'=(2*`N1'*`N2')/(`N1'+`N2')+1
 scalar `S2N'=(2*`N1'*`N2'*(2*`N1'*`N2'-`N1'-`N2'))/((`N1'+`N2')^2*(`N1'+`N2'-1))
 scalar `SN'=sqrt((2*`N1'*`N2'*(2*`N1'*`N2'-`N1'-`N2'))/((`N1'+`N2')^2*(`N1'+`N2'-1)))
 gen `LDE'= `DE'[_n-1] 
 replace `LDE'=0 if `DE'==1 in 1
 gen `LDF1'= 1 if `DE' != `LDE'
 replace `LDF1'= 1 if `DE' == `LDE' in 1
 replace `LDF1'= 0 if `LDF1' == .
 count if `LDF1'>0
 scalar `Rn'=r(N)
 ereturn scalar lmng=(`Rn'-`EN')/`SN'
 ereturn scalar lmngp= chi2tail(2, abs(e(lmng)))
 scalar `Lower'=`EN'-1.96*`SN'
 scalar `Upper'=`EN'+1.96*`SN'
 cap summ `E' 
 scalar `mean'=r(mean)
 scalar `sd'=r(sd)
 scalar `small'= 1e-20
 gen double `Es' =`E' 
 sort `Es'
 replace `Es'=normal((`Es'-`mean')/`sd') 
 gen double `Yt'=`Es'*(1-`Es'[`N'-_n+1]) 
 replace `Yt'=`small' if `Yt' < =0
 replace `Yt'=sum((2*_n-1)*ln(`Yt')) 
 scalar `A2'=-`N'-`Yt'[`N']/`N'
 scalar `A2'=`A2'*(1+(0.75+2.25/`N')/`N')
 scalar `B0'=2.25247+0.000317*exp(29.5/`N')
 scalar `B1'=2.16872+0.00243*exp(27.7/`N')
 scalar `B2'=0.19135+0.00255*exp(28.3/`N')
 scalar `B3'=0.110978+0.00001624*exp(39.04/`N')+0.00476*exp(21.37/`N')
 scalar `LA'=ln(`A2')
 ereturn scalar lmnad=(`A2')
 scalar `Zn'=abs(`B0'+`LA'*(`B1'+`LA'*(`B2'+`LA'*`B3')))
 ereturn scalar lmnadp= normal(abs(-`Zn'))
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
 scalar `yalpha'=`y'/`alpha'
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
 sort `Time'
noi di "{bf:*** Non Normality Tests:}
noi di as txt "- Jarque-Bera LM Test" _col(40) "=" %9.4f e(lmnjb) _col(55) "P-Value > Chi2(2) " _col(73) %5.4f e(lmnjbp)
noi di as txt "- White IM Test" _col(40) "=" %9.4f e(lmnw) _col(55) "P-Value > Chi2(2) " _col(73) %5.4f e(lmnwp)
noi di as txt "- Doornik-Hansen LM Test" _col(40) "=" %9.4f e(lmndh) _col(55) "P-Value > Chi2(2) " _col(73) %5.4f e(lmndhp)
noi di as txt "- Geary LM Test" _col(40) "=" %9.4f e(lmng) _col(55) "P-Value > Chi2(2) " _col(73) %5.4f e(lmngp)
noi di as txt "- Anderson-Darling Z Test" _col(40) "=" %9.4f e(lmnad) _col(55) "P > Z(" %6.3f `Zn' ")" _col(73) %5.4f e(lmnadp)
noi di as txt "- D'Agostino-Pearson LM Test " _col(40) "=" %9.4f e(lmndp) _col(55) "P-Value > Chi2(2)" _col(73) %5.4f e(lmndpp)
noi di _dup(78) "-"
noi di "{bf:*** Skewness Tests:}
noi di as txt "- Srivastava LM Skewness Test" _col(40) "=" %9.4f e(lmnsvs) _col(55) "P-Value > Chi2(1)" _col(73) %5.4f e(lmnsvsp)
noi di as txt "- Small LM Skewness Test" _col(40) "=" %9.4f e(lmnsms) _col(55) "P-Value > Chi2(1)" _col(73) %5.4f e(lmnsmsp)
noi di as txt "- Skewness Z Test" _col(40) "=" %9.4f e(lmnsz) _col(55) "P-Value > Chi2(1)" _col(73) %5.4f e(lmnszp)
noi di _dup(78) "-"
noi di "{bf:*** Kurtosis Tests:}
noi di as txt "- Srivastava Z Kurtosis Test" _col(40) "=" %9.4f e(lmnsvk) _col(55) "P-Value > Z(0,1)" _col(73) %5.4f e(lmnsvkp)
noi di as txt "- Small LM Kurtosis Test" _col(40) "=" %9.4f e(lmnsmk) _col(55) "P-Value > Chi2(1)" _col(73) %5.4f e(lmnsmkp)
noi di as txt "- Kurtosis Z Test" _col(40) "=" %9.4f e(lmnkz) _col(55) "P-Value > Chi2(1)" _col(73) %5.4f e(lmnkzp)
noi di _dup(78) "-"
noi di as txt _col(5) "Skewness Coefficient =" _col(28) %7.4f `Sk' "   " "  - Standard Deviation = " _col(48) %7.4f `sksd'
noi di as txt _col(5) "Kurtosis Coefficient =" _col(28) %7.4f `Ku' "   " "  - Standard Deviation = " _col(48) %7.4f `kusd'
noi di _dup(78) "-"
noi di as txt _col(5) "Runs Test:" " " "(" `Rn' ")" " " "Runs - " " " "(" `N1' ")" " " "Positives -" " " "(" `N2' ")" " " "Negatives"
noi di as txt _col(5) "Standard Deviation Runs Sig(k) = " %7.4f `SN' " , " "Mean Runs E(k) = " %7.4f `EN' 
noi di as txt _col(5) "95% Conf. Interval [E(k)+/- 1.96* Sig(k)] = (" %7.4f `Lower' " , " %7.4f `Upper' " )"
noi di _dup(78) "-"
 }

 if "`mfx'"!="" {
noi di
noi di _dup(78) "{bf:{err:=}}"
 tempvar ZSLS 
 tempname _Yoz _Zoz
 unab varlist: `_Zo'
 foreach var of local varlist {
 summ `var' `wgt'
 gen double `ZSLS'_`var' = r(sd)
 }
 tsunab ZSLS : `ZSLS'_*
 tokenize `ZSLS'
 summ `_Yo' `wgt'
 scalar `_Yoz' = r(sd)
 mkmat `ZSLS' in 1/1 , matrix(`_Zoz')
 matrix `Bx'=`Bx'[1, 1..`kx']'
 matrix `BsZ' =vecdiag(`Bx'*`_Zoz')'/`_Yoz'
 if "`tolog'"!="" {
 replace `yvar'=`yvarexp'
 local ZVarM "`xvarexp'"
 }
 else {
 local ZVarM "`xvar'"
 }
 }
 if inlist("`mfx'", "lin", "log") {
 tempname mfxbox mfxb mfxb1 mfxe mfxlin mfxlog XMB XYMB YMB YMB1 XMB1 XMB2
 if inlist("`model'", "bcox") {
 local Lam1 = `Lam'
 summ `yvar' 
 if inlist("`lamp'", "lhs") {
 scalar `YMB1'=r(mean)^`Lam1'
 mean `xvar'
 matrix `XMB'=e(b)'
 mata: X = st_matrix("`XMB'")
 }
 else {
 mean `ZVarM'
 matrix `XMB'=e(b)'
 mata: X = st_matrix("`XMB'")
 if inlist("`lamp'", "rhs") {
 summ `yvar' 
 scalar `YMB1'=r(mean)
 mata: X = X:^(`Lam1')
 }
 if inlist("`lamp'", "alls") {
 summ `yvar' 
 scalar `YMB1'=r(mean)^`Lam1'
 mata: X = X:^(`Lam1')
 }
 if inlist("`lamp'", "alld") {
 summ `yvar' 
 scalar `YMB1'=r(mean)^`Lam1'
 local Gam1 = `Gam'
 mata: X = X:^(`Gam1')
 }
 }
 matrix `YMB'=J(rowsof(`XMB'),1,`YMB1')
 mata: Y = st_matrix("`YMB'")
 mata: `XYMB'=X:/Y
 mata: `XYMB'=st_matrix("`XYMB'",`XYMB')
 matrix `mfxe' =vecdiag(`Bx'*`XYMB'')'
 matrix `mfxb'=`Bx'
 summ `yvar' 
 scalar `YMB1'=r(mean)
 matrix `YMB'=J(rowsof(`XMB'),1,`YMB1')
 mata: X = st_matrix("`XMB'")
 matrix `YMB'=J(rowsof(`XMB'),1,`YMB1')
 mata: Y = st_matrix("`YMB'")
 mata: `XYMB'=Y:/X
 mata: `XYMB'=st_matrix("`XYMB'",`XYMB')
 matrix `mfxb1' =vecdiag(`mfxe'*`XYMB'')'
 matrix `mfxbox' =`mfxb',`mfxb1',`mfxe',`BsZ',`XMB'
 matrix roweq `mfxbox' = "`NYvar'"
 matrix rownames `mfxbox' = `NUXvar'
 matrix colnames `mfxbox' = Beta Margin Elasticity St_Beta Mean
noi matlist `mfxbox' , title({bf:* {err:Marginal Effect - Elasticity - Standardized Beta} {bf:(Model= {err:`ModeL'})}: {err:Linear} *}) twidth(10) border(all) lines(columns) rowtitle("`NYvar'") format(%10.4f)
 ereturn matrix mfxbox=`mfxbox'
 matrix `mfxb'=`mfxb1'
 matrix `mfxe'=`mfxe'
 matrix `Beta1'=`mfxb1''
 }
 else {
 mean `ZVarM' 
 matrix `XMB'=e(b)'
 summ `yvar' 
 scalar `YMB1'=r(mean)
 matrix `YMB'=J(rowsof(`XMB'),1,`YMB1')
 mata: X = st_matrix("`XMB'")
 matrix `YMB'=J(rowsof(`XMB'),1,`YMB1')
 mata: Y = st_matrix("`YMB'")
 if inlist("`mfx'", "lin") {
 mata: `XYMB'=X:/Y
 mata: `XYMB'=st_matrix("`XYMB'",`XYMB')
 matrix `mfxb' =`Bx'
 matrix `mfxe'=vecdiag(`Bx'*`XYMB'')'
 matrix `mfxlin' =`mfxb',`mfxe',`BsZ',`XMB'
 matrix roweq `mfxlin' = "`NYvar'"
 matrix rownames `mfxlin' = `NUXvar'
 matrix colnames `mfxlin' = Margin Elasticity St_Beta Mean
noi matlist `mfxlin' , title({bf:* {err:Marginal Effect - Elasticity - Standardized Beta} {bf:(Model= {err:`ModeL'})}: {err:Linear} *}) twidth(14) border(all) lines(columns) rowtitle("`NYvar'") format(%12.4f)
 ereturn matrix mfxlin=`mfxlin'
 matrix `Beta1'=`mfxb''
 }
 if inlist("`mfx'", "log") {
 mata: `XYMB'=Y:/X
 mata: `XYMB'=st_matrix("`XYMB'",`XYMB')
 matrix `mfxe'=`Bx'
 matrix `mfxb'=vecdiag(`Bx'*`XYMB'')'
 matrix `mfxlog' =`mfxe',`mfxb',`BsZ',`XMB'
 matrix roweq `mfxlog' = "`NYvar'"
 matrix rownames `mfxlog' = `NUXvar' 
 matrix colnames `mfxlog' = Elasticity Margin St_Beta Mean
noi matlist `mfxlog' , title({bf:* {err:Elasticity - Marginal Effect - Standardized Beta} {bf:(Model= {err:`ModeL'})}: {err:Log-Log} *}) twidth(14) border(all) lines(columns) rowtitle("`NYvar'") format(%12.4f)
 ereturn matrix mfxlog=`mfxlog'
 matrix `Beta1'=`mfxb''
 }
 }
noi di as txt " Mean of Dependent Variable =" _col(30) %12.4f `YMB1'
noi di
noi di _dup(78) "{bf:{err:-}}"
noi di as txt "{bf:* Variable" _col(14) "Mean Lag" _col(25) "Full Lag" _col(37) "SUM(Coefs.)" _col(51) "Std. Err." _col(62) "T-Test" _col(73) "P>|t|}"
noi di _dup(78) "{bf:{err:-}}"
 tempname R M1 M2 M11 M21 FLag MLag SLag Cov VLag SDLag TLag Covt PTLag
 local NeQ : word count `zlag'
 local G = 0
 forvalue i = 1/`kZLag' {
 local zx: word `i' of `zlag'
 local x: word `i' of `MVar'
 tsunab MVar1 : `x'
 local G`i' : word count `MVar1'
 matrix `R'=J(`G`i'',1,0)
 forvalue m =1/`G`i'' {
 matrix `R'[`m',1] = `m'-1
 }
 local j=`i'-1
 local a =`G'+1
 local b =`G'+`G`i''
 local G =`G`i''
 matrix `Bx'`i'=`Beta1'[1, `a'..`b']
 matrix `M1'=`Bx'`i'*`R'
 matrix `M2'=trace(diag(`Bx'`i'))
 scalar `M11'=`M1'[1,1]
 scalar `M21'=`M2'[1,1]
 scalar `MLag'`i'=`M11'/`M21'
 scalar `FLag'`i'=`MLag'`i'+1
 scalar `SLag'`i'=`M21'
 matrix `Cov'=0
 forvalue r =`a'/`b' {
 forvalue c =`a'/`b' {
 if `r' > `c' {
 matrix `Cov' = nullmat(`Cov') + `VCov'[`r',`c']
 matrix `Covt' = `VCov'[`a'..`b',`a'..`b']
 matrix `VLag'=trace(`Covt')+2*`Cov'
 }
 }
 }
 scalar `SDLag'=`VLag'[1,1]
 scalar `SDLag'`i'=sqrt(`SDLag')
 scalar `TLag'`i'=`SLag'`i'/`SDLag'`i'
 scalar `PTLag'`i'= ttail(`DF' , abs(`TLag'`i'))*2
noi di as txt _col(3) "`zx'" _col(14) %7.4f `MLag'`i' _col(25) %7.4f `FLag'`i' _col(37) %8.4f `SLag'`i' _col(51) %7.4f `SDLag'`i' _col(60) %8.3f `TLag'`i' _col(73) %5.4f `PTLag'`i'
noi di _dup(78) "-"
 }
noi di
noi di _dup(78) "{bf:{err:-}}"
noi di as txt "{bf:* Variable" _col(15) "Marginal Effect (B)"_col(43) "|" _col(50) "Elasticity (Es)}"
noi di as err _col(15) "Short Run" _col(30) "Long Run" _col(43) "{cmd:|}" _col(50) "Short Run" _col(65) "Long Run"
noi di _dup(78) "{bf:{err:-}}"
 matrix `mfxb' =`mfxb''
 matrix `mfxe'=`mfxe''
 local G = 0
 forvalue i=1/`kZLag' {
 local zx: word `i' of `zlag'
 local x: word `i' of `MVar'
 tsunab MVar1 : `x'
 local G`i' : word count `MVar1'
 local a =`G'+1
 local b =`G'+`G`i''
 tempname mfxb1 mfxe1 SRB LRB SRE LRE SRB1 LRB1 SRE1 LRE1
 matrix `mfxb1'=`Beta1'[1, `a'..`b']
 matrix `mfxe1'=`mfxe'[1, `a'..`b']
 local G =`G`i''
 matrix `SRB'=`mfxb1'[1,1]
 matrix `SRE'=`mfxe1'[1,1]
 matrix `LRB'=trace(diag(`mfxb1'))
 matrix `LRE'=trace(diag(`mfxe1'))
 scalar `SRB1'=`SRB'[1,1]
 scalar `SRE1'=`SRE'[1,1]
 scalar `LRB1'=`LRB'[1,1]
 scalar `LRE1'=`LRE'[1,1]
noi di as txt _col(3) "`zx'" _col(15) %9.4f `SRB1' _col(30) %9.4f `LRB1' _col(43) "{cmd:|}" _col(50) %7.4f `SRE1' _col(65) %7.4f `LRE1'
noi di _dup(78) "-"
 }
 }
 restore
 if "`predict'"!= "" {
 cap drop `predict'
 getmata `predict' , force replace
 label variable `predict' `"Yh_`ModeL' - Prediction"'
 }
 if "`resid'"!= "" {
 cap drop `resid'
 getmata `resid' , force replace
 label variable `resid' `"Ue_`ModeL' - Residual"'
 }
 cap mata: mata drop *
 cap mata: mata clear
 cap matrix drop _all
 cap constraint drop _all
 ereturn local cmd "almon"
 }
 end

program define Poly , eclass
 version 11.2
 syntax , rmat(str) p(str) q(str) [NOCONSTant model(str) ar(str)]
 local r = `p' - `q'
 local m = `q' + 1
 tempname odd
 if inlist("`model'", "arch") {
 if "`noconstant'" != "" {
 local rho = 3+`ar'
 matrix `rmat' = J(`r',`p'+`rho',0)
 }
 else {
 local rho = 4+`ar'
 matrix `rmat' = J(`r',`p'+`rho',0)
 }
 }
 if inlist("`model'", "als") & `ar' == 1 {
 if "`noconstant'" != "" {
 matrix `rmat' = J(`r',`p'+2,0)
 }
 else {
 matrix `rmat' = J(`r',`p'+3,0)
 }
 }
 if inlist("`model'", "als") & `ar' > 1 {
 if "`noconstant'" != "" {
 local rho = 3+`ar'
 matrix `rmat' = J(`r',`p'+`rho',0)
 }
 else {
 local rho = 4+`ar'
 matrix `rmat' = J(`r',`p'+`rho',0)
 }
 }
 if !inlist("`model'", "als", "arch") {
 if "`noconstant'" != "" {
 matrix `rmat' = J(`r',`p'+2,0)
 }
 else {
 matrix `rmat' = J(`r',`p'+3,0)
 }
 }
 forvalue i = 1/`r' {
 local x = `i' + `q' + 1
 local k = -1
 scalar `odd'=mod(`q',2)
 if `odd' == 0 {
 local d = -1
 }
 if `odd' == 1 {
 local d = 1
 }
 forvalues j = `x'(-1)`i' {
 local k = `k' + 1
 matrix `rmat'[`i',`j'] = `d'*comb(`m',`k')
 local d = -1*`d'
 }
 }
 end

*! dlagif V1.0 25/04/2016
*!
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

program define dlagif , eclass
version 11.2
 syntax varlist [if] [in] , [Model(str) LAG(int 2) WVar(str) tolog CONDition LAMp(str) ///
 tune(int 7) ridge(str) NOCONStant DN KR(real 0) HETcov(str) diag LMAuto LMNorm LMHet ///
 Weights(str) TWOstep PREDict(str) RESid(str) iter(int 200) TOLerance(real 0.00001) ///
 TECHn(str) Quantile(int 50) Level(passthru) VCE(passthru) mfx(str) test ar(int 1) NOLag LIst]
 gettoken yvar xvar : varlist
 local sthlp dlagif
 marksample touse
 markout `touse' `varlist' `wvar' , strok
di
 local both : list yvar & xvar
if "`both'" != "" {
di as err " {bf:{cmd:`both'} cannot be included in both LHS and RHS Variables}"
di as res " LHS: `yvar'"
di as res " RHS: `xvar'"
 exit
 }
 if "`xvar'"=="" {
di as err " {bf:Independent Variable(s) must be combined with Dependent Variable}"
 exit
 }
 tsunab RHS : `xvar'
 _rmcoll `RHS' , `noconstant' forcedrop
 local both "`r(varlist)'"
 local both : list  RHS - both
 if "`both'" != "" {
di as err " {bf:{cmd:`both'} cannot be Included more than One in RHS Variables}"
di as res " RHS : `RHS'"
di as res " Coll: `both'"
 exit
 }
 _rmcoll `xvar' , `noconstant' forcedrop
  local xvar "`r(varlist)'"

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
if inlist("`model'", "gls") & "`wvar'"=="" {
di as err " {bf:wvar({it:var name})} {cmd:must be combined with:} {bf:model({it:gls})}"
exit
 }
 if inlist("`model'", "rreg") & "`wvar'"!="" {
di as err " {bf:wvar( )} {cmd:not Valid with:} {bf:model({it:rreg})}"
 exit
 }
if "`test'"!="" {
 local lmauto "lmauto"
 local lmhet "lmhet"
 local lmnorm "lmnorm"
 local diag "diag"
 } 
if "`hetcov'"!="" {
if !inlist("`hetcov'", "white", "nwest", "bart", "trunc", "parzen", "quad", "tukey") {
if !inlist("`hetcov'", "hdun", "hink", "crag", "jack", "tukeyn", "tukeym", "dan", "tent") {
di as err "{bf:hetcov()} {cmd:must be} {bf:({it:bart, crag, dan, hdun, hink, jack, nwest,}}"
di as err _col(19) "{bf:{it:parzen, quad, tent, trunc, tukey, tukeym, tukeyn, white})}"
di in smcl _c "{cmd: see:} {help `sthlp'##03:GMM Options}"
di in gr _c " (dlagif Help):"
 exit
 }
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
di in smcl _c "{cmd: see:} {help `sthlp'##05:Ridge Options}"
di in gr _c " (dlagif Help):"
 exit
 }	
 }
if inlist("`ridge'", "grr1", "grr2", "grr3") & `kr'>0 {
di as err " {bf:kr(#)} {cmd:must be not combined with:} {bf:ridge({it:grr1, grr2, grr3})}"
 exit
 }
if "`weights'"!="" {
if !inlist("`weights'", "yh",  "abse", "e2", "yh2", "x", "xi", "x2", "xi2") {
di as err " {bf:weights( )} {cmd:works only with:} {bf:yh}, {bf:yh2}, {bf:abse}, {bf:e2}, {bf:x}, {bf:xi}, {bf:x2}, {bf:xi2}"
di in smcl _c "{cmd: see:} {help `sthlp'##05:Options}"
di in gr _c " (dlagif Help):"
 exit
 }
 }
 if !inlist("`model'", "bcox") & "`lamp'"!="" {
di as err " {bf:lamp( )} {cmd:Valid only with:} {bf:model({it:bcox})}"
 exit
 }
 if "`lamp'"!="" {
 if !inlist("`lamp'", "lhs", "rhs", "alls", "alld") {
di as err " {bf:lamp( )} {cmd:must be} {bf:lamp({it:lhs, rhs, alls, alld})}"
di as err " {bf:lamp({it:lhs})}  {cmd:Power Transformations on Left Hand Side Only; default)}"
di as err " {bf:lamp({it:rhs})}  {cmd:Power Transformations on Right Hand Side Only)}"
di as err " {bf:lamp({it:alls})} {cmd:Same Power Transformations on both LHS & RHS)}"
di as err " {bf:lamp({it:alld})} {cmd:Different Power Transformations on both LHS & RHS)}"
 exit
 }
 }
 if inlist("`model'", "bcox") & "`lamp'"=="" {
 local lamp "lhs"
 }
 if "`model'"=="" {
 local model "ols"
 }
 if inlist("`model'", "als") {
 local ModeL "ALS"
 local Mtitle "Autoregressive Least Squares (ALS)"
 }
 if inlist("`model'", "arch") {
 local ModeL "ARCH"
 local Mtitle "Autoregressive Conditional Heteroskedasticity (ARCH)"
 }
 if inlist("`model'", "bcox") {
 local ModeL "Box-Cox"
 local Mtitle "Box-Cox Regression Model (Box-Cox)"
 }
 if inlist("`model'", "gls") {
 local ModeL "GLS"
 local Mtitle "Generalized Least Squares (GLS)"
 }
 if inlist("`model'", "gmm") {
 local ModeL "GMM"
 }
 if inlist("`model'", "qreg") {
 local ModeL "QREG"
 local Mtitle "Quantile Regression (QREG)"
 }
 if inlist("`model'", "rreg") {
 local ModeL "RREG"
 local Mtitle "Robust Regression (RREG)"
 }
 if !inlist("`model'", "als", "gls", "gmm", "qreg", "rreg", "arch", "bcox") {
 local ModeL "OLS"
 local Mtitle "Ordinary Least Squares (OLS)"
 }

di _dup(78) "{bf:{err:=}}"
di as txt _col(12) "{bf:{err:*** Irving Fisher Arithmetic Distributed Lag Model ***}}"
di _dup(78) "{bf:{err:=}}"
if !inlist("`model'", "gmm") {
noi di as err _col(2) "*** `Mtitle' ***"
 }
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
 }

qui {
tempvar _X _Y absE Ci COR DE DF1 DFF DumE DW DX DX_ DY_ cons _Z_ _W_ _Wx_ _Zx_
tempvar Yh_ML Yh_MLs Ue_ML Ue_MLs Yh_MLo Ue_MLo YBox LBoxZ yvarexp Zo Yhs Zw SLSVar
tempvar E E2 E3 E4 Ea Ea1 EDumE EE Eo Es Es1 Ev f1 fgF fgFp Hat ht ILVal L LDE
tempvar LVal LVal1 LY LYh LYh2 Rx X0 XQ fg Ls f13 LE LEo lf LnE2 WLSVar
tempvar Si SLv2 SSE Time U Ue VIFI Wis Wi Wio WS E1 E2 E12 EE1 LE1
tempvar XQX_ Yb Yh Yh2 Yhb Yho Yho2 Yhr Yt YY YYm YYv TimeN
tempname b B b1 b2 Beta BOLS BOLS1 Bv Bv1 Bx COR corr CORr Cov CovC Hat hjm R1 Ro1 it Evs
tempname Cr D DCor Dr Ds DX E E1 EE1 Eg eigVaL Eo EP Es Es2 HT IDRmk IPhi Sig2a BsZ
tempname Ew F f1 f13d fg FGFF fgT FLin FLog Go GoRY h Omega P Phi Pm q Q q1 q2 Qr _Ys _Xs
tempname J K L LDCor Ls LVal LVal1 M M1 M2 n nw NY OM Sig2n Sig2o Sig2o1 SLv2 Sn Sw LVR Lms
tempname S12 sd Sig2w Sig2 v2 VaL Val VaL1 VaL21 VaLv1 Vec vh VIF VIFI VM VP vy1 W W1
tempname We Wi Wi1 Wio WMAT WY X X0 xq XQ Xx Y Yh OmegaG S2y W1W W2 Aa Bb Cc Ss Qq
tempname Z Z0 Z1 Zo Zr Zz mh f13 SST1 SST2 V v1 Uew Yhw E11 SE1 SE12 SEE1 Phi R1 miss
tempname NT N kx DF kb Kr sqN Ko SSEo llf WMTD SLS Koi rid Rmk RX RY s S S11 Roi SE2 VCov
tempname Yh_ML Yh_MLs Ue_ML Ue_MLs Yh_MLo Ue_MLo DJ11 DJ20 DJ22 wald waldp Kk xOx xSx Yws Xws

 marksample touse
 markout `touse' `varlist' `wvar'
 gen `TimeN'=_n
 tsset `TimeN'
 preserve 
 gen `Time'=_n if `touse'
 tsset `Time'
 local NT1=r(tmin) + `lag'+1
 if "`nolag'"!="" {
 local NT1=r(tmin) + `lag' 
 }
 local NT2=r(tmax)
 local samp " in `NT1'/`NT2' "
 if "`wvar'"!="" {
 gen double `_Wx_' = `wvar'
 }
 if "`nolag'"=="" {
 if "`wvar'"!="" {
 replace `_Wx_' = L1.`wvar'
 }
 foreach var of local xvar {
 gen double `_Zx_'`var' = L1.`var'
 replace `var' = `_Zx_'`var'
 }
 }
 local NXvar ""
 foreach var of local xvar {
 forvalue i = 1/`lag' {
 local j=`lag'+1-`i'
 local j1= `j1'+`j'
 local Z_`var' "`Z_`var'' + `j'*L`i'.`var'"
 }
 local NXvar = "`NXvar' `Z_`var''"
 gen double `_Z_'`var'= (`Z_`var'')/`j1'
 }
 local kz : word count `xvar'
 local jkz=(`j1'/`kz')
 _rmcoll `_Z_'* , `noconstant' coll
 local ZVar "`r(varlist)'"

 if "`wvar'"!="" {
 local j1= 0
 replace `wvar'=`_Wx_'
 forvalue i = 1/`lag' {
 local j=`lag'+1-`i'
 local j1= `j1'+`j'
 local W_ "`W_' + `j'*L`i'.`wvar'"
 }
 gen double `_W_'= (`W_')/`j1'
 replace `wvar' = `_W_'
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
noi di as txt " {cmd:** `vlistlog'} "
noi di _dup(78) "-"
 local kvlog: word count `ZVar'
 forvalue i=1/`kvlog' {
 local var: word `i' of `ZVar'
 gen double `xvarexp'_`i'=(`var')
 replace `var'=ln(`var')
 }
 tsunab xvarexp : `xvarexp'_*
 }

 mark `miss'
 markout `miss' `yvar' `ZVar' `wvar'
 keep `samp'
 keep if `miss' == 1
 replace `Time'=_n 
 tsset `Time'
 count 
 local NT=r(N)
 local N=r(N)
 local kz : word count `xvar'
 local kx : word count `ZVar'
 local wgt ""
 gen `X0'=1 
 gen `Wi'=1
 gen `Wi1'= 1
 gen `Wis'= 1
 local WiB =1
 local _Yo "`yvar'"
 local _Xo "`ZVar'"
 mkmat `_Yo' , matrix(`Y')
 if "`noconstant'"!="" {
 mkmat `_Xo' , matrix(`X')
 scalar `DF'=`N'-`kx'
 scalar `kb'=`kx'
 }
 else { 
 mkmat `_Xo' `X0' , matrix(`X')
 scalar `DF'=`N'-`kx'-1
 scalar `kb'=`kx'+1
 }
 local Bz=`kx'
 local in=`N'/(`N'-`kb')
 if "`dn'"!="" {
 scalar `DF'=`N'
 local in=1
 }
 local Jkx=`kx'
 local Jkb=`kb'
 local JDF=`DF'
 if "`list'"!="" {
 if "`wvar'"!="" {
 putmata _W_`wvar'= `wvar' ,  replace omitmissing
 } 
 local YZVar "`yvar' `ZVar'"
 local YXVar "`yvar' `xvar'"
 local kyx : word count `varlist'
 forvalue i=1/`kyx' {
 local xz : word `i' of `YXVar'
 local zz : word `i' of `YZVar'
 putmata _Z_`xz'= `zz' ,  replace omitmissing
 } 
 } 

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
 regress `_Yo' `_Xo' , `noconstant'
 predict double `Yho' 
 predict double `Eo' , resid
 regress `Yho' `_Xo' , `noconstant'
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
 regress `Yho2' `_Xo' , `noconstant'
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
 matrix `Xws'=`Wi'*`X'
 matrix `xOx'=`X''*`X'
 matrix `xSx'=`Xws''*`Xws'
 scalar `Kr'=0
 matrix `Zz'=I(`Jkb')*0
 local kxy =`Jkx'+1
 gen double `Zo'= `Wi'
 gen `Zw'=.
 local Yw_Xw "`X0' `_Yo' `_Xo'"
 local kXw: word count `Yw_Xw'
 forvalue i=1/`kXw' {
 local v : word `i' of `Yw_Xw'
 replace `Zw' = `v'*`Wi'
 gen double `WLSVar'_`i' = `Zw'
 }
 tsunab ZWLSVar : `WLSVar'_*
 tokenize `ZWLSVar'
 local Zo `1'
 macro shift
 local bXWLS "`*'"
 gettoken _Yw _Xw : bXWLS
 if "`ridge'"!="" {
 scalar `Kr'=`kr'
 local Ro1= 0 
 replace `Zo' = `WiB'
 if inlist("`model'", "als") & `ar' == 1 {
 if "`noconstant'"!="" {
 prais `_Yw' `_Xw' , noconstant rhotype(regress)
 }
 else {
 prais `_Yw' `_Xw' `Zo' , noconstant rhotype(regress)
 }
 local Ro1= e(rho) 
 tempvar WLSVar
 local Yw_Xw "`_Yw' `_Xw'"
 local kXw: word count `Yw_Xw'
 forvalue i=1/`kXw' {
 local v : word `i' of `Yw_Xw'
 replace `Zw' = `v'
 gen double `WLSVar'_`i' = `Zw'-`Ro1'*`Zw'[_n-1] 
 replace `WLSVar'_`i' = `Zw'*sqrt(1-`Ro1'^2) in 1
 }
 tsunab ZWLSVar : `WLSVar'_*
 tokenize `ZWLSVar'
 local _Yw `1'
 macro shift
 local _Xw "`*'"
 tokenize `_Xw'
 replace `Zw' = `WiB'
 replace `Zo' = `Zw'-`Ro1'*`Zw'[_n-1] 
 replace `Zo' = `Zw'*sqrt(1-`Ro1'^2) in 1
 }
 local Zo_Xw "`Zo' `_Xw'"
 local kXw: word count `Zo_Xw'
 forvalue i=1/`kXw' {
 local v : word `i' of `Zo_Xw'
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
 mkmat `_Xw' , matrix(`Xws')
 tabstat `_Xw' , statistics( sd ) save
 }
 else {
 mkmat `ZSLSVar' `ZoC' , matrix(`Zr')
 mkmat `_Xw' `Zo' , matrix(`Xws')
 tabstat `_Xw' `ZoC' , statistics( sd ) save
 }

 if inlist("`ridge'", "orr") {
 local rtitle "{bf:Ordinary Ridge Regression}"
 }
 if inlist("`ridge'", "grr1") {
 local rtitle "{bf:Generalized Ridge Regression}"
 matrix `sd'=r(StatTotal)
 scalar `sqN'=sqrt(`N'-1)
 matrix `WMTD'=diag(`sd')*`sqN'
 matrix `Beta'=invsym(`Xws''*`Xws')*`Xws''*`Yws'
 matrix `BOLS'=`WMTD''*`Beta'
 matrix `BOLS'=`BOLS''*`BOLS'
 scalar `BOLS1'=`BOLS'[1,1]
 matrix `Sig2o'=`Yws'-`Xws'*`Beta'
 matrix `Sig2o'=(`Sig2o''*`Sig2o')/`DF'
 scalar `Sig2o1'=`Sig2o'[1,1]
 scalar `Kr'=`Jkx'*`Sig2o1'/`BOLS1'
 }
 if inlist("`ridge'", "grr2") {
 local rtitle "{bf:Iterative Generalized Ridge Regression}"
 matrix `sd'=r(StatTotal)
 scalar `sqN'=sqrt(`N'-1)
 matrix `WMTD'=diag(`sd')*`sqN'
 matrix `Beta'=invsym(`Xws''*`Xws')*`Xws''*`Yws'
 matrix `BOLS'=`WMTD''*`Beta'
 matrix `BOLS'=`BOLS''*`BOLS'
 scalar `BOLS1'=`BOLS'[1,1]
 matrix `Sig2o'=`Yws'-`Xws'*`Beta'
 matrix `Sig2o'=(`Sig2o''*`Sig2o')/`DF'
 scalar `Sig2o1'=`Sig2o'[1,1]
 scalar `Kr'=`Jkx'*`Sig2o1'/`BOLS1'
 forvalue i=1/`iter' { 
 scalar `Ko'=`Kr'
 matrix `rid'=I(`Jkb')*`Kr'
 matrix `Zz'=diag(vecdiag(`Zr''*`Zr'*`rid'))
 matrix `Beta'=invsym(`Xws''*`Xws'+`Zz')*`Xws''*`Yws'
 matrix `BOLS'=`WMTD''*`Beta'
 matrix `BOLS'=`BOLS''*`BOLS'
 scalar `BOLS1'=`BOLS'[1,1]
 tempname Kit`i' Koi
 scalar `Kit`i''=`Jkx'*`Sig2o1'/`BOLS1'
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
 corr `_Xw' `_Yw'
 matrix `CovC'=r(C)
 matrix `RY' = `CovC'[`Jkb' ,1..`Jkx']
 matrix `RX' = `CovC'[1..`Jkx', 1..`Jkx']
 matrix symeigen `Vec' `VaL'=`RX'
 matrix `VaL1' =`VaL''
 svmat double `VaL1' , name(`VaL1')
 rename `VaL1'1 `VaL1'
 replace `VaL1'=1/`VaL1' in 1/`Jkx' 
 mkmat `VaL1' in 1/`Jkx' , matrix(`VaLv1')
 matrix `VaL21' =diag(`VaLv1')
 matrix `VaL21' = `VaL21'[1..`Jkx', 1..`Jkx']
 matrix `Go'=`Vec'*`VaL21'*`Vec''
 matrix `GoRY'=`Go'*`RY''
 matrix `SSE'=1-`RY'*`GoRY'
 matrix `Sig2'=`SSE'/`DF'
 matrix `Qr'=`GoRY''*`GoRY'-`Sig2'*trace(`Go')
 matrix `LVR'=`Vec''*`RY''
 svmat double `LVR' , name(`LVR')
 rename `LVR'1 `LVR'
 scalar `Kr'=0
 forvalue i=1/`iter' { 
 tempname Ko`i'
 scalar `Ko'=`Kr'
 scalar `Ko`i''=`Kr'
 matrix `rid'=I(`Jkx')
 matrix `rid'=vecdiag(`rid')*`Kr'
 matrix `f1'=`VaL1'+`rid''
 cap drop `f1'*
 cap drop `f13'*
 svmat double `f1' , name(`f1')
 rename `f1'1 `f1'
 gen double `f13'`i'=`f1'^3 in 1/`Jkx'
 mkmat `f13'`i' in 1/`Jkx' , matrix(`f13')
 matrix `f13d'=diag(`f13')
 matrix `f13' =`f13d'[1..`Jkx', 1..`Jkx']
 matrix `Rmk' =vecdiag(`f13')'
 matrix `IDRmk'=invsym(`f13')
 matrix `Lms'=`LVR''*`IDRmk'
 matrix `Lms'=(`Lms'*diag(`LVR'))'
 cap drop `Lms' `lf'
 svmat double `Lms' , name(`Lms'`i')
 rename `Lms'`i'1 `Lms'`i'
 summ `Lms'`i' in 1/`Jkx'
 scalar `SLS'=r(sum)
 gen double `lf'`i'=`LVR'/`f1' in 1/`Jkx'
 mkmat `lf'`i' in 1/`Jkx' , matrix(`lf'`i')
 matrix `lf'`i' =diag(`lf'`i')
 matrix `lf'`i' = `lf'`i'[1..`Jkx', 1..`Jkx']
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
 matrix `rid'=I(`Jkb')*`Kr'
 matrix `Zz'=diag(vecdiag((`Zr''*`Zr')*`rid'))
 }
 local leveln " level(`level') "
 local itern " iter(`iter') "
 local techn " techn(`techn') "
 local vcen " vce(`vce') "
noi di
noi di as txt " `yvar' = [`NXvar']/`jkz' "
 if inlist("`model'", "qreg", "rreg") {
 if inlist("`model'", "qreg") {
 qreg `_Yo' `_Xo' `wgt' , nolog `leveln' quantile(`quantile')
 local R2_P = 1 - (e(sum_adev)/e(sum_rdev))
 }
 if inlist("`model'", "rreg") {
 rreg `_Yo' `_Xo' , `itern' nolog `leveln' tune(`tune')
 local R2_P = e(r2)
 }
 matrix `B'=e(b)'
 matrix `Cov'=e(V)
 predict double `Ue_ML' , resid
 predict double `Yh_ML' , xb
 mkmat `Ue_ML' , matrix(`Ue_ML')
 mkmat `Yh_ML' , matrix(`Yh_ML')
 }

 if inlist("`model'", "arch") {
 arch `_Yo' `_Xo' `wgt' , `noconstant' nolog `vcen' `techn' `itern' `leveln' `auto'
 scalar `wald'= e(chi2)
 scalar `waldp'= e(p)
 local LLFs=e(ll)
 matrix `B'=e(b)
 matrix `B' = `B'[1, 1..`Jkb']'
 matrix `Cov'=e(V)
 matrix `Cov'=`Cov'[1..`Jkb' ,1..`Jkb']
 predict double `Ue_ML' , resid
 predict double `Yh_ML' , xb
 mkmat `Ue_ML' , matrix(`Ue_ML')
 mkmat `Yh_ML' , matrix(`Yh_ML')
 }

 if inlist("`model'", "bcox") {
 if inlist("`lamp'", "lhs") {
 boxcox `_Yo' `_Xo' `wgt' , model(lhsonly) `noconstant' nolog `itern' `leveln'
 local Lam=_b[theta:_cons]
 gen double `YBox'=(`_Yo'^`Lam'-1)/`Lam'
 tsunab ZBox : `ZVar'
 }
 else {
 if inlist("`lamp'", "rhs") {
 boxcox `_Yo' `_Xo' `wgt' , model(rhsonly) `noconstant' nolog `itern' `leveln'
 local Lam=_b[lambda:_cons]
 gen double `YBox'=`_Yo'
 local kBox : word count `ZVar'
 forvalue i=1/`kBox' {
 local var: word `i' of `ZVar'
 gen double `ZBoxL'`i'=(`var'^`Lam'-1)/`Lam'
 }
 }
 if inlist("`lamp'", "alls") {
 boxcox `_Yo' `_Xo' `wgt' , model(lambda) `noconstant' nolog `itern' `leveln'
 local Lam=_b[lambda:_cons]
 gen double `YBox'=(`_Yo'^`Lam'-1)/`Lam'
 foreach var of local ZVar {
 gen double `ZBoxL'`var'=(`var'^`Lam'-1)/`Lam'
 }
 }
 if inlist("`lamp'", "alld") {
 boxcox `_Yo' `_Xo' `wgt' , model(theta) `noconstant' nolog `itern' `leveln'
 local Lam=_b[theta:_cons]
 gen double `YBox'=(`_Yo'^`Lam'-1)/`Lam'
 local Gam=_b[lambda:_cons]
 foreach var of local ZVar {
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
 local _Xw "`ZBox'"
 mkmat `Ue_ML' , matrix(`Ue_ML')
 mkmat `Yh_ML' , matrix(`Yh_ML')
 if "`ridge'"!="" & `Kr' > 0 {
 tempvar SLSVar
 local Zo_Xw "`Zo' `_Xw'"
 local kXw: word count `Zo_Xw'
 forvalue i=1/`kXw' {
 local v : word `i' of `Zo_Xw'
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
 mkmat `_Yw' , matrix(`Yws')
 if "`noconstant'"!="" {
 mkmat `ZSLSVar' , matrix(`Zr')
 mkmat `_Xw' , matrix(`Xws')
 }
 else {
 mkmat `ZSLSVar' `ZoC' , matrix(`Zr')
 mkmat `_Xw' `Zo' , matrix(`Xws')
 }
 matrix `Zz'=diag(vecdiag((`Zr''*`Zr')*`rid'))
 matrix `xSx'=`Xws''*`Xws'
 matrix `B'=invsym(`xSx'+`Zz')*`Xws''*`Yws' 
 }
 tempvar Yh_ML Ue_ML Yhs
 matrix `Yhs'=(`Xws'*`B')
 svmat double `Yhs' , name(`Yhs')
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
 matrix `E'=`Wi'*(`Y'-`X'*`B')
 matrix `Sig2'=`E''*`E'/`DF'

 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`xSx'+`Zz')*`xSx'*invsym(`xSx'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`xSx')
 }
 }

 if inlist("`model'", "als") & `ar'>1 {
 arima `_Yo' `_Xo' `wgt' , `noconstant' nolog `vcen' `techn' `itern' `leveln' `auto' `condition'
 scalar `wald'= e(chi2)
 scalar `waldp'= e(p)
 local LLFs=e(ll)
 matrix `B'=e(b)
 matrix `B' = `B'[1, 1..`Jkb']'
 matrix `Cov'=e(V)
 matrix `Cov'=`Cov'[1..`Jkb' ,1..`Jkb']
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
 regress `_Yo' `_Xo' `wgt' , `noconstant' `leveln' `robust'
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
noi di as res _col(5) `it' _col(20) as res %10.6f `R1' _col(35) as res %10.4f `LLFs' _col(50) as res %10.4f `SSEo'
 tempvar WLSVar SLSVar ZoC SLSVarC
 local Yw_Xw "`_Yo' `_Xo'"
 local kXw: word count `Yw_Xw'
 forvalue i=1/`kXw' {
 local v : word `i' of `Yw_Xw'
 replace `Zw' = `v'*`Wi'
 gen double `WLSVar'_`i' = `Zw'-`Ro1'*`Zw'[_n-1] 
 replace `WLSVar'_`i' = `Zw'*sqrt(1-`Ro1'^2) in 1
 }
 tsunab ZWLSVar : `WLSVar'_*
 tokenize `ZWLSVar'
 local _Yw `1'
 macro shift
 local _Xw "`*'"
 tokenize `_Xw'
 replace `Zw' = `WiB'
 replace `Zo' = `Zw'-`Ro1'*`Zw'[_n-1] 
 replace `Zo' = `Zw'*sqrt(1-`Ro1'^2) in 1
 mkmat `_Yw' , matrix(`Yws')
 if "`noconstant'"!="" {
 mkmat `_Xw' , matrix(`Xws')
 }
 else {
 mkmat `_Xw' `Zo' , matrix(`Xws')
 }
 if "`ridge'"!="" & `Kr' > 0 {
 tempvar SLSVar
 local Zo_Xw "`Zo' `_Xw'"
 local kXw: word count `Zo_Xw'
 forvalue i=1/`kXw' {
 local v : word `i' of `Zo_Xw'
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
 if "`noconstant'"!="" {
 mkmat `ZSLSVar' , matrix(`Zr')
 tabstat `_Xw' , statistics( sd ) save
 }
 else {
 mkmat `ZSLSVar' `ZoC' , matrix(`Zr')
 tabstat `_Xw' `ZoC' , statistics( sd ) save
 }
 matrix `rid'=I(`Jkb')*`Kr'
 matrix `Zz'=diag(vecdiag((`Zr''*`Zr')*`rid'))
 }
 matrix `B'=invsym(`Xws''*`Xws'+`Zz')*`Xws''*`Yws'
 matrix `xSx'=`Xws''*`Xws'
 matrix `E'=`Wi'*(`Y'-`X'*`B')
 matrix `Ue_ML'=(`Yws'-`Xws'*`B')
 matrix `Ue_MLs'=(`Yws'-`Xws'*`B')
 matrix `Yh_MLs'=(`Xws'*`B')
 matrix `SSE'=`Ue_ML''*`Ue_ML'
 scalar `SSEo'=`SSE'[1,1]
 scalar `Sig2'=`SSEo'/`DF'
 cap drop `E'
 cap drop `LE1'
 svmat double `E' , name(`E')
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
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`xSx'+`Zz')*`xSx'*invsym(`xSx'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`Xws''*`Xws')
 }
 matrix `Ue_ML'=(`Yws'-`Xws'*`B')
 matrix `Yh_ML'=`Y'-`Ue_ML' 
 } 

 if `iter' == e(ic) {
noi di 
noi di as err " {bf:** Convergence has not Achieved, try to increase number of iterations **}"
 }

 if inlist("`model'", "ols", "gls") {
 matrix `xSx'=`Xws''*`Xws'
 matrix `B'=invsym(`Xws''*`Xws'+`Zz')*`Xws''*`Yws'
 matrix `E'=`Wi'*(`Y'-`X'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`xSx'+`Zz')*`xSx'*invsym(`xSx'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`xSx')
 }
 matrix `Yh_ML'=(`X'*`B')
 matrix `Ue_ML'=(`Y'-`X'*`B')
 }

 if inlist("`model'", "gmm") {
noi di _dup(78) "-"
 if "`hetcov'"=="" {
 local hetcov "white"
 }
 if inlist("`hetcov'", "crag") { 
noi di as txt "{bf:{err:* Cragg (1983) Auxiliary Variables Regression}}"
 matrix `B'=invsym(`Xws''*`Xws'+`Zz')*`Xws''*`Yws'
 matrix `E'=`Wi'*(`Y'-`X'*`B')
 matrix `Eo'=diag(`E')
 matrix `OM'=`Eo'*`Eo'
 foreach var of local ZVar {
 gen double `XQ'`var' = `var'^2 
 }
 mkmat `XQ'* , matrix(`XQ')
 matrix `Q'=`X' , `XQ' 
 matrix `Q'=`Wi'*`Q'
 matrix `OmegaG'=`Q'*invsym(`Q''*`OM'*`Q')*`Q''
 matrix `B'=invsym(`Xws''*`OmegaG' *`Xws'+`Zz')*(`Xws''*`OmegaG' *`Yws')
 matrix `E'=`Wi'*(`Y'-`X'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`xSx'+`Zz')*`xSx'*invsym(`xSx'+`Zz')
 }
 else {
 matrix `Cov'=invsym(`Xws''*`OmegaG'*`Xws')
 }
 }

 if inlist("`hetcov'", "hdun") { 
noi di as txt "{bf:{err:* Horn-Duncan (1975) Regression}}"
 matrix `HT' = vecdiag(`Xws'*invsym(`Xws''*`Xws')*`Xws'')'
 svmat double `HT' , name(`HT')
 gen double `DX'=(1-`HT'1)
 matrix `B'=invsym(`Xws''*`Xws'+`Zz')*`Xws''*`Yws'
 matrix `E'=`Wi'*(`Y'-`X'*`B')
 matrix `Eo'=diag(`E')
 matrix `OM'=vecdiag(`Eo'*`Eo')'
 svmat double `OM' , name(`Es2')
 rename `Es2'1 `Es2'
 gen double `OM' =`Es2'/`DX' 
 mkmat `OM' , matrix(`OM')
 matrix `OM'=diag(`OM')
 matrix `OmegaG'=`Xws'*invsym(`Xws''*`OM'*`Xws')*`Xws''
 matrix `B'=invsym(`Xws''*`OmegaG'*`Xws'+`Zz')*`Xws''*`OmegaG'*`Yws'
 matrix `E'=`Wi'*(`Y'-`X'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`xSx'+`Zz')*`xSx'*invsym(`xSx'+`Zz')
 }
 else {
  matrix `Cov'=invsym(`Xws''*`Xws')*(`Xws''*`OM'*`Xws')*invsym(`Xws''*`Xws')
 }
 }
 
 if inlist("`hetcov'", "hink") { 
noi di as txt "{bf:{err:* Hinkley (1977) Method Regression}}"
 matrix `B'=invsym(`Xws''*`Xws'+`Zz')*`Xws''*`Yws'
 matrix `E'=`Wi'*(`Y'-`X'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 matrix `Eo'=diag(`E')
 matrix `OM'=`Eo'*`Eo'
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`xSx'+`Zz')*`xSx'*invsym(`xSx'+`Zz')
 }
 else {
 matrix `Cov'=`in'*invsym(`Xws''*`Xws')*(`Xws''*`OM'*`Xws')*invsym(`Xws''*`Xws')
 }
 }

 if inlist("`hetcov'", "jack") { 
noi di as txt "{bf:{err:* Jackknife Mackinnon-White (1985) Regression}}"
 tempvar E Eo Yh
 matrix `B'=invsym(`Xws''*`Xws'+`Zz')*`Xws''*`Yws'
 matrix `Yh'=`Wi1'*(`X'*`B')
 svmat double `Yh' , name(`Yh')
 rename `Yh'1 `Yh'
 matrix `E'=`Wi'*(`Y'-`X'*`B')
 svmat double `E' , name(`Eo')
 rename `Eo'1 `Eo'
 matrix `HT' = vecdiag(`Xws'*invsym(`Xws''*`Xws')*`Xws'')'
 svmat double `HT' , name(`HT')
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
 matrix `B'=invsym(`Xws''*`Xws'+`Zz')*(`Xws''*`NY')
 matrix `E'=`Wi'*(`Y'-`X'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`xSx'+`Zz')*`xSx'*invsym(`xSx'+`Zz')
 }
 else {
 matrix `Cov'=((`N'-1)/`N')*invsym(`xSx')*(`Xws''*`OM'*`Xws'-(1/`N')*(`Xws''*`Es'*`Es''*`Xws'))*invsym(`xSx')
 }
 }

 if inlist("`hetcov'", "white") {
noi di as err " *** Generalized Method of Moments (GMM) - (White Method) ***"
 matrix `B'=invsym(`Xws''*`Xws'+`Zz')*`Xws''*`Yws'
 matrix `E'=`Wi'*(`Y'-`X'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 matrix `OM'=diag(`E')
 matrix `OmegaG'=`OM'*`OM'
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`xSx'+`Zz')*`xSx'*invsym(`xSx'+`Zz')
 }
 else {
 matrix `Cov'=invsym(`Xws''*`Xws')*(`Xws''*`OmegaG'*`Xws')*invsym(`Xws''*`Xws')
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
 foreach var of local ZVar {
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
 matrix `B'=invsym(`Xws''*`Xws'+`Zz')*`Xws''*`Yws'
 matrix `E'=`Wi'*(`Y'-`X'*`B')
 svmat double `E' , name(`Eg')
 rename `Eg'1 `Eg'
 gen double `E1'=`Eg'[_n-1] 
 gen double `EE1'=`E1'*`Eg' 
 replace `EE1' = 0 if `EE1'==.
 mkmat `EE1' , matrix(`EE1')
 matrix `OM'=diag(`E')
 matrix `We'=`OM'*`OM'
 matrix `Sw'=`Xws''*`We'*`Xws'
 matrix `We'=diag(`EE1')
 matrix `S11'=`Xws''*`We'*`M'
 matrix `S12'=`M''*`We'*`Xws'
 matrix `Sn'=(`S11'+`S12')*`kw'
 matrix `nw'=(`Sw'+`Sn')*`in'
 matrix `OmegaG'=`Xws'*invsym(`Xws''*`Xws')*`Xws''
 matrix `B'=invsym(`Xws''*`OmegaG' *`Xws'+`Zz')*(`Xws''*`OmegaG' *`Yws')
 matrix `E'=`Wi'*(`Y'-`X'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`xSx'+`Zz')*`xSx'*invsym(`xSx'+`Zz')
 }
 else {
 matrix `Cov'=invsym(`xSx')*`nw'*invsym(`xSx')
 }
 }
 matrix `Ue_ML' = (`Y'-`X'*`B')
 matrix `Yh_ML' = (`X'*`B')
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
 matrix `Ue_MLo' = (`Y'-`X'*`B')
 matrix `Yh_MLo' = (`X'*`B')
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
 correlate `Yh_MLo' `_Yo'  `wgt'
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
 if inlist("`model'", "als", "bcox", "gls", "gmm", "ols", "qreg", "rreg") {
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
 matrix `Ew'=`Wi1'*(`Y'-`X'*`B')
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
 local Dof =`DF'
 matrix `B'=`B''
 tokenize " `xvar' "
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
 ereturn scalar r2raw =`r2raw'
 ereturn scalar r2raw_a=`r2raw_a'
 ereturn scalar llf =`llf'
 ereturn scalar sig=`Sigo'
 ereturn scalar r2h=`r2h'
 ereturn scalar r2h_a=`r2h_a'
 ereturn scalar fh=`fh'
 ereturn scalar fhp=`fhp'
 ereturn scalar Kr=`Kr'
 ereturn scalar Jkx=`Jkx'
 ereturn scalar Jkb=`Jkb'
 ereturn scalar DF=`DF'
 ereturn scalar NT=_N
 ereturn scalar R20=`R20'

noi ereturn display , `level' 
 matrix `b'=e(b)
 matrix `V'=e(V)
 matrix `Bx'=e(b)
 matrix `Beta'=e(b)
 matrix `VCov'=e(V)
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
 matrix `E'=`Wi'*(`Y'-`X'*`B')
 svmat double `E' , name(`E') 
 matrix `Ue_ML1'=`Wi'*(`Yws'-`Xws'*`B')
 svmat double `Ue_ML1' , name(`Ue_ML1')
 rename `Ue_ML1'1 `Ue_ML1'
 replace `Ue_ML1'=`E'1 in 1
 mkmat `Ue_ML1' , matrix(`Ue_ML1')
 matrix `Yh_ML1'=`Y'-`Ue_ML1' 
 svmat double `Yh_ML1' , name(`Yh_ML1')
 rename `Yh_ML1'1 `Yh_ML1'
 if "`predict'"!= "" {
 putmata `predict'=`Yh_ML1' , replace
 }
 if "`resid'"!= "" {
 putmata `resid'=`Ue_ML1' , replace
 }
 }

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
tempname SSE Rho lmabpg lmabgd lmadmk lmabgk Pa1 lmadha lmadhap lmahha lmahhap
tempname lmabp lmalb Po lmadho lmadhop lmahho lmahhop SSEa Pa lmakg
tempvar Yh Yh2 E E2 E3 E4 Es
 local N=`NT'
 tsset `Time'
 gen double `Yh' =`Yh_MLo'
 gen double `E' =`Ue_MLo'
 forvalue i=1/`ar' {
tempvar E`i' EE`i' LE`i' LEo`i' DE`i' LEE`i'
 gen double `E`i''=`E'^`i' 
 gen double `LEo`i''=L`i'.`E' 
 replace `LEo`i''= 0 in 1/`i'
 gen double `LE`i'' =L`i'.`E' 
 gen double `LEE`i''=L`i'.`E'*`E' 
 summ `LEE`i'' 
 scalar `SSE'`i'=r(sum)
 scalar `Rho'`i'=`SSE'`i'/`SSEo'
 regress `E' `LEo`i'' `_Xo' , `noconstant'
 scalar `lmabpg'`i'=sqrt(e(N)*e(r2))
 tempvar LEo LE
 gen double `LEo'`i'=L`i'.`E' 
 replace `LEo'`i'= 0 in 1/`i'
 gen double `LE'`i' =L`i'.`E' 
 regress `E' `LE'* `_Xo' , `noconstant'
 scalar `lmabgd'`i'=e(N)*e(r2)
 testparm `LE'*
 scalar `lmadmk'`i'=r(F)*`i'
 regress `E' `LEo'* `_Xo' , `noconstant'
 scalar `lmabgk'`i'=e(N)*e(r2)
noi di as txt "- Rho Value for Order(" `i' ")" _col(40) "AR(" `i' ")=" %8.4f `Rho'`i'
 ereturn scalar rho`i'=`Rho'`i'
noi di as txt "- Breusch-Godfrey LM Test (drop `i' obs)" _col(40) "AR(" `i' ")=" %8.4f `lmabgd'`i' _col(56) "P-Value >Chi2(`i')" _col(73) %5.4f chi2tail(`i', abs(`lmabgd'`i'))
 ereturn scalar lmabgd`i'=`lmabgd'`i'
 ereturn scalar lmabgdp`i'=chi2tail(`i', abs(`lmabgd'`i'))
noi di as txt "- Breusch-Godfrey LM Test (keep `i' obs)" _col(40) "AR(" `i' ")=" %8.4f `lmabgk'`i' _col(56) "P-Value >Chi2(`i')" _col(73) %5.4f chi2tail(`i', abs(`lmabgk'`i'))
 ereturn scalar lmabgk`i'=`lmabgk'`i'
 ereturn scalar lmabgkp`i'=chi2tail(`i', abs(`lmabgk'`i'))
noi di as txt "- Breusch-Pagan-Godfrey LM Test" _col(40) "AR(" `i' ")=" %8.4f `lmabpg'`i' _col(56) "P-Value >Chi2(`i')" _col(73) %5.4f chi2tail(`i', abs(`lmabpg'`i'))
noi di _dup(78) "-"
 }
 }

 if "`lmhet'" != "" {
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:*** {err:Heteroscedasticity Tests} - {bf:(Model= {err:`ModeL'})}}"
noi di _dup(78) "{bf:{err:-}}"
noi di as txt "{bf: Ho: Homoscedasticity - Ha: Heteroscedasticity}"
noi di _dup(78) "-"
tempname dfw0 lmhw01 lmhw01p lmhw02 lmhw02p lmhharv lmhharvp lmhhp1
tempname lmhhp1p lmhhp2 lmhhp2p lmhhp3 lmhhp3p lmharch lmharchp lmhbg lmhbgp 
tempvar Yh Yh2 E E2 E3 E4 LYh2 LnE2
 local N=`NT'
 tsset `Time'
 gen double `Yh' =`Yh_MLo'
 gen double `E' =`Ue_MLo'
 gen double `Yh2'=`Yh'^2 
 gen double `LYh2'=ln(`Yh2') 
 gen double `E2'=`E'^2 
 gen double `LnE2'=log(`E2') 
 regress `E2' `_Xo' , `noconstant'
 scalar `dfw0'=e(df_m)
 scalar `lmhw01'=e(r2)*e(N)
 scalar `lmhw01p'= chi2tail(`dfw0' , abs(`lmhw01'))
 scalar `lmhw02'=e(mss)/(2*`Sig2n'^2)
 scalar `lmhw02p'= chi2tail(`dfw0' , abs(`lmhw02'))
 regress `LnE2' `_Xo' , `noconstant'
 scalar `lmhharv'=e(mss)/4.9348
 scalar `lmhharvp'= chi2tail(2, abs(`lmhharv'))
 regress `E2' `Yh' 
 scalar `lmhhp1'=e(N)*e(r2)
 scalar `lmhhp1p'= chi2tail(1, abs(`lmhhp1'))
 regress `E2' `Yh2' 
 scalar `lmhhp2'=e(N)*e(r2)
 scalar `lmhhp2p'= chi2tail(1, abs(`lmhhp2'))
 regress `E2' `LYh2' 
 scalar `lmhhp3'=e(N)*e(r2)
 scalar `lmhhp3p'= chi2tail(1, abs(`lmhhp3'))
 tsset `Time'
 cap drop `LE'*
 forvalue i = 1/`ar' {
 gen double `LE'`i'=L`i'.`E2' 
 regress `E2' `LE'* 
 scalar `lmharch'`i'=e(r2)*e(N)
 scalar `lmharchp'`i'= chi2tail(`i', abs(`lmharch'`i'))
noi di as txt "- Engle LM ARCH Test AR(`i') E2=E2_1-E2_`i'" _col(40) "=" %9.4f `lmharch'`i' _col(53) " P-Value > Chi2(`i')" _col(73) %5.4f `lmharchp'`i'
 }
 regress `E2' L1.`E2' `_Xo' , `noconstant'
 scalar `lmhbg'=e(r2)*e(N)
 scalar `lmhbgp'= chi2tail(1, abs(`lmhbg'))
noi di _dup(78) "-"
noi di as txt "- Hall-Pagan LM Test:      E2 = Yh" _col(40) "=" %9.4f `lmhhp1' _col(53) " P-Value > Chi2(1)" _col(73) %5.4f `lmhhp1p'
noi di as txt "- Hall-Pagan LM Test:      E2 = Yh2" _col(40) "=" %9.4f `lmhhp2' _col(53) " P-Value > Chi2(1)" _col(73) %5.4f `lmhhp2p'
noi di as txt "- Hall-Pagan LM Test:      E2 = LYh2" _col(40) "=" %9.4f `lmhhp3' _col(53) " P-Value > Chi2(1)" _col(73) %5.4f `lmhhp3p'
noi di _dup(78) "-"
noi di as txt "- Harvey LM Test:       LogE2 = X" _col(40) "=" %9.4f `lmhharv' _col(53) " P-Value > Chi2(2)" _col(73) %5.4f `lmhharvp'
noi di as txt "- White Test -Koenker(R2): E2 = X" _col(40) "=" %9.4f `lmhw01' _col(53) " P-Value > Chi2(" `dfw0' ")" _col(73) %5.4f `lmhw01p'
noi di as txt "- White Test -B-P-G (SSR): E2 = X" _col(40) "=" %9.4f `lmhw02' _col(53) " P-Value > Chi2(" `dfw0' ")" _col(73) %5.4f `lmhw02p'
noi di _dup(78) "-"
 ereturn scalar lmhw01= `lmhw01'
 ereturn scalar lmhw01p= `lmhw01p'
 ereturn scalar lmhw02= `lmhw02'
 ereturn scalar lmhw02p= `lmhw02p'
 ereturn scalar lmhharv= `lmhharv'
 ereturn scalar lmhharvp= `lmhharvp'
 ereturn scalar lmhbg= `lmhbg'
 ereturn scalar lmhbgp= `lmhbgp'
 ereturn scalar lmhhp1= `lmhhp1'
 ereturn scalar lmhhp1p= `lmhhp1p'
 ereturn scalar lmhhp2= `lmhhp2'
 ereturn scalar lmhhp2p= `lmhhp2p'
 ereturn scalar lmhhp3= `lmhhp3'
 ereturn scalar lmhhp3p= `lmhhp3p'
 forvalue i = 1/`ar' {
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
 local N=`NT'
tempvar Yh E E1 E2 E3 E4 Es DE LDE LDF1 Hat 
tempname Hat Eb Sk Ku M2 M3 M4 K2 K3 K4 Ss Kk GK N1 N2 EN S2N SN
tempname B2 B3 LA Z Rn R2W S1 S2 S3 S4 pc1 pc2 pc3 pc4 
 tsset `Time'
 gen double `E' =`Ue_ML'
 gen double `E2'=`E'*`E' 
 regress `_Yw' `_Xw' `Zo' , noconstant
 predict `Hat' ,  hat 
 regress `E2' `Hat' 
 scalar `R2W'=e(r2)
 summ `E' , det
 scalar `Eb'=r(mean)
 scalar `Sk'=r(skewness)
 scalar `Ku'=r(kurtosis)
 forvalue i = 1/4 {
 gen double `E'`i'=(`E'-`Eb')^`i' 
 summ `E'`i' `wgt'
 scalar `S`i''=r(mean)
 scalar `pc`i''=r(sum)
 }
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
 gen `DE'=1 if `E'>0
 replace `DE'=0  if `E' <= 0
 count if `DE'>0
 scalar `N1'=r(N)
 scalar `N2'=`N'-r(N)
 scalar `EN'=(2*`N1'*`N2')/(`N1'+`N2')+1
 scalar `S2N'=(2*`N1'*`N2'*(2*`N1'*`N2'-`N1'-`N2'))/((`N1'+`N2')^2*(`N1'+`N2'-1))
 scalar `SN'=sqrt((2*`N1'*`N2'*(2*`N1'*`N2'-`N1'-`N2'))/((`N1'+`N2')^2*(`N1'+`N2'-1)))
 gen `LDE'= `DE'[_n-1]  
 replace `LDE'=0 if `DE'==1 in 1
 gen `LDF1'= 1  if `DE' != `LDE'
 replace `LDF1'= 1 if `DE' == `LDE' in 1
 replace `LDF1'= 0 if `LDF1' == .
 count if `LDF1'>0
 scalar `Rn'=r(N)
 ereturn scalar lmng=(`Rn'-`EN')/`SN'
 ereturn scalar lmngp= chi2tail(2, abs(e(lmng)))
noi di as txt "- Jarque-Bera LM Test" _col(40) "=" %9.4f e(lmnjb) _col(55) "P-Value > Chi2(2) " _col(73) %5.4f e(lmnjbp)
noi di as txt "- White IM Test" _col(40) "=" %9.4f e(lmnw) _col(55) "P-Value > Chi2(2) " _col(73) %5.4f e(lmnwp)
noi di as txt "- Geary LM Test" _col(40) "=" %9.4f e(lmng) _col(55) "P-Value > Chi2(2) " _col(73) %5.4f e(lmngp)
noi di _dup(78) "-"
 }

 if "`mfx'"!="" {
 tempvar ZSLS 
 tempname _Yoz _Xoz
 unab varlist: `_Xo'
 foreach var of local varlist {
 summ `var' `wgt'
 gen double `ZSLS'_`var' = r(sd)
 }
 tsunab ZSLS : `ZSLS'_*
 tokenize `ZSLS'
 summ `_Yo' `wgt'
 scalar `_Yoz' = r(sd)
 mkmat `ZSLS' in 1/1 , matrix(`_Xoz')
 matrix `Bx'=`Bx'[1, 1..`Jkx']'
 matrix `BsZ' =vecdiag(`Bx'*`_Xoz')'/`_Yoz'
 if "`tolog'"!="" {
 replace `yvar'=`yvarexp'
 local ZVarM "`xvarexp'"
 }
 else {
 local ZVarM "`ZVar'"
 }
 }
 if inlist("`mfx'", "lin", "log") {
 tempname mfxbox mfxb mfxb1 mfxe mfxlin mfxlog XMB XYMB YMB YMB1
 if inlist("`model'", "bcox") {
 local Lam1 = `Lam'
 summ `yvar' 
 if inlist("`lamp'", "lhs") {
 scalar `YMB1'=r(mean)^`Lam1'
 mean `ZVar'
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
noi matlist `mfxbox' , title({bf:* {err:Marginal Effect - Elasticity - Standardized Beta} {bf:(Model= {err:`ModeL'})}: {err:Linear} *}) twidth(14) border(all) lines(columns) rowtitle("`NYvar'") format(%12.4f)
 ereturn matrix mfxbox=`mfxbox'
 matrix `mfxb'=`mfxb1'
 matrix `mfxe'=`mfxe'
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
 }
 }
noi di as txt " Mean of Dependent Variable =" _col(30) %12.4f `YMB1'
 }

 restore
 if "`predict'"!= "" {
 getmata `predict' , force replace
 label variable `predict' `"Yh_`ModeL' - Prediction"'
 }
 if "`resid'"!= "" {
 getmata `resid' , force replace
 label variable `resid' `"Ue_`ModeL' - Residual"'
 }
 if "`list'"!="" {
 if "`wvar'"!="" {
 getmata _W_`wvar' , replace force
 } 
 local YXVar "`yvar' `xvar'"
 local kyx : word count `varlist'
 forvalue i=1/`kyx' {
 local xz : word `i' of `YXVar'
 getmata _Z_`xz' , replace force
 } 
 }

 cap mata: mata drop *
 cap mata: mata clear
 cap matrix drop _all
 ereturn local cmd "dlagif"
 }
 end

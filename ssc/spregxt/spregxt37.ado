 program define spregxt37 , eclass 
 version 11.2
 syntax varlist , [ idv(str) itv(str) Model(str) Run(str) be fe re dn diag reset ///
 stand NOCONStant aux(str) ehat(str) ehato(str) endog(str) exog(str) HAUSman inv inv2 ///
 LMAuto LMCl LMEc inst(str) instx(str) iter(str) lag(str) level(str) LL(str) tolog mle ///
 spar(str) tech(str) LMForm LMHet LMIden LMNorm LMSPac LMUnit NWmat(str) ORDer(str) ///
 TESTs wsxi(str) wsyi(str) wvar(str) yhat(str) yhato(str) yvarexp(str) spxv(str) tobit]

 qui {
 tempvar _Zo absE Bw D DE DF DF1 DumE DW DX_ DY_ E e E2 E3 E4 Ea Ea1 EDumE _Yw
 tempvar EE Eo Es Es1 Etd Etk Ev Ew Hat ht id it LDE LDF1 LE LEo LnE2 LYh2 P Wis
 tempvar Q SBB Sig2 SRho SSE Time tm U U2 Ue Ue_ Ue_1 Ue_MLo uiv VN wald Wi Wio
 tempvar X X0 Xb XB Yb Yh Yh_MLo Yh2 Yhat1 Yhb Yho Yho2 Yhr Yt YY Z miss _Zo
 tempname WCS A AIC B b B1 b1 B12 B1b B1B2 B1t b2 BB2 Bm BOLS Bt Bv Bv1 Bx Bx_SP
 tempname Bxx CPX D den DF Dx E E1 EE1 Eg eigw Eo Eom eVec Ew eWe eWy F FPE GCV h
 tempname Hat hjm HQ IN J K kaux kb kbm kmhet kpw  L LAIC lf llf lmhs Ls LSC M M1
 tempname M2 mh n N NE NEB NN nw Omega P Phi Pm q Q q1 q2 Qr Qrq R20 Rho Rice rim RX
 tempname RY s S11 S12 S2y SC sd Shibata Sig2 Sig2n Sig2o Sig2SP Sn SSE SSEo Sw Ue
 tempname Ue_ Ue_1 Ue_ML Ue_MLo Ue_SP v V1 v1 V1s V1V2 v2 VaL Vec vh VM VN VP VQ Vs
 tempname W W1 Wald We Wi Wi1 Wio wmat WMTD wMw WS WW wWw1 wWw2 WXb WY WZ0 X X0
 tempname xAx xAx2 XB xBx Xg xMx XQ Y Yh Yh_ML Yh_MLo Yi Z Z0 Z1 Zo zWz Yws Zws     

 gettoken yvar xvar : varlist
 if "`log'" != "" {
 local qui quietly
 }
 xtset `idv' `itv'
 local NC=r(imax)
 local NT=r(tmax)
 local N=_N
 local DF=e(DF)
 local Jkb=e(Jkb)
 local Jkx=e(Jkx)
 local kaux=e(kaux)
 local kb=e(kb)
 local kendog=e(kendog)
 local kexog=e(kexog)
 local kinst=e(kinst)
 local kinstx=e(kinstx)
 local kmhet=e(kmhet)
 local kx=e(kx)
 local llf=e(llf)
 local llt=spat_llt
 local R20=e(R20)
 local S2y=e(S2y)
 local Sig2n=e(Sig2n)
 local Sig2o=e(Sig2o)
 local SSEo=e(SSEo)
 matrix `Bx'=e(Bxx)'
 if inlist("`model'", "sarxt") {
 unab WsYi: `wsyi'
 }
 if inlist("`model'", "gs2sls", "gs2slsar") {
 unab WsYi: `wsyi'
 unab WsXi: `wsxi'
 unab exog: `exog'
 unab inst: `inst'
 unab instx: `instx'
 }
 if inlist("`model'", "sdm", "sdmxt", "mstard") {
 unab WsXi: `wsxi'
 }
 scalar `kpw'=0
 if inlist("`model'", "mstar", "mstard") {
 scalar `kpw'=`nwmat'
 }
 unab _Yo: `yvar'
 unab _Zo: `xvar'
 unab SPXvar: `spxv'
 gen `Time'=_n 
 tsset `Time'
 if "`wvar'"!="" {
 gen double `Wi' = `wvar'
 gen double `Zo' = `Wi'
 gen double `Wis' = (`Wi')^2
 local wgt "[weight = `Wis']"
 local wgts "[weight = `Wis']"
 if inlist("`model'", "sar", "sem", "sac", "sdm", "mstar", "mstard") {
 local wgt "[aweight=`Wis']"
 }
 if inlist("`run'", "xtmle", "xtfrontier") {
 local wgts " [iweight = `Wis'] "
 }
 local Yw_Zw "`_Yo' `_Zo'"
 local kXw: word count `Yw_Zw'
 forvalue i=1/`kXw' {
 local v : word `i' of `Yw_Zw'
 gen double `WLSVar'_`i' = `v'*`Wi'
 }
 unab ZWLSVar : `WLSVar'_*
 tokenize `ZWLSVar'
 local _Yw `1'
 macro shift
 local _Zw "`*'"
 }
 else { 
 unab _Yw: `yvar'
 unab _Zw: `xvar'
 gen `Zo'= 1
 gen `Wi'= 1
 gen `Wis'= 1
 local wgt ""
 local wgts ""
 }
 if "`noconstant'"!="" {
 local Zo ""
 }
 else { 
 local Zo "`Zo'"
 }

 if "`model'"!="" & "`diag'"!= "" {
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Panel Model Selection Diagnostic Criteria - Model= ({bf:{err:`model'}})}}"
noi di _dup(78) "{bf:{err:=}}"
 scalar `kbm'=`kmhet'+`kb'+`kpw'
 if "`run'"=="xtmle" | "`run'"=="xtmln" | "`run'"=="xtmlh" | "`run'"=="xtre" ///
 | "`run'"=="xtrem" | "`run'"=="xtpa" | "`run'"=="xtfe" | "`run'"=="xtfem" | "`run'"=="xttobit" {
 scalar `kbm'=`kmhet'+`kb'+3
 }
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

 if "`model'"!="" & "`lmspac'"!= "" {
 tempname B0 B1 B2 b2k B3 B4 chi21 chi22 DEN DIM E EI Ein Esp eWe Ue_ML1
 tempname I m1k m2k m3k m4k MEAN NUM NUM1 NUM2 NUM3 RJ SSESP YwSP ZwSP
 tempname S0 S1 S2 sd SEI SG0 SG1 TRa1 TRa2 trb TRw2 VI wi wj wMw wMw1
 tempname WZ0 Xk NUM Zk m2 m4 b2 M eWe1 wWw2 zWz eWy eWy1 CPX SUM DFr
 tempvar WZ0 Vm2 Vm4 Ue_ML1
 getmata `E' =Ue_SP , replace force
 matrix `WCS'= e(WCS)
 gen `X0'=1 
 mkmat `X0' , matrix(`X0')
 count
 local NN=r(N)
 mkmat `E' , matrix(`E')
 matrix `Bx_SP'=e(Bx_SP)
 matrix `YwSP'=e(YwSP)
 matrix `ZwSP'=e(ZwSP)
 scalar `Sig2SP'=e(Sig2SP)
 scalar `SSESP'=e(SSESP)
 matrix `wmat'=`WCS'#I(`NT')
 scalar `DFr'=`NN'-`kb'
 scalar `S1'=0
 forvalue i = 1/`NN' {
 forvalue j = 1/`NN' {
 scalar `S1'=`S1'+(`wmat'[`i',`j']+`wmat'[`j',`i'])^2
 local j=`j'+1
 }
 }
 matrix `zWz'=`X0''*`wmat'*`X0'
 scalar `S0'=`zWz'[1,1]
 scalar `SG0'=`S0'*2
 matrix `WZ0'=`wmat'*`X0'
 svmat double `WZ0' , name(`WZ0')
 rename `WZ0'1 `WZ0'
 replace `WZ0'=(`WZ0'+`WZ0')^2 
 summ `WZ0'
 scalar `SG1'=r(sum)
 matrix `eWe'=`E''*`wmat'*`E'
 scalar `eWe1'=`eWe'[1,1]
 matrix `CPX'=`YwSP''*`YwSP'
 matrix `A'=inv(`CPX')
 matrix `xAx'=`A'*`YwSP''*`wmat'*`YwSP'
 scalar `TRa1'=trace(`xAx')
 matrix `xAx2'=`xAx'*`xAx'
 scalar `TRa2'=trace(`xAx2')
 matrix `wWw1'=(`wmat'+`wmat'')*(`wmat'+`wmat'')
 matrix `B'=inv(`CPX')
 matrix `xBx'=`B'*`YwSP''*`wWw1'*`YwSP'
 scalar `trb'=trace(`xBx')
 scalar `VI'=(`NN'^2/(`NN'^2*`DFr'*(2+`DFr')))*((`S1'/2)+2*`TRa2'-`trb'-2*`TRa1'^2/`DFr')
 scalar `SEI'=sqrt(`VI')
 scalar `I'=(`NN'/`S0')*`eWe1'/`SSESP'
 scalar `EI'=-(`NN'*`TRa1')/(`DFr'*`NN')
 ereturn scalar mi1=(`I'-`EI')/`SEI'
 ereturn scalar mi1p=2*(1-normal(abs(e(mi1))))
 matrix `wWw2'=`wmat''*`wmat'+`wmat'*`wmat'
 scalar `TRw2'=trace(`wWw2')
 matrix `WY'=`wmat'*`YwSP'
 matrix `eWy'=`E''*`WY'
 scalar `eWy1'=`eWy'[1,1]
 matrix `WXb'=`wmat'*`YwSP'*`Bx_SP'
 matrix `IN'=I(`NN')
 matrix `M'=inv(`CPX')
 matrix `xMx'=`IN'-`YwSP'*`M'*`YwSP''
 matrix `wMw'=`WXb''*`xMx'*`WXb'
 scalar `wMw1'=`wMw'[1,1]
 scalar `RJ'=1/(`TRw2'+`wMw1'/`Sig2SP')
 ereturn scalar lmerr=((`eWe1'/`Sig2SP')^2)/`TRw2'
 ereturn scalar lmlag=((`eWy1'/`Sig2SP')^2)/(`TRw2'+`wMw1'/`Sig2SP') 
 ereturn scalar lmerrr=(`eWe1'/`Sig2SP'-`TRw2'*`RJ'*(`eWy1'/`Sig2SP'))^2/(`TRw2'-`TRw2' *`TRw2'*`RJ')
 ereturn scalar lmlagr=(`eWy1'/`Sig2SP'-`eWe1'/`Sig2SP')^2/((1/`RJ')-`TRw2')
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
 gen double `EQsq' = `E'^`j'
 summ `EQsq' , mean 
 matrix `M'[1,`j'] = r(sum)
 local j=`j'+1
 }
 summ `E' , mean
 scalar `MEAN'=r(mean)
 gen double `Ue_ML1'=`E'-`MEAN' 
 gen double `Vm2'=`Ue_ML1'^2 
 summ `Vm2' , mean
 matrix `m2'[1,1]=r(mean)	
 scalar `m2k'=r(mean)
 gen double `Vm4'=`Ue_ML1'^4
 summ `Vm4' , mean
 matrix `m4'[1,1]=r(mean)	
 scalar `m4k'=r(mean)
 matrix `b2'[1,1]=`m4k'/(`m2k'^2)
 mkmat `Ue_ML1' , matrix(`Ue_ML1')
 scalar `S0'=0
 scalar `S1'=0
 scalar `S2'=0
 local i=1
 while `i'<=`NN' {
 scalar `wi'=0
 scalar `wj'=0
 local j=1
 while `j'<=`NN' {
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
 matrix `Zk'=`Ue_ML1'[1...,1]
 matrix `Zk'=`Zk''*`wmat'*`Zk'
 scalar `Ein'=-1/(`NN'-1)
 scalar `NUM1'=`NN'*((`NN'^2-3*`NN'+3)*`S1'-(`NN'*`S2')+(3*`S0'^2))
 scalar `NUM2'=`b2k'*((`NN'^2-`NN')*`S1'-(2*`NN'*`S2')+(6*`S0'^2))
 scalar `DEN'=(`NN'-1)*(`NN'-2)*(`NN'-3)*(`S0'^2)
 scalar `sd'=sqrt((`NUM1'-`NUM2')/`DEN'-(1/(`NN'-1))^2)
 ereturn scalar mig=`Zk'[1,1]/(`S0'*`m2k') 
 ereturn scalar migz=(e(mig)-`Ein')/`sd'
 ereturn scalar migp=2*(1-normal(abs(e(migz))))
 ereturn scalar mi1z=(e(mi1)-`Ein')/`sd'
 scalar `m2k'=`m2'[1,1]
 scalar `b2k'=`b2'[1,1]
 matrix `Zk'=`Ue_ML1'[1...,1]
 scalar `SUM'=0
 local i=1
 while `i'<=`NN' {
 local j=1
 while `j'<=`NN' {
 scalar `SUM'=`SUM'+`wmat'[`i',`j']*(`Zk'[`i',1]-`Zk'[`j',1])^2
 local j=`j'+1
 }
 local i=`i'+1
 }
 scalar `NUM1'=(`NN'-1)*`S1'*(`NN'^2-3*`NN'+3-(`NN'-1)*`b2k')
 scalar `NUM2'=(1/4)*(`NN'-1)*`S2'*(`NN'^2+3*`NN'-6-(`NN'^2-`NN'+2)*`b2k')
 scalar `NUM3'=(`S0'^2)*(`NN'^2-3-((`NN'-1)^2)*`b2k')
 scalar `DEN'=(`NN')*(`NN'-2)*(`NN'-3)*(`S0'^2)
 scalar `sd'=sqrt((`NUM1'-`NUM2'+`NUM3')/`DEN')
 ereturn scalar gcg=((`NN'-1)*`SUM')/(2*`NN'*`S0'*`m2k')
 ereturn scalar gcgz=(e(gcg)-1)/`sd'
 ereturn scalar gcgp=2*(1-normal(abs(e(gcgz))))
 scalar `B0'=((`NN'^2)-3*`NN'+3)*`S1'-`NN'*`S2'+3*(`S0'^2)
 scalar `B1'=-(((`NN'^2)-`NN')*`S1'-2*`NN'*`S2'+6*(`S0'^2))
 scalar `B2'=-(2*`NN'*`S1'-(`NN'+3)*`S2'+6*(`S0'^2))
 scalar `B3'=4*(`NN'-1)*`S1'-2*(`NN'+1)*`S2'+8*(`S0'^2)
 scalar `B4'=`S1'-`S2'+(`S0'^2)
 scalar `m1k'=`M'[1,1]
 scalar `m2k'=`M'[1,2]
 scalar `m3k'=`M'[1,3]
 scalar `m4k'=`M'[1,4]
 matrix `Xk'=`Ue_ML1'[1...,1]
 matrix `NUM'=`Xk''*`wmat'*`Xk'
 scalar `DEN'=0
 local i=1
 while `i'<=`NN' {
 local j=1
 while `j'<=`NN' {
 if `i'!=`j' {
 scalar `DEN'=`DEN'+`Xk'[`i',1]*`Xk'[`j',1]
 }
 local j=`j'+1
 }
 local i=`i'+1
 }
 ereturn scalar gog=`NUM'[1,1]/`DEN'
 scalar `Esp'=`S0'/(`NN'*(`NN'-1))
 scalar `NUM'=(`B0'*`m2k'^2)+(`B1'*`m4k')+(`B2'*`m1k'^2*`m2k') ///
 +(`B3'*`m1k'*`m3k')+(`B4'*`m1k'^4)
 scalar `DEN'=(((`m1k'^2)-`m2k')^2)*`NN'*(`NN'-1)*(`NN'-2)*(`NN'-3)
 scalar `sd'=(`NUM'/`DEN')-((`Esp')^2)
 ereturn scalar gogz=(e(gog)-`Esp')/sqrt(`sd')
 ereturn scalar gogp=2*(1-normal(abs(e(gogz))))
 scalar `chi21'=invchi2(1,0.95)
 scalar `chi22'=invchi2(2,0.95)
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:*** Spatial Panel Aautocorrelation Tests - Model= ({bf:{err:`model'}})}}"
 if "`stand'"!="" {
noi di as txt "{bf:*** Standardized Weight Matrix (W): (Normalized)}"
 if "`inv'"!="" {
noi di as txt "*** Inverse Standardized Weight Matrix (1/W)"
 }
 if "`inv2'"!="" {
noi di as txt "*** Inverse Squared Standardized Weight Matrix (1/W^2)"
 }
 }
 else {
noi di as txt "{bf:*** Binary (0/1) Weight Matrix (W): (Non Normalized)}"
 }
noi di _dup(78) "{bf:{err:=}}"
noi di as txt _col(2) "{bf: Ho: Error has No Spatial AutoCorrelation}"
noi di as txt _col(2) "{bf: Ha: Error has    Spatial AutoCorrelation}"
noi di
noi di as txt "- GLOBAL Moran MI" _col(30) "=" %9.4f e(mig) _col(45) "P-Value > Z(" %6.3f e(migz) ")" _col(67) %5.4f e(migp)
noi di as txt "- GLOBAL Geary GC" _col(30) "=" %9.4f e(gcg) _col(45) "P-Value > Z(" %5.3f e(gcgz) ")" _col(67) %5.4f e(gcgp)
noi di as txt "- GLOBAL Getis-Ords GO" _col(30) "=" %9.4f e(gog) as txt _col(45) "P-Value > Z(" %5.3f e(gogz) ")" _col(67) %5.4f e(gogp)
noi di _dup(78) "-"
noi di as txt "- Moran MI Error Test" _col(30) "=" %9.4f e(mi1) _col(45) "P-Value > Z(" %5.3f e(mi1z) ")" _col(67) %5.4f e(mi1p)
noi di _dup(78) "-"
noi di as txt "- LM Error (Burridge)" _col(30) "=" %9.4f e(lmerr) _col(45) "P-Value > Chi2(1)" _col(67) %5.4f e(lmerrp)
noi di as txt "- LM Error (Robust)" _col(30) "=" %9.4f e(lmerrr) _col(45) "P-Value > Chi2(1)" _col(67) %5.4f e(lmerrrp)
noi di _dup(78) "-"
noi di as txt _col(2) "{bf: Ho: Spatial Lagged Dependent Variable has No Spatial AutoCorrelation}"
noi di as txt _col(2) "{bf: Ha: Spatial Lagged Dependent Variable has    Spatial AutoCorrelation}"
noi di
noi di as txt "- LM Lag (Anselin)" _col(30) "=" %9.4f e(lmlag) _col(45) "P-Value > Chi2(1)" _col(67) %5.4f e(lmlagp)
noi di as txt "- LM Lag (Robust)" _col(30) "=" %9.4f e(lmlagr) _col(45) "P-Value > Chi2(1)" _col(67) %5.4f e(lmlagrp)
noi di _dup(78) "-"
noi di as txt _col(2) "{bf: Ho: No General Spatial AutoCorrelation}"
noi di as txt _col(2) "{bf: Ha:    General Spatial AutoCorrelation}"
noi di
noi di as txt "- LM SAC (LMErr+LMLag_R)" _col(30) "=" %9.4f e(lmsac2) _col(45) "P-Value > Chi2(2)" _col(67) %5.4f e(lmsac2p)
noi di as txt "- LM SAC (LMLag+LMErr_R)" _col(30) "=" %9.4f e(lmsac1) _col(45) "P-Value > Chi2(2)" _col(67) %5.4f e(lmsac1p)
noi di _dup(78) "-"
 }

 if "`model'"!="" & "`lmunit'"!= "" {
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:*** Panel Unit Roots Tests - Model= ({bf:{err:`model'}})}}"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt _col(2) "{bf: Ho: All Panels are Stationary - Ha: Some Panels Have Unit Roots}"
noi di
 mata: `YwSP' = st_matrix("`YwSP'")
 getmata `YwSP' , replace force
 getmata `idv' =idv, replace force
 getmata `itv' =itv, replace force 
 xtset `idv' `itv'
 xtunitroot hadri `YwSP' 
 ereturn scalar lmu1=r(z)
 ereturn scalar lmu1p=r(p)
noi di as txt "- Hadri Z Test (No Trend - No Robust)" _col(39) "=" %9.4f e(lmu1) _col(52) "P-Value > Z(0,1)" _col(71) %5.4f e(lmu1p)
 xtunitroot hadri `YwSP' , robust
 ereturn scalar lmu2=r(z)
 ereturn scalar lmu2p=r(p)
noi di as txt "- Hadri Z Test (No Trend -    Robust)" _col(39) "=" %9.4f e(lmu2) _col(52) "P-Value > Z(0,1)" _col(71) %5.4f e(lmu2p)
 xtunitroot hadri `YwSP' , trend
 ereturn scalar lmu3=r(z)
 ereturn scalar lmu3p=r(p)
noi di as txt "- Hadri Z Test (   Trend - No Robust)" _col(39) "=" %9.4f e(lmu3) _col(52) "P-Value > Z(0,1)" _col(71) %5.4f e(lmu3p)
 xtunitroot hadri `YwSP' , trend robust
 ereturn scalar lmu4=r(z)
 ereturn scalar lmu4p=r(p)
noi di as txt "- Hadri Z Test (   Trend -    Robust)" _col(39) "=" %9.4f e(lmu4) _col(52) "P-Value > Z(0,1)" _col(71) %5.4f e(lmu4p)
noi di _dup(78) "-"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:* (1)  (DF):           Dickey-Fuller   Test}"
noi di as txt "{bf:* (2) (ADF): Augmented Dickey-Fuller   Test}"
noi di as txt "{bf:* (3) (APP): Augmented Phillips-Perron Test}"
noi di _dup(50) "{bf:-}"
noi di as txt _col(2) "{bf: Ho: All Panels Have Unit Roots  (Non stationary)}"
noi di as txt _col(2) "{bf: Ha: At Least One Panel is Stationary}"
noi di _dup(78) "-"
noi di as txt _col(3) "{bf:Ho: Non Stationary [0.05, 0.01 {err:<} P-Value]}"
noi di as txt _col(3) "{bf:Ha:     Stationary [0.05, 0.01 {err:>} P-Value]}"
noi di _dup(78) "{bf:{err:-}}"
noi di as txt "{bf:*** (1) Dickey-Fuller (DF) Test:}"
noi di _dup(50) "{bf:-}"
 xtset `idv' `itv'
 xtunitroot fisher `YwSP' , lag(0) dfuller
 ereturn scalar lmudf1=r(Z)
 ereturn scalar lmudf1p=r(p_Z)
noi di as txt "-  DF Test: [Lag = 0] (No Trend)" _col(35) "=" %9.4f e(lmudf1) _col(50) "P-Value > Z(0,1)" _col(70) %5.4f e(lmudf1p)
 if r(Z) != . {
noi LMUtest `YwSP' , level(`level') depname("`_Yo'")
 }
 xtunitroot fisher `YwSP' , lag(0) dfuller trend
 ereturn scalar lmudf2=r(Z)
 ereturn scalar lmudf2p=r(p_Z)
noi di as txt "-  DF Test: [Lag = 0] (   Trend)" _col(35) "=" %9.4f e(lmudf2) _col(50) "P-Value > Z(0,1)" _col(70) %5.4f e(lmudf2p)
 if r(Z) != . {
noi LMUtest `YwSP' , level(`level') depname("`_Yo'")
 }
noi di
noi di _dup(78) "{bf:{err:-}}"
noi di as txt "{bf:*** (2) Augmented Dickey-Fuller (ADF) Test:}"
noi di _dup(50) "{bf:-}"
 forvalue i=1/`lag' {
 xtunitroot fisher `YwSP' , lag(`i') dfuller
 ereturn scalar lmudf3=r(Z)
 ereturn scalar lmudf3p=r(p_Z)
noi di as txt "- ADF Test: [Lag = `i'] (No Trend)" _col(35) "=" %9.4f e(lmudf3) _col(50) "P-Value > Z(0,1)" _col(70) %5.4f e(lmudf3p)
 if r(Z) != . {
noi LMUtest `YwSP' , level(`level') depname("`_Yo'")
 }
 xtunitroot fisher `YwSP' , lag(`i') dfuller trend
 ereturn scalar lmudf4=r(Z)
 ereturn scalar lmudf4p=r(p_Z)
noi di as txt "- ADF Test: [Lag = `i'] (   Trend)" _col(35) "=" %9.4f e(lmudf4) _col(50) "P-Value > Z(0,1)" _col(70) %5.4f e(lmudf4p)
 if r(Z) != . {
noi LMUtest `YwSP' , level(`level') depname("`_Yo'")
 }
 }
noi di
noi di _dup(78) "{bf:{err:-}}"
noi di as txt "{bf:*** (3) Augmented Phillips-Perron (APP) Test:}"
noi di _dup(50) "{bf:-}"
 forvalue i=1/`lag' {
 xtunitroot fisher `YwSP' , lag(`i') pperron
 ereturn scalar lmupp1=r(Z)
 ereturn scalar lmupp1p=r(p_Z)
noi di as txt "- APP Test: [Lag = `i'] (No Trend)" _col(35) "=" %9.4f e(lmupp1) _col(50) "P-Value > Z(0,1)" _col(70) %5.4f e(lmupp1p)
 if r(Z) != . {
noi LMUtest `YwSP' , level(`level') depname("`_Yo'")
 }
 xtunitroot fisher `YwSP' ,lag(`i') pperron trend
 ereturn scalar lmupp2=r(Z)
 ereturn scalar lmupp2p=r(p_Z)
noi di as txt "- APP Test: [Lag = `i'] (   Trend)" _col(35) "=" %9.4f e(lmupp2) _col(50) "P-Value > Z(0,1)" _col(70) %5.4f e(lmupp2p)
 if r(Z) != . {
noi LMUtest `YwSP' , level(`level') depname("`_Yo'")
 }
 }
 }

 mkmat `_Yo' , matrix(`Y')
 mkmat `_Zo' `Zo' , matrix(`Z')
 mkmat `_Yw' , matrix(`Yws')
 mkmat `_Zw' `Zo' , matrix(`Zws')
 gen double `Yh_ML' = `yhat'
 gen double `Ue_ML' = `ehat'
 gen double `Yh_MLo' = `yhato'
 gen double `Ue_MLo' = `ehato'
 if inlist("`run'", "xtdhp", "xtabond", "xtdpdsys") {
 mark `miss'
 if inlist("`run'", "xtdhp") {
 markout `miss' `idv' `itv' `_Yo' `_Zo' `Yh_ML' `Ue_ML' `Yh_MLo' `Ue_MLo' `Wi' `Zo' `SPXvar'
 }
 if inlist("`run'", "xtabond", "xtdpdsys") {
 markout `miss' `idv' `itv' `_Yo' `_Zo' `Yh_ML' `Ue_ML' `Yh_MLo' `Ue_MLo' `Wi' `Zo' `SPXvar' `inst'
 }
 keep if `miss' == 1
 egen `id' = group(`idv')
 egen `it' = group(`itv')
 replace `idv' = `id'
 replace `itv' = `it'
 xtset `idv' `itv'
 local NC=r(imax)
 local NT=r(tmax)
 local N=_N
 }
 mkmat `Yh_ML' , matrix(`Yh_ML')
 mkmat `Ue_ML' , matrix(`Ue_ML')
 mkmat `Yh_MLo' , matrix(`Yh_MLo')
 mkmat `Ue_MLo' , matrix(`Ue_MLo')
 mkmat `Wi' , matrix(`Wi')
 matrix `Wi'= diag(`Wi')

 if "`model'"!="" & "`lmec'"!= "" {
 tempvar  U E Ms SumE E1 Em Ti U1 Uu Elmec Time
 tempname U E Ms SumE E1 Em Ti U1 Uu
 gen `Time'=_n
 tsset `Time'
 regress `_Yo' `_Zo' `wgt' , `noconstant'
 predict double `Elmec' , res
 mkmat `Elmec' , matrix(`E')
 xtset `idv' `itv'
 by `idv': gen double `SumE' = cond(_n==_N,sum(`Elmec')^2,.) 
 replace `SumE' = sum(`SumE') 
 tempname A1 SD SD1 B1 T2
 scalar `A1' = `SumE'[_N]
 replace `SumE' = sum(`Elmec'^2) 
 scalar `SD' = `SumE'[_N]
 scalar `A1' = 1-(`A1'/`SD')
 by `idv': gen double `U1' = L.`Elmec' 
 by `idv': gen double `Em' = `Elmec' 
 by `idv': replace `Em' = . if _n==1
 replace `SumE' = sum(`Em'^2) 
 scalar `SD1' = `SumE'[_N]
 replace `SumE' = sum(`Elmec'*`U1') 
 scalar `B1' = `SumE'[_N]/`SD1'
 scalar `T2' = `NT'*`NT'*`NC'
 ereturn scalar lmec1=((0.5*`N'^2*`A1'^2)/(`T2'-`N'))
 ereturn scalar lmec2=(`N'^2*(`A1'+2*`B1')^2/(2*(`T2'-3*`N'+2*`NC')))
 ereturn scalar lmec3=(-sqrt((0.5*`N'^2)/(`T2'-`N'))* `A1')
 ereturn scalar lmec4=(-sqrt(`N'^2/(2*(`T2'-3*`N'+2*`NC')))*(`A1'+2*`B1'))
 ereturn scalar lmec5=(`N'^2 * `B1'^2/(`N'-`NC'))
 ereturn scalar lmec6=(e(lmec5)-e(lmec1)+e(lmec2))
 ereturn scalar lmec7=(e(lmec1)+e(lmec6))
 ereturn scalar lmec1p=chi2tail(1 , abs(e(lmec1)))
 ereturn scalar lmec2p=chi2tail(1 , abs(e(lmec2)))
 ereturn scalar lmec3p=chi2tail(1 , abs(e(lmec3)))
 ereturn scalar lmec4p=chi2tail(1 , abs(e(lmec4)))
 ereturn scalar lmec5p=chi2tail(1 , abs(e(lmec5)))
 ereturn scalar lmec6p=chi2tail(1 , abs(e(lmec6)))
 ereturn scalar lmec7p=chi2tail(2 , abs(e(lmec7)))
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:*** Panel Error Component Tests - Model= ({bf:{err:`model'}})}}"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Panel Random Effects Tests}}"
noi di as txt _col(3) "{bf:Ho: No AR(1) Autocorrelation - Ha: AR(1) Autocorrelation}"
noi di as txt _col(3) "{bf:Ho: Pooled OLS    - No Significance Difference among Panels}"
noi di as txt _col(3) "{bf:Ha: Random Effect -    Significance Difference among Panels}"
noi di
noi di as txt "- Breusch-Pagan  LM Test -Two Side" _col(41) "=" %9.4f e(lmec1) _col(52) " P-Value > Chi2(1)" _col(73) %5.4f e(lmec1p)
noi di as txt "- Breusch-Pagan ALM Test -Two Side" _col(41) "=" %9.4f e(lmec2) _col(52) " P-Value > Chi2(1)" _col(73) %5.4f e(lmec2p)
noi di _dup(78) "-"
noi di as txt "- Sosa-Escudero-Yoon  LM Test -One Side" _col(41) "=" %9.4f e(lmec3) _col(52) " P-Value > Chi2(1)" _col(73) %5.4f e(lmec3p)
noi di as txt "- Sosa-Escudero-Yoon ALM Test -One Side" _col(41) "=" %9.4f e(lmec4) _col(52) " P-Value > Chi2(1)" _col(73) %5.4f e(lmec4p)
noi di _dup(78) "-"
noi di as txt "- Baltagi-Li  LM Autocorrelation Test" _col(41) "=" %9.4f e(lmec5) _col(52) " P-Value > Chi2(1)" _col(73) %5.4f e(lmec5p)
noi di as txt "- Baltagi-Li ALM Autocorrelation Test" _col(41) "=" %9.4f e(lmec6) _col(52) " P-Value > Chi2(1)" _col(73) %5.4f e(lmec6p)
noi di _dup(78) "-"
noi di as txt "- Baltagi-Li LM AR(1) Joint Test" _col(41) "=" %9.4f e(lmec7) _col(52) " P-Value > Chi2(2)" _col(73) %5.4f e(lmec7p)
noi di _dup(78) "-"

 if "`model'"!="" & !inlist("`run'", "xtdhp", "xtabond", "xtdpdsys") {
 tempvar  U LMCov E Ms E1 Em Ti U1 Uu Time
 tempname U LMCov E Ms E1 Em Ti U1 Uu
 local idv `idv'
 cap drop `Time'
 gen `Time'=_n
 tsset `Time'
 mkmat `Ue_ML' , matrix(`E')
 levelsof `idv' , local(levels)
 foreach i of local levels {
 summ `Time' if `idv' == `i'
 tempname min max M
 scalar `min'=r(min)
 scalar `max'=r(max)
 matrix `E'`i'=`E'[`min'..`max', 1..1]
 svmat double `E'`i' , name(`E'`i')
 svmat double `E'`i' , name(`Uu'`i')
 }
 levelsof `idv' , local(levels)
 foreach i of local levels {
 foreach j of local levels {
 gen double `U'`i'`j' = `E'`i'*`E'`j' 
 summ `U'`i'`j' 
 tempname s`i'`j'
 scalar `s`i'`j''=r(sum)
 }
 }
 scalar `M'=0
 gen `Ms'=0 
 levelsof `idv' , local(levels)
 foreach i of local levels {
 foreach j of local levels {
 replace `Ms'=`s`i'`j''^2/(`s`i'`i''*`s`j'`j'')
 summ `Ms' if `i' < `j'
 tempname M`i'`j'
 scalar `M`i'`j''=`M'+ r(mean)
 gen double `LMCov'`i'`j'=`M`i'`j'' 
 }
 }
 egen double `LMCov'=rowtotal(`LMCov'*) in 1/1
 ereturn scalar lmec8=`LMCov'*`NT'
 local ChiDF = `NC'*(`NC'-1)/2
 ereturn scalar lmec8p = chi2tail(`ChiDF', abs(e(lmec8)))
 tempname CCp cor cov TCCp
 matrix accum `cov' = `Uu'* , noconstant dev
 matrix `cor' = corr(`cov')
 matrix `CCp' = `cor' * `cor''
 scalar `TCCp' =trace(`CCp')
 ereturn scalar lmec9 = (`TCCp'-`NC')*`NT'/2
 ereturn scalar lmec9p = chi2tail(`ChiDF', abs(e(lmec9)))
noi di
noi di as txt "{bf:{err:* Contemporaneous Correlations Across Cross Sctions Test}}"
noi di as txt _col(3) "{bf:Ho: No Contemporaneous Correlations (Independence) - (Pooled OLS)}"
noi di as txt _col(3) "{bf:Ha:    Contemporaneous Correlations (Dependence)   - (Panel)}"
noi di
noi di as txt "- Breusch-Pagan Diagonal Covariance Matrix LM Test" _col(41) "=" %9.4f e(lmec8) _col(52) " P>Chi2(" `ChiDF' ")" _col(73) %5.4f e(lmec8p)
noi di as txt "- Breusch-Pagan Cross-Section Independence LM Test" _col(41) "=" %9.4f e(lmec9) _col(52) " P>Chi2(" `ChiDF' ")" _col(73) %5.4f e(lmec9p)
noi di _dup(78) "-"
noi di as txt _col(5) "LM= Lagrange Multiplier ; ALM = Adjusted Lagrange Multiplier"
noi di _dup(78) "-"
 }
 }

 if "`model'"!="" & "`lmauto'"!="" {
 tsset `Time'
 tempvar UD
 regress d.(`_Yo') d.(`_Zo') , noconstant cluster(`idv')
 predict double `UD' , res
 regress `UD' L.`UD' , noconstant cluster(`idv')
 test L.`UD'
 tempname lmawold1 lmawold1p lmawold2 lmawold2p woldf1 woldf2
 tempname Rho Rhosq Rw1 Rw2 lmadw lmavon lmaz lmazp lmabp lmabpp lmabpgk1 lmabpgk1p
 tempname lmabpgd lmabpgdp lmabgd lmabgdp lmadmd lmadmdp dmdf1 dmdf2 lmabpgk lmabpgkp
 tempname lmabgk lmabgkp lmadmk lmadmkp dmkf1 dmkf2 Po lmadh lmadhp lmahh lmahhp
 tempname SSEu SSE SSE1 lmab1 lmab1p lmab2 lmab2p
 tempname B id EE1 SSE SSE1 Ro1 Ro2 EE1 En Obs E E2 Sig2
 scalar `lmawold1'=e(N)*e(r2)
 scalar `lmawold1p'=chi2tail(1, abs(`lmawold1'))
 scalar `lmawold2'= r(F)
 scalar `lmawold2p'= r(p)
 scalar `woldf1'= r(df)
 scalar `woldf2'= r(df_r)
 tsset `Time'
 gen double `Yh'=`Yh_MLo'
 gen double `E' =`Ue_MLo'
 mkmat `E' , matrix(`E')
 gen double `E1'=L1.`E' 
 replace `E1' = 0 in 1
 local icc `idv'
 local i=`idv'+1 
 levelsof `icc' , local(levels)
 foreach i of local levels {
 tempname EA`i' EAL`i' 
 tempvar SSR1 SSR2 SSW1 SSW2 EA`i' EAL`i' ELd1 ELk1
 mkmat `E' if `icc'==`i' , matrix(`EA`i'')
 svmat double `EA`i'' , name(`EA`i'')
 rename `EA`i''1 `EA`i''
 gen double `EAL`i'' =L.`EA`i'' 
 }
 forvalue i = 1/`NC' {
 tempvar SSR1`i' SSR2`i' SSW1`i' SSW2`i'
 gen double `SSR1'`i'=`EAL`i''*`EA`i'' 
 replace `SSR1'`i'=0 in 1
 gen double `SSR2'`i'=`EAL`i''^2 
 replace `SSR2'`i'=0 in 1
 gen double `SSW1'`i'=(`EA`i''-`EAL`i'')^2 
 replace `SSW1'`i'=0 in 1
 gen double `SSW2'`i'=`EA`i''^2 
 gen double `ELd1'`i'=`EAL`i'' 
 gen double `ELk1'`i'=`EAL`i'' 
 replace `ELk1'`i'=0 in 1
 }
 tempvar Rov1 Rov2 Rwv1 Rwv2
 egen double `Rov1' = rowtotal(`SSR1'*) 
 summ `Rov1' 
 scalar `Ro1'=r(sum)
 egen double `Rov2' = rowtotal(`SSR2'*) 
 summ `Rov2' 
 scalar `Ro2'=r(sum)
 scalar `Rho' = `Ro1'/`Ro2'
 scalar `Rhosq' = `Ro1'^2/`Ro2'^2
 egen double `Rwv1' = rowtotal(`SSW1'*) 
 summ `Rwv1' 
 scalar `Rw1'=r(sum)
 egen double `Rwv2' = rowtotal(`SSW2'*) 
 summ `Rwv2' 
 scalar `Rw2'=r(sum)
 scalar `lmadw' =`Rw1'/`Rw2'
 scalar `lmavon'=`lmadw'*`N'/(`N'-1)
 scalar `lmaz'=`Rho'*sqrt(`N')
 scalar `lmazp'=2*(1-normal(abs(`lmaz')))
 scalar `lmabp'=`N'*`Rhosq'
 scalar `lmabpp'=chi2tail(1, abs(`lmabp'))
 tempname Etd Etk
 mkmat `ELd1'* in 1/`NT' , matrix(`Etd')
 mkmat `ELk1'* in 1/`NT' , matrix(`Etk')
 matrix `Etd' = vec(`Etd')
 matrix `Etk' = vec(`Etk')
 svmat double `Etd' , name(`Etd')
 svmat double `Etk' , name(`Etk')
 rename `Etd'1 `Etd'
 rename `Etk'1 `Etk'
 regress `E' `E1' `_Zo' , `noconstant'
 scalar `lmabpgk1'=sqrt(e(N)*e(r2))
 scalar `lmabpgk1p'=2*(1-normal(abs(`lmabpgk1')))
 regress `E' `Etd' `_Zo' , `noconstant'
 scalar `lmabpgd'=sqrt(e(N)*e(r2))
 scalar `lmabpgdp'=2*(1-normal(abs(`lmabpgd')))
 scalar `lmabgd'=e(N)*e(r2)
 scalar `lmabgdp'=chi2tail(1, abs(`lmabgd'))
 testparm `Etd'
 scalar `lmadmd'=r(F)
 scalar `lmadmdp' =r(p)
 scalar `dmdf1' =r(df)
 scalar `dmdf2' =r(df_r)
 regress `E' `Etk' `_Zo' , `noconstant'
 scalar `lmabpgk'=sqrt(e(N)*e(r2))
 scalar `lmabpgkp'=2*(1-normal(abs(`lmabpgk')))
 scalar `lmabgk'=e(N)*e(r2)
 scalar `lmabgkp'=chi2tail(1, abs(`lmabgk'))
 testparm `Etk'
 scalar `lmadmk'=r(F)
 scalar `lmadmkp'=r(p)
 scalar `dmkf1'=r(df)
 scalar `dmkf2'=r(df_r)
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:*** Panel Serial Autocorrelation Tests - Model= ({bf:{err:`model'}})}}"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt _col(2) "{bf: Ho: No AR(1) Panel AutoCorrelation - Ha: AR(1) Panel AutoCorrelation}"
noi di
 matrix `SSE'=`E''*`E'
 matrix `Sig2'=`SSE'/`DF'
 local Sig=sqrt(`Sig2'[1,1])
 replace `E1' =L1.`E' 
 regress `E' `E1' , noconstant
 scalar `Po'= _b[`E1']
 scalar `lmadh'=`Po'*sqrt(`N'/(1-`N'*`S2y'))
 scalar `lmadhp'= 2*(1-normal(abs(`lmadh')))
 scalar `lmahh'=`Po'^2*(`N'/(1-`N'*`S2y'))
 scalar `lmahhp'= chi2tail(1, abs(`lmahh'))
 if `lmadh' ==. {
noi di as txt "- Durbin  h Panel Test cannot be computed"
 }
 if `lmadh' != . {
noi di as txt "- Durbin  h Test (Lag DepVar)" _col(43) "=" %9.4f `lmadh' _col(55) "P-Value > Z(0,1)" _col(73) %5.4f `lmadhp'
 } 
 if `lmahh' > 0 {
noi di as txt "- Harvey LM Test (Lag DepVar)" _col(43) "=" %9.4f `lmahh' _col(55) "P-Value > Chi2(1)" _col(73) %5.4f `lmahhp'
 }
noi di _dup(78) "-"
noi di as txt "- Panel Rho Value" _col(43) "=" %9.4f `Rho'
noi di as txt "- Durbin-Watson Test" _col(43) "=" %9.4f `lmadw' _col(55) "df: ("  `kb'  " , " `N' ")
noi di as txt "- Von Neumann Ratio Test" _col(43) "=" %9.4f `lmavon' _col(55) "df: ("  `kb'  " , " `N' ")
noi di as txt "- Box-Pierce LM Test" _col(43) "=" %9.4f `lmabp' _col(55) "P-Value > Chi2(1)" _col(73) %5.4f `lmabpp'
noi di as txt "- Z Test" _col(43) "=" %9.4f `lmaz' _col(55) "P-Value > Z(0,1)" _col(73) %5.4f `lmazp'
noi di _dup(78) "-"
noi di as txt "- Durbin m Test (drop 1 cs obs)" _col(43) "=" %9.4f `lmadmd' _col(55) "P-Value > F(" `dmdf1' "," `dmdf2' ")" _col(73) %5.4f `lmadmdp'
noi di as txt "- Durbin m Test (keep 1 cs obs)" _col(43) "=" %9.4f `lmadmk' _col(55) "P-Value > F(" `dmkf1' "," `dmkf2' ")" _col(73) %5.4f `lmadmkp'
noi di _dup(78) "-"
noi di as txt "- Breusch-Godfrey LM Test (drop 1 cs obs)" _col(43) "=" %9.4f `lmabgd' _col(55) "P-Value > Chi2(1)" _col(73) %5.4f `lmabgdp'
noi di as txt "- Breusch-Godfrey LM Test (keep 1 cs obs)" _col(43) "=" %9.4f `lmabgk' _col(55) "P-Value > Chi2(1)" _col(73) %5.4f `lmabgkp'
noi di _dup(78) "-"
noi di as txt "- Breusch-Pagan-Godfrey Z (keep 1 nt obs)" _col(43) "=" %9.4f `lmabpgk1' _col(55) "P-Value > Z(0,1)" _col(73) %5.4f `lmabpgk1p'
noi di as txt "- Breusch-Pagan-Godfrey Z (drop 1 cs obs)" _col(43) "=" %9.4f `lmabpgd' _col(55) "P-Value > Z(0,1)" _col(73) %5.4f `lmabpgdp'
noi di as txt "- Breusch-Pagan-Godfrey Z (keep 1 cs obs)" _col(43) "=" %9.4f `lmabpgk' _col(55) "P-Value > Z(0,1)" _col(73) %5.4f `lmabpgkp'
noi di _dup(78) "-"
 tempvar EE EE1 SSE SSE11
 tempname SSEu SSEo
 tsset `Time'
 scalar `SSEu'=e(rss)
 local idv `idv'
 sort `idv' `ivt'
 gen double `EE'=`E'*`E' 
 gen double `SSE'=sum(`EE') 
 scalar `SSEo'=`SSE'[_N]
 gen double `EE1'=`E'*`E'[_n-1] if `idv'==`idv'[_n-1]
 gen double `SSE1'=sum(`EE1') 
 scalar `SSE11'=`SSE1'[_N]
 scalar `lmab1'=`NC'*`NT'*(`NT'/(`NT'-1))*((`SSE11'/`SSEo')^2)
 scalar `lmab1p'=chi2tail(1, abs(`lmab1'))
 scalar `lmab2'=sqrt(`lmab1')
 scalar `lmab2p'=2*(1-normal(abs(`lmab2')))
noi di as txt "- Baltagi LM Test" _col(43) "=" %9.4f `lmab1' _col(55) "P-Value > Chi2(1)" _col(73) %5.4f `lmab1p'
noi di as txt "- Baltagi  Z Test" _col(43) "=" %9.4f `lmab2' _col(55) "P-Value > Z(0,1)" _col(73) %5.4f `lmab2p'
noi di _dup(78) "-"
noi di as txt "- Wooldridge  F Test" _col(43) "=" %9.4f `lmawold2' _col(55) "P-Value > F(" `woldf1' ", " `woldf2' ")" _col(73) %5.4f `lmawold2p'
noi di as txt "- Wooldridge LM Test" _col(43) "=" %9.4f `lmawold1' _col(55) "P-Value > Chi2(1)" _col(73) %5.4f `lmawold1p'
noi di _dup(78) "-"
 ereturn scalar lmadh=`lmadh'
 ereturn scalar lmadhp=`lmadhp'
 ereturn scalar lmahh=`lmahh'
 ereturn scalar lmahhp=`lmahhp'
 ereturn scalar rho=`Rho'
 ereturn scalar lmadw=`lmadw'
 ereturn scalar lmavon=`lmavon'
 ereturn scalar lmabp=`lmabp'
 ereturn scalar lmabpp=`lmabpp'
 ereturn scalar lmaz=`lmaz'
 ereturn scalar lmazp=`lmazp'
 ereturn scalar lmabpgk1=`lmabpgk1'
 ereturn scalar lmabpgk1p=`lmabpgk1p'
 ereturn scalar lmadmd=`lmadmd'
 ereturn scalar lmadmdp=`lmadmdp'
 ereturn scalar lmabpgd=`lmabpgd'
 ereturn scalar lmabpgdp=`lmabpgdp'
 ereturn scalar lmabgd=`lmabgd'
 ereturn scalar lmabgdp=`lmabgdp'
 ereturn scalar lmadmk=`lmadmk'
 ereturn scalar lmadmkp=`lmadmkp'
 ereturn scalar lmabpgk=`lmabpgk'
 ereturn scalar lmabpgkp=`lmabpgkp'
 ereturn scalar lmabgk=`lmabgk'
 ereturn scalar lmabgkp=`lmabgkp'
 ereturn scalar lmab1=`lmab1'
 ereturn scalar lmab1p=`lmab1p'
 ereturn scalar lmab2=`lmab2'
 ereturn scalar lmab2p=`lmab2p'
 ereturn scalar lmawold1=`lmawold1'
 ereturn scalar lmawold1p=`lmawold1p'
 ereturn scalar lmawold2=`lmawold2'
 ereturn scalar lmawold2p=`lmawold2p'
 }

 if "`model'"!="" & "`lmhet'"!= "" {
 tempvar Yh Yh2 LYh2 E E2 E3 E4 LnE2 absE time LE ht DumE EDumE U2
 tempname mh vh h Q LMh_cwx lmhmss1 mssdf1 lmhmss1p 
 tempname lmhmss2 mssdf2 lmhmss2p dfw0 lmhw01 lmhw01p lmhw02 lmhw02p dfw1 lmhw11
 tempname lmhw11p lmhw12 lmhw12p dfw2 lmhw21 lmhw21p lmhw22 lmhw22p lmhharv
 tempname lmhharvp lmhwald lmhwaldp lmhhp1 lmhhp1p lmhhp2 lmhhp2p lmhhp3 lmhhp3p lmhgl
 tempname lmhglp lmhcw1 cwdf1 lmhcw1p lmhcw2 cwdf2 lmhcw2p lmhq lmhqp
 tsset `Time'
 gen double `Yh'=`Yh_MLo'
 gen double `E' =`Ue_MLo'
 mkmat `E' , matrix(`E')
 matrix `SSE'=`E''*`E'
 gen double `U2' =`E'^2/`Sig2n'
 gen double `Yh2'=`Yh'^2
 gen double `LYh2'=ln(`Yh2')
 gen double `E2'=`E'^2
 gen double `E3'=`E'^3
 gen double `E4'=`E'^4
 gen double `LnE2'=log(`E2') 
 gen double `absE'=abs(`E') 
 gen `DumE'=0 
 replace `DumE'=1 if `E' >= 0
 summ `DumE' 
 gen double `EDumE'=`E'*(`DumE'-r(mean)) 
 regress `EDumE' `Yh' `Yh2' `wgt'
 scalar `lmhmss1'=e(N)*e(r2)
 scalar `mssdf1'=e(df_m)
 scalar `lmhmss1p'=chi2tail(`mssdf1', abs(`lmhmss1'))
 regress `EDumE' `_Zo' , `noconstant' 
 scalar `lmhmss2'=e(N)*e(r2)
 scalar `mssdf2'=e(df_m)
 scalar `lmhmss2p'=chi2tail(`mssdf2', abs(`lmhmss2'))
 forvalue i=1/`kx' {
 local v: word `i' of `_Zo'
 gen double `XQ'`i'`i' = `v'*`v' 
 }
 regress `E2' `_Zo' , `noconstant'
 scalar `dfw0'=e(df_m)
 scalar `lmhw01'=e(r2)*e(N)
 scalar `lmhw01p'=chi2tail(`dfw0' , abs(`lmhw01'))
 scalar `lmhw02'=e(mss)/(2*`Sig2n'^2)
 scalar `lmhw02p'=chi2tail(`dfw0' , abs(`lmhw02'))
 unab _ZoXQ: `_Zo' `XQ'*
 local k_ZoXQ1 : word count `_ZoXQ'
 local k_ZoXQ1 = `k_ZoXQ1'+1
 if `k_ZoXQ1' < `N' {
 regress `E2' `_ZoXQ' , `noconstant'
 scalar `dfw1'=e(df_m)
 scalar `lmhw11'=e(r2)*e(N)
 scalar `lmhw11p'=chi2tail(`dfw1' , abs(`lmhw11'))
 scalar `lmhw12'=e(mss)/(2*`Sig2n'^2)
 scalar `lmhw12p'=chi2tail(`dfw1' , abs(`lmhw12'))
 }
 cap drop `XQ'*
 local i=1
 while `i'<=`kx' {
 local vi: word `i' of `_Zo'
 local j=1
 while `j'<=`kx' {
 local vj: word `j' of `_Zo'
 if `i' <= `j' {
 gen double `XQ'`i'`j' = `vi'*`vj' 
 }
 local j=`j'+1
 }
 local i=`i'+1
 }
 unab _ZoXQ: `_Zo' `XQ'*
 local k_ZoXQ2 : word count `_ZoXQ'
 local k_ZoXQ2 = `k_ZoXQ2'+1
 if `k_ZoXQ2' < `N' {
 regress `E2' `_ZoXQ' , `noconstant'
 scalar `dfw2'=e(df_m)
 scalar `lmhw21'=e(r2)*e(N)
 scalar `lmhw21p'=chi2tail(`dfw2' , abs(`lmhw21'))
 scalar `lmhw22'=e(mss)/(2*`Sig2n'^2)
 scalar `lmhw22p'=chi2tail(`dfw2' , abs(`lmhw22'))
 }
 regress `LnE2' `_Zo' , `noconstant'
 scalar `lmhharv'=e(mss)/4.9348
 scalar `lmhharvp'= chi2tail(2, abs(`lmhharv'))
 regress `LnE2' `_Zo' , `noconstant'
 scalar `lmhwald'=e(mss)/2
 scalar `lmhwaldp'=chi2tail(1, abs(`lmhwald'))
 regress `absE' `_Zo' , `noconstant'
 scalar `lmhgl'=e(mss)/((1-2/_pi)*`Sig2n')
 scalar `lmhglp'=chi2tail(2, abs(`lmhgl'))
 regress `U2' `_Zo' , `noconstant'
 scalar `lmhcw2'=e(mss)/2
 scalar `cwdf2' =e(df_m)
 scalar `lmhcw2p'=chi2tail(`cwdf2', abs(`lmhcw2'))
 regress `E2' `Yh' , `noconstant'
 scalar `lmhhp1'=e(N)*e(r2)
 scalar `lmhhp1p'=chi2tail(1, abs(`lmhhp1'))
 regress `E2' `Yh2' , `noconstant'
 scalar `lmhhp2'=e(N)*e(r2)
 scalar `lmhhp2p'=chi2tail(1, abs(`lmhhp2'))
 regress `E2' `LYh2' , `noconstant'
 scalar `lmhhp3'=e(N)*e(r2)
 scalar `lmhhp3p'= chi2tail(1, abs(`lmhhp3'))
 regress `U2' `Yh' , `noconstant'
 scalar `lmhcw1'= e(mss)/2
 scalar `cwdf1' = e(df_m)
 scalar `lmhcw1p'=chi2tail(`cwdf1', abs(`lmhcw1'))
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:*** Panel Heteroscedasticity Tests - Model= ({bf:{err:`model'}})}}"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt _col(2) "{bf: Ho: Panel Homoscedasticity - Ha: Panel Heteroscedasticity}"
noi di
 tempvar Time
 tempname lmharch lmharchp lmhbg lmhbgp
 gen `Time'=_n
 tsset `Time'
 cap drop `LE'*
 gen double `LE'1=L1.`E2' 
 regress `E2' `LE'* 
 scalar `lmharch'=e(r2)*e(N)
 scalar `lmharchp'= chi2tail(1, abs(`lmharch'))
 regress `E2' L1.`E2' `_Zo' , `noconstant'
 scalar `lmhbg'=e(r2)*e(N)
 scalar `lmhbgp'=chi2tail(1, abs(`lmhbg'))
noi di as txt "- Engle LM ARCH Test AR(1): E2 = E2_1" _col(41) "=" %9.4f `lmharch' _col(54) "P-Value > Chi2(1)" _col(73) %5.4f `lmharchp'
noi di _dup(78) "-"
noi di as txt "- Hall-Pagan LM Test:   E2 = Yh" _col(41) "=" %9.4f `lmhhp1' _col(54) "P-Value > Chi2(1)" _col(73) %5.4f `lmhhp1p'
noi di as txt "- Hall-Pagan LM Test:   E2 = Yh2" _col(41) "=" %9.4f `lmhhp2' _col(54) "P-Value > Chi2(1)" _col(73) %5.4f `lmhhp2p'
noi di as txt "- Hall-Pagan LM Test:   E2 = LYh2" _col(41) "=" %9.4f `lmhhp3' _col(54) "P-Value > Chi2(1)" _col(73) %5.4f `lmhhp3p'

noi di _dup(78) "-"
noi di as txt "- Harvey LM Test:    LogE2 = X" _col(41) "=" %9.4f `lmhharv' _col(54) "P-Value > Chi2(2)" _col(73) %5.4f `lmhharvp'
noi di as txt "- Wald Test:         LogE2 = X " _col(41) "=" %9.4f `lmhwald' _col(54) "P-Value > Chi2(1)" _col(73) %5.4f `lmhwaldp'
noi di as txt "- Glejser LM Test:     |E| = X" _col(41) "=" %9.4f `lmhgl' _col(54) "P-Value > Chi2(2)" _col(73) %5.4f `lmhglp'
noi di as txt "- Breusch-Godfrey Test:  E = E_1 X" _col(41) "=" %9.4f `lmhbg' _col(54) "P-Value > Chi2(1)" _col(73) %5.4f `lmhbgp'
noi di _dup(78) "-"
noi di as txt "- Machado-Santos-Silva Test: Ev=Yh Yh2" _col(41) "=" %9.4f `lmhmss1' _col(54) "P-Value > Chi2(" `mssdf1' ")" _col(73) %5.4f `lmhmss1p'
noi di as txt "- Machado-Santos-Silva Test: Ev=X" _col(41) "=" %9.4f `lmhmss2' _col(54) "P-Value > Chi2(" `mssdf2' ")" _col(73) %5.4f `lmhmss2p'
 ereturn scalar lmhmss2p= `lmhmss2p'
 ereturn scalar lmhmss2= `lmhmss2p'
 ereturn scalar lmhmss1p= `lmhmss1p'
 ereturn scalar lmhmss1= `lmhmss1'
noi di _dup(78) "-"
noi di as txt "- White Test - Koenker(R2): E2 = X" _col(41) "=" %9.4f `lmhw01' _col(54) "P-Value > Chi2(" `dfw0' ")" _col(73) %5.4f `lmhw01p'
noi di as txt "- White Test - B-P-G (SSR): E2 = X" _col(41) "=" %9.4f `lmhw02' _col(54) "P-Value > Chi2(" `dfw0' ")" _col(73) %5.4f `lmhw02p'
noi di _dup(78) "-"
 if `k_ZoXQ1' < `N' {
noi di as txt "- White Test - Koenker(R2): E2 = X X2" _col(41) "=" %9.4f `lmhw11' _col(54) "P-Value > Chi2(" `dfw1' ")" _col(73) %5.4f `lmhw11p'
noi di as txt "- White Test - B-P-G (SSR): E2 = X X2" _col(41) "=" %9.4f `lmhw12' _col(54) "P-Value > Chi2(" `dfw1' ")" _col(73) %5.4f `lmhw12p'
noi di _dup(78) "-"
 }
 if `k_ZoXQ2' < `N' {
noi di as txt "- White Test - Koenker(R2): E2 = X X2 XX" _col(41) "=" %9.4f `lmhw21' _col(54) "P-Value > Chi2(" `dfw2' ")" _col(73) %5.4f `lmhw21p'
noi di as txt "- White Test - B-P-G (SSR): E2 = X X2 XX" _col(41) "=" %9.4f `lmhw22' _col(54) "P-Value > Chi2(" `dfw2' ")" _col(73) %5.4f `lmhw22p'
noi di _dup(78) "-"
 }
noi di as txt "- Cook-Weisberg LM Test: E2/S2n = Yh" _col(41) "=" %9.4f `lmhcw1' _col(54) "P-Value > Chi2(" `cwdf1' ")" _col(73) %5.4f `lmhcw1p'
noi di as txt "- Cook-Weisberg LM Test: E2/S2n = X" _col(41) "=" %9.4f `lmhcw2' _col(54) "P-Value > Chi2(" `cwdf2' ")" _col(73) %5.4f `lmhcw2p'
noi di _dup(78) "-"
noi di as txt "*** Single Variable Tests: ***"
noi di as txt "* Cook-Weisberg LM Test: E2/Sig2"
 local nx : word count `_Zo'
 tokenize `_Zo'
 local i 1
 while `i' <= `nx' {
 regress `U2' ``i''
 ereturn scalar lmhcwx_`i'= e(mss)/2
 ereturn scalar lmhcwxp_`i'= chi2tail(1 , abs(e(lmhcwx_`i')))
noi di as txt "- ``i''" _col(40) "=" %9.4f e(lmhcwx_`i') _col(53) " P-Value > Chi2(1)" _col(73) %5.4f e(lmhcwxp_`i')
 local i =`i'+1
 }
noi di _dup(78) "-"
noi di as txt "*** Single Variable Tests: ***"
noi di as txt "* King LM Test:"
 foreach i of local _Zo {
 cap drop `ht'`i'
 tempvar `ht'`i'
 egen `ht'`i' = rank(`i')
 summ `ht'`i'
 scalar `mh' = r(mean)
 scalar `vh' = r(Var)
 summ `ht'`i' [aw=`E'^2] , meanonly
 scalar `h' = r(mean)
 ereturn scalar lmhq_`i'=(`N'^2/(2*(`N'-1)))*(`h'-`mh')^2/`vh'
 ereturn scalar lmhqp_`i'= chi2tail(1, abs(e(lmhq_`i')))
noi di as txt "- `i'" _col(40) "=" %9.4f e(lmhq_`i') _col(53) " P-Value > Chi2(1)" _col(73) %5.4f e(lmhqp_`i')
 }
noi di _dup(78) "-"
 if "`model'"!="" & !inlist("`run'", "xtdhp", "xtabond", "xtdpdsys") {
 tempvar Sig2 SigLR SigLRs SigLM SigLMs SigW SigWs E E2 EE1 En cN cT Obs Egh
 local idv `idv'
 tsset `Time'
 regress `_Yo' `_Zo' `wgt' , `noconstant'
 predict double `E' , res
 gen double `E2' = `E'^2 
 summ `E2' , meanonly
 local Sig2 = r(mean)
 gen double `SigLR' = . 
 gen double `SigLM' = . 
 gen double `SigW'  = . 
 local SigLRs = 0
 local SigLMs = 0
 local SigWs  = 0
 levelsof `idv' , local(levels)
 foreach l of local levels {
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
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Panel Groupwise Heteroscedasticity Tests}}"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt _col(2) "{bf: Ho: Panel Homoscedasticity - Ha: Panel Groupwise Heteroscedasticity}"
noi di
noi di as txt "- Lagrange Multiplier LM Test" _col(33) "=" %12.4f `lmhglm' as txt _col(50) "P-Value > Chi2(" `dflm' ")" _col(70) %5.4f `lmhglmp'
noi di as txt "- Likelihood Ratio LR Test" _col(33) "=" %12.4f `lmhglr' _col(50) "P-Value > Chi2(" `dflr' ")" _col(70) %5.4f `lmhglrp'
noi di as txt "- Wald Test" _col(33) "=" %12.4f `lmhgw' _col(50) "P-Value > Chi2(" `dfw' ")" _col(70) %5.4f `lmhgwp'
noi di _dup(78) "-"
 ereturn scalar lmhglr=`lmhglr'
 ereturn scalar lmhglrp=`lmhglrp'
 ereturn scalar lmhglm=`lmhglm'
 ereturn scalar lmhglmp=`lmhglmp'
 ereturn scalar lmhgw=`lmhgw'
 ereturn scalar lmhgwp=`lmhgwp'
 }
 ereturn scalar lmhw01=`lmhw01'
 ereturn scalar lmhw01p=`lmhw01p'
 ereturn scalar lmhw02=`lmhw02'
 ereturn scalar lmhw02p=`lmhw02p'
 if `k_ZoXQ1' < `N' {
 ereturn scalar lmhw11=`lmhw11'
 ereturn scalar lmhw12=`lmhw12'
 ereturn scalar lmhw11p=`lmhw11p'
 ereturn scalar lmhw12p=`lmhw12p'
 }
 if `k_ZoXQ2' < `N' {
 ereturn scalar lmhw21=`lmhw21'
 ereturn scalar lmhw22=`lmhw22'
 ereturn scalar lmhw21p=`lmhw21p'
 ereturn scalar lmhw22p=`lmhw22p'
 }
 ereturn scalar lmhharv=`lmhharv'
 ereturn scalar lmhharvp=`lmhharvp'
 ereturn scalar lmhwald=`lmhwald'
 ereturn scalar lmhwaldp=`lmhwaldp'
 ereturn scalar lmhgl=`lmhgl'
 ereturn scalar lmhglp=`lmhglp'
 ereturn scalar lmhcw2=`lmhcw2'
 ereturn scalar lmhcw2p=`lmhcw2p'
 ereturn scalar lmhhp1=`lmhhp1'
 ereturn scalar lmhhp1p=`lmhhp1p'
 ereturn scalar lmhhp2=`lmhhp2'
 ereturn scalar lmhhp2p=`lmhhp2p'
 ereturn scalar lmhhp3=`lmhhp3'
 ereturn scalar lmhhp3p=`lmhhp3p'
 ereturn scalar lmhcw1=`lmhcw1'
 ereturn scalar lmhcw1p=`lmhcw1p'
 ereturn scalar lmharch=`lmharch'
 ereturn scalar lmharchp=`lmharchp'
 ereturn scalar lmhbg=`lmhbg'
 ereturn scalar lmhbgp=`lmhbgp'
 }

 if "`model'"!="" & "`lmnorm'"!= "" {
 tempvar Yh E E1 E2 E3 E4 Es U2 DE LDE LDF1 Yt U Hat 
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
 gen double `E'`i'=(`E'-`Eb')^`i' 
 summ `E'`i'
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
 summ `E' 
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
 sort `Time'
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Panel Non Normality Tests - Model= ({bf:{err:`model'}})}}"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf: Ho: Normality - Ha: Non Normality}"
noi di _dup(78) "-"
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
noi di as txt "- Srivastava  Z Kurtosis Test" _col(40) "=" %9.4f e(lmnsvk) _col(55) "P-Value > Z(0,1)" _col(73) %5.4f e(lmnsvkp)
noi di as txt "- Small LM Kurtosis Test" _col(40) "=" %9.4f e(lmnsmk) _col(55) "P-Value > Chi2(1)" _col(73) %5.4f e(lmnsmkp)
noi di as txt "- Kurtosis Z Test" _col(40) "=" %9.4f e(lmnkz) _col(55) "P-Value > Chi2(1)" _col(73) %5.4f e(lmnkzp)
noi di _dup(78) "-"
noi di as txt _col(5) "Skewness Coefficient =" _col(28) %7.4f `Sk' as txt "   " "  - Standard Deviation = " _col(48) %7.4f `sksd'
noi di as txt _col(5) "Kurtosis Coefficient =" _col(28) %7.4f `Ku' as txt "   " "  - Standard Deviation = " _col(48) %7.4f `kusd'
noi di _dup(78) "-"
noi di as txt _col(5) "Runs Test:" " " "(" `Rn' ")" " " "Runs - " " " "(" `N1' ")" " " "Positives -" " " "(" `N2' ")" " " "Negatives"
noi di as txt _col(5) "Standard Deviation Runs Sig(k) = " %7.4f `SN' " , " "Mean Runs E(k) = " %7.4f `EN' 
noi di as txt _col(5) "95% Conf. Interval [E(k)+/- 1.96* Sig(k)] = (" %7.4f `Lower' " , " %7.4f `Upper' " )"
noi di _dup(78) "-"
 }

 if "`lmhet'"!="" | "`lmnorm'"!= "" {
 if "`tobit'"!="" {
 tempname K B XBM XB CDF PDF E2 Sig CDFs PDFs lmnci NR2
 tempname DB DS U3 U4 M1 M2 DB0 Yh SigM H kxt SSE YYR R2Raw
 tempvar EXwXw AM XBs ImR XBX SigV SigV2 E D0 D1 Eg Gz Eg3 Eg4 Es
 tempvar dfdb dfds sig XB u1 u2 u3 u4
 tsset `Time'
 scalar `kxt' = `kx'
 if inlist("`model'", "gs2slsar") {
 scalar `kxt' = `kx'-1
 }
 xtset `idv' `itv'
 xttobit `_Yo' `_Zo' , nolog ll(`llt') `noconstant' `coll'
 predict double `XBX' , xb
 local k = `kxt'
 gen double `SigV'=_b[/sigma_e]
 gen double `E'=`_Yo'-`XBX' 
 gen double `SigV2'= `SigV'^2 
 gen double `XBs'= `XBX'/`SigV' 
 gen double `Es'= `E'/`SigV' 
 gen double `ImR'=normalden(`XBs')/(1-normal(`XBs')) 
 replace `ImR'=0 if `ImR' == .
 gen `D0'=0 
 gen `D1'=0 
 replace `D0'=1 if `_Yo' == `llt'
 replace `D1'=1 if `_Yo' > `llt'
 gen double `DB' =(`D1'*`Es'-`D0'*`ImR')/`SigV' 
 gen double `DS' =(`D1'*(`Es'^2-1)+`D0'*`ImR'*`XBs')/`SigV' 
 gen double `Eg'=(`D1'*(`_Yo'-`XBX')-`D0'*`SigV'*`ImR')/(`SigV2') 
 foreach var of local _Zo {
 gen double `EXwXw'`var'=`Eg'*`var' 
 }
 gen double `Gz'=(`D1'*(((`_Yo'-`XBX')^2/`SigV2')-1)+`D0'*`XBs'*`ImR')/(2*`SigV2') 
 gen double `Eg3'=`Eg'^3 
 gen double `Eg4'=(`Eg'^4)-3*`Eg'*`Eg' 
 regress `X0' `EXwXw'* `Eg' `Gz' `Eg3' `Eg4' , noconst
 scalar `SSE'=e(rss)
 scalar `YYR'=_N
 scalar `R2Raw'=1-(`SSE'/`YYR')
 scalar `lmnci'=`N'*`R2Raw'
 tobit `_Yo' `_Zo' , nolog ll(`llt') `noconstant' `coll'
 predict double `dfdb' `dfds' , score 
 gen double `sig'=_b[/sigma]
 predict double `XB' , xb
 replace `XBs'=`XB'/`sig' 
 replace `Es'=(`_Yo'-`XB')/`sig' 
 replace `ImR'=normalden(`XBs')/(1-normal(`XBs')) 
 replace `ImR'=0 if `ImR' == .
 gen double `u1'= -`D0'*`ImR' +`D1'*`Es' 
 gen double `u2'= `D0'*`XBs'*`ImR' +`D1'*(`Es'^2 - 1) 
 gen double `u3'= -`D0'*(2+`XBs'^2)*`ImR' +`D1'*`Es'^3 
 gen double `u4'= `D0'*(3*`XBs'+`XBs'^3) *`ImR' +`D1'*(`Es'^4 - 3) 
 tempvar d0 
 summ `dfdb' 
 gen double `d0'=`dfdb' 
 local vlist "`d0'"
 local mlist ""
 local vlist ""
 local mlist ""
 local j=1
 while `j'<=`kx' {
 tempvar d`j' mom`j'
 local j=`j'+1
 }
 local j=0
 tokenize `_Zo'
 while "`1'"~="" {
 local j=`j'+1
 gen double `d`j''=`dfdb'*`1' 
 gen double `mom`j''=`u2'*`1' 
 local vlist "`vlist' `d`j''"	
 local mlist "`mlist' `mom`j''"	
 macro shift
 local vlist "`vlist' `dfdb' `dfds'"
 }
 local j=1
 while "`1'"~="" {
 local vlist "`vlist' `dfdb'`j'"
 local j=`j'+1
 }
 tempvar const
 gen `const'=1 
 local q=0
 while `q'<=4 {
 if `q'==0 {
 local j=1
 tokenize `_Zo'
noi di 
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:*** Tobit Heteroscedasticity LM Tests Model= ({bf:{err:`model'}})}}"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt " {bf:Separate LM Tests - Ho: Homoscedasticity}"
 while `j'<=`kx' {
 regress `const' `mom`j'' `vlist' , noconstant
 scalar `NR2'=e(r2)*e(N)
 local df=1
noi di as txt "- LM Test: " "``j''" _col(33) "=" %10.4f `NR2' _col(47) "P-Value > Chi2(1)" _col(67) %5.4f chi2tail(`df', abs(`NR2'))
 local j=`j'+1
 }
 }
 if `q'==1 {
noi di
noi di as txt " {bf:Joint LM Test     - Ho: Homoscedasticity}"
 regress `const' `mlist' `vlist' , noconstant
 }
 if `q'==2 {
noi di 
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:*** Tobit Non Normality LM Tests - Model= ({bf:{err:`model'}})}}"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt " {bf:LM Test - Ho: No Skewness}"
 regress `const' `u3' `vlist' , noconstant
 }
 if `q'==3 {
noi di
noi di as txt " {bf:LM test - Ho: No Kurtosis}"
 regress `const' `u4' `vlist' , noconstant
 }
 if `q'==4 {
noi di
noi di as txt " {bf:LM Test - Ho: Normality (No Kurtosis, No Skewness)}"
 regress `const' `u3' `u4' `vlist' , noconstant
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
noi di as txt _col(2) "- LM Test"  _col(33) "=" %10.4f `NR2' as txt _col(47) "P-Value > Chi2(" `df' ")" _col(67) %5.4f chi2tail(`df', abs(`NR2'))
 }
 if `q' == 4 {
noi di as txt _col(2) "- Pagan-Vella LM Test" _col(33) "=" %10.4f `NR2' as txt _col(47) "P-Value > Chi2(2)" _col(67) %5.4f chi2tail(2, abs(`NR2'))
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
noi di as txt _col(2) "- Chesher-Irish LM Test" _col(33) "=" %10.4f e(lmnci) as txt _col(47) "P-Value > Chi2(2)" _col(67) %5.4f e(lmncip)
noi di _dup(78) "-"
 }
 }

 if "`model'"!="" & "`reset'"!= "" {
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:*** {bf: {err:RE}}gression {bf:{err:S}}pecification {bf:{err:E}}rror {bf:{err:T}}ests (RESET)} - {bf:(Model= {err:`model'})}"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf: Ho: Model is Specified  -  Ha: Model is Misspecified}"
noi di _dup(78) "-"
 tempvar E2 Yh2 Yh3 Yh4 SSi SCi SLi CLi WL WS Yh
 tempname k0 rim
 tsset `Time'
 gen double `Yh' =`Yh_ML'
 summ `Yh' 
 scalar YMin = r(min)
 scalar YMax = r(max)
 gen double `WL'=_pi*(2*`Yh'-(YMax+YMin))/(YMax-YMin) 
 gen double `WS'=2*_pi*(sin(`Yh_ML')^2)-_pi 
noi di as txt "{bf:* Ramsey Specification ResetF Test}"
 scalar `k0'=1
 if "`noconstant'"!="" {
 scalar `k0'=0
 }
 forvalue i=2/4 {
 tempvar Yhrm`i'
 gen double `Yhr'_`i'=`Yh'^`i'
 regress `_Yo' `_Zo' `Yhr'_* `wgt' , noomitted `noconstant'
 predict double `Yhrm`i'' , xb
 correlate `Yhrm`i'' `_Yo'
 scalar `rim'=r(rho)*r(rho)
 scalar resetf`i'=(e(N)-e(df_m)-`k0')*(`rim'-`R20')/((`i'-1)*(1-`rim'))
 scalar resetf`i'p= Ftail((`i'-1), (e(N)-e(df_m)-1), resetf`i')
 scalar resetf`i'df= (e(N)-e(df_m)-1)
 }
noi di as txt "- Ramsey RESETF1 Test: Y= X Yh2" _col(41) "= " %7.3f resetf2 _col(52) "P-Value > F("1 ",  "    resetf2df ") " _col(72) %5.4f resetf2p
noi di as txt "- Ramsey RESETF2 Test: Y= X Yh2 Yh3" _col(41) "= " %7.3f resetf3 _col(52) "P-Value > F("2 ",  "    resetf3df ") " _col(72) %5.4f resetf3p
noi di as txt "- Ramsey RESETF3 Test: Y= X Yh2 Yh3 Yh4" _col(41) "= " %7.3f resetf4 _col(52) "P-Value > F("3 ",  "    resetf4df ") " _col(72) %5.4f resetf4p
noi di _dup(78) "-"
noi di as txt "{bf:* DeBenedictis-Giles Specification ResetL Test}"
 forvalue i=1/3 {
 gen double `SLi'`i'=sin(`i'*`WL') 
 gen double `CLi'`i'=sin(`i'*`WL'+_pi/2) 
 regress `_Yo' `_Zo' `SLi'* `CLi'* `wgt' , noomitted `noconstant'
 cap testparm `SLi'* `CLi'*
 if r(F) != . {
noi di as txt "- Debenedictis-Giles ResetL`i' Test" _col(41) "= " %7.3f r(F) _col(52) "P-Value > F("r(df) ", "    r(df_r) ")" _col(72) %5.4f r(p)
 scalar resetl`i'= r(F)
 scalar resetl`i'p=r(p)
 ereturn scalar resetl`i'=resetl`i'
 ereturn scalar resetl`i'=resetl`i'p
 }
 }
noi di _dup(78) "-"
noi di as txt "{bf:* DeBenedictis-Giles Specification ResetS Test}"
 forvalue i=1/3 {
 gen double `SSi'`i'=sin(`i'*`WS')
 gen double `SCi'`i'=sin(`i'*`WS'+_pi/2)
 regress `_Yo' `_Zo' `SSi'* `SCi'* `wgt' , noomitted `noconstant'
 cap testparm `SSi'* `SCi'*
 if r(F) != . {
noi di as txt "- Debenedictis-Giles ResetS`i' Test" _col(41) "= " %7.3f r(F) _col(52) "P-Value > F("r(df) ", "    r(df_r) ")" _col(72) %5.4f r(p)
 scalar resets`i'= r(F)
 scalar resets`i'p=r(p)
 ereturn scalar resets`i'=resets`i'
 ereturn scalar resets`i'=resets`i'p
 }
 }
noi di _dup(78) "-"
 ereturn scalar resetf1=resetf2
 ereturn scalar resetf1p=resetf2p
 ereturn scalar resetf2=resetf3
 ereturn scalar resetf2p=resetf3p
 ereturn scalar resetf3=resetf4
 ereturn scalar resetf3p=resetf4p
 }

 if "`model'"!="" & "`hausman'"!= "" {
noi di
 local xtype Random-Effects
 if "`be'"!="" {
 local xtype Between-Effects
 }
 if "`fe'"!="" {
 local xtype Fixed-Effects
 }
 if "`re'"!="" {
 local xtype Random-Effects
 }
 if "`mle'"!="" {
 local xtype MLE Random-Effects
 }
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:*** Hausman Fixed vs Random Effects & Specification Panel vs IV-Panel Tests}}"
noi di _dup(78) "{bf:{err:=}}"
 if inlist("`model'", "gs2sls", "gs2slsar") & "`hausman'"!="" {
noi di as txt "{bf:*** (1) Hausman {bf:({err:Panel}} vs {bf:{err:IV Panel}) `xtype' - Model (`model')}}"
noi di
noi di as txt "{bf: Ho: (Biv) Consistent  * Ha: (Bo) InConsistent}"
noi di as txt "{bf: LM = (Bo-Biv)'inv(Vo-Viv)*(Bo-Biv)}"
noi di as txt "{bf: [Low/(High*)] Hausman Test = [Biv/(Bo*)] Model}"
noi di as txt "{bf:XTREG   - differences in XTREG and XTIVREG are not systematic}"
noi di as txt "{bf:XTIVREG - differences in XTREG and XTIVREG are systematic}"
 xtset `idv' `itv'
 tempname Haus_Fiv
 xtreg `_Yo' `_Zo' , `fe' `be' `re' `mle'
 estimates store `Haus_Fiv'
 xtivreg `_Yo' `exog' (`WsYi'=`inst') , `fe' `be' `re' small
 hausman `Haus_Fiv'
 tempname lmhs lmhsp
 ereturn scalar lmhs=r(chi2)
 ereturn scalar lmhsp= chi2tail(r(df), abs(e(lmhs)))
noi di
noi di as txt " Hausman LM Test " _col(15) " = " %10.5f e(lmhs) _col(35) "P-Value > Chi2(" r(df) ")" _col(55) %5.4f e(lmhsp)
noi di _dup(78) "-"
 }
noi di
noi di as txt "{bf:*** (2) Hausman ({bf:{err:Fixed Effects}} vs {bf:{err:`xtype'}) Test - Model (`model')}}"
noi di
noi di as txt "{bf: Ho: Random Effects (RE) (Consistent) - Ha: Fixed Effects (FE) (InConsistent)}"
noi di as txt "{bf: LM = (Bfe-Bre)'inv(Vfe-Vre)*(Bfe-Bre)}"
noi di as txt "{bf: [Low/(High*)] Hausman Test = [REM/(FEM*)] Model}"
noi di as txt "{bf:RE - differences in FE and RE are not systematic}"
noi di as txt "{bf:FE - differences in FE and RE are systematic}"
 xtset `idv' `itv'
 tempname Haus_Fix
 xtreg `_Yo' `_Zo' , fe
 estimates store `Haus_Fix'
 xtreg `_Yo' `_Zo' , `be' `re' `mle'
 hausman `Haus_Fix'
 tempname lmhsfe lmhsfep
 ereturn scalar lmhsfe=r(chi2)
 ereturn scalar lmhsfep= chi2tail(r(df), abs(e(lmhsfe)))
noi di
noi di as txt " Hausman LM Test " _col(15) " = " %10.5f e(lmhsfe) _col(35) "P-Value > Chi2(" r(df) ")" _col(55) %5.4f e(lmhsfep)
noi di _dup(78) "-"
 }

 if inlist("`model'", "gs2sls", "gs2slsar") & "`lmiden'"!="" {
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:*** Panel Identification Restrictions LM Tests - Model= ({bf:{err:`model'}})}}"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:Ho: Valid Included & Excluded Instruments ; RHS Not Correlated with Error Term}"
noi di
 tempvar uiv
 tempname Z DFr
 xtset `idv' `itv'
 local useconxt `fe' `re' `be'
 if inlist("`model'", "gs2sls", "gs2slsar") & "`useconxt'"!="" {
 xtivreg `_Yo' `exog' (`WsYi'=`inst') , `fe' `be' `re' `ec2sls' `nosa' small
 } 
 if inlist("`model'", "gs2sls", "gs2slsar") & "`useconxt'"=="" {
 xtivreg `_Yo' `exog' (`WsYi'=`inst') , re `ec2sls' `nosa' small
 } 
 predict double `uiv' , xb 
 replace `uiv'=`_Yo'-`uiv'
 local sgp=`kinstx'-`kexog'
 regress `uiv' `exog' `inst'
 local lms=e(N)*e(r2)
 scalar `DFr' =e(N)-`Jkb'
 local lmb =`lms'*`DFr'/(e(N)-`lms')
 local lmbp= chi2tail(`sgp', abs(`lmb'))
 local lmsp= chi2tail(`sgp', abs(`lms'))
noi di as txt "{bf:{err:** Y  = LHS Dependent Variable:}}" _col(37) "`_Yo'" 
noi di as txt "{bf:{err:** Yi = RHS Endogenous Variables:}}"
noi di as txt "   " `kendog' " : " "`WsYi'" 
noi di as txt "{bf:{err:** Xi = RHS Exogenous Variables:}}"
noi di as txt "   " `kexog' " : " "`exog'" 
noi di as txt "{bf:{err:** Z  = Overall Instrumental Variables:}}"
noi di as txt "   " `kinstx' " : " "`instx'"
noi di _dup(60) "-"
noi di as txt "- Sargan  LM Test = " %9.4f `lms' _col(35) "P-Value > Chi2(" `sgp' ")" _col(55) %5.4f `lmsp' 
noi di as txt "- Basmann LM Test = " %9.4f `lmb' _col(35) "P-Value > Chi2(" `sgp' ")" _col(55) %5.4f `lmbp' 
 ereturn scalar lmb = `lmb'
 ereturn scalar lms = `lms'
 ereturn scalar lmbp= chi2tail(`sgp', abs(`lmb'))
 ereturn scalar lmsp= chi2tail(`sgp', abs(`lms'))
noi di _dup(78) "-" 
 tempvar E E2 Lambdav
 tempname W1 W2 WY M1 M2 Xg X Zg lamp1 lamp2 lamp lam Lambda kliml W1W OM We hjm
 local N=`N'
 tsset `Time'
 local inst : list instx - exog
 local lrdf= `kinst'-`kendog'
 local useconxt `fe' `re' `be'
 xtset `idv' `itv'
 if "`useconxt'"!="" {
 xtreg `Ue_MLo' `instx' , `fe' `be' `re' `mle'
 local lmih1 =`N'*e(r2_o)
 xtivreg `_Yo' `exog' (`WsYi'=`inst') , `fe' `be' `re' `ec2sls' `nosa' small
 } 
 if "`useconxt'"=="" {
 xtreg `Ue_MLo' `instx' , re 
 local lmih1 =`N'*e(r2_o)
 xtivreg `_Yo' `exog' (`WsYi'=`inst') , re `ec2sls' `nosa' small
 } 
 matrix `Bv1'=e(b)
 matrix `Bv'=-`Bv1'[1, 1..`kendog']
 matrix `Bv'=1 \ `Bv''
noi di 
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Panel-IV Order Condition Identification - Model= ({bf:{err:`model'}})}}"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:** Y  = LHS Dependent Variable}
noi di as txt "   " 1 " : " "`_Yo'"
noi di as txt "{bf:** Yi = RHS Endogenous Variables}
noi di as txt "   " `kendog' " : " "`WsYi'"
noi di as txt "{bf:** Xi = RHS Included Exogenous Variables}"
noi di as txt "   " `kexog' " : " "`exog'"
noi di as txt "{bf:** Xj = RHS Excluded Exogenous Variables}"
noi di as txt "   " `kinst' " : " "`inst'"
noi di as txt "{bf:** Z  = Overall Instrumental Variables}"
noi di as txt "   " `kinstx' " : "  "`instx'"
noi di _dup(60) "-"
 if `kinstx' == `kx' {
noi di as txt "{bf: Model is Just Identification:}"
noi di as txt _col(7) "Z(" `kinstx' ")" " = Yi + Xi (" `kx' ")
noi di as txt "* since: Z = Yi + Xi : it is recommended to use (2SLS-LIML-MELO-3SLS-FIML)"
noi di _dup(60) "-"
 }
 if `kinstx'>`kx' {
noi di as txt "{bf: Model is Over Identification:}"
noi di as txt _col(7) "Z(" `kinstx' ")" " > Yi + Xi (" `kx' ")"
noi di as txt "* since: Z > Yi + Xi : it is recommended to use (2SLS-LIML-MELO-3SLS-FIML)"
 tsset `Time'
 local dfs=`kinst'-`kendog'
 local dfr=`N'-`kx'
 local dfu=`N'-`kinstx'
 matrix `WY'=`Wi'*`Y'
 matrix `M1'=I(`N')
 matrix `M2'=I(`N')
 if "`noconstant'"!="" {
 mkmat `exog' , matrix(`Xg')
 mkmat `exog' `inst' , matrix(`Zg')
 }
 else {
 mkmat `exog' `Zo' , matrix(`Xg')
 mkmat `exog' `inst' `Zo' , matrix(`Zg')
 }
 if `kexog' >= 1 {
 matrix `M1'=I(`N')-`Wi'*`Xg'*invsym(`Xg''*`Wi''*`Wi'*`Xg')*`Xg''*`Wi''
 }
 if `kinst' >= 1 {
 matrix `M2'=I(`N')-`Wi'*`Zg'*invsym(`Zg''*`Wi''*`Wi'*`Zg')*`Zg''*`Wi''
 }
 matrix `W1'=`WY''*`M1'*`WY'
 matrix `W2'=`WY''*`M2'*`WY'
 matrix `W1W'=`W1'*invsym(`W2')
 matrix eigenvalues `Lambda' `Vec' = `W1W'
 matrix `Lambda' =`Lambda''
 svmat double `Lambda' , name(`Lambdav')
 rename `Lambdav'1 `Lambda'
 summ `Lambda' 
 scalar `kliml'=r(min)
 local lmih1p= chi2tail(`dfs', abs(`lmih1'))
 local lmis1 = `lmih1'*`dfr'/`N'
 local lmis1p= chi2tail(`dfs', abs(`lmis1'))
 local lmib=`lmih1'*`dfu'/(`N'-`lmih1')
 local lmibp= chi2tail(`dfs', abs(`lmib'))
 local lmisf = `lmih1'/`N'*`dfr'/`dfs'
 local lmisfp= Ftail(`dfs',`dfr',`lmisf')
 local fb4= `lmih1'*`dfu'/(`N'-`lmih1')/`dfs'
 local fbp4= Ftail(`dfs',`dfu',`fb4')
 local lmiar=`N'*(`kliml'-1)
 local lmiarp=chi2tail(`dfs', abs(`lmiar'))
 matrix `lamp1' = `Bv''*`W1'*`Bv'
 matrix `lamp2' = `Bv''*`W2'*`Bv'
 scalar `lamp' = `lamp1'[1,1]/`lamp2'[1,1]
 ereturn scalar lam=`kliml'
 ereturn scalar lamp=`lamp'
 local lmibf2= (`N'-`kinstx')/`dfs'*(`lamp'-1)
 local lmibf2p=Ftail(`dfs', `dfu', `lmibf2')
 local lmibf3 =((`N'-`kx')/(`lrdf'))*(`kliml'-1)
 local lmibf3p=Ftail(`dfs', `dfu', `lmibf3')
 local lmibf1= (`N'-`kinstx')/`dfs'*(`kliml'-1)
 local lmibf1p=Ftail(`dfs', `dfu', `lmibf1')
noi di 
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Panel 2SLS-IV Over Identification Restrictions Tests - Model= ({bf:{err:`model'}})}}"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf: Ho: Valid Included & Excluded Instruments ; RHS Not Correlated with Error Term}"
noi di _dup(78) "-"
noi di as txt " - Hausman LM Test" _col(28) "=" %10.5f `lmih1' _col(43) "P-Value > Chi2(" `dfs' ")" _col(65) %5.4f `lmih1p' 
noi di _dup(78) "-"
noi di as txt " - Sargan LM Test " _col(28) "=" %10.5f `lmis1' _col(43) "P-Value > Chi2(" `dfs' ")" _col(65) %5.4f `lmis1p'
noi di as txt " - Sargan F  Test " _col(28) "=" %10.5f `lmisf' _col(43) "P-Value > F(" `dfs' " , " `dfr' ")" _col(65) %5.4f `lmisfp'
noi di _dup(78) "-"
noi di as txt " - Basmann LM Test" _col(28) "=" %10.5f `lmib' _col(43) "P-Value > Chi2(" `dfs' ")" _col(65) %5.4f `lmibp' 
noi di as txt " - Basmann F  Test (lam)" _col(28) "=" %10.5f `lmibf1' _col(43) "P-Value > F(" `dfs' " , " `dfu' ")" _col(65) %5.4f `lmibf1p'
noi di as txt " - Basmann F  Test (lam')" _col(28) "=" %10.5f `lmibf2' _col(43) "P-Value > F(" `dfs' " , " `dfu' ")" _col(65) %5.4f `lmibf2p'
noi di _dup(78) "-"
noi di as txt " - Anderson-Rubin LR Test" _col(28) "=" %10.5f `lmiar' _col(43) "P-Value > Chi2(" `dfs' ")" _col(65) %5.4f `lmiarp' 
noi di _dup(78) "-"
 ereturn scalar lmiarp=`lmiarp'
 ereturn scalar lmiar=`lmiar'
 ereturn scalar lmibf2p=`lmibf2p'
 ereturn scalar lmibf2=`lmibf2'
 ereturn scalar lmibf3p=`lmibf3p'
 ereturn scalar lmibf3=`lmibf3'
 ereturn scalar lmibf1p=`lmibf1p'
 ereturn scalar lmibf1=`lmibf1'
 ereturn scalar lmibp=`lmibp'
 ereturn scalar lmib=`lmib'
 ereturn scalar lmisfp=`lmisfp'
 ereturn scalar lmisf=`lmisf'
 ereturn scalar lmis1p=`lmis1p'
 ereturn scalar lmis1=`lmis1'
 ereturn scalar lmih1p=`lmih1p'
 ereturn scalar lmih1=`lmih1'
 }
 }

 if "`model'"!="" & "`lmcl'"!="" {
 local kxc : word count `SPXvar'
 if `kxc' > 1 {
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:*** Multicollinearity Diagnostic Tests - Model= ({bf:{err:`model'}})}}"
noi di _dup(78) "{bf:{err:=}}"
noi di
noi di as txt "{bf:{err:* Correlation Matrix}}"
 tsset `Time'
 tempvar R2xx Rx VIFI DFF DFF1 DFF2 fgF fgFp SH6v LVal eigVaL
 tempvar eigVaLn ILVal R2oS CNmax CImax X 
 tempname COR VIF Vec eigVaL VIFI R2xx FGFF LDCor fg CORx fgT DCor X corr
 tempname Cond X0 J S Ds Val Cr Dr LVal1 LVal SLv2 SH6v q0 q1 q2 q3 q4 q5 q6
 tempname fgdf fgchi dcor1 dfm R2 R2oSs r2th Kcol Krow MaxLv MinLv SumLv SumILv
 gen `R2xx'=0 
 gen `Rx'=0 
 gen `VIFI'=0 
 gen `DFF'=0 
 gen `DFF1'=0 
 gen `DFF2'=0 
 gen `fgF'=0 
 gen `fgFp'=0 
 local star =(1-0.`level')
 corr `_Yo' `SPXvar' 
 matrix `corr'=r(C)
 matrix rownames `corr' = `_Yo' `SPXvar'
 matrix colnames `corr' = `_Yo' `SPXvar'
noi matlist `corr', twidth(10) border(all) lines(columns) noblank rowtitle(Variable) format(%7.3f)
noi pwcorr `_Yo' `SPXvar' , star(`star') sig
 corr `SPXvar'
 matrix `COR'=r(C)'
 matrix `VIF'=vecdiag(invsym(`COR'))'
 forvalue i=1/`kxc' { 
 replace `VIFI'=1/`VIF'[`i',1] in `i'
 replace `R2xx'=1-1/`VIF'[`i',1] in `i'
 }
 matrix symeigen `Vec' `eigVaL'=`COR'
 svmat double `eigVaL' , name(`eigVaL')
 rename `eigVaL'1 `eigVaL'
 mkmat `VIFI' in 1/`kxc' , matrix(`VIFI')
 mkmat `R2xx' in 1/`kxc' , matrix(`R2xx')
 matrix `eigVaL'=`eigVaL''
 svmat double `eigVaL' , name(`eigVaLn')
 rename `eigVaLn'1 `eigVaLn'
 summ `eigVaLn' 
 gen double `CNmax'=r(max) 
 replace `CNmax'=`CNmax'/`eigVaLn' 
 gen double `CImax'=sqrt(`CNmax') 
 mkmat `CNmax' `CImax' in 1/`kxc' , matrix(`Cond')
 matrix `Cond' = `eigVaL',`Cond',`VIF',`VIFI',`R2xx'
noi di
noi di as txt "{bf:{err:* Multicollinearity Diagnostic Criteria}}"
 matrix rownames `Cond' = `SPXvar'
 matrix colnames `Cond' = "Eigenval" "C_Number" "C_Index" "VIF" "1/VIF" "R2_xi,X"
noi matlist `Cond', twidth(8) border(all) lines(columns) noblank rowtitle(Variable) format(%8.4f)
 corr `SPXvar' 
 matrix `COR'=r(C)'
 matrix `VIF'=vecdiag(invsym(`COR'))'
 forvalue i=1/`kxc' { 
 replace `VIFI'=1/`VIF'[`i',1] in `i'
 replace `R2xx'=1-1/`VIF'[`i',1] in `i'
 replace `Rx'=`R2xx' in `i'
 replace `DFF'=(`N'-`kxc')/(`kxc'-1) in `i'
 replace `DFF1'=(`N'-`kxc') in `i'
 replace `DFF2'=(`kxc') in `i'
 replace `fgF'=`Rx'/(1-`Rx')*`DFF' in `i'
 replace `fgFp'= Ftail(`DFF1', `DFF2', `fgF') in `i'
 }
 mkmat `fgF' `DFF1' `DFF2' `fgFp' in 1/`kxc' , matrix(`FGFF')
 forvalue i=1/`kxc' {
 forvalue j=1/`kxc' {
 cap drop  `COR'`i'`j'
 tempvar COR`i'`j'
 gen `COR'`i'`j'=0 
 }
 }
 matrix `LDCor'=ln(det(`COR'))
 matrix `fg'=-(`N'-1-(((2*`kxc')+5)/6))*`LDCor'
 scalar `fgdf'=0.5*`kxc'*(`kxc'-1)
 scalar `fgchi'=`fg'[1,1]
 forvalue i=1/`kxc' {
 forvalue j=1/`kxc' {
 replace `COR'`i'`j'=`COR'[`i',`j']*sqrt((e(N)-`kxc'))/sqrt(1-`COR'[`i',`j']^2) in `i'
 }
 }
 forvalue i=1/`kxc' {
 forvalue j=1/`kxc' {
 mkmat `COR'`i'* in 1/`kxc' , matrix(`CORx'`i')
 matrix `CORx'`i'[1,`kxc']=`CORx'`i'[1,`kxc']'
 }
 }
 forvalue i=1/`kxc' {
 forvalue j=1/`kxc' {
 replace `COR'1`j' = `COR'`i'`j' in `i'
 }
 }
 mkmat `COR'1* in 1/`kxc' , matrix(`fgT')
noi di
noi di as txt "{bf:{err:* Farrar-Glauber Multicollinearity Tests}}"
noi di as txt _col(3) "Ho: No Multicollinearity - Ha: Multicollinearity"
noi di _dup(50) "-"
noi di
noi di as txt "{bf:* (1) Farrar-Glauber Multicollinearity Chi2-Test:}"
noi di as txt _col(5) "Chi2 Test = " %9.4f `fgchi' _col(30) "P-Value > Chi2(" `fgdf' ") " _col(45) %5.4f chi2tail(`fgdf', `fgchi') "
 ereturn scalar fgchi = `fgchi'
noi di
noi di as txt "{bf:* (2) Farrar-Glauber Multicollinearity F-Test:}"
 matrix rownames `FGFF' = `SPXvar'
 matrix colnames `FGFF' = F_Test DF1 DF2 P_Value
noi matlist `FGFF', twidth(10) border(all) lines(columns) noblank rowtitle(Variable) format(%12.3f)
noi di
noi di as txt "{bf:* (3) Farrar-Glauber Multicollinearity t-Test:}"
 matrix rownames `fgT' = `SPXvar'
 matrix colnames `fgT' = `SPXvar'
noi matlist `fgT', twidth(10) border(all) lines(cells) noblank rowtitle(Variable) format(%9.3f)
 mkmat `SPXvar' , matrix(`Z')
 corr `SPXvar' 
 matrix `COR'=r(C)'
 matrix `VIF'=vecdiag(invsym(`COR'))'
 matrix symeigen `Vec' `eigVaL'=`COR'
 matrix `LDCor'=ln(det(`COR'))
 matrix `DCor'=det(`COR')
 scalar `dcor1'=`DCor'[1,1]
 local R2oSs =0
 forvalue i=1/`kxc' {
 local j : word `i' of `SPXvar'
 local both: list SPXvar - j 
 regress `_Yo' `both' , `noconstant'
 local R2oSs =`R2oSs' + e(r2)
 local R2oSs `R2oSs'
 }
 scalar `r2th'=`R20'-(`kxc'*`R20'-`R2oSs')
 scalar `Kcol' = colsof(`Z')
 scalar `Krow' = rowsof(`Z')
 matrix `X0'= J(`N',1,1)
 matrix `J'=`X0'*`X0''
 matrix `S'=(`Z''*(I(`Krow')-1/`N'*(`J'))*`Z')/(`Krow'-1)
 matrix `Ds'=diag(vecdiag(`S'))*I(`Kcol')
 matrix symeigen `Vec' `Val' = `Ds'
 local ncol=colsof(`Ds')
 local Val `Val'
 forvalue i = 1/`ncol' {
 cap matrix `Val'[1,`i'] = sqrt(`Val'[1,`i'])
 }
 matrix `Ds' = `Vec'*diag(`Val')*`Vec''
 matrix `Cr'=invsym(`Ds')*`S'*invsym(`Ds')
 matrix `Dr'=det(`Cr')
 matrix symeigen `Vec' `LVal1' = `COR'
 matrix symeigen `Vec' `LVal' = `Cr'
 matrix `LVal'=`LVal''
 svmat double `LVal' , name(`LVal')
 rename `LVal'1 `LVal'
 summ `LVal' 
 scalar `MaxLv'=r(max)
 scalar `MinLv'=r(min)
 scalar `SumLv'=r(sum)
 gen double `ILVal'=1/`LVal' 
 summ `ILVal' 
 scalar `SumILv'=r(sum)
 matrix `SLv2'=`LVal''*`LVal'
* Gleason-Staelin (1975) *
 scalar `q0'=sqrt((`SLv2'[1,1]-`Kcol')/(`Kcol'*(`Kcol'-1)))
* Heo (1987) *
 scalar `q1'=(1-(`MinLv'/`MaxLv'))^(`Kcol'+2)
 scalar `q2'=1-(`Kcol'/`SumILv')
 scalar `q3'=1-sqrt(`Dr'[1,1])
 scalar `q4'=(`MaxLv'/`Kcol')^(3/2)
 scalar `q5'=(1-`MinLv'/`Kcol')^(5)
 matrix `SH6v'=vecdiag(invsym(`Cr'))'
 svmat double `SH6v' , name(`SH6v')
 rename `SH6v'1 `SH6v'
 replace `SH6v'=(1-1/`SH6v')/`Kcol' 
 summ `SH6v' 
 scalar `q6'=r(sum)
noi di
noi di as txt "{bf:{err:* |X'X| Determinant:}}"
noi di as txt _col(3) "{bf:|X'X| = 0 Multicollinearity - |X'X| = 1 No Multicollinearity}"
noi di as txt _col(3) "|X'X| Determinant: " _col(28) "(0 < " %5.4f `dcor1' " < 1)"
noi di _dup(63) "-"
noi di
noi di as txt "{bf:{err:* Theil R2 Multicollinearity Effect:}}"
noi di as txt _col(3) "{bf:R2 = 0 No Multicollinearity - R2 = 1 Multicollinearity}"
noi di as txt _col(6) "- Theil R2: " _col(28) "(0 < " %5.4f `r2th' " < 1)"
noi di _dup(63) "-"
noi di
noi di as txt "{bf:{err:* Multicollinearity Range:}}"
noi di as txt _col(3) "{bf:Q = 0 No Multicollinearity - Q = 1 Multicollinearity}"
noi di as txt _col(5) " - Gleason-Staelin Q0: " _col(28) "(0 < " %5.4f `q0' " < 1)"
noi di as txt _col(5) "1- Heo Range Q1: " _col(28) "(0 < " %5.4f `q1' " < 1)"
noi di as txt _col(5) "2- Heo Range Q2: " _col(28) "(0 < " %5.4f `q2' " < 1)"
noi di as txt _col(5) "3- Heo Range Q3: " _col(28) "(0 < " %5.4f `q3' " < 1)"
noi di as txt _col(5) "4- Heo Range Q4: " _col(28) "(0 < " %5.4f `q4' " < 1)"
noi di as txt _col(5) "5- Heo Range Q5: " _col(28) "(0 < " %5.4f `q5' " < 1)"
noi di as txt _col(5) "6- Heo Range Q6: " _col(28) "(0 < " %5.4f `q6' " < 1)"
noi di _dup(78) "-"
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

 if "`model'"!="" & "`lmform'"!= "" {
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:*** {err:Linear vs Log-Linear Functional Form Tests} - {bf:(Model= {err:OLS})}}"
noi di _dup(78) "{bf:{err:=}}"
 tempvar E Yh E2 Log_Yh Log_Yo LYh ELYh ELin ELog YhLin YhLog FLin FLog
 tempname SSELin llflin r2lin r2log YbG SumLY llflog SSELog r2loga bcox
 tempname bcoxp bmlin bmlinp bmlog bmlogp dmlin dmlinp dmlog dmlogp r2lina
 if "`tolog'"!="" {
 replace `_Yo'= `yvarexp'
 }
 tsset `Time'
 regress `_Yo' `_Zo' `wgt' , `noconstant'
 scalar `SSELin'=e(rss)
 scalar `llflin'=-(`N'/2)*ln(2*_pi*(`SSELin'/`N'))-(`N'/2)
 scalar `r2lin'=e(r2)
 predict double `E' , res
 gen double `E2'=`E'*`E' 
 predict double `Yh' 
 correlate `Yh' `_Yo' 
 if `r2lin'==. {
 scalar `r2lin'=r(rho)*r(rho)
 }
 gen double `Log_Yh'=ln(`Yh') 
 gen double `Log_Yo' = ln(`_Yo') 
 regress `Log_Yo' `_Zo' `wgt' , `noconstant'
 scalar `r2log'=e(r2)
 predict double `LYh' 
 correlate `LYh' `Log_Yo' 
 if `r2log'==. {
 scalar `r2log'=r(rho)*r(rho)
 }
 scalar `SSELog'=e(rss) 
 summ `Log_Yo' 
 scalar `YbG'=exp(r(mean))
 scalar `SumLY'=r(sum)
 scalar `llflog'=-(`N'/2)*ln(2*_pi*(`SSELog'/`N'))-(`N'/2)-`SumLY'
noi di as txt " {bf:(1) R-squared}"
noi di as txt _col(7) "Linear  R2" _col(36) "=" %10.4f `r2lin'
noi di as txt _col(7) "Log-Log R2" _col(36) "=" %10.4f `r2log'
noi di _dup(75) "-"
noi di as txt " {bf:(2) Log Likelihood Function (LLF)}"
noi di as txt _col(7) "LLF - Linear" _col(36) "=" %10.4f `llflin'
noi di as txt _col(7) "LLF - Log-Log" _col(36) "=" %10.4f `llflog'
noi di _dup(75) "-"
noi di as txt " {bf:(3) Antilog R2}"
 regress `Log_Yo' `_Zo' `wgt' , `noconstant'
 scalar `SSELog'=e(rss)
 gen double `ELYh'=exp(`LYh') 
 regress `ELYh' `_Yo'
 scalar `r2lina'=e(r2)
 regress `Log_Yh' `Log_Yo'
 scalar `r2loga'=e(r2)
noi di as txt _col(7) "Linear  vs Log-Log: R2Lin" _col(36) "=" %10.4f `r2lina'
noi di as txt _col(7) "Log-Log vs Linear : R2log" _col(36) "=" %10.4f `r2loga'
noi di _dup(75) "-"
 scalar `bcox'=e(N)/2*abs(ln((`SSELin'/`YbG'^2)/`SSELog'))
 scalar `bcoxp'=chi2tail(1, abs(`bcox'))
noi di as txt" {bf:(4) Box-Cox Test}" _col(36) "=" %10.4f `bcox' _col(50) "P-Value > Chi2(1)" _col(70) %5.4f `bcoxp'
noi di as txt _col(7) "Ho: Choose Log-Log Model - Ha: Choose Linear  Model"
noi di _dup(75) "-"
noi di as txt " {bf:(5) Bera-McAleer BM Test}"
 regress `ELYh' `_Zo' `wgt' , `noconstant' 
 predict double `ELin' , res
 regress `Log_Yh' `_Zo' `wgt' , `noconstant'
 predict double `ELog' , res
 regress `_Yo' `_Zo' `ELog' `wgt' , `noconstant'
 test `ELog'=0
noi di as txt _col(7) "Ho: Choose Linear  Model" _col(36) "=" %10.4f r(F) _col(50) "P-Value > F(1, " e(df_r) ")" _col(70) %5.4f r(p)
 scalar `bmlin'=r(F)
 scalar `bmlinp'=r(p) 
 regress `Log_Yo' `_Zo' `ELin' `wgt' , `noconstant'
 test `ELin'=0
noi di as txt _col(7) "Ho: Choose Log-Log Model" _col(36) "=" %10.4f r(F) _col(50) "P-Value > F(1, " e(df_r) ")" _col(70) %5.4f r(p) 
 scalar `bmlog'=r(F)
 scalar `bmlogp'=r(p) 
noi di _dup(75) "-"
noi di as txt " {bf:(6) Davidson-Mackinnon PE Test}"
* Test loglog vs Linear
 regress `_Yo' `_Zo' `wgt' , `noconstant'
 predict double `YhLin' 
* Test Linear vs loglog
 regress `Log_Yo' `_Zo' `wgt' , `noconstant'
 predict double `YhLog' 
 gen double `FLin'=`YhLin'-exp(`YhLog') 
 gen double `FLog'=`YhLog'-ln(`YhLin') 
* Test FLin=0 : Choose Linear Model
 regress `_Yo' `_Zo' `FLog' `wgt' , `noconstant'
 test `FLog'=0
noi di as txt _col(7) "Ho: Choose Linear  Model" _col(36) "=" %10.4f r(F) _col(50) "P-Value > F(1, " e(df_r) ")" _col(70) %5.4f r(p)
* Test FLog=0 : Choose LogLog Model
 scalar `dmlin'=r(F)
 scalar `dmlinp'=r(p) 
 regress `Log_Yo' `_Zo' `FLin' `wgt' , `noconstant'
 test `FLin'=0
noi di as txt _col(7) "Ho: Choose Log-Log Model" _col(36) "=" %10.4f r(F) _col(50) "P-Value > F(1, " e(df_r) ")" _col(70) %5.4f r(p) 
 scalar `dmlog'=r(F)
 scalar `dmlogp'=r(p) 
noi di _dup(78) "-"
 ereturn scalar r2lin=`r2lin'
 ereturn scalar llflin=`llflin'
 ereturn scalar r2log=`r2log'
 ereturn scalar llflog=`llflog'
 ereturn scalar r2lina=`r2lina'
 ereturn scalar r2loga=`r2loga'
 ereturn scalar bcox=`bcox'
 ereturn scalar bcoxp=`bcoxp'
 ereturn scalar bmlin=`bmlin'
 ereturn scalar bmlinp=`bmlinp'
 ereturn scalar bmlog=`bmlog'
 ereturn scalar bmlogp=`bmlogp'
 ereturn scalar dmlin=`dmlin'
 ereturn scalar dmlinp=`dmlinp'
 ereturn scalar dmlog=`dmlog'
 ereturn scalar dmlogp=`dmlogp'
 }
 }
 end

 program define LMUtest
 version 11.2
 syntax varlist(ts) , Level(cilevel) depname(str)
 gettoken yvar : varlist
 local testu =(100-`level')/100
 if `testu' < r(p_Z) { 
noi di as err "* {it:Since [`testu' < " %5.4f r(p_Z) "]: " _col(27) "Variable (`depname') has Non Stationary (Unit Roots)}"
 }
 if `testu' > r(p_Z) { 
noi di as txt "* {it:Since [`testu' > " %5.4f r(p_Z) "]: " _col(27) "Variable (`depname') has Stationary Process}"
 }
noi di as txt "{hline 78}"
 end


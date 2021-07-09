 program define spregcs37 , eclass 
 version 11.2
 syntax varlist , [WMFile(str) LL(real 0) Model(str) aux(str) wsxi(str) wsyi(str) ///
 reset vce(passthru) LMIden LMHet LMSPac var2(str) ENDOG(str) exog(str) wit(str) ///
 INST(str) ORDer(int 1) LMCl tech(str) iter(int 100) tobit tolog sig diag ///
 NOCONStant NOCONEXOG HAUSman run(str) LMForm TESTs NWmat(str) usp(str) LMNorm] 

 qui {
 tempvar DY_ DX_ absE Bw D DE LDF1 DumE E E2 E3 E4 EDumE EE Eo Es _Yo _Zo
 tempvar Ev Ew Hat ht idv itv LDE LE LEo LnE2 LYh2 P Q Sig2 SSE
 tempvar Time tm U U2 Ue Ue_ Ue_1 uiv wald weit Wi Wio X X0 VN
 tempvar Xb XB Yb Yh Yh2 Yhb Yho Yho2 Yt YY Z Yhr Etd Etk Yh_MLo Ue_MLo
 tempname A B b B1 b1 B12 B1b B1t b2 Bm Bt Bv Bv1 Bx D den Dx Yh_MLo Ue_MLo
 tempname E E1 EE1 Eg Eo Eom Ew F h Hat hjm idv itv J K L lf lmhs Ls M M1 M2
 tempname NEB nw Omega P Phi Pm q Q Qr q1 q2 Qrq Rho RX RY mh n NE Y Yh Bx_SP
 tempname S11 S12 sd Sig2 Sn SSE Sw Ue Ue_ Ue_1 V1 WMTD B1B2 V1V2 XQX_ VN
 tempname v1 V1s v2 VaL Yh_ML Ue_ML Vec vh VM VP VQ Vs W WY X X0 XB Xg s eVec
 tempname W1 Wald We Wi Wi1 Wio Yi Z Z0 Z1 Zo wmat D WW Y E N R20 Wis Ue_SP
 tempname A xAx xAx2 wWw1 B xBx WY WXb IN M xMx llf kaux kmhet kb kx DF Nn
 tempname SSEo Sig2o Sig2n AIC LAIC FPE SC LSC HQ Rice Shibata GCV kbm kmhet kb 

 gettoken yvar xvar  : varlist
 gettoken yvar xvar1 : varlist
 local varlist1 `varlist'
 gettoken yvar xvar1 : varlist1

 if "`var2'"!="" {
 local varlist2 `var2'
 gettoken endg xvar2 : varlist2
 }
 if inlist("`model'", "gs2sls", "gs2slsar") & inlist("`run'", "gmm") {
 tempname lmihj dfgmm lmihjp
 scalar `lmihj'=e(lmihj)
 scalar `dfgmm'=e(dfgmm)
 scalar `lmihjp'=e(lmihjp)
 }
 gen `Time'=_n 
 tsset `Time'
 matrix `Y'=e(Y)
 matrix `Z'=e(Z)
 matrix `Wis'=e(Wis)
 matrix `Bx'=e(Bxx)'
 matrix `Yh_ML' =e(Yh_ML)
 matrix `Ue_ML' =e(Ue_ML)
 matrix `Yh_MLo' =e(Yh_MLo)
 matrix `Ue_MLo' =e(Ue_MLo)
 if inlist("`model'", "sarariv","ivtobit","gs2sls","gs2slsar","gs3sls","gs3slsar","sdm","durbin","mstard") {
 local WsXi=e(WsXi)
 }
 local _Yo=e(_Yo)
 local _Zo=e(_Zo)
 local _Yw=e(_Yw)
 local _Zw=e(_Zw)
 local Zo=e(Zo)
 if "`log'" != "" {
 local qui quietly
 }
 local llt=spat_llt
 local kaux=e(kaux)
 local kmhet=e(kmhet)
 local kb=e(kb)
 local kx =e(kx)
 local DF=e(DF)
 local N=e(Nn)
 local R20=e(R20)
 local N=e(N)
 if inlist("`model'", "lag", "gs2sls", "gs2slsar", "gs3sls", "gs3slsar", "ivtobit", "sarariv") {
 unab WsYi: `wsyi'
 unab exog: `exog'
 }
 if inlist("`model'", "gs3sls", "gs3slsar") {
 local y1 "`yvar'"
 local y2 "`endg'"
 }
 mata: `Yh_ML' = st_matrix("`Yh_ML'")
 getmata `Yh_ML' , force replace
 mata: `Ue_ML' = st_matrix("`Ue_ML'")
 getmata `Ue_ML' , force replace
 mata: `Yh_MLo' = st_matrix("`Yh_MLo'")
 getmata `Yh_MLo' , force replace
 mata: `Ue_MLo' = st_matrix("`Ue_MLo'")
 getmata `Ue_MLo' , force replace
 gen `X0'=1 
 mkmat `X0' , matrix(`X0')
 matrix `SSE'=`Ue_ML''*`Ue_ML'
 scalar `SSEo'=`SSE'[1,1]
 scalar `Sig2o'=`SSEo'/`DF'
 scalar `Sig2n'=`SSEo'/`N'
 local k0=1
 local k =0
 if "`noconstant'"!="" | "`noconexog'"!="" {
 local nocons "noconstant"
 local k0=0
 }

 if "`model'"!="" & "`diag'"!= "" {
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:*** {err:Spatial Model Selection Diagnostic Criteria}" _col(60) "{bf:(Model= {err:`model'})}}"
noi di _dup(78) "{bf:{err:=}}"
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
 ereturn scalar llf = e(llf)
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
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:*** {err:Spatial Aautocorrelation Tests}" _col(60) "{bf:(Model= {err:`model'})}}"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt _col(2) "{bf: Ho: Error has No Spatial AutoCorrelation}"
noi di as txt _col(2) "{bf: Ha: Error has    Spatial AutoCorrelation}"
noi di _dup(72) "-"
 tempname B0 B1 B2 b2k B3 B4 chi21 chi22 DEN DIM E EI Ein Esp eWe
 tempname I m1k m2k m3k m4k MEAN NUM NUM1 NUM2 NUM3 RJ SSEN Sig2n1 SSEo1
 tempname S0 S1 S2 sd SEI SG0 SG1 TRa1 TRa2 trb TRw2 VI wi wj wMw wMw1
 tempname WZ0 Xk NUM Zk m2 m4 b2 M eWe1 wWw2 zWz eWy eWy1 CPX SUM DFr
 tempvar WZ0 Vm2 Vm4
 gen double `E' = `usp'
 mkmat `E' , matrix(`E')
 matrix `Bx_SP'=e(Bx_SP)'
 matrix `wmat'=_WB
 scalar `DFr'=`N'-`kb'
 scalar `S1'=0
 forvalue i = 1/`N' {
 forvalue j = 1/`N' {
 scalar `S1'=`S1'+(`wmat'[`i',`j']+`wmat'[`j',`i'])^2
 local j=`j'+1
 }
 }
 matrix `zWz'=`X0''*`wmat'*`X0'
 scalar `S0'=`zWz'[1,1]
 scalar `SG0'=`S0'*2
 matrix `WZ0' =`wmat'*`X0'
 mata: `WZ0' = st_matrix("`WZ0'")
 getmata `WZ0' , force replace
 replace `WZ0'=(`WZ0'+`WZ0')^2 
 summ `WZ0'
 scalar `SG1'=r(sum)
 matrix `SSEN'=`E''*`E'
 scalar `SSEo1'=`SSEN'[1,1]
 scalar `Sig2n1'=`SSEo1'/`N'
 matrix `eWe'=`E''*`wmat'*`E'
 scalar `eWe1'=`eWe'[1,1]
 matrix `CPX'=`Z''*`Z'
 matrix `A'=inv(`CPX')
 matrix `xAx'=`A'*`Z''*`wmat'*`Z'
 scalar `TRa1'=trace(`xAx')
 matrix `xAx2'=`xAx'*`xAx'
 scalar `TRa2'=trace(`xAx2')
 matrix `wWw1'=(`wmat'+`wmat'')*(`wmat'+`wmat'')
 matrix `B'=inv(`CPX')
 matrix `xBx'=`B'*`Z''*`wWw1'*`Z'
 scalar `trb'=trace(`xBx')
 scalar `VI'=(`N'^2/(`N'^2*`DFr'*(2+`DFr')))*((`S1'/2)+2*`TRa2'-`trb'-2*`TRa1'^2/`DFr')
 scalar `SEI'=sqrt(`VI')
 scalar `I'=(`N'/`S0')*`eWe1'/`SSEo1'
 scalar `EI'=-(`N'*`TRa1')/(`DFr'*`N')
 ereturn scalar mi1=(`I'-`EI')/`SEI'
 ereturn scalar mi1p=2*(1-normal(abs(e(mi1))))
 matrix `wWw2'=`wmat''*`wmat'+`wmat'*`wmat'
 scalar `TRw2'=trace(`wWw2')
 matrix `WY'=`wmat'*`Y'
 matrix `eWy'=`E''*`WY'
 scalar `eWy1'=`eWy'[1,1]
 matrix `WXb'=`wmat'*`Z'*`Bx_SP'
 matrix `IN'=I(`N')
 matrix `M'=inv(`CPX')
 matrix `xMx'=`IN'-`Z'*`M'*`Z''
 matrix `wMw'=`WXb''*`xMx'*`WXb'
 scalar `wMw1'=`wMw'[1,1]
 scalar `RJ'=1/(`TRw2'+`wMw1'/`Sig2n1')
 ereturn scalar lmerr=((`eWe1'/`Sig2n1')^2)/`TRw2'
 ereturn scalar lmlag=((`eWy1'/`Sig2n1')^2)/(`TRw2'+`wMw1'/`Sig2n1') 
 ereturn scalar lmerrr=(`eWe1'/`Sig2n1'-`TRw2'*`RJ'*(`eWy1'/`Sig2n1'))^2/(`TRw2'-`TRw2' *`TRw2'*`RJ')
 ereturn scalar lmlagr=(`eWy1'/`Sig2n1'-`eWe1'/`Sig2n1')^2/((1/`RJ')-`TRw2')
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
 gen double `EQsq' = `Ue_ML'^`j'
 summ `EQsq' , mean 
 matrix `M'[1,`j'] = r(sum)
 local j=`j'+1
 }
 summ `E' , mean
 scalar `MEAN'=r(mean)
 replace `E'=`E'-`MEAN' 
 gen double `Vm2'=`E'^2 
 summ `Vm2' , mean
 matrix `m2'[1,1]=r(mean)	
 scalar `m2k'=r(mean)
 gen double `Vm4'=`E'^4
 summ `Vm4' , mean
 matrix `m4'[1,1]=r(mean)	
 scalar `m4k'=r(mean)
 matrix `b2'[1,1]=`m4k'/(`m2k'^2)
 mkmat `E' , matrix(`E')
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
 matrix `Zk'=`E'[1...,1]
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
 matrix `Zk'=`E'[1...,1]
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
 matrix `Xk'=`E'[1...,1]
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
noi di as txt "- GLOBAL Moran MI" _col(30) "=" %9.4f e(mig) _col(45) "P-Value > Z(" %6.3f e(migz) ")" _col(67) %5.4f e(migp)
noi di as txt "- GLOBAL Geary GC" _col(30) "=" %9.4f e(gcg) _col(45) "P-Value > Z(" %5.3f e(gcgz) ")" _col(67) %5.4f e(gcgp)
noi di as txt "- GLOBAL Getis-Ords GO" _col(30) "=" %9.4f e(gog) _col(45) "P-Value > Z(" %5.3f e(gogz) ")" _col(67) %5.4f e(gogp)
noi di _dup(78) "-"
noi di as txt "- Moran MI Error Test" _col(30) "=" %9.4f e(mi1) _col(45) "P-Value > Z(" %5.3f e(mi1z) ")" _col(67) %5.4f e(mi1p)
noi di _dup(78) "-"
noi di as txt "- LM Error (Burridge)" _col(30) "=" %9.4f e(lmerr) _col(45) "P-Value > Chi2(1)" _col(67) %5.4f e(lmerrp)
noi di as txt "- LM Error (Robust)" _col(30) "=" %9.4f e(lmerrr) _col(45) "P-Value > Chi2(1)" _col(67) %5.4f e(lmerrrp)
noi di _dup(78) "-"
noi di as txt _col(2) "{bf: Ho: Spatial Lagged Dependent Variable has No Spatial AutoCorrelation}"
noi di as txt _col(2) "{bf: Ha: Spatial Lagged Dependent Variable has    Spatial AutoCorrelation}"
noi di _dup(72) "-"
noi di as txt "- LM Lag (Anselin)" _col(30) "=" %9.4f e(lmlag) _col(45) "P-Value > Chi2(1)" _col(67) %5.4f e(lmlagp)
noi di as txt "- LM Lag (Robust)" _col(30) "=" %9.4f e(lmlagr) _col(45) "P-Value > Chi2(1)" _col(67) %5.4f e(lmlagrp)
noi di _dup(78) "-"
noi di as txt _col(2) "{bf: Ho: No General Spatial AutoCorrelation}"
noi di as txt _col(2) "{bf: Ha:    General Spatial AutoCorrelation}"
noi di _dup(72) "-"
noi di as txt "- LM SAC (LMErr+LMLag_R)" _col(30) "=" %9.4f e(lmsac2) _col(45) "P-Value > Chi2(2)" _col(67) %5.4f e(lmsac2p)
noi di as txt "- LM SAC (LMLag+LMErr_R)" _col(30) "=" %9.4f e(lmsac1) _col(45) "P-Value > Chi2(2)" _col(67) %5.4f e(lmsac1p)
noi di _dup(78) "-"
 }

 if "`model'"!="" & "`lmhet'"!= "" {
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:*** {err:Spatial Heteroscedasticity Tests}" _col(60) "{bf:(Model= {err:`model'})}}"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf: Ho: Homoscedasticity - Ha: Heteroscedasticity}"
noi di _dup(78) "-"
 tempname Eb2 Eb4 lmhmss1 lmhmss1p mssdf1 lmhmss2 lmhmss2p mssdf2 dfw0
 tempname lmhw01 lmhw01p lmhw02 lmhw02p dfw1 lmhw11 lmhw11p lmhw12 lmhw12p dfw2
 tempname lmhw21 lmhw21p lmhw22 lmhw22p lmhharv lmhharvp lmhwald lmhwaldp lmhhp1
 tempname lmhhp1p lmhhp2 lmhhp2p lmhhp3 lmhhp3p lmhgl lmhglp lmhcw1 cwdf1 lmhcw1p
 tempname lmhcw2 cwdf2 lmhcw2p LMh_cwx mh vh h Q
 tempvar Yh2 U2 E2 E3 E4 E Yh XQ
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
 regress `EDumE' `_Zo' , `nocons'
 scalar `lmhmss2'=e(N)*e(r2)
 scalar `lmhmss2p'=chi2tail(e(df_m), abs(`lmhmss2'))
 scalar `mssdf2'=e(df_m)
 cap drop `XQ'*
 local nX : word count `_Zo'
 forvalue i=1/`nX' {
 local v: word `i' of `_Zo'
 gen double `XQ'`i'`i' = `v'*`v' 
 } 
 regress `E2' `_Zo' , `nocons'
 scalar `dfw0'=e(df_m)
 scalar `lmhw01'=e(r2)*e(N)
 scalar `lmhw01p'= chi2tail(`dfw0' , abs(`lmhw01'))
 scalar `lmhw02'=e(mss)/(2*`Sig2n'^2)
 scalar `lmhw02p'= chi2tail(`dfw0' , abs(`lmhw02'))
 regress `E2' `_Zo' `XQ'* , `nocons'
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
 regress `E2' `_Zo' `XQ'* , `nocons'
 scalar `dfw2'=e(df_m)
 scalar `lmhw21'=e(r2)*e(N)
 scalar `lmhw21p'= chi2tail(`dfw2' , abs(`lmhw21'))
 scalar `lmhw22'=e(mss)/(2*`Sig2n'^2)
 scalar `lmhw22p'= chi2tail(`dfw2' , abs(`lmhw22'))
 regress `LnE2' `_Zo' , `nocons'
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
 regress `absE' `_Zo' , `nocons'
 scalar `lmhgl'=e(mss)/((1-2/_pi)*`Sig2n')
 scalar `lmhglp'= chi2tail(2, abs(`lmhgl'))
 regress `U2' `Yh' 
 scalar `lmhcw1'= e(mss)/2
 scalar `cwdf1'= e(df_m)
 scalar `lmhcw1p'= chi2tail(`cwdf1', abs(`lmhcw1'))
 regress `U2' `_Zo' , `nocons'
 scalar `lmhcw2'= e(mss)/2
 scalar `cwdf2'= e(df_m)
 scalar `lmhcw2p'= chi2tail(`cwdf2', abs(`lmhcw2'))
noi di as txt "- Hall-Pagan LM Test:      E2 = Yh" _col(40) "=" %9.4f `lmhhp1' _col(53) " P-Value > Chi2(1)" _col(73) %5.4f `lmhhp1p'
noi di as txt "- Hall-Pagan LM Test:      E2 = Yh2" _col(40) "=" %9.4f `lmhhp2' _col(53) " P-Value > Chi2(1)" _col(73) %5.4f `lmhhp2p'
noi di as txt "- Hall-Pagan LM Test:      E2 = LYh2" _col(40) "=" %9.4f `lmhhp3' _col(53) " P-Value > Chi2(1)" _col(73) %5.4f `lmhhp3p'
noi di _dup(78) "-"
noi di as txt "- Harvey LM Test:       LogE2 = X" _col(40) "=" %9.4f `lmhharv' _col(53) " P-Value > Chi2(2)" _col(73) %5.4f `lmhharvp'
noi di as txt "- Wald LM Test:         LogE2 = X " _col(40) "=" %9.4f `lmhwald' _col(53) " P-Value > Chi2(1)" _col(73) %5.4f `lmhwaldp'
noi di as txt "- Glejser LM Test:        |E| = X" _col(40) "=" %9.4f `lmhgl' _col(53) " P-Value > Chi2(2)" _col(73) %5.4f `lmhglp'
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
noi di as txt "*** Single Variable Tests: ***"
 regress `_Yo' `_Zo' , `nocons'
 tokenize `_Zo'
noi di as txt "* Cook-Weisberg LM Test: E2/Sig2" 
 forvalue j=1/`nX' {
 local i: word `j' of `_Zo'
 regress `U2' `i'
 scalar `LMh_cwx'`j' = e(mss)/2
 ereturn scalar lmhcwx`j'= `LMh_cwx'`j'
 ereturn scalar lmhcwxp`j'= chi2tail(1 , abs(`LMh_cwx'`j'))
noi di as txt "- `i'" _col(40) "=" %9.4f e(lmhcwx`j') _col(53) " P-Value > Chi2(1)" _col(73) %5.4f e(lmhcwxp`j')
 }
noi di _dup(78) "-"
noi di as txt "* King LM Test:"
 forvalue j=1/`nX' {
 local i: word `j' of `_Zo'
 tempvar `ht'`j'
 egen `ht'`j' = rank(`i') 
 summ `ht'`j' 
 scalar `mh' = r(mean)
 scalar `vh' = r(Var)
 summ `ht'`j' [aw=`E'^2] , meanonly
 scalar `h' = r(mean)
 ereturn scalar lmhq_`j'= (`N'^2 / (2*(`N'-1))) * (`h'-`mh')^2/`vh'
 ereturn scalar lmhqp_`j'= chi2tail(1, abs(e(lmhq_`j')))
noi di as txt "- `i'" _col(40) "=" %9.4f e(lmhq_`j') _col(53) " P-Value > Chi2(1)" _col(73) %5.4f e(lmhqp_`j')
 }
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
 ereturn scalar lmhmss2p= `lmhmss2p'
 ereturn scalar lmhmss2= `lmhmss2p'
 ereturn scalar lmhmss1p= `lmhmss1p'
 ereturn scalar lmhmss1= `lmhmss1'
 ereturn scalar lmhhp1= `lmhhp1'
 ereturn scalar lmhhp1p= `lmhhp1p'
 ereturn scalar lmhhp2= `lmhhp2'
 ereturn scalar lmhhp2p= `lmhhp2p'
 ereturn scalar lmhhp3= `lmhhp3'
 ereturn scalar lmhhp3p= `lmhhp3p'
 }

 if "`xvar'"!="" {
 if "`model'"!="" & "`lmnorm'"!="" {
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:*** {err:Spatial Non Normality Tests}" _col(60) "{bf:(Model= {err:`model'})}}"
noi di _dup(78) "{bf:{err:=}}"
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

 if "`tests'"!="" {
 tempname K B XBM XB E E2 Sig XBs Es Eg Gz Eg3 Eg4
 tempname ImR D0 D1 DB DS U3 U4 M1 M2 DB0 XBX SigV SigV2 Yh SigM H kxt
 tempvar EXwXw AM SSE YYR R2Raw
 scalar `kxt' = `kx'
 tsset `Time'
 tobit `_Yo' `_Zo' `wgt' , nolog ll(`llt') `nocons'
 predict double `XBX' , xb
 local k = `kxt'
 gen double `SigV'=_b[/sigma]
 gen double `E'=`_Yo'-`XBX' 
 gen double `SigV2'= `SigV'^2 
 gen double `XBs'= `XBX'/`SigV' 
 gen double `Es'= `E'/`SigV' 
 gen double `ImR'=normalden(`XBs')/(1-normal(`XBs')) 
 replace `ImR'=0 if `ImR' == .
 gen double `D0'=0 
 gen double `D1'=0 
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
 tempname SSE YYR lmnci NR2 
 tempvar dfdb dfds B  Sig XB XBs Es u1 u2 u3 u4
 scalar `SSE'=e(rss)
 scalar `YYR'=_N
 scalar `R2Raw'=1-(`SSE'/`YYR')
 scalar `lmnci'=`N'*`R2Raw'
 tobit `_Yo' `_Zo' `wgt' , nolog ll(`llt') `nocons'
 predict double `dfdb' `dfds' , score
 gen double `Sig'=_b[/sigma]
 predict double `XB' , xb
 gen double `XBs'=`XB'/`Sig' 
 gen double `Es'=(`_Yo'-`XB')/`Sig' 
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
 local vlist "`vlist' dfdb`j'"
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
noi di as txt "{bf:{err:*** Tobit Heteroscedasticity LM Tests}}"
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
noi di as txt "{bf:{err:*** Tobit Non Normality LM Tests}}"
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
noi di as txt _col(2) "- LM Test"  _col(33) "=" %10.4f `NR2' _col(47) "P-Value > Chi2(" `df' ")" _col(67) %5.4f chi2tail(`df', abs(`NR2'))
 }
 if `q' == 4 {
noi di as txt _col(2) "- Pagan-Vella LM Test" _col(33) "=" %10.4f `NR2' _col(47) "P-Value > Chi2(2)" _col(67) %5.4f chi2tail(2, abs(`NR2'))
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
noi di as txt _col(2) "- Chesher-Irish LM Test" _col(33) "=" %10.4f e(lmnci) _col(47) "P-Value > Chi2(2)" _col(67) %5.4f e(lmncip)
noi di _dup(78) "-"
 }
 if "`model'"!="" & "`reset'"!= "" {
 tempvar E2 Yh2 Yh3 Yh4 SSi SCi SLi CLi WL WS XQ Yh
 tempname rim
 tsset `Time'
 gen double `Yh' =`Yh_ML'
 summ `Yh' 
 local YMin = r(min)
 local YMax = r(max)
 gen double `WL'=_pi*(2*`Yh'-(`YMax'+`YMin'))/(`YMax'-`YMin') 
 gen double `WS'=2*_pi*(sin(`Yh_ML')^2)-_pi 
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:*** {bf:Spatial {err:RE}}gression {bf:{err:S}}pecification {bf:{err:E}}rror {bf:{err:T}}ests (RESET)" _col(60) "Model= ({bf:{err:`model'})}}"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf: Ho: Model is Specified  -  Ha: Model is Misspecified}"
noi di _dup(78) "-"
noi di as txt "{bf:* Ramsey Specification ResetF Test}"
 forvalue i=2/4 {
 tempvar Yhrm`i'
 gen double `Yhr'_`i'=`Yh'^`i'
 if !inlist("`model'", "sarariv", "ivtobit", "gs2sls", "gs2slsar", "gs3sls", "gs3slsar") {
 regress `_Yo' `_Zo' `wgt' `Yhr'_* , `nocons'
 } 
 if inlist("`model'", "sarariv", "ivtobit", "gs2sls", "gs2slsar") {
 if inlist("`run'", "2sls", "liml", "gmm") {
 ivregress `run' `_Yo' `exog' `Yhr'_* (`WsYi' = `inst') `wgt' , `nocons' small
 }
 if inlist("`run'", "melo", "kclass", "fuller") {
 ivregress liml `_Yo' `exog' `Yhr'_* (`WsYi' = `inst') `wgt' , `nocons' small
 }
 }
 if inlist("`model'", "gs3sls", "gs3slsar") {
 ivregress 2sls `_Yo' `exog' `Yhr'_* (`WsYi' = `inst') `wgt' , `nocons' small
 }
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
 if !inlist("`model'", "sarariv", "ivtobit", "gs2sls", "gs2slsar", "gs3sls", "gs3slsar") {
 regress `_Yo' `_Zo' `wgt' `SLi'* `CLi'* , `nocons'
 } 
 if inlist("`model'", "sarariv", "ivtobit", "gs2sls", "gs2slsar") {
 if inlist("`run'", "2sls", "liml", "gmm") {
 ivregress `run' `_Yo' `exog' `SLi'* `CLi'* (`WsYi' = `inst') `wgt' , `nocons' small
 }
 if inlist("`run'", "melo", "kclass", "fuller") {
 ivregress liml `_Yo' `exog' `SLi'* `CLi'* (`WsYi' = `inst') `wgt' , `nocons' small
 }
 }
 if inlist("`model'", "gs3sls", "gs3slsar") {
 ivregress 2sls `_Yo' `exog' `SLi'* `CLi'* (`WsYi' = `inst') `wgt' , `nocons' small
 }
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
 if !inlist("`model'", "sarariv", "ivtobit", "gs2sls", "gs2slsar", "gs3sls", "gs3slsar") {
 regress `_Yo' `_Zo' `wgt' `SSi'* `SCi'* , `nocons'
 } 
 if inlist("`model'", "sarariv", "ivtobit", "gs2sls", "gs2slsar") {
 if inlist("`run'", "2sls", "liml", "gmm") {
 ivregress `run' `_Yo' `exog' `SSi'* `SCi'* (`WsYi' = `inst') `wgt' , `nocons' small
 }
 if inlist("`run'", "melo", "kclass", "fuller") {
 ivregress liml `_Yo' `exog' `SSi'* `SCi'* (`WsYi' = `inst') `wgt' , `nocons' small
 }
 }
 if inlist("`model'", "gs3sls", "gs3slsar") {
 ivregress 2sls `_Yo' `exog' `SSi'* `SCi'* (`WsYi' = `inst') `wgt' , `nocons' small
 }
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

 if inlist("`model'", "gs2sls", "gs2slsar", "sarariv", "ivtobit") & "`hausman'"!="" {
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:*** Spatial Hausman Specification Test {bf:({err:OLS}} vs {bf:{err:IV-2SLS})}" _col(60) "{bf:(Model= {err:`model'})}}"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf: Ho: (Biv) Consistent  * Ha: (Bo) InConsistent}"
noi di as txt "{bf: LM = (Bo-Biv)'inv(Vo-Viv)*(Bo-Biv)}"
noi di as txt "{bf: [Low/(High*)] Hausman Test = [Biv/(Bo*)] Model}"
 tsset `Time'
 tempname kxk DFr lmhs1 lmhsp
 regress `_Yo' `_Zo' `wgt' , `nocons' `vce'
 scalar `kxk' =`kx'
 matrix `b1'=e(b)'
 matrix `v1'=e(V)
 matrix `b1'=`b1'[1..`kxk', 1..1]
 matrix `v1'=`v1'[1..`kxk', 1..`kxk']
 matrix `b2'=biv2'
 matrix `b2'= `b2'[1..`kxk', 1..1]
 matrix `v2'= viv2[1..`kxk', 1..`kxk']
 matrix `B1B2'=`b2'-`b1'
 matrix `V1V2'=`v2'-`v1'
 matrix `lmhs'=`B1B2''*invsym(`V1V2')*`B1B2'
 scalar `lmhs1'=`lmhs'[1,1]
 scalar `lmhsp'= chi2tail(1, abs(`lmhs1'))
noi di
noi di as txt " Hausman LM Test " _col(15) "=" %10.5f `lmhs1' _col(35) "P-Value > Chi2(1)" _col(55) %5.4f `lmhsp'
 ereturn scalar lmhs=`lmhs1'
 ereturn scalar lmhsp= `lmhsp'
noi di _dup(78) "-"
 }

 if inlist("`model'", "gs2sls", "gs2slsar", "gs3sls", "gs3slsar", "ivtobit", "sarariv") & "`lmiden'"!="" {
noi di 
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:*** {err:Spatial 2SLS-IV Order Condition Identification}" _col(60) "{bf:(Model= {err:`model'})}}"
noi di _dup(78) "{bf:{err:=}}"

 tempvar Zhin Zhout
 tempname Xg X Z Yy W1 W2 M1 M2 WY lamp lamp1 lamp2 W1W Lambdav Lambda kliml
 tsset `Time'
 local instx `exog' `WsXi' `inst'
 _rmcoll `instx' , `nocons' forcedrop
 local instx "`r(varlist)'"
 local kendog : word count `WsYi'
 local kexog : word count `exog'
 local kinst : word count `inst'
 local kinstx: word count `instx'
 local ky =1
 local lrdf= `kinst'-`kendog'
 if inlist("`model'", "sarariv", "ivtobit", "gs2sls", "gs2slsar") {
 if inlist("`run'", "2sls", "liml", "gmm") {
 ivregress `run' `_Yo' `exog' (`WsYi' = `inst') `wgt' , `nocons' small
 }
 if inlist("`run'", "melo", "kclass", "fuller") {
 ivregress liml `_Yo' `exog' (`WsYi' = `inst') `wgt' , `nocons' small
 }
 }
 if inlist("`model'", "gs3sls", "gs3slsar") {
 ivregress 2sls `_Yo' `exog' (`WsYi' = `inst') `wgt' , `nocons' small
 }
 predict double `Zhin' , xb
 matrix `Bv1'=e(b)
 matrix `Bv'=-`Bv1'[1, 1..`kendog']
 matrix `Bv'=1 \ `Bv''
noi di "* `_Yo' `exog' (`WsYi' = `inst')"
noi di _dup(78) "-"
noi di as txt "{bf:** Y  = LHS Dependent Variable}
noi di as txt "   " `ky' " : " "`_Yo'"
noi di as txt "{bf:** Yi = RHS Endogenous Variables}
noi di as txt "   " `kendog' " : " "`WsYi'"
noi di as txt "{bf:** Xi = RHS Included Exogenous Variables}"
noi di as txt "   " `kexog' " : " "`exog'"
noi di as txt "{bf:** Xj = RHS Excluded Exogenous Variables (Additional Instrumental Variables)}"
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
 if `kinstx' > `kx' {
noi di as txt "{bf: Model is Over Identification:}"
noi di as txt _col(7) "Z(" `kinstx' ")" " > Yi + Xi (" `kx' ")"
noi di as txt "* since: Z > Yi + Xi : it is recommended to use (2SLS-LIML-MELO-3SLS-FIML)"
 tsset `Time'
 local dfs=`kinst'-`kendog'
 local dfr=`N'-`kx'
 local dfu=`N'-`kinstx'
 tempvar E E2
 gen double `E'=`Ue_ML' 
 gen double `E2'=`Ue_ML'^2 
 summ `E2' 
 local SSE = r(sum)
 regress `Ue_ML' `instx' `wgt'
 if "`noconstant'"!="" {
 cap mkmat `exog' , matrix(`Xg')
 cap mkmat `exog' `inst' `X0' , matrix(`X')
 cap mkmat `WsYi' `exog' , matrix(`Z')
 }
 else if "`noconexog'"!="" {
 cap mkmat `exog' , matrix(`Xg')
 cap mkmat `exog' `inst' , matrix(`X')
 cap mkmat `WsYi' `exog' , matrix(`Z')
 }
 else { 
 if "`noconexog'"=="" | "`noconstant'"=="" {
 cap mkmat `exog' `X0' , matrix(`Xg')
 cap mkmat `exog' `inst' `X0' , matrix(`X')
 cap mkmat `WsYi' `exog' `X0' , matrix(`Z')
 }
 }
 mkmat `_Yo' `WsYi' , matrix(`Yy')
 mkmat `wit' , matrix(`Wi')
 matrix `Wi'= diag(`Wi')
 matrix `WY'=`Wi'*`Yy'
 matrix `M1'=I(`N')
 matrix `M2'=I(`N')
 if `kexog' >= 1 {
 matrix `M1'=I(`N')-`Wi'*`Xg'*invsym(`Xg''*`Wi''*`Wi'*`Xg')*`Xg''*`Wi''
 }
 if `kinst' >= 1 {
 matrix `M2'=I(`N')-`Wi'*`X'*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''
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
 local lmih1 =`N'*e(r2)
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
noi di as txt "{bf:*** {err:Spatial 2SLS-IV Over Identification Restrictions Tests}" _col(60) "{bf:(Model= {err:`model'})}}"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf: Ho: Valid Included & Excluded Instruments ; RHS Not Correlated with Error Term}"
noi di _dup(78) "-"
 if inlist("`model'", "gs2sls", "gs2slsar") & inlist("`run'", "gmm") {
noi di as txt " - Hansen J Test" _col(28) "=" %10.5f `lmihj' _col(43) "P-Value > Chi2(" `dfs' ")" _col(65) %5.4f `lmihjp'
noi di _dup(78) "-"
 }
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
 local kxx =`kinst'+`kexog'
 local kxy =`kinst'+`kendog'
 if `kxy' < `kxx' {
 if inlist("`model'", "sarariv", "ivtobit", "gs2sls", "gs2slsar") {
 if inlist("`run'", "2sls", "liml", "gmm") {
 ivregress `run' `_Yo' `inst' (`WsYi' = `exog') `wgt' , `nocons' small
 }
 if inlist("`run'", "melo", "kclass", "fuller") {
 ivregress liml `_Yo' `inst' (`WsYi' = `exog') `wgt' , `nocons' small
 }
 }
 if inlist("`model'", "gs3sls", "gs3slsar") {
 ivregress 2sls `_Yo' `inst' (`WsYi' = `exog') `wgt' , `nocons' small
 }
 predict double `Zhout' , xb
 regress `_Yo' `Zhin' `Zhout' `wgt' , `nocons' 
 test `Zhout'=0
noi di as txt " - Spencer-Berk F Test" _col(28) "=" %10.5f r(F) _col(43) "P-Value > F(" r(df) " , " r(df_r) ")" _col(65) %5.4f r(p)
noi di _dup(78) "-"
 ereturn scalar lmisbfp=r(p)
 ereturn scalar lmisbf=r(F)
 }
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

 if "`model'"!="" & "`lmform'"!= "" {
noi di 
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:*** {err:Spatial Linear vs Log-Linear Functional Form Tests}" _col(60) "{bf:(Model= {err:`model'})}}"
noi di _dup(78) "{bf:{err:=}}"
 tempname SSELin llflin r2lin r2log YbG SumLY llflog SSELog r2loga boxcox
 tempname boxcoxp bmlin bmlinp bmlog bmlogp dmlin dmlinp dmlog dmlogp r2lina
 tempvar logYh LOGyvar E E2 Yh LYh ELYh ELin ELog YhLin YhLog FLin FLog _Yo1
 gen double `_Yo1'= `_Yo'
 if "`tolog'"!="" {
 replace `_Yo1'= exp(`_Yo')
 }
 tsset `Time'
 local _Yo1 "`_Yo1'"
 local _Zo "`_Zo'"
 local exog "`xvar' `aux'"
 if !inlist("`model'", "sarariv", "ivtobit", "gs2sls", "gs2slsar", "gs3sls", "gs3slsar") {
 regress `_Yo1' `_Zo' `wgt' , `nocons'
 } 
 if inlist("`model'", "sarariv", "ivtobit", "gs2sls", "gs2slsar") {
 if inlist("`run'", "2sls", "liml", "gmm") {
 ivregress `run' `_Yo1' `exog' (`WsYi' = `inst') `wgt' , `nocons' small
 }
 if inlist("`run'", "melo", "kclass", "fuller") {
 ivregress liml `_Yo1' `exog' (`WsYi' = `inst') `wgt' , `nocons' small
 }
 }
 if inlist("`model'", "gs3sls", "gs3slsar") {
 ivregress 2sls `_Yo1' `exog' (`WsYi' = `inst') `wgt' , `nocons' small
 }
 scalar `SSELin'=e(rss)
 scalar `llflin'=-(`N'/2)*ln(2*_pi*(`SSELin'/`N'))-(`N'/2)
 scalar `r2lin'=e(r2)
 predict `E' , res
 gen double `E2'=`E'*`E' 
 predict `Yh' 
 if `r2lin'==. {
 correlate `Yh' `_Yo1'
 scalar `r2lin'=r(rho)*r(rho)
 }
 gen double `logYh'=ln(`Yh') 
 gen double `LOGyvar' = ln(`_Yo1') 
 if !inlist("`model'", "sarariv", "ivtobit", "gs2sls", "gs2slsar", "gs3sls", "gs3slsar") {
 regress `LOGyvar' `_Zo' `wgt' , `nocons'
 }
 if inlist("`model'", "sarariv", "ivtobit", "gs2sls", "gs2slsar") {
 if inlist("`run'", "2sls", "liml", "gmm") {
 ivregress `run' `LOGyvar' `exog' (`WsYi' = `inst') `wgt' , `nocons' small
 }
 if inlist("`run'", "melo", "kclass", "fuller") {
 ivregress liml `LOGyvar' `exog' (`WsYi' = `inst') `wgt' , `nocons' small
 }
 }
 if inlist("`model'", "gs3sls", "gs3slsar") {
 ivregress 2sls `LOGyvar' `exog' (`WsYi' = `inst') `wgt' , `nocons' small
 }
 scalar `r2log'=e(r2)
 predict `LYh' 
 if `r2log'==. {
 correlate `LYh' `LOGyvar'
 scalar `r2log'=r(rho)*r(rho)
 }
 scalar `SSELog'=e(rss) 
 summ `LOGyvar' 
 scalar `YbG'=exp(r(mean))
 scalar `SumLY'=r(sum)
 scalar `llflog'=-(`N'/2)*ln(2*_pi*(`SSELog'/`N'))-(`N'/2)-`SumLY'
noi di as txt " {bf:(1) R-squared}"
noi di as txt _col(7) "Linear  R2" _col(36) "=" %10.4f `r2lin'
noi di as txt _col(7) "Log-Log R2" _col(36) "=" %10.4f `r2log'
noi di _dup(78) "-"
noi di as txt " {bf:(2) Log Likelihood Function (LLF)}"
noi di as txt _col(7) "LLF - Linear" _col(36) "=" %10.4f `llflin'
noi di as txt _col(7) "LLF - Log-Log" _col(36) "=" %10.4f `llflog'
noi di _dup(78) "-"
noi di as txt " {bf:(3) Antilog R2}"
 regress `LOGyvar' `_Zo' `wgt' , `nocons'
 scalar `SSELog'=e(rss)
 gen double `ELYh'=exp(`LYh') 
 regress `ELYh' `_Yo1'
 scalar `r2lina'=e(r2)
 regress `logYh' `LOGyvar'
 scalar `r2loga'=e(r2)
noi di as txt _col(7) "Linear  vs Log-Log: R2Lin" _col(36) "=" %10.4f `r2lina'
noi di as txt _col(7) "Log-Log vs Linear : R2log" _col(36) "=" %10.4f `r2loga'
noi di _dup(78) "-"
 scalar `boxcox'=e(N)/2*abs(ln((`SSELin'/`YbG'^2)/`SSELog'))
 scalar `boxcoxp'=chi2tail(1, abs(`boxcox'))
noi di as txt" {bf:(4) Box-Cox Test}" _col(36) "=" %10.4f `boxcox' _col(50) "P-Value > Chi2(1)" _col(70) %5.4f `boxcoxp'
noi di as txt _col(7) "Ho: Choose Log-Log Model - Ha: Choose Linear Model"
noi di _dup(78) "-"
noi di as txt " {bf:(5) Bera-McAleer BM Test}"
 regress `ELYh' `_Zo' `wgt' , `nocons'
 predict `ELin' , res
 regress `logYh' `_Zo' `wgt' , `nocons'
 predict `ELog' , res
 regress `_Yo1' `_Zo' `ELog' `wgt' , `nocons'
 test `ELog'=0
noi di as txt _col(7) "Ho: Choose Linear Model" _col(36) "=" %10.4f r(F) _col(50) "P-Value > F(1, " e(df_r) ")" _col(70) %5.4f r(p)
 scalar `bmlin'=r(F)
 scalar `bmlinp'=r(p) 
 regress `LOGyvar' `_Zo' `ELin' `wgt' , `nocons'
 test `ELin'=0
noi di as txt _col(7) "Ho: Choose Log-Log Model" _col(36) "=" %10.4f r(F) _col(50) "P-Value > F(1, " e(df_r) ")" _col(70) %5.4f r(p) 
 scalar `bmlog'=r(F)
 scalar `bmlogp'=r(p) 
noi di _dup(78) "-"
noi di as txt " {bf:(6) Davidson-Mackinnon PE Test}"
* Test loglog vs Linear
 regress `_Yo1' `_Zo' `wgt' , `nocons'
 predict `YhLin' 
* Test Linear vs loglog
 regress `LOGyvar' `_Zo' `wgt' , `nocons'
 predict `YhLog' 
 gen double `FLin'=`YhLin'-exp(`YhLog') 
 gen double `FLog'=`YhLog'-ln(`YhLin') 
* Test FLin=0 : Choose Linear Model
 regress `_Yo1' `_Zo' `FLog' `wgt' , `nocons'
 test `FLog'=0
noi di as txt _col(7) "Ho: Choose Linear Model" _col(36) "=" %10.4f r(F) _col(50) "P-Value > F(1, " e(df_r) ")" _col(70) %5.4f r(p)
* Test FLog=0 : Choose LogLog Model
 scalar `dmlin'=r(F)
 scalar `dmlinp'=r(p) 
 regress `LOGyvar' `_Zo' `FLin' `wgt' , `nocons'
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
 ereturn scalar boxcox=`boxcox'
 ereturn scalar boxcoxp=`boxcoxp'
 ereturn scalar bmlin=`bmlin'
 ereturn scalar bmlinp=`bmlinp'
 ereturn scalar bmlog=`bmlog'
 ereturn scalar bmlogp=`bmlogp'
 ereturn scalar dmlin=`dmlin'
 ereturn scalar dmlinp=`dmlinp'
 ereturn scalar dmlog=`dmlog'
 ereturn scalar dmlogp=`dmlogp'
 }

 if "`model'"!="" & "`lmcl'"!="" {
 if `kx' > 1 {
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:*** {err:Spatial Multicollinearity Diagnostic Tests}" _col(60) "{bf:(Model= {err:OLS})}}"
noi di _dup(78) "{bf:{err:=}}"
noi di
noi di as txt "{bf:{err:* Correlation Matrix}}"
 tempvar R2xx Rx VIFI DFF DFF1 DFF2 fgF fgFp SH6v LVal eigVaL
 tempvar eigVaLn ILVal R2oS CNmax CImax
 tempname COR VIF Vec eigVaL VIFI R2xx FGFF LDCor fg CORx fgT DCor corr
 tempname Cond X0 J S Ds Val Cr Dr LVal1 LVal SLv2 SH6v q0 q1 q2 q3 q4 q5 q6 XX
 tempname fgdf fgchi dcor1 dfm R2 R2oSs r2th Kcol Krow MaxLv MinLv SumLv SumILv
 tsset `Time'
 gen `R2xx'=0 
 gen `Rx'=0 
 gen `VIFI'=0 
 gen `DFF'=0 
 gen `DFF1'=0 
 gen `DFF2'=0 
 gen `fgF'=0 
 gen `fgFp'=0 
 local star =(1-0.`level')
 corr `_Yo' `_Zo'
 matrix `corr'=r(C)
 matrix rownames `corr' = `_Yo' `_Zo'
 matrix colnames `corr' = `_Yo' `_Zo'
noi matlist `corr', twidth(10) border(all) lines(columns) noblank rowtitle(Variable) format(%7.3f)
noi pwcorr `_Yo' `_Zo' , star(`star') `sig'
 corr `_Zo'
 matrix `COR'=r(C)'
 matrix `VIF'=vecdiag(invsym(`COR'))'
 forvalue i=1/`kx' { 
 replace `VIFI'=1/`VIF'[`i',1] in `i'
 replace `R2xx'=1-1/`VIF'[`i',1] in `i'
 }
 matrix symeigen `Vec' `eigVaL'=`COR'
 svmat double `eigVaL' , name(`eigVaL')
 rename `eigVaL'1 `eigVaL'
 mkmat `VIFI' in 1/`kx' , matrix(`VIFI')
 mkmat `R2xx' in 1/`kx' , matrix(`R2xx')
 matrix `eigVaL'=`eigVaL''
 svmat double `eigVaL' , name(`eigVaLn')
 rename `eigVaLn'1 `eigVaLn'
 summ `eigVaLn' 
 gen double `CNmax'=r(max) 
 replace `CNmax'=`CNmax'/`eigVaLn' 
 gen double `CImax'=sqrt(`CNmax') 
 mkmat `CNmax' `CImax' in 1/`kx' , matrix(`Cond')
 matrix `Cond' = `eigVaL',`Cond',`VIF',`VIFI',`R2xx'
noi di
noi di as txt "{bf:{err:* Multicollinearity Diagnostic Criteria}}"
 matrix rownames `Cond' = `_Zo'
 matrix colnames `Cond' = "Eigenval" "C_Number" "C_Index" "VIF" "1/VIF" "R2_xi,X"
noi matlist `Cond', twidth(8) border(all) lines(columns) noblank rowtitle(Variable) format(%8.4f)
 corr `_Zo' 
 matrix `COR'=r(C)'
 matrix `VIF'=vecdiag(invsym(`COR'))'
 forvalue i=1/`kx' { 
 replace `VIFI'=1/`VIF'[`i',1] in `i'
 replace `R2xx'=1-1/`VIF'[`i',1] in `i'
 replace `Rx'=`R2xx' in `i'
 replace `DFF'=(`N'-`kx')/(`kx'-1) in `i'
 replace `DFF1'=(`N'-`kx') in `i'
 replace `DFF2'=(`kx') in `i'
 replace `fgF'=`Rx'/(1-`Rx')*`DFF' in `i'
 replace `fgFp'= Ftail(`DFF1', `DFF2', `fgF') in `i'
 }
 mkmat `fgF' `DFF1' `DFF2' `fgFp' in 1/`kx' , matrix(`FGFF')
 forvalue i=1/`kx' {
 forvalue j=1/`kx' {
 cap drop `COR'`i'`j'
 tempvar COR`i'`j'
 gen `COR'`i'`j'=0 
 }
 }
 matrix `LDCor'=ln(det(`COR'))
 matrix `fg'=-(`N'-1-(((2*`kx')+5)/6))*`LDCor'
 scalar `fgdf'=0.5*`kx'*(`kx'-1)
 scalar `fgchi'=`fg'[1,1]
 forvalue i=1/`kx' {
 forvalue j=1/`kx' {
 replace `COR'`i'`j'=`COR'[`i',`j']*sqrt((e(N)-`kx'))/sqrt(1-`COR'[`i',`j']^2) in `i'
 }
 }
 forvalue i=1/`kx' {
 forvalue j=1/`kx' {
 mkmat `COR'`i'* in 1/`kx' , matrix(`CORx'`i')
 matrix `CORx'`i'[1,`kx']=`CORx'`i'[1,`kx']'
 }
 }
 forvalue i=1/`kx' {
 forvalue j=1/`kx' {
 replace `COR'1`j' = `COR'`i'`j' in `i'
 }
 }
 mkmat `COR'1* in 1/`kx' , matrix(`fgT')
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
 matrix rownames `FGFF' = `_Zo'
 matrix colnames `FGFF' = F_Test DF1 DF2 P_Value
noi matlist `FGFF', twidth(10) border(all) lines(columns) noblank rowtitle(Variable) format(%12.3f)
noi di
noi di as txt "{bf:* (3) Farrar-Glauber Multicollinearity t-Test:}"
 matrix rownames `fgT' = `_Zo'
 matrix colnames `fgT' = `_Zo'
noi matlist `fgT', twidth(10) border(all) lines(cells) noblank rowtitle(Variable) format(%9.3f)
 mkmat `_Zo' , matrix(`Z')
 corr `_Zo' 
 matrix `COR'=r(C)'
 matrix `VIF'=vecdiag(invsym(`COR'))'
 matrix symeigen `Vec' `eigVaL'=`COR'
 matrix `LDCor'=ln(det(`COR'))
 matrix `DCor'=det(`COR')
 scalar `dcor1'=`DCor'[1,1]
 local R2oSs =0
 forvalue i=1/`kx' {
 local j : word `i' of `_Zo'
 local both: list _Zo - j 
 regress `_Yo' `both' , `nocons'
 local R2oSs =`R2oSs' + e(r2)
 local R2oSs `R2oSs'
 }
 scalar `r2th'=`R20'-(`kx'*`R20'-`R2oSs')
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
 }
 }
 end

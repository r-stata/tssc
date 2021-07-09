 program define spregcs03 , eclass 
 version 11.2
 syntax [anything] , RUN(str) [NOCONStant NOCONEXOG KC(real 0) KF(real 0) TOLerance(real 0.00001) ///
 KR(real 0) HETCov(str) ORDer(int 1) rest(str) RIDge(str) DN wit(str) aux(str) iter(int 100)]

 qui {
 preserve
 tempvar E E2 SSE Yh Ys WYs Yh_ML Y Ue_ML X0 varx vary vary2 E Time varz2 Z1
 tempvar Ue_ML X0  varx vary Time lf Z1
 tempvar U X0 Yh Lambda YY EE Eo LE XQ ht SLSVar WLSVar
 tempvar e dcs SLSVar WLSVar ht Sig2 Wis Wi WiB Wio WS Z X0 Zo Zw
 tempname E E2 EG EG2 h1 h1t h2 h2t h3 h3t HH11 HH12 HH13 HH21 HH22 HH23 HH31 HH32
 tempname HH33 HHy1 HHy2 HHy3 hy hyt MMM Rho SSE SSEs Ug Ug2 Uh Uh2 Uh2m UVh Zo
 tempname UVhm UWh UWhm V1 V2 V3 Vh Vh2 Vh2m VWh VWhm W1X W2h W2hm W2X Wh WY WYsv
 tempname WYv WX0 XB Xsv Xv Y Yh YHb Ysv Yv Z Z1 Zsv0 Zv0 ZZ Uh YHb X0 Rso Rs
 tempname WS1 WS2 WS3 WS4 varx vary vary2 wmat Wi Zz Omega E kb N Kr ZwZ Yws Zws
 tempname X Y Z M2 Xg M1 W1 W2 W1W Lambda Yy E Cov b h SSE ky Sig2n Sigo Wi OM
 tempname hjm We v lamp M W b1 v1 q vh Z0 xq Eo E1 EE1 Sw Sn nw S11 S12 Zr
 tempname WY Eg Sig2 Sig2o X X0 J S DF N kx kb F K B Omega Rso Rs WYX rid
 tempname V E Kr kfc Vec kliml kmelo kinst kw i L Li in SSEo ZwZ Yws Zws Dim LVR Lms
 tempname E E2 EG EG2 h1 h1t h2 h2t h3 h3t HH11 HH12 HH13 HH21 HH22 HH23 HH31 HH32
 tempname HH33 HHy1 HHy2 HHy3 hy hyt MMM Rho RhoGMM SSE SSEs Ug Ug2 Uh Uh2 Uh2m UVh
 tempname UVhm UWh UWhm V1 V2 V3 Vh Vh2 Vh2m VWh VWhm W1X W2h W2hm W2X Wh WY WYsv
 tempname WYv WX0 XB ZZ Uh wmat X0 X B Cov Sig2 Rso Rs
 tempname Wi Xx Zz Y var kb kx N DF Yws Zws ZwZ Z Z1 CovC
 tempname Cov D E E1 EE1 Eg Eo Eom Ew F f1 WMTD Beta Sig2o Sig2o1 Vec Qr
 tempname f13 f13d gam gam2 Go GoRY h Hat hjm IDRmk J K L Bm BOLS Zr
 tempname lmhs Ls M M1 Kr Qrq rid Rmk RX RY s sd VaL VaL1 VaL21 VaLv1
 tempname sqN Kr BOLS1 Ko Koi SLS rLm Dim LVR Lms Kk Yws Zws ZwZ

 _iv_parse `0'
 local yvar `s(lhs)'
 local endog `s(endog)'
 local exogx `s(exog)'
 local inst `s(inst)'
 if "`noconstant'"!="" | "`noconexog'"!="" {
 local nocons "noconstant"
 }
 _rmcoll `endog' , `nocons' forcedrop
 local endog "`r(varlist)'"
 _rmcoll `exogx' , `nocons' forcedrop
 local exogx "`r(varlist)'"
 unab xvar : `endog' `exogx' `aux'
 unab exog : `exogx' `aux'
 unab instx : `exog' `inst'
 _rmcoll `instx' , `nocons' forcedrop
 local instx "`r(varlist)'"

* local inst : list instx-exog
* local inst : list inst-aux
 local kendog : word count `endog'
 local kexog : word count `exog'
 local kinst : word count `inst'
 local kinstx: word count `instx'
 local kx =`kendog'+`kexog'
 local ky =1
 if `kinstx' < `kx' {
noi di _dup(70) "-" 
noi di as err " " "`run'" "{bf: cannot be Estimated} {cmd: - Equation }" "`yvar'" "{cmd: is Underidentified}" 
noi di _dup(70) "-" 
noi di as txt "{bf:** Y  = LHS Dependent Variable}
noi di as txt "   " `ky' " : " "`yvar'"
noi di as txt "{bf:** Yi = RHS Endogenous Variables}
noi di as txt "   " `kendog' " : " "`endog'"
noi di as txt "{bf:** Xi = RHS Included Exogenous Variables}"
noi di as txt "   " `kexog' " : " "`exog'"
noi di as txt "{bf:** Xj = RHS Excluded Exogenous Variables (Additional Instrumental Variables)}"
noi di as txt "   " `kinst' " : " "`inst'"
noi di as txt "{bf:** Z  = Overall Instrumental Variables}"
noi di as txt "   " `kinstx' " : "  "`instx'"
noi di as txt "{bf: Model is Under Identification:}"
noi di as txt _col(7) "Xj(" `kinstx' ")" " < Yi + Xi (" `kx' ")
noi di as txt "* since: Xj < Yi + Xi : it is recommended to use (OLS)"
noi di as err "  {bf:or let Instrumental Variables > Endogenous Variables}"
noi di _dup(70) "-"
 exit
 }

 local N = e(Nn)
 scalar `Kr'=e(Kr)
 local k =e(k)
 local k0 =e(k0)
 local kx=e(kx)
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
 if "`rest'"!="" {
 matrix `Rs'=e(Rs)
 matrix `Rso'=e(Rso)
 }

 matrix `wmat'=WMB
 gen `Time' =_n 
 tsset `Time'
 ivregress 2sls `yvar' `exog' (`endog' = `inst') , `nocons'
 predict double `E' , res
 gen double `E2'=`E'^2 
 egen double `SSE'=sum(`E2') 
 summ `E2' 
 mkmat `E' , mat(`Uh')
 matrix `Vh'=`wmat'*`Uh'
 matrix `Wh'=`wmat'*`Vh'
 mata: `Uh' = st_matrix("`Uh'")
 mata: `Vh' = st_matrix("`Vh'")
 mata: `Wh' = st_matrix("`Wh'")
 getmata `Uh' , force replace
 getmata `Vh' , force replace
 getmata `Wh' , force replace
 gen double `Uh2'=`Uh'*`Uh'
 gen double `Vh2'=`Vh'*`Vh'
 gen double `UVh'=`Uh'*`Vh'
 gen double `VWh'=`Vh'*`Wh'
 gen double `W2h'=`Wh'*`Wh'
 gen double `UWh'=`Uh'*`Wh'
 matrix `MMM'=trace(`wmat''*`wmat')/_N
 egen double `Uh2m' = mean(`Uh2') 
 egen double `Vh2m' = mean(`Vh2') 
 egen double `UVhm' = mean(`UVh') 
 egen double `VWhm' = mean(`VWh') 
 egen double `W2hm' = mean(`W2h') 
 egen double `UWhm' = mean(`UWh') 
 gen double `HH11'=-2*`UVhm' 
 gen double `HH12'=`Vh2m' 
 gen `HH13'=-1 
 gen double `HH21'=-2*`VWhm' 
 gen double `HH22'=`W2hm' 
 gen double `HH23'=-trace(`MMM') 
 gen double `HH31'=-(`Vh2m'+`UWhm') 
 gen double `HH32'=`VWhm' 
 gen `HH33'=0 
 gen double `HHy1'=-`Uh2m' 
 gen double `HHy2'=-`Vh2m' 
 gen double `HHy3'=-`UVhm' 
 forvalues i = 1/3 {
 forvalues j = 1/3 {
 sum `HH`i'`j'' 
 tempname h`i'`j'
 scalar `h`i'`j''=r(mean)
 sum `HHy`i''
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
 mata: `V1' = st_matrix("`h1'")
 mata: `V2' = st_matrix("`h2'")
 mata: `V3' = st_matrix("`h3'")
 mata: `Z1' = st_matrix("`hy'")
 getmata `V1' , force replace
 getmata `V2' , force replace
 getmata `V3' , force replace
 getmata `Z1' , force replace

 nl (`Z1'=`V1'*{Rho}+`V2'*{Rho}^2+`V3'*{Sigma2}) , init(Rho 0.7 Sigma2 1) nolog
 scalar `Rho'=_b[/Rho]
 gen double `Wi' = `wit'
 mkmat `Wi' , matrix(`Wi')
 matrix `Wi'=`Wi'-`Rho'*`wmat'*`Wi'
 mata: `Wi' = st_matrix("`Wi'")
 getmata `Wi' , force replace
 gen double `X0'= `Wi' 
 mkmat `yvar' , matrix(`yvar')
 matrix `yvar'=`yvar'-`Rho'*`wmat'*`yvar'
 mata: `yvar' = st_matrix("`yvar'")
 getmata `yvar' , force replace
 matrix `WYX'=`wmat'*`yvar'
 mata: w1y_`yvar' = st_matrix("`WYX'")
 getmata w1y_`yvar' , force replace
 foreach var of local exogx {
 mkmat `var' , matrix(`var')
 matrix `var'=`var'-`Rho'*`wmat'*`var'
 mata: `var' = st_matrix("`var'")
 getmata `var' , force replace
 } 
 if "`endog'"!="" {
 foreach var of local endog {
 mkmat `var' , matrix(`var')
 matrix `var'=`var'-`Rho'*`wmat'*`var'
 mata: `var' = st_matrix("`var'")
 getmata `var' , force replace
 } 
 }
 if "`inst'"!="" {
 foreach var of local inst {
 mkmat `var' , matrix(`var')
 matrix `var'=`var'-`Rho'*`wmat'*`var'
 mata: `var' = st_matrix("`var'")
 getmata `var' , force replace
 } 
 }
 local Wxis ""
 if "`order'"!="" {
 forvalues i = 1/`order' {
 foreach var of local exogx {
 mata: w`i'x_`var' = st_matrix("w`i'x_`var'")
 getmata w`i'x_`var' , force replace
 label variable w`i'x_`var' `"AR(`i') `var' Spatial Lag"'
 local Wxis "`Wxis' w`i'x_`var'"
 }
 }
 }
 local zvar `exogx' `aux' `Wxis' `inst'
 unab endog : `endog'
 unab exog : `exogx' `aux'
 unab xvar : `endog' `exog'
 local _Zo "`endog' `exog'"
 unab instx : `zvar'
 local inst : list zvar-exog
 unab inst : `inst'
 mkmat `yvar' , matrix(`Y')
 mkmat `yvar' `endog' , matrix(`Yy')
 if "`noconstant'"!="" | "`noconexog'"!="" {
 if "`noconstant'"!="" {
 mkmat `exog' , matrix(`Xg')
 mkmat `exog' `inst' `X0' , matrix(`X')
 mkmat `endog' `exog' , matrix(`Z')
 }
 if "`noconexog'"!="" {
 mkmat `exog' , matrix(`Xg')
 mkmat `exog' `inst' , matrix(`X')
 mkmat `endog' `exog' , matrix(`Z')
 }
 }
 else { 
 if "`noconstant'"=="" | "`noconexog'"=="" {
 mkmat `exog' `X0' , matrix(`Xg')
 mkmat `exog' `inst' `X0' , matrix(`X')
 mkmat `endog' `exog'  `X0' , matrix(`Z')
 }
 }
 matrix `Zz'=I(`kb')*0
 getmata `Wi' , force replace
 mkmat `Wi' , matrix(`Wi')
 gen double `Zo'= `Wi'
 local _Yw "`yvar'"
 local _Zw "`xvar'"
 matrix `Yws'=`Y'
 matrix `Zws'=`Z'
 summ `Wi' 
 local WiB =r(mean)
 scalar `Kr' =`kr'
 if "`ridge'"!="" {
 local Ro1= 0 
 replace `Zo' = `WiB'
 local Zo_Zw "`Zo' `_Zw'"
 local kZw: word count `Zo_Zw'
 forvalue i=1/`kZw' {
 local v : word `i' of `Zo_Zw'
 if "`noconstant'"!="" | "`noconexog'"!="" {
 gen double `SLSVar'_`i' = `v'
 }
 else {
 summ `v'
 gen double `SLSVar'_`i' = `v' - r(mean)
 }
 }
 unab ZSLSVar : `SLSVar'_*
 tokenize `ZSLSVar'
 local ZoC `1'
 macro shift
 local ZSLSVar "`*'"
 replace `ZoC' = 0
 mkmat `_Yw' , matrix(`Yws')
 if "`noconstant'"!="" | "`noconexog'"!="" {
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
 svmat double `VaL1' , name(`VaL1')
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
 svmat double `LVR' , name(`LVR')
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
 svmat double `f1' , name(`f1')
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
 svmat double `Lms' , name(`Lms'`i')
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
 matrix `Wi'= diag(`Wi')
 matrix `Omega'=`Wi''*`Wi'
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
 cap matrix `W1W'=`W1'*invsym(`W2')
 matrix eigenvalues `Lambda' `Vec' = `W1W'
 matrix `Lambda' =`Lambda''
 mata: `Lambda' = st_matrix("`Lambda'")
 getmata `Lambda' , force replace
 summ `Lambda' 
 scalar `kliml'=r(min)
 matrix `ZwZ'=`Z''*`Omega'*`Z'
 matrix `Yws'=`Wi'*`Y'
 matrix `Zws'=`Wi'*`Z'

 if inlist("`run'", "2sls") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Two Stage Least Squares (2SLS)}}"
noi di _dup(78) "{bf:{err:=}}"
 matrix `Omega'=`Wi'*`X'*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''
 matrix `B'=invsym(`Zws''*`Omega'*`Zws'+`Zz')*`Zws''*`Omega'*`Yws'
 }
 if inlist("`run'", "liml") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Limited-Information Maximum Likelihood (LIML)}}"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf: K - Class (LIML) Value =} " as res %9.5f `kliml'
 matrix `Omega'=`Wi'*`X'*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''
 matrix `Omega'=(I(`N')-`kliml'*(I(`N')-`Omega'))
 matrix `B'=invsym(`Zws''*`Omega'*`Zws'+`Zz')*`Zws''*`Omega'*`Yws'
 }
 if inlist("`run'", "kclass") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Theil k-Class (LIML)}}"
noi di _dup(78) "{bf:{err:=}}"
 local kc =`kc'
noi di as txt "{bf: K - Class Value =} " as res %9.5f `kc'
 matrix `Omega'=(I(`N')-`kc'*(I(`N')-`Wi'*`X'*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''))
 matrix `B'=invsym(`Zws''*`Omega'*`Zws'+`Zz')*`Zws''*`Omega'*`Yws'
 }
 if inlist("`run'", "fuller") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Fuller k-Class (LIML)}}"
noi di _dup(78) "{bf:{err:=}}"
 local kfc =`kliml'-(`kf'/(`N'-`kinstx'))
noi di as txt "{bf:  LIML-Class Value}" _col(27) " = " as res %9.5f `kliml'
noi di as txt "{bf: Alpha-Class Value}" _col(27) " = " as res %9.5f `kf'
noi di as txt "{bf:     K-Class Fuller Value}" _col(27) " = " as res %9.5f `kfc'
 matrix `Omega'=(I(`N')-`kfc'*(I(`N')-`Wi'*`X'*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''))
 matrix `B'=invsym(`Zws''*`Omega'*`Zws'+`Zz')*`Zws''*`Omega'*`Yws'
 }
 if inlist("`run'", "melo") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Minimum Expected Loss (MELO)}}"
noi di _dup(78) "{bf:{err:=}}"
 local kmelo =1-`kx'/(`N'-`kx'-2)
noi di as txt "{bf: K - Class (MELO) Value  =} " as res %9.5f `kmelo'
 matrix `Omega'=(I(`N')-`kmelo'*(I(`N')-`Wi'*`X'*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''))
 matrix `B'=invsym(`Zws''*`Omega'*`Zws'+`Zz')*`Zws''*`Omega'*`Yws'
 }
 if inlist("`run'", "gmm") {
 if "`hetcov'"=="" {
 local hetcov "white"
 }
 if inlist("`hetcov'", "white") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (White Method)}}"
noi di _dup(78) "{bf:{err:=}}"
 matrix `Omega'=`Wi'*`X'*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''
 matrix `B'=invsym(`Zws''*`Omega'*`Zws'+`Zz')*`Zws''*`Omega'*`Yws'
 matrix `E'=(`Y'-`Z'*`B')
 matrix `OM'=diag(`E')
 matrix `We'=`OM'*`OM'
 matrix `Omega'=`X'*invsym(`X''*`We'*`X')*`X''
 matrix `B'=invsym(`Zws''*`Omega'*`Zws'+`Zz')*`Zws''*`Omega'*`Yws'
 }
 if inlist("`run'", "gmm") & !inlist("`hetcov'", "white") {
 if inlist("`hetcov'", "bart") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Bartlett Method)}}"
noi di _dup(78) "{bf:{err:=}}"
 local i=1
 local L=4*(`N'/100)^(2/9)
 local Li=`i'/(1+`L')
 local kw=1-`Li'
 }
 if inlist("`hetcov'", "dan") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Daniell Method)}}"
noi di _dup(78) "{bf:{err:=}}"
 local i=1
 local L=4*(`N'/100)^(2/9)
 local Li=`i'/(1+`L')
 local kw=sin(_pi*`Li')/(_pi*`Li')
 }
 if inlist("`hetcov'", "nwest") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Newey-West Method)}}"
noi di _dup(78) "{bf:{err:=}}"
 local i=1
 local L=1
 local Li=`i'/(1+`L')
 local kw=1-`Li'
 }
 if inlist("`hetcov'", "parzen") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Parzen Method)}}"
noi di _dup(78) "{bf:{err:=}}"
 local i=1
 local L=4*(`N'/100)^(2/9)
 local Li=`i'/(1+`L')
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
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Quadratic Spectral Method)}}"
noi di _dup(78) "{bf:{err:=}}"
 local i=1
 local L=4*(`N'/100)^(2/25)
 local Li=`i'/(1+`L')
 local kw=(25/(12*_pi^2*`Li'^2))*(sin(6*_pi*`Li'/5)/(6*_pi*`Li'/5)-sin(6*_pi*`Li'/5+_pi/2))
 }
 if inlist("`hetcov'", "tent") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Tent Method)}}"
noi di _dup(78) "{bf:{err:=}}"
 local i=1
 local L=4*(`N'/100)^(2/9)
 local Li=`i'/(1+`L')
 local kw=2*(1-cos(`Li'*`Li'))/(`Li'^2)
 }
 if inlist("`hetcov'", "trunc") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Truncated Method)}}"
noi di _dup(78) "{bf:{err:=}}"
 local i=1
 local L=4*(`N'/100)^(1/4)
 local Li=`i'/(1+`L')
 local kw=1-`Li'
 }
 if inlist("`hetcov'", "tukeym") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Tukey-Hamming Method)}}"
noi di _dup(78) "{bf:{err:=}}"
 local i=1
 local L=4*(`N'/100)^(1/4)
 local Li=`i'/(1+`L')
 local kw=0.54+0.46*cos(_pi*`Li')
 }
 if inlist("`hetcov'", "tukeyn") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Tukey-Hanning Method)}}"
noi di _dup(78) "{bf:{err:=}}"
 local i=1
 local L=4*(`N'/100)^(1/4)
 local Li=`i'/(1+`L')
 local kw=(1+sin((_pi*`Li')+_pi/2))/2
 }
 gen `Z0' = 1 
 replace `Z0' = 0 in 1
 foreach var of local _Zo {
 gen double `xq'`var' = `var'[_n-1] 
 replace `xq'`var' = 0 in 1
 }
 if ("`noconstant'"!="" | "`noconexog'"!="") {
 mkmat `xq'* , matrix(`M')
 }
 else {
 mkmat `xq'* `Z0' , matrix(`M')
 }
 matrix `M'=`Wi'*`M'
 matrix `Omega'=`Wi'*`X'*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''
 matrix `B'=invsym(`Zws''*`Omega'*`Zws'+`Zz')*`Zws''*`Omega'*`Yws'
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 mata: `Eg' = st_matrix("`E'")
 getmata `Eg' , force replace
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
 matrix `nw'=`nw'*`in'
 }
 }
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 matrix `E'=`Y'-`Z'*`B'
 matrix `SSE'=`E''*`E'
 scalar `SSEo'=`SSE'[1,1]
 scalar `Sig2o'=`SSEo'/`DF'
 scalar `Sig2n'=`SSEo'/`N'
 scalar `Sigo'=sqrt(`Sig2o')
 matrix `OM'=diag(`E')
 matrix `We'=`OM'*`OM'
 matrix `hjm'=(`E''*(`X'*invsym(`X''*`We'*`X')*`X'')*`E')
 local lmihj=`hjm'[1,1]
 local dfgmm=`kinstx'-`kx'
 local lmihjp= chi2tail(`dfgmm', abs(`lmihj'))
 matrix `ZwZ'=`Z''*`Omega'*`Z'
 if "`rest'"!="" {
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 if "`ridge'"!="" & `Kr' > 0 {
 if inlist("`run'", "ols", "2sls", "liml", "melo", "fuller", "kclass") {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')-`Sig2'*invsym(`ZwZ'+`Zz') ///
 *`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 if inlist("`run'", "gmm") & inlist("`hetcov'", "white") {
 matrix `Cov'=invsym(`ZwZ'+`Zz')-invsym(`ZwZ'+`Zz')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 if inlist("`run'", "gmm") & !inlist("`hetcov'", "white") {
 matrix `Cov'=invsym(`ZwZ'+`Zz')-invsym(`ZwZ'+`Zz')*`Rs'' ///
 *invsym(`Rs'*(`nw'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 }
 }
 else {
 if "`ridge'"!="" & `Kr' > 0 {
 if inlist("`run'", "ols", "2sls", "liml", "melo", "fuller", "kclass") {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')*`ZwZ'*invsym(`ZwZ'+`Zz')
 }
 if inlist("`run'", "gmm") & inlist("`hetcov'", "white") {
 matrix `Cov'=invsym(`ZwZ'+`Zz')*`ZwZ'*invsym(`ZwZ'+`Zz')
 }
 if inlist("`run'", "gmm") & !inlist("`hetcov'", "white") {
 matrix `Cov'=invsym(`ZwZ'+`Zz')*`nw'*invsym(`ZwZ'+`Zz')
 }
 }
 else {
 if inlist("`run'", "ols", "2sls", "liml", "melo", "fuller", "kclass") {
 matrix `Cov'=`Sig2o'*invsym(`ZwZ')
 }
 if inlist("`run'", "gmm") & inlist("`hetcov'", "white") {
 matrix `Cov'=invsym(`ZwZ')
 }
 if inlist("`run'", "gmm") & !inlist("`hetcov'", "white") {
 matrix `Cov'=invsym(`ZwZ')*`nw'*invsym(`ZwZ')
 }
 }
 }
 matrix `B'=`B''
 if "`noconstant'"!="" | "`noconexog'"!="" {
 matrix colnames `Cov' = `xvar'
 matrix rownames `Cov' = `xvar'
 matrix colnames `B'= `xvar'
 }
 else { 
 matrix colnames `Cov' = `xvar' _cons
 matrix rownames `Cov' = `xvar' _cons
 matrix colnames `B'= `xvar' _cons
 }
 local Nof =`N'
 local Dof =`DF'
 ereturn post `B' `Cov' , dep(`yvar') obs(`Nof') dof(`Dof')
 if "`ridge'"!="" {
 ereturn local Kr = `Kr'
 }
 if inlist("`run'", "gmm") {
 ereturn local lmihj=`lmihj'
 ereturn local dfgmm=`dfgmm'
 ereturn local lmihjp=`lmihjp'
 }
 }
 restore
 end

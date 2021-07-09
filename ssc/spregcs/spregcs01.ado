 program define spregcs01 , eclass 
 version 11.2
 syntax varlist , [coll vce(passthru) rest(str) ridge(str) TOLerance(real 0.00001) ///
 KR(real 0) ROBust aux(str) wit(str) NOCONStant iter(int 100) tobit ll(real 0) DN]

 qui {
 gettoken yvar xvar : varlist
 preserve
 tempvar E E2 SSE Ue_ML X0  varx vary Time lf Z1 yhat
 tempname E E2 EG EG2 h1 h1t h2 h2t h3 h3t HH11 HH12 HH13 HH21 HH22 HH23 HH31 HH32
 tempname HH33 HHy1 HHy2 HHy3 hy hyt MMM Rho RhoGMM SSE SSEs Ug Ug2 Uh Uh2 Uh2m UVh
 tempname UVhm UWh UWhm V1 V2 V3 Vh Vh2 Vh2m VWh VWhm W1X W2h W2hm W2X Wh WY WYsv
 tempname WYv WX0 XB ZZ Uh wmat X0 X B Cov Sig2 Rso Rs
 tempname Wi Xx Zz Y var kb kx N DF Yws Zws ZwZ Z Z1 CovC
 tempvar E e dcs SLSVar WLSVar ht Sig2 Wis Wi WiB Wio WS Z X0 Zo Zw
 tempname Cov D E E1 EE1 Eg Eo Eom Ew F f1 WMTD Beta Sig2o Sig2o1 Vec Qr
 tempname f13 f13d gam gam2 Go GoRY h Hat hjm IDRmk J K L Bm BOLS Zr
 tempname lmhs Ls M M1 Kr Qrq rid Rmk RX RY s sd VaL VaL1 VaL21 VaLv1
 tempname sqN Kr BOLS1 Ko Koi SLS rLm Dim LVR Lms Kk Yws Zws ZwZ

 local N =e(Nn)
 local kb =e(kb)
 local kx =e(kx)
 local DF =e(DF)
 local llt=spat_llt
 matrix `wmat'=WMB
 gen `Time'=_n
 gen `X0'=1
 if "`tobit'"!="" {
 tobit `yvar' `xvar' `aux' `wgt' , `noconstant' `vce' ll(`llt')
 predict double `yhat' , xb
 gen double `E'=`yvar'-`yhat'
 }
 else { 
 regress `yvar' `xvar' `aux' `wgt' , `noconstant' `vce'
 predict double `E' , resid
 }
 gen double `E2'=`E'^2 
 matrix `wmat'=WMB
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
 matrix `MMM'=trace(`wmat''*`wmat')/`N'
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
 matrix `RhoGMM'=`h1',`h2',`h3',`hy'
 mata: `V1' = st_matrix("`h1'")
 mata: `V2' = st_matrix("`h2'")
 mata: `V3' = st_matrix("`h3'")
 mata: `Z1' = st_matrix("`hy'")
 getmata `V1' , force replace
 getmata `V2' , force replace
 getmata `V3' , force replace
 getmata `Z1' , force replace

 nl (`Z1'=`V1'*{Rho}+`V2'*{Rho}^2+`V3'*{Sigma2}) , init(Rho 0.5 Sigma2 1) nolog
 scalar `Rho'=_b[/Rho]
 gen double `Wi' = `wit'
 replace `yvar'=`Wi'*`yvar'
 mkmat `yvar' , matrix(`Y')
 matrix `Y'=`Y'-`Rho'*`wmat'*`Y'
 mata: `yvar' = st_matrix("`Y'")
 getmata `yvar' , force replace
 mkmat `Wi' , matrix(`X0')
 matrix `X0'=`X0'-`Rho'*`wmat'*`X0'
 foreach var of local xvar {
 replace `var'=`Wi'*`var' 
 mkmat `var' , matrix(`var')
 matrix `var'=`var'-`Rho'*`wmat'*`var'
 mata: `var' = st_matrix("`var'")
 getmata `var' , force replace
 } 
 if "`xvar'"!="" {
 if "`noconstant'"!="" {
 mkmat `xvar' `aux' , matrix(`Z')
 }
 else { 
 mkmat `xvar' `aux' , matrix(`Z')
 matrix `Z'=`Z', `X0'
 }
 }
 if "`xvar'" == "" {
 if `kb'== 1 {
 mkmat `X0' , matrix(`Z')
 }
 } 
 mata: `Wi' = st_matrix("`X0'")
 getmata `Wi' , force replace
 mkmat `Wi' , matrix(`Wi')
 matrix `Wi'= diag(`Wi')
 gen double `Zo'= `Wi'
 local _Yw "`yvar'"
 local _Zw "`xvar' `aux'"
 matrix `Yws'=`Y'
 matrix `Zws'=`Z'
 summ `Wi' 
 local WiB =r(mean)
 matrix `Zz'=I(`kb')*0
 scalar `Kr'=`kr'
 if "`ridge'"!="" {
 local Ro1= 0 
 replace `Zo' = `WiB'
 local Zo_Zw "`Zo' `_Zw'"
 local kZw: word count `Zo_Zw'
 forvalue i=1/`kZw' {
 local v : word `i' of `Zo_Zw'
 if "`noconstant'"!="" {
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
 matrix `ZwZ'=`Zws''*`Zws'
 matrix `B'=invsym(`Zws''*`Zws'+`Zz')*`Zws''*`Yws'
 if "`rest'"!="" {
 matrix `Rs'=e(Rs)
 matrix `Rso'=e(Rso)
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 }
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 if "`rest'"!="" {
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')-`Sig2'*invsym(`ZwZ'+`Zz')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 }
 }
 else {
 if "`ridge'"!="" & `Kr' > 0 {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')*`ZwZ'*invsym(`ZwZ'+`Zz')
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')
 }
 }
 matrix `B'=`B''
 if "`xvar'"!="" {
 if "`noconstant'"!="" {
 matrix colnames `Cov' = `xvar' `aux'
 matrix rownames `Cov' = `xvar' `aux'
 matrix colnames `B'= `xvar' `aux'
 }
 else { 
 matrix colnames `Cov' = `xvar' `aux' _cons
 matrix rownames `Cov' = `xvar' `aux' _cons
 matrix colnames `B'= `xvar' `aux' _cons
 }
 }
 if "`xvar'" == "" {
 if `kb'== 1 {
 matrix colnames `Cov' = _cons
 matrix rownames `Cov' = _cons
 matrix colnames `B'= _cons
 }
 } 
 local Nof =`N'
 local Dof =`DF'
 matrix `B'=`B'
 ereturn post `B' `Cov' , dep(`yvar') obs(`Nof') dof(`Dof')
 if "`ridge'"!="" {
 ereturn local Kr = `Kr'
 }
 restore
 }
 end


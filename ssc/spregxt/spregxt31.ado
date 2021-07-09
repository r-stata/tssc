 program define spregxt31 , eclass 
 version 11.2
 syntax varlist , [idv(str) itv(str) gmm(str) NOCONStant vce(str) level(str) ///
 aux(str) dn tobit LL(str) wvar(str) ROBust RIDge(str) KR(str) iter(str) ///
 tech(str) rest(str)]

 qui {
 tempvar ss2 u u2 X0 Time tm Wi yhat res res2 Wis Zo Zw WLSVar Wip
 tempvar US VS WS UQS VQS WQS UTS VTS WTS Wio WiB SLSVar VaL1 LVR Lms lf
 tempname matg h1 h1t h2 h2t h3 h3t HM1 HM1t HM2 HM2t HM3 HM3t HM4 HM4t HMY HMYt hy Z0
 tempname hyt mats matj wmat wmat1 mtr MQ0 MQ1 MW1 MWT1 MWT2 MWT21 MW2 MW3 MW4 OMGINV
 tempname Q0 Q1 P matt Q1UVEC UQVEC VCOV Q1VVEC B VQVEC VVEC Q1WVEC WQVEC WVEC UVEC XB
 tempname X Y E Cov B Sig2 RhoGM Xx Z Zz Wi Y var kb Kr NC NT L T1 T2 Yws Zws ZwZ
 tempname sqN WMTD Beta BOLS BOLS1 Sig2o Sig2o1 Ko rid Zz CovC RY RX Vec VaL Zr VaLv1 F sd
 tempname WCS VaL1 VaL21 Go GoRY SSE Sig2 Qr LVR f1 SLS f13 f13d Rmk IDRmk Lms lf Kk Koi

 gettoken yvar xvar : varlist
 local kb=e(kb)
 local kx=e(kx)
 local Kr=e(Kr)
 local DF=e(DF)
 gen `Time'=_n
 count 
 local N = r(N)
 xtset `idv' `itv'
 local NC=r(imax)
 local NT=r(tmax)
 if "`wvar'"!="" {
 bys `idv' : egen `Wi'=mean(`wvar')
 gen double `Wis' = `Wi'^2
 local wgt "[weight = `Wis']"
 }
 else {
 local wgt ""
 gen `Wi'= 1
 gen `Wis'= 1
 }
 preserve
 matrix `wmat'= e(WCS)
 matrix `WCS'= `wmat'
 matrix `mtr'=trace(`wmat''*`wmat')/_N
 matrix `mats'=I(`NC')
 matrix `matt'=I(`NT')
 matrix `matj'=J(`NT',`NT',1/`NT')
 matrix `wmat1'=`matt'#`wmat'
 matrix `Q0'=(`matt'-`matj')#`mats'
 matrix `Q1'=`matj'#`mats'
 matrix `MW1'=`wmat''*`wmat'
 matrix `MWT1'=trace(`MW1')/`NC'
 matrix `MWT21'=`MW1'*(`wmat'+`wmat'')
 matrix `MWT2'=trace(`MWT21')/`NC'
 matrix `MW2'=`wmat'*`wmat'
 matrix `MW3'=`MW1'*`MW1'
 matrix `MW4'=`MW1'+`MW2'
 matrix `MQ0'=trace(`MW3')/`NC'
 matrix `MQ1'=trace(`MW4')/`NC'
 cap matrix drop `MWT21' `MW1' `MW2' `MW3' `MW4'
 if "`tobit'"!="" {
 xttobit `yvar' `xvar' `aux' `wgt' , `noconstant' `vce' level(`level') ///
 ll(`ll') iter(`iter') tech(`tech') `tobit'
 predict `yhat' , xb
 gen double `res'=`yvar'-`yhat'  
 }
 else { 
 tsset `Time'
 regress `yvar' `xvar' `aux' `wgt' , `noconstant' `vce' `robust'
 predict `res' , resid
 }
 tsset `Time'
 gen double `res2'=`res'^2
 scalar `L'=`gmm'
 mkmat `res' , matrix(`UVEC')
 matrix `VVEC'=`wmat1'*`UVEC'
 matrix `WVEC'=`wmat1'*`VVEC'
 matrix `UQVEC'=`Q0'*`UVEC'
 matrix `VQVEC'=`Q0'*`VVEC'
 matrix `WQVEC'=`Q0'*`WVEC'
 matrix `Q1UVEC'=`Q1'*`UVEC'
 matrix `Q1VVEC'=`Q1'*`VVEC'
 matrix `Q1WVEC'=`Q1'*`WVEC'
 mata: `US' = st_matrix("`UVEC'")
 mata: `VS' = st_matrix("`VVEC'")
 mata: `WS' = st_matrix("`WVEC'")
 mata: `UQS' = st_matrix("`UQVEC'")
 mata: `VQS' = st_matrix("`VQVEC'")
 mata: `WQS' = st_matrix("`WQVEC'")
 mata: `UTS' = st_matrix("`Q1UVEC'")
 mata: `VTS' = st_matrix("`Q1VVEC'")
 mata: `WTS' = st_matrix("`Q1WVEC'")
 getmata `US' , force replace
 getmata `VS' , force replace
 getmata `WS' , force replace
 getmata `UQS' , force replace
 getmata `VQS' , force replace
 getmata `WQS' , force replace
 getmata `UTS' , force replace
 getmata `VTS' , force replace
 getmata `WTS' , force replace
 cap matrix drop `wmat1' `VVEC' `UVEC' `WVEC'
 cap matrix drop `UQVEC' `VQVEC' `WQVEC' `Q1UVEC' `Q1VVEC' `Q1WVEC'
 tempvar UQ2 VQ2 WQ2 UQVQ UQWQ VQWQ UQ12 VQ12 WQ12 UQ1VQ1 UQ1WQ1 VQ1WQ1
 gen double `UQ2'=`UQS'*`UQS'
 gen double `VQ2'=`VQS'*`VQS'
 gen double `WQ2'=`WQS'*`WQS'
 gen double `UQVQ'=`UQS'*`VQS'
 gen double `UQWQ'=`UQS'*`WQS'
 gen double `VQWQ'=`VQS'*`WQS'
 gen double `UQ12'=`UTS'*`UTS'
 gen double `VQ12'=`VTS'*`VTS'
 gen double `WQ12'=`WTS'*`WTS'
 gen double `UQ1VQ1'=`UTS'*`VTS'
 gen double `UQ1WQ1'=`UTS'*`WTS'
 gen double `VQ1WQ1'=`VTS'*`WTS'
 matrix `mtr'=trace(`wmat''*`wmat')/`NC'
 scalar `T1'=`NT'/(`NT'-1)
 scalar `T2'=`NT'
 tempvar UQ2M VQ2M WQ2M UQVQM UQWQM VQWQM UQ12M VQ12M WQ12M UQ1VQ1M UQ1WQ1M VQ1WQ1M
 egen double `UQ2M' = mean(`UQ2')
 egen double `VQ2M' = mean(`VQ2')
 egen double `WQ2M' = mean(`WQ2')
 egen double `UQVQM' = mean(`UQVQ')
 egen double `UQWQM' = mean(`UQWQ')
 egen double `VQWQM' = mean(`VQWQ')
 egen double `UQ12M' = mean(`UQ12')
 egen double `VQ12M' = mean(`VQ12')
 egen double `WQ12M' = mean(`WQ12')
 egen double `UQ1VQ1M' = mean(`UQ1VQ1')
 egen double `UQ1WQ1M' = mean(`UQ1WQ1')
 egen double `VQ1WQ1M' = mean(`VQ1WQ1')
 tempname SUQ2M SVQ2M SWQ2M SUQVQM SUQWQM SVQWQM SUQ12M VAR1 VAR2
 tempname SVQ12M SWQ12M SUQ1VQ1M SUQ1WQ1M SVQ1WQ1M RhoH SIGV SIG1
 scalar `SUQ2M'=`UQ2M'*`T1'
 scalar `SVQ2M'=`VQ2M'*`T1'
 scalar `SWQ2M'=`WQ2M'*`T1'
 scalar `SUQVQM'=`UQVQM'*`T1'
 scalar `SUQWQM'=`UQWQM'*`T1'
 scalar `SVQWQM'=`VQWQM'*`T1'
 scalar `SUQ12M'=`UQ12M'*`T2'
 scalar `SVQ12M'=`VQ12M'*`T2'
 scalar `SWQ12M'=`WQ12M'*`T2'
 scalar `SUQ1VQ1M'=`UQ1VQ1M'*`T2'
 scalar `SUQ1WQ1M'=`UQ1WQ1M'*`T2'
 scalar `SVQ1WQ1M'=`VQ1WQ1M'*`T2' 
 tempvar h11 h12 h13 h21 h22 h23 h31 h32 h33 hy1 hy2 hy3
 gen double `h11'=2*`SUQVQM'
 gen double `h12'=-`SVQ2M'
 gen `h13'=1
 gen double `h21'=2*`SVQWQM'
 gen double `h22'=-`SWQ2M'
 gen double `h23'=trace(`mtr')
 gen double `h31'=(`SVQ2M'+`SUQWQM')
 gen double `h32'=-`SVQWQM'
 gen `h33'=0
 gen double `hy1'=`SUQ2M'
 gen double `hy2'=`SVQ2M'
 gen double `hy3'=`SUQVQM'
 collapse `h11' `h12' `h13' `hy1' `h21' `h22' `h23' `hy2' `h31' `h32' `h33' `hy3'
 mkmat `h11' `h21' `h31' , matrix(`h1t')
 mkmat `h12' `h22' `h32' , matrix(`h2t')
 mkmat `h13' `h23' `h33' , matrix(`h3t')
 mkmat `hy1' `hy2' `hy3' , matrix(`hyt')
 matrix `h1'=`h1t''
 matrix `h2'=`h2t''
 matrix `h3'=`h3t''
 matrix `hy'=`hyt''
 set obs 3
 tempvar V1 V2 V3 Z1
 tempname V1 V2 V3 Z1
 mata: `V1' = st_matrix("`h1'")
 mata: `V2' = st_matrix("`h2'")
 mata: `V3' = st_matrix("`h3'")
 mata: `Z1' = st_matrix("`hy'")
 getmata `V1' , force replace
 getmata `V2' , force replace
 getmata `V3' , force replace
 getmata `Z1' , force replace
 nl (`Z1'=`V1'*{Rho} +`V2'*{Rho}^2 +`V3'*{Sigma2}) , init(Rho 0 Sigma2 1) nolog
 tempname RhoH SIGV SIG1 VAR1 VAR2 SIGVV SIG11
 scalar `RhoH'=_b[/Rho]
 scalar `SIGV'=_b[/Sigma2]
 scalar `SIG1'=`SUQ12M'-(2*`SUQ1VQ1M'*`RhoH')-(-1*`SVQ12M'*(`RhoH'^2))
 scalar `VAR1'= ((`SIGV'^2)/(`NT'-1))^0.5
 scalar `VAR2'= (`SIG1'^2)^0.5
 tempname VAR11 VAR22 VAR33 VAR44 VAR55 VAR66 VAR12 VAR23 VAR45 VAR56
 if `L' == 1 {
 scalar `RhoGM'=`RhoH'
 scalar `SIGVV'=`SIGV'
 scalar `SIG11'=`SIG1'
 }
 if `L' == 2 {
 scalar `VAR11'=`NC'*((1*(`SIGV'^2)/(`NC'*(`NT'-1))))
 scalar `VAR22'=`NC'*((1*(`SIGV'^2)/(`NC'*(`NT'-1))))
 scalar `VAR33'=`NC'*((1*(`SIGV'^2)/(`NC'*(`NT'-1))))
 scalar `VAR44'=`NC'*((1*(`SIG1'^2)/`NC'))
 scalar `VAR55'=`NC'*((1*(`SIG1'^2)/`NC'))
 scalar `VAR66'=`NC'*((1*(`SIG1'^2)/`NC'))
 scalar `VAR12' = 0
 scalar `VAR23' = 0
 scalar `VAR45' = 0
 scalar `VAR56' = 0
 }
 if `L' == 3 {
 scalar `VAR11' = `NC'*((2*(`SIGV'^2)/(`NC'*(`NT'-1))))
 scalar `VAR22' = `NC'*((2*(`SIGV'^2)/(`NC'*(`NT'-1)))*trace(`MQ0'))
 scalar `VAR33' = `NC'*((1*(`SIGV'^2)/(`NC'*(`NT'-1)))*trace(`MQ1'))
 scalar `VAR44' = `NC'*((2*(`SIG1'^2)/`NC'))
 scalar `VAR55' = `NC'*((2*(`SIG1'^2)/`NC')*trace(`MQ0'))
 scalar `VAR66' = `NC'*((1*(`SIG1'^2)/`NC')*trace(`MQ1'))
 scalar `VAR12' = `NC'*(2*(`SIGV'^2)/(`NC'*(`NT'-1)))*trace(`MWT1')
 scalar `VAR23' = `NC'*(1*(`SIGV'^2)/(`NC'*(`NT'-1)))*trace(`MWT2')
 scalar `VAR45' = `NC'*(2*(`SIG1'^2)/`NC')*trace(`MWT1')
 scalar `VAR56' = `NC'*(1*(`SIG1'^2)/`NC')*trace(`MWT2')
 }
 if `L' > 1 {
 matrix `VCOV'=I(6)
 matrix `VCOV'[1,1]=`VAR11'
 matrix `VCOV'[1,2]=`VAR12'
 matrix `VCOV'[2,1]=`VAR12'
 matrix `VCOV'[2,2]=`VAR22'
 matrix `VCOV'[2,3]=`VAR23'
 matrix `VCOV'[3,2]=`VAR23'
 matrix `VCOV'[3,3]=`VAR33'
 matrix `VCOV'[4,4]=`VAR44'
 matrix `VCOV'[4,5]=`VAR45'
 matrix `VCOV'[5,4]=`VAR45'
 matrix `VCOV'[5,5]=`VAR55'
 matrix `VCOV'[5,6]=`VAR56'
 matrix `VCOV'[6,5]=`VAR56'
 matrix `VCOV'[6,6]=`VAR66'
 matrix `VCOV'=invsym(`VCOV')
 matrix `P' = (cholesky(`VCOV'))'
 tempname P11 P12 P21 P22 P23 P32 P33 P44 P45 P54 P55 P56 P65 P66
 scalar `P11' = `P'[1,1]
 scalar `P12' = `P'[1,2]
 scalar `P21' = `P'[2,1]
 scalar `P22' = `P'[2,2]
 scalar `P23' = `P'[2,3]
 scalar `P32' = `P'[3,2]
 scalar `P33' = `P'[3,3]
 scalar `P44' = `P'[4,4]
 scalar `P45' = `P'[4,5]
 scalar `P54' = `P'[5,4]
 scalar `P55' = `P'[5,5]
 scalar `P56' = `P'[5,6]
 scalar `P65' = `P'[6,5]
 scalar `P66' = `P'[6,6]
 tempvar HM11 HM21 HM31 HM41 HM51 HM61
 tempvar HM12 HM22 HM32 HM42 HM52 HM62
 tempvar HM13 HM23 HM33 HM43 HM53 HM63
 tempvar HM14 HM24 HM34 HM44 HM54 HM64
 tempvar HMY1 HMY2 HMY3 HMY4 HMY5 HMY6
 gen double `HM11' = 2*`SUQVQM'*`P11'+2*`SVQWQM'*`P12'
 gen double `HM12' = -`SVQ2M'*`P11'-`SWQ2M'*`P12'
 gen double `HM13' = 1*`P11'+trace(`mtr')*`P12'
 gen `HM14' = 0
 gen double `HMY1' = `SUQ2M'*`P11'+`SVQ2M'*`P12'
 gen double `HM21' = 2*`SUQVQM'*`P21'+2*`SVQWQM'*`P22'+(`SVQ2M'+`SUQWQM')*`P23'
 gen double `HM22' = -`SVQ2M'*`P21'-`SWQ2M'*`P22'-`SVQWQM'*`P23'
 gen double `HM23' = 1*`P21'+trace(`mtr')*`P22'
 gen `HM24' = 0
 gen double `HMY2' = `SUQ2M'*`P21'+`SVQ2M'*`P22'+`SUQVQM'*`P23'
 gen double `HM31' = 2*`SVQWQM'*`P32'+(`SVQ2M'+`SUQWQM')*`P33'
 gen double `HM32' = -`SWQ2M'*`P32'-`SVQWQM'*`P33'
 gen double `HM33' = trace(`mtr')*`P32'
 gen `HM34' = 0
 gen double `HMY3' = `SVQ2M'*`P32'+`SUQVQM'*`P33'
 gen double `HM41' = 2*`SUQ1VQ1M'*`P44'+2*`SVQ1WQ1M'*`P45'
 gen double `HM42' = -`SVQ12M'*`P44'-`SWQ12M'*`P45'
 gen `HM43' = 0
 gen double `HM44' = 1*`P44'+trace(`mtr')*`P45'
 gen double `HMY4' = `SUQ12M'*`P44'+`SVQ12M'*`P45'
 gen double `HM51' = 2*`SUQ1VQ1M'*`P54'+2*`SVQ1WQ1M'*`P55'+(`SVQ12M'+`SUQ1WQ1M')*`P56'
 gen double `HM52' = -`SVQ12M'*`P54'-`SWQ12M'*`P55'-`SVQ1WQ1M'*`P56'
 gen `HM53' = 0
 gen double `HM54' = 1*`P54'+trace(`mtr')*`P55'
 gen double `HMY5' = `SUQ12M'*`P54'+`SVQ12M'*`P55'+`SUQ1VQ1M'*`P56'
 gen double `HM61' = 2*`SVQ1WQ1M'*`P65'+(`SVQ12M'+`SUQ1WQ1M')*`P66'
 gen double `HM62' = -`SWQ12M'*`P65'-`SVQ1WQ1M'*`P66'
 gen `HM63' = 0
 gen double `HM64' = trace(`mtr')*`P65'
 gen double `HMY6' = `SVQ12M'*`P65'+`SUQ1VQ1M'*`P66'
 collapse `HM11' `HM12' `HM13' `HM14' `HMY1' `HM21' `HM22' `HM23' `HM24' `HMY2' ///
 `HM31' `HM32' `HM33' `HM34' `HMY3' `HM41' `HM42' `HM43' `HM44' `HMY4' `HM51' ///
 `HM52' `HM53' `HM54' `HMY5' `HM61' `HM62' `HM63' `HM64' `HMY6'
 mkmat `HM11' `HM21' `HM31' `HM41' `HM51' `HM61' , matrix(`HM1t')
 mkmat `HM12' `HM22' `HM32' `HM42' `HM52' `HM62' , matrix(`HM2t')
 mkmat `HM13' `HM23' `HM33' `HM43' `HM53' `HM63' , matrix(`HM3t')
 mkmat `HM14' `HM24' `HM34' `HM44' `HM54' `HM64' , matrix(`HM4t')
 mkmat `HMY1' `HMY2' `HMY3' `HMY4' `HMY5' `HMY6' , matrix(`HMYt')
 matrix `HM1'=`HM1t''
 matrix `HM2'=`HM2t''
 matrix `HM3'=`HM3t''
 matrix `HM4'=`HM4t''
 matrix `HMY'=`HMYt''
 set obs 6
 tempvar V1 V2 V3 V4 Z1
 mata: `V1' = st_matrix("`HM1'")
 mata: `V2' = st_matrix("`HM2'")
 mata: `V3' = st_matrix("`HM3'")
 mata: `V4' = st_matrix("`HM4'")
 mata: `Z1' = st_matrix("`HMY'")
 getmata `V1' , force replace
 getmata `V2' , force replace
 getmata `V3' , force replace
 getmata `V4' , force replace
 getmata `Z1' , force replace
 nl (`Z1'=`V1'*{Rho}+`V2'*{Rho}^2+`V3'*{sigv}+`V4'*{sig1}), init(Rho 0 sigv 1 sig1 1) nolog
 scalar `RhoGM'=_b[/Rho]
 scalar `SIGVV'=_b[/sigv]
 scalar `SIG11'=_b[/sig1]
 }
 matrix `matg'=`matt'#(`mats'-`RhoGM'*`wmat')
 matrix `OMGINV' = (1/(`SIGVV'^0.5))*`Q0'+(1/(`SIG11'^0.5))*`Q1'
 restore 

 preserve

 gen `X0'=1
 local SPVAR "`X0' `yvar' `xvar'"
 foreach var of local SPVAR {
 mkmat `var' , matrix(`var')
 matrix `var'=`matg'*`var'
 matrix `var'=`OMGINV'*`var'
 mata: `var' = st_matrix("`var'")
 getmata `var' , replace force
 }
 bys `idv' : egen `Wip'=mean(`Wi')
 replace `Wi' = (`Wip')
 replace `Wis' = (`Wip')^2
 if "`wvar'"!="" {
 local wgt " [weight = `Wis'] "
 }
 else {
 local wgt ""
 }
 if `L'==1 {
noi di as txt "{bf:* Initial GMM Model: 1 }"
 }
 if `L'==2 {
noi di as txt "{bf:* Partial Weighted GMM Model: 2 }"
 }
 if `L'==3 {
noi di as txt "{bf:* Full Weighted GMM Model: 3 }"
 }
noi di _dup(37) "{bf:{err:-}}"
 mkmat `Wi' , matrix(`Wi')
 matrix `Wi'= diag(`Wi')
 if "`tobit'"!="" {
 xtset `idv' `itv'
 mkmat `yvar' , matrix(`Y')
 if "`noconstant'"!=""  { 
 mkmat `xvar' `aux' , matrix(`Z')
 xttobit `yvar' `xvar' `aux' `wgt' , noconstant `vce' ll(`ll') level(`level') ///
 iter(`iter') tech(`tech') `tobit'
 }
 else {
 mkmat `xvar' `aux' `X0' , matrix(`Z')
 xtset `idv' `itv'
 xttobit `yvar' `xvar' `aux' `X0' `wgt' , noconstant level(`level') ///
 `vce' ll(`ll') iter(`iter') tech(`tech') `tobit'
 }
 matrix `B'=e(b)
 matrix `B'=`B'[1,1..`kb']'
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 matrix `Cov'= e(V)
 matrix `Cov' =`Cov'[1..`kb', 1..`kb']
 ereturn scalar llf=e(ll)
 }
 else {
 gettoken _Yo _Zo : varlist
 gen double `Zo'= `Wi'
 mkmat `_Yo' , matrix(`Y')
 if "`noconstant'"!="" {
 mkmat `_Zo' `aux' , matrix(`Z')
 }
 else { 
 mkmat `_Zo' `aux' `X0' , matrix(`Z')
 }
 matrix `Yws'=`Y'
 matrix `Zws'=`Z'
 if "`wvar'"!="" {
 local Yw_Zw "`X0' `_Yo' `_Zo' `aux'"
 local kXw: word count `Yw_Zw'
 forvalue i=1/`kXw' {
 local v: word `i' of `Yw_Zw'
 replace `v' = `v'*`Wi'
 }
 local Zo "`Wi'"
 summ `Wi' 
 gen double `WiB' =r(mean)
 replace `Zo' = `WiB'
 mkmat `_Yo' , matrix(`Yws')
 if "`noconstant'"!="" {
 mkmat `_Zo' `aux' , matrix(`Zws')
 }
 else {
 mkmat `_Zo' `aux' `X0' , matrix(`Zws')
 }
 }
 local _Yw "`_Yo'"
 local _Zw "`_Zo'"
 matrix `Zz'=I(`kb')*0
 local Kr =`kr'
 if "`ridge'"!="" {
 local Ro1= 0
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
 unab ZSLSVar : `SLSVar'_* `aux' 
 tokenize `ZSLSVar'
 local ZoC `1'
 macro shift
 local ZSLSVar "`*'"
 replace `ZoC' = 0
 local _Zw "`_Zw' `aux'"
 if "`noconstant'"!="" {
 mkmat `ZSLSVar' , matrix(`Zr')
 tabstat `_Zw' , statistics( sd ) save
 }
 else {
 mkmat `ZSLSVar' `ZoC' , matrix(`Zr')
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
 local Kr=`kx'*`Sig2o1'/`BOLS1'
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
 local Kr=`kx'*`Sig2o1'/`BOLS1'
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
 local Kr=`Kit`i''
 if `Kr'==. {
 local Kr=0
 }
 scalar `Koi'=abs(`Kr'-`Ko')
 if (`Koi' <= 0.00001) {
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
 local Kr=0
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
cap matrix `IDRmk'=invsym(`f13')
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
 local Kr=`Kk'`i'
 if `Kr'==. {
 local Kr=0
 }
 scalar `Koi'=abs(`Kr'-`Ko')
 if (`Koi' <= 0.00001) {
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
 local Nof =`N'
 local Dof =`DF'
 matrix `B'=`B'
 ereturn post `B' `Cov' , dep(`yvar') obs(`Nof') dof(`Dof')
 if "`ridge'"!="" {
 ereturn scalar Kr=`Kr'
 }
 restore
 }
 }
 end


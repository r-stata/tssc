 program define spregxt32 , eclass 
 version 11.2
 syntax varlist , [idv(str) itv(str) gmm(str) be fe re ec2sls level(str) ///
 coll nosa vce(str) aux(str) order(str) endog(str) inst(str) wsxi(str)]
 qui {
 gettoken yvar xvar : varlist
 tempvar Time
 tempname NC NT
 gen `Time'=_n
 count 
 local N = r(N)
 xtset `idv' `itv'
 local NC=r(imax)
 local NT=r(tmax)
 local be `be'
 local fe `fe'
 local re `re'
 preserve
 local kb=e(kb)
 local Kr=e(Kr)
 tempvar ss2 u u2 RhoGM res res2 E E2 SSE Yh Ys Yh_ML Y Ue_ML vary vary2 varx varz2
 tempname matg h1 h1t h2 h2t h3 h3t HM1 HM1t HM2 HM2t HM3 HM3t HM4 HM4t HMY
 tempname HMYt hy Z0 hyt mats matj wmat wmat1 mtr MQ0 MQ1 MW1 MWT1 MWT2 MWT21
 tempname MW2 MW3 MW4 OMGINV Q0 Q1 P matt Q1UVEC UQVEC VCOV Q1VVEC WCS
 tempname VQVEC VVEC Q1WVEC WQVEC WVEC UVEC XB Bx BetaSP WS1 WS2 WS3 WS4
 tsset `Time'
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
 local inst "`wsxi' `inst'"
 local endog "w1y_`yvar' `endog'"
 xtset `idv' `itv'
 xtivreg `yvar' `xvar' `aux' (`endog' = `inst') , small ///
 `vce' `nosa' `be' `fe' `re' `ec2sls' level(`level')
 matrix `BetaSP'=e(b)
 matrix `Bx'=`BetaSP'[1,1..`kb']
 predict `Yh_ML' , xb
 gen double `res' =`yvar'-`Yh_ML'  
 gen double `res2'=`res'^2
 cap drop WY W1X_* W2X_*
 tempname L T1 T2
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
 tempvar US VS WS UQS VQS WQS UTS VTS WTS
 svmat double `UVEC', name(`US')
 svmat double `VVEC', name(`VS')
 svmat double `WVEC', name(`WS')
 svmat double `UQVEC', name(`UQS')
 svmat double `VQVEC', name(`VQS')
 svmat double `WQVEC', name(`WQS')
 svmat double `Q1UVEC' , name(`UTS')
 svmat double `Q1VVEC' , name(`VTS')
 svmat double `Q1WVEC' , name(`WTS')
 cap matrix drop `VVEC' `UVEC' `WVEC'
 cap matrix drop `UQVEC' `VQVEC' `WQVEC' `Q1UVEC' `Q1VVEC' `Q1WVEC'
 rename `US'1 `US'
 rename `VS'1 `VS'
 rename `WS'1 `WS'
 rename `UQS'1 `UQS'
 rename `VQS'1 `VQS'
 rename `WQS'1 `WQS'
 rename `UTS'1 `UTS'
 rename `VTS'1 `VTS'
 rename `WTS'1 `WTS'
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
 tempname SUQ2M SVQ2M SWQ2M SUQVQM SUQWQM SVQWQM SUQ12M
 tempname SVQ12M SWQ12M SUQ1VQ1M SUQ1WQ1M SVQ1WQ1M RhoH SIGV SIG1 VAR1 VAR2
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
 mkmat `h11' `h21' `h31', matrix(`h1t')
 mkmat `h12' `h22' `h32', matrix(`h2t')
 mkmat `h13' `h23' `h33', matrix(`h3t')
 mkmat `hy1' `hy2' `hy3', matrix(`hyt')
 matrix `h1'=`h1t''
 matrix `h2'=`h2t''
 matrix `h3'=`h3t''
 matrix `hy'=`hyt''
 set obs 3
 tempvar V1 V2 V3 Z
 svmat double `h1' , name(`V1')
 svmat double `h2' , name(`V2')
 svmat double `h3' , name(`V3')
 svmat double `hy' , name(`Z')
 rename `V1'1 `V1'
 rename `V2'1 `V2'
 rename `V3'1 `V3'
 rename `Z'1 `Z'
 nl (`Z'=`V1'*{Rho} +`V2'*{Rho}^2 +`V3'*{Sigma2}) , init(Rho 0.3 Sigma2 1) nolog
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
 tempname P11 P22 P33 P44 P55 P66 P12 P23 P45 P56
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
 gen double `HM21' = 2*`SUQVQM'*P21+2*`SVQWQM'*`P22'+(`SVQ2M'+`SUQWQM')*`P23'
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
 gen double `HM44' = 1*P44+trace(`mtr')*`P45'
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
 mkmat `HM11' `HM21' `HM31' `HM41' `HM51' `HM61', matrix(`HM1t')
 mkmat `HM12' `HM22' `HM32' `HM42' `HM52' `HM62', matrix(`HM2t')
 mkmat `HM13' `HM23' `HM33' `HM43' `HM53' `HM63', matrix(`HM3t')
 mkmat `HM14' `HM24' `HM34' `HM44' `HM54' `HM64', matrix(`HM4t')
 mkmat `HMY1' `HMY2' `HMY3' `HMY4' `HMY5' `HMY6', matrix(`HMYt')
 matrix `HM1'=`HM1t''
 matrix `HM2'=`HM2t''
 matrix `HM3'=`HM3t''
 matrix `HM4'=`HM4t''
 matrix `HMY'=`HMYt''
 set obs 6
 tempvar V1 V2 V3 V4 Z
 svmat double `HM1' , name(`V1')
 svmat double `HM2' , name(`V2')
 svmat double `HM3' , name(`V3')
 svmat double `HM4' , name(`V4')
 svmat double `HMY' , name(`Z')
 rename `V1'1 `V1'
 rename `V2'1 `V2'
 rename `V3'1 `V3'
 rename `V4'1 `V4'
 rename `Z'1 `Z'
 nl (`Z'=`V1'*{Rho}+`V2'*{Rho}^2+`V3'*{sigv}+`V4'*{sig1}), init(Rho 0 sigv 1 sig1 1) nolog
 scalar `RhoGM'=_b[/Rho]
 scalar `SIGVV'=_b[/sigv]
 scalar `SIG11'=_b[/sig1]
 }
 matrix `matg'=`matt'#(`mats'-`RhoGM'*`wmat')
 matrix `OMGINV' = (1/(`SIGVV'^0.5))*`Q0'+(1/(`SIG11'^0.5))*`Q1'
 restore 
 preserve
 local SPVAR "`yvar' `xvar' `endog' `inst'"
 foreach var of local SPVAR {
 mkmat `var' , matrix(`var')
 matrix `var'=`matg'*`var'
 matrix `var'=`OMGINV'*`var'
 mata: `var' = st_matrix("`var'")
 getmata `var' , replace force
 }
 if `L'==1 {
di as txt _col(3) "{bf:* Initial GMM Model: 1 }"
 }
 if `L'==2 {
di as txt _col(3) "{bf:* Partial Weighted GMM Model: 2 }"
 }
 if `L'==3 {
di as txt _col(3) "{bf:* Full Weighted GMM Model: 3 }"
 }
 xtset `idv' `itv'
 xtivreg `yvar' `xvar' `aux' (`endog' = `inst') , small ///
 `vce' `nosa' `be' `fe' `re' `ec2sls' level(`level')
 restore
 }
 end


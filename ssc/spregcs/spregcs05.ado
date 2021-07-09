 program define spregcs05 , eclass byable(onecall)
 version 11.2
 syntax varlist , [NOCONStant vce(passthru) var2(str) inst(str) ///
 EQ(int 1) ORDer(str) ols 2sls 3sls sure mvreg first aux(str) wit(str)]

 qui {
 tempvar X0 E1 E2 y1 y2 Time X01 X02 _cons1 _cons2
 tempname X0 E1 E2 y1 y2 wmat w1x w2x w3x w4x N X3SLS1 X3SLS2 kb N Rho1 Rho2 k0
 local varlist1 "`varlist'"
 local varlist2 "`var2'"
 gettoken y1 xvar1 : varlist1
 gettoken y2 xvar2 : varlist2
 local xvar "`xvar1' `xvar2'"
 _rmcoll `xvar' , `noconstant' forcedrop
 local xvar "`r(varlist)'"
 _rmcoll `xvar' `aux' `inst' , `noconstant' forcedrop
 local instx "`r(varlist)'"
 scalar `kb'=e(kb)
 scalar `N'=e(Nn)
 gen `Time' =_n 
 tsset `Time'
 matrix `wmat'=WMB
 if "`noconstant'"!="" {
 scalar `k0'=0
 local X0 ""
 }
 else {
 scalar `k0'=1
 gen `X0'=1
 mkmat `X0', matrix(`X0')
 }
 local wgt ""
 if "`wvar'"!="" {
 local wgt " [weight = `wit'] "
 }
 local WsY1 "w1y_`y1'"
 local WsY2 "w1y_`y2'"
 local SPXvar1 "`WsY1' `WsY2' `y2' `xvar1' `aux'"
 local SPXvar2 "`WsY1' `WsY2' `y1' `xvar2' `aux'"
 mkmat `SPXvar1' `X0' , matrix(`X3SLS1')
 mkmat `SPXvar2' `X0' , matrix(`X3SLS2')
 if "`eq'"=="2" {
 local SPXvar "`SPXvar2'"
 }
 else {
 local SPXvar "`SPXvar1'"
 }
 mkmat `SPXvar1' `X0' , matrix(`X3SLS1')
 mkmat `SPXvar2' `X0' , matrix(`X3SLS2')
 local xWvar1 : list instx-aux
 local xWvar : list xWvar1-xvar

 preserve
 ivregress 2sls `varlist1' `aux' `wgt' (`WsY1' `WsY2' `y2'= `xWvar') , `noconstant'
 predict `E1' , resid
 ivregress 2sls `varlist2' `aux' `wgt' (`WsY1' `WsY2' `y1'= `xWvar') , `noconstant'
 predict `E2' , resid
 mkmat `E1' , matrix(`E1')
 mkmat `E2' , matrix(`E2')
 forvalue i=1/2 {
 tempvar u2h v2h uvh vwh uwh u2hm v2hm uvhm vwhm uwhm E
 tempvar w2h w2hm h11 h12 h13 hy1 h21 h22 h23 hy2 h31 h32 h33 hy3 uh vh wh
 tempname MMM vh wh
 matrix `vh'=`wmat'*`E`i''
 matrix `wh'=`wmat'*`vh'
 mata: `uh' = st_matrix("`E`i''")
 mata: `vh' = st_matrix("`vh'")
 mata: `wh' = st_matrix("`wh'")
 getmata `uh' , force replace
 getmata `vh' , force replace
 getmata `wh' , force replace
 gen double `u2h'=`uh'*`uh'
 gen double `v2h'=`vh'*`vh'
 gen double `uvh'=`uh'*`vh'
 gen double `vwh'=`vh'*`wh'
 gen double `w2h'=`wh'*`wh'
 gen double `uwh'=`uh'*`wh'
 matrix `MMM'=trace(`wmat''*`wmat')/`N'
 egen double `u2hm' = mean(`u2h')
 egen double `v2hm' = mean(`v2h')
 egen double `uvhm' = mean(`uvh')
 egen double `vwhm' = mean(`vwh')
 egen double `w2hm' = mean(`w2h')
 egen double `uwhm' = mean(`uwh')
 gen double `h11'=-2*`uvhm'
 gen double `h12'=`v2hm'
 gen `h13'=-1
 gen double `h21'=-2*`vwhm'
 gen double `h22'=`w2hm'
 gen double `h23'=-trace(`MMM')
 gen double `h31'=-(`v2hm'+`uwhm')
 gen double `h32'=`vwhm'
 gen `h33'=0
 gen double `hy1'=-`u2hm'
 gen double `hy2'=-`v2hm'
 gen double `hy3'=-`uvhm'
 tempvar Z1 V1 V2 V3
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
 mata: `V1' = st_matrix("`h1'")
 mata: `V2' = st_matrix("`h2'")
 mata: `V3' = st_matrix("`h3'")
 mata: `Z1' = st_matrix("`hy'")
 getmata `V1' , force replace
 getmata `V2' , force replace
 getmata `V3' , force replace
 getmata `Z1' , force replace
 nl (`Z1'=`V1'*{Rho}+`V2'*{Rho}^2+`V3'*{Sigma2}) , init(Rho 0.7 Sigma2 1) nolog
 scalar Rho`i'=_b[/Rho]
 }
 restore 
 scalar `Rho1'=Rho1
 scalar `Rho2'=Rho2
 preserve
 cap drop w1x_*
 cap drop w2x_*
 cap drop w3x_*
 cap drop w4x_*
 local SPv1 ""
 local SPv2 ""
 local SPXv1 "`y1' `WsY1' `WsY2' `y2'"
 local SPXv2 "`y2' `WsY1' `WsY2' `y1'"
 forvalue i=1/2 {
 foreach var of local SPXv`i' {
 mkmat `var', matrix(`var')
 matrix `var' =`var' -`Rho`i''*`wmat'*`var'
 mata: `var'_`i' = st_matrix("`var'")
 getmata `var'_`i' , force replace
 local SPv`i' "`SPv`i'' `var'_`i'"
 }
 }
 local SPx1 ""
 local SPx2 ""
 local SPXx1 "`xvar1'"
 local SPXx2 "`xvar2'"
 forvalue i=1/2 {
 foreach var of local SPXx`i' {
 mkmat `var', matrix(`var')
 matrix `var' =`var' -`Rho`i''*`wmat'*`var'
 mata: `var'_`i' = st_matrix("`var'")
 getmata `var'_`i' , force replace
 local SPx`i' "`SPx`i'' `var'_`i'"
 }
 }
 if "`noconstant'"!="" {
 local X01 ""
 local X02 ""
 }
 else {
 gen `X01'=1
 gen `X02'=1
 local SPX01 "`X01'"
 local SPX02 "`X02'"
 forvalue i=1/2 {
 foreach var of local SPX0`i' {
 mkmat `var', matrix(`var')
 matrix `var' =`var' -`Rho`i''*`wmat'*`var'
 mata: `var' = st_matrix("`var'")
 getmata `var' , force replace
 }
 }
 rename `X01' _cons1
 rename `X02' _cons2
 }
 forvalue i=1/2 {
 foreach var of local SPx`i' {
 mkmat `var', matrix(`var')
 matrix `w1x'= `wmat'*`var'
 matrix `w2x'= `wmat'*`w1x'
 matrix `w3x'= `wmat'*`w2x'
 matrix `w4x'= `wmat'*`w3x'
 mata: w1x_`i'_`var' = st_matrix("`w1x'")
 mata: w2x_`i'_`var' = st_matrix("`w2x'")
 mata: w3x_`i'_`var' = st_matrix("`w3x'")
 mata: w4x_`i'_`var' = st_matrix("`w4x'")
 getmata w1x_`i'_`var' , force replace
 getmata w2x_`i'_`var' , force replace
 getmata w3x_`i'_`var' , force replace
 getmata w4x_`i'_`var' , force replace
 }
 }
 if "`order'"=="1" {
 cap drop w2x_*
 cap drop w3x_*
 cap drop w4x_*
 local instx "w1x_1_* w1x_2_* `aux'"
 }
 if "`order'"=="2" {
 cap drop w3x_*
 cap drop w4x_*
 local instx "w1x_1_* w1x_2_* w2x_1_* w2x_2_* `aux'"
 }
 if "`order'"=="3" {
 cap drop w4x_*
 local instx "w1x_1_* w1x_2_* w2x_1_* w2x_2_* w3x_1_* w3x_2_* `aux'"
 }
 if "`order'"=="4" {
 local instx "w1x_1_* w1x_2_* w2x_1_* w2x_2_* w3x_1_* w3x_2_* w4x_1_* w4x_2_* `aux'"
 }
 local N2N=2*`N'
 set matsize `N2N'
 if "`noconstant'"!="" {
 local instx "`SPx1' `SPx2' `instx'"
noi reg3 (`SPv1' `SPx1' `aux' , noconstant) (`SPv2' `SPx2' `aux' , noconstant) , ///
 endog(`SPv1' `SPv2') exog(`instx') noconstant ///
 small `ols' `2sls' `3sls' `sure' `mvreg' `first' `vce'
 }
 else {
 local instx "`SPx1' `SPx2' `instx' _cons1 _cons2"
noi reg3 (`SPv1' `SPx1' `aux' _cons1 , noconstant) (`SPv2' `SPx2' `aux' _cons2 , noconstant) , ///
 endog(`SPv1' `SPv2') exog(`instx') noconstant ///
 small `ols' `2sls' `3sls' `sure' `mvreg' `first' `vce'
 }

 restore
 tempname Omega BS SSE1 SSE2 SSE3 MSS1 MSS2 MSS3 SST1 SST2 SST3 ks
 tempname aic sc PF B3SLS1 B3SLS2 y1s y2s YMAT RSQ SSE1 SSE2 SSE3
 tempname MSS1 MSS2 Sig Sig21 MSS3 SST1 SST2 SST3 Ybv Yb Yv Yb_Y1 Yb_Y2 Sig2 Y
 tempname YM RS1 RS2 RS3 k1 k2 Ro ADR F kb21 kb2 K Q DF1 DF2 DFF DFChi LSig2 Ev E
 tempname W LLF df1 df2 Chi PChi kb N kb1 kb2 Kx XB1 XB2 Eu1 Eu2
 matrix `BS'=e(b)
 local N=e(N)
 scalar `k1'=e(df_m1)
 scalar `k2'=e(df_m2)
 scalar `kb1'=`k1'
 scalar `kb2'=`k2'
 scalar `K'=e(k)
 scalar `Q'=2
 scalar `DF1'=`k1'+`k2'-2*`k0'
 scalar `DF2'=`Q'*`N'-(`k1'+`k2'-2*`k0')
 scalar `DFF'=(`Q'*`N'-`DF1')/`DF1'
 scalar `DFChi'=`DF1'
 scalar `ks'=`kb1'+1
 matrix `B3SLS1'=`BS'[1,1..`kb1']
 matrix `B3SLS2'=`BS'[1,`ks'..`kb1'+`kb2']
 forvalue i=1/2 {
 tempname r2h`i' r2h_a`i' fth`i' fth`i'p llf`i' aic`i' sc`i' Sig`i' df`i'
 scalar `df`i''1=`kb`i''-`k0'
 scalar `df`i''2=e(N)-`kb`i''-`k0'
 scalar `r2h`i''=e(r2_`i')
 scalar `r2h_a`i''=1-((1-e(r2_`i'))*(e(N)-1)/(e(N)-`kb`i''))
 scalar `fth`i''=`r2h`i''/(1-`r2h`i'')*(e(N)-`kb`i''-`k0')/(`kb`i''-`k0')
 scalar `fth`i'p'=Ftail(`df`i''1, `df`i''2,`fth`i'')
 scalar `llf`i''=-(e(N)/2)*log(2*_pi*e(rss_`i')/e(N))-(e(N)/2)
 scalar `aic`i''= 2*(`kb`i'')-2*`llf`i''
 scalar `sc`i''=(`kb`i'')*ln(e(N))-2*`llf`i''
 scalar `Sig`i''=e(rmse_`i')
 mkmat `y`i'' , matrix(`y`i'')
 matrix `XB`i''=`X3SLS`i''*`B3SLS`i'''
 matrix `Eu`i''=`y`i''-`XB`i''
 if "`noconstant'"!="" {
 gen double `Yb_Y`i'' = `y`i'' 
 }
 else {
 summ `y`i''
 gen double `Yb_Y`i'' = `y`i'' - `r(mean)'
 }
 }
noi di as txt _col(25) "{cmd:Yij = LHS Y(i) in Eq.(j)}"
noi di as txt "{cmd:EQ1:} R2=" %7.4f `r2h1' " - R2 Adj.=" %7.4f `r2h_a1' "  F-Test =" _col(42) %9.3f `fth1' _col(56) "P-Value> F("`df1'1 ", " `df1'2 ")" %5.3f _col(74) `fthp1'
noi di as txt "    LLF=" %10.3f `llf1' _col(22) "AIC =" %9.3f `aic1' _col(40) "SC =" %9.3f `sc1' _col(56) "Root MSE =" %8.4f `Sig1'
noi di _dup(73) "{bf:-}"
noi di as txt "{cmd:EQ2:} R2=" %7.4f `r2h2' " - R2 Adj.=" %7.4f `r2h_a2' "  F-Test =" _col(42) %9.3f `fth2' _col(56) "P-Value> F("`df2'1 ", " `df2'2 ")" %5.3f _col(74) `fthp2'
noi di as txt "    LLF=" %10.3f `llf2' _col(22) "AIC =" %9.3f `aic2' _col(40) "SC =" %9.3f `sc2' _col(56) "Root MSE =" %8.4f `Sig2'
noi di "{hline 78}"
 local N2N=2*`N'
 set matsize `N2N'
 matrix `E'=`Eu1',`Eu2'
 matrix `Omega'=inv(`E''*`E'/`N')
 mkmat `Yb_Y1' `Yb_Y2' , matrix(`Yb')
 matrix `Ybv'=vec(`Yb')
 matrix `Y'=`y1',`y2'
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
 forvalues i = 1/3 {
 tempname Ro`i'
 matrix `MSS`i''=`SST`i''-`SSE`i''
 matrix R`i'=1-(`SSE`i''*inv(`SST`i''))
 scalar `Ro`i''=R`i'[1,1]
 }
 forvalues i = 1/3 {
 tempname ADR`i' F`i' Chi`i' PChi`i' PF`i'
 scalar `ADR`i''=1-(1-`Ro`i'')*((`Q'*`N'-`Q')/(`Q'*`N'-`K'))
 scalar `F`i''=`Ro`i''/(1-`Ro`i'')*`DFF'
 scalar `Chi`i''= -`N'*(log(1-`Ro`i''))
 scalar `PChi`i''= chi2tail(`DFChi', `Chi`i'')
 scalar `PF`i''= Ftail(`DF1',`DF2', `F`i'')
 }
 set matsize `N'
 drop if `y1' ==.
 scalar `LSig2'=log(`Sig21')
 scalar `LLF'=-(`N'*`Q'/2)*(1+log(2*_pi))-(`N'/2*abs(`LSig2'))
 matrix `RS1'=`Ro1',`ADR1',`F1',`PF1',`Chi1',`PChi1'
 matrix `RS2'=`Ro2',`ADR2',`F2',`PF2',`Chi2',`PChi2'
 matrix `RS3'=`Ro3',`ADR3',`F3',`PF3',`Chi3',`PChi3'
 matrix `RSQ'=`RS1' \ `RS2' \ `RS3'
 matrix rownames `RSQ' = Berndt McElroy Judge
 matrix colnames `RSQ' = R2 Adj_R2 F "P-Value" Chi2 "P-Value"
noi matlist `RSQ', title({cmd:- Overall System R2 - Adjusted R2 - F Test - Chi2 Test}) twidth(8) border(all) lines(columns) rowtitle(Name) format(%8.4f)
noi di as txt "  Number of Parameters         =" _col(35) %10.0f `K'
noi di as txt "  Number of Equations          =" _col(35) %10.0f `Q'
noi di as txt "  Degrees of Freedom F-Test    =" _col(39) "(" `DF1' ", " `DF2' ")"
noi di as txt "  Degrees of Freedom Chi2-Test =" _col(35) %10.0f `DFChi'
noi di as txt "  Log Determinant of Sigma     =" _col(35) %10.4f `LSig2'
noi di as txt "  Log Likelihood Function      =" _col(35) %10.4f `LLF'
noi di
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
* ereturn matrix X3SLS1=`X3SLS1'
* ereturn matrix X3SLS2=`X3SLS2'
* ereturn matrix Y1_ML=`y1'
* ereturn matrix Y2_ML=`y2'
 }
 end


*! almon1 V1.0 07/06/2015
*! 
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

program define almon1 , eclass sortpreserve byable(recall)
 version 11.2
 syntax varlist [if] [in] , [ Model(str) LAG(int 3) PDL(int 2) ENDpr(int 0) NOLag ///
 NOCONSTant ITERate(int 300) TECHnique(str) diag Level(passthru) VCE(passthru) ///
 PREDict(str) RESid(str) mfx(str) tolog dn test OMInv WVAR(str) ORDer(int 1)]
di
 marksample touse
 markout `touse'
 gettoken yvar xvar : varlist
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
 if `lag' <= `pdl' {
di as err " {bf:Lag Length {cmd:lag(#)} must be greater than Polynomial Degree {cmd:pdl(#)} by at lesat (1)}"
 exit
 }
 if "`model'"!="" {
 if !inlist("`model'", "als", "gls", "ols", "arch") {
di as err " {bf:model( )} {cmd:must be} {bf:model({it:als, ols, arch})}"
di as err " {bf:model({it:ols})}  {cmd:Ordinary Least Squares (OLS)}"
di as err " {bf:model({it:als})}  {cmd:Autoregressive Least Squares (ALS)}"
di as err " {bf:model({it:gls})}  {cmd:Generalized Least Squares (GLS)}"
di as err " {bf:model({it:arch})} {cmd:Autoregressive Conditional Heteroskedasticity (ARCH)}"
 exit
 }
 }
 if inlist("`model'", "gls") & "`wvar'"=="" {
di
di as err " {bf:wvar({it:var name})} {cmd:must be combine with:} {bf:model({it:gsls})}"
 exit
 }
 if "`endpr'"!="" {
 if !inlist("`endpr'", "0", "1", "2", "3") {
di as err " {bf:endpr( )} {cmd:Endpoint Restriction must be} {bf:model({it:0, 1, 2, 3})}"
di as err " {bf:endpr({it:0})} {cmd:No Endpoint Polynomial Restrictions}"
di as err " {bf:endpr({it:1})} {cmd:Left Side Endpoint Polynomial Restrictions}"
di as err " {bf:endpr({it:2})} {cmd:Right Side Endpoint Polynomial Restrictions}"
di as err " {bf:endpr({it:3})} {cmd:Left & Right Side Endpoint Restrictions of Polynomial}"
 exit
 }
 }
 if "`mfx'"!="" {
 if !inlist("`mfx'", "lin", "log") {
di as err " {bf:mfx( )} {cmd:must be} {bf:mfx({it:lin})} {cmd:for Linear Model, or} {bf:mfx({it:log})} {cmd:for Log-Log Model}"
 exit
 }
 }
 local nolog ""
 local itern ""
 local itern1 ""
 local techn ""
 if inlist("`model'", "als") {
 local mtitle "Autoregressive Least Squares (ALS)"
 local Model "ALS"
 local run "arima"
 local wgt ""
 local nolog "nolog"
 local auto "ar(1/`order')"
 local itern "iterate(`iterate')"
 local itern1 "iterate(3)"
 local techn "technique(`technique')"
 }
 if inlist("`model'", "arch") {
 local mtitle "Autoregressive Conditional Heteroskedasticity (ARCH)"
 local Model "ARCH"
 local run " arch "
 local wgt ""
 local nolog "nolog"
 local auto " arch(1/`order') "
 local itern "iterate(`iterate')"
 local itern1 "iterate(3)"
 local techn "technique(`technique')"
 }
 if inlist("`model'", "gls") {
 local mtitle "Generalized Least Squares (GLS)"
 local wgt "[weight=1/`wvar']"
 if "`ominv'"!="" {
 local wgt "[weight=`wvar']"
 }
 local Model "GLS"
 local run "cnsreg"
 if `pdl' == 0 {
 local run "reg"
 }
 }
 if !inlist("`model'", "als", "gls", "arch") {
 local mtitle "Ordinary Least Squares (OLS)"
 local Model "OLS"
 local run "cnsreg"
 if `pdl' == 0 {
 local run " reg "
 }
 }

di _dup(78) "{bf:{err:=}}"
di as txt _col(15) "{bf:{err:*** Shirley Almon Polynomial Distributed Lag Model ***}}"
di _dup(78) "{bf:{err:=}}"
di as err _col(2) "*** `mtitle' ***"
 if inlist("`endpr'", "0") {
di as err _col(2) "*** {bf:{cmd:No Endpoint Polynomial Restrictions}} ***"
 }
 if inlist("`endpr'", "1") {
di as err _col(2) "*** {bf:{cmd:Left Side Endpoint Polynomial Restrictions}} ***"
 }
 if inlist("`endpr'", "2") {
di as err _col(2) "*** {bf:{cmd:Right Side Endpoint Polynomial Restrictions}} ***"
 }
 if inlist("`endpr'", "3") {
di as err _col(2) "*** {bf:{cmd:Left & Right Side Endpoint Polynomial Restrictions}} ***"
 }
di _dup(78) "{bf:{err:-}}"
di as err  "- Lag Length: {bf:{cmd:Lag(`lag')}} - Polynomial Degree {bf:{cmd:PDL(`pdl')}} - Endpoint Restriction {bf:{cmd:End(`endpr')}}"
di "{cmd:{hline 78}}"

qui {
tempvar DE DF1 SSE weit Wi YYm YYv Wio WS X0 Yb Yh_ML Ue_ML yvarm MSE Time TimeN _Xx_ miss v
tempname B D IPhi J K L M M1 M2 NY OM P Phi Pm Q MSE Sig2n Sig2o cmat r2v r2v_a
tempname cmat0 cmatl cmatr cmatlr V W W1 We Wi Wi1 Wio Y kx DF kb AIC2 SC2  VCov
tempname llf SST1 SST2 SSE SSEo Sigo r2bu r2bu_a r2raw r2raw_a f fp Beta Bx
tempname fv fvp r2h r2h_a fh fhp SSTm SSE1 SST11 SST21 Rho wald waldp AIC1 SC1

 gen `TimeN'=_n
 tsset `TimeN'
 preserve
 gen `Time'=_n if `touse'
 tsset `Time'
 local NT=r(tmax)
 if "`nolag'"=="" {
 foreach var of local xvar {
 gen double `_Xx_'`var' = L1.`var'
 replace `var' = `_Xx_'`var'
 }
 }
 local kz : word count `xvar'
 local j =0
 local Bz=`kz'*(`lag'+1)
 if "`tolog'"!="" {
 local vlistlog " `yvar' `xvar' `wvar'"
 _rmcoll `vlistlog' , `noconstant' forcedrop
 local vlistlog "`r(varlist)'"
noi di as err " {cmd:** Data Have been Transformed to Log Form **}"
noi di as txt " {cmd:** `yvar' `xvar' `wvar'} "
noi di _dup(78) "-"
 local kvlog: word count `vlistlog'
 forvalue i=1/`kvlog' {
 tempvar xyind_`i'
 local var: word `i' of `vlistlog'
 gen double `xyind_`i''=`var'
 replace `var'=ln(`var')
 }
 }
 constraint drop _all
 local ZVar ""
 local NXvar ""
 foreach var of local xvar {
 tsunab LVar : L(0/`lag').(`var')
 local var1 `LVar'
 local ZVar "`ZVar' `var1'"
 local NXvar "`NXvar' `var1'"
 local G=`lag'+1
 if `pdl' > 0 {
 Poly , rmat(`cmat0') p(`lag') q(`pdl') order(`order') `noconstant' model(`model')
 local kcl= colsof(`cmat0')
 local krr= `lag'-`pdl'
 local kr = rowsof(`cmat0')
 local kcr= `kcl'-`krr'-2
 if "`endpr'"!="" {
 if inlist("`endpr'", "1") {
 matrix `cmatl' = `cmat0'[1..1,2..`kcl'],J(1,1,0)
 matrix `cmat'=`cmat0' \ `cmatl'
 }
 if inlist("`endpr'", "2") {
 matrix `cmatr' = J(1,`krr',0), `cmat0'[1..1,1..`kcr'], J(1,2,0)
 matrix `cmat'=`cmat0' \ `cmatr'
 }
 if inlist("`endpr'", "3") {
 matrix `cmatl' = `cmat0'[1..1,2..`kcl'],J(1,1,0)
 matrix `cmatr' = J(1,`krr',0), `cmat0'[1..1,1..`kcr'], J(1,2,0)
 matrix `cmat'=`cmat0' \ `cmatl' \ `cmatr'
 }
 }
 if !inlist("`endpr'", "1", "2", "3") {
 matrix `cmat'=`cmat0'
 local endpr "endpr(0)"
 }
 local k = rowsof(`cmat')
 `run' `yvar' `var1' , constr(`cmat') `noconstant' `auto' `itern1' `techn' `nolog'
 local Qw = `kz'*`k'
 local Qbw=`kz'*(`lag'-`pdl'+2)
 matrix dispCns , r
 forvalue i = 1/`k' {
 local j =`j'+1
 constraint define `j' `=r(cns`i')'
 local i =`i'+1
 } 
 }
 }
 tsset `Time'
 if `pdl' == 0 {
 `run' `yvar' `ZVar' `wgt' if `touse' , `noconstant' `vce' `level' `nolog' `auto' `itern' `techn'
 }
 else {
 `run' `yvar' `ZVar' `wgt' if `touse' , `noconstant' `vce' `level' `nolog' `auto' `itern' `techn' constr(1-`Qw')
 }
 if inlist("`model'", "als", "arch") {
 local NT1= e(tmin)
 local NT2= e(tmax)
 }
 if !inlist("`model'", "als", "arch") {
 local NT1=`lag'+1
 local NT2=`NT'
 }
 if inlist("`model'", "als") {
 local DF=e(N) - e(k1)
 }
 if inlist("`model'", "arch") {
 local DF=e(ic)
 }
 if !inlist("`model'", "als", "arch") {
 local DF=e(df_r)
 }
 local ZVar ""
 local kxz=`lag'+1
 foreach var of local xvar {
 tsunab MVar : L(0/`lag').(`var')
 forvalue i = 1/`kxz' {
 local v: word `i' of `MVar'
 tempvar v`i'
 gen double `v`i'' = `v'
 local ZVar "`ZVar' `v`i''"
 }
 }
 unab ZVar: `ZVar'*
 if inlist("`model'", "als", "arch") {
 predict double `Yh_ML' , y
 }
 if !inlist("`model'", "als", "arch") {
 predict double `Yh_ML' , xb
 }
 predict double `Ue_ML' , resid
 markout `touse' `yvar' `ZVar' `wvar' `Ue_ML' `Yh_ML'
 keep if `touse'
 mark `miss'
 markout `miss' `yvar' `ZVar' `wvar' `Ue_ML' `Yh_ML'
 keep if `miss' == 1
 replace `Time'=_n
 tsset `Time'
 count 
 local N=r(N)
 mkmat `Ue_ML' , matrix(`Ue_ML')
 gen `Wi'=1
 gen `weit' = 1
 if inlist("`model'", "gls") {
 replace `Wi' =1/(`wvar')^0.5
 if "`ominv'"!="" {
 replace `Wi' =(`wvar')^0.5
 }
 }
 replace `weit' =`Wi'^2
 mkmat `Wi' , matrix(`Wi')
 matrix `Wi'=diag(`Wi')
 if "`noconstant'" != "" {
 local kb=e(df_m)
 }
 else {
 local kb=e(df_m)+1
 }
 local kx=e(df_m)
 gen double `yvarm' = `yvar' 
 mkmat `yvarm' , matrix(`Y')
 matrix `SSE'=`Ue_ML''*`Ue_ML'
 local SSEo =`SSE'[1,1]
 if "`dn'" != "" {
 local DF=`N'
 }
 if inlist("`model'", "als") {
 scalar `Sigo'=e(sigma)
 scalar `Sig2o'=`SSEo'/`DF'
 scalar `Sig2n'=`SSEo'/`N'
 }
 if inlist("`model'", "arch") {
 scalar `Sigo'=e(archi)^0.5
 scalar `Sig2o'=`SSEo'/`DF'
 scalar `Sig2n'=`SSEo'/`N'
 }
 if !inlist("`model'", "als", "arch") {
 scalar `Sigo'=e(rmse)
 scalar `Sig2o'=`SSEo'/`DF'
 scalar `Sig2n'=`SSEo'/`N'
 }
 summ `Yh_ML'
 local NUM=r(Var)
 summ `yvar'
 local DEN=r(Var)
 scalar `r2v'=`NUM'/`DEN'
 scalar `r2v_a'=1-((1-`r2v')*(`N'-1)/`DF')
 scalar `fv'=`r2v'/(1-`r2v')*(`N'-`kb')/(`kx')
 scalar `fvp'=Ftail(`kx', `DF', `fv')
 correlate `Yh_ML' `yvar'
 scalar `r2h'=r(rho)*r(rho)
 scalar `r2h_a'=1-((1-`r2h')*(`N'-1)/`DF')
 scalar `fh'=`r2h'/(1-`r2h')*(`N'-`kb')/(`kx')
 scalar `fhp'=Ftail(`kx', `DF', `fh')
 summ `yvar'
 local Yb=r(mean)
 gen double `YYm'=(`yvar'-`Yb')^2
 summ `YYm'
 scalar `SSTm' = r(sum)
 gen double `YYv'=(`yvar')^2
 summ `YYv'
 local SSTv = r(sum)
 summ `weit' 
 gen double `Wi1'=sqrt(`weit'/r(mean))
 mkmat `Wi1' , matrix(`Wi1')
 matrix `P' =diag(`Wi1')
 gen double `Wio'=(`Wi1') 
 mkmat `Wio' , matrix(`Wio')
 matrix `Wio'=diag(`Wio')
 matrix `Pm' =`Wio'
 matrix `IPhi'=`P''*`P'
 matrix `Phi'=inv(`P''*`P')
 matrix `J'= J(`N',1,1)
 matrix `D'=(`J'*`J''*`IPhi')/`N'
 matrix `SSE'=`Ue_ML''*`IPhi'*`Ue_ML'
 matrix `SST1'=(`Y'-`D'*`Y')'*`IPhi'*(`Y'-`D'*`Y')
 matrix `SST2'=(`Y''*`Y')
 scalar `SSE1'=`SSE'[1,1]
 scalar `SST11'=`SST1'[1,1]
 scalar `SST21'=`SST2'[1,1]
 scalar `r2bu'=1-`SSE1'/`SST11'
 if `r2bu' == . {
 scalar `r2bu'=`r2h'
 }
 else if `r2bu'< 0 {
 scalar `r2bu'=`r2h'
 }
 scalar `r2bu_a'=1-((1-`r2bu')*(`N'-1)/`DF')
 scalar `r2raw'=1-`SSE1'/`SST21'
 scalar `r2raw_a'=1-((1-`r2raw')*(`N'-1)/`DF')
 scalar `f'=`r2bu'/(1-`r2bu')*(`N'-`kb')/`kx'
 if "`noconstant'"!="" {
 scalar `r2bu'=`r2raw'2
 scalar `r2bu_a'=1-((1-`r2bu')*(`N'-1)/`DF')
 scalar `f'=`r2bu'/(1-`r2bu')*(`N'-`kx')/`kx'
 }
 if inlist("`model'", "als", "arch") {
 scalar `wald'=e(chi2)
 scalar `waldp'=chi2tail(`kx', abs(`wald'))
 scalar `f'=`wald'/`kx'
 }
 else {
 scalar `wald'=`f'*`kx'
 scalar `waldp'=chi2tail(`kx', abs(`wald'))
 }
 scalar `fp'= Ftail(`kx', `DF', `f')
 scalar `llf'=e(ll)
 if inlist("`model'", "gls") {
 tempname Ew SSEw SSEw1 Sig2nw LWi21 LWi2
 matrix `Ew'=`Wi'*`Ue_ML'
 matrix `SSEw'=(`Ew''*`Ew')
 scalar `SSEw1'=`SSEw'[1,1]
 scalar `Sig2nw'=`SSEw1'/`N'
 gen double `LWi2'= 0.5*ln(`Wi'^2)
 summ `LWi2'
 scalar `LWi21'=r(sum)
 scalar `llf'=-`N'/2*ln(2*_pi*`Sig2nw')+`LWi21'-(`N'/2)
 }

noi di as txt _col(2) "Sample Size" _col(21) "=" %12.0f as res `e(N)' _col(37) "|" as txt _col(41) "Sample Range" _col(65) "=" %7.0f as res `NT1' " - " `NT2'
noi di as txt _col(2) "{cmd:Wald Test}" _col(21) "=" %12.4f as res `wald' _col(37) "|" _col(41) as txt "P-Value > {cmd:Chi2}(" as res `kx' ")" _col(65) "=" %12.4f as res `waldp'
noi di as txt _col(2) "{cmd:F-Test}" _col(21) "=" %12.4f as res `f' _col(37) "|" _col(41) as txt "P-Value > {cmd:F}(" as res `kx' " , " `DF' ")" _col(65) "=" %12.4f as res `fp'
noi di as txt _col(2) "R2  (R-Squared)" _col(21) "=" %12.4f as res `r2bu' _col(37) "|" as txt _col(41) "Raw Moments R2" _col(65) "=" %12.4f as res `r2raw'

 ereturn scalar r2bu =`r2bu'
 ereturn scalar r2bu_a=`r2bu_a'
 ereturn scalar f =`f'
 ereturn scalar fp=`fp'
 ereturn scalar wald =`wald'
 ereturn scalar waldp=`waldp'
noi di as txt _col(2) "R2a (Adjusted R2)" _col(21) "=" %12.4f as res `r2bu_a' _col(37) "|" as txt _col(41) "Raw Moments R2 Adj." _col(65) "=" %12.4f as res `r2raw_a'
noi di as txt _col(2) "Root MSE (Sigma)" _col(21) "=" %12.4f as res `Sigo' as txt _col(37) "|" _col(41) "Log Likelihood Function" _col(65) "=" %12.4f as res `llf'
noi di _dup(78) "-"
noi di as txt "- {cmd:R2h}=" %7.4f as res `r2h' _col(17) as txt "{cmd:R2h Adj}=" as res %7.4f `r2h_a' as txt _col(34) "{cmd:F-Test} =" %8.2f as res `fh' _col(51) as txt "P-Value > F(" as res `kx' " , " `DF' ")" _col(72) %5.4f as res `fhp'
if `r2v'<1 {
noi di as txt "- {cmd:R2v}=" %7.4f as res `r2v' _col(17) as txt "{cmd:R2v Adj}=" as res %7.4f `r2v_a' as txt _col(34) "{cmd:F-Test} =" %8.2f as res `fv' _col(51) as txt "P-Value > F(" as res `kx' " , " `DF' ")" _col(72) %5.4f as res `fvp'
 ereturn scalar r2v=`r2v'
 ereturn scalar r2v_a=`r2v_a'
 ereturn scalar fv=`fv'
 ereturn scalar fvp=`fvp'
 ereturn scalar k=e(df_m)+1
 }
 scalar `AIC1'=-2*`llf' + 2* e(k)
 scalar `SC1'=-2*`llf' + ln(`N')* e(k)
noi di _dup(78) "-"
noi di as txt _col(2) "{cmd:Akaike Criterion AIC }" _col(21) "=" %12.4f as res `AIC1' _col(37) "|" as txt _col(41) "{cmd:Schwarz Criterion SC}" _col(65) "=" %12.4f as res `SC1'
 ereturn scalar r2raw =`r2raw'
 ereturn scalar r2raw_a=`r2raw_a'
 ereturn scalar llf =`llf'
 ereturn scalar sig=`Sigo'
 ereturn scalar r2h=`r2h'
 ereturn scalar r2h_a=`r2h_a'
 ereturn scalar fh=`fh'
 ereturn scalar fhp=`fhp'
 ereturn scalar kb=`kb'
 ereturn scalar kx=`kx'
 ereturn scalar DF=`DF'
 ereturn scalar NT=`NT'
 ereturn scalar N=`N'
noi di _dup(78) "-"
 foreach var of local xvar {
 tsunab RLVar : L(0/`lag').(`var')
 test `RLVar' , `noconstant'
 if !inlist("`model'", "als", "arch") {
noi di as txt "- {bf:Joint F-Test Restriction}" _col(30) "`var'" _col(41) "= " %7.3f r(F) _col(55) "P > F("r(df) ", "   r(df_r) ") " _col(72) %5.4f r(p)
 } 
 if inlist("`model'", "als", "arch") {
noi di as txt "- {bf:Joint Chi2-Test Restriction}" _col(31) "`var'" _col(45) "= " %7.3f r(chi2) _col(60) "P > Chi2(" r(df) ")" _col(73) %5.4f r(p)
 }
 }

 if "`predict'"!= "" {
 putmata `predict'=`Yh_ML' , replace
 }
 if "`resid'"!= "" {
 putmata `resid'=`Ue_ML' , replace
 }
noi ereturn display , `levell' 
 matrix `Beta'=e(b)
 matrix `VCov'= e(V)
 matrix `VCov'= `VCov'[1..`Bz',1..`Bz']
 local N=e(N)

 if "`diag'" != "" {
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:*** {err:Model Selection Diagnostic Criteria}}"
noi di _dup(78) "{bf:{err:-}}"
 scalar `AIC1'=-2*`llf' + 2*e(k)
 scalar `SC1'=-2*`llf' + ln(`N')* e(k)
 scalar `AIC2'=ln(`Sig2n')+2*e(k)/`N'
 scalar `SC2'=ln(`Sig2n')+e(k)*ln(`N')/`N'
noi di as txt "{bf:{err:* Stata Method}}"
noi di as txt "- Akaike Information Criterion" _col(45) "(1974) AIC" _col(60) "=" as res %12.4f `AIC1'
noi di as txt "- Schwarz Criterion" _col(45) "(1978) SC" _col(60) "=" as res %12.4f `SC1'
noi di _dup(73) "-"
 ereturn scalar aic=`Sig2n'*exp(2*e(k)/`N')
 ereturn scalar aicc= e(aic)+ 2*((e(k)*(e(k)+1))/(`N'-e(k)-1))
 ereturn scalar laic=ln(`Sig2n')+2*e(k)/`N'
 ereturn scalar fpe=`Sig2n'*(1+e(k)/`N')/(1-e(k)/`N')
 ereturn scalar sc=`Sig2n'*`N'^(e(k)/`N')
 ereturn scalar lsc=ln(`Sig2n')+e(k)*ln(`N')/`N'
 ereturn scalar hq=`Sig2n'*ln(`N')^(2*e(k)/`N')
 ereturn scalar rice=`Sig2n'/(1-2*e(k)/`N')
 ereturn scalar shibata=`Sig2n'*(`N'+2*e(k))/`N'
 ereturn scalar gcv=`Sig2n'*(1-e(k)/`N')^(-2)
 ereturn scalar llf = `llf'
noi di as txt "- Log Likelihood Function" _col(45) "(LLF)" _col(60) "=" as res %12.4f `llf'
noi di _dup(75) "-"
noi di as txt "- Akaike Information Criterion" _col(45) "(1974) AIC" _col(60) "=" %12.4f `e(aic)'
noi di as txt "- Akaike Information Criterion" _col(45) "(1973) Log AIC" _col(60) "=" %12.4f `e(laic)'
noi di as txt "- Corrected Akaike Information Criterion" _col(45) "AICC" _col(60) "=" %12.4f `e(aicc)'
noi di _dup(75) "-"
noi di as txt "- Schwarz Criterion" _col(45) "(1978) SC" _col(60) "=" %12.4f `e(sc)'
noi di as txt "- Schwarz Criterion" _col(45) "(1978) Log SC" _col(60) "=" %12.4f `e(lsc)'
noi di _dup(75) "-"
noi di as txt "- Final Prediction Criterion" _col(45) "(1969) FPE" _col(60) "=" %12.4f `e(fpe)'
noi di as txt "- Hannan-Quinn Criterion" _col(45) "(1979) HQ" _col(60) "=" %12.4f `e(hq)'
noi di as txt "- Rice Criterion" _col(45) "(1984) Rice" _col(60) "=" %12.4f `e(rice)'
noi di as txt "- Shibata Criterion" _col(45) "(1981) Shibata" _col(60) "=" %12.4f `e(shibata)'
noi di as txt "- Craven-Wahba Generalized Cross Validation" _col(45) "(1979) GCV" _col(60) "=" %12.4f `e(gcv)'
noi di _dup(78) "{bf:{err:-}}"
 ereturn scalar aic1 = `AIC1'
 ereturn scalar sc1 = `SC1'
 ereturn scalar aic2 = `AIC2'
 ereturn scalar sc2 = `SC2'
 }
 
 if "`test'" != "" {
noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:*** {err:Autocorrelation Tests} - {bf:(Model= {err:`model'})}}"
noi di _dup(78) "{bf:{err:-}}"
noi di as txt "{bf: Ho: No Autocorrelation - Ha: Autocorrelation}"
noi di _dup(78) "-"
tempname S2y SSE Rho BB lmaz lmadw lmabpg lmabgd lmadmk lmabgk 
tempname SRhos lmabp SBBs lmalb Po lmadho lmadhop lmahho lmahhop SSEa Pa
tempname lmawt lmawtp lmawc lmawcp Pa1 lmadha lmadhap lmahha lmahhap lmabw lmakg
tempvar Yh Yh2 U2 E E2 E3 E4 Es

 local N=`NT'
 tsset `Time'
 gen double `Yh'=`Yh_ML'
 gen double `E' =`Ue_ML'
 forvalue i=1/`order' {
 tempvar E`i' EE`i' LE`i' LEo`i' DE`i' LEE`i'
 gen double `E`i''=`E'^`i'
 gen double `LEo`i''=L`i'.`E'
 replace `LEo`i''= 0 in 1/`i'
 gen double `LE`i'' =L`i'.`E'
 gen double `LEE`i''=L`i'.`E'*`E'
 summ `LEE`i''
 scalar `SSE'`i'=r(sum)
 scalar `Rho'`i'=`SSE'`i'/`SSEo'
 regress `E' `LEo`i'' `xvar'
 scalar `lmabpg'`i'=sqrt(e(N)*e(r2))
 tempvar LEo LE
 gen double `LEo'`i'=L`i'.`E'
 replace `LEo'`i'= 0 in 1/`i'
 gen double `LE'`i' =L`i'.`E'
 regress `E' `LE'* `xvar'
 scalar `lmabgd'`i'=e(N)*e(r2)
 testparm `LE'*
 scalar `lmadmk'`i'=r(F)*`i'
 regress `E' `LEo'* `xvar'
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

noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:*** {err:Heteroscedasticity Tests} - {bf:(Model= {err:`model'})}}"
noi di _dup(78) "{bf:{err:-}}"
noi di as txt "{bf: Ho: Homoscedasticity - Ha: Heteroscedasticity}"
noi di _dup(78) "-"

tempname Eb2 Eb4 lmhmss1 lmhmss1p mssdf1 lmhmss2 lmhmss2p mssdf2 dfw0
tempname lmhw01 lmhw01p lmhw02 lmhw02p dfw1 lmhw11 lmhw11p lmhw12 lmhw12p dfw2
tempname lmhw21 lmhw21p lmhw22 lmhw22p lmhharv lmhharvp lmhwald lmhwaldp lmhhp1
tempname lmhhp1p lmhhp2 lmhhp2p lmhhp3 lmhhp3p lmhgl lmhglp lmhcw1 cwdf1 lmhcw1p
tempname lmhcw2 cwdf2 lmhcw2p lmharch lmharchp lmhbg lmhbgp LMh_cwx mh vh h Q
tempvar Yh Yh2 U2 E E2 E3 E4 LYh2 LnE2
 local N=`NT'
 tsset `Time'
 gen double `Yh'=`Yh_ML'
 gen double `Yh2'=`Yh_ML'^2
 gen double `LYh2'=ln(`Yh2')
 gen double `E' =`Ue_ML'
 gen double `E2'=`Ue_ML'^2
 gen double `LnE2'=log(`E2')
 regress `E2' `xvar'
 scalar `dfw0'=e(df_m)
 scalar `lmhw01'=e(r2)*e(N)
 scalar `lmhw01p'= chi2tail(`dfw0' , abs(`lmhw01'))
 scalar `lmhw02'=e(mss)/(2*`Sig2n'^2)
 scalar `lmhw02p'= chi2tail(`dfw0' , abs(`lmhw02'))
 regress `LnE2' `xvar'
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
 forvalue i = 1/`order' {
 gen double `LE'`i'=L`i'.`E2'
 regress `E2' `LE'*
 scalar `lmharch'`i'=e(r2)*e(N)
 scalar `lmharchp'`i'= chi2tail(`i', abs(`lmharch'`i'))
noi di as txt "- Engle LM ARCH Test AR(`i') E2=E2_1-E2_`i'" _col(40) "=" %9.4f `lmharch'`i' _col(53) " P-Value > Chi2(`i')" _col(73) %5.4f `lmharchp'`i'
 }
 regress `E2' L1.`E2' `xvar'
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
 forvalue i = 1/`order' {
 ereturn scalar lmharchp`i'= `lmharchp'`i'
 ereturn scalar lmharch`i'= `lmharch'`i'
 }

noi di
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:*** {err:Non Normality Tests} - {bf:(Model= {err:`model'})}}"
noi di _dup(78) "{bf:{err:-}}"
noi di as txt "{bf: Ho: Normality - Ha: Non Normality}"
noi di _dup(78) "-"
 local N=`NT'
tempvar Yh E E1 E2 E3 E4 Es U2 DE LDE LDF1 Yt U Hat ZVarXi X0
tempname Hat corr1 corr3 corr4 mpc2 mpc3 mpc4 s uinv q1 uinv2 q2 ECov ECov2 Eb Sk Ku X
tempname M2 M3 M4 K2 K3 K4 Ss Kk GK N1 N2 EN S2N SN mean sd small A2 B0 B1
tempname B2 B3 LA Z Rn Lower Upper wsq2 ve lve Skn gn an cn kn vz Ku1 Kun n1 n2 n3 eb2
tempname R2W vb2 svb2 k1 a devsq m2 sdev m3 m4 sqrtb1 b2 g1 g2 stm3b2 S1 S2 S3 S4
tempname b2minus3 sm sms y k2 wk delta alpha yalpha pc1 pc2 pc3 pc4 pcb1 pcb2 sqb1p b2p
 tsset `Time'
 gen double `Yh'=`Yh_ML'
 gen double `E' =`Ue_ML'
 gen double `E2'=`E'*`E'
 local KMv : word count `ZVar'
 gen `X0'=1
 forvalue i=1/`KMv' {
 local z : word `i' of `ZVar'
 gen double `ZVarXi'_`i'=`z'
 }
if "`noconstant'"!="" {
 mkmat `ZVarXi'_* , matrix(`X')
 }
 else {
 mkmat `ZVarXi'_* `X0' , matrix(`X')
 }
 matrix `Hat'=vecdiag(`Wi''*`Wi'*`X'*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''*`Wi')'
 svmat `Hat' , name(`Hat')
 rename `Hat'1 `Hat'
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
 gen `DE'=1 if `E'>0
 replace `DE'=0 if `E' <= 0
 count if `DE'>0
 scalar `N1'=r(N)
 scalar `N2'=`N'-r(N)
 scalar `EN'=(2*`N1'*`N2')/(`N1'+`N2')+1
 scalar `S2N'=(2*`N1'*`N2'*(2*`N1'*`N2'-`N1'-`N2'))/((`N1'+`N2')^2*(`N1'+`N2'-1))
 scalar `SN'=sqrt((2*`N1'*`N2'*(2*`N1'*`N2'-`N1'-`N2'))/((`N1'+`N2')^2*(`N1'+`N2'-1)))
 gen double `LDE'= `DE'[_n-1] 
 replace `LDE'=0 if `DE'==1 in 1
 gen `LDF1'= 1 if `DE' != `LDE'
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
 if "`tolog'"!="" {
 forvalue i=1/`kvlog' {
 local var: word `i' of `vlistlog'
 replace `var'=`xyind_`i''
 }
 }
 if inlist("`mfx'", "lin", "log") {
 tempname mfxb mfxe mfxlin mfxlog XMB XYMB YMB YMB1
 matrix `Bx'=`Beta'[1, 1..`Bz']'
 tempvar ZVarM
 local KMv : word count `ZVar'
 forvalue i=1/`KMv' {
 local K : word `i' of `ZVar'
 gen double `ZVarM'_`i'=`K'
 }
 mean `ZVarM'_*
 matrix `XMB'=e(b)'
 summ `yvar'
 scalar `YMB1'=r(mean)
 matrix `YMB'=J(rowsof(`XMB'),1,`YMB1')
 mata: X = st_matrix("`XMB'")
 mata: Y = st_matrix("`YMB'")
 if inlist("`mfx'", "lin") {
 mata: `XYMB'=X:/Y
 mata: `XYMB'=st_matrix("`XYMB'",`XYMB')
 matrix `mfxb' =`Bx'
 matrix `mfxe'=vecdiag(`Bx'*`XYMB'')'
 matrix `mfxlin' =`mfxb',`mfxe',`XMB'
 matrix rownames `mfxlin' = `NXvar'
 matrix colnames `mfxlin' = "Marginal Effect(B)" "Elasticity(Es)" Mean
noi matlist `mfxlin' , title({bf:*** {err:Marginal Effect - Elasticity} {bf:(Model= {err:`Model'})}: {err:Linear} *}) twidth(11) border(all) lines(columns) rowtitle(Variable) format(%18.4f)
 ereturn matrix mfxlin=`mfxlin'
 }

 if inlist("`mfx'", "log") {
 mata: `XYMB'=Y:/X
 mata: `XYMB'=st_matrix("`XYMB'",`XYMB')
 matrix `mfxe'=`Bx'
 matrix `mfxb'=vecdiag(`Bx'*`XYMB'')'
 matrix `mfxlog' =`mfxe',`mfxb',`XMB'
 matrix rownames `mfxlog' = `NXvar'
 matrix colnames `mfxlog' = "Elasticity(Es)" "Marginal Effect(B)" Mean
noi matlist `mfxlog' , title({bf:*** {err:Elasticity - Marginal Effect} {bf:(Model= {err:`Model'})}: {err:Log-Log} *}) twidth(11) border(all) lines(columns) rowtitle(Variable) format(%18.4f)
 ereturn matrix mfxlog=`mfxlog'
 }
noi di as txt " Mean of Dependent Variable =" _col(30) %12.4f `YMB1' 
noi di
noi di _dup(78) "{bf:{err:-}}"
noi di as txt "{bf:* Variable" _col(14) "Mean Lag" _col(25) "Full Lag" _col(37) "SUM(Coefs.)" _col(51) "Std. Err." _col(62) "T-Test" _col(73) "P>|t|}"

noi di _dup(78) "{bf:{err:-}}"
 tempname R M1 M2 M11 M21 FLag MLag SLag Cov VLag SDLag TLag Covt PTLag
 local NeQ=`Bz'/`kz'
 local G=`lag'+1
 matrix `R'=J(`G',1,0)
 forvalue m =1/`G' {
 matrix `R'[`m',1] = `m'-1
 }
 forvalue i=1/`kz' {
 local x : word `i' of `xvar'
 local j=`i'-1
 local a =`j'*`NeQ'+1
 local b =`i'*`NeQ'
 matrix `Bx'`i'=`Beta'[1, `a'..`b']
 matrix `M1'=`Bx'`i'*`R'
 matrix `M2'=trace(diag(`Bx'`i'))
 scalar `M11'=`M1'[1,1]
 scalar `M21'=`M2'[1,1]
 scalar `MLag'=`M11'/`M21'
 scalar `FLag'=`MLag'+1
 scalar `SLag'=`M21'
 local MG=`i'*`G'
 matrix `Cov'=0
 forvalue r =`a'/`MG' {
 forvalue c =`a'/`MG' {
 if `r' > `c' {
 matrix `Cov' = nullmat(`Cov') + `VCov'[`r',`c']
 matrix `Covt' = `VCov'[`a'..`MG',`a'..`MG']
 matrix `VLag'=trace(`Covt')+2*`Cov'
 }
 }
 }
 scalar `SDLag'=`VLag'[1,1]
 scalar `SDLag'=sqrt(`SDLag')
 scalar `TLag'=`SLag'/`SDLag'
 scalar `PTLag'= ttail(`DF' , abs(`TLag'))*2
noi di as txt _col(3) "`x'" _col(14) %7.4f `MLag' _col(25) %7.4f `FLag' _col(37) %7.4f `SLag' _col(51) %7.4f `SDLag' _col(62) %7.4f `TLag' _col(73) %5.4f `PTLag'
noi di _dup(78) "-"
 }
noi di
noi di _dup(78) "{bf:{err:-}}"
noi di as txt "{bf:* Variable" _col(15) "Marginal Effect (B)"_col(43) "|"  _col(50) "Elasticity (Es)}"
noi di as err _col(15) "Short Run" _col(30) "Long Run" _col(43) "{cmd:|}" _col(50) "Short Run" _col(65) "Long Run"
noi di _dup(78) "{bf:{err:-}}"
 matrix `mfxb' =`mfxb''
 matrix `mfxe'=`mfxe''
 forvalue i=1/`kz' {
 local x : word `i' of `xvar'
 local j=`i'-1
 local a =`j'*`NeQ'+1
 local b =`i'*`NeQ'
 tempname mfxb1 mfxe1 SRB LRB SRE LRE SRB1 LRB1 SRE1 LRE1
 matrix `mfxb1'=`mfxb'[1, `a'..`b']
 matrix `mfxe1'=`mfxe'[1, `a'..`b']
 matrix `SRB'=`mfxb1'[1,1]
 matrix `SRE'=`mfxe1'[1,1]
 matrix `LRB'=trace(diag(`mfxb1'))
 matrix `LRE'=trace(diag(`mfxe1'))
 scalar `SRB1'=`SRB'[1,1]
 scalar `SRE1'=`SRE'[1,1]
 scalar `LRB1'=`LRB'[1,1]
 scalar `LRE1'=`LRE'[1,1]
noi di as txt _col(3) "`x'" _col(15) %7.4f `SRB1' _col(30) %7.4f `LRB1' _col(43) "{cmd:|}" _col(50) %7.4f `SRE1' _col(65) %7.4f `LRE1'
noi di _dup(78) "-"
 }
 }
 restore
 if "`predict'"!= "" {
 getmata `predict' , force replace
 label variable `predict' `"Yh_`ModeL' - Prediction"'
 }
 if "`resid'"!= "" {
 getmata `resid'  , force replace
 label variable `resid' `"Ue_`ModeL' - Residual"'
 }
 cap mata: mata drop *
 cap mata: mata clear
 cap matrix drop _all
 }
 end

 program define Poly , eclass
 version 11.2
 syntax , rmat(str) p(str) q(str) [NOCONSTant model(str) order(str)]
 local r = `p' - `q'
 local m = `q' + 1
 tempname odd
if inlist("`model'", "als", "arch") {
 if "`noconstant'" != "" {
 local rho = 3+`order'
 matrix `rmat' = J(`r',`p'+`rho',0)
 }
 else {
 local rho = 4+`order'
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
 forvalues i = 1/`r' {
 local x = `i' + `q' + 1
 local k =  -1
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


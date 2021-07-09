*! resetxt V1.0 06/08/2015
*! 
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage:               http://emadstat.110mb.com/stata.htm
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

*! Sahra Khaleel A. Mickaiel
*! Professor (PhD Economics)
*! Cairo University - Faculty of Agriculture - Department of Economics - Egypt
*! Email: sahra_atta@hotmail.com
*! WebPage:               http://sahraecon.110mb.com/stata.htm
*! WebPage at IDEAS:      http://ideas.repec.org/f/pmi520.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/pmi520.htm

program define resetxt, eclass 
version 11.2
syntax varlist [if] [in] , [id(str) it(str) Model(str) ti tvd TWOstep ///
 coll hetonly NOCONStant BE cost FE igls Panels(str) LL(str) RHOType(str) RE corr(str)]
gettoken yvar xvar : varlist
local sthlp resetxt
qui marksample touse
qui markout `touse' `varlist' , strok
local both : list yvar & xvar
if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both LHS and RHS Variables}"
di as res " LHS: `yvar'"
di as res " RHS: `xvar'"
 exit
 }
if "`xvar'"=="" {
di as err " {bf:Independent Variable(s) must be combined with Dependent Variable}"
 exit
 }

if "`model'"!="" {
if !inlist("`model'", "xtbe", "xtfe", "xtmle", "xtfm", "xtfrontier", "xtgls", "xtpa") {
if !inlist("`model'", "xtpcse", "xtre", "xtregar", "xtrc", "xtkmhomo") {
if !inlist("`model'", "xtkmhet1", "xtkmhet2", "xtparks", "xttobit") {
di
di as err "{bf:model( )} {cmd:options:} {bf:xtbe, xtfe, xtfm, xtfrontier, xtgls, xtkmhet1, xtkmhet2}" 
di as err _col(2) "{bf:xtkmhomo, xtmle, xtpa, xtparks, xtpcse, xtrc, xtre, xtregar, xttobit}"
di in smcl _c "{cmd: see:} {help `sthlp'##04:model Options}"
di in gr _c " (resetxt Help):"
 exit
 }
 }
 }
 }
local usefront `ti' `tvd'
if inlist("`model'", "xtfrontier") & "`usefront'"=="" {
di
di as err " {bf:ti} {cmd:or} {bf:tvd} {cmd:must be combined with {bf:model({it:xtfrontier})}}"
 exit
 } 
if inlist("`model'", "xtbe", "xtfe", "xtre", "xtregar") & "`noconstant'"!="" {
di
di as err " {bf:noconstant} {cmd:cannot be combined with} {bf:model({it:xtbe, xtfe, xtre, xtregar})}"
 exit
 }

tempvar DF1 TimeN dcs idv itv SST Time tm U U2 Ue wald weit Wi Wio
tempvar Xb XB Yb Yh YYm YYv Yh_ML Ue_ML Z X X0 Bo
tempvar D DE DF DF1 E E1 E2 E3 E4 EE Eo P Q Sig2 SSE den Dim Dx 
tempname A AIC B b Beta Bx Cov F FPE GCV HQ In IPhi J K kb kbm
tempname M2 N NC NE Nn NT kx L LAIC lf llf Ls LSC M M1
tempname P Phi Pm Q R20 Rice SC Shibata Sig2 Sig2o
tempname SSE SSEo SST1 SST2 Ue Ue_ML W W1 W2 Wald waldm We Wi 
tempname V Wi1 Wio WY X X0 XB Y Yh Yh_ML YYm YYv P Q Xo D
 if "`coll'"=="" {
_rmcoll `varlist' , `noconstant' `coll' forcedrop
 local varlist "`r(varlist)'"
 }
qui tab `id' if `touse'
local NCNo= r(r)
qui xtset `id' `it'
local idv "`r(panelvar)'"
local itv "`r(timevar)'"
scalar `NC'=r(imax)
scalar `NT'= r(tmax)
mkmat `idv' if `touse' , matrix(idv)
mkmat `itv' if `touse' , matrix(itv)
mata: idv= st_matrix("idv")
mata: itv= st_matrix("itv")
qui cap count if `touse'
local N = r(N)
qui gen `TimeN'=_n
qui gen `Time'=_n if `touse'
qui tsset `Time'
if "`model'"!="" {
scalar xt_llt=0
 if "`ll'" != "" {
qui replace `yvar' = 0 if `yvar' <= `ll'
qui local llt `"`ll'"'
scalar xt_llt=`llt'
qui count if `yvar' == 0
local minyvar=r(N)
if `minyvar' > 0 { 
di _dup(60) "-"
di "{cmd:***} {bf:{err: Truncated Dependent Variable Lower Limit =} `llt'}"
di "{cmd:***} {bf:{err: Left-Censoring Dependent Variable Number =} `minyvar'}"
di _dup(60) "-"
 }

if inlist("`model'", "xttobit") {
di _dup(60) "-"
di "{cmd:***} {bf:{err: Truncated Dependent Variable Lower Limit =} `ll'}"
di "{cmd:***} {bf:{err: Left-Censoring Dependent Variable Number =} `minyvar'}"
di _dup(60) "-"
 }
 }
}

qui gen `X0'=1 if `touse' 
qui mkmat `X0' if `touse' , matrix(`X0')
mkmat `yvar' if `touse' , matrix(`Y')
local kx : word count `xvar'
if "`noconstant'"!="" {
qui mkmat `xvar' if `touse' , matrix(`X')
scalar `kb'=`kx'
scalar `DF'=`N'-`kx'-`NC'
qui mean `xvar' if `touse' 
 }
 else { 
qui mkmat `xvar' `X0' if `touse' , matrix(`X')
scalar `kb'=`kx'+1
scalar `DF'=`N'-`kx'-`NC'
qui mean `xvar' `X0' if `touse' 
 }

qui mean `yvar' if `touse' 
matrix `Yb'=e(b)'
qui gen `Wi'=1 if `touse' 
qui gen `weit' = 1 if `touse' 
mkmat `Wi' if `touse' , matrix(`Wi')
matrix `Wi'=diag(`Wi')
scalar `llf'=.
di
di _dup(78) "{bf:{err:=}}"
if inlist("`model'", "xtbe") {
di as txt "{bf:{err:* Between-Effects Panel Data Regression}}"
qui xtset `idv' `itv'
qui xtreg `yvar' `xvar' if `touse' , be `noconstant'
matrix `Beta'=e(b)
matrix `Beta'=`Beta'[1,1..`kb']'
matrix `E'=(`Y'-`X'*`Beta')
matrix `Sig2'=`E''*`E'/`DF'
matrix `Cov'= e(V)
matrix `Cov' = `Cov'[1..`kb', 1..`kb']
scalar `llf'=e(ll)
 } 

if inlist("`model'", "xtfe") {
di as txt "{bf:{err:* Fixed-Effects Panel Data Regression}}"
qui xtset `idv' `itv'
qui xtreg `yvar' `xvar' if `touse' , fe `noconstant'
matrix `Beta'=e(b)
matrix `Beta'=`Beta'[1,1..`kb']'
qui predict `E'  if `touse' , e
mkmat `E'  if `touse' , matrix(`E')
matrix `E'=(`Y'-`X'*`Beta')
matrix `Sig2'=`E''*`E'/`DF'
matrix `Cov'= e(V)
matrix `Cov' = `Cov'[1..`kb', 1..`kb']
scalar `llf'=e(ll)
 }

if inlist("`model'", "xtfm") {
di as txt "{bf:{err:* Fama-MacBeth Panel Data Regression}}"
qui xtset `idv' `itv'
preserve
local tvar "`r(timevar)'" 
qui statsby _b , by(`tvar') clear: regress `yvar' `xvar' if `touse' , `noconstant'
qui mean _b*
restore
matrix `Beta'=e(b)'
matrix `E'=`Y'-`X'*`Beta'
matrix `Sig2'=`E''*`E'/`DF'
matrix `Cov'= e(V)
matrix `Cov' = `Cov'[1..`kb', 1..`kb']
 } 

if inlist("`model'", "xtfrontier") {
di as txt "{bf:{err:* Frontier Panel Data Regression}}"
qui xtset `idv' `itv'
qui xtfrontier `yvar' `xvar' if `touse' , `noconstant' `coll' `cost' `ti' `tvd' 
matrix `Beta'=e(b)
matrix `Beta'=`Beta'[1,1..`kb']'
matrix `E'=`Y'-`X'*`Beta'
matrix `Sig2'=`E''*`E'/`DF'
matrix `Cov'= e(V)
matrix `Cov' = `Cov'[1..`kb', 1..`kb']
scalar `llf'=e(ll)
 } 

if inlist("`model'", "xtgls") {
di as txt "{bf:{err:* Generalized Least Squares Panel Data Regression}}"
qui xtset `idv' `itv'
qui xtgls `yvar' `xvar' if `touse' , `noconstant' ///
 `igls' panels(`panels') rhotype(`rhotype') 
matrix `Beta'=e(b)
matrix `Beta'=`Beta'[1,1..`kb']'
matrix `E'=`Y'-`X'*`Beta'
matrix `Sig2'=`E''*`E'/`DF'
matrix `Cov'= e(V)
matrix `Cov' = `Cov'[1..`kb', 1..`kb']
scalar `llf'=e(ll)
 }

if inlist("`model'", "xtkmhomo") {
di as txt "{bf:{err:* Kmenta Homoscedastic Generalized Least Squares AR(1) Panel Data Regression}}"
qui xtset `idv' `itv'
qui xtgls `yvar' `xvar' if `touse' , panels(iid) corr(psar1) `noconstant'
matrix `Beta'=e(b)
matrix `Beta'=`Beta'[1,1..`kb']'
matrix `E'=`Y'-`X'*`Beta'
matrix `Sig2'=`E''*`E'/`DF'
matrix `Cov'= e(V)
matrix `Cov' = `Cov'[1..`kb', 1..`kb']
scalar `llf'=e(ll)
 }

if inlist("`model'", "xtkmhet1") {
di as txt "{bf:{err:* Kmenta Heteroscedastic GLS AR(1) Panel Data Regression}}"
qui xtset `idv' `itv'
qui xtgls `yvar' `xvar' if `touse' , panels(het) corr(psar1) `noconstant'
matrix `Beta'=e(b)
matrix `Beta'=`Beta'[1,1..`kb']'
matrix `E'=`Y'-`X'*`Beta'
matrix `Sig2'=`E''*`E'/`DF'
matrix `Cov'= e(V)
matrix `Cov' = `Cov'[1..`kb', 1..`kb']
scalar `llf'=e(ll)
 }

if inlist("`model'", "xtkmhet2") {
di as txt "{bf:{err:* Kmenta Heteroscedastic SAME Common AR(1) for all Panels}}"
qui xtset `idv' `itv'
qui xtgls `yvar' `xvar' if `touse' , panels(het) corr(ar1) `noconstant'
matrix `Beta'=e(b)
matrix `Beta'=`Beta'[1,1..`kb']'
matrix `E'=`Y'-`X'*`Beta'
matrix `Sig2'=`E''*`E'/`DF'
matrix `Cov'= e(V)
matrix `Cov' = `Cov'[1..`kb', 1..`kb']
scalar `llf'=e(ll)
 }

if inlist("`model'", "xtmle") {
di as txt "{bf:{err:* MLE Random-Effects Panel Data Regression}}"
qui xtset `idv' `itv'
qui xtreg `yvar' `xvar' if `touse' , mle `noconstant' 
matrix `Beta'=e(b)
matrix `Beta'=`Beta'[1,1..`kb']'
matrix `E'=`Y'-`X'*`Beta'
matrix `Sig2'=`E''*`E'/`DF'
matrix `Cov'= e(V)
matrix `Cov' = `Cov'[1..`kb', 1..`kb']
scalar `llf'=e(ll)
 }

if inlist("`model'", "xtpa") {
di as txt "{bf:{err:* Population Averaged-Effects Panel Data Regression}}"
qui xtset `idv' `itv'
qui xtreg `yvar' `xvar' if `touse' , pa `noconstant' 
scalar `llf'=e(ll)
matrix `Beta'=e(b)'
matrix `E'=`Y'-`X'*`Beta'
matrix `Sig2'=`E''*`E'/`DF'
matrix `Cov'= e(V)
 }

if inlist("`model'", "xtparks") {
di as txt "{bf:{err:* Parks (FULL) Heteroscedastic Cross-Section GLS AR(1) Panel Data Regression}}"
qui xtset `idv' `itv'
qui xtgls `yvar' `xvar' if `touse' , panels(corr) corr(psar1) `noconstant'
matrix `Beta'=e(b)
matrix `Beta'=`Beta'[1,1..`kb']'
matrix `E'=`Y'-`X'*`Beta'
matrix `Sig2'=`E''*`E'/`DF'
matrix `Cov'= e(V)
matrix `Cov' = `Cov'[1..`kb', 1..`kb']
scalar `llf'=e(ll)
 }

if inlist("`model'", "xtpcse") {
di as txt "{bf:{err:* Linear Panel-Corrected Standard Error (PCSE) Regression}}"
qui xtset `idv' `itv'
qui xtpcse `yvar' `xvar' if `touse' , `noconstant' `indep'
matrix `Beta'=e(b)
matrix `Beta'=`Beta'[1,1..`kb']'
matrix `E'=`Y'-`X'*`Beta'
matrix `Sig2'=`E''*`E'/`DF'
matrix `Cov'= e(V)
matrix `Cov' = `Cov'[1..`kb', 1..`kb']
scalar `llf'=e(ll)
 } 

if inlist("`model'", "xtrc") {
di as txt "{bf:{err:* Swamy Random-Coefficients Panel Data Regression}}"
qui xtset `idv' `itv'
qui xtrc `yvar' `xvar' if `touse' , `noconstant'
local lmconsdf= e(df_chi2c)
local lmcons =e(chi2_c)
local lmconsp=chi2tail(`lmconsdf',`lmcons')
matrix `Beta'=e(b)
matrix `Beta'=`Beta'[1,1..`kb']'
matrix `E'=`Y'-`X'*`Beta'
matrix `Sig2'=`E''*`E'/`DF'
matrix `Cov'= e(V)
matrix `Cov' = `Cov'[1..`kb', 1..`kb']
scalar `llf'=e(ll)
 } 
 
if inlist("`model'", "xtre") {
di as txt "{bf:{err:* GLS Random-Effects Panel Data Regression}}"
qui xtset `idv' `itv'
qui xtreg `yvar' `xvar' if `touse' , re `noconstant'
matrix `Beta'=e(b)
matrix `Beta'=`Beta'[1,1..`kb']'
matrix `E'=`Y'-`X'*`Beta'
matrix `Sig2'=`E''*`E'/`DF'
matrix `Cov'= e(V)
matrix `Cov' = `Cov'[1..`kb', 1..`kb']
scalar `llf'=e(ll)
 }

if inlist("`model'", "xtregar") {
di as txt "{bf:{err:* Linear AR(1) Panel Data Regression}}"
qui xtset `idv' `itv'
qui xtregar `yvar' `xvar' if `touse' , `fe' `re' `twostep' rhotype(`rhotype')
matrix `Beta'=e(b)
matrix `Beta'=`Beta'[1,1..`kb']'
matrix `E'=`Y'-`X'*`Beta'
matrix `Sig2'=`E''*`E'/`DF'
matrix `Cov'= e(V)
matrix `Cov' = `Cov'[1..`kb', 1..`kb']
scalar `llf'=e(ll)
 } 

if inlist("`model'", "xttobit") {
di as txt "{bf:{err:* Tobit Random-Effects Panel Data Regression}}"
qui xtset `idv' `itv'
qui xttobit `yvar' `xvar' if `touse' , `noconstant' `coll' ll(`ll') 
matrix `Beta'=e(b)
matrix `Beta'=`Beta'[1,1..`kb']'
matrix `E'=`Y'-`X'*`Beta'
matrix `Sig2'=`E''*`E'/`DF'
matrix `Cov'= e(V)
matrix `Cov' = `Cov'[1..`kb', 1..`kb']
scalar `llf'=e(ll)
 } 
di _dup(78) "{bf:{err:=}}"
matrix `Bx' =`Beta'[1..`kx', 1..1]
matrix `Yh_ML'=`X'*`Beta'
qui svmat `Yh_ML' , name(`Yh_ML')
qui rename `Yh_ML'1 `Yh_ML'
matrix `Ue_ML'=`E'
qui svmat `Ue_ML' , name(`Ue_ML')
qui rename `Ue_ML'1 `Ue_ML'

tempname SSEo Sigo r2bu r2bu_a r2raw r2raw_a R20 f fp wald waldp
tempname r2v r2v_a fv fvp r2h r2h_a fh fhp SSTm SSE1 SST11 SST21
matrix `SSE'=`Ue_ML''*`Ue_ML'
scalar `SSEo'=`SSE'[1,1]
scalar `Sig2o'=`SSEo'/`DF'
scalar `Sigo'=sqrt(`Sig2o')
qui summ `Yh_ML' if `touse' 
local NUM=r(Var)
qui summ `yvar' if `touse' 
local DEN=r(Var)
scalar `r2v'=`NUM'/`DEN'
scalar `r2v_a'=1-((1-`r2v')*(`N'-1)/`DF')
scalar `fv'=`r2v'/(1-`r2v')*(`N'-`kb')/(`kx')
scalar `fvp'=Ftail(`kx', `DF', `fv')
qui correlate `Yh_ML' `yvar' if `touse' 
scalar `r2h'=r(rho)*r(rho)
scalar `r2h_a'=1-((1-`r2h')*(`N'-1)/`DF')
scalar `fh'=`r2h'/(1-`r2h')*(`N'-`kb')/(`kx')
scalar `fhp'=Ftail(`kx', `DF', `fh')
local Sig=`Sigo'
qui summ `yvar' if `touse' 
local Yb=r(mean)
qui gen `YYm'=(`yvar'-`Yb')^2 if `touse'
qui summ `YYm' if `touse'
qui scalar `SSTm' = r(sum)
qui gen `YYv'=(`yvar')^2 if `touse'
qui summ `YYv' if `touse'
local SSTv = r(sum)
qui summ `weit' if `touse' 
qui gen `Wi1'= 1 if `touse'
mkmat `Wi1' if `touse' , matrix(`Wi1')
matrix `P' =diag(`Wi1')
qui gen `Wio'=`Wi1' if `touse' 
mkmat `Wio' if `touse' , matrix(`Wio')
matrix `Wio'=diag(`Wio')
matrix `Pm' =`Wio'
matrix `IPhi'=`P''*`P'
matrix `Phi'=invsym(`P''*`P')
matrix `J'= J(`N',1,1)
matrix `D'=(`J'*`J''*`IPhi')/`N'
matrix `SSE'=`Ue_ML''*`IPhi'*`Ue_ML'
matrix `SST1'=(`Y'-`D'*`Y')'*`IPhi'*(`Y'-`D'*`Y')
matrix `SST2'=(`Y''*`Y')
scalar `SSE1'=`SSE'[1,1]
scalar `SST11'=`SST1'[1,1]
scalar `SST21'=`SST2'[1,1]
scalar `r2bu'=1-`SSE1'/`SST11'
 if `r2bu'< 0 {
scalar `r2bu'=`r2h'
 }
scalar `r2bu_a'=1-((1-`r2bu')*(`N'-1)/`DF')
scalar `r2raw'=1-`SSE1'/`SST21'
scalar `r2raw_a'=1-((1-`r2raw')*(`N'-1)/`DF')
scalar `R20'=`r2bu'
scalar `f'=`r2bu'/(1-`r2bu')*(`N'-`kb')/`kx'
scalar `fp'= Ftail(`kx', `DF', `f')
scalar `wald'=`f'*`kx'
scalar `waldp'=chi2tail(`kx', abs(`wald'))
if `llf' == . {
scalar `llf'=-(`N'/2)*log(2*_pi*`SSEo'/`N')-(`N'/2)
 }
local Nof =`N'
local Dof =`DF'
matrix `B'=`Beta''
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
yxregeq `yvar' `xvar'
di as txt _col(2) "Sample Size" _col(21) "=" %12.0f as res `N' _col(37) "|" _col(41) as txt "Cross Sections Number" _col(65) "=" _col(73) %5.0f as res `NCNo'
ereturn post `B' `Cov' , dep(`yvar') obs(`Nof') dof(`Dof')
qui test `xvar'
scalar `f'=r(F)
scalar `fp'= Ftail(`kx', `DF', `f')
scalar `wald'=`f'*`kx'
scalar `waldp'=chi2tail(`kx', abs(`wald'))
di as txt _col(2) "{cmd:Wald Test}" _col(21) "=" %12.4f as res `wald' _col(37) "|" _col(41) as txt "P-Value > {cmd:Chi2}(" as res `kx' ")" _col(65) "=" %12.4f as res `waldp'
di as txt _col(2) "{cmd:F-Test}" _col(21) "=" %12.4f as res `f' _col(37) "|" _col(41) as txt "P-Value > {cmd:F}(" as res `kx' " , " `DF' ")" _col(65) "=" %12.4f as res `fp'
di as txt _col(2) "R2  (R-Squared)" _col(21) "=" %12.4f as res `r2bu' _col(37) "|" as txt _col(41) "Raw Moments R2" _col(65) "=" %12.4f as res `r2raw'
ereturn scalar r2bu =`r2bu'
ereturn scalar r2bu_a=`r2bu_a'
ereturn scalar f =`f'
ereturn scalar fp=`fp'
ereturn scalar wald =`wald'
ereturn scalar waldp=`waldp'
di as txt _col(2) "R2a (Adjusted R2)" _col(21) "=" %12.4f as res `r2bu_a' _col(37) "|" as txt _col(41) "Raw Moments R2 Adj" _col(65) "=" %12.4f as res `r2raw_a'
di as txt _col(2) "Root MSE (Sigma)" _col(21) "=" %12.4f as res `Sigo' as txt _col(37) "|" _col(41) "Log Likelihood Function" _col(65) "=" %12.4f as res `llf'
di _dup(78) "-"
di as txt "- {cmd:R2h}=" %7.4f as res `r2h' _col(17) as txt "{cmd:R2h Adj}=" as res %7.4f `r2h_a' as txt _col(34) "{cmd:F-Test} =" %8.2f as res `fh' _col(51) as txt "P-Value > F(" as res `kx' " , " `DF' ")" _col(72) %5.4f as res `fhp'
if `r2v'<1 {
di as txt "- {cmd:R2v}=" %7.4f as res `r2v' _col(17) as txt "{cmd:R2v Adj}=" as res %7.4f `r2v_a' as txt _col(34) "{cmd:F-Test} =" %8.2f as res `fv' _col(51) as txt "P-Value > F(" as res `kx' " , " `DF' ")" _col(72) %5.4f as res `fvp'
ereturn scalar r2v=`r2v'
ereturn scalar r2v_a=`r2v_a'
ereturn scalar fv=`fv'
ereturn scalar fvp=`fvp'
 }
ereturn scalar r2raw =`r2raw'
ereturn scalar r2raw_a=`r2raw_a'
ereturn scalar llf =`llf'
ereturn scalar sig=`Sigo'
ereturn scalar r2h =`r2h'
ereturn scalar r2h_a=`r2h_a'
ereturn scalar fh =`fh'
ereturn scalar fhp=`fhp'
ereturn scalar kb=`kb'
ereturn scalar kx=`kx'
ereturn scalar DF=`DF'
ereturn scalar Nn=_N
ereturn scalar R20=`R20'
ereturn scalar NC=`NC'
ereturn scalar NT=`NT'
ereturn display
matrix `b'=e(b)
matrix `V'=e(V)
local llf=e(llf)
local kb=e(kb)
local kx=e(kx)
local DF=e(DF)
local N=e(Nn)
local R20=e(R20)
local NC=e(NC)
local NT=e(NT)
qui drop if `yvar'== .
qui replace `Time'=_n if `touse'
qui tsset `Time'
 local N=`N'
qui mkmat `X0' if `touse' , matrix(`X0')
 
tempvar E E2 Yh Yh2 Yh3 Yh4 SSi SCi SLi CLi WL WS XQX_ Yhr
tempname k0 rim
qui tsset `Time'
qui gen `E' =`Ue_ML' if `touse' 
qui gen `Yh'=`Yh_ML' if `touse'
qui gen `E2'=`Ue_ML'^2 if `touse'
qui summ `Yh' if `touse'
scalar YMin = r(min)
scalar YMax = r(max)
qui gen `WL'=_pi*(2*`Yh'-(YMax+YMin))/(YMax-YMin) if `touse' 
qui gen `WS'=2*_pi*(sin(`Yh_ML')^2)-_pi if `touse' 
qui forvalue j =1/`kx' {
qui foreach i of local xvar {
tempvar vn
gen `vn'`j'=`i' if `touse' 
qui cap drop `XQX_'`i'
qui gen `XQX_'`i' = `vn'`j'*`vn'`j' if `touse'
 }
 }
qui regress `E2' `xvar' `XQX_'* if `touse'
local LMW=e(N)*e(r2)
local LMWp= chi2tail(2, abs(`LMW'))
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:*** {bf:{err:RE}}gression {bf:{err:S}}pecification {bf:{err:E}}rror {bf:{err:T}}ests (RESET) - Model= ({bf:{err:`model'})}}"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf: Ho: Model is Specified  -  Ha: Model is Misspecified}"
di _dup(78) "-"
di as txt "{bf:* Ramsey Specification ResetF Test}"
forvalue i=2/4 {
tempvar Yhrm`i'
qui gen `Yhr'`i'=`Yh'^`i' if `touse' 
if "`noconstant'"!="" {
qui regress `yvar' `xvar' `Yhr'* if `touse' , noconstant noomitted
scalar `k0'=0
 }
else {
qui regress `yvar' `xvar' `Yhr'* if `touse' , noomitted
 scalar `k0'=1
 }
qui predict `Yhrm`i'' if `touse' , xb
qui correlate `Yhrm`i'' `yvar' if `touse' 
scalar `rim'=r(rho)*r(rho)
scalar resetf`i'=(e(N)-e(df_m)-`k0')*(`rim'-`R20')/((`i'-1)*(1-`rim'))
scalar resetf`i'p= Ftail((`i'-1), (e(N)-e(df_m)-1), resetf`i')
scalar resetf`i'df= (e(N)-e(df_m)-1)
 }
di as txt "- Ramsey RESETF1 Test: Y= X Yh2" _col(41) "= " %7.3f as res resetf2 as txt _col(52) "P-Value > F("1 ",  "    resetf2df ") " _col(72) %5.4f as res resetf2p
di as txt "- Ramsey RESETF2 Test: Y= X Yh2 Yh3" _col(41) "= " %7.3f as res resetf3 as txt _col(52) "P-Value > F("2 ",  "    resetf3df ") " _col(72) %5.4f as res resetf3p
di as txt "- Ramsey RESETF3 Test: Y= X Yh2 Yh3 Yh4" _col(41) "= " %7.3f as res resetf4 as txt _col(52) "P-Value > F("3 ",  "    resetf4df ") " _col(72) %5.4f as res resetf4p
di _dup(78) "-"
di as txt "{bf:* DeBenedictis-Giles Specification ResetL Test}"
forvalue i=1/3 {
qui gen `SLi'`i'=sin(`i'*`WL') if `touse'
qui gen `CLi'`i'=sin(`i'*`WL'+_pi/2) if `touse'
if "`noconstant'"!="" {
qui regress `yvar' `xvar' `SLi'* `CLi'* `wgt' if `touse' , noomitted noconstant
 }
else {
qui regress `yvar' `xvar' `SLi'* `CLi'* `wgt' if `touse' , noomitted
 }
qui testparm `SLi'* `CLi'*
di as txt "- Debenedictis-Giles ResetL`i' Test" _col(41) "= " %7.3f as res r(F) as txt _col(52) "P-Value > F("r(df) ", "    r(df_r) ")" _col(72) as res %5.4f r(p)
scalar resetl`i'= r(F)
scalar resetl`i'p=r(p)
 }
di _dup(78) "-"
di as txt "{bf:* DeBenedictis-Giles Specification ResetS Test}"
forvalue i=1/3 {
qui gen `SSi'`i'=sin(`i'*`WS')
qui gen `SCi'`i'=sin(`i'*`WS'+_pi/2)
if "`noconstant'"!="" {
qui regress `yvar' `xvar' `SSi'* `SCi'* `wgt' if `touse' , noomitted noconstant
 }
 else {
qui regress `yvar' `xvar' `SSi'* `SCi'* `wgt' if `touse' , noomitted
 }
qui testparm `SSi'* `SCi'*
di as txt "- Debenedictis-Giles ResetS`i' Test" _col(41) "= " %7.3f as res r(F) as txt _col(52) "P-Value > F("r(df) ", "    r(df_r) ")" _col(72) as res %5.4f r(p)
scalar resets`i'= r(F)
scalar resets`i'p=r(p)
 }
di _dup(78) "-"
di as txt "{bf:- White Functional Form Test}: E2= X X2" _col(41) "= " %7.3f as res `LMW' as txt _col(52) "P-Value > Chi2(1)   " _col(72) %5.4f as res `LMWp'
di _dup(78) "-"
ereturn scalar resetf1=resetf2
ereturn scalar resetf1p=resetf2p
ereturn scalar resetf2=resetf3
ereturn scalar resetf2p=resetf3p
ereturn scalar resetf3=resetf4
ereturn scalar resetf3p=resetf4p
ereturn scalar lmw=`LMW'
ereturn scalar lmwp=`LMWp'
ereturn scalar resetl1=resetl1
ereturn scalar resetl1p=resetl1p
ereturn scalar resetl2=resetl2
ereturn scalar resetl2p=resetl2p
ereturn scalar resetl3=resetl3
ereturn scalar resetl3p=resetl3p
ereturn scalar resets1=resets1
ereturn scalar resets1p=resets1p
ereturn scalar resets2=resets2
ereturn scalar resets2p=resets2p
ereturn scalar resets3=resets3
ereturn scalar resets3p=resets3p
qui tsset `TimeN'
end

program define yxregeq
version 10.0
 syntax varlist 
tempvar `varlist'
gettoken yvar xvar : varlist
local LEN=length("`yvar'")
local LEN=`LEN'+3
di "{p 2 `LEN' 5}" as res "{bf:`yvar'}" as txt " = " "
local NX : word count `xvar'
local i=1
 while `i'<=`NX' {
local X : word `i' of `xvar'
if `i'<`NX' {
di " " as res " {bf:`X'}" _c
di as txt " + " _c
 }
if `i'==`NX' {
di " " as res "{bf:`X'}"
 }
local i=`i'+1
 }
di "{p_end}"
di as txt "{hline 78}"
end


*! ridge2sls V1.0 25/04/2013
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

program define ridge2sls , eclass byable(onecall)
version 11.0
syntax [anything] [if] [in] , [WVar(str) RIDge(str) NOCONStant NOCONEXOG ///
 Level(passthru) DN KR(real 0) first Weights(str) diag mfx(str) ///
 PREDict(str) RESid(str) TOLerance(real 0.00001) ITER(int 100) coll]
tempvar _Y _X E E2 U U2 X0 Yh Yhb Ev Ue Lambdav Lambda Time TimeN YY Yb YYv
tempvar wald SSE SST weit EE Es DW WS DX_ DY_ LE DE LEo YYm Yho2
tempvar Yt e LDE DF1 Eo Yh2 LYh2 E3 E4 Yho Yh_ML Ue_ML Wio Wi
tempvar LnE2 absE LE XQ ht Hat Yhat1 DFF DFF1 DFF2 Rx COR Yh LYh xq
tempname X Y Z M2 XgXg Xg M1 W1 W2 W1W Lambda Vec Yi E Cov b h mh YMB1
tempname Wio Wi Ew OM Omega hjm Wald We v mfxe mfxlin mfxlog kyi kzi
tempname Bv1 Bv lamp1 lamp2 lamp M W b1 v1 q lmhs b2 v2 Beta P Pm IPhi Phi J D
tempname Wi1 Z0 Z1 Eo E1 EE1 Sw Sn nw S11 S12 WY Xgw Eg Sig2 Sig2o Sig2o1
tempname DCor X X0 Vec Val J Ds Cr Dr S LDCor rid sqN
tempname COR ICOR WMTD CovC RY RX VaL VaL1 Go GoRY SSE Sig2 Q L SST1 SST2
tempname id f1 f13 f13d Rmk IDRmk Ls lf F K B Bx BOLS1
tempname Zz Xx id Zr sd WMAT BOLS Zo V Ko Koi VaL21 VaLv1 SLS
tempname Nn kx kb DF N ky kyi kzi Kr llf rhsendog Kz biv2 viv2 Sig2n
tempname SSEo Sigo r2bu r2bu_a r2raw r2raw_a f fp wald waldp Qr 
tempname r2v r2v_a fv fvp r2h r2h_a fh fhp SSTm SSE1 SST11 SST21 
qui marksample touse
gettoken yvar 0 : 0
gettoken p 0 : 0, parse(" (") quotes
while `"`p'"' != "(" {
 local exog `"`exog' `p'"'
 gettoken p 0 : 0, parse(" (") quotes
 }
gettoken q 0 : 0, parse(" =") quotes
while `"`q'"' != "=" {
 local endog `"`endog' `q'"'
 gettoken q 0 : 0, parse(" =") quotes
 }
gettoken r 0 : 0, parse(" )") quotes
while `"`r'"' != ")" {
 local inst `"`inst' `r'"'
 gettoken r 0 : 0, parse(" )") quotes
 } 
markout `touse' `yvar' `endog' `inst' `exog' `allinst' `xvar' `exogex' , strok
 if "`coll'"=="" {
_rmcoll `exog' if `touse' , `noconstant' `coll' forcedrop
 local exog "`r(varlist)'"
_rmcoll `endog' if `touse' , `noconstant' `coll' forcedrop
 local endog "`r(varlist)'"
_rmcoll `inst' if `touse' , `noconstant' `coll' forcedrop
 local inst "`r(varlist)'"
 }
qui cap count if `touse'
local N = r(N)
scalar `Nn'=`N'
qui gen `TimeN'=_n
qui gen `Time'=_n if `touse'
qui tsset `Time'
qui gen `X0'=1 if `touse'
matrix `X0'= J(`N',1,1)
local sthlp ridge2sls

if inlist("`weights'", "x", "xi", "x2", "xi2") & "`wvar'"=="" {
di
di as err " {bf:wvar( )} {cmd:must be combined with:} {bf:weights(x, xi, x2, xi2)}"
exit
 }
if "`ridge'"!="" {
if !inlist("`ridge'", "orr", "grr1", "grr2", "grr3") {
di 
di as err " {bf:ridge( )} {cmd:must be} {bf:ridge({it:orr, grr1, grr2, grr3})}"
di in smcl _c "{cmd: see:} {help `sthlp'##03:Ridge Options}"
di in gr _c " (ridge2sls Help):"
exit
 }	
 }
 if inlist("`ridge'", "grr1", "grr2", "grr3") & `kr'>0 {
di 
di as err " {bf:kr(#)} {cmd:must be not combined with:} {bf:ridge({it:grr1, grr2, grr3})}"
exit
 }
if "`mfx'"!="" {
if !inlist("`mfx'", "lin", "log") {
di 
di as err " {bf:mfx( )} {cmd:must be} {bf:mfx({it:lin})} {cmd:for Linear Model, or} {bf:mfx({it:log})} {cmd:for Log-Log Model}"
exit
 }	
 }
local allinst `"`exog' `inst'"'
local xvar `"`endog' `exog'"'
local exogex : list inst-exog
local endog `endog'
local kendog : word count `endog'
local exog `exog'
local kexog : word count `exog'
local exogex `exogex'
local kexogex : word count `exogex'
local inst `inst'
local kinst : word count `inst'
local kx=`kendog'+`kexog'
local rhsx=`kexog'+1
scalar `ky'=1
tsunab inst : `inst'
tokenize `inst'
local inst `*'
 if `kexog' > 0 {
tsunab exog : `exog'
tokenize `exog'
local exog `*'
 if "`coll'"=="" {
_rmcoll `exog' if `touse' , `noconstant' `coll' forcedrop
 local exog "`r(varlist)'"
 }
 }

tsunab endog : `endog'
tokenize `endog'
local endog `*'
tsunab xvar : `xvar'
tokenize `xvar'
local xvar `*'
 if "`coll'"=="" {
_rmcoll `xvar' if `touse' , `noconstant' `coll' forcedrop
 local xvar "`r(varlist)'"
 }
 local both : list yvar & exog
 if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both LHS and RHS Variables}"
di as res " LHS: `yvar'"
di as res " RHS: `exog'"
 exit
 }
 local both : list yvar & endog
 if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both LHS and Endogenous Variables}"
di as res " LHS  : `yvar'"
di as res " Endog: `endog'"
 exit
 }
 local both : list yvar & inst
 if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both LHS and Instrumental Variables}"
di as res " LHS : `yvar'"
di as res " Inst: `inst'"
 exit
 }
 local both : list endog & inst
 if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both Endogenous and Instrumental Variables}"
di as res " Endog: `endog'"
di as res " Inst : `inst'"
 exit
 }
 local both : list endog & exog
 foreach x of local both {
di
di as err " {bf:{cmd:`x'} included in both Endogenous and Exogenous Variables}"
di as res " Endog: `endog'"
di as res " Exog : `exog'"
 exit
 }
 if "`endog'"=="" {
di as err " {bf:Endogenous Variable(s) must be specified}"
 exit
 }
local yvar `yvar'
mkmat `yvar' if `touse' , matrix(`Yi')
mkmat `yvar' `endog' if `touse' , matrix(`Y')
if "`noconstant'"!="" {
qui cap mkmat `exog' if `touse' , matrix(`Xg')
qui cap mkmat `exog' `exogex' `X0' if `touse' , matrix(`X')
qui cap mkmat `endog' `exog' if `touse' , matrix(`Z')
local instrhs `"`inst' `X0'"'
scalar `DF'=`N'-`kx'
scalar `kb'=`kx'
 }
else if "`noconexog'"!="" {
qui cap mkmat `exog' if `touse' , matrix(`Xg')
qui cap mkmat `exog' `exogex' if `touse' , matrix(`X')
qui cap mkmat `endog' `exog'  if `touse' , matrix(`Z')
local instrhs `"`inst'"'
scalar `DF'=`N'-`kx'
scalar `kb'=`kx'
 }
 else { 
qui cap mkmat `exog' `X0' if `touse' , matrix(`Xg')
qui cap mkmat `exog' `exogex' `X0' if `touse' , matrix(`X')
qui cap mkmat `endog' `exog'  `X0' if `touse' , matrix(`Z')
local instrhs `"`inst' `X0'"'
scalar `DF'=`N'-`kx'-1
scalar `kb'=`kx'+1
 }

local dfs =`kinst'-`rhsx'
if "`exogex'" == "`inst'" {
local exogex 0
local kexogex=0
 } 
 local in=`N'/(`N'-`kb')
 if "`dn'"!="" {
 scalar `DF'=`N'
 local in=1
 }

if `kinst' < `kx' {
 di
di as err " " "{bf:Model cannot be Estimated} {cmd:Equation }" "`yvar'" "{cmd: is Underidentified}" 
local kexogex=0
di _dup(60) "-" 
di as txt "{bf:** Y  = LHS Dependent Variable}
di as txt "   " `ky' " : " "`yvar'"
di as txt "{bf:** Yi = RHS Endogenous Variables}
di as txt "   " `kendog' " : " "`endog'"
di as txt "{bf:** Xi = RHS Included Exogenous Variables}"
di as txt "   " `kexog' " : " "`exog'"
di as txt "{bf:** Xj = RHS Excluded Exogenous Variables}"
di as txt "   " `kexogex' " : " "`exogex'"
di as txt "{bf:** Z  = Overall Instrumental Variables}"
di as txt "   " `kinst' " : "  "`inst'"
di as txt "{bf: Model is Under Identification:}"
di as txt _col(7) "Z(" `kinst' ")" " < Yi + Xi (" `kx' ")
di as txt "* since: Z < Yi + Xi : it is recommended to use (OLS)"
di _dup(60) "-"
exit
 }
matrix `Wi'=J(`N',1,1)
qui gen `Wi'=1 if `touse'
qui gen `weit' = 1 if `touse'
 if "`weights'"!="" {
 if !inlist("`weights'", "yh",  "abse", "e2", "le2", "yh2", "x", "xi", "x2", "xi2") {
 di
di as err " {bf:weights( )} {cmd:works only with:} {bf:yh}, {bf:yh2}, {bf:abse}, {bf:e2}, {bf:le2}, {bf:x}, {bf:xi}, {bf:x2}, {bf:xi2}"
 di in smcl _c "{cmd: see:} {help `sthlp'##04:Weight Options}"
 di in gr _c " (ridge2sls Help):"
 exit
 }
 }
 if "`wvar'"!="" { 
 qui replace `Wi' = (`wvar')^0.5 if `touse'
 }
if "`weights'"!="" {
qui cap drop `Wi'
qui regress `yvar' `xvar' if `touse' , `noconstant'
qui predict `Yho' if `touse' 
qui predict `Eo' if `touse' , resid
qui regress `Yho' `xvar' if `touse' , `noconstant'
qui predict `Wi' if `touse' 
if inlist("`weights'", "yh") {
qui replace `Wi' = 1/(abs(`Wi'))^0.5 if `touse'
local wtitle "Weighted Regression Type: (Yh)    -   Variable: Yh Predicted Value"
 }
if inlist("`weights'", "abse") {
local wtitle "Weighted Regression Type: (absE)  -   Variable: abs(E) Residual Absolute Value"
qui replace `Wi' = 1/(abs(`Eo'))^0.5 if `touse' 
 }
if inlist("`weights'", "e2") {
local wtitle "Weighted Regression Type: (E2)    -   Variable: E^2 Residual Squared"
qui replace `Wi' = 1/(`Eo'^2)^0.5 if `touse'
 }
if inlist("`weights'", "le2") {
local wtitle "Weighted Regression Type: (lE2)   -   Variable: log(E^2) Log Residual Squared"
qui replace `Wi' = log(1/((`Eo')^2)^0.5) if `touse' 
qui replace `Wi' = 0 if `Wi'==.
 }
if inlist("`weights'", "yh2") {
qui cap drop `Wi'
local wtitle "Weighted Regression Type: (Yh2)   -   Variable: Yh^2 Predicted Value Squared"
qui gen `Yho2' = `Yho'^2 if `touse'  
qui regress `Yho2' `xvar' if `touse' , `noconstant'
qui predict `Wi' if `touse' , xb
qui replace `Wi' = 1/(abs(`Wi'))^0.5 if `touse' 
 } 
if inlist("`weights'", "x") {
local wtitle "Weighted Regression Type: (X)     -   Variable: (`wvar')"
qui replace `Wi' = (`wvar')^0.5 if `touse' 
 } 
if inlist("`weights'", "xi") {
local wtitle "Weighted Regression Type: (Xi)    -   Variable: (1/`wvar')"
qui replace `Wi' = 1/(`wvar')^0.5 if `touse' 
 } 
if inlist("`weights'", "x2") {
local wtitle "Weighted Regression Type: (X2)    -   Variable: (`wvar')^2"
qui replace `Wi' = (`wvar')^2 if `touse'
 } 
if inlist("`weights'", "xi2") {
local wtitle "Weighted Regression Type: (Xi2)   -   Variable: (1/`wvar')^2"
qui replace `Wi' = 1/(`wvar')^2 if `touse'
 }
qui replace `weit' =`Wi'^2 if `touse' 
 }
mkmat `Wi' if `touse' , matrix(`Wi')
matrix `Wi'=diag(`Wi')
matrix `WY'=`Wi'*`Y'
matrix `M1'=I(`N')
matrix `M2'=I(`N')
 if `kexog' > 1 {
matrix `M1'=I(`N')-`Wi'*`Xg'*invsym(`Xg''*`Wi''*`Wi'*`Xg')*`Xg''*`Wi''
matrix `M2'=I(`N')-`Wi'*`X'*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''
 }
matrix `Omega'=`Wi''*`Wi'
matrix `Xx'=`X''*`Omega'*`X'
matrix `Zz'=I(`kb')*0
scalar `Kr'=0
mkmat `Wi' if `touse' , matrix(`Wi')
matrix `Wi'=diag(`Wi')
matrix `Omega'=`Wi''*`Wi'
matrix `Xx'=`X''*`Omega'*`X'
matrix `Zz'=I(`kb')*0

if "`ridge'"!="" {
scalar `Kr'=`kr'
qui summ `yvar' if `touse'
qui gen `_Y'`yvar' = `yvar' - `r(mean)' if `touse'
qui foreach var of local xvar {
qui summ `var' if `touse'
qui gen `_X'`var' = `var' - `r(mean)' if `touse'
 }
qui gen `Zo'=0 if `touse'
if ("`noconstant'"!="" | "`noconexog'"!="") {
qui mkmat `_X'* if `touse' , matrix(`Zr')
 }
 else {
qui mkmat `_X'* `Zo' if `touse' , matrix(`Zr')
 }
if inlist("`ridge'", "orr") {
local rtitle "{bf:Ordinary Ridge Regression}"
 }
if inlist("`ridge'", "grr1") {
local rtitle "{bf:Generalized Ridge Regression}"
if ("`noconstant'"!="" | "`noconexog'"!="") {
qui tabstat `xvar' if `touse' , statistics( sd ) save
 }
else {
qui tabstat `xvar' `X0' if `touse' , statistics( sd ) save
 }
 matrix `sd'=r(StatTotal)
 scalar `sqN'=sqrt(`N'-1)
 matrix `WMTD'=diag(`sd')*`sqN'
 matrix `Beta'=invsym(`Z''*`Omega'*`Z')*`Z''*`Omega'*`Yi'
 matrix `BOLS'=`WMTD''*`Beta'
 matrix `BOLS'=`BOLS''*`BOLS'
 scalar `BOLS1'=`BOLS'[1,1]
 matrix `Sig2o'=`Yi'-`Z'*`Beta'
 matrix `Sig2o'=(`Sig2o''*`Sig2o')/`DF'
 scalar `Sig2o1'=`Sig2o'[1,1]
 scalar `Kr'=`kx'*`Sig2o1'/`BOLS1'
 }
if inlist("`ridge'", "grr2") {
local rtitle "{bf:Iterative Generalized Ridge Regression}"
if ("`noconstant'"!="" | "`noconexog'"!="") {
qui tabstat `xvar' if `touse' , statistics( sd ) save
 }
else {
qui tabstat `xvar' `X0' if `touse' , statistics( sd ) save
 }
 matrix `sd'=r(StatTotal)
 scalar `sqN'=sqrt(`N'-1)
 matrix `WMTD'=diag(`sd')*`sqN'
 matrix `Beta'=invsym(`Z''*`Omega'*`Z')*`Z''*`Omega'*`Yi'
 matrix `BOLS'=`WMTD''*`Beta'
 matrix `BOLS'=`BOLS''*`BOLS'
 scalar `BOLS1'=`BOLS'[1,1]
 matrix `Sig2o'=`Yi'-`Z'*`Beta'
 matrix `Sig2o'=(`Sig2o''*`Sig2o')/`DF'
 scalar `Sig2o1'=`Sig2o'[1,1]
 scalar `Kr'=`kx'*`Sig2o1'/`BOLS1'
qui forvalue i=1/`iter' { 
scalar `Ko'=`Kr'
 matrix `rid'=I(`kb')*`Kr'
 matrix `Zz'=diag(vecdiag(`Zr''*`Zr'*`rid'))
 matrix `Beta'=invsym(`Z''*`Omega'*`Z'+`Zz')*`Z''*`Omega'*`Yi'
 matrix `BOLS'=`WMTD''*`Beta'
 matrix `BOLS'=`BOLS''*`BOLS'
 scalar `BOLS1'=`BOLS'[1,1]
 tempname K`i' Koi
 scalar `K`i''=`kx'*`Sig2o1'/`BOLS1'
 scalar `Kr'=`K`i''
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
qui corr `_X'* `_Y'`yvar' if `touse' 
 matrix `CovC'=r(C)
 matrix `RY' = `CovC'[`kb' ,1..`kx']
 matrix `RX' = `CovC'[1..`kx', 1..`kx']
 matrix symeigen `Vec' `VaL'=`RX'
 matrix `VaL1' =`VaL''
qui svmat `VaL1' , name(`VaL1')
qui rename `VaL1'1 `VaL1'
qui replace `VaL1'=1/`VaL1' in 1/`kx' 
qui mkmat `VaL1' in 1/`kx' , matrix(`VaLv1')
 matrix `VaL21' =diag(`VaLv1')
 matrix `VaL21' = `VaL21'[1..`kx', 1..`kx']
 matrix `Go'=`Vec'*`VaL21'*`Vec''
 matrix `GoRY'=`Go'*`RY''
 matrix `SSE'=1-`RY'*`GoRY'
 matrix `Sig2'=`SSE'/`DF'
 matrix `Qr'=`GoRY''*`GoRY'-`Sig2'*trace(`Go')
 matrix `L'=`Vec''*`RY''
qui svmat `L' , name(`L')
qui rename `L'1 `L'
 scalar `Kr'=0
qui forvalue i=1/`iter' { 
 tempname Ko`i'
 scalar `Ko'=`Kr'
 scalar `Ko`i''=`Kr'
 matrix `rid'=I(`kx')
 matrix `rid'=vecdiag(`rid')*`Kr'
 matrix `f1'=`VaL1'+`rid''
 cap drop `f1'*
 cap drop `f13'*
qui svmat `f1' , name(`f1')
qui rename `f1'1 `f1'
 gen double `f13'`i'=`f1'^3 in 1/`kx'
 mkmat `f13'`i' in 1/`kx' , matrix(`f13')
 matrix `f13d'=diag(`f13')
 matrix `f13' =`f13d'[1..`kx', 1..`kx']
 matrix `Rmk' =vecdiag(`f13')'
 matrix `IDRmk'=invsym(`f13')
 matrix `Ls'=`L''*`IDRmk'
 matrix `Ls'=(`Ls'*diag(`L'))'
qui cap drop `Ls' `lf'
qui svmat `Ls' , name(`Ls'`i')
qui rename `Ls'`i'1 `Ls'`i'
 summ `Ls'`i' in 1/`kx'
 scalar `SLS'=r(sum)
 gen double `lf'`i'=`L'/`f1' in 1/`kx'
 mkmat `lf'`i' in 1/`kx' , matrix(`lf'`i')
 matrix `lf'`i' =diag(`lf'`i')
 matrix `lf'`i' = `lf'`i'[1..`kx', 1..`kx']
 matrix `lf'`i' = vecdiag(`lf'`i')'
 matrix `F'=`lf'`i''*`lf'`i'-`Qr'
 scalar `K'`i'=`Ko`i''+(0.5*`F'[1,1]/`SLS')
 scalar `Kr'=`K'`i'
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
di 
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Two Stage Least Squares (2SLS)}}"
di _dup(78) "{bf:{err:=}}"
matrix `Omega'=`Wi''*`Wi'*`X'*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''*`Wi'
matrix `B'=invsym(`Z''*`Omega'*`Z'+`Zz')*`Z''*`Omega'*`Yi'
matrix `E'=`Yi'-`Z'*`B'
matrix `Yh_ML'=`Z'*`B'
matrix `Ue_ML'=`E'
qui svmat `Yh_ML' , name(`Yh_ML')
qui svmat `Ue_ML' , name(`Ue_ML')
qui rename `Yh_ML'1 `Yh_ML'
qui rename `Ue_ML'1 `Ue_ML'
matrix `SSE'=`E''*`E'
scalar `SSEo'=`SSE'[1,1]
scalar `Sig2o'=`SSEo'/`DF'
scalar `Sig2n'=`SSEo'/`N'
scalar `Sigo'=sqrt(`Sig2o')
matrix `OM'=diag(`E')
matrix `We'=`OM'*`OM'
if "`ridge'"!="" & `Kr' > 0 {
matrix `Xx'=`Z''*`Omega'*`Z'
matrix `Cov'=`Sig2o'*invsym(`Z''*`Omega'*`Z'+`Zz')*`Xx'*invsym(`Z''*`Omega'*`Z'+`Zz')
 } 
else {
matrix `Cov'=`Sig2o'*invsym(`Z''*`Omega'*`Z')
 }
qui summ `Yh_ML' if `touse' 
local NUM=r(Var)
qui summ `yvar' if `touse' 
local DEN=r(Var)
scalar `r2v'=`NUM'/`DEN'
scalar `r2v_a'=1-((1-`r2v')*(`N'-1)/`DF')
scalar `fv'=`r2v'/(1-`r2v')*(`N'-`kb')/`kx'
scalar `fvp'=Ftail(`kx', `DF', `fv')
qui correlate `Yh_ML' `yvar' if `touse'
scalar `r2h'=r(rho)*r(rho)
scalar `r2h_a'=1-((1-`r2h')*(`N'-1)/`DF')
scalar `fh'=`r2h'/(1-`r2h')*(`N'-`kb')/`kx'
scalar `fhp'=Ftail(`kx', `DF', `fh')
qui summ `yvar' if `touse' 
local Yb=r(mean)
qui gen `YYm'=(`yvar'-`Yb')^2 if `touse'
qui summ `YYm' if `touse'
qui scalar `SSTm' = r(sum)
qui gen `YYv'=(`yvar')^2 if `touse'
qui summ `YYv' if `touse'
local SSTv = r(sum)
qui summ `weit' if `touse' 
qui gen `Wi1'=sqrt(`weit'/r(mean)) if `touse'
mkmat `Wi1' if `touse' , matrix(`Wi1')
matrix `P' =diag(`Wi1')
qui gen `Wio'=(`Wi1') if `touse' 
mkmat `Wio' if `touse' , matrix(`Wio')
matrix `Wio'=diag(`Wio')
matrix `Pm' =`Wio'
matrix `IPhi'=`P''*`P'
matrix `Phi'=inv(`P''*`P')
matrix `J'= J(`N',1,1)
matrix `D'=(`J'*`J''*`IPhi')/`N'
matrix `SSE'=`E''*`IPhi'*`E'
matrix `SST1'=(`Yi'-`D'*`Yi')'*`IPhi'*(`Yi'-`D'*`Yi')
matrix `SST2'=(`Yi''*`Yi')
scalar `SSE1'=`SSE'[1,1]
scalar `SST11'=`SST1'[1,1]
scalar `SST21'=`SST2'[1,1]
scalar `r2bu'=1-`SSE1'/`SST11'
scalar `r2bu_a'=1-((1-`r2bu')*(`N'-1)/`DF')
scalar `r2raw'=1-`SSE1'/`SST21'
scalar `r2raw_a'=1-((1-`r2raw')*(`N'-1)/`DF')
scalar `f'=`r2bu'/(1-`r2bu')*(`N'-`kb')/`kx'
scalar `fp'= Ftail(`kx', `DF', `f')
local wald=`f'*`kx'
local waldp=chi2tail(`kx', abs(`wald'))
scalar `llf'=-(`N'/2)*log(2*_pi*`SSEo'/`N')-(`N'/2)
local Nof = `N'
local Dof =`DF'
matrix `B' = `B''
if ("`noconstant'"!="" | "`noconexog'"!="") {
 matrix colnames `Cov' = `endog' `exog'
 matrix rownames `Cov' = `endog' `exog'
 matrix colnames `B'   = `endog' `exog'
 }
else { 
 matrix colnames `Cov' = `endog' `exog' _cons
 matrix rownames `Cov' = `endog' `exog' _cons
 matrix colnames `B'   = `endog' `exog' _cons
 }
yxregeq `yvar' `xvar'
if "`weights'"!="" { 
di as txt _col(1) "{bf:* " "`wtitle'" " *}"
di _dup(78) "-"
 }
if "`ridge'"!="" {
di as txt _col(2) "{bf:Ridge k Value}" _col(21) "=" as res %10.5f `Kr' _col(37) "|" _col(41) "`rtitle'"
di _dup(78) "-"
 }
di as txt _col(3) "Sample Size" _col(21) "=" %12.0f as res `N'
if `r2bu'>0 {
ereturn post `B' `Cov' , dep(`yvar') obs(`Nof') dof(`Dof')
qui test `xvar'
local f=r(F)
local fp= Ftail(`kx', `DF', `f')
local wald=`f'*`kx'
local waldp=chi2tail(`kx', abs(`wald'))
di as txt _col(3) "{cmd:Wald Test}" _col(21) "=" %12.4f as res `wald' _col(37) "|" _col(41) as txt "P-Value > {cmd:Chi2}(" as res `kx' ")" _col(65) "=" %12.4f as res `waldp'
di as txt _col(3) "{cmd:F-Test}" _col(21) "=" %12.4f as res `f' _col(37) "|" _col(41) as txt "P-Value > {cmd:F}(" as res `kx' " , " `DF' ")" _col(65) "=" %12.4f as res `fp'
di as txt _col(2) "(Buse 1973) R2" _col(21) "=" %12.4f as res `r2bu' _col(37) "|" as txt _col(41) "Raw Moments R2" _col(65) "=" %12.4f as res `r2raw'
ereturn scalar r2bu =`r2bu'
ereturn scalar r2bu_a=`r2bu_a'
ereturn scalar f =`f'
ereturn scalar fp=`fp'
ereturn scalar wald =`wald'
ereturn scalar waldp=`waldp'
di as txt _col(2) "(Buse 1973) R2 Adj" _col(21) "=" %12.4f as res `r2bu_a' _col(37) "|" as txt _col(41) "Raw Moments R2 Adj" _col(65) "=" %12.4f as res `r2raw_a'
di as txt _col(3) "Root MSE (Sigma)" _col(21) "=" %12.4f as res `Sigo' as txt _col(37) "|" _col(41) "Log Likelihood Function" _col(65) "=" %12.4f as res `llf'
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
ereturn scalar r2h=`r2h'
ereturn scalar r2h_a=`r2h_a'
ereturn scalar fh=`fh'
ereturn scalar fhp=`fhp'
ereturn scalar Kr=`Kr'
ereturn scalar kb=`kb'
ereturn scalar kx=`kx'
ereturn scalar DF=`DF'
ereturn scalar Nn=_N
 }
if `r2bu' < 0 {
 qui foreach var of local endog {
 qui regress `var' `inst' if `touse' , `noconstant'
 qui predict `Yhat1'`var' if `touse' 
 }
 qui regress `yvar' `Yhat1'* `exog'  if `touse' , `noconstant'
 local ssr=e(mss)
local r2cc =(`ssr'/`SSEo'*`DF')/(`ssr'/`SSEo'*`DF'+`DF')
local r2cc_a=1-((1-`r2cc')*(`N'-1)/`DF')
local fc=`r2cc'/(1-`r2cc')*(`DF')/`kx'
local r2c_a=1-((1-`r2bu')*(`N'-1)/`DF')
local r2u_a=1-((1-`r2raw')*(`N'-1)/`DF')
local fpc= Ftail(`kx', `DF', `fc')
di as txt _col(3) "F-Test" _col(21) "=" %12.4f as res `fc' _col(37) "|" _col(41) as txt "P-Value > F(" as res `kx' " , " `DF' ")" _col(65) "=" %12.4f as res `fpc'
di as txt _col(3) "R2 (-)" _col(21) "=" %12.4f as res `r2bu' _col(37) "|" as txt _col(41) "Adj R2 (-)" _col(65) "=" %12.4f as res `r2c_a'
di as txt _col(3) "Corrected R2" _col(21) "=" %12.4f as res `r2cc' _col(37) "|" _col(41) as txt "Raw Moments R2" _col(65) "=" %12.4f as res `r2raw'
di as txt _col(3) "Corrected R2 Adj" _col(21) "=" %12.4f as res `r2cc_a'  _col(37) "|" _col(41) as txt "Raw Moments R2 Adj" _col(65) "=" %12.4f as res `r2u_a'
di as txt _col(3) "Root MSE (Sigma)" _col(21) "=" %12.4f as res `Sigo' as txt _col(37) "|" _col(41) "Log Likelihood Function" _col(65) "=" %12.4f as res `llf'
ereturn post `B' `Cov' , dep(`yvar') obs(`Nof') dof(`Dof')
ereturn scalar r2c =`r2bu'
ereturn scalar r2c_a=`r2c_a'
ereturn scalar r2cc=`r2cc'
ereturn scalar r2cc_a =`r2cc_a'
ereturn scalar f =`fc'
ereturn scalar fp=`fpc'
 } 
ereturn display , `level'
matrix `b'=e(b)
matrix `V'=e(V)
matrix `Bx'=e(b)
di as txt "{bf:* Y  = LHS Dependent Variable:}" _col(37) " " `ky' " = " "`yvar'"
di as txt "{bf:* Yi = RHS Endogenous Variables:}"_col(37) " " `kendog' " = " "`endog'"
di as txt "{bf:* Xi = RHS Included Exogenous Vars:}"_col(37) " " `kexog' " = " "`exog'"
di as txt "{bf:* Xj = RHS Excluded Exogenous Vars:}"_col(37) " " `kexogex' " = " "`exogex'"
di as txt "{bf:* Z  = Overall Instrumental Vars:}"_col(37) " " `kinst' " = "  "`inst'"

if "`predict'"!= "" {
cap drop `predict'
qui gen `predict'=`Yh_ML' if `touse' 
label variable `predict' `"Yh - Prediction"'
 }
if "`resid'"!= "" {
qui cap drop `resid'
qui gen `resid'=`Ue_ML' if `touse'
label variable `resid' `"Ue - Residual"'
 }

if "`diag'" != "" {
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* 2SLS-IV Model Selection Diagnostic Criteria}}"
di _dup(78) "{bf:{err:=}}"
ereturn scalar aic=`Sig2n'*exp(2*`kb'/`N')
ereturn scalar laic=ln(`Sig2n')+2*`kb'/`N'
ereturn scalar fpe=`Sig2o'*(1+`kb'/`N')
ereturn scalar sc=`Sig2n'*`N'^(`kb'/`N')
ereturn scalar lsc=ln(`Sig2n')+`kb'*ln(`N')/`N'
ereturn scalar hq=`Sig2n'*ln(`N')^(2*`kb'/`N')
ereturn scalar rice=`Sig2n'/(1-2*`kb'/`N')
ereturn scalar shibata=`Sig2n'*(`N'+2*`kb')/`N'
ereturn scalar gcv=`Sig2n'*(1-`kb'/`N')^(-2)
ereturn scalar llf = `llf'
di as txt "- Log Likelihood Function" _col(45) "LLF" _col(60) "=" %12.4f `e(llf)'
di _dup(75) "-"
di as txt "- Akaike Information Criterion" _col(45) "(1974) AIC" _col(60) "=" %12.4f `e(aic)'
di as txt "- Akaike Information Criterion" _col(45) "(1973) Log AIC" _col(60) "=" %12.4f `e(laic)'
di _dup(75) "-"
di as txt "- Schwarz Criterion" _col(45) "(1978) SC" _col(60) "=" %12.4f `e(sc)'
di as txt "- Schwarz Criterion" _col(45) "(1978) Log SC" _col(60) "=" %12.4f `e(lsc)'
di _dup(75) "-"
di as txt "- Amemiya Prediction Criterion" _col(45) "(1969) FPE" _col(60) "=" %12.4f `e(fpe)'
di as txt "- Hannan-Quinn Criterion" _col(45) "(1979) HQ" _col(60) "=" %12.4f `e(hq)'
di as txt "- Rice Criterion" _col(45) "(1984) Rice" _col(60) "=" %12.4f `e(rice)'
di as txt "- Shibata Criterion" _col(45) "(1981) Shibata" _col(60) "=" %12.4f `e(shibata)'
di as txt "- Craven-Wahba Generalized Cross Validation" _col(45) "(1979) GCV" _col(60) "=" %12.4f `e(gcv)'
di _dup(78) "-"
 }

if "`first'"!="" {
qui tsset `Time'
 tokenize `endog'
 local i 1
 while "``i''" != "" {
di
di _dup(78) "-"
di as err " {bf:- Variable ""(``i'')" ": " "First-Stage Regression (Reduced Form)}"
 regress ``i'' `inst' `weight' if `touse' , `noconstant' `levopt'
 local i = `i' + 1
 }
 }
if inlist("`mfx'", "lin", "log") {
tempname mfxb mfxe mfxlin mfxlog XMB XYMB YMB YMB1
matrix `Bx'=`Bx'[1, 1..`kx']'
qui mean `xvar' if `touse' 
matrix `XMB'=e(b)'
qui summ `yvar' if `touse' 
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
matrix rownames `mfxlin' = `xvar'
matrix colnames `mfxlin' = Marginal_Effect(B) Elasticity(Es) Mean
matlist `mfxlin' , title({bf:* Marginal Effect - Elasticity: {err:Linear} *}) twidth(10) border(all) lines(columns) rowtitle(Variable) format(%18.4f)
ereturn matrix mfxlin=`mfxlin'
 }
if inlist("`mfx'", "log") {
mata: `XYMB'=Y:/X
mata: `XYMB'=st_matrix("`XYMB'",`XYMB')
matrix `mfxe'=`Bx'
matrix `mfxb'=vecdiag(`Bx'*`XYMB'')'
matrix `mfxlog' =`mfxe',`mfxb',`XMB'
matrix rownames `mfxlog' = `xvar'
matrix colnames `mfxlog' = Elasticity(Es) Marginal_Effect(B) Mean
matlist `mfxlog' , title({bf:* Elasticity - Marginal Effect: {err:Log-Log} *}) twidth(10) border(all) lines(columns) rowtitle(Variable) format(%18.4f)
ereturn matrix mfxlog=`mfxlog'
 }
di as txt " Mean of Dependent Variable =" as res _col(30) %12.4f `YMB1' 
 }
qui tsset `TimeN'
qui cap mata: mata drop *
end

program define yxregeq
version 10.0
 syntax varlist 
tempvar `varlist'
gettoken yvar xvar : varlist
local LEN=length("`yvar'")
local LEN=`LEN'+3
di "{p 2 `LEN' 5}" as res "{bf:`yvar'}" as txt " = " "
local kx : word count `xvar'
local i=1
 while `i'<=`kx' {
local X : word `i' of `xvar'
 if `i'<`kx' {
di " " as res " {bf:`X'}" _c
di as txt " + " _c
 }
 if `i'==`kx' {
di " " as res "{bf:`X'}"
 }
local i=`i'+1
 }
di "{p_end}"
di as txt "{hline 78}"
end


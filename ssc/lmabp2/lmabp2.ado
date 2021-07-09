*! lmabp2 V1.0 03/07/2014
*! 
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

*! Sahra Khaleel A. Mickaiel
*! Professor (PhD Economics)
*! Cairo University - Faculty of Agriculture - Department of Economics - Egypt
*! Email: sahra_atta@hotmail.com
*! WebPage at IDEAS:      http://ideas.repec.org/f/pmi520.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/pmi520.htm

program define lmabp2 , eclass byable(onecall)
version 11.2
syntax [anything] [if] [in] , Model(string) [NOCONStant NOCONEXOG kc(real 0) ///
 KF(real 0) HETcov(str) coll LAGs(int 1)]
tempvar E E2 U U2 X0 Yh Yhb Ev Ue Lambdav Lambda Time TimeN YY Yb YYv
tempvar wald SSE SST weit EE Ea Ea1 Es Es1 DW WS LE DE Yho2
tempvar Yt LDE DF1 Eo Lambda0 Yh2 LYh2 E3 E4 Yhr YYm
tempvar LE XQ ht Hat Yhat1 Yho Yh_ML Ue_ML Wio Wi DFF DFF1 DFF2 Yh
tempname X Y Z M2 XgXg Xg M1 W1 W2 W1W Lambda Vec Yi E Cov b h mh kliml
tempname Wio Wi Ew OM Omega hjm Wald We vy1 v kyi kzi
tempname Bv1 Bv lamp1 lamp2 lamp M W b1 v1 q lmhs b2 v2 Beta P Pm IPhi Phi J D
tempname Hat Wi1 Z0 Z1 xq Eo E1 EE1 Sw Sn nw S11 S12 WY Xgw Eg Sig2 Sig2o
tempname X X0 Vec J SST1 SST2 Sig2o1 CovC SSE Sig2 F K B Bx Zo qhiv V Ko Koi
tempname Nn kx kb DF N ky kyi kzi llf rhsendog Kz biv2 viv2 kmelo
tempname SSEo Sigo r2bu r2bu_a r2raw r2raw_a f fp wald waldp Qr SLS Q L
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
local sthlp lmabp2
if "`model'"!="" {
if !inlist("`model'", "2sls", "liml", "kclass", "fuller", "gmm", "melo") {
di 
di as err " {bf:model( )} {cmd:must be} {bf:model({it:2sls, liml, melo, kclass, fuller, gmm})}"
di in smcl _c "{cmd: see:} {help `sthlp'##03:Model Options}"
di in gr _c " (lmabp2 Help):"
exit
 }
 }
if "`hetcov'"!="" {
if !inlist("`hetcov'", "white", "nwest", "bart", "trunc", "parzen", "quad") {
if !inlist("`hetcov'", "tukeyn", "tukeym", "dan", "tent") {
di 
di as err "{bf:hetcov()} {cmd:must be} {bf:({it:bart, dan, nwest, parzen, quad, tent, trunc, tukeym, tukeyn, white})}"
di in smcl _c "{cmd: see:} {help `sthlp'##04:GMM Options}"
di in gr _c " (lmabp2 Help):"
exit
 }
 }
 }
if !inlist("`model'", "kclass") & "`kc'"=="" {
di
di as err " {bf:kc({it:#})} {cmd:Theil k-Class works only with:} {bf:model({it:kclass})}"
exit
 }
if !inlist("`model'", "fuller") & "`kf'"=="" {
di
di as err " {bf:kf({it:#})} {cmd:Fuller k-Class works only with:} {bf:model({it:fuller})}"
exit
 }
if !inlist("`model'", "gmm") & "`hetcov'"!="" {
di
di as err " {bf:hetcov( )} {cmd:works only with:} {bf:model({it:gmm})}"
exit
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
if `kinst' < `kx' {
di
di as err " " "`model'" "{bf: cannot be Estimated} {cmd:Equation }" "`yvar'" "{cmd: is Underidentified}" 
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
mkmat `Wi' if `touse' , matrix(`Wi')
matrix `Wi'=diag(`Wi')
matrix `WY'=`Wi'*`Y'
matrix `M1'=I(`N')
matrix `M2'=I(`N')
 if `kexog' > 1 {
matrix `M1'=I(`N')-`Wi'*`Xg'*invsym(`Xg''*`Wi''*`Wi'*`Xg')*`Xg''*`Wi''
matrix `M2'=I(`N')-`Wi'*`X'*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''
 }
matrix `W1'=`WY''*`M1'*`WY'
matrix `W2'=`WY''*`M2'*`WY'
matrix `W1W'=`W1'*invsym(`W2')
matrix eigenvalues `Lambda' `Vec' = `W1W'
matrix `Lambda' =`Lambda''
svmat `Lambda' , name(`Lambdav')
rename `Lambdav'1 `Lambda'
qui summ `Lambda' if `touse'
scalar `kliml'=r(min)
matrix `Omega'=`Wi''*`Wi'
mkmat `Wi' if `touse' , matrix(`Wi')
matrix `Wi'=diag(`Wi')
matrix `Omega'=`Wi''*`Wi'
di 
 if inlist("`model'", "2sls")  {
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Two Stage Least Squares (2SLS)}}"
di _dup(78) "{bf:{err:=}}"
matrix `Omega'=`Wi''*`Wi'*`X'*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''*`Wi'
matrix `B'=invsym(`Z''*`Omega'*`Z')*`Z''*`Omega'*`Yi'
 }

 if inlist("`model'", "liml") {
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Limited-Information Maximum Likelihood (LIML)}}"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf: K - Class (LIML) Value  =} " as res %9.5f `kliml'
matrix `Omega'=`Wi''*`Wi'*`X'*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''*`Wi'
matrix `Omega'=(I(`N')-`kliml'*(I(`N')-`Omega'))
matrix `B'=invsym(`Z''*`Omega'*`Z')*`Z''*`Omega'*`Yi'
 }

 if inlist("`model'", "kclass") {
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Theil k-Class (LIML)}}"
di _dup(78) "{bf:{err:=}}"
local kc =`kc'
di as txt "{bf: K - Class Value  =} " as res %9.5f `kc'
matrix `Omega'=`Wi'*(I(`N')-`kc'*(I(`N')-`Wi'*`X' ///
*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''))*`Wi'
matrix `B'=invsym(`Z''*`Omega'*`Z')*`Z''*`Omega'*`Yi'
 }

 if inlist("`model'", "fuller") {
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Fuller k-Class (LIML)}}"
di _dup(78) "{bf:{err:=}}"
local kfc =`kliml'-(`kf'/(`N'-`kinst'))
di as txt "{bf:  LIML-Class Value}" _col(27) " = " as res %9.5f `kliml'
di as txt "{bf: Alpha-Class Value}" _col(27) " = " as res %9.5f `kf'
di as txt "{bf:     K-Class Fuller Value}" _col(27) " = " as res %9.5f `kfc'
matrix `Omega'=`Wi'*(I(`N')-`kfc'*(I(`N')-`Wi'*`X' ///
*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''))*`Wi'
matrix `B'=invsym(`Z''*`Omega'*`Z')*`Z''*`Omega'*`Yi'
 }

 if inlist("`model'", "melo") {
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Minimum Expected Loss (MELO)}}"
di _dup(78) "{bf:{err:=}}"
scalar `kyi'=`kendog'
scalar `kzi'=`kyi'+`kx'
scalar `kmelo'=1-`kx'/(`N'-`kzi'-2)
di as txt "{bf: K - Class (MELO) Value  =} " as res %9.5f `kmelo'
matrix `Omega'=`Wi'*(I(`N')-`kmelo'*(I(`N')-`Wi'*`X' ///
*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''))*`Wi'
matrix `B'=invsym(`Z''*`Omega'*`Z')*`Z''*`Omega'*`Yi'
 }

 if inlist("`model'", "gmm") & inlist("`hetcov'", "white") {
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (White Method)}}"
di _dup(78) "{bf:{err:=}}"
matrix `Omega'=`Wi''*`Wi'*`X'*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''*`Wi'
matrix `B'=invsym(`Z''*`Omega'*`Z')*`Z''*`Omega'*`Yi'
matrix `E'=`Yi'-`Z'*`B'
matrix `OM'=diag(`E')
matrix `We'=`OM'*`OM'
matrix `Omega'=`X'*invsym(`X''*`We'*`X')*`X''
matrix `B'=invsym(`Z''*`Omega'*`Z')*`Z''*`Omega'*`Yi'
 }

if inlist("`hetcov'", "bart") {
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Bartlett Method)}}"
di _dup(78) "{bf:{err:=}}"
local i=1
local L=4*(`N'/100)^(2/9)
local Li=`i'/(1+`L')
local kw=1-`Li'
 }
if inlist("`hetcov'", "dan") {
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Daniell Method)}}"
di _dup(78) "{bf:{err:=}}"
local i=1
local L=4*(`N'/100)^(2/9)
local Li=`i'/(1+`L')
local kw=sin(_pi*`Li')/(_pi*`Li')
 }
if inlist("`hetcov'", "nwest") {
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Newey-West Method)}}"
di _dup(78) "{bf:{err:=}}"
local i=1
local L=1
local Li=`i'/(1+`L')
local kw=1-`Li'
 }
if inlist("`hetcov'", "parzen") {
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Parzen Method)}}"
di _dup(78) "{bf:{err:=}}"
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
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Quadratic Spectral Method)}}"
di _dup(78) "{bf:{err:=}}"
local i=1
local L=4*(`N'/100)^(2/25)
local Li=`i'/(1+`L')
local kw=(25/(12*_pi^2*`Li'^2))*(sin(6*_pi*`Li'/5)/(6*_pi*`Li'/5)-sin(6*_pi*`Li'/5+_pi/2))
}
if inlist("`hetcov'", "tent") {
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Tent Method)}}"
di _dup(78) "{bf:{err:=}}"
local i=1
local L=4*(`N'/100)^(2/9)
local Li=`i'/(1+`L')
local kw=2*(1-cos(`Li'*`Li'))/(`Li'^2)
 }
if inlist("`hetcov'", "trunc") {
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Truncated Method)}}"
di _dup(78) "{bf:{err:=}}"
local i=1
local L=4*(`N'/100)^(1/4)
local Li=`i'/(1+`L')
local kw=1-`Li'
 }
if inlist("`hetcov'", "tukeym") {
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Tukey-Hamming Method)}}"
di _dup(78) "{bf:{err:=}}"
local i=1
local L=4*(`N'/100)^(1/4)
local Li=`i'/(1+`L')
local kw=0.54+0.46*cos(_pi*`Li')
 }
if inlist("`hetcov'", "tukeyn") {
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Tukey-Hanning Method)}}"
di _dup(78) "{bf:{err:=}}"
local i=1
local L=4*(`N'/100)^(1/4)
local Li=`i'/(1+`L')
local kw=(1+sin((_pi*`Li')+_pi/2))/2
 }

if inlist("`model'", "gmm") & !inlist("`hetcov'", "white") {
qui gen `Z0' = 1 if `touse'
qui replace `Z0' = 0 in 1
qui foreach var of local xvar {
qui gen `xq'`var' = `var'[_n-1] if `touse'
qui replace `xq'`var' = 0 in 1
 }
if ("`noconstant'"!="" | "`noconexog'"!="") {
qui mkmat `xq'* if `touse' , matrix(`M')
 }
 else {
qui mkmat `xq'* `Z0' if `touse' , matrix(`M')
 }
matrix `Omega'=`Wi''*`Wi'*`X'*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''*`Wi'
matrix `B'=invsym(`Z''*`Omega'*`Z')*`Z''*`Omega'*`Yi'
matrix `E'=`Yi'-`Z'*`B'
svmat `E' , name(`Eg')
rename `Eg'1 `Eg'
qui gen `E1'=`Eg'[_n-1] if `touse'
qui gen `EE1'=`E1'*`Eg' if `touse'
qui replace `EE1' = 0 if `EE1'==.
mkmat `EE1' if `touse' , matrix(`EE1')
matrix `OM'=diag(`E')
matrix `We'=`OM'*`OM'
matrix `Sw'=`Z''*`We'*`Z'
matrix `We'=diag(`EE1')
matrix `S11'=`Z''*`We'*`M'
matrix `S12'=`M''*`We'*`Z'
matrix `Sn'=(`S11'+`S12')*`kw'
matrix `nw'=(`Sw'+`Sn')*`in'
matrix `nw'=`nw'*`in'
matrix `Omega'=`X'*invsym(`X''*`X')*`X''
matrix `B'=invsym(`Z''*`Omega'*`Z')*`Z''*`Omega'*`Yi'
 }
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
scalar `Sigo'=sqrt(`Sig2o')
matrix `OM'=diag(`E')
matrix `We'=`OM'*`OM'
matrix `hjm'=(`E''*(`X'*invsym(`X''*`We'*`X')*`X'')*`E')
local lmihj=`hjm'[1,1]
local dfgmm=`kinst'-`kx'
local lmihjp= chi2tail(`dfgmm', abs(`lmihj'))
if inlist("`model'", "2sls", "liml", "melo", "fuller", "kclass") {
matrix `Cov'=`Sig2o'*invsym(`Z''*`Omega'*`Z')
 }
if inlist("`model'", "gmm") & inlist("`hetcov'", "white") {
matrix `Cov'=invsym(`Z''*`Omega'*`Z')
 }
if inlist("`model'", "gmm") & !inlist("`hetcov'", "white") {
matrix `Cov'=invsym(`Z''*`Omega'*`Z')*`nw'*invsym(`Z''*`Omega'*`Z')
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
di as txt _col(2) "F-Test" _col(21) "=" %12.4f as res `fc' _col(37) "|" _col(41) as txt "P-Value > F(" as res `kx' " , " `DF' ")" _col(65) "=" %12.4f as res `fpc'
di as txt _col(2) "R2 (-)" _col(21) "=" %12.4f as res `r2bu' _col(37) "|" as txt _col(41) "Adj R2 (-)" _col(65) "=" %12.4f as res `r2c_a'
di as txt _col(2) "Corrected R2" _col(21) "=" %12.4f as res `r2cc' _col(37) "|" _col(41) as txt "Raw Moments R2" _col(65) "=" %12.4f as res `r2raw'
di as txt _col(2) "Corrected R2 Adj" _col(21) "=" %12.4f as res `r2cc_a'  _col(37) "|" _col(41) as txt "Raw Moments R2 Adj" _col(65) "=" %12.4f as res `r2u_a'

di as txt _col(2) "Root MSE (Sigma)" _col(21) "=" %12.4f as res `Sigo' as txt _col(37) "|" _col(41) "Log Likelihood Function" _col(65) "=" %12.4f as res `llf'
ereturn post `B' `Cov' , dep(`yvar') obs(`Nof') dof(`Dof')
ereturn scalar r2c =`r2bu'
ereturn scalar r2c_a=`r2c_a'
ereturn scalar r2cc=`r2cc'
ereturn scalar r2cc_a =`r2cc_a'
ereturn scalar f =`fc'
ereturn scalar fp=`fpc'
 } 
if inlist("`model'", "gmm") {
local dfgmm=`kinst'-`kx'
di as txt "{bf: Hansen Over Identification J Test =}" %12.4f as res `lmihj' _col(51) as txt "P-Value > Chi2(" `dfgmm' ")" _col(72) as res %5.4f as res `lmihjp'
ereturn scalar lmihj = `lmihj'
ereturn scalar lmihjp = `lmihjp'
 }
ereturn display 
matrix `b'=e(b)
matrix `V'=e(V)
matrix `Bx'=e(b)
di as txt "{bf:* Y  = LHS Dependent Variable:}" _col(37) " " `ky' " = " "`yvar'"
di as txt "{bf:* Yi = RHS Endogenous Variables:}"_col(37) " " `kendog' " = " "`endog'"
di as txt "{bf:* Xi = RHS Included Exogenous Vars:}"_col(37) " " `kexog' " = " "`exog'"
di as txt "{bf:* Xj = RHS Excluded Exogenous Vars:}"_col(37) " " `kexogex' " = " "`exogex'"
di as txt "{bf:* Z  = Overall Instrumental Vars:}"_col(37) " " `kinst' " = "  "`inst'"
tempname SSE Rho SBBs SRhos lmabp
local N=`Nn'
qui tsset `Time'
tempvar Yh Yh2 U2 E E2 E3 E4 Es SBB SRho Rho
qui gen `Yh'=`Yh_ML' if `touse'
qui gen `E' =`Ue_ML' if `touse'
matrix `Cov'=e(V)
qui forvalue i=1/`lags' {
tempvar E`i' EE`i' LE`i' DE`i' LEE`i'
 gen `E`i''=`E'^`i' if `touse'
 gen `LE`i'' =L`i'.`E' if `touse'
 gen `LEE`i''=L`i'.`E'*`E' if `touse'
 summ `LEE`i'' if `touse'
scalar `SSE'`i'=r(sum)
scalar `Rho'`i'=`SSE'`i'/`SSEo'
 }
qui gen double `SBB' = . if `touse'
qui gen double `SRho'= . if `touse'
scalar `SBBs' = 0
scalar `SRhos'= 0
qui forvalue i=1/`lags' {
qui replace `SRho' = `Rho'`i'^2 if `touse'
summ `SRho' if `touse' , meanonly
qui replace `SRho' = r(mean) if `touse'
summ `SRho' if `touse' , meanonly
scalar `SRhos' = `SRhos' + r(mean)
scalar `lmabp'`i'=`N'*`SRhos'
 }
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:*** 2SLS-IV Autocorrelation Box-Pierce Test - Model= ({bf:{err:`model'}})}}"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf: Ho: No Autocorrelation - Ha: Autocorrelation}"
di _dup(78) "-"
if "`lags'"!="" {
forvalue i=1/`lags' {
di as txt "- Rho Value for Order(" `i' ")" _col(40) "AR(" `i' ")=" as res %8.4f `Rho'`i'
ereturn scalar rho`i'=`Rho'`i'
di as txt "- Box-Pierce LM Test" _col(40) "AR(" `i' ")=" as res %8.4f `lmabp'`i' _col(56) as txt "P-Value >Chi2(`i')" _col(73) as res %5.4f chi2tail(`i', abs(`lmabp'`i'))
ereturn scalar lmabp`i'=`lmabp'`i'
ereturn scalar lmabpp`i'=chi2tail(`i', abs(`lmabp'`i'))
di _dup(78) "-"
 }
 }
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


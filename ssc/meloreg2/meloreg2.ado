*! meloreg2 V1.0 15jan2012
*! Emad Abd Elmessih Shehata
*! Assistant Professor
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage: http://emadstat.110mb.com/stata.htm

program define meloreg2 , eclass byable(onecall)
version 10.1
syntax [anything] [if] [in] , [WVar(str) NOCONStant NOCONEXOG Level(cilevel) ///
 DN Weights(str) PREDict(str) RESid(str)]
tempvar E E2 U U2 X0 Yh Yhb Ev Ue Lambdav Lambda Time YY Yb YYv YYm Wio Wi
tempvar wald SSE SST weit Yho2 Yt e DF1 Eo Lambdav0 Lambda0
tempvar Yh2 LYh2 LnE2 absE LE DF Yhat1 Yho
tempname X Y Z M2 XgXg Xg M1 W1 W2 W1W Lambda Vec Yi Sig2 E Cov b h 
tempname Omega Wald We lamp1 lamp2 lamp M W P Pm IPhi Phi J D Wi1 Z0 Z1
tempname Eo E1 WY Xgw Eg Sig2n X X0 J SSE Sig2 Q L F K B Bx Beta Wio Wi Ew
marksample touse
qui cap count if `touse'
qui gen `X0'=1 if `touse'
local N = r(N)
qui gen `Time'=_n
qui tsset `Time'
local sthlp reg2
if "`hetcov'"!="" {
if !inlist("`hetcov'", "white", "nwest", "bart", "trunc", "parzen", "quad") {
if !inlist("`hetcov'", "tukeyn", "tukeym", "dan", "tent") {
di 
di as err "{bf:hetcov()} {cmd:must be} {bf:({it:bart, dan, nwest, parzen, quad, tent, trunc, tukeym, tukeyn, white})}"
exit
 }
 }
 }
if inlist("`weights'", "x", "xi", "x2", "xi2") & "`wvar'"=="" {
di
di as err " {bf:wvar( )} {cmd:must be combined with:} {bf:weights(x, xi, x2, xi2)}"
exit
 }
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
local options "Level(cilevel)"
local allinst `"`exog' `inst'"'
local xvar `"`endog' `exog'"'
local exogex : list inst-exog
local endog `endog'
local kendog : word count `endog'
scalar kendog=`kendog'
local exog `exog'
local kexog : word count `exog'
scalar kexog=`kexog'
local exogex `exogex'
local kexogex : word count `exogex'
local inst `inst'
local kinst : word count `inst'
scalar kinst=`kinst'
local kx=kendog+kexog
local rhsx=kexog+1
markout `touse' `yvar' `endog' `inst' `exog' `allinst' `xvar' `exogex'
 _rmdcoll `xvar'  if `touse', `noconstant'
 _rmdcoll `endog' if `touse', `noconstant'
 _rmdcoll `inst'  if `touse', `noconstant'
scalar ky=1
tsunab inst : `inst'
tokenize `inst'
local inst `*'
 if kexog > 0 {
tsunab exog : `exog'
tokenize `exog'
local exog `*'
 _rmdcoll `exog'  if `touse', `noconstant'
 }
tsunab endog : `endog'
tokenize `endog'
local endog `*'
tsunab xvar : `xvar'
tokenize `xvar'
local xvar `*'
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
local DF=`N'-`kx'
local kb=`kx'
 }
else if "`noconexog'"!="" {
qui cap mkmat `exog' if `touse' , matrix(`Xg')
qui cap mkmat `exog' `exogex' if `touse' , matrix(`X')
qui cap mkmat `endog' `exog' if `touse' , matrix(`Z')
local instrhs `"`inst'"'
local DF=`N'-`kx'
local kb=`kx'
 }
 else { 
qui cap mkmat `exog' `X0' if `touse' , matrix(`Xg')
qui cap mkmat `exog' `exogex' `X0' if `touse' , matrix(`X')
qui cap mkmat `endog' `exog' `X0' if `touse' , matrix(`Z')
local instrhs `"`inst' `X0'"'
local DF=`N'-`kx'-1
local kb=`kx'+1
 }
local dfs =`kinst'-`rhsx'
if "`exogex'" == "`inst'" {
local exogex 0
scalar kexogex=0
 } 
 local in=`N'/(`N'-`kb')
 if "`dn'"!="" {
 local DF=`N'
 local in=1
 }

if `kinst' < `kx' {
 di
 di as err " " "`model'" "{bf: cannot be Estimated} {cmd:Equation }" "`yvar'" "{cmd: is Underidentified}" 
scalar kexogex=0
di _dup(60) "-" 
di as txt "{bf:** Y  = LHS Dependent Variable}
di as txt "   " ky " : " "`yvar'"
di as txt "{bf:** Yi = RHS Endogenous Variables}
di as txt "   " kendog " : " "`endog'"
di as txt "{bf:** Xi = RHS Included Exogenous Variables}"
di as txt "   " kexog " : " "`exog'"
di as txt "{bf:** Xj = RHS Excluded Exogenous Variables}"
di as txt "   " `kexogex' " : " "`exogex'"
di as txt "{bf:** Z  = Overall Exogenous Variables}"
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
 di in smcl _c "{cmd: see:} {help `sthlp'##05:Options}"
 di in gr _c " (reg2 Help):"
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
 qui predict `Eo'  if `touse' , resid
 qui regress `Yho' `xvar' if `touse' , `noconstant'
 qui predict `Wi' if `touse'
if inlist("`weights'", "yh") {
 local wtitle "Weighted Type: yh - Variable: Yh Predicted Value"
 }
if inlist("`weights'", "abse") {
 local wtitle "Weighted Type: abse - Variable: abs(E) Absolute Value of Residual"
 qui replace `Wi' = abs(`Eo') if `touse'
 }
if inlist("`weights'", "e2") {
 local wtitle "Weighted Type: e2 - Variable: E^2 Residual Squared"
 qui replace `Wi' = (`Eo')^2 if `touse' 
 }
if inlist("`weights'", "le2") {
 local wtitle "Weighted Type: le2 - Variable: log(E^2) Log Residual Squared"
 qui replace `Wi' = log((`Eo')^2) if `touse'
 }
if inlist("`weights'", "yh2") {
 qui cap drop `Wi'
 local wtitle "Weighted Type: yh2 - Variable: Yh^2 Predicted Value Squared"
 qui gen `Yho2' = `Yho'^2 if `touse'
 qui regress `Yho2' `xvar' if `touse' , `noconstant'
 qui predict `Wi' if `touse'
 } 
if inlist("`weights'", "x") {
 local wtitle "Weighted Type: X - Variable: (`wvar')"
 qui replace `Wi' = (`wvar')^0.5 if `touse'
 } 
if inlist("`weights'", "xi") {
 local wtitle "Weighted Type: xi - Variable: (1/`wvar')"
 qui replace `Wi' = 1/(`wvar')^0.5 if `touse'
 } 
if inlist("`weights'", "x2") {
 local wtitle "Weighted Type: x2 - Variable: (`wvar')^2"
 qui replace `Wi' = (`wvar')^2 if `touse'
 } 
if inlist("`weights'", "xi2") {
 local wtitle "Weighted Type: xi2 - Variable: (1/`wvar')^2"
 qui replace `Wi' = 1/(`wvar')^2 if `touse'
 }
 qui replace `weit' =`Wi'^2 if `touse'
 }
mkmat `Wi' if `touse' , matrix(`Wi')
matrix `Wi'=diag(`Wi')
matrix `WY'=`Wi'*`Y'
matrix `M1'=I(`N')
matrix `M2'=I(`N')
 if kexog > 1 {
matrix `M1'=I(`N')-`Wi'*`Xg'*inv(`Xg''*`Wi''*`Wi'*`Xg')*`Xg''*`Wi''
matrix `M2'=I(`N')-`Wi'*`X'*inv(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''
 }
matrix `W1'=`WY''*`M1'*`WY'
matrix `W2'=`WY''*`M2'*`WY'
matrix `W1W'=`W1'*inv(`W2')
matrix eigenvalues `Lambda' `Vec' = `W1W'
matrix `Lambda' =`Lambda''
svmat `Lambda' , name(`Lambdav')
rename `Lambdav'1 `Lambda'
qui summ `Lambda' if `touse'
scalar kliml=r(min)
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Minimum Expected Loss (MELO) Instrumental Variables Regression)}}"
di _dup(78) "{bf:{err:=}}"
 if "`weights'"!="" { 
di as txt _col(3) "{bf:* " "`wtitle'" " *}"
 }
scalar kyi=kendog
scalar kzi=kyi+`kx'
scalar kmelo=1-`kx'/(`N'-kzi-2)
di as txt "{bf: K - Class (MELO) Value  =} " as res %9.5f kmelo
matrix `Omega'=`Wi'*(I(`N')-kmelo*(I(`N')-`Wi'*`X' ///
*inv(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''))*`Wi'
matrix `B'=inv(`Z''*`Omega'*`Z')*`Z''*`Omega'*`Yi'

matrix `Yh'=`Z'*`B'
matrix `E'=`Yi'-`Z'*`B'
matrix `We'=(diag(`E')*diag(`E'))'
qui svmat `E' , names(`E')
qui rename `E'1 `E'
qui svmat `Yh' , names(`Yh')
qui rename `Yh'1 `Yh'
matrix `SSE'=`E''*`E'
local SSEo=`SSE'[1,1]
matrix `Ew'=`Wi'*`Yi'-`Wi'*`Z'*`B'
matrix `Sig2n'=(`Ew''*`Ew')/`N'
local Sig2n=`Sig2n'[1,1]
matrix `Sig2'=(`Ew''*`Ew')/`DF'
local Sig=sqrt(`Sig2'[1,1])
matrix `Cov'=`Sig2'*inv(`Z''*`Omega'*`Z')
qui summ `yvar' if `touse' 
local Yb=r(mean)
qui gen `YYm'=(`yvar'-`Yb')^2 if `touse' 
qui summ `YYm' if `touse' 
qui scalar SSTm = r(sum)
qui gen `YYv'=(`yvar')^2 if `touse' 
qui summ `YYv' if `touse' 
local SSTv = r(sum)
qui summ `weit' if `touse' 
qui local Wib = r(mean)
qui gen `Wi1'=sqrt(`weit'/`Wib') if `touse' 
mkmat `Wi1' if `touse' , matrix(`Wi1')
qui gen `Wio'=(`Wi1')^2 if `touse' 
mkmat `Wio' if `touse' , matrix(`Wio')
matrix `P'  =diag(`Wi1')
matrix `Pm' =diag(`Wio')
matrix `IPhi'=`P''*`P'
matrix `Phi'=inv(`P''*`P')
matrix `J'= J(`N',1,1)
matrix `D'=(`J'*`J''*`IPhi')/`N'
matrix `SSE'=`E''*`IPhi'*`E'
matrix `SST'=(`Yi'-`D'*`Yi')'*`IPhi'*(`Yi'-`D'*`Yi')
local r2c=1-`SSE'[1,1]/`SST'[1,1]
matrix `SST'=(`Yi''*`Yi')
local r2u=1-`SSE'[1,1]/`SST'[1,1]
local llf=-(`N'/2)*log(2*_pi*`SSE'[1,1]/`N')-(`N'/2)
matrix `Beta'= `B''
local N = `N'
local DOF =`DF'
matrix `B' = `B''
 if "`noconstant'"!="" {
 matrix colnames `Cov' = `endog' `exog'
 matrix rownames `Cov' = `endog' `exog'
 matrix colnames `B'   = `endog' `exog'
 }
else if "`noconexog'"!="" {
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
di as txt _col(3) "Number of Obs"  _col(19) " = " %10.0f as res `N'
if `r2c'>0 {
ereturn post `B' `Cov' , dep(`yvar') obs(`N') dof(`DOF')
qui test `xvar'
local f=r(F)
local fp=r(p)
local r2u_a=1-((1-`r2u')*(`N'-1)/(`DF'))
local r2c_a=1-((1-`r2c')*(`N'-1)/(`DF'))
local fp= fprob(`kx', `DF', `f')
matrix `Wald'=`f'*`kx'
local wald=`Wald'[1,1]
local waldp=chiprob(`kx', abs(`wald'))
di as txt _col(3) "Wald Test" _col(19) " = " %10.4f as res `wald' _col(41) as txt "P-Value > Chi2(" as res `kx' ")" _col(65) " = " %10.4f as res `waldp'
di as txt _col(3) "F Test" _col(19) " = " %10.4f as res `f' _col(41) as txt "P-Value > F(" as res `kx' " , " `DF' ")" _col(65) " = " %10.4f as res `fp'
di as txt _col(3) "R-squared" _col(19) " = " %10.4f as res `r2c' as txt _col(41) "Raw R2" _col(65) " = " %10.4f as res `r2u'
ereturn scalar r2c =`r2c'
ereturn scalar r2c_a=`r2c_a'
ereturn scalar f =`f'
ereturn scalar fp=`fp'
ereturn scalar wald =`f'
ereturn scalar waldp=`waldp'
di as txt _col(3) "R-squared Adj" _col(19) " = " %10.4f as res `r2c_a' as txt _col(41) "Raw R2 Adj" _col(65) " = " %10.4f as res `r2u_a'
di as txt _col(3) "Root MSE (Sigma)" _col(19) " = " %10.4f as res `Sig' as txt _col(41) "Log Likelihood Function" _col(65) " = " %10.4f as res `llf'
ereturn scalar r2u =`r2u'
ereturn scalar r2u_a=`r2u_a'
scalar r2ols =`r2u'
 }
if `r2c' < 0 {
 qui foreach var of local endog {
 qui regress `var' `inst' if `touse' , `noconstant'
 qui predict `Yhat1'`var' if `touse' 
 }
 qui regress `yvar' `Yhat1'* `exog'  if `touse' , `noconstant'
 local ssr=e(mss)
local r2cc =(`ssr'/`SSE'[1,1]*`DF')/(`ssr'/`SSE'[1,1]*`DF'+`DF')
local r2cc_a=1-((1-`r2cc')*(`N'-1)/(`DF'))
local fc=`r2cc'/(1-`r2cc')*(`DF')/(`kx')
local r2c_a=1-((1-`r2c')*(`N'-1)/(`DF'))
local r2u_a=1-((1-`r2u')*(`N'-1)/(`DF'))
local fpc= fprob(`kx', `DF', `fc')
scalar r2ols =`r2cc'
di as txt _col(3) "F Test" _col(19) " = " %10.4f as res `fc' _col(41) as txt "P-Value > F(" as res `kx' " , " `DF' ")" _col(65) " = " %10.4f as res `fpc'
di as txt _col(3) "R2 (-)" _col(19) " = " %10.4f as res `r2c' as txt _col(41) "Adj R2 (-)" _col(65) " = " %10.4f as res `r2c_a'
di as txt _col(3) "Corrected R2" _col(19) " = " %10.4f as res `r2cc' as txt _col(41) "Raw R2" _col(65) " = " %10.4f as res `r2u'
ereturn post `B' `Cov' , dep(`yvar') obs(`N') dof(`DOF')
ereturn scalar r2c =`r2c'
ereturn scalar r2c_a=`r2c_a'
ereturn scalar f =`fc'
ereturn scalar fp=`fpc'
ereturn scalar r2cc=`r2cc'
ereturn scalar r2cc_a =`r2cc_a'
di as txt _col(3) "Corrected R2 Adj" _col(19) " = " %10.4f as res `r2cc_a' as txt _col(41) "Raw R2 Adj" _col(65) " = " %10.4f as res `r2u_a'
di as txt _col(3) "Root MSE (Sigma)" _col(19) " = " %10.4f as res `Sig' as txt _col(41) "Log Likelihood Function" _col(65) " = " %10.4f as res `llf'
ereturn scalar r2u =`r2u'
ereturn scalar r2u_a=`r2u_a'
ereturn scalar sig=`Sig'
 }
ereturn display
if "`predict'"!= "" {
cap drop `predict'
qui gen `predict'=`Yh' if `touse' 
label variable `predict' `"Yh_`model' - Prediction"'
 }
if "`resid'"!= "" {
qui cap drop `resid'
qui gen `resid'=`yvar' - `Yh' if `touse'
label variable `resid' `"Ue_`model' - Residual"'
 }
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

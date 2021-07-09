*! alsmle V1.0 14feb2012
*! Emad Abd Elmessih Shehata
*! Assistant Professor
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email:   emadstat@hotmail.com
*! WebPage:                http://emadstat.110mb.com/stata.htm
*! WebPage at IDEAS:       http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers:  http://econpapers.repec.org/RAS/psh494.htm

program define alsmle , eclass byable(onecall)
version 10.1
syntax varlist [if] [in] [aw iw pw] , [vce(passthru) MFX(str) ///
ITER(int 50) TOLOG DN level(passthru) PREDict(str) RESid(str) ///
NOCONStant RHO TOLerance(real 0.00001) diag LOG TWOstep]
tempvar E Ev Ue Time YY Yb YYv Hat ALSxvar cons Evs
tempvar wald SSE EE Ea LEo Eo X X0 EE1 E2 Sig2 Xo D P Xb Q XB Z Ew
tempvar Yh2 E3 E4 LE ht X Y Z Sig2 E B Wald B X0 X SSEo
tempvar E2 U U2 X0 Yh Yhb Ev Ue Time YYm wald SSE SST
tempname Beta LE1 LE2 LE3 LE4 Eo E1 EE1 BRho J Wald A Yh X0 XB
tempname X Y Z Sig2 E Cov Ew Wald B mfxe mfxlin mfxlog
tempname Beta P Pm IPhi J D SSE SST Sig2 VQ VP VM XMB YMB XYMB Bx YYm YYv
tempvar `varlist'
marksample touse
gettoken yvar xvar : varlist
markout `touse' `varlist'
_rmdcoll `varlist' if `touse' , `noconstant'
tsunab xvar : `xvar'
tokenize `xvar'
local xvar `*'
qui cap count if `touse'
qui gen `X0'=1 if `touse'
local N = r(N)
qui gen `Time'=_n 
qui tsset `Time' 
qui drop if `Time' == .
 if "`weight'" != "" {
 local wgt "[`weight'`exp']"
 if "`weight'" == "pweight" {
 local awgt "[aw`exp']"
 }
 else local awgt "`wgt'"
 }
 local both : list yvar & xvar
 if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both LHS & RHS Variables}"
di as res " LHS: `yvar'"
di as res " RHS:`xvar'"
 exit
 } 
 if "`mfx'"!="" {
if !inlist("`mfx'", "lin", "log") {
di 
di as err " {bf:mfx( )} {cmd:must be} {bf:mfx({it:lin})} {cmd:for Linear Model, or} {bf:mfx({it:log})} {cmd:for Log-Log Model}"
exit
 }
 }
 if inlist("`mfx'", "log") {
 if "`tolog'"=="" {
di 
di as err " {bf:tolog} {cmd:must be combined with} {bf:mfx(log)}"
 exit
 }
 }
 if "`tolog'"!="" {
di _dup(45) "-"
di as err " {cmd:** Data Have been Transformed to Log Form **}"
di as txt " {cmd:** `varlist'} "
di _dup(45) "-"
qui foreach var of local varlist {
tempvar xyind`var'
qui gen `xyind`var''=`var' if `touse'
qui replace `var'=ln(`var') if `touse'
qui replace `var'=1 if `var'==0
qui replace `var'=0 if `var'==.
 }
 }
mkmat `yvar' if `touse' , matrix(`Y')
qui mkmat `X0' if `touse' , matrix(`X0')
local kx : word count `xvar'
scalar kx=`kx'
if "`noconstant'"!="" {
qui mkmat `xvar' if `touse' , matrix(`X')
scalar kb=`kx'
local DF=`N'-kb
qui mean `xvar' if `touse'
 }
 else { 
qui mkmat `xvar' `X0' if `touse' , matrix(`X')
scalar kb=`kx'+1
local DF=`N'-kb
qui mean `xvar' `X0' if `touse'
 }
matrix `Xb'=e(b)
qui mean `yvar' if `touse'
matrix `Yb'=e(b)'
 if "`dn'"!="" {
 local DF=`N'
 }
 scalar df1=`kx'
 scalar df2=`N'-kb
qui cap drop `E'
scalar R1=0
 if "`log'" != "" {
 qui regress `yvar' `xvar' if `touse' `wgt' , `noconstant' `vce' `level'
scalar rss = e(rss)
local llf=e(ll)
 }
local iter=`iter'+1

preserve
qui keep if `touse'

if "`twostep'"!="" {
local iter=2
 }
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Beach-Mackinnon AR(1) Autoregressive Maximum Likelihood Estimation}}"
di _dup(78) "{bf:{err:=}}"
 if "`log'" != "" {
noi di as txt _col(5) "Iteration" _col(21) "Rho" _col(37) "LLF" _col(51) "SSE"
 }
scalar Ro1 = 2
qui gen `cons'=.
qui forval i = 1/`iter' {
scalar Ro1=R1
scalar it=`i'-1
tempvar ALSxvar
qui foreach i of local varlist {
qui gen `ALSxvar'`i' = `i'-Ro1*`i'[_n-1] if `touse'
qui replace `ALSxvar'`i' = `i'*sqrt(1-Ro1^2) in 1/1 
 }
qui replace `cons' = 1-Ro1 if `touse'
qui replace `cons' = sqrt(1-Ro1^2) in 1/1
if "`noconstant'"!="" {
qui regress `ALSxvar'* if `touse' `wgt' , noconstant `vce' `level'
 }
else {
qui regress `ALSxvar'* `cons' if `touse' `wgt' , noconstant `vce' `level'
 }
scalar rss=e(rss)
 if "`log'" != "" {
noi di as res _col(5) it _col(20) as res %10.6f R1 _col(35) as res %10.4f `llf' _col(50) as res %10.4f rss
 }
scalar sig2a=e(rss)/(`N'-kb)
matrix `Cov'=e(V)/sig2a
qui cap drop `Evs'
qui predict `Evs' if `touse' , res
matrix `B'=e(b)'
matrix `E'=(`Y'-`X'*`B')
qui cap drop `E'
qui cap drop `LE1'
svmat `E' , name(`E')
qui replace  `E'= `E'1 if `touse'
qui gen `LE1' =L1.`E' if `touse'
qui replace `LE1'=0 in 1/1
qui regress `E' `LE1' if `touse' `wgt' , noconstant
tempvar E1 E2 E12 EE1
scalar E11=`E'^2
 gen  `E2'=`E'^2 if `touse'
 qui replace  `E2'= 0 in 1/1
 gen  `E1'=L1.`E' if `touse'
 gen `E12'=L1.`E'^2 if `touse'
 gen `EE1'=L1.`E'*`E' if `touse'
 qui summ `E2' if `touse'
 scalar SE2=r(sum)
 qui summ `E1' if `touse'
 scalar SE1=r(sum)
 qui summ `E12' if `touse'
 scalar SE12=r(sum)
 qui summ `EE1' if `touse'
 scalar SEE1=r(sum)
 scalar A=-(`N'-2)*SEE1/((`N'-1)*(SE12-E11))
 scalar B=((`N'-1)*E11-`N'*SE12-SE2)/((`N'-1)*(SE12-E11))
 scalar C=`N'*SEE1/((`N'-1)*(SE12-E11))
 scalar S=B-(A^2/3)
 scalar Q=C-(A*B/3)+(2*A^3/27)
 scalar Phi=acos((Q*27^0.5)/(2*S*(-S)^0.5))
 scalar R1=-(A/3)-2*(-S/3)^0.5*cos((Phi/3)+(_pi/3))
scalar Roi=abs(R1-Ro1)
local llf=0.5*ln(1-R1^2)-(`N'/2)*ln(2*_pi*rss/`N')-(`N'/2)
 if (Roi <= `tolerance') {
 continue, break
 }
 }
 if "`log'" != "" {
di as txt "{hline 78}"
 }
qui cap drop `E'
matrix `Beta'=`B'
matrix `B'=`Beta''
matrix `E'=(`Y'-`X'*`Beta')
matrix `Sig2'=rss/`N'
matrix `Cov'=`Sig2'*`Cov'
tempvar  Ue Ue2 Ue2S Yh Ue_1 Ue_
tempname Ue Ue2 Ue2S Yh Ue_Diag Yh_Diag Ue_ Ue_1
qui svmat `E' , names(`E')
qui rename `E'1 `E'
matrix `Yh'=`Y'-`E'
 svmat `E' , name(`Ue_')
 svmat `E' , name(`Ue')
 rename `Ue'1 `Ue'
 rename `Ue_'1 `Ue_'
 matrix `Ue'=`E'
 matrix `Ue_Diag'=`E'
 matrix `Yh_Diag'=`Yh'
qui svmat `Yh' , names(`Yh')
qui rename `Yh'1 `Yh'
mkmat `Evs' if `touse' , matrix(`Evs')
matrix `SSE'=`Evs''*`Evs'
matrix `SSEo'=`E''*`E'
scalar SSEo=`SSEo'[1,1]
matrix `Sig2'=`SSE'/`DF'
local Sig=sqrt(`Sig2'[1,1])
local Sig2n= SSEo/`N'
qui summ `yvar' if `touse' 
local Yb=r(mean)
qui gen `YYm'=(`yvar'-`Yb')^2 if `touse' 
qui summ `YYm' if `touse' 
qui scalar SSTm = r(sum)
qui gen `YYv'=(`yvar')^2 if `touse' 
qui summ `YYv' if `touse' 
local SSTv = r(sum)
matrix `P'  =diag(`X0')
matrix `IPhi'=`P''*`P'
matrix `J'= J(`N',1,1)
matrix `D'=(`J'*`J''*`IPhi')/`N'
matrix `SST'=(`Y'-`D'*`Y')'*`IPhi'*(`Y'-`D'*`Y')
local r2c=1-`SSE'[1,1]/`SST'[1,1]
matrix `SST'=(`Y''*`Y')
local r2u=1-`SSE'[1,1]/`SST'[1,1]
scalar R20_=`r2u'
local llf=0.5*ln(1-R1^2)-(`N'/2)*ln(2*_pi*`SSE'[1,1]/`N')-(`N'/2)
local N = `N'
local DOF =`DF'
matrix `B' = `Beta''
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
if "`predict'"!= "" {
cap drop `predict'
qui gen `predict'=`Yh' if `touse' 
label variable `predict' `"Yh - Prediction"'
 }
if "`resid'"!= "" {
qui cap drop `resid'
qui gen `resid'=`yvar' - `Yh' if `touse'
label variable `resid' `"Ue - Residual"'
 }
di as txt _col(3) "Number of Obs"  _col(19) " = " %10.0f as res `N'
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
di as txt _col(3) "R-squared" _col(19) " = " %10.4f as res `r2c' as txt _col(41) "Raw Moments R2" _col(65) " = " %10.4f as res `r2u'
ereturn scalar r2c =`r2c'
ereturn scalar r2c_a=`r2c_a'
ereturn scalar f =`f'
ereturn scalar fp=`fp'
ereturn scalar wald =`f'
ereturn scalar waldp=`waldp'
di as txt _col(3) "R-squared Adj" _col(19) " = " %10.4f as res `r2c_a' as txt _col(41) "Raw Moments R2 Adj" _col(65) " = " %10.4f as res `r2u_a'
ereturn scalar r2u =`r2u'
ereturn scalar r2u_a=`r2u_a'
di as txt _col(3) "Root MSE (Sigma)" _col(19) " = " %10.4f as res `Sig' as txt _col(41) "Log Likelihood Function" _col(65) " = " %10.4f as res `llf'
di as txt _col(3) "Autoregressive Coefficient (Rho) Value = " %9.7f as res R1
ereturn display
if "`diag'" != "" {
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Model Selection Diagnostic Criteria}}"
di _dup(78) "{bf:{err:=}}"
scalar SSE=`SSEo'[1,1]
scalar SSEr=`SSE'[1,1]
local llf=0.5*ln(1-R1^2)-(`N'/2)*ln(2*_pi*`SSE'[1,1]/`N')-(`N'/2)
local AIC=SSE/`N'*exp(2*`kx'/`N')
local LAIC=ln(SSE/`N')+2*`kx'/`N'
local FPE=(SSE/`DF')*(1+`kx'/`N')
local SC=SSE/`N'*`N'^(`kx'/`N')
local LSC=ln(SSE/`N')+`kx'*ln(`N')/`N'
local HQ=SSE/`N'*ln(`N')^(2*`kx'/`N')
local Rice=SSE/`N'/(1-2*`kx'/`N')
local Shibata=SSE/`N'*(`N'+2*`kx')/`N'
local GCV=SSE/`N'*(1-`kx'/`N')^(-2)
di as txt "  Log Likelihood Function       LLF" _col(49) as res "=" as res %12.4f `llf'
di as txt "  Akaike Final Prediction Error AIC" _col(49) as res "=" as res %12.4f `AIC'
di as txt "  Schwartz Criterion            SC" _col(49) as res "=" as res %12.4f `SC'
di as txt "  Akaike Information Criterion  ln AIC" _col(49) as res "=" as res %12.4f `LAIC'
di as txt "  Schwarz Criterion             ln SC" _col(49) as res "=" as res %12.4f `LSC'
di as txt "  Amemiya Prediction Criterion  FPE" _col(49) as res "=" as res %12.4f `FPE'
di as txt "  Hannan-Quinn Criterion        HQ" _col(49) as res "=" as res %12.4f `HQ'
di as txt "  Rice Criterion                Rice" _col(49) as res "=" as res %12.4f `Rice'
di as txt "  Shibata Criterion             Shibata" _col(49) as res "=" as res %12.4f `Shibata'
di as txt "  Craven-Wahba Generalized Cross Validation GCV" _col(49) as res "=" as res %12.4f `GCV'
di _dup(63) "-"
ereturn scalar aic = `AIC'
ereturn scalar laic = `LAIC'
ereturn scalar fpe = `FPE'
ereturn scalar sc = `SC'
ereturn scalar lsc = `LSC'
ereturn scalar hq = `HQ'
ereturn scalar rice = `Rice'
ereturn scalar shibata = `Shibata'
ereturn scalar gcv = `GCV'
ereturn scalar llf = `llf'
 }
if "`tolog'"!="" {
qui foreach var of local varlist {
qui replace `var'= `xyind`var'' if `touse'
 }
 }
 if inlist("`mfx'", "lin", "log") {
tempname XMB YMB XYMB B Bx
matrix `B'=`Beta''
matrix `Bx'=`B'[1, 1..`kx']'
qui mean `xvar' if `touse'
matrix `XMB'=e(b)'
qui summ `yvar' if `touse' 
scalar YMB1=r(mean)
local YmeanB=r(mean)
matrix `YMB'=J(rowsof(`XMB'),1,YMB1)
mata: X = st_matrix("`XMB'")
mata: Y = st_matrix("`YMB'")
if inlist("`mfx'", "lin") {
mata: `XYMB'=divide(X, Y)
mata: `XYMB'=st_matrix("`XYMB'",`XYMB')
matrix mfx =`Bx'
matrix mfxe=vecdiag(`Bx'*`XYMB'')'
matrix mfxlin =mfx,mfxe,`XMB'
matrix rownames mfxlin = `xvar'
matrix colnames mfxlin = Marginal_Effect(B) Elasticity(Es) Mean
matlist mfxlin , title({bf:* {bf:{err:Linear:}} Marginal Effect - Elasticity}) twidth(12) border(all) lines(columns) rowtitle(Variable) format(%18.4f)
ereturn matrix mfx=mfxlin
 }
if inlist("`mfx'", "log") {
mata: `XYMB'=divide(Y, X)
mata: `XYMB'=st_matrix("`XYMB'",`XYMB')
mat mfxe=`Bx'
matrix mfx=vecdiag(`Bx'*`XYMB'')'
matrix mfxlog =mfxe,mfx,`XMB'
matrix rownames mfxlog = `xvar'
matrix colnames mfxlog = Elasticity(Es) Marginal_Effect(B) Mean
matlist mfxlog , title({bf:* {bf:{err:Log-Log:}} Elasticity - Marginal Effect}) twidth(12) border(all) lines(columns) rowtitle(Variable) format(%18.4f)
ereturn matrix mfx=mfxlog
 }
di as txt " Mean of Dependent Variable = " as res _col(33) %7.4f `YmeanB' 
 }
end


 program define spregcs02 , eclass byable(onecall)
 version 11.2
 syntax [anything] , RUN(string) [NOCONStant NOCONEXOG KC(real 0) KF(real 0) ///
 KR(real 0) HETCov(str) rest(str) RIDge(str) DN]

 qui {
 tempvar E E2 U X0 Yh Lambda YY EE Eo LE XQ ht
 tempname X Y Z M2 Xg M1 W1 W2 W1W Lambda Yy E Cov b h SSE ky Sig2n Sigo Wi OM
 tempname hjm We v lamp M W b1 v1 q vh Z0 xq Eo E1 EE1 Sw Sn nw S11 S12
 tempname WY Eg Sig2 Sig2o X X0 J S DF N kx kb F K B Omega Rso Rs
 tempname V E Kr kfc Vec kliml kmelo kinst kw i L Li in Zz SSEo ZwZ Yws Zws
 _iv_parse `0'
 local yvar `s(lhs)'
 local endog `s(endog)'
 local exog `s(exog)'
 local inst `s(inst)'
 
 if "`noconstant'"!="" | "`noconexog'"!="" {
 local nocons "noconstant"
 }
 _rmcoll `endog' , `nocons' forcedrop
 local endog "`r(varlist)'"
 _rmcoll `exog' , `nocons' forcedrop
 local exog "`r(varlist)'"
 _rmcoll `inst' , `nocons' forcedrop
 local inst "`r(varlist)'"
 local _Zo "`endog' `exog'"
 unab xvar : `endog' `exog'
 unab instx : `exog' `inst'
 local kendog : word count `endog'
 local kexog : word count `exog'
 local kinst : word count `inst'
 local kinstx: word count `instx'
 local kx =`kendog'+`kexog'
 local ky =1

 if `kinstx' < `kx' {
noi di _dup(70) "-" 
noi di as err " " "`run'" "{bf: cannot be Estimated} {cmd: - Equation }" "`yvar'" "{cmd: is Underidentified}" 
noi di _dup(70) "-" 
noi di as txt "{bf:** Y  = LHS Dependent Variable}
noi di as txt "   " `ky' " : " "`yvar'"
noi di as txt "{bf:** Yi = RHS Endogenous Variables}
noi di as txt "   " `kendog' " : " "`endog'"
noi di as txt "{bf:** Xi = RHS Included Exogenous Variables}"
noi di as txt "   " `kexog' " : " "`exog'"
noi di as txt "{bf:** Xj = RHS Excluded Exogenous Variables (Additional Instrumental Variables)}"
noi di as txt "   " `kinst' " : " "`inst'"
noi di as txt "{bf:** Z  = Overall Instrumental Variables}"
noi di as txt "   " `kinstx' " : "  "`instx'"
noi di as txt "{bf: Model is Under Identification:}"
noi di as txt _col(7) "Xj(" `kinstx' ")" " < Yi + Xi (" `kx' ")
noi di as txt "* since: Xj < Yi + Xi : it is recommended to use (OLS)"
noi di as err "  {bf:or let Instrumental Variables > Endogenous Variables}"
noi di _dup(70) "-"
 exit 
 }
 
 cap count 
 local N = r(N)
 gen `X0'=1 
 matrix `X0'= J(`N',1,1)
 local yvar `yvar'
 mkmat `yvar' , matrix(`Y')
 mkmat `yvar' `endog' , matrix(`Yy')
 if "`noconstant'"!="" | "`noconexog'"!="" {
 if "`noconstant'"!="" {
 mkmat `exog' , matrix(`Xg')
 mkmat `exog' `inst' `X0' , matrix(`X')
 mkmat `endog' `exog' , matrix(`Z')
 }
 if "`noconexog'"!="" {
 mkmat `exog' , matrix(`Xg')
 mkmat `exog' `inst' , matrix(`X')
 mkmat `endog' `exog' , matrix(`Z')
 }
 }
 else { 
 if "`noconstant'"=="" | "`noconexog'"=="" {
 mkmat `exog' `X0' , matrix(`Xg')
 mkmat `exog' `inst' `X0' , matrix(`X')
 mkmat `endog' `exog'  `X0' , matrix(`Z')
 }
 }
 local Kr =e(Kr)
 local k =e(k)
 local k0 =e(k0)
 local kx=`kx'
 local kb=`kx'+`k0'
 local Jkx=`kx'-`k'
 local Jkb=`kb'-`k'
 local DF=`N'-`Jkb'
 local in=`N'/`DF'
 if "`dn'"!="" {
 local DF=`N'
 local in=1
 }
 local JDF=`DF'
 if "`rest'"!="" {
 matrix `Rs'=e(Rs)
 matrix `Rso'=e(Rso)
 }
 matrix `Zz'=e(Zz)
 matrix `Wi'=e(Wi)
 matrix `Omega'=`Wi''*`Wi'
 matrix `WY'=`Wi'*`Yy'
 matrix `M1'=I(`N')
 matrix `M2'=I(`N')
 if `kexog' >= 1 {
 matrix `M1'=I(`N')-`Wi'*`Xg'*invsym(`Xg''*`Wi''*`Wi'*`Xg')*`Xg''*`Wi''
 }
 if `kinst' >= 1 {
 matrix `M2'=I(`N')-`Wi'*`X'*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''
 }
 matrix `W1'=`WY''*`M1'*`WY'
 matrix `W2'=`WY''*`M2'*`WY'
 cap matrix `W1W'=`W1'*invsym(`W2')
 matrix eigenvalues `Lambda' `Vec' = `W1W'
 matrix `Lambda' =`Lambda''
 mata: `Lambda' = st_matrix("`Lambda'")
 getmata `Lambda' , force replace
 summ `Lambda' 
 scalar `kliml'=r(min)
 matrix `ZwZ'=`Z''*`Omega'*`Z'
 matrix `Yws'=`Wi'*`Y'
 matrix `Zws'=`Wi'*`Z'
 if inlist("`run'", "2sls") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Two Stage Least Squares (2SLS)}}"
noi di _dup(78) "{bf:{err:=}}"
 matrix `Omega'=`Wi'*`X'*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''
 matrix `B'=invsym(`Zws''*`Omega'*`Zws'+`Zz')*`Zws''*`Omega'*`Yws'
 }
 if inlist("`run'", "liml") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Limited-Information Maximum Likelihood (LIML)}}"
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf: K - Class (LIML) Value =} " as res %9.5f `kliml'
 matrix `Omega'=`Wi'*`X'*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''
 matrix `Omega'=(I(`N')-`kliml'*(I(`N')-`Omega'))
 matrix `B'=invsym(`Zws''*`Omega'*`Zws'+`Zz')*`Zws''*`Omega'*`Yws'
 }
 if inlist("`run'", "kclass") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Theil k-Class (LIML)}}"
noi di _dup(78) "{bf:{err:=}}"
 local kc =`kc'
noi di as txt "{bf: K - Class Value =} " as res %9.5f `kc'
 matrix `Omega'=(I(`N')-`kc'*(I(`N')-`Wi'*`X'*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''))
 matrix `B'=invsym(`Zws''*`Omega'*`Zws'+`Zz')*`Zws''*`Omega'*`Yws'
 }
 if inlist("`run'", "fuller") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Fuller k-Class (LIML)}}"
noi di _dup(78) "{bf:{err:=}}"
 local kfc =`kliml'-(`kf'/(`N'-`kinstx'))
noi di as txt "{bf:  LIML-Class Value}" _col(27) " = " as res %9.5f `kliml'
noi di as txt "{bf: Alpha-Class Value}" _col(27) " = " as res %9.5f `kf'
noi di as txt "{bf:     K-Class Fuller Value}" _col(27) " = " as res %9.5f `kfc'
 matrix `Omega'=(I(`N')-`kfc'*(I(`N')-`Wi'*`X'*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''))
 matrix `B'=invsym(`Zws''*`Omega'*`Zws'+`Zz')*`Zws''*`Omega'*`Yws'
 }
 if inlist("`run'", "melo") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Minimum Expected Loss (MELO)}}"
noi di _dup(78) "{bf:{err:=}}"
 local kmelo =1-`kx'/(`N'-`kx'-2)
noi di as txt "{bf: K - Class (MELO) Value  =} " as res %9.5f `kmelo'
 matrix `Omega'=(I(`N')-`kmelo'*(I(`N')-`Wi'*`X'*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''))
 matrix `B'=invsym(`Zws''*`Omega'*`Zws'+`Zz')*`Zws''*`Omega'*`Yws'
 }
 if inlist("`run'", "gmm") {
 if "`hetcov'"=="" {
 local hetcov "white"
 }
 if inlist("`hetcov'", "white") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (White Method)}}"
noi di _dup(78) "{bf:{err:=}}"
 matrix `Omega'=`Wi'*`X'*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''
 matrix `B'=invsym(`Zws''*`Omega'*`Zws'+`Zz')*`Zws''*`Omega'*`Yws'
 matrix `E'=(`Y'-`Z'*`B')
 matrix `OM'=diag(`E')
 matrix `We'=`OM'*`OM'
 matrix `Omega'=`X'*invsym(`X''*`We'*`X')*`X''
 matrix `B'=invsym(`Zws''*`Omega'*`Zws'+`Zz')*`Zws''*`Omega'*`Yws'
 }
 if inlist("`run'", "gmm") & !inlist("`hetcov'", "white") {
 if inlist("`hetcov'", "bart") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Bartlett Method)}}"
noi di _dup(78) "{bf:{err:=}}"
 local i=1
 local L=4*(`N'/100)^(2/9)
 local Li=`i'/(1+`L')
 local kw=1-`Li'
 }
 if inlist("`hetcov'", "dan") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Daniell Method)}}"
noi di _dup(78) "{bf:{err:=}}"
 local i=1
 local L=4*(`N'/100)^(2/9)
 local Li=`i'/(1+`L')
 local kw=sin(_pi*`Li')/(_pi*`Li')
 }
 if inlist("`hetcov'", "nwest") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Newey-West Method)}}"
noi di _dup(78) "{bf:{err:=}}"
 local i=1
 local L=1
 local Li=`i'/(1+`L')
 local kw=1-`Li'
 }
 if inlist("`hetcov'", "parzen") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Parzen Method)}}"
noi di _dup(78) "{bf:{err:=}}"
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
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Quadratic Spectral Method)}}"
noi di _dup(78) "{bf:{err:=}}"
 local i=1
 local L=4*(`N'/100)^(2/25)
 local Li=`i'/(1+`L')
 local kw=(25/(12*_pi^2*`Li'^2))*(sin(6*_pi*`Li'/5)/(6*_pi*`Li'/5)-sin(6*_pi*`Li'/5+_pi/2))
 }
 if inlist("`hetcov'", "tent") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Tent Method)}}"
noi di _dup(78) "{bf:{err:=}}"
 local i=1
 local L=4*(`N'/100)^(2/9)
 local Li=`i'/(1+`L')
 local kw=2*(1-cos(`Li'*`Li'))/(`Li'^2)
 }
 if inlist("`hetcov'", "trunc") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Truncated Method)}}"
noi di _dup(78) "{bf:{err:=}}"
 local i=1
 local L=4*(`N'/100)^(1/4)
 local Li=`i'/(1+`L')
 local kw=1-`Li'
 }
 if inlist("`hetcov'", "tukeym") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Tukey-Hamming Method)}}"
noi di _dup(78) "{bf:{err:=}}"
 local i=1
 local L=4*(`N'/100)^(1/4)
 local Li=`i'/(1+`L')
 local kw=0.54+0.46*cos(_pi*`Li')
 }
 if inlist("`hetcov'", "tukeyn") {
noi di _dup(78) "{bf:{err:=}}"
noi di as txt "{bf:{err:* Generalized Method of Moments (GMM) - (Tukey-Hanning Method)}}"
noi di _dup(78) "{bf:{err:=}}"
 local i=1
 local L=4*(`N'/100)^(1/4)
 local Li=`i'/(1+`L')
 local kw=(1+sin((_pi*`Li')+_pi/2))/2
 }
 gen `Z0' = 1 
 replace `Z0' = 0 in 1
 foreach var of local _Zo {
 gen double `xq'`var' = `var'[_n-1] 
 replace `xq'`var' = 0 in 1
 }
 if ("`noconstant'"!="" | "`noconexog'"!="") {
 mkmat `xq'* , matrix(`M')
 }
 else {
 mkmat `xq'* `Z0' , matrix(`M')
 }
 matrix `M'=`Wi'*`M'
 matrix `Omega'=`Wi'*`X'*invsym(`X''*`Wi''*`Wi'*`X')*`X''*`Wi''
 matrix `B'=invsym(`Zws''*`Omega'*`Zws'+`Zz')*`Zws''*`Omega'*`Yws'
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 mata: `Eg' = st_matrix("`E'")
 getmata `Eg' , force replace
 gen double `E1'=`Eg'[_n-1] 
 gen double `EE1'=`E1'*`Eg' 
 replace `EE1' = 0 if `EE1'==.
 mkmat `EE1' , matrix(`EE1')
 matrix `OM'=diag(`E')
 matrix `We'=`OM'*`OM'
 matrix `Sw'=`Zws''*`We'*`Zws'
 matrix `We'=diag(`EE1')
 matrix `S11'=`Zws''*`We'*`M'
 matrix `S12'=`M''*`We'*`Zws'
 matrix `Sn'=(`S11'+`S12')*`kw'
 matrix `nw'=(`Sw'+`Sn')*`in'
 matrix `nw'=`nw'*`in'
 }
 }
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 matrix `E'=`Y'-`Z'*`B'
 matrix `SSE'=`E''*`E'
 scalar `SSEo'=`SSE'[1,1]
 scalar `Sig2o'=`SSEo'/`DF'
 scalar `Sig2n'=`SSEo'/`N'
 scalar `Sigo'=sqrt(`Sig2o')
 matrix `OM'=diag(`E')
 matrix `We'=`OM'*`OM'
 matrix `hjm'=(`E''*(`X'*invsym(`X''*`We'*`X')*`X'')*`E')
 local lmihj=`hjm'[1,1]
 local dfgmm=`kinstx'-`kx'
 local lmihjp= chi2tail(`dfgmm', abs(`lmihj'))
 matrix `ZwZ'=`Z''*`Omega'*`Z'
 if "`rest'"!="" {
 matrix `B'=`B'+(invsym(`ZwZ'+`Zz')*`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*(`Rso'-`Rs'*`B'))
 matrix `E'=`Wi'*(`Y'-`Z'*`B')
 matrix `Sig2'=`E''*`E'/`DF'
 if "`ridge'"!="" & `Kr' > 0 {
 if inlist("`run'", "ols", "2sls", "liml", "melo", "fuller", "kclass") {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')-`Sig2'*invsym(`ZwZ'+`Zz') ///
 *`Rs''*invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 if inlist("`run'", "gmm") & inlist("`hetcov'", "white") {
 matrix `Cov'=invsym(`ZwZ'+`Zz')-invsym(`ZwZ'+`Zz')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 if inlist("`run'", "gmm") & !inlist("`hetcov'", "white") {
 matrix `Cov'=invsym(`ZwZ'+`Zz')-invsym(`ZwZ'+`Zz')*`Rs'' ///
 *invsym(`Rs'*(`nw'+`Zz')*`Rs'')*`Rs'*invsym(`ZwZ'+`Zz')
 }
 }
 else {
 matrix `Cov'=`Sig2'*invsym(`ZwZ')-`Sig2'*invsym(`ZwZ')*`Rs'' ///
 *invsym(`Rs'*invsym(`ZwZ')*`Rs'')*`Rs'*invsym(`ZwZ')
 }
 }
 else {
 if "`ridge'"!="" & `Kr' > 0 {
 if inlist("`run'", "ols", "2sls", "liml", "melo", "fuller", "kclass") {
 matrix `Cov'=`Sig2'*invsym(`ZwZ'+`Zz')*`ZwZ'*invsym(`ZwZ'+`Zz')
 }
 if inlist("`run'", "gmm") & inlist("`hetcov'", "white") {
 matrix `Cov'=invsym(`ZwZ'+`Zz')*`ZwZ'*invsym(`ZwZ'+`Zz')
 }
 if inlist("`run'", "gmm") & !inlist("`hetcov'", "white") {
 matrix `Cov'=invsym(`ZwZ'+`Zz')*`nw'*invsym(`ZwZ'+`Zz')
 }
 }
 else {
 if inlist("`run'", "ols", "2sls", "liml", "melo", "fuller", "kclass") {
 matrix `Cov'=`Sig2o'*invsym(`ZwZ')
 }
 if inlist("`run'", "gmm") & inlist("`hetcov'", "white") {
 matrix `Cov'=invsym(`ZwZ')
 }
 if inlist("`run'", "gmm") & !inlist("`hetcov'", "white") {
 matrix `Cov'=invsym(`ZwZ')*`nw'*invsym(`ZwZ')
 }
 }
 }
 matrix `B'=`B''
 if "`noconstant'"!="" | "`noconexog'"!="" {
 matrix colnames `Cov' = `xvar'
 matrix rownames `Cov' = `xvar'
 matrix colnames `B'= `xvar'
 }
 else { 
 matrix colnames `Cov' = `xvar' _cons
 matrix rownames `Cov' = `xvar' _cons
 matrix colnames `B'= `xvar' _cons
 }
 local Nof =`N'
 local Dof =`DF'
 ereturn post `B' `Cov' , dep(`yvar') obs(`Nof') dof(`Dof')
 if "`ridge'"!="" {
 ereturn local Kr = `Kr'
 }
 if inlist("`run'", "gmm") {
 ereturn local lmihj=`lmihj'
 ereturn local dfgmm=`dfgmm'
 ereturn local lmihjp=`lmihjp'
 }
 }
 end


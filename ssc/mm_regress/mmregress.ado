program define mmregress, eclass


* MM-regression fit
* By Vincenzo Verardi FNRS-FUNDP

version 10.0

if replay()& "`e(cmd)'"=="mmregress" {
	ereturn  display
exit
}


syntax varlist [if] [in] , [dummies(varlist) outlier NOConstant eff(real 0.7) replic(numlist max=1) INITial graph label(varlist)]

tempvar rand yres touse finsamp u u0 w rho weight res stdres ru continuous tempconst tempes tempem tempu tempmad tempccx
tempname mad mad2 bestmad mrho scale eps maxit err v A B B1 B2 coefS  nvar1 ord A
local nvar: word count `varlist'
gen `ord'=_n
/* includes constant implicitly by counting depvar */

mark `touse' `if' `in'
markout `touse' `varlist' `dummies'
qui count if `touse'

local dv: word 1 of `varlist'
local expl: list varlist - dv


local N=r(N)
scalar `err'=1

if ("`initial'"!="") {
local ccx=1.5468906
}

else {
	if ("`eff'"!="") {

		if `eff'>1|`eff'<0.287 {
		display in r "Efficiency has to be set between 0.287 and 1"
		exit
		}

		else if `eff'==1{
		display in r "Run regress and not mmregress if you want a Gaussian efficiency of 1!!"
		exit
		}
		else {
		local elx=(((`eff'*100)^(-1.442303))-1)/(-1.442303)
		local cdx= ((12.75327*`elx')-8.551849)*(-3.582472)+1
		local ccx=`cdx'^(-1/3.582472)
		}

	}
}
	
	if "`replic'"!="" {
	local reps=`replic'
	}
	else {
	local reps=max(ceil((log(1-0.99))/(log(1-(1-0.2)^(`nvar')))),20)
	}
      if `reps'>500 {
      display in red "!!! The total number of p-subsets to check is " `reps' " it can take quite some time."
      }

      else {
		if "`dummies'"=="" {
      	display in white "The total number of p-subsets to check is "`reps'
		}
		else {
	      display in white "The total number of p-subsets to check for each iteration is "`reps'
   		}
      }

local ivs "`dummies'"

if "`noconstant'"!="" {
qui reg `varlist' `dummies', noc
}

else {
qui reg `varlist' `dummies'
}

local dftot=e(df_r)

local nvar: word count `varlist'
local ndum: word count `dummies'

if `ndum'==0 {

	if "`noconstant'"!="" {
	capture qui sregress `varlist' if `touse', outlier noc replic(`reps')
	label var S_stdres "Robust standardized residuals"
	}

	else {
	capture qui sregress `varlist' if `touse', outlier replic(`reps')
	label var S_stdres "Robust standardized residuals"
	}

	qui gen `u'=S_stdres

	if "`outlier'"=="" {
	qui capture drop S_outlier  S_stdres 
	}
}

else {
	if "`noconstant'"!="" {
	capture qui msregress `varlist' if `touse', dummies(`dummies') outlier noc replic(`reps')
	label var MS_stdres "Robust standardized residuals"
	global S_1=$MS_1
	}

	else {
	capture qui msregress `varlist' if `touse', dummies(`dummies') outlier replic(`reps')
	label var MS_stdres "Robust standardized residuals"
	global S_1=$MS_1
	}

	qui gen `u'=MS_stdres

	if "`outlier'"=="" {
	qui capture drop MS_outlier MS_stdres
	}
}


qui gen `tempes'=`u'*$S_1
qui gen `ru'=`u'
matrix `B1'=e(b)
scalar `eps'=1e-20
scalar `maxit'=1000
scalar `nvar1'=`nvar'-1
local mad=$S_1
capture drop `w'
qui gen `w'=1*(abs(`u')/`ccx'<=1)
capture drop `weight'
qui gen `weight'=(1-(`u'/`ccx')^2)^2*`w'

			
            local j 1

            while `j'<=`maxit'&`err'>`eps' {
		if "`noconstant'"!="" {
		capture qui reg `varlist' `dummies' [aweight=`weight'] if `touse', nocons
		}
		else {
		capture qui reg `varlist' `dummies' [aweight=`weight'] if `touse'
		}

		qui matrix `B2'=e(b)
		capture drop `u0'
            qui predict `u0',res
            capture drop `u'
            qui gen `u'=`u0'/`mad'
            capture drop `w'
            qui gen `w'=1*(abs(`u')/`ccx'<=1)
		capture drop `rho'
            qui gen `rho'=(`u'^2/(2)*(1-(`u'^2/(`ccx'^2))+(`u'^4/(3*`ccx'^4))))*`w' +(1-`w')*(`ccx'^2/6)
            capture qui replace `rho'=`rho'*6/`ccx'^2
            capture drop `weight'
            qui gen `weight'=(1-(`u'/`ccx')^2)^2*`w'
		qui matrix `A'=mreldif(`B1',`B2')
		qui scalar `err'=`A'[1,1]
            local j=`j'+1
		qui matrix `B1'=`B2'
            }

 
	if "`noconstant'"!="" {
	capture qui reg `varlist' `dummies' [aweight=`weight'] if `touse', nocons
	gen `tempconst'=.
	}

	else {
	capture qui reg `varlist' `dummies' [aweight=`weight'] if `touse'
	gen `tempconst'=1
	}

capture drop `res'
qui predict `res' if `touse', res
predict `tempem', res
capture drop `stdres'
qui gen `stdres'=`res'/`mad' if `res'!=.
qui gen `tempu'=`stdres'
qui gen `tempmad'=`mad'
qui gen `tempccx'=`ccx'
qui matrix `coefS'=e(b)

local tempconsti="`tempconst'"
local tempesi="`tempes'"
local tempemi="`tempem'"
local tempui="`tempu'"
local tempmadi="`tempmad'"
mata: tstatb("`varlist'","`dummies'","`tempconsti'","`tempesi'", "`tempemi'","`tempui'","`tempmadi'","`tempccx'","`touse'")


matrix V=e(V)
ereturn post `coefS' V, esample(`touse') depname(`dv') obs(`N')

ereturn scalar scale=`mad'
ereturn scalar N = `N'

if "`noconstant'"!="" {
ereturn scalar df_r= `N'-`nvar'-`ndum'+1
ereturn scalar df_m= `nvar'-1+`ndum'
}

else {
ereturn scalar df_r= `N'-`nvar'-`ndum'
ereturn scalar df_m= `nvar'+`ndum'
}

ereturn local cmd="mmregress"
ereturn local title="MM-regression"

if `ndum'==0 {

matrix repost V=MMCOVASYM
matrix drop MMCOV
}

else {
matrix repost V=MMCOV
matrix drop MMCOVASYM
}


sort `ord'

ereturn display
di in bl "Scale parameter= " in y %9.0g $S_1 
qui est store `A'

if ("`outlier'"!=""|"`graph'"!="") {
local c=0
local dv: word 1 of `varlist'
local ids: list varlist-dv
foreach v of local ids { 
qui tab `v'

	if r(r)==2 {
	local c=`c'
	}
	else {
	local continuous "`continuous' `v'"
	local c=`c'+1

	}
}

local cv: word 1 of `continuous'
local continuous: list continuous-cv
local b=sqrt(invchi2(`c'),0.975)
capture qui mcd `continuous', outlier
qui capture estimates restore `A'

if "`graph'"!="" {
	if "`label'"!=""{
	local lab="`label'"
	}
	else {
	local lab="`ord'"
	}
label var `ru' "Robust standardized residuals"
twoway (scatter `ru' Robust_distance if abs(`ru')<4&Robust_distance<sqrt(2)*`b') (scatter `ru' Robust_distance if abs(`ru')>=4|Robust_distance>=2*`b', mlabel(`lab') msymbol(circle_hollow)), xline(`b') yline(2.25) yline(-2.25) legend(off)
	
	if "`outlier'"=="" {
	drop Robust_distance MCD_outlier

	} 	
qui estimates restore `A'
}

}

end

version 10.0
mata:
void tstatb(string scalar varlist, string scalar dummies, string scalar tempconsti, string scalar tempesi, string scalar tempemi, string scalar tempui, string scalar tempmadi, string scalar tempccx, string scalar touse)

{
st_view(X=.,.,tokens(varlist),touse)
st_view(Z=.,.,tokens(dummies),touse)
st_view(ONE=.,.,tokens(tempconsti), touse)
st_view(u=.,.,tokens(tempui), touse)
st_view(sc=.,.,tokens(tempmadi), touse)
st_view(sc2=.,.,tokens(tempccx), touse)
st_view(es=.,.,tokens(tempesi), touse)
st_view(em=.,.,tokens(tempemi), touse)

s=sc[1,1]
n=rows(X)
ccx=sc2[1,1]


Z=(nonmissing(ONE)==0 ? Z : (Z,ONE) )
X=(X,Z)

k0=cols(X)
w=(abs(u):/ccx):<=1

psi=w:*u:*(1:-(u:/ccx):^2):^2
dpsi=w:*(1:-u:^2:*(6/ccx^2:-5:*u:^2:/ccx^4))

rho0=(u:^2:/(2):*(1:-(u:^2:/(1.5468906^2)):+(u:^4/(3*1.5468906^4)))):*w:+(1:-w):*(1.5468906^2/6)
drho0=w:*u:*(1:-(u:/1.5468906):^2):^2
ddrho0=w:*(1:-u:^2:*(6/1.5468906^2:-5:*u:^2:/1.5468906^4))

X=X[.,(2..k0)]
k=cols(X)

h1=dpsi*J(1,k,1)  
h1=h1:*X
EdpsiXX=(1/n)*X'*h1
h1=ddrho0*J(1,k,1)
h1=h1:*X;
Eddrho0XX=(1/n)*X'*h1
EdpsiXem=(1/n)*(dpsi:*em)'*X
Eddrho0Xes=(1/n)*(ddrho0:*es)'*X
Edrho0es=(1/n)*drho0'*es

A=(-1/s)*(EdpsiXX,EdpsiXem',J(k,k,0)\J(1,k,0),Edrho0es,J(1,k,0)\J(k,k,0),Eddrho0Xes',Eddrho0XX)
iA=luinv(A)
h1=psi*J(1,k,1)
h0=drho0*J(1,k,1)
rho005=rho0:-0.5*J(n,1,1)

G2=(h1:*X,rho005,h0:*X)

h2=psi*J(1,k,1)  
G=X:*h2
B2=(1/n)*G2'*G2
B=(1/n)*G'*G
h3=invsym(EdpsiXX)
cov1s=s^2*(1/n)*h3*B*h3
cov1=(1/n)*iA*B2*iA'

cov1=cov1[1..k,1..k]

st_matrix("MMCOV",cov1s)
st_matrix("MMCOVASYM",cov1)
}

end


exit


 

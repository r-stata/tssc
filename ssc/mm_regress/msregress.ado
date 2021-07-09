set more off
program define msregress, eclass

if replay()& "`e(cmd)'"=="msregress" {
	ereturn  display
exit
}
syntax varlist(min=2) [if] [in] , dummies(varlist) [ outlier graph NOConstant replic(numlist max=1)]


version 10.0

* MS-regression fit
* By Vincenzo Verardi FNRS-FUNDP


tempvar touse res y0 y y1 residS stdres res w u rho mrho weight tcand u0 mad mad2 dv continuous ord tempconst tempconsti tempu tempui tempmad tempmadi tempes tempesi tempem tempemi tempccx
tempname eps maxit err scale1 scale2 v coefS mrho err2 B1best B2best V1best V2best tempB tempV B B1 B2 V1 V2 A

mark `touse' `if' `in'
markout `touse' `varlist' `dummies'

gettoken dep indep : varlist
qui count if `touse'
local depvar: word 1 of `varlist'
local expl: list varlist -depvar

local nvar: word count `varlist'
local ndum: word count `dummies'
qui count if `touse'
local N=r(N)

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
      display in white "The total number of p-subsets to check for each iteration is "`reps'
      }

local maxit=ceil(log(`nvar')+5)
local ivs "`dummies'"
qui reg `varlist' `dummies'
local dftot=e(df_r)

scalar `eps'=1e-3

scalar `err'=1e20

local ivs `varlist'
qui gen `ord'=_n


	if "`noconstant'"!="" {
	qui mregress `depvar' `dummies' if `touse', noc
	}

	else {
	qui mregress `depvar' `dummies' if `touse'
	}

capture predict `res', res


capture qui sregress `res' `expl' if `touse', replic(`reps') outlier noc

		qui predict `y0'
		capture qui gen `y1'=`dep'-`y0'
		capture qui gen `y'=`dep'-`y0'

		local besterr=1e20
		local bestscale=1e20
            local j 1
            while `j'<=`maxit'&`err'>`eps'{

			scalar `scale1'=$S_1
			capture qui replace `y'=`y1'

			if "`noconstant'"!="" {
			capture qui mregress `y' `dummies' if `touse', noc 
			}

			else {
			capture qui mregress `y' `dummies' if `touse'
			}

			capture drop `y0'
			capture qui predict `y0'
			capture qui replace `y'=`dep'-`y0'

			matrix `B1'=(e(b))'
			matrix `V1'=e(V)

			capture qui sregress `y' `indep'  if `touse',  noc replic(`reps') outlier
			qui capture drop `residS'
			qui capture qui gen `residS'=S_stdres*$S_1
			qui capture drop `stdres'
			qui capture qui gen `stdres'=S_stdres
			capture drop S_stdres S_outlier

			capture drop `y0'
			capture qui predict `y0'

			scalar `scale2'=$S_1

			scalar `err'=abs((`scale2'/`bestscale')-1)
			capture drop `y1'
			capture qui gen `y1'=`dep'-`y0'

			local j=`j'+1
			scalar `scale1'=`scale2'

			matrix `B2'=(e(b))'
			local df2=e(df_r)
			matrix `V2'=e(V)

			capture drop `y0'
			capture qui predict `y0'
			capture drop `y1'
			capture qui gen `y1'=`dep'-`y0'

			if `scale2'<`bestscale' {
			matrix `B1best'=`B1'
			matrix `B2best'=`B2'
			matrix `V1best'=`V1'
			matrix `V2best'=`V2'
			capture drop `u'
			capture qui gen `u'=`stdres'
			local bestscale=`scale2'
			*global MS_1=`bestscale'
			display in g "Iteration " `j'-1  "    scale:   "  `scale2' " - improved"
			}

			else {
			display in y "Iteration " `j'-1  "    scale:   "  `scale2'
			}
			}

capture drop `w'
capture qui gen `w'=1*(abs(`u')/1.5468906<=1)
capture drop `rho'
capture qui gen `rho'=(`u'^2/(2)*(1-(`u'^2/(1.5468906^2))+(`u'^4/(3*1.5468906^4))))*`w' +(1-`w')*(1.5468906^2/6)
capture qui replace `rho'=`rho'*6/1.5468906^2
capture drop `weight'
capture qui gen `weight'=(1-(`u'/1.5468906)^2)^2*`w'
local err=1e20
local eps=1e-15
local mad=`bestscale'
            local j 1
            while `j'<=100&`err'>`eps' {

		if "`noconstant'"!="" {
		qui reg `varlist' `dummies' [aweight=`weight'] if `touse', nocons
		}
		else {
		qui reg `varlist' `dummies' [aweight=`weight'] if `touse'
		}

            capture drop `u0'
            capture qui predict `u0',res
            capture drop `u'
            capture qui gen `u'=`u0'/`mad'
            capture drop `w'
            capture qui gen `w'=1*(abs(`u')/1.5468906<=1)
            capture qui replace `rho'=(`u'^2/(2)*(1-(`u'^2/(1.5468906^2))+(`u'^4/(3*1.5468906^4))))*`w' +(1-`w')*(1.5468906^2/6)
            capture qui replace `rho'=`rho'*6/1.5468906^2
		capture qui summ `rho' if `touse'

            local mrho=r(mean)
            local mad2 = sqrt(`mad'^2 * `mrho'/ 0.5)
            local err=abs(`mad2'/`mad' - 1) 
            capture drop `weight'
            capture qui gen `weight'=(1-(`u'/1.5468906)^2)^2*`w'
            local mad=`mad2'
            local j=`j'+1
            }
		
global MS_1 `mad'

	if "`noconstant'"!="" {
	capture qui reg `varlist' `dummies' [aweight=`weight'] if `touse', nocons
	gen `tempconst'=.
	}

	else {
	capture qui reg `varlist' `dummies' [aweight=`weight'] if `touse'
	gen `tempconst'=1
	}

macro drop S_1
capture drop `res'
qui predict `res' if `touse', res
predict `tempem', res
capture drop `stdres'

qui gen `stdres'=`res'/`mad' if `res'!=.
qui gen `tempu'=`stdres'
qui gen `tempmad'=`mad'
qui matrix `coefS'=e(b)

local tempconsti="`tempconst'"
local tempui="`tempu'"
local tempmadi="`tempmad'"
mata: tstatb("`varlist'","`dummies'","`tempconsti'","`tempui'","`tempmadi'","`touse'")

local depvar: word 1 of `varlist'
matrix V=e(V)
ereturn post `coefS' V, esample(`touse') depname(`depvar') obs(`N')

ereturn scalar scale=`mad'
ereturn scalar N = `N'



if "`noconstant'"!="" {
ereturn scalar df_r= `N'-`nvar'-`ndum'+1
ereturn scalar df_m= `nvar'+`ndum'-1
}

else {
ereturn scalar df_r= `N'-`nvar'-`ndum'
ereturn scalar df_m= `nvar'+`ndum'
}

ereturn local cmd="msregress"
ereturn local title="MS-regression"


else {
matrix repost V=MMCOV
}


sort `ord'
di""
ereturn display
di "Scale parameter: " in y $MS_1
qui est store `A'

if "`outlier'"!="" {
capture drop MS_outlier
gen MS_outlier=(abs(`stdres')>2.5) if e(sample)&`stdres'!=.
capture drop MS_stdres
gen MS_stdres=`stdres' if e(sample)&`stdres'!=.

}
capture drop S_stdres S_outlier

if "`graph'"!="" {
local dv: word 1 of `varlist'
local continuous: list varlist-dv
local b=sqrt(invchi2(`nvar'-1),0.95)
capture qui mcd `continuous', outlier
label var `stdres' "Robust standardized residuals"
twoway (scatter `stdres' Robust_distance if abs(`stdres')<4&Robust_distance<sqrt(2)*`b') (scatter `stdres' Robust_distance if abs(`stdres')>=4|Robust_distance>=2*`b', mlabel(`ord') msymbol(circle_hollow)), xline(`b') yline(1.96) yline(-1.96) legend(off)
qui est restore `A'
}

end

version 10.0
mata:
void tstatb(string scalar varlist, string scalar dummies, string scalar tempconsti, string scalar tempui, string scalar tempmadi, string scalar touse)

{
st_view(X=.,.,tokens(varlist),touse)
st_view(Z=.,.,tokens(dummies),touse)
st_view(ONE=.,.,tokens(tempconsti), touse)
st_view(u=.,.,tokens(tempui), touse)
st_view(sc=.,.,tokens(tempmadi), touse)


s=sc[1,1]
n=rows(X)
ccx=1.5468906


Z=(nonmissing(ONE)==0 ? Z : (Z,ONE) )
X=(X,Z)

k0=cols(X)
w=(abs(u):/ccx):<=1
psi=w:*u:*(1:-(u:/ccx):^2):^2
dpsi=w:*(1:-u:^2:*(6/ccx^2:-5:*u:^2:/ccx^4))


X=X[.,(2..k0)]
k=cols(X)

h1=dpsi*J(1,k,1)  
h1=h1:*X
EdpsiXX=(1/n)*X'*h1

h2=psi*J(1,k,1)  
G=X:*h2
B=(1/n)*G'*G
h3=invsym(EdpsiXX)
cov1s=s^2*(1/n)*h3*B*h3

st_matrix("MMCOV",cov1s)
}

end

exit

program define sregress, eclass

* S-regression fit
* By Vincenzo Verardi FNRS-FUNDP and Christophe Croux

version 10.0


if replay()& "`e(cmd)'"=="sregress" {
	ereturn  display
exit
}

syntax varlist [if] [in] , [outlier replic(numlist max=1)  NOConstant graph ]

tempvar rand yres touse u u0 w rho psi weight tcand bestw res stdres ord continuous dv v ivs tempconst tempu tempmad
tempname mad mad2 bestmad bestmrho mrho scale eps maxit err v B coefS nvar1 b c touse1 A
local nvar: word count `varlist'
local nvar1=`nvar'-1
	
if `nvar'==1 {
local nvar=2
}

local dv: word 1 of `varlist'
local expl: list varlist -dv
 
mark `touse' `if' `in'
markout `touse' `varlist' 

qui count if `touse'
local N=r(N)

qui gen `ord'=_n
qui gen `touse1'=1-`touse'
qui sort `touse1'

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
      display in white "The total number of p-subsets to check is "`reps'
      }

qui gen `rand'=0
scalar `bestmad'=10e+12
scalar `bestmrho'=10e+12
scalar `eps'=1e-5
scalar `maxit'=50
qui gen `tcand'=10e+12
qui gen `bestw'=1

capture qui {

local i 1
while `i'<=`reps' {
	capture drop `rand'
	sort `touse1' `ord'

      qui gen `rand'=uniform()
      sort `touse1' `rand'
      scalar `err'=1

	if "`noconstant'"!="" {
	qui reg `varlist' in 1/`nvar1', nocons
	}
	else {
	qui reg `varlist' in 1/`nvar'
	}
	
      capture drop `yres'	
      capture drop `u0'
      predict `yres', res
      gen `u0'=`yres'
      qui replace `yres'=abs(`yres')
      summ `yres' if `touse', d
      scalar `mad'=_result(10)/0.6745

      capture drop `u'
      gen `u'=`u0'/`mad'
      capture drop `w'
      gen `w'=1*(abs(`u')/1.5468906<=1)
      capture drop `rho'
      gen `rho'=(`u'^2/(2)*(1-(`u'^2/(1.5468906^2))+(`u'^4/(3*1.5468906^4))))*`w' +(1-`w')*(1.5468906^2/6)
      replace `rho'=`rho'*6/1.5468906^2
      qui summ `rho' if `touse'
      scalar `mrho'=r(mean)

 
      capture drop `weight'
      gen `weight'=(1-(`u'/1.5468906)^2)^2*`w'

		sort `tcand'
 		if `mad'<`tcand' in 5 {
		replace `tcand'=`mad' in 5

            local j 1
            while `j'<=`maxit'&`err'>`eps' {

		if "`noconstant'"!="" {
		qui reg `varlist' [aweight=`weight'] if `touse', nocons
		}
		else {
		qui reg `varlist' [aweight=`weight'] if `touse'
		}

            capture drop `u0'
            capture qui predict `u0',res
            capture drop `u'
            capture qui gen `u'=`u0'/`mad'
            capture drop `w'
            capture qui gen `w'=1*(abs(`u')/1.5468906<=1)
            replace `rho'=(`u'^2/(2)*(1-(`u'^2/(1.5468906^2))+(`u'^4/(3*1.5468906^4))))*`w' +(1-`w')*(1.5468906^2/6)
            replace `rho'=`rho'*6/1.5468906^2
            qui summ `rho' if `touse'
            scalar `mrho'=r(mean)
            scalar `mad2' = sqrt(`mad'^2 * `mrho'/ 0.5)
            scalar `err'=abs(`mad2'/`mad' - 1) 
            capture drop `weight'
            capture qui gen `weight'=(1-(`u'/1.5468906)^2)^2*`w'
            scalar `mad'=`mad2'
            local j=`j'+1
            }
		}

      if `mad'<`bestmad' {
      scalar `bestmad'=`mad'
      replace `bestw'=`weight'

      }


local i=`i'+1
}
}
sort `ord'
	if "`noconstant'"!="" {
	qui reg `varlist' [aweight=`bestw'] if `touse', nocons
	gen `tempconst'=.
	}

	else {
	qui reg `varlist' [aweight=`bestw'] if `touse'
	gen `tempconst'=1
	}
	
	matrix `coefS'=e(b)

	capture drop `u'
	predict `u', res
	qui replace `u'=`u'/`bestmad'
	capture drop `stdres'
	qui gen `stdres'=`u'

	qui gen `tempu'=`stdres'
	qui gen `tempmad'=`bestmad'

local tempconsti="`tempconst'"
local tempui="`tempu'"
local tempmadi="`tempmad'"

mata: tstat("`varlist'","`tempconsti'","`tempui'","`tempmadi'","`touse'")

matrix V=e(V)

ereturn post `coefS' V, esample(`touse') depname(`dv') obs(`N')
ereturn local depvar = "`depvar'"

ereturn scalar scale=`bestmad'
ereturn scalar N = `N'
if "`noconstant'"!="" {
ereturn scalar df_r= `N'-`nvar'+1
ereturn scalar df_m= `nvar'-1
}

else {
ereturn scalar df_r= `N'-`nvar'
ereturn scalar df_m= `nvar'
}

ereturn local cmd="sregress"
ereturn local title="S-regression"
matrix repost V=COV

qui sort `ord'

ereturn display
di in bl "Scale parameter= "%9.0g in y scalar(`bestmad') 
qui est store `A'

global S_1=`bestmad'

if "`outlier'"!="" {
capture drop S_outlier
capture qui gen S_outlier=(abs(`stdres')>2.25) if e(sample)&`stdres'!=.
capture drop S_stdres
capture qui gen S_stdres=`stdres' if e(sample)&`stdres'!=.
qui est restore `A'
}


if "`graph'"!="" {

local c=0
local dv: word 1 of `varlist'
local ivs: list varlist-dv
foreach v of local ivs { 
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
qui est restore `A'
label var `stdres' "Robust standardized residuals"
twoway (scatter `stdres' Robust_distance if abs(`stdres')<4&Robust_distance<sqrt(2)*`b') (scatter `stdres' Robust_distance if abs(`stdres')>=4|Robust_distance>=2*`b', mlabel(`ord') msymbol(circle_hollow)), xline(`b') yline(2.25) yline(-2.25) legend(off)
}
end

version 10.0
mata:

void tstat(string scalar varlist, string scalar tempconsti, string scalar tempui, string scalar tempmadi, string scalar touse)

{
st_view(X=.,.,tokens(varlist),touse)
st_view(ONE=.,.,tokens(tempconsti), touse)
st_view(u=.,.,tokens(tempui),touse)
st_view(sc=.,.,tokens(tempmadi), touse)

s=sc[1,1]
n=rows(X)
ONE=ONE[1..n,1]

X=(nonmissing(ONE)==0 ? X : (X,ONE) )

k0=cols(X)
w=(abs(u):/1.5468906):<=1

psi=w:*u:*(1:-(u:/1.5468906):^2):^2
dpsi=w:*(1:-u:^2:*(6/1.5468906^2:-5:*u:^2:/1.5468906^4))

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

st_matrix("COV",cov1s)
}

end

exit


 

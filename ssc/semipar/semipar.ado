
*version 1.2
program define semipar, eclass

version 10.1

if replay()& "`e(cmd)'"=="semipar" {
	ereturn  display
exit
}

syntax varlist [if] [in] [aw fw/], nonpar(varlist) [Generate(string) PARtial(string) degree(real 1) trim(real 0) kernel(string) NOGraph ci Title(string) ytitle(string) xtitle(string) robust cluster(varlist) test(numlist max=1) nsim(real 100)  level(real 95) weight_test(varlist)  ]

tempvar touse res hat y2 res2 id low hi aa nonpardd zzz Parametric_Fit
tempname B1 B2 B V V0 A


mark `touse' `if' `in'
markout `touse' `varlist'

if "`kernel'"=="" {
local kernel="gaussian"
}

gen `id'=_n
qui sum `id'
local max=r(max)

qui count
local N0=r(N)

qui count if `touse'
local N=r(N)

local dv: word 1 of `varlist'
local expl: list varlist -dv

tokenize `expl'
local nex: word count `expl'

    if "`weight'"!="" {
    local wgt "[`weight' = `exp']"
    }
	
	if "`weight'"!=""&"`kernel'"=="gaussian" {
	di in r "Due to limitations in lpoly, the gaussian kernel cannot be used with weights"
	exit 198
	}
	
	_get_kernel_name, kernel(`"`kernel'"')
	local kernel `s(kernel)'
	if `"`kernel'"' == "" {
		di as err "invalid kernel function"
		exit 198
	}

capture qui kdensity `nonpar' `wgt', nograph gen(`aa' `nonpardd') at(`nonpar')
qui sum `nonpardd'

if `trim'<0|`trim'>r(max) {
di ""
di in r "Trimming is related to the density of " "`nonpar'" " and should be between 0 and " round(r(max),0.001)
exit 198
}

capture qui replace `touse'=`touse'*(`nonpardd'>=`trim')


if `nex'==0 {
di ""
di in r "No parametric part is present. Use a nonparametric regression estimator (e.g. lpoly)"
exit 198
}

foreach var of varlist `varlist' {
tempvar hat`var'
capture qui lpoly `var' `nonpar' if `touse', degree(`degree') gen(`hat`var'') at(`nonpar') nograph kernel(`kernel')
tempvar res`var'
qui gen `res`var''=`var'-`hat`var''
local variabres "`variabres' `res`var''"
}

if "`cluster'"!="" { 
qui reg `variabres' `wgt' if `touse', cluster(`cluster') nocons
}

else if "`robust'"!="" { 
qui reg `variabres' `wgt' if `touse', robust  nocons
}

else { 
qui reg `variabres' `wgt' if `touse', nocons
}

gen `zzz'=e(sample)
matrix `B1'=e(b)
matrix `V0'=e(V)

matrix colnames `B1'=`expl' 
matrix colnames `V0'=`expl' 
matrix rownames `V0'=`expl' 
ereturn local depvar = "`dv'"


local nobs = e(N)
local dof  = e(df_r)
local F   = e(F)
local r2   = e(r2)
local rmse = e(rmse)
local mss  = e(mss)
local rss = e(rss)
local r2_a = e(r2_a)
local ll   = e(ll)


matrix b =`B1'
matrix V=`V0'



ereturn post b V, esample(`zzz') depname(`dv') obs(`nobs') dof(`dof') 

ereturn scalar df_m   = `nobs'-`dof'
ereturn scalar F=`F'
ereturn scalar r2=`r2'
ereturn scalar rmse=`rmse'
ereturn scalar mss=`mss'
ereturn scalar rss=`rss'
ereturn scalar r2_a=`r2_a'
ereturn scalar ll =`ll'

ereturn local title "Partial linear regression"
ereturn local depvar `dv'
ereturn local model "Robinson Semiparametric Estimation"

ereturn local cmd "semipar"

di ""
di in green "{col 55} Number of obs =" in yellow %8.0f `nobs'
di in green "{col 55} R-squared     =" in yellow %8.4f `r2'
di in green "{col 55} Adj R-squared =" in yellow %8.4f  `r2_a'
di in green "{col 55} Root MSE      ="	in yellow %8.4f `rmse'

ereturn display
qui est store `Parametric_Fit'
qui reg `varlist' if `touse', nocons

matrix `B2'=e(b)


ereturn post `B2'
matrix repost b=`B1'


predict `res2'
qui summarize `res2', meanonly
local mean_y_hat=r(mean)

qui replace `res2'=`dv'-`res2'+`mean_y_hat'

if "`generate'"!="" {
	tokenize `"`generate'"'
	local nw: word count `generate'

	if `nw'==1 {  
		
		local marker `1'
		confirm new var `marker'
		qui sum  `nonpar'
		lpoly `res2' `nonpar' `wgt' if `touse' , degree(`degree') gen(`marker') at(`nonpar') legend(off) kernel(`kernel')  nograph
	}

	else {
	di ""
	di in r "define 1 variables in option generate"
	exit 198
	}
}


else {
lpoly `res2' `nonpar' `wgt' if `touse', degree(`degree') nograph at(`nonpar') kernel(`kernel')
}

local b1=r(bwidth)
local rn=r(ngrid)

if "`nograph'"=="" {

if "`ci'"!="" {

	if "`generate'"!="" {
	twoway (lpolyci `res2' `nonpar' `wgt' if `touse', bwidth(`b1') kernel(`kernel') degree(`degree') level(`level')) (scatter `res2' `nonpar', mcolor(navy)) if `touse', legend(off) title(`title') ytitle(`ytitle') xtitle(`xtitle')
	}

	else {
	twoway (lpolyci `res2' `nonpar' `wgt' if `touse', bwidth(`b1') kernel(`kernel') degree(`degree') level(`level')) (scatter `res2' `nonpar', mcolor(navy)) if `touse', legend(off) title(`title') ytitle(`ytitle') xtitle(`xtitle')
	}
}

else {
	if "`generate'"!="" {
	twoway (lpolyci `res2' `nonpar' `wgt' if `touse', bwidth(`b1') kernel(`kernel') degree(`degree')  fcolor(none) alcolor(none) ) (scatter `res2' `nonpar', mcolor(navy)) if `touse', legend(off) title(`title') ytitle(`ytitle') xtitle(`xtitle')
	}

	else {
	twoway (lpolyci `res2' `nonpar' `wgt' if `touse', bwidth(`b1') kernel(`kernel') degree(`degree')  fcolor(none) alcolor(none) ) (scatter `res2' `nonpar', mcolor(navy)) if `touse', legend(off) title(`title') ytitle(`ytitle') xtitle(`xtitle')
	}
}
}

*twoway lpolyci `res2' `nonpar' if `touse', legend(off) title(`title')

if "`test'"!="" {

if `test'<0|round(`test')!=`test' {
di ""

display in r "The order of the polynomial should be a positive integer or zero"
di""

capture qui keep in 1/`N0'

error 198

exit
}

qui{
tempvar yhat0 yhat yhat2 diff2 T0 Ts TT ystar e u
lpoly `res2' `nonpar' `wgt' if `touse', gen(`yhat0') at(`nonpar') nograph kernel(`kernel') degree(`degree')
local b0=r(bwidth)

if `test'==0 {
local nonparb ""
}

else {
local nonparb "`nonpar'"
}

forvalues k=2(1)`test' {
tempvar nonpar`k'
gen `nonpar`k''=`nonpar'^`k'
local nonparb "`nonparb' `nonpar`k''"
}


qui reg `res2' `nonparb' `wgt' if `touse'

predict `yhat'
predict `res', res

lpoly `yhat' `nonpar' `wgt' if `touse', gen(`yhat2') at(`nonpar') bw(`b0') nograph kernel(`kernel') degree(`degree')

if "`weight_test'"=="" {
tempvar weight_test
gen `weight_test'=1/`nobs' if `touse'
}

gen `diff2'=((`yhat0'-`yhat2')^2)*`weight_test'
qui sum `diff2' if `touse'
local nobs=r(N)
gen `T0'=0

if `nsim'>`max' {
set obs `nsim'
}



gen `Ts'=`nobs'*sqrt(`b0')*r(sum)

noi di""
noi di "Simulation the distribution of the test statistic"
noi di ""
nois _dots `i' 0, title(bootstrap replicates) reps(`nsim')
noi di ""


forvalues i=1(1)`nsim' {
nois _dots `i' 0
capture drop `u' `ystar'
capture drop `e'
gen `e'=(sqrt(5)+1)/2
gen `u'=uniform()

qui replace `e'=-(sqrt(5)-1)/2 if `u'<=((sqrt(5)+1)/(2*sqrt(5)))
gen `ystar'=`yhat'+`res'*`e'

if "`cluster'"!="" {
qui bysort `cluster': replace `e'=(sqrt(5)+1)/2
qui bysort `cluster': replace `e'=-(sqrt(5)-1)/2 if `u'[1]<=((sqrt(5)+1)/(2*sqrt(5)))
replace `ystar'=`yhat'+`res'*`e'
}


capture drop `yhat0' `yhat' `yhat2' `diff2'
lpoly `ystar' `nonpar' `wgt' if `touse', gen(`yhat0') at(`nonpar') nograph kernel(`kernel') degree(`degree')
local b0=r(bwidth)
 
reg `ystar' `nonparb' `wgt' if `touse'
predict `yhat' if `touse'

lpoly `yhat' `nonpar' `wgt' if `touse', gen(`yhat2') at(`nonpar') bw(`b0') nograph  kernel(`kernel') degree(`degree')


gen `diff2'=((`yhat0'-`yhat2')^2)*`weight_test'
qui sum `diff2'
qui replace `T0'=`nobs'*sqrt(`b0')*r(sum) in `i'


}
scalar TTT=`Ts'
qui gen `TT'=(`Ts'<`T0') in 1/`nsim'
sum `TT' in 1/`nsim', detail
}
local m=r(mean)


qui centile `T0' in 1/`nsim',  centile(`level')
tempname loclev

local loclev=1-((1-(`level'/100))/2)

local quant=r(c_1)

qui replace `Ts'=(`Ts'/`quant')*invnorm(`loclev')
qui replace `T0'=(`T0'/`quant')*invnorm(`loclev')
qui centile `T0' in 1/`nsim',  centile(`level')

di ""
di ""
di "H0: Parametric and non-parametric fits are not different"
di "-------------------------------------------------------"
di "Standardized Test statistic T: " `Ts'
di "Critical value ("  `level'  "%" "): " r(c_1)
di "Approximate P-value: " `m'
di""
}

if "`partial'"!="" {
	tokenize `"`partial'"'
	local nw: word count `partial'

	if `nw'==1 {  
		
		local marker2 `1'
		confirm new var `marker2'
		gen `marker2'=`res2'
	}

	else {
	di in r "define 1 variables in option partial"
	exit 198
	}
}

capture qui est restore  `Parametric_Fit'
ereturn local _estimates_name "Parametric fit"
capture qui keep in 1/`max'


end

// parsing facility to retrieve kernel name
// copied from lpoly
program _get_kernel_name, sclass
	syntax , KERNEL(string)
	local kernlist epan2 epanechnikov biweight	///
			cosine gaussian parzen		///
			rectangle triangle
	local maxabbrev 5 2 2 3 3 3 3 3
	tokenize `maxabbrev'
	local i = 1
	foreach kern of local kernlist {
		if substr("`kern'",1,length(`"`kernel'"')) == `"`kernel'"' ///
					     & length(`"`kernel'"') >= ``i'' {
			sreturn local kernel `kern'
			continue, break
		}
		else {
			sreturn local kernel
		}
		local ++i
	}
end

exit


*xtsemipar V1.2  23 April 2014
*François Libois and Vincenzo Verardi, University of Namur
*contact: francois.libois@unamur.be

program define xtsemipar, eclass

version 10.1

if replay()& "`e(cmd)'"=="xtsemipar" {
	ereturn  display
exit
}

syntax varlist [if] [in] [aw fw/], nonpar(varlist) [robust cluster(varlist) ci DEGree(real 4)  NOGraph GENerate(string) level(cilevel) BWidth(numlist max=1) spline  knots1(numlist) knots2(numlist)]

tempname lnonpar touse

mark `touse' `if' `in'
markout `touse' `varlist'

	capture tsset
	
	capture local ivar "`r(panelvar)'"
	if "`ivar'"=="" {
		di as err "must tsset data and specify panelvar"
		exit 459
	}
	capture local tvar "`r(timevar)'"
	if "`tvar'" == "" {
		di as err "must tsset data and specify timevar"
		exit 459
	}

	tokenize `"`generate'"'
	if `"`3'"'!="" { error 198 }
	local marker `1'
	local Dvar `2'		/* may be null */
	confirm new var `marker' `Dvar'
	di ""
	di in r "Maximum two variables can be declared in option generate"
	exit 198
	}

local varlist: list varlist -nonpar

tempvar tmax tmin
bysort `ivar': egen `tmax'=count(`tvar')
bysort `ivar': egen `tmin'=max(`tmax')
qui sum `tmin'


markout `touse' `varlist'

qui gen `lnonpar'=l.`nonpar'
local dvarlist "d.(`varlist')"
local dv: word 1 of `varlist'

local expl: list varlist -dv

tokenize `expl'
local nex: word count `expl'

    if "`weight'"!="" {
    local wgt "[`weight' = `exp']"
    }
	

if `nex'==0 {
di ""
di in r "No parametric part is present. Use a nonparametric regression estimator instead"
exit 198
}

local nvar: word count `dvarlist'
local nvar=`nvar'-1
qui {

qui reg `dvarlist' `wgt'


if "`knots1'"!= "" {
local nknots1: word count `knots1'
}

else {
local nknots1=11
}

if "`knots2'"!= "" {
local nknots2: word count `knots2'
}

else {
local nknots2=11
}

if "`knots1'"!= ""& "`knots2'"== ""{
local nknots2=`nknots1'
}

local nfin1=`degree'+`nknots1'+1
local nfin2=`degree'+`nknots2'+1


forvalues i=1(1)`nfin1' {
tempname diffa`i'
local diffa="`diffa' `diffa`i''"
tempname diffb`i'
local diffb="`diffb' `diffb`i''"
}


if "`degree'"=="0" {
di ""
di in r "degree should be strictly positive"
exit 198
}

if "`knots1'"!="" {
qui bspline `diffa' if `touse', x(`nonpar') power(`degree') knots(`knots1')
qui bspline `diffb' if `touse', x(`lnonpar') power(`degree')  knots(`knots1')
}

else {
qui centile `nonpar', centile(0 10 20 30 40 50 60 70 80 90 100)

forvalues k=1(1)9 {
local ck=r(c_`k')
local knots=("`knots' `ck'")
}

qui bspline `diffa' if `touse', x(`nonpar') power(`degree') knots(`knots') 
qui bspline `diffb' if `touse', x(`lnonpar') power(`degree')  knots(`knots')
}

forvalues i=1(1)`degree' {
tempname diffc`i'
gen `diffc`i''=`diffa`i''-`diffb`i''
local diff="`diff' `diffc`i''"
}

tempvar touse0
qui generate byte `touse0' = `touse'

else if "`robust'"!="" { 
qui reg `dvarlist' `diff'  `wgt' if `touse', robust nocons level(`level')
}

if "`cluster'"!="" { 
qui reg `dvarlist' `diff' `wgt' if `touse', cluster(`cluster') nocons level(`level')
}

else { 
qui reg `dvarlist' `diff'  `wgt'  if `touse', nocons level(`level')
}

local dof  = e(df_r)
local F   = e(F)
local r2   = e(r2)
local rmse = e(rmse)
local mss  = e(mss)
local rss = e(rss)
local r2_a = e(r2_a)
local ll   = e(ll)
local nobs = e(N)

local j=0
foreach var of varlist `diff' {
local j=`j'+1
drop `var'
qui rename `diffa`j'' `var'
local diff2 "`diff2' `var'"
}

tempname B1 B2 res2 Vb Vb2 Vb0 B10

matrix `B1'=e(b)
matrix `Vb'=e(V)

matrix `B10'=e(b)
matrix `Vb0'=e(V)

qui reg `varlist' `diff2'  `wgt' if `touse', noc level(`level')
matrix `B2'=e(b)
matrix `Vb2'=e(V)

ereturn post `B2' `Vb2'

matrix repost b=`B1'
matrix repost V=`Vb'

tempvar ehat
qui predict `ehat' if `touse'&`tmin'!=1
qui replace `ehat'=`dv'-`ehat'
tempname m`ehat'
bysort `ivar': egen `m`ehat''=mean(`ehat')

matrix `Vb'=`Vb0'[1..`nvar',1..`nvar']
matrix `B1'=`B10'[1,1..`nvar']

qui reg `varlist' `wgt' if `touse', noc
matrix `B2'=e(b)
matrix `B2'=`B2'[1,1..`nvar']
matrix `Vb2'=e(V)
matrix `Vb2'=`Vb2'[1..`nvar',1..`nvar']
}



ereturn post `B2' `Vb2', depname(`dv') obs(`nobs') dof(`dof')

ereturn scalar df_m   = `nobs'-`dof'
ereturn scalar F=`F'
ereturn scalar r2=`r2'
ereturn scalar rmse=`rmse'
ereturn scalar mss=`mss'
ereturn scalar rss=`rss'
ereturn scalar r2_a=`r2_a'
ereturn scalar ll =`ll'

matrix repost b=`B1'
matrix repost V=`Vb'

ereturn repost, esample(`touse0')

ereturn local title "Panel fixed-effects partial linear regression"
ereturn local depvar "`dv'"
ereturn local model "Baltagi Fixed-effect Series Semiparametric Estimation"
ereturn local cmd "xtsemipar"

noi di ""
noi di in green "{col 48} Number of obs        =" in yellow %8.0f `nobs'
noi di in green "{col 48} Within R-squared     =" in yellow %8.4f `r2'
noi di in green "{col 48} Adj Within R-squared =" in yellow %8.4f  `r2_a'
noi di in green "{col 48} Root MSE             =" in yellow %8.4f `rmse'
tempname E1
est store `E1'
ereturn display, level(`level')

qui predict `res2' if `touse'
qui replace `res2'=`dv'-`res2'-`m`ehat''
qui sum `res2'
qui replace `res2'=`res2'-r(mean)
qui replace `res2'=. if `tmin'==1

tempvar aaa bbb low up

if "`nograph'"==""|"`generate'"!="" {

	if "`spline'"==""{
		qui lpoly  `res2' `nonpar' `wgt' if `touse', bw(`bw') `ci' degree(`degree') at(`nonpar') gen(`aaa') level(`level') nograph
		
		if "`knots2'"!="" {
		di ""
		no di in r "Option knots2 is ignored as it is meaningful only in Spline regressions." 
		di""
		}
	
	}

	else {

		if "`bwidth'"!="" {
		di ""
		no di in r "Only Spline options are considered, bw is meaningful only in Kernel regressions." 
		di""
		}	

		forvalues i=1(1)`nfin2' {
		tempname levela`i'
		local levela "`levela' `levela`i''"
		}

	if "`knots2'"!="" {
	qui bspline `levela' if `touse'&`tmin'!=1, x(`nonpar') power(`degree') knots(`knots2')
	}
	
	else {
	qui bspline `levela' if `touse'&`tmin'!=1, x(`nonpar') power(`degree') knots(`knots1')
	}
	
	
	qui reg `res2' `levela'  `wgt' if `touse'&`tmin'!=1, noc
	
	qui predict `aaa' if `tmin'!=1
	qui predict `bbb' if `tmin'!=1, stdp

}

if "`nograph'"=="" {

	if "`ci'"!=""&"`spline'"!="" {
	local z =  invnormal(1 - (100 - `level') / 200)
	qui gen `low'=`aaa'-`z'*`bbb'
	qui gen `up'=`aaa'+`z'*`bbb'
	twoway (rarea `low' `up' `nonpar' if `touse', sort(`nonpar') color(gs10))(scatter `res2' `nonpar' if `touse', mcolor(navy)) (line `aaa' `nonpar' if `touse', sort(`nonpar') color(maroon)), legend( order( 1 "`level'% CI" 2 "linear fit" 3 "B-spline smooth") cols(3))
	}
	
	else if "`spline'"!="" {
	twoway (scatter `res2' `nonpar' if `touse', mcolor(navy)) (line `aaa' `nonpar' if `touse', sort(`nonpar') color(maroon)), legend( order( 1 "linear fit" 2 "spline smooth") cols(2))
	}
	
	else {
	qui lpoly  `res2' `nonpar' `wgt' if `touse'&`tmin'!=1, bw(`bwidth') `ci' degree(`degree') at(`nonpar') level(`level')
	}
}

tempvar aab

gen `aab'=`aaa'

}


if "`generate'"!="" {

	tokenize `"`generate'"'
	label var `aab' `"Nonparametric fit"'
	local marker `1'
	local Dvar `2'
	rename `aab' `marker'
	
	if `"`Dvar'"'!="" {
	label var `res2' `"Partialled-out residuals"'
	rename `res2' `Dvar'
	}
	
}


if "`nograph'"!=""&"`ci'"!="" {
noi di ""
noi di in red "Option ci ignored since no graph is requested"
noi di ""
}

if "`nograph'"!=""&"`spline'"!="" {
noi di ""
noi di in red "Option spline is ignored since no graph is requested"
noi di ""
}

if "`nograph'"!=""&"`knots2'"!="" {
noi di ""
noi di in red "Option knots2 is ignored since no graph is requested"
noi di ""
}

qui est restore `E1'
end

* 1.2.0 TC KS 25 june 2009
program define inteff3
version 9
set more off

syntax [if] [in], [average post at(numlist) varx1(varname) varx2(varname) varx3(varname) varx1x2(varname) varx1x3(varname) varx2x3(varname) varx1x2x3(varname) pex1(name) pex2(name) pex3(name) pex1x2(name) pex1x3(name) pex2x3(name) pex1x2x3(name) sx1(name) sx2(name) sx3(name) sx1x2(name) sx1x3(name) sx2x3(name) sx1x2x3(name)]

tempvar dyd ser sig_level v probit test sample

marksample touse
qui gen `sample'=0
qui replace `sample'=1 if `touse' & e(sample)==1
set varabbrev off

preserve
qui keep if e(sample)

tempname M M3 b V sum VP a c

_estimates hold `probit', copy



if "`varx1'"=="" & "`varx2'"=="" & "`varx3'"=="" & "`varx1x2'"=="" & "`varx1x3'"=="" & "`varx2x3'"=="" & "`varx1x2x3'"==""{
local names : colnames e(b)
tokenize `names'
local w `1'
local j `2'
local n `3'
local wj `4'
local wn `5'
local jn `6'
local jnw `7'
mat `b'=e(b)
mat `b'=`b'[1,8..colsof(`b')-1]
local controls : colnames `b'
}
else {
if "`varx1'"~="" & "`varx2'"~="" & "`varx3'"~="" & "`varx1x2'"~="" & "`varx1x3'"~="" & "`varx2x3'"~="" & "`varx1x2x3'"~=""{
local w `varx1'
local j `varx2'
local n `varx3'
local wj `varx1x2'
local wn `varx1x3'
local jn `varx2x3'
local jnw `varx1x2x3'
mat `b'=e(b)

foreach X of any `varx1' `varx2' `varx3' `varx1x2' `varx1x3' `varx2x3' `varx1x2x3' {
if colnumb(`b',"`X'")==.{
	di in red "`X' is no regressor of the preceding probit/logit model."
	error 9
	}

if colnumb(`b',"`X'")==1{
	mat `b'=`b'[1,2..colsof(`b')]
	}
else {
	mat `b'=`b'[1,1..colnumb(`b',"`X'")-1],`b'[1,colnumb(`b',"`X'")+1..colsof(`b')]
	}
}
mat `b'=`b'[1,1..colsof(`b')-1]
local controls : colnames `b'
}
else {
di in red "You must specify all options varx1() varx2() varx3() varx1x2() varx1x3() varx2x3() varx1x2x3() simultaneously."
di in red "Alternatively you can specify none of them and make sure that the first seven regressors of the preceding estimation"
di in red "corrspond to the three dummies and their interactions in the following order: x1 x2 x3 x1*x2 x1*x3 x2*x3 x1*x2*x3."
error 9
} 
}

tempvar der`j' der`n' der`w' der`wj' der`wn' der`jn' der`jnw'
if "`controls'"!=""{
foreach m of varlist `controls'{
	tempvar der`m'
	}
}
tempvar dercons

** I. Check the previous command;
if (e(cmd)=="probit") {
	local F normal(((
	local f normden(((
	}
else if (e(cmd)=="logit") {
	local F 1/(1+exp(-(
	}
else {
    di in red "inteff3 requires last estimates to be logit or probit. Those"
    error 301
    }


** II. Check the order of the arguments
qui gen `test' = sum(abs((`w'*`j' - `wj')/`wj'))
scalar `sum' = `test'[_N]
if `sum'>0.001 {
if "`varx1'"=="" if "`varx1'"=="" di in red "Error: The fourth regressor is not the product of the first and second regressors."
else di in red "Error: `varx1x2' is not the product of `varx1' and `varx2'"
}
if `sum'>0.001 error 9

drop `test'
qui gen `test' = sum(abs((`w'*`n' - `wn')/`wn'))
scalar `sum' = `test'[_N]
if `sum'>0.001 {
if "`varx1'"=="" di  in red "Error: The fifth regressor is not the product of the first and third regressors." 
else di in red "Error: `varx1x3' is not the product of `varx1' and `varx3'"
}
if `sum'>0.001 error 9

drop `test'
qui gen `test' = sum(abs((`j'*`n' - `jn')/`jn'))
scalar `sum' = `test'[_N]
if `sum'>0.001 {
if "`varx1'"=="" di in red "Error: The sixth regressor is not the product of the second and third regressors." 
else di in red "Error: `varx2x3' is not the product of `varx2' and `varx3'"
}
if `sum'>0.001 error 9

drop `test'
qui gen `test' = sum(abs((`j'*`n'*`w' - `jnw')/`jnw'))
scalar `sum' = `test'[_N]
if `sum'>0.001 {
if "`varx1'"=="" di  in red "Error: The seventh regressor is not the product of the first, second and third regressors."
else di in red "Error: `varx1x2x3' is not the product of `varx1', `varx2' and `varx3'"
}
if `sum'>0.001 error 9
drop `test'

**III. Check length of me and se strings and existence of vars
if "`pex1' `pex2' `pex3' `pex1x2' `pex1x3' `pex2x3' `pex1x2x3' `sx1' `sx2' `sx3' `sx1x2' `sx1x3' `sx2x3' `sx1x2x3'"~="             " {
if "`average'" =="" {
	di  in red "Error: Option me is only valid with option average."
	error 9
	}
else foreach X of any `pex1' `pex2' `pex3' `pex1x2' `pex1x3' `pex2x3' `pex1x2x3' `sx1' `sx2' `sx3' `sx1x2' `sx1x3' `sx2x3' `sx1x2x3' {
cap confirm variable `X'
if !_rc==1 {
	di in red "Error: Variable `X' already exists."
	error 9
	}
}
}


di _newline in green "Dummies and Interactions: `w', `j', `n', `wj', `wn', `jn', `jnw'."
di in green "Control variable: `controls', constant term."

if "`at'"!=""{
mat `M'=0
foreach k of numlist `at'{
mat `M'=`M',`k'
}
mat `M3'=`M'[1,2..4]
mat `M'=`M'[1,5..colsof(`M')]
local wc=wordcount("`controls'")+4
if colsof(`M')!= `wc'-3{
di in red "Vector of values of option 'at' must have length of `wc'!"
error 121
}
mat colnames `M' = `controls' _cons
mat rownames `M' = Values
mat colnames `M3' = `w' `j' `n'
mat rownames `M3' = Values

}
else{
qui mat accum `M'=`controls'   if e(sample) & `touse', means(`M')
qui mat accum `M3'=`w' `j' `n' if e(sample) & `touse', means(`M3')
mat `M3'=`M3'[1,1..colsof(`M3')-1]
}

local i=1
local xbmean=" _b[_cons]"
local xbvar=" _b[_cons]"

if "`controls'"!=""{
foreach m of varlist `controls'{
local add=string(`M'[1,`i'])
local xbmean "`xbmean'+`add'*_b[`m']"
local xbvar "`xbvar'+`m'*_b[`m']"
local i=`i'+1
}
}

if "`average'"!="average" {
local mw=`M3'[1,1] //`M3'[1,1] contains mean value of w
local mj=`M3'[1,2] //`M3'[1,2] contains mean value of j
local mn=`M3'[1,3] //`M3'[1,3] contains mean value of n
}
else{
local mw `w'
local mj `j'
local mn `n'
}


local x11 _b[`j']*1 + _b[`n']*`mn' + _b[`w']*`mw' + _b[`jn']*`mn' + _b[`wj']*`mw' + _b[`wn']*`mn'*`mw' + _b[`jnw']*`mn'*`mw' //erster Term der Ableitung nach x1
local x12 _b[`j']*0 + _b[`n']*`mn' + _b[`w']*`mw' + _b[`jn']*0 + _b[`wj']*0 + _b[`wn']*`mn'*`mw' + _b[`jnw']*0   //zweiter Term der Ableitung nach x1
local x21 _b[`j']*`mj' + _b[`n']*1 + _b[`w']*`mw' + _b[`jn']*`mj' + _b[`wj']*`mw'*`mj' + _b[`wn']*`mw' + _b[`jnw']*`mj'*`mw' //erster Term der Ableitung nach x2
local x22 _b[`j']*`mj' + _b[`n']*0 + _b[`w']*`mw' + _b[`jn']*0 + _b[`wj']*`mw'*`mj' + _b[`wn']*0 + _b[`jnw']*0   //zweiter Term der Ableitung nach x2
local x31 _b[`j']*`mj' + _b[`n']*`mn' + _b[`w']*1 + _b[`jn']*`mj'*`mn' + _b[`wj']*`mj' + _b[`wn']*`mn' + _b[`jnw']*`mj'*`mn' //erster Term der Ableitung nach x3
local x32 _b[`j']*`mj' + _b[`n']*`mn' + _b[`w']*0 + _b[`jn']*`mj'*`mn' + _b[`wj']*0 + _b[`wn']*0 + _b[`jnw']*0   //zweiter Term der Ableitung nach x3

local x121 _b[`j']*1 + _b[`n']*1 + _b[`w']*`mw' + _b[`jn']*1 + _b[`wj']*`mw' + _b[`wn']*`mw' + _b[`jnw']*`mw' 	//erster Term der Abl. nach x1 und x2
local x122 _b[`j']*1 + _b[`n']*0 + _b[`w']*`mw' + _b[`jn']*0 + _b[`wj']*`mw' + _b[`wn']*0 + _b[`jnw']*0 	//zweiter Term der Abl. nach x1 und x2
local x123 _b[`j']*0 + _b[`n']*1 + _b[`w']*`mw' + _b[`jn']*0 + _b[`wj']*0 + _b[`wn']*`mw' + _b[`jnw']*0 	//dritter Term der Abl. nach x1 und x2
local x124 _b[`j']*0 + _b[`n']*0 + _b[`w']*`mw' + _b[`jn']*0 + _b[`wj']*0 + _b[`wn']*0 + _b[`jnw']*0 	//vierter Term der Abl. nach x1 und x2

local x131 _b[`j']*1 + _b[`n']*`mn' + _b[`w']*1 + _b[`jn']*`mn' + _b[`wj']*1 + _b[`wn']*`mn' + _b[`jnw']*`mn' 	//erster Term der Abl. nach x1 und x3
local x132 _b[`j']*1 + _b[`n']*`mn' + _b[`w']*0 + _b[`jn']*`mn' + _b[`wj']*0 + _b[`wn']*0 + _b[`jnw']*0 	//zweiter Term der Abl. nach x1 und x3
local x133 _b[`j']*0 + _b[`n']*`mn' + _b[`w']*1 + _b[`jn']*0 + _b[`wj']*0 + _b[`wn']*`mn' + _b[`jnw']*0 	//dritter Term der Abl. nach x1 und x3
local x134 _b[`j']*0 + _b[`n']*`mn' + _b[`w']*0 + _b[`jn']*0 + _b[`wj']*0 + _b[`wn']*0 + _b[`jnw']*0 	//vierter Term der Abl. nach x1 und x3

local x231 _b[`j']*`mj' + _b[`n']*1 + _b[`w']*1 + _b[`jn']*`mj' + _b[`wj']*`mj' + _b[`wn']*1 + _b[`jnw']*`mj' 	//erster Term der Abl. nach x2 und x3
local x232 _b[`j']*`mj' + _b[`n']*1 + _b[`w']*0 + _b[`jn']*`mj' + _b[`wj']*0 + _b[`wn']*0 + _b[`jnw']*0 	//zweiter Term der Abl. nach x2 und x3
local x233 _b[`j']*`mj' + _b[`n']*0 + _b[`w']*1 + _b[`jn']*0 + _b[`wj']*`mj' + _b[`wn']*0 + _b[`jnw']*0 	//dritter Term der Abl. nach x2 und x3
local x234 _b[`j']*`mj' + _b[`n']*0 + _b[`w']*0 + _b[`jn']*0 + _b[`wj']*0 + _b[`wn']*0 + _b[`jnw']*0 	//vierter Term der Abl. nach x2 und x3

local xb111jnw _b[`j']*1 + _b[`n']*1 + _b[`w']*1 + _b[`jn']*1 + _b[`wj']*1 + _b[`wn']*1 + _b[`jnw']*1       //x1=x2=x3=1
local xb110jnw _b[`j']*1 + _b[`n']*1 + _b[`w']*0 + _b[`jn']*1 + _b[`wj']*0 + _b[`wn']*0 + _b[`jnw']*0 	//x1=x2=1 x3=0
local xb101jnw _b[`j']*1 + _b[`n']*0 + _b[`w']*1 + _b[`jn']*0 + _b[`wj']*1 + _b[`wn']*0 + _b[`jnw']*0 	//x1=x3=1 x2=0
local xb011jnw _b[`j']*0 + _b[`n']*1 + _b[`w']*1 + _b[`jn']*0 + _b[`wj']*0 + _b[`wn']*1 + _b[`jnw']*0      //x2=x3=1 x1=0
local xb001jnw _b[`j']*0 + _b[`n']*0 + _b[`w']*1 + _b[`jn']*0 + _b[`wj']*0 + _b[`wn']*0 + _b[`jnw']*0      //x1=x2=0 x3=1
local xb010jnw _b[`j']*0 + _b[`n']*1 + _b[`w']*0 + _b[`jn']*0 + _b[`wj']*0 + _b[`wn']*0 + _b[`jnw']*0 	//x1=x3=0 x2=1
local xb100jnw _b[`j']*1 + _b[`n']*0 + _b[`w']*0 + _b[`jn']*0 + _b[`wj']*0 + _b[`wn']*0 + _b[`jnw']*0     //x2=x3=0 x1=1
local xb000jnw _b[`j']*0 + _b[`n']*0 + _b[`w']*0 + _b[`jn']*0 + _b[`wj']*0 + _b[`wn']*0 + _b[`jnw']*0    //x1=x2=x3=0


* Ableitungen von ME_j nach allen Koeffizienten b (ohne Variablen hinten dran!)

** Differenz nach der Interaktion aus "jung", "nachher" und "weiblich"

if "`average'"!="average" {

if "`at'"!="" {
	di in green _newline "Marginal effect at following values:"
	mat list `M3'
	mat list `M'
	}
	else {
	di in green _newline "Marginal effect at means of probit estimation sample:"
	}

*Marginal effect w
qui nlcom `F'`x31'+ `xbmean'))) - `F'`x32'+ `xbmean'))), post
mat `V'=e(V)
mat `b'=e(b)
_estimates unhold `probit'
_estimates hold `probit', copy

*Marginal effect j
qui nlcom `F'`x11'+ `xbmean'))) - `F'`x12'+ `xbmean'))) , post
mat `V'=`V',e(V)
mat `b'=`b',e(b)
_estimates unhold `probit'
_estimates hold `probit', copy

*Marginal effect n
qui nlcom `F'`x21'+ `xbmean'))) - `F'`x22'+ `xbmean'))), post
mat `V'=`V',e(V)
mat `b'=`b',e(b)
_estimates unhold `probit'
_estimates hold `probit', copy

*Marginal effect wj
qui nlcom `F'`x131'+ `xbmean'))) - `F'`x132'+ `xbmean'))) - `F'`x133'+ `xbmean'))) + `F'`x134'+ `xbmean'))), post
mat `V'=`V',e(V)
mat `b'=`b',e(b)
_estimates unhold `probit'
_estimates hold `probit', copy

*Marginal effect wn
qui nlcom `F'`x231'+ `xbmean'))) - `F'`x232'+ `xbmean'))) - `F'`x233'+ `xbmean'))) + `F'`x234'+ `xbmean'))), post
mat `V'=`V',e(V)
mat `b'=`b',e(b)
_estimates unhold `probit'
_estimates hold `probit', copy


*Marginal effect jn
qui nlcom `F'`x121'+ `xbmean'))) - `F'`x122'+ `xbmean'))) - `F'`x123'+ `xbmean'))) + `F'`x124'+ `xbmean'))), post
mat `V'=`V',e(V)
mat `b'=`b',e(b)
_estimates unhold `probit'
_estimates hold `probit', copy

*Marginal effect jnw
qui nlcom `F'`xb111jnw'+ `xbmean'))) - `F'`xb110jnw'+ `xbmean'))) - `F'`xb101jnw'+ `xbmean'))) - `F'`xb011jnw'+ `xbmean'))) + 	/*
*/			 `F'`xb001jnw'+ `xbmean'))) + `F'`xb010jnw'+ `xbmean'))) + `F'`xb100jnw'+ `xbmean'))) - `F'`xb000jnw'+ `xbmean'))), post
mat `V'=`V',e(V)
mat `V'=diag(`V')
mat `b'=`b',e(b)
mat rownames `V'=`w' `j' `n' `wj' `wn' `jn' `jnw'
mat colnames `V'=`w' `j' `n' `wj' `wn' `jn' `jnw'
mat colnames `b'=`w' `j' `n' `wj' `wn' `jn' `jnw'
ereturn post `b' `V'
ereturn display
}
else {

di in green _newline "Average marginal effect:"

*Marginal effect w
qui predictnl `dyd' = `F'`x31'+ `xbvar'))) - `F'`x32'+ `xbvar'))) if e(sample) & `touse', se(`ser')
if "`pex1'"!=""{
qui gen `pex1'=`dyd'
}
if "`sx1'"!=""{
qui gen `sx1'=`ser'
}
qui sum `dyd'
drop `dyd' `ser'
mat `b'=r(mean)
mat `VP'=e(V)
if (e(cmd)=="probit") {
qui gen `der`w''= `f'`x31'+ `xbvar')))
qui gen `der`j''=(`f'`x31'+ `xbvar'))) - `f'`x32'+ `xbvar'))))*`j'
qui gen `der`n''= (`f'`x31'+ `xbvar'))) - `f'`x32'+ `xbvar'))))*`n'
qui gen `der`wj''= `f'`x31'+ `xbvar')))*`j'
qui gen `der`wn''= `f'`x31'+ `xbvar')))*`n'
qui gen `der`jn''= (`f'`x31'+ `xbvar'))) - `f'`x32'+ `xbvar'))))*`j'*`n' 
gen `der`jnw''=`f'`x31'+ `xbvar')))*`j'*`n'
local derk (`f'`x31'+ `xbvar'))) - `f'`x32'+ `xbvar'))))
}
if (e(cmd)=="logit") {
qui gen `der`w''=  `F'`x31'+ `xbvar')))*(1-`F'`x31'+ `xbvar'))))
qui gen `der`j''= (`F'`x31'+ `xbvar')))*(1-`F'`x31'+ `xbvar')))) - `F'`x32'+ `xbvar')))*(1-`F'`x32'+ `xbvar')))))*`j'
qui gen `der`n''= (`F'`x31'+ `xbvar')))*(1-`F'`x31'+ `xbvar')))) - `F'`x32'+ `xbvar')))*(1-`F'`x32'+ `xbvar')))))*`n'
qui gen `der`wj''= `F'`x31'+ `xbvar')))*(1-`F'`x31'+ `xbvar'))))*`j'
qui gen `der`wn''= `F'`x31'+ `xbvar')))*(1-`F'`x31'+ `xbvar'))))*`n'
qui gen `der`jn''=(`F'`x31'+ `xbvar')))*(1-`F'`x31'+ `xbvar')))) - `F'`x32'+ `xbvar')))*(1-`F'`x32'+ `xbvar')))))*`j'*`n' 
gen `der`jnw''=`F'`x31'+ `xbvar')))*(1-`F'`x31'+ `xbvar'))))*`j'*`n'
local derk (`F'`x31'+ `xbvar')))*(1-`F'`x31'+ `xbvar')))) - `F'`x32'+ `xbvar')))*(1-`F'`x32'+ `xbvar')))))
}

if "`controls'"!=""{
foreach m of varlist `controls'{
	qui gen `der`m''=`derk'*`m'
	}
}
qui gen `dercons'=`derk'
mata: compute1()
mat `V'=`v'
_estimates unhold `probit'
_estimates hold `probit', copy

*Marginal effect j
qui predictnl `dyd' = `F'`x11'+ `xbvar'))) - `F'`x12'+ `xbvar'))) if e(sample) & `touse', se(`ser')
if "`pex2'"!=""{
qui gen `pex2'=`dyd'
}
if "`sx2'"!=""{
qui gen `sx2'=`ser'
}
qui sum `dyd'
drop `dyd' `ser'
mat `b'=`b',r(mean)
mat `VP'=e(V)
if (e(cmd)=="probit") {
qui replace `der`w''= (`f'`x11'+ `xbvar'))) - `f'`x12'+ `xbvar'))))*`w'
qui replace `der`j''= `f'`x11'+ `xbvar')))
qui replace `der`n''= (`f'`x11'+ `xbvar'))) - `f'`x12'+ `xbvar'))))*`n'
qui replace `der`wj''= `f'`x11'+ `xbvar')))*`w'
qui replace `der`wn''=(`f'`x11'+ `xbvar'))) - `f'`x12'+ `xbvar'))))*`w'*`n'
qui replace `der`jn''=`f'`x11'+ `xbvar')))*`n'
qui replace `der`jnw''=`f'`x11'+ `xbvar')))*`w'*`n'
local derk (`f'`x11'+ `xbvar'))) - `f'`x12'+ `xbvar'))))
}
if (e(cmd)=="logit") {
qui replace `der`w''= (`F'`x11'+ `xbvar')))*(1-`F'`x11'+ `xbvar')))) - `F'`x12'+ `xbvar')))*(1-`F'`x12'+ `xbvar')))))*`w'
qui replace `der`j''=  `F'`x11'+ `xbvar')))*(1-`F'`x11'+ `xbvar'))))
qui replace `der`n''= (`F'`x11'+ `xbvar')))*(1-`F'`x11'+ `xbvar')))) - `F'`x12'+ `xbvar')))*(1-`F'`x12'+ `xbvar')))))*`n'
qui replace `der`wj''= `F'`x11'+ `xbvar')))*(1-`F'`x11'+ `xbvar'))))*`w'
qui replace `der`wn''=(`F'`x11'+ `xbvar')))*(1-`F'`x11'+ `xbvar')))) - `F'`x12'+ `xbvar')))*(1-`F'`x12'+ `xbvar')))))*`w'*`n'
qui replace `der`jn''= `F'`x11'+ `xbvar')))*(1-`F'`x11'+ `xbvar'))))*`n'
qui replace `der`jnw''=`F'`x11'+ `xbvar')))*(1-`F'`x11'+ `xbvar'))))*`w'*`n'
local derk (`F'`x11'+ `xbvar')))*(1-`F'`x11'+ `xbvar')))) - `F'`x12'+ `xbvar')))*(1-`F'`x12'+ `xbvar')))))
}

if "`controls'"!=""{
foreach m of varlist `controls'{
	qui replace `der`m''=`derk'*`m'
	}
}
qui replace `dercons'=`derk'
mata: compute1()
mat `V'=`V',`v'
_estimates unhold `probit'
_estimates hold `probit', copy

*Marginal effect n
qui predictnl `dyd' = `F'`x21'+ `xbvar'))) - `F'`x22'+ `xbvar')))  if e(sample) & `touse', se(`ser')
if "`pex3'"!=""{
qui gen `pex3'=`dyd'
}
if "`sx3'"!=""{
qui gen `sx3'=`ser'
}
qui sum `dyd'
drop `dyd' `ser'
mat `b'=`b',r(mean)
mat `VP'=e(V)
if (e(cmd)=="probit") {
qui replace `der`w''=(`f'`x21'+ `xbvar'))) - `f'`x22'+ `xbvar'))))*`w'
qui replace `der`j''=(`f'`x21'+ `xbvar'))) - `f'`x22'+ `xbvar'))))*`j'
qui replace `der`n''=`f'`x21'+ `xbvar')))
qui replace `der`wj''=(`f'`x21'+ `xbvar'))) - `f'`x22'+ `xbvar'))))*`w'*`j'
qui replace `der`wn''=`f'`x21'+ `xbvar')))*`w'
qui replace `der`jn''=`f'`x21'+ `xbvar')))*`j'
qui replace `der`jnw''=`f'`x21'+ `xbvar')))*`w'*`j'
local derk (`f'`x21'+ `xbvar'))) - `f'`x22'+ `xbvar'))))
}
if (e(cmd)=="logit") {
qui replace `der`w''= (`F'`x21'+ `xbvar')))*(1-`F'`x21'+ `xbvar')))) - `F'`x22'+ `xbvar')))*(1-`F'`x22'+ `xbvar')))))*`w'
qui replace `der`j''= (`F'`x21'+ `xbvar')))*(1-`F'`x21'+ `xbvar')))) - `F'`x22'+ `xbvar')))*(1-`F'`x22'+ `xbvar')))))*`j'
qui replace `der`n''=  `F'`x21'+ `xbvar')))*(1-`F'`x21'+ `xbvar'))))
qui replace `der`wj''=(`F'`x21'+ `xbvar')))*(1-`F'`x21'+ `xbvar')))) - `F'`x22'+ `xbvar')))*(1-`F'`x22'+ `xbvar')))))*`w'*`j'
qui replace `der`wn''= `F'`x21'+ `xbvar')))*(1-`F'`x21'+ `xbvar'))))*`w'
qui replace `der`jn''= `F'`x21'+ `xbvar')))*(1-`F'`x21'+ `xbvar'))))*`j'
qui replace `der`jnw''=`F'`x21'+ `xbvar')))*(1-`F'`x21'+ `xbvar'))))*`w'*`j'
local derk (`F'`x21'+ `xbvar')))*(1-`F'`x21'+ `xbvar')))) - `F'`x22'+ `xbvar')))*(1-`F'`x22'+ `xbvar')))))
}

if "`controls'"!=""{
foreach m of varlist `controls'{
	qui replace `der`m''=`derk'*`m'
	}
}
qui replace `dercons'=`derk'
mata: compute1()
mat `V'=`V',`v'
_estimates unhold `probit'
_estimates hold `probit', copy

*Marginal effect wj
qui predictnl `dyd' =`F'`x131'+ `xbvar'))) - `F'`x132'+ `xbvar'))) - `F'`x133'+ `xbvar'))) + `F'`x134'+ `xbvar'))) if e(sample) & `touse', se(`ser')
if "`pex1x2'"!=""{
qui gen `pex1x2'=`dyd'
}
if "`sx1x2'"!=""{
qui gen `sx1x2'=`ser'
}
qui sum `dyd'
drop `dyd' `ser'
mat `b'=`b',r(mean)
mat `VP'=e(V)
if (e(cmd)=="probit") {
qui replace `der`w''=(`f'`x131'+ `xbvar')))- `f'`x133'+ `xbvar'))))
qui replace `der`j''=(`f'`x131'+ `xbvar')))- `f'`x132'+ `xbvar'))))
qui replace `der`n''= (`f'`x131'+ `xbvar'))) - `f'`x132'+ `xbvar'))) - `f'`x133'+ `xbvar'))) + `f'`x134'+ `xbvar'))))*`n'
qui replace `der`wj''=`f'`x131'+ `xbvar')))
qui replace `der`wn''=(`f'`x131'+ `xbvar'))) - `f'`x133'+ `xbvar'))))*`n'
qui replace `der`jn''=(`f'`x131'+ `xbvar'))) - `f'`x132'+ `xbvar'))))*`n'
qui replace `der`jnw''=`f'`x131'+ `xbvar')))*`n'
local derk (`f'`x131'+ `xbvar'))) - `f'`x132'+ `xbvar'))) - `f'`x133'+ `xbvar'))) + `f'`x134'+ `xbvar'))))
}
if (e(cmd)=="logit") {
qui replace `der`w''= (`F'`x131'+ `xbvar')))*(1-`F'`x131'+ `xbvar'))))- `F'`x133'+ `xbvar')))*(1-`F'`x133'+ `xbvar')))))
qui replace `der`j''= (`F'`x131'+ `xbvar')))*(1-`F'`x131'+ `xbvar'))))- `F'`x132'+ `xbvar')))*(1-`F'`x132'+ `xbvar')))))
qui replace `der`n''= (`F'`x131'+ `xbvar')))*(1-`F'`x131'+ `xbvar'))))- `F'`x132'+ `xbvar')))*(1-`F'`x132'+ `xbvar')))) - `F'`x133'+ `xbvar')))*(1-`F'`x133'+ `xbvar')))) + `F'`x134'+ `xbvar')))*(1-`F'`x134'+ `xbvar')))))*`n'
qui replace `der`wj''= `F'`x131'+ `xbvar')))*(1-`F'`x131'+ `xbvar'))))
qui replace `der`wn''=(`F'`x131'+ `xbvar')))*(1-`F'`x131'+ `xbvar'))))- `F'`x133'+ `xbvar')))*(1-`F'`x133'+ `xbvar')))))*`n'
qui replace `der`jn''=(`F'`x131'+ `xbvar')))*(1-`F'`x131'+ `xbvar'))))- `F'`x132'+ `xbvar')))*(1-`F'`x132'+ `xbvar')))))*`n'
qui replace `der`jnw''=`F'`x131'+ `xbvar')))*(1-`F'`x131'+ `xbvar'))))*`n'
local derk (`F'`x131'+ `xbvar')))*(1-`F'`x131'+ `xbvar')))) - `F'`x132'+ `xbvar')))*(1-`F'`x132'+ `xbvar')))) - `F'`x133'+ `xbvar')))*(1-`F'`x133'+ `xbvar')))) + `F'`x134'+ `xbvar')))*(1-`F'`x134'+ `xbvar')))))
}

if "`controls'"!=""{
foreach m of varlist `controls'{
	qui replace `der`m''=`derk'*`m'
	}
}
qui replace `dercons'=`derk'
mata: compute1()
mat `V'=`V',`v'
_estimates unhold `probit'
_estimates hold `probit', copy

*Marginal effect wn
qui predictnl `dyd' = `F'`x231'+ `xbvar'))) - `F'`x232'+ `xbvar'))) - `F'`x233'+ `xbvar'))) + `F'`x234'+ `xbvar'))) if e(sample) & `touse', se(`ser')
if "`pex1x3'"!=""{
qui gen `pex1x3'=`dyd'
}
if "`sx1x3'"!=""{
qui gen `sx1x3'=`ser'
}
qui sum `dyd'
drop `dyd' `ser'
mat `b'=`b',r(mean)
mat `VP'=e(V)
if (e(cmd)=="probit") {
qui replace `der`w''=(`f'`x231'+ `xbvar'))) - `f'`x233'+ `xbvar'))))
qui replace `der`j''=(`f'`x231'+ `xbvar'))) - `f'`x232'+ `xbvar'))) - `f'`x233'+ `xbvar'))) + `f'`x234'+ `xbvar'))))*`j'
qui replace `der`n''= (`f'`x231'+ `xbvar'))) - `f'`x232'+ `xbvar'))))
qui replace `der`wj''= (`f'`x231'+ `xbvar'))) - `f'`x233'+ `xbvar'))))*`j'
qui replace `der`wn''= `f'`x231'+ `xbvar')))
qui replace `der`jn''= (`f'`x231'+ `xbvar'))) - `f'`x232'+ `xbvar'))))*`j'
qui replace `der`jnw''=`f'`x231'+ `xbvar')))*`j'
local derk (`f'`x231'+ `xbvar'))) - `f'`x232'+ `xbvar'))) - `f'`x233'+ `xbvar'))) + `f'`x234'+ `xbvar'))))
}
if (e(cmd)=="logit") {
qui replace `der`w''= (`F'`x231'+ `xbvar')))*(1-`F'`x231'+ `xbvar')))) - `F'`x233'+ `xbvar')))*(1-`F'`x233'+ `xbvar')))))
qui replace `der`j''= (`F'`x231'+ `xbvar')))*(1-`F'`x231'+ `xbvar')))) - `F'`x232'+ `xbvar')))*(1-`F'`x232'+ `xbvar')))) - `F'`x233'+ `xbvar')))*(1-`F'`x233'+ `xbvar')))) + `F'`x234'+ `xbvar')))*(1-`F'`x234'+ `xbvar')))))*`j'
qui replace `der`n''= (`F'`x231'+ `xbvar')))*(1-`F'`x231'+ `xbvar')))) - `F'`x232'+ `xbvar')))*(1-`F'`x232'+ `xbvar')))))
qui replace `der`wj''=(`F'`x231'+ `xbvar')))*(1-`F'`x231'+ `xbvar')))) - `F'`x233'+ `xbvar')))*(1-`F'`x233'+ `xbvar')))))*`j'
qui replace `der`wn''= `F'`x231'+ `xbvar')))*(1-`F'`x231'+ `xbvar'))))
qui replace `der`jn''=(`F'`x231'+ `xbvar')))*(1-`F'`x231'+ `xbvar')))) - `F'`x232'+ `xbvar')))*(1-`F'`x232'+ `xbvar')))))*`j'
qui replace `der`jnw''=`F'`x231'+ `xbvar')))*(1-`F'`x231'+ `xbvar'))))*`j'
local derk (`F'`x231'+ `xbvar')))*(1-`F'`x231'+ `xbvar')))) - `F'`x232'+ `xbvar')))*(1-`F'`x232'+ `xbvar')))) - `F'`x233'+ `xbvar')))*(1-`F'`x233'+ `xbvar')))) + `F'`x234'+ `xbvar')))*(1-`F'`x234'+ `xbvar')))))
}
if "`controls'"!=""{
foreach m of varlist `controls'{
	qui replace `der`m''=`derk'*`m'
	}
}
qui replace `dercons'=`derk'
mata: compute1()
mat `V'=`V',`v'
_estimates unhold `probit'
_estimates hold `probit', copy

*Marginal effect jn
qui predictnl `dyd'=`F'`x121'+ `xbvar'))) - `F'`x122'+ `xbvar'))) - `F'`x123'+ `xbvar'))) + `F'`x124'+ `xbvar'))) if e(sample) & `touse', se(`ser')
if "`pex2x3'"!=""{
qui gen `pex2x3'=`dyd'
}
if "`sx2x3'"!=""{
qui gen `sx2x3'=`ser'
}
qui sum `dyd'
drop `dyd' `ser'
mat `b'=`b',r(mean)
mat `VP'=e(V)
if (e(cmd)=="probit") {
qui replace `der`w''= (`f'`x121'+ `xbvar'))) - `f'`x122'+ `xbvar'))) - `f'`x123'+ `xbvar'))) + `f'`x124'+ `xbvar'))))*`w'
qui replace `der`j''= (`f'`x121'+ `xbvar'))) - `f'`x122'+ `xbvar'))))
qui replace `der`n''=(`f'`x121'+ `xbvar')))- `f'`x123'+ `xbvar'))))
qui replace `der`wj''=(`f'`x121'+ `xbvar'))) - `f'`x122'+ `xbvar'))))*`w'
qui replace `der`wn''=(`f'`x121'+ `xbvar')))  - `f'`x123'+ `xbvar'))))*`w'
qui replace `der`jn''=`f'`x121'+ `xbvar')))
qui replace `der`jnw''=`f'`x121'+ `xbvar')))*`w'
local derk (`f'`x121'+ `xbvar'))) - `f'`x122'+ `xbvar'))) - `f'`x123'+ `xbvar'))) + `f'`x124'+ `xbvar'))))
}
if (e(cmd)=="logit") {
qui replace `der`w''= (`F'`x121'+ `xbvar')))*(1-`F'`x121'+ `xbvar'))))- `F'`x122'+ `xbvar')))*(1-`F'`x122'+ `xbvar')))) - `F'`x123'+ `xbvar')))*(1-`F'`x123'+ `xbvar')))) + `F'`x124'+ `xbvar')))*(1-`F'`x124'+ `xbvar')))))*`w'
qui replace `der`j''= (`F'`x121'+ `xbvar')))*(1-`F'`x121'+ `xbvar'))))- `F'`x122'+ `xbvar')))*(1-`F'`x122'+ `xbvar')))))
qui replace `der`n''= (`F'`x121'+ `xbvar')))*(1-`F'`x121'+ `xbvar'))))- `F'`x123'+ `xbvar')))*(1-`F'`x123'+ `xbvar')))))
qui replace `der`wj''=(`F'`x121'+ `xbvar')))*(1-`F'`x121'+ `xbvar'))))- `F'`x122'+ `xbvar')))*(1-`F'`x122'+ `xbvar')))))*`w'
qui replace `der`wn''=(`F'`x121'+ `xbvar')))*(1-`F'`x121'+ `xbvar'))))- `F'`x123'+ `xbvar')))*(1-`F'`x123'+ `xbvar')))))*`w'
qui replace `der`jn''= `F'`x121'+ `xbvar')))*(1-`F'`x121'+ `xbvar'))))
qui replace `der`jnw''=`F'`x121'+ `xbvar')))*(1-`F'`x121'+ `xbvar'))))*`w'
local derk (`F'`x121'+ `xbvar')))*(1-`F'`x121'+ `xbvar')))) - `F'`x122'+ `xbvar')))*(1-`F'`x122'+ `xbvar')))) - `F'`x123'+ `xbvar')))*(1-`F'`x123'+ `xbvar')))) + `F'`x124'+ `xbvar')))*(1-`F'`x124'+ `xbvar')))))
}

if "`controls'"!=""{
foreach m of varlist `controls'{
	qui replace `der`m''=`derk'*`m'
	}
}
qui replace `dercons'=`derk'
mata: compute1()
mat `V'=`V',`v'
_estimates unhold `probit'
_estimates hold `probit', copy

qui predictnl `dyd' = `F'`xb111jnw'+ `xbvar'))) - `F'`xb110jnw'+ `xbvar'))) - `F'`xb101jnw'+ `xbvar'))) - `F'`xb011jnw'+ `xbvar'))) + 	/*
*/			 `F'`xb001jnw'+ `xbvar'))) + `F'`xb010jnw'+ `xbvar'))) + `F'`xb100jnw'+ `xbvar'))) - `F'`xb000jnw'+ `xbvar'))) if e(sample) & `touse', se(`ser')

if "`pex1x2x3'"!=""{
qui gen `pex1x2x3'=`dyd'
}
if "`sx1x2x3'"!=""{
qui gen `sx1x2x3'=`ser'
}
qui sum `dyd'
drop `dyd' `ser'
mat `b'=`b',r(mean)
mat `VP'=e(V)
if (e(cmd)=="probit") {
qui replace `der`w''=(`f'`xb111jnw'+ `xbvar')))- `f'`xb101jnw'+ `xbvar'))) - `f'`xb011jnw'+ `xbvar')))+ `f'`xb001jnw'+ `xbvar'))))
qui replace `der`j''=(`f'`xb111jnw'+ `xbvar')))- `f'`xb101jnw'+ `xbvar')))- `f'`xb110jnw'+ `xbvar'))) +`f'`xb100jnw'+ `xbvar'))))
qui replace `der`n''=(`f'`xb111jnw'+ `xbvar')))- `f'`xb011jnw'+ `xbvar'))) - `f'`xb110jnw'+ `xbvar')))+ `f'`xb010jnw'+ `xbvar'))))
qui replace `der`wj''=(`f'`xb111jnw'+ `xbvar')))- `f'`xb101jnw'+ `xbvar'))))
qui replace `der`wn''=(`f'`xb111jnw'+ `xbvar')))- `f'`xb011jnw'+ `xbvar'))))
qui replace `der`jn''=( `f'`xb111jnw'+ `xbvar')))- `f'`xb110jnw'+ `xbvar'))))
qui replace `der`jnw''=`f'`xb111jnw'+ `xbvar')))
local derk1 (`f'`xb111jnw'+ `xbvar')))- `f'`xb101jnw'+ `xbvar'))) - `f'`xb011jnw'+ `xbvar'))) -`f'`xb110jnw'+ `xbvar'))))
local derk2 (`f'`xb010jnw'+ `xbvar'))) +`f'`xb100jnw'+ `xbvar'))) + `f'`xb001jnw'+ `xbvar'))) -`f'`xb000jnw'+ `xbvar'))))

}
if (e(cmd)=="logit") {
qui replace `der`w''=(`F'`xb111jnw'+ `xbvar')))*(1-`F'`xb111jnw'+ `xbvar'))))- `F'`xb101jnw'+ `xbvar')))*(1-`F'`xb101jnw'+ `xbvar'))))- `F'`xb011jnw'+ `xbvar')))*(1-`F'`xb011jnw'+ `xbvar'))))+ `F'`xb001jnw'+ `xbvar')))*(1-`F'`xb001jnw'+ `xbvar')))))
qui replace `der`j''=(`F'`xb111jnw'+ `xbvar')))*(1-`F'`xb111jnw'+ `xbvar'))))- `F'`xb101jnw'+ `xbvar')))*(1-`F'`xb101jnw'+ `xbvar'))))- `F'`xb110jnw'+ `xbvar')))*(1-`F'`xb110jnw'+ `xbvar'))))+ `F'`xb100jnw'+ `xbvar')))*(1-`F'`xb100jnw'+ `xbvar')))))
qui replace `der`n''=(`F'`xb111jnw'+ `xbvar')))*(1-`F'`xb111jnw'+ `xbvar'))))- `F'`xb011jnw'+ `xbvar')))*(1-`F'`xb011jnw'+ `xbvar'))))- `F'`xb110jnw'+ `xbvar')))*(1-`F'`xb110jnw'+ `xbvar'))))+ `F'`xb010jnw'+ `xbvar')))*(1-`F'`xb010jnw'+ `xbvar')))))
qui replace `der`wj''=(`F'`xb111jnw'+ `xbvar')))*(1-`F'`xb111jnw'+ `xbvar'))))- `F'`xb101jnw'+ `xbvar')))*(1-`F'`xb101jnw'+ `xbvar')))))
qui replace `der`wn''=(`F'`xb111jnw'+ `xbvar')))*(1-`F'`xb111jnw'+ `xbvar'))))- `F'`xb011jnw'+ `xbvar')))*(1-`F'`xb011jnw'+ `xbvar')))))
qui replace `der`jn''=(`F'`xb111jnw'+ `xbvar')))*(1-`F'`xb111jnw'+ `xbvar'))))- `F'`xb110jnw'+ `xbvar')))*(1-`F'`xb110jnw'+ `xbvar')))))
qui replace `der`jnw''=`F'`xb111jnw'+ `xbvar')))*(1-`F'`xb111jnw'+ `xbvar'))))
local derk1 (`F'`xb111jnw'+ `xbvar')))*(1-`F'`xb111jnw'+ `xbvar'))))- `F'`xb101jnw'+ `xbvar')))*(1-`F'`xb101jnw'+ `xbvar')))) - `F'`xb011jnw'+ `xbvar')))*(1-`F'`xb011jnw'+ `xbvar')))) -`F'`xb110jnw'+ `xbvar')))*(1-`F'`xb110jnw'+ `xbvar')))))
local derk2 (`F'`xb010jnw'+ `xbvar')))*(1-`F'`xb010jnw'+ `xbvar'))))+ `F'`xb100jnw'+ `xbvar')))*(1-`F'`xb100jnw'+ `xbvar')))) + `F'`xb001jnw'+ `xbvar')))*(1-`F'`xb001jnw'+ `xbvar')))) -`F'`xb000jnw'+ `xbvar')))*(1-`F'`xb000jnw'+ `xbvar')))))

}

if "`controls'"!=""{
foreach m of varlist `controls'{
	qui replace `der`m''=`derk1'*`m'
	qui replace `der`m''=`der`m''+`derk2'*`m'
	}
}
qui replace `dercons'=`derk1'
qui replace `dercons'=`dercons'+`derk1'
mata: compute1()
mat `V'=`V',`v'
mat `V'=diag(`V')
mat rownames `V'=`w' `j' `n' `wj' `wn' `jn' `jnw'
mat colnames `V'=`w' `j' `n' `wj' `wn' `jn' `jnw'
mat colnames `b'=`w' `j' `n' `wj' `wn' `jn' `jnw'
ereturn post `b' `V'
ereturn display
}

if "`post'"!="post" {
_estimates unhold `probit'
}

if "`pex1' `pex2' `pex3' `pex1x2' `pex1x3' `pex2x3' `pex1x2x3' `sx1' `sx2' `sx3' `sx1x2' `sx1x3' `sx2x3' `sx1x2x3'"~="             " mata: save("`pex1' `pex2' `pex3' `pex1x2' `pex1x3' `pex2x3' `pex1x2x3' `sx1' `sx2' `sx3' `sx1x2' `sx1x3' `sx2x3' `sx1x2x3'")
end

mata:
void compute1()
{
firstindex=st_varindex(st_macroexpand("`"+"der"+"`"+"w"+"'"+"'"))
lastindex=st_varindex(st_macroexpand("`"+"dercons"+"'"))
st_view(X,.,range(firstindex,lastindex,1)')
V=st_matrix(st_macroexpand("`"+"VP"+"'"))
a=J(1,rows(X),1)
z=a*X*V*X'*a'/rows(X)^2
st_local("v",strofreal(z))
}

void compute2()
{
firstindex=st_varindex(st_macroexpand("`"+"der"+"`"+"w"+"'"+"'"))
lastindex=st_varindex(st_macroexpand("`"+"dercons"+"'"))
st_view(X,.,range(firstindex,lastindex,1)')
V=st_matrix(st_macroexpand("`"+"VP"+"'"))
z=0
for (i=1; i<=rows(X);i++) {
for (l=1; l<=i;l++) {
	if (i==l){
		z=z+X[i,.]*V*X[l,.]'
		}
	else{
		z=z+2*X[i,.]*V*X[l,.]'
		}
	}
	}
z=z/rows(X)^2
st_local("v",strofreal(z))
}

void save(string scalar storenames)
{
M=st_data(.,tokens(storenames))
stata("restore")
(void) st_addvar("double",tokens(storenames))
st_store(.,tokens(storenames),st_varindex(st_macroexpand("`"+"sample"+"'")),M)
}

end

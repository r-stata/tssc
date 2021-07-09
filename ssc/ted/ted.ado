*************************************************************************
* PROGRAM "TED"
* Date: 04/11/2016
* Author: Giovanni Cerulli
* Used for the paper:
* "Testing Stability of Regression Discontinuity Models"
* by G. Cerulli, Y. Dong, A. Lewbel, and A. Poulsen (2016)
*************************************************************************

*************************************************************************
* PROGRAM FOR VARIOUS KERNELS GENERATION: "_Kernel_"
*************************************************************************
cap program drop _Kernel_
program define _Kernel_
	args kernel weight dif bwidth
	if ("`kernel'"=="epan") {
		qui g double `weight' = 1 - (`dif'/`bwidth')^2 if abs(`dif')<=`bwidth'
	}
	else if ("`kernel'"=="normal") {
		qui g double `weight' = normalden(`dif'/`bwidth')
	}
	else if ("`kernel'"=="biweight") {
		qui g double `weight' = (1 - (`dif'/`bwidth')^2)^2 if abs(`dif')<=`bwidth'
	}
	else if ("`kernel'"=="uniform") {
		qui g double `weight' = 1 if abs(`dif')<=`bwidth'
	}
	else if ("`kernel'"=="triangular") {
		qui g double `weight' = (1-abs(`dif'/`bwidth')) if abs(`dif')<=`bwidth'
	}	
	else if ("`kernel'"=="tricube") {
		qui g double `weight' = (1-abs(`dif'/`bwidth')^3)^3 if abs(`dif')<=`bwidth'
	}
	// normalize sum of weights to 1
	sum `weight', mean
	replace `weight' = `weight'/r(sum)
end
*************************************************************************
* PROGRAM "ted"
*************************************************************************
*! ted v2.0.0 GCerulli 29apr2016
capture program drop ted
program ted, eclass
version 13
#delimit;     
syntax varlist [if] [in] [fweight iweight pweight] [,
model(string)
h(numlist max=1)
c(numlist max=1)
m(numlist max=1 integer)
l(numlist max=1)
k(string)
vce(string)
graph
save_graph_o(string)
save_graph_p(string)
];
#delimit cr
************************************************************
if "`model'"=="sharp"{
marksample touse
tokenize `varlist'
local y `1'  // outcome
local s `2'  // running variable
local w `3'
macro shift
macro shift
macro shift
local xvars `*'
*************************************************************
cap drop _x
gen _x=`s'-`c' // demeaned forcing variable
la var _x "Running variable (centered at zero)" 
*************************************************************
la var `w' "Binary treatment variable"
la var `s' "Uncentered running variable"
la var `y' "Outcome variable"
*************************************************************
* GENERATE _T=1(s>s_star)
*************************************************************
cap drop _T
gen _T=(`s'>=`c')
la var _T "1[S > S*] = above-threshold variable"
*************************************************************************
* Generate the polynomial factors
*************************************************************
forvalues j=1/`m'{
cap drop _x_`j'
}
forvalues j=1/`m'{
gen _x_`j'=(_x)^(`j')
la var _x_`j' "Polynomial term for running variable of degree `j'"  
}

forvalues j=1/`m'{
cap drop _T_x_`j'  
}
forvalues j=1/`m'{
gen _T_x_`j'=_T*(_x)^(`j')
la var _T_x_`j' "Interaction between running and above-threshold. Polynomial degree `j'"  
}

local xvars
forvalues j=1/`m'{
local xvars `xvars' _x_`j'  
}

local Txvars
forvalues j=1/`m'{
local Txvars `Txvars' _T_x_`j'  
}
*************************************************************************
* COMPUTATION OF DISCONTINUITY IN THE OUTCOME 
*************************************************************************
* GENERATE KERNEL WEIGHTS ("weight")
*************************************************************************
tempvar _weight
_Kernel_ `k' `_weight' _x `h'
*************************************************************************
* LOCAL KERNEL POLYNOMIAL REGRESSION OF DEGREE "m"
* (AROUND THE CUT-OFF s*, WITH BANDWIDTH "b")
*************************************************************************
di as text ""
di as text "{hline}"
di as text "{bf:******************************************************************************}"
di as text "{bf:************************ DISCONTINUITY IN THE OUTCOME ************************}"
di as text "{bf:******************************************************************************}"
reg `y' `xvars' _T `Txvars' [pw=`_weight'] if _x>=-`h' & _x<=`h' & `touse', `vce'
scalar size_o=r(N)
*************************************************************************
* RETURNED SCALARS
*************************************************************************
scalar alfaO0=_b[_cons]        // left regression intercept at cut-off
scalar alfaO1=_b[_T]+alfaO0    // right regression intercept at cut-off
scalar gammaO0=_b[_T]          // discontinuity in the outcome at cut-off
scalar gammaO1=_b[_T_x_1]      // discontinuity in derivative at cut-off
scalar betaO0=_b[_x_1]         // left slope at cut-off
scalar betaO1=betaO0+gammaO1   // right slope at cut-off
global gammaO1=_b[_T_x_1]
*************************************************************************
* Calculate (again) the discontinuity in the outcome ("disc_y")
*************************************************************************
scalar disc_y = _b[_T]
*************************************************************************
* Prediction of the polynomial fit ("y_hat")
*************************************************************************
tempvar y_hat1
predict `y_hat1' if _T==1, xb 
tempvar y_hat0 
predict `y_hat0' if _T==0 , xb 
replace `y_hat0'=alfaO0 if _x==0 & _T==0
*************************************************************************
* GENERATE THE LEFT ("0") AND THE RIGHT ("1") TANGENTS AT CUT-OFF
*************************************************************************
tempvar y_tang1
gen `y_tang1' = alfaO1 + betaO1*_x 
tempvar y_tang0
gen `y_tang0' = alfaO0 + betaO0*_x
*************************************************************************
* GRAPH OUTCOME DISCONTINUITY WITH TANGENTS
*************************************************************************
if "`graph'"=="graph"{
* RIGHT
tempvar grid_r points_r
lpoly `y' _x if _x>=0 & _x<=`h' & `touse', kernel(rect) at(_x) gen(`grid_r' `points_r')  degree(0) bwidth(1)  noscatter  nograph
* LEFT
tempvar grid_l points_l 
lpoly `y' _x if _x<=0 & _x>=-`h' & `touse', kernel(rect) at(_x) gen(`grid_l' `points_l') degree(0) bwidth(1)  noscatter  nograph
graph twoway ///
   (scatter  `points_r' `grid_r' if _x >0 & _x<`l' & `touse', msymbol(o)) ///
   (scatter  `points_l' `grid_l' if _x >-`l' & _x<=0 & `touse', msymbol(oh)) ///
   (line `y_tang1' _x  if _x>=0 & _x<=`h'  & _x >-`l' & _x<`l' & `touse', lcolor(gs10) lpattern(solid) ) ///
   (mspline `y_hat1' _x    if _T==1 & _x>=0 & _x<=`h'  & _x >-`l' & _x<`l' & `touse', lcolor(gs0) lpattern(solid)) ///
   (line `y_tang0' _x  if _x<=0 & _x>=-`h' & _x >-`l' & _x<`l' & `touse', lcolor(gs10) lpattern(solid))  ///
   (mspline `y_hat0' _x    if _T==0 & _x<=0 & _x>=-`h' & _x >-`l' & _x<`l' & `touse', lcolor(gs0) lpattern(solid)) ,  ///
   legend(on order(1 2 3 4) label(1 "Right local means") label(2 "Left local means" ) label(3 "Tangent" ) label(4 "Prediction" ))   ///
    xline(0, lpattern(dash))  ///
	ylabel(,labsize(small)) ///
	xlabel(-`l' +`l') ///
	xtitle("Running variable", size(small)) ///
	ytitle("Outcome") ///
	scheme(s2mono) graphregion(fcolor(white)) ///
	title("Fuzzy RD, KLPR, Outcome discontinuity" , size(medium)) ///
	legend(size(small)) ///
	xlabel(,labsize(small)) ///
	ylabel(,labsize(small)) ///
	note("KLPR = Kernel Local Polynomial Regression" "Kernel = `k'" "Bandwidth value = `h'" ///
	"Polynomial degree = `m'")
if "`save_graph_o'"!=""{	
graph save `save_graph_o' , replace
}
}
*************************************************************************
* TEST OF SIGNIFICANCE FOR "LATE"
*************************************************************************
qui reg `y' `xvars' _T `Txvars' [pw=`_weight'] if _x>=-`h' & _x<=`h' & `touse' , `vce'
di as text "{hline}"
di as text "{bf:************************ Test of significance for LATE ***********************}"
nlcom (LATE: _b[_T])
*************************************************************************
* TEST OF SIGNIFICANCE FOR "TED"
*************************************************************************
di as text "{hline}"
di as text "{bf:************************ Test of significance for TED ************************}"
nlcom (TED: _b[_T_x_1])
*************************************************************************
*************************************************************************
* CALCULATE "LATE"
*************************************************************************
ereturn scalar LATE=disc_y
*************************************************************************	
* CALCULATE "TED"
*************************************************************************
ereturn scalar TED=_b[_T_x_1]
*** Number of (used) treated and untreated units ************************
qui sum `w' if e(sample)
ereturn scalar N_tot=r(sum_w)
qui sum `w' if e(sample) & `w'==1
ereturn scalar N_treated=r(sum_w)
qui sum `w' if e(sample) & `w'==0
ereturn scalar N_untreated=r(sum_w)
}
*************************************************************************
* FUZZY
*************************************************************************
else if "`model'"=="fuzzy"{
marksample touse
tokenize `varlist'
local y `1'  // outcome
local s `2'  // running variable
local w `3'
macro shift
macro shift
macro shift
local xvars `*'
*************************************************************
cap drop _x
gen _x=`s'-`c' // demeaned forcing variable 
la var _x "Running variable (centered at zero)"
*************************************************************
la var `w' "Binary treatment variable"
la var `s' "Uncentered running variable"
la var `y' "Outcome variable"
*************************************************************
* GENERATE _T=1(s>s_star)
*************************************************************
cap drop _T
gen _T=(`s'>=`c')
la var _T "1[S > S*] = above-threshold indicator"
*************************************************************************
* Generate the polynomial factors
*************************************************************
forvalues j=1/`m'{
cap drop _x_`j'
}
forvalues j=1/`m'{
gen _x_`j'=(_x)^(`j')
la var _x_`j' "Polynomial term for running variable of degree `j'"  
}

forvalues j=1/`m'{
cap drop _T_x_`j'  
}
forvalues j=1/`m'{
gen _T_x_`j'=_T*(_x)^(`j') 
la var _T_x_`j' "Interaction between running and above-threshold. Polynomial degree `j'" 
}

local xvars
forvalues j=1/`m'{
local xvars `xvars' _x_`j'  
}

local Txvars
forvalues j=1/`m'{
local Txvars `Txvars' _T_x_`j'  
}
*************************************************************************
* COMPUTATION OF DISCONTINUITY IN THE OUTCOME 
*************************************************************************
* GENERATE KERNEL WEIGHTS ("weight")
*************************************************************************
tempvar _weightO
_Kernel_ `k' `_weightO' _x `h'
*************************************************************************
* LOCAL KERNEL POLYNOMIAL REGRESSION OF DEGREE "m"
* (AROUND THE CUT-OFF s*, WITH BANDWIDTH "b")
*************************************************************************
di as text ""
di as text "{hline}"
di as text "{bf:******************************************************************************}"
di as text "{bf:************************ DISCONTINUITY IN THE OUTCOME ************************}"
di as text "{bf:******************************************************************************}"
reg `y' `xvars' _T `Txvars' [pw=`_weightO'] if _x>=-`h' & _x<=`h' & `touse', `vce'
*estimates store my
scalar size_o=r(N)
*************************************************************************
* RETURNED SCALARS
*************************************************************************
scalar alfaO0=_b[_cons]        // left regression intercept at cut-off
scalar alfaO1=_b[_T]+alfaO0    // right regression intercept at cut-off
scalar gammaO0=_b[_T]          // discontinuity in the outcome at cut-off
scalar gammaO1=_b[_T_x_1]      // discontinuity in derivative at cut-off
scalar betaO0=_b[_x_1]         // left slope at cut-off
scalar betaO1=betaO0+gammaO1   // right slope at cut-off
*************************************************************************
* Calculate (again) the discontinuity in the outcome ("disc_y")
*************************************************************************
scalar disc_y = _b[_T]
*************************************************************************
* Prediction of the polynomial fit ("y_hat")
*************************************************************************
tempvar y_hat1
predict `y_hat1' if _T==1, xb 
tempvar y_hat0 
predict `y_hat0' if _T==0 , xb 
replace `y_hat0'=alfaO0 if _x==0 & _T==0
*************************************************************************
* GENERATE THE LEFT ("0") AND THE RIGHT ("1") TANGENTS AT CUT-OFF
*************************************************************************
tempvar y_tang1
gen `y_tang1' = alfaO1 + betaO1*_x 
tempvar y_tang0
gen `y_tang0' = alfaO0 + betaO0*_x
*************************************************************************
* GRAPH OUTCOME DISCONTINUITY WITH TANGENTS
*************************************************************************
if "`graph'"=="graph"{
* RIGHT
tempvar grid_r points_r
lpoly `y' _x if _x>=0 & _x<=`h' & `touse', kernel(rect) at(_x) gen(`grid_r' `points_r')  degree(0) bwidth(1)  noscatter  nograph
* LEFT
tempvar grid_l points_l 
lpoly `y' _x if _x<=0 & _x>=-`h' & `touse', kernel(rect) at(_x) gen(`grid_l' `points_l') degree(0) bwidth(1)  noscatter  nograph
graph twoway ///
   (scatter  `points_r' `grid_r' if _x >0 & _x<`l' & `touse', msymbol(o)) ///
   (scatter  `points_l' `grid_l' if _x >-`l' & _x<=0 & `touse', msymbol(oh)) ///
   (line `y_tang1' _x  if _x>=0 & _x<=`h'  & _x >-`l' & _x<`l' & `touse', lcolor(gs10) lpattern(solid) ) ///
   (mspline `y_hat1' _x    if _T==1 & _x>=0 & _x<=`h'  & _x >-`l' & _x<`l' & `touse', lcolor(gs0) lpattern(solid)) ///
   (line `y_tang0' _x  if _x<=0 & _x>=-`h' & _x >-`l' & _x<`l' & `touse', lcolor(gs10) lpattern(solid))  ///
   (mspline `y_hat0' _x    if _T==0 & _x<=0 & _x>=-`h' & _x >-`l' & _x<`l' & `touse', lcolor(gs0) lpattern(solid)) ,  ///
   legend(on order(1 2 3 4) label(1 "Right local means") label(2 "Left local means" ) label(3 "Tangent" ) label(4 "Prediction" ))   ///
    xline(0, lpattern(dash))  ///
	ylabel(,labsize(small)) ///
	xlabel(-`l' +`l') ///
	xtitle("Running variable", size(small)) ///
	ytitle("Outcome") ///
	scheme(s2mono) graphregion(fcolor(white)) ///
	title("Fuzzy RD, KLPR, Outcome discontinuity" , size(medium)) ///
	legend(size(small)) ///
	xlabel(,labsize(small)) ///
	ylabel(,labsize(small)) ///
	note("KLPR = Kernel Local Polynomial Regression" "Kernel = `k'" "Bandwidth value = `h'" ///
	"Polynomial degree = `m'" )
if "`save_graph_o'"!=""{	
graph save `save_graph_o' , replace
}
}
*************************************************************************
* DISCONTINUITY IN THE PROBABILITY 
*************************************************************************
* GENERATE KERNEL WEIGHTS ("weight")
*************************************************************************
tempvar _weightP
_Kernel_ `k' `_weightP' _x `h'
*************************************************************************
* LOCAL KERNEL POLYNOMIAL REGRESSION OF DEGREE "m"
* (AROUND THE CUT-OFF s*, WITH BANDWIDTH "b")
*************************************************************************
di as text ""
di as text "{hline}"
di as text "{bf:******************************************************************************}"
di as text "{bf:********************** DISCONTINUITY IN THE PROBABILITY **********************}"
di as text "{bf:******************************************************************************}"
reg `w' `xvars' _T `Txvars' [pw=`_weightP'] if _x>=-`h' & _x<=`h'  & `touse', `vce' // same bandwidth of outcome
*estimates store mw
scalar size_p=r(N)
*************************************************************************
* RETURNED SCALARS
*************************************************************************
scalar alfaP0=_b[_cons]         // left regression intercept at cut-off
scalar alfaP1=_b[_T]+alfaP0     // right regression intercept at cut-off
scalar gammaP0=_b[_T]           // discontinuity in the probability at cut-off
scalar gammaP1=_b[_T_x_1]       // CPD or discontinuity in derivative at cut-off
scalar betaP0=_b[_x_1]          // left slope at cut-off
scalar betaP1=betaP0+gammaP1    // right slope at cut-off
*************************************************************************
* Calculate (again) the discontinuity in the probability ("disc_w")
*************************************************************************
scalar disc_w = _b[_T]
*************************************************************************
* Prediction of the polynomial fit ("w_hat")
*************************************************************************
tempvar w_hat1
predict `w_hat1' if _T==1, xb 
tempvar w_hat0 
predict `w_hat0' if _T==0 , xb 
replace `w_hat0'=alfaP0 if _x==0 & _T==0
*************************************************************************
* GENERATE THE LEFT ("0") AND THE RIGHT ("1") TANGENTS AT CUT-OFF
*************************************************************************
tempvar w_tang1
gen `w_tang1' = alfaP1 + betaP1*_x 
tempvar w_tang0
gen `w_tang0' = alfaP0 + betaP0*_x
*************************************************************************
* GRAPH PROBABILITY DISCONTINUITY WITH TANGENTS
*************************************************************************
if "`graph'"=="graph"{
* RIGHT
tempvar grid_r points_r
lpoly `w' _x if _x>=0 & _x<=`h' & `touse', kernel(rect) at(_x) gen(`grid_r' `points_r')  degree(0) bwidth(1)  noscatter nograph
* LEFT
tempvar grid_l points_l 
lpoly `w' _x if _x<=0 & _x>=-`h' & `touse', kernel(rect) at(_x) gen(`grid_l' `points_l') degree(0) bwidth(1)  noscatter nograph
graph twoway ///
   (scatter  `points_r' `grid_r' if _x >0 & _x<`l' & `touse', msymbol(o)) ///
   (scatter  `points_l' `grid_l' if _x >-`l' & _x<=0 & `touse', msymbol(oh)) ///
   (line `w_tang1' _x  if _x>=0 & _x<=`h'  & _x >-`l' & _x<`l' & `touse', lcolor(gs10) lpattern(solid) ) ///
   (mspline `w_hat1' _x    if _T==1 & _x>=0 & _x<=`h'  & _x>-`l' & _x<`l' & `touse', lcolor(gs0) lpattern(solid)) ///
   (line `w_tang0' _x  if _x<=0 & _x>=-`h' & _x >-`l' & _x<`l' & `touse', lcolor(gs10) lpattern(solid))  ///
   (mspline `w_hat0' _x    if _T==0 & _x<=0 & _x>=-`h' & _x >-`l' & _x<`l' & `touse', lcolor(gs0) lpattern(solid)) ,  ///
   legend(on order(1 2 3 4) label(1 "Right local means") label(2 "Left local means" ) label(3 "Tangent" ) label(4 "Prediction" ))    ///
    xline(0, lpattern(dash))  ///
	xtitle("Running variable") ///
	xlabel(-`l' +`l') ///
	scheme(s2mono) graphregion(fcolor(white)) ///
    title("Fuzzy RD, KLPR, Probability discontinuity" , size(medium)) ///
	ylabel(,labsize(small)) ///
	ytitle("Probability")  ///
	xtitle("Running variable", size(small)) ///
	legend(size(small)) ///
	note("KLPR = Kernel Local Polynomial Regression" "Kernel = `k'" "Bandwidth value = `h'" ///
	"Polynomial degree = `m'")
if "`save_graph_p'"!=""{	
graph save `save_graph_p' , replace
}	
}
*************************************************************************	
* SENSITIVITY TEST (PROBABILITY)
*************************************************************************
di as text ""
di as text "{hline}"
di as text "{bf:************************ Test of significance for CPD ************************}"
nlcom (CPD: _b[_T_x_1])
*************************************************************************
* CALCULATE "LATE" AS THE RATIO OF THE TWO DISCONTINUITY
*************************************************************************
scalar LATE=disc_y/disc_w
*************************************************************************	
* CALCULATE "TED"
*************************************************************************
ereturn scalar TED=(gammaO1-(gammaP1*gammaO0/gammaP0))/gammaP0
ereturn scalar CPD=gammaP1
*************************************************************************	
* SIGNIFICANT TEST FOR "LATE" AND "TED" USING THE DELTA METHOD
*************************************************************************
qui sureg ///
(`y' `xvars' _T `Txvars') (`w' `xvars' _T `Txvars') ///
if _x>=-`h' & _x<=`h' & `touse' [aw =`_weightP']

*Estimate LATE as the ratio of the coefficient of "_T" in equation "y" and "w"
di as text ""
di as text "{hline}"
di as text "{bf:************************ Test of significance for LATE ***********************}"
nlcom (LATE: [`y']_b[_T]/[`w']_b[_T])

*Estimate TED
scalar TED=(gammaO1-(gammaP1*gammaO0/gammaP0))/gammaP0
di as text ""
di as text "{hline}"
di as text "{bf:************************ Test of significance for TED ************************}"
nlcom (TED: ([`y']_b[_T_x_1]-([`w']_b[_T_x_1]*[`y']_b[_T]/[`w']_b[_T]))/[`w']_b[_T])
di as text ""
ereturn scalar LATE=disc_y/disc_w
ereturn scalar TED=(gammaO1-(gammaP1*gammaO0/gammaP0))/gammaP0
ereturn scalar CPD=gammaP1
*** Number of (used) treated and untreated units ************************
*qui reg `y' `xvars' _T `Txvars' [pw=`_weightO'] if _x>=-`h' & _x<=`h' & `touse', `vce'
qui sum `w' if e(sample)
ereturn scalar N_tot=r(sum_w)
qui sum `w' if e(sample) & `w'==1
ereturn scalar N_treated=r(sum_w)
qui sum `w' if e(sample) & `w'==0
ereturn scalar N_untreated=r(sum_w)
}
*************************************************************************
end

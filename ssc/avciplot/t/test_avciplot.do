* test avciplot.ado

capture set trace off
set tracedepth 1
set more off

capture qui log using test_avciplot, replace
cd "~/Documents/econ/research/stata/ado/personal/avciplot/"
cscript "avciplot after regress" adofile avciplot
about
which avciplot

sysuse auto, clear

local x_av "displacement"

// -------- test accuracy of _b estimates ----------
// x_av in preceding regression
reg mpg `x_av' weight foreign
scalar b = _b[`x_av']
avciplot `x_av', debug
di as txt "   _b from xtreg     =  " as result %18.16f scalar(b)
di as txt "   _b from reg ey ex =  " as result %18.16f r(b_check)
di as txt "   diff in _b:  " as result %18.16f (scalar(b)-r(b_check)) 
assert reldif(scalar(b), r(b_check)) < 1e-13	

// x_av not in preceding regression
reg mpg weight foreign
avciplot `x_av', debug
di as txt "   _b from xtreg     =  " as result %18.16f scalar(b)
di as txt "   _b from reg ey ex =  " as result %18.16f r(b_check)
di as txt "   diff in _b:  " as result %18.16f (scalar(b)-r(b_check)) 
assert reldif(scalar(b), r(b_check)) < 1e-13	

// ----- test for factor variables in varlist -----

//		for included x and not included x
reg mpg c.`x_av'#c.`x_av' weight foreign
avciplot c.`x_av'#c.`x_av'
reg mpg weight foreign
avciplot c.`x_av'#c.`x_av'
rcof "avciplot `x_av'##`x_av'" == 198
rcof "avciplot i.foreign" == 198


// -------- test that -generate()- option works ----------

// `x_av' included in preceding -regress-
qui reg mpg `x_av' weight foreign
scalar b = _b[`x_av']
scalar se = _se[`x_av']
local dof = e(df_r)
avciplot `x_av', gen(e_x e_y) debug nodisplay
noi di as txt "   r(b_check)        =  " as result %18.16f r(b_check)

_regress e_y e_x, nocons dof(`dof')
di as txt "   b from regress   =  " as result %18.16f scalar(b)
di as txt "   _b from e_y on e_x =  " as result %18.16f _b[e_x]
di as txt "   reldif = " as result %18.16f reldif(_b[e_x],scalar(b)) 
assert reldif(_b[e_x],scalar(b)) < 1e-13	
di as txt "   se from regress   =  " as result %18.16f scalar(se)
di as txt "   _se from e_y on e_x =  " as result %18.16f _se[e_x]
di as txt "   reldif = " as result %18.16f reldif(_se[e_x],scalar(se)) 
assert reldif(_se[e_x],scalar(se)) < 1e-13	
drop e_x e_y

// `x_av' NOT included in preceding -regress-
qui reg mpg weight foreign
avciplot `x_av', gen(e_x e_y) debug nodisplay
noi di as txt "   r(b_check)        =  " as result %18.16f r(b_check)

_regress e_y e_x, nocons dof(`dof')
di as txt "   b from regress   =  " as result %18.16f scalar(b)
di as txt "   _b from e_y on e_x =  " as result %18.16f _b[e_x]
di as txt "   reldif = " as result %18.16f reldif(_b[e_x],scalar(b)) 
assert reldif(_b[e_x],scalar(b)) < 1e-13	
di as txt "   se from regress   =  " as result %18.16f scalar(se)
di as txt "   _se from e_y on e_x =  " as result %18.16f _se[e_x]
di as txt "   reldif = " as result %18.16f reldif(_se[e_x],scalar(se)) 
assert reldif(_se[e_x],scalar(se)) < 1e-13	
drop e_x e_y

// ------ test for varname problems ------

	qui reg mpg `x_av' weight foreign
	// no varname
	rcof "avciplot" == 100

	// too many variables
	rcof "avciplot `x_av' weight" == 103

// ------ test for existence of previous estimates ------

	ereturn clear
	rcof "avciplot `x_av'" == 301

// ------ test for EXCLUDED x variable problems ------

//  "cannot include dependent variable"
	qui reg `x_av' weight foreign
	rcof "avciplot `x_av'" == 398

//  "x has missing values"
	gen miss_test = `x_av' if _n>50
	qui reg mpg `x_av' weight foreign
	rcof "avciplot c.miss_test#c.miss_test" == 398
	drop miss_test

// check for collinearity of variable x with depvar or rhs
	qui reg mpg `x_av' weight foreign
	gen coll_test = mpg*2
	rcof "avciplot coll_test" == 459
	replace coll_test = `x_av'+1
	rcof "avciplot coll_test" == 459
	drop coll_test

// ------ test for INCLUDED x variable problems ------

// check for "x was dropped from model"
	gen coll_x = `x_av'+1
	qui reg mpg coll_x `x_av' weight foreign
	rcof "avciplot `x_av'" == 399
	drop coll_x

	
// ----------- test avciplots -----------

	qui reg mpg `x_av' weight foreign
	avciplots

display "test_avciplot completed successfully!"

qui log close
window manage forward results

// test for Stata version 11

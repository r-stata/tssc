*! version 1.3 beta  27dec2012
*moehring@wiso.uni-koeln.de
* General Formulas (Simplified Version) as proposed by Snijders/Bosker 1994, 350-354, cf. also 1999, 99-105
* Second version by Bryk/Raudenbush 1992, p. 68



capture program drop mltrsq
program define mltrsq, eclass
version 12.0, missing


syntax [, full]
*syntax varlist, IV(varlist) [IF(string)]  


*Erase variables
capture drop mltsample


*Display error messages and terminate program if necessary
**1. error if command != xtmixed
if regexm(e(cmd), "xtmixed")==0 {
 di as error "xtmrsq works only after xtmixed"
 exit
}

**2. error if number of levels > 2
local lvl2var = e(ivars)
tokenize "`lvl2var'"
if "`2'" !="" {
 di as error "xtmrsq works only with 2-level models"
 exit
}



*Check if xtmelogit or xtmixed specified
if regexm(e(cmd), "xtmixed")==1 {
 local logit=0
}
if regexm(e(cmd), "xtmelogit")==1 {
 local logit=1
}


*Check if random-intercept specified
local revars = e(revars)
gettoken re1 re2: revars, parse("_")
if "`re1'" !="_" {
 *di as error "Please estimate a random-intercept model for R-squared calculation"
 local repeatmod_rs=1
}
else {
 local repeatmod_rs=0
}


* store estimation results of user 
capture drop userest
_est hold userest, copy restore
est store FULL		
drop _est_FULL		



*Save sample
gen mltsample=e(sample)


*Get lvl2-values
dis as text "Level 2 variable is" as result " `lvl2var' "
dis " "
qui levelsof `lvl2var', local(lvl2values)
gettoken l2v1 l2v2: lvl2values, parse(" ")

*Get commandline and options
local cmdline  `e(cmdline)'		
gettoken rest options: cmdline, parse(",")


*Get number of fixed and random parameters and number of independent variables
local fixpar = e(k_f)
local ranpar = e(k_r)
local niv = `fixpar'-1

*Get names of independent variables, command and dependent variable and display them 
gettoken com rest: cmdline // default: parse(" ") meaning tokens are identified by blanks
gettoken dvarn rest: rest
local command="`com' "+"`dvarn' "	
mat VARn=e(b)				 
mat VARn=VARn[1,1..`niv']		 
local ivars:colnames(VARn)		

dis " "
dis as text "Calculating R-squared for the parameters of"
dis as result " `ivars' " as text "and" as result " _cons"			

* check for weighting and construct the weighting command, $ as 29nov12
if "`e(wtype)'"!="" {
local weight = "[`e(wtype)'`e(wexp)']"
} 


*Repeat model if random slope specified
if (`repeatmod_rs'==1) {
 display as text "  "
 display as text "Model needs to be recalculated without random slopes to estimate R-squared values"
 display as text "this may take some time..."
 qui `command' `ivars' `weight' || `lvl2var': if mltsample==1 `options'
}


*Get number of fixed and random parameters and number of independent variables
local fixpar = e(k_f)
local ranpar = e(k_r)
local niv = `fixpar'-1


*Get total number of parameters (fixed+random)
capture local drop np
local np=e(k)


*Get matrix of parameters
matrix b=e(b)
*matrix list e(b)


local bomega=b[1,`np']
local modelomega=exp(`bomega')^2
local btau=b[1,`np'-1]
local modeltau=exp(`btau')^2

matrix drop b


capture local drop lvl2var
local lvl2var=e(ivars)
dis "   "



*Get number of level2-units
matrix m=e(N_g)
local nmacro=m[1,1]
matrix drop m
dis as text "   "
dis as text "Number of macro-units: " %5.0f as result `nmacro'


*Calculation of the harmonic mean of the level-2 group sizes
tempvar n nc nsum hmean

preserve 
qui keep if mltsample == 1
quietly: bysort `lvl2var': gen `n'=_N
quietly: replace `n'=1/`n'
quietly: bysort `lvl2var': gen `nc'=_n
quietly: egen `nsum'=total(`n') if  `nc'==1
quietly: gen `hmean'= `nmacro'/`nsum'

if "`full'" == "full" {
 dis as text "   "
 dis as text "Harmonic mean of the level-2 group sizes: " %5.2f as result `hmean'
}


if "`full'" == "full" {
 dis as text "   "
 dis as text "Random-effects Parameters of complete model:  " 
 dis as text "   Residual-varianz level 1: " %5.4f as result `modelomega'
 dis as text "   Residual-varianz level 2: " %5.4f as result `modeltau'
}



capture local drop dv
local dv=e(depvar)


capture local drop cmdline
local cmdline=e(cmdline)


*Estimation of Null-model		
qui `command' `weight' || `lvl2var': if mltsample==1 `options'

*Saving variables from estimation of complete model as locals
matrix b=e(b)



local bomega=b[1,3]
local nullomega=exp(`bomega')^2
local btau=b[1,2]
local nulltau=exp(`btau')^2


matrix drop b

if "`full'" == "full" {
 dis as text "   "
 dis as text "Random-effects Parameters of Null-model:  " 
 dis as text "   Residual-varianz level 1: " %5.4f as result `nullomega'
 dis as text "   Residual-varianz level 2: " %5.4f as result `nulltau'
}


***R-squared berechnen***
**Level 1 (Micro): dis "1-(MODELvar(Residual) + MODELvar(_cons))/(NULLvar(Residual) + NULLvar(_cons))"
**Level 2 (Macro): dis "1-((MODELvar(Residual)/MeanCountryN) + MODELvar(_cons))/((NULLvar(Residual)/MeanCountryN) + NULLvar(_cons))"

tempvar sbrmicro sbrmacro brrmicro brrmacro

*Snijders/Bosker R-squared
qui: gen `sbrmicro'=1-((`modelomega' + `modeltau')/(`nullomega' + `nulltau'))
qui: gen `sbrmacro'=1-((`modelomega'/`hmean' + `modeltau')/(`nullomega'/`hmean' + `nulltau'))

*Bryk/Raudenbush R-squared
qui: gen `brrmicro'=(`nullomega' - `modelomega')/`nullomega'
qui: gen `brrmacro'=(`nulltau' - `modeltau')/`nulltau'

dis as text "   "
dis as text "   "
dis as text "Snijders/Bosker R-squared Level 1:  " %5.4f as result `sbrmicro'
dis as text "Snijders/Bosker R-squared Level 2:  " %5.4f as result `sbrmacro'
dis as text "   "
dis as text "Bryk/Raudenbush R-squared Level 1:  " %5.4f as result `brrmicro'
dis as text "Bryk/Raudenbush R-squared Level 2:  " %5.4f as result `brrmacro'


*Erase variables
capture drop mltsample

* restore the estimation results from user to e() 
_est unhold userest

*  writing parameters into e-list
	* save number of macro units as scalar in e-list 
	ereturn scalar N_l2= `nmacro'
	* save Bosker/Snijders Rsq
	ereturn scalar sb_rsq_l1= `sbrmicro'
	ereturn scalar sb_rsq_l2= `sbrmacro'
	* save Bryk/Raudenbush Rsq
	ereturn scalar br_rsq_l1= `brrmicro'
	ereturn scalar br_rsq_l2= `brrmacro'

*restore
restore

end

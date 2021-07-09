*==========================================================================*
*                             mmsel.ado   (v2.0)                           *
*--------------------------------------------------------------------------*
*               Adapted for Sample Selection Correction by				   *
*					 Sami Souabni (sami@souabni.com)					   *
*		School of Business and Economics, Swansea University			   *
*			who bears no responsibility for any errors. 				   *
*					  Based on original code by   						   *
*               Mark Bryan, ISER, University of Essex,					   *
*			who bears no responsibility for any errors.                    *
*--------------------------------------------------------------------------*
*  Downloaded from The Statistical Software Components (SSC) Archive	   *
*--------------------------------------------------------------------------*
*  Code to simulate (counterfactual) distributions from quantile           *
*  regressions. Based on Machado and Mata (2005). An option to correct     *
*  for sample selection has been added, using as adaptation of the         *
*  procedure described in Albrecht et. al (2009). Multiple options		   *
*  available for different references groups, following Oaxaca (1973),     *
*  Blinder (1973) Oaxaca Ransom (1994) and Jann (2008).                    *
*--------------------------------------------------------------------------*
*  Requires pid variable							                       *
*--------------------------------------------------------------------------*
*  Creates directories: tmp, logs, results, data                           *
*  Log file: results/`filename'(_sel).log								   *
*  Graphs: results/`filename'(_sel).gph                                    *
*  Other logs: logs/gaps                                                   *
*--------------------------------------------------------------------------*
*  Syntax:                                                                 *
*  mmsel varlist(min=2) [if] [in] , GRoup(varname numeric) Reps(integer 200*
*  )Filename(string) [pooled incgrp group1 Method(integer 2)               *
*  ADJust(varname numeric) REDuced(var list numeric min=2) grponlysel       *
* CONSTRaint(string)]								   					   *
*                                                                          *
*==========================================================================*

*Machado and Mata Program, taking into account sample selection

capture program drop mmsel
program define mmsel
version 10.0
syntax varlist(min=2) [if] [in] , GRoup(varname numeric) Filename(string) [pooled incgrp group1 grponlysel percentile Method(integer 2) Reps(integer 200) SIngle(varlist numeric) ADJust(varname numeric) REDuced(varlist numeric min=2) CONSTRaint(string)]
tokenize `varlist'
global lhs "`1'"
macro shift 1
global rhs "`*'"

local lhs $lhs
local rhs $rhs

global group `group'
global adjust `adjust'
global filename `filename'
global pooled `pooled'
global incgrp `incgrp'
global group1 `group'
global method `method'
global reps `reps'
global reduced `reduced'
global constraint `constraint'
global grponlysel `grponlysel'
global single `single'

capture mkdir tmp
capture mkdir logs
capture mkdir results
capture mkdir data

if `"`single'"'!=""&`"`grponlysel'"'!="" {

ge works=0
replace works==1 if `lhs'>0
foreach gen in 0 1 {
if `gen'==0 {
keep if `group'==`gen'

tempfile presingle
save "`presingle'"

	capture program drop single
	capture program drop dsingle

keep works `single'
single works `single', h(0.4)

use "`presingle'", clear
compress
	matrix gamma = e(b)
	local k_totaal = colsof(gamma)
	matrix cov_step1 = e(V)
	local b1 = gamma[1,1]
	local b0 = gamma[1,colsof(gamma)]

	local i = 0
	tempvar lambda
	tempvar lambda1
	tempvar z
	
	g `z' = `b0'
	local i = 0
	local svar "$svar"
	
	while (`i' < `k_totaal'-1) {
		local i = `i'+ 1
		local b1 = gamma[1,`i']

		tempvar hulp_x
		local name_x = word("`svar'",1)
		g `hulp_x' = `name_x'
		local svar1 : list local(svar) - local(name_x)
		local svar "`svar1'"
		
		quietly replace `z' = `z' + `b1' * `hulp_x'
	}
	replace Ps1 = `z'
	}
	probit works Ps1
	predict ps, xb
	replace Ps1 = normalden(-ps) / (1-normal(-ps))
	else {
	keep if `group'==`gen'
	}
	tempfile single_`gen'
	save "`single_`gen''"
	}
 use "`single_0'"
 append "`single_1'"
 
  keep if works==1

if `"`grponlysel'"'=="" {
drop if Ps1==.
}
else {
drop if Ps1==.&`group'==0
}

foreach var of local rhs {
drop if `var'==.
}

}


if `"`single'"'!=""&`"`grponlysel'"'=="" {
ge works=0
replace works==1 if `lhs'>0

foreach gen in 0 1 {
keep if `group'==`gen'

tempfile presingle
save "`presingle'"

	capture program drop single
	capture program drop dsingle

keep works `single'
single works `single', h(0.4)
di ""
di ""
di "BEWARE: If running 64bit Stata, expect an error r(9999) - use 32bit version instead!"
di ""
di ""
use "`presingle'", clear
compress
	matrix gamma = e(b)
	local k_totaal = colsof(gamma)
	matrix cov_step1 = e(V)
	local b1 = gamma[1,1]
	local b0 = gamma[1,colsof(gamma)]

	local i = 0
	tempvar lambda
	tempvar lambda1
	tempvar z
	
	g `z' = `b0'
	local i = 0
	local svar "$svar"
	
	while (`i' < `k_totaal'-1) {
		local i = `i'+ 1
		local b1 = gamma[1,`i']

		tempvar hulp_x
		local name_x = word("`svar'",1)
		g `hulp_x' = `name_x'
		local svar1 : list local(svar) - local(name_x)
		local svar "`svar1'"
		
		quietly replace `z' = `z' + `b1' * `hulp_x'
	}
	replace Ps1 = `z'
	probit works Ps1
	predict ps, xb
	replace Ps1 = normalden(-ps) / (1-normal(-ps))
	tempfile single_`gen'
	save "`single_`gen''"
	}
use "`single_0'"
append "`single_1'"
 
keep if works==1

if `"`grponlysel'"'=="" {
drop if Ps1==.
}
else {
drop if Ps1==.&`group'==0
}

foreach var of local rhs {
drop if `var'==.
}

}

save data/data_with_ps, replace

*---------------------------------
* Clean up working directory
*---------------------------------
forval i = 1/99 {

capture erase tmp/xfbf`i'.dta
capture erase tmp/xmbm`i'.dta
capture erase tmp/xfbm`i'.dta
capture erase tmp/xfbp`i'.dta
capture erase tmp/xmbp`i'.dta
}

capture erase tmp/xfbf.dta
capture erase tmp/xmbm.dta
capture erase tmp/xfbm.dta
capture erase tmp/xmbp.dta
capture erase tmp/xfbp.dta
clear
estimates clear

use data/data_with_ps, clear
if `"`if'"'!="" {
keep `if'
}

capture ge `adjust'2=`adjust'^2
capture ge `adjust'3=`adjust'2^2

*---------------------------------
* Build matrix of means for each group
*---------------------------------

matrix accum X = `rhs' if `group'==1
matrix X = X["_cons",1...] /* extract totals */
matrix N = X["_cons","_cons"] /* number of obs */
scalar N = N[1, 1] /* number of obs */
matrix xbarm = X / N /* men */

matrix accum X = `rhs' if `group'==0
matrix X = X["_cons",1...] /* extract totals */
matrix N = X["_cons","_cons"] /* number of obs */
scalar N = N[1, 1] /* number of obs */
matrix xbarf = X / N /* women */

*---------------------------------
* At the mean
*---------------------------------
if `"`grponlysel'"'!=""{
if `"`adjust'"'!="" {
	reg `lhs' `rhs' if `group'==1
	matrix bmols = e(b)
	matrix Vmols = e(V)
	
	reg `lhs' `rhs' `adjust' if `group'==0
	scalar beta1=_b[`adjust']
	ge `lhs'_adj=`lhs'-(beta1*`adjust') if `group'==0
	reg `lhs'_adj `rhs' if `group'==0
	matrix bfols = e(b)
	matrix Vfols = e(V)
	drop `lhs'_adj
	}
		else {
	reg `lhs' `rhs' if `group'==1
	matrix bmols = e(b)
	matrix Vmols = e(V)

	reg `lhs' `rhs' if `group'==0
	matrix bfols = e(b)
	matrix Vfols = e(V)
	}
}
else{
if `"`adjust'"'!="" {
	reg `lhs' `rhs' `adjust' if `group'==1
	scalar beta1m=_b[`adjust']
	ge `lhs'_adj=`lhs'-(beta1m*`adjust') if `group'==1
	reg `lhs'_adj `rhs' if `group'==1
	matrix bmols = e(b)
	matrix Vmols = e(V)
	drop `lhs'_adj

	reg `lhs' `rhs' `adjust' if `group'==0
	scalar beta1f=_b[`adjust']
	ge `lhs'_adj=`lhs'-(beta1f*`adjust') if `group'==0
	reg `lhs'_adj `rhs' if `group'==0
	matrix bfols = e(b)
	matrix Vfols = e(V)
	drop `lhs'_adj
	}
	else {
	reg `lhs' `rhs' if `group'==1
	matrix bmols = e(b)
	matrix Vmols = e(V)

	reg `lhs' `rhs' if `group'==0
	matrix bfols = e(b)
	matrix Vfols = e(V)
	}
}


* Predictions, standard errors and differentials 

matrix olsdiffmat = (bmols - bfols) * xbarf' /* gender diff holding characs constant (mean female characs) */
scalar olsdiff=  olsdiffmat[1,1]
matrix V = Vmols + Vfols
matrix v_olsdiff = xbarf*V*xbarf' /* calculate se */
scalar se_olsdiff = v_olsdiff[1,1]
scalar se_olsdiff = sqrt(se_olsdiff)

*---------------------------------
* Reference Wage Structure Selected?
*---------------------------------
if `"`grponlysel'"'!="" {
if `"`pooled'"' != "" {
di "POOLED REFERENCE WAGE STRUCTURE"
di "GROUP=0 SS CORRECTION ONLY"
}
if `"`group1'"' != "" {
di "GROUP=1 REFERENCE STRUCTURE"
di "GROUP=0 SS CORRECTION ONLY"
}
if `"`incgen'"' != "" {
di "POOLED REF INC GROUP DUMMY"
di "GROUP=0 SS CORRECTION ONLY"
}
}
else {
if `"`pooled'"' != "" {
di "POOLED REFERENCE WAGE STRUCTURE"
}
if `"`group1'"' != "" {
di "GROUP=1 REFERENCE STRUCTURE"
}
if `"`incgen'"' != "" {
di "POOLED REF INC GROUP DUMMY"
}
}
*---------------------------------
* Across each quantile
*---------------------------------

* Raw gaps

forval i = 1/19 {
	local q = `i'*0.05
	quietly: qreg `lhs' `group', quantile(`q') nolog 
	scalar raw`i' = _b[`group']
}

*Sex included due to http://www.ssc.wisc.edu/~jmuniz/jann_oaxaca.pdf p.6

	if `"`pooled'"'!="" {
		adjtest m p
		adjtest f p
	}
	
	if `"`incgen'"'!="" {
		adjtest m i
		adjtest f i
	}
	
	if `"`group1'"'!="" {
		adjtest f g
	}
	
	adjtest m m
	adjtest f f


* Calculate wage gaps

set seed 1

set rmsg on /* See how long gengap takes */

if `"`percentile'"' != ""{
if `"`group1'"' != "" {
gengap1 g
}
if `"`incgen'"'!="" {
gengap1 i
}
if `"`pooled'"'!="" {
gengap1 p
} 
}
else {
if `"`group1'"' != "" {
gengap g
}
if `"`incgen'"'!="" {
gengap i
}
if `"`pooled'"'!="" {
gengap p
} 
}
set rmsg off
/*
copy tmp/xfbf.dta logs/xfbf.dta, replace /* save simulated women's distribution for future ref */
copy tmp/xmbm.dta logs/xmbm.dta, replace /* save simulated women's distribution for future ref */
copy tmp/xfbm.dta logs/xfbm.dta, replace /* save simulated women's distribution for future ref */
*/
* Compare simulated distribution with actual distribution for women

use tmp/xfbf, clear /* simulated */
su xfbf, de

use data/data_with_ps, clear
if `"`if'"'!="" {
	keep `if'
}
capture ge `adjust'2=`adjust'^2
capture ge `adjust'3=`adjust'^3

su $lhs, de

* Do replications
if `"`percentile'"' != ""{
if `"`group1'"' != "" {
	gengap1 g
}
if `"`incgen'"'!="" {
	gengap1 i
}
if `"`pooled'"'!="" {
	gengap1 p
} 
}
else{
if `"`group1'"' != "" {
	gengap g
}
if `"`incgen'"'!="" {
	gengap i
}
if `"`pooled'"'!="" {
	gengap p
} 
}

if `"`percentile'"' != ""{
if `"`group1'"' != "" {
	simulate "gengap1 g" ovgap1=r(ovgap1) ovgap2=r(ovgap2) ovgap3=r(ovgap3) ovgap4=r(ovgap4) ovgap5=r(ovgap5) ovgap6=r(ovgap6) ovgap7=r(ovgap7) ovgap8=r(ovgap8) /*
	*/ ovgap9=r(ovgap9) ovgap10=r(ovgap10) ovgap11=r(ovgap11) ovgap12=r(ovgap12) ovgap13=r(ovgap13) ovgap14=r(ovgap14) ovgap15=r(ovgap15) ovgap16=r(ovgap16) ovgap17=r(ovgap17) /*
	*/ ovgap18=r(ovgap18) ovgap19=r(ovgap20) ovgap19=r(ovgap20) ovgap21=r(ovgap21) ovgap22=r(ovgap22) ovgap23=r(ovgap23) ovgap24=r(ovgap24) ovgap25=r(ovgap25) ovgap26=r(ovgap26) ovgap27=r(ovgap27) ovgap8=r(ovgap28) /*
	*/ ovgap29=r(ovgap29) ovgap30=r(ovgap30) ovgap31=r(ovgap31) ovgap32=r(ovgap32) ovgap33=r(ovgap33) ovgap34=r(ovgap34) ovgap35=r(ovgap35) ovgap36=r(ovgap36) ovgap37=r(ovgap37) /*
	*/ ovgap38=r(ovgap38) ovgap39=r(ovgap39) ovgap40=r(ovgap40) ovgap41=r(ovgap41) ovgap42=r(ovgap42) ovgap43=r(ovgap43) ovgap44=r(ovgap44) ovgap45=r(ovgap45) ovgap46=r(ovgap46) ovgap47=r(ovgap47) ovgap48=r(ovgap48) /*
	*/ ovgap49=r(ovgap49) ovgap50=r(ovgap50) ovgap51=r(ovgap51) ovgap52=r(ovgap52) ovgap53=r(ovgap53) ovgap54=r(ovgap54) ovgap55=r(ovgap55) ovgap56=r(ovgap56) ovgap57=r(ovgap57) /*
	*/ ovgap58=r(ovgap58) ovgap59=r(ovgap59) ovgap60=r(ovgap60) ovgap61=r(ovgap61) ovgap62=r(ovgap62) ovgap63=r(ovgap63) ovgap64=r(ovgap64) ovgap65=r(ovgap65) ovgap66=r(ovgap66) ovgap67=r(ovgap67) ovgap68=r(ovgap68) /*
	*/ ovgap69=r(ovgap69) ovgap70=r(ovgap70) ovgap71=r(ovgap71) ovgap72=r(ovgap72) ovgap73=r(ovgap73) ovgap74=r(ovgap74) ovgap75=r(ovgap75) ovgap76=r(ovgap76) ovgap77=r(ovgap77) /*
	*/ ovgap78=r(ovgap78) ovgap79=r(ovgap79) ovgap80=r(ovgap80) ovgap81=r(ovgap81) ovgap82=r(ovgap82) ovgap83=r(ovgap83) ovgap84=r(ovgap84) ovgap85=r(ovgap85) ovgap86=r(ovgap86) ovgap87=r(ovgap87) ovgap88=r(ovgap88) /*
	*/ ovgap89=r(ovgap89) ovgap90=r(ovgap90) ovgap91=r(ovgap91) ovgap92=r(ovgap92) ovgap93=r(ovgap93) ovgap94=r(ovgap94) ovgap95=r(ovgap95) ovgap96=r(ovgap96) ovgap97=r(ovgap97) /*
	*/ ovgap98=r(ovgap98) ovgap99=r(ovgap99) expgap1=r(expgap1) expgap2=r(expgap2) expgap3=r(expgap3) expgap4=r(expgap4) expgap5=r(expgap5) expgap6=r(expgap6) expgap7=r(expgap7) expgap8=r(expgap8) /*
	*/ expgap9=r(expgap9) expgap10=r(expgap10) expgap11=r(expgap11) expgap12=r(expgap12) expgap13=r(expgap13) expgap14=r(expgap14) expgap15=r(expgap15) expgap16=r(expgap16) expgap17=r(expgap17) /*
	*/ expgap18=r(expgap18) expgap19=r(expgap20) expgap19=r(expgap20) expgap21=r(expgap21) expgap22=r(expgap22) expgap23=r(expgap23) expgap24=r(expgap24) expgap25=r(expgap25) expgap26=r(expgap26) expgap27=r(expgap27) expgap8=r(expgap28) /*
	*/ expgap29=r(expgap29) expgap30=r(expgap30) expgap31=r(expgap31) expgap32=r(expgap32) expgap33=r(expgap33) expgap34=r(expgap34) expgap35=r(expgap35) expgap36=r(expgap36) expgap37=r(expgap37) /*
	*/ expgap38=r(expgap38) expgap39=r(expgap39) expgap40=r(expgap40) expgap41=r(expgap41) expgap42=r(expgap42) expgap43=r(expgap43) expgap44=r(expgap44) expgap45=r(expgap45) expgap46=r(expgap46) expgap47=r(expgap47) expgap48=r(expgap48) /*
	*/ expgap49=r(expgap49) expgap50=r(expgap50) expgap51=r(expgap51) expgap52=r(expgap52) expgap53=r(expgap53) expgap54=r(expgap54) expgap55=r(expgap55) expgap56=r(expgap56) expgap57=r(expgap57) /*
	*/ expgap58=r(expgap58) expgap59=r(expgap59) expgap60=r(expgap60) expgap61=r(expgap61) expgap62=r(expgap62) expgap63=r(expgap63) expgap64=r(expgap64) expgap65=r(expgap65) expgap66=r(expgap66) expgap67=r(expgap67) expgap68=r(expgap68) /*
	*/ expgap69=r(expgap69) expgap70=r(expgap70) expgap71=r(expgap71) expgap72=r(expgap72) expgap73=r(expgap73) expgap74=r(expgap74) expgap75=r(expgap75) expgap76=r(expgap76) expgap77=r(expgap77) /*
	*/ expgap78=r(expgap78) expgap79=r(expgap79) expgap80=r(expgap80) expgap81=r(expgap81) expgap82=r(expgap82) expgap83=r(expgap83) expgap84=r(expgap84) expgap85=r(expgap85) expgap86=r(expgap86) expgap87=r(expgap87) expgap88=r(expgap88) /*
	*/ expgap89=r(expgap89) expgap90=r(expgap90) expgap91=r(expgap91) expgap92=r(expgap92) expgap93=r(expgap93) expgap94=r(expgap94) expgap95=r(expgap95) expgap96=r(expgap96) expgap97=r(expgap97) /*
	*/ expgap98=r(expgap98) expgap99=r(expgap99) unexpgap1=r(unexpgap1) unexpgap2=r(unexpgap2) unexpgap3=r(unexpgap3) unexpgap4=r(unexpgap4) unexpgap5=r(unexpgap5) unexpgap6=r(unexpgap6) unexpgap7=r(unexpgap7) unexpgap8=r(unexpgap8) /*
	*/ unexpgap9=r(unexpgap9) unexpgap10=r(unexpgap10) unexpgap11=r(unexpgap11) unexpgap12=r(unexpgap12) unexpgap13=r(unexpgap13) unexpgap14=r(unexpgap14) unexpgap15=r(unexpgap15) unexpgap16=r(unexpgap16) unexpgap17=r(unexpgap17) /*
	*/ unexpgap18=r(unexpgap18) unexpgap19=r(unexpgap20) unexpgap19=r(unexpgap20) unexpgap21=r(unexpgap21) unexpgap22=r(unexpgap22) unexpgap23=r(unexpgap23) unexpgap24=r(unexpgap24) unexpgap25=r(unexpgap25) unexpgap26=r(unexpgap26) unexpgap27=r(unexpgap27) unexpgap8=r(unexpgap28) /*
	*/ unexpgap29=r(unexpgap29) unexpgap30=r(unexpgap30) unexpgap31=r(unexpgap31) unexpgap32=r(unexpgap32) unexpgap33=r(unexpgap33) unexpgap34=r(unexpgap34) unexpgap35=r(unexpgap35) unexpgap36=r(unexpgap36) unexpgap37=r(unexpgap37) /*
	*/ unexpgap38=r(unexpgap38) unexpgap39=r(unexpgap39) unexpgap40=r(unexpgap40) unexpgap41=r(unexpgap41) unexpgap42=r(unexpgap42) unexpgap43=r(unexpgap43) unexpgap44=r(unexpgap44) unexpgap45=r(unexpgap45) unexpgap46=r(unexpgap46) unexpgap47=r(unexpgap47) unexpgap48=r(unexpgap48) /*
	*/ unexpgap49=r(unexpgap49) unexpgap50=r(unexpgap50) unexpgap51=r(unexpgap51) unexpgap52=r(unexpgap52) unexpgap53=r(unexpgap53) unexpgap54=r(unexpgap54) unexpgap55=r(unexpgap55) unexpgap56=r(unexpgap56) unexpgap57=r(unexpgap57) /*
	*/ unexpgap58=r(unexpgap58) unexpgap59=r(unexpgap59) unexpgap60=r(unexpgap60) unexpgap61=r(unexpgap61) unexpgap62=r(unexpgap62) unexpgap63=r(unexpgap63) unexpgap64=r(unexpgap64) unexpgap65=r(unexpgap65) unexpgap66=r(unexpgap66) unexpgap67=r(unexpgap67) unexpgap68=r(unexpgap68) /*
	*/ unexpgap69=r(unexpgap69) unexpgap70=r(unexpgap70) unexpgap71=r(unexpgap71) unexpgap72=r(unexpgap72) unexpgap73=r(unexpgap73) unexpgap74=r(unexpgap74) unexpgap75=r(unexpgap75) unexpgap76=r(unexpgap76) unexpgap77=r(unexpgap77) /*
	*/ unexpgap78=r(unexpgap78) unexpgap79=r(unexpgap79) unexpgap80=r(unexpgap80) unexpgap81=r(unexpgap81) unexpgap82=r(unexpgap82) unexpgap83=r(unexpgap83) unexpgap84=r(unexpgap84) unexpgap85=r(unexpgap85) unexpgap86=r(unexpgap86) unexpgap87=r(unexpgap87) unexpgap88=r(unexpgap88) /*
	*/ unexpgap89=r(unexpgap89) unexpgap90=r(unexpgap90) unexpgap91=r(unexpgap91) unexpgap92=r(unexpgap92) unexpgap93=r(unexpgap93) unexpgap94=r(unexpgap94) unexpgap95=r(unexpgap95) unexpgap96=r(unexpgap96) unexpgap97=r(unexpgap97) /*
	*/ unexpgap98=r(unexpgap98) unexpgap99=r(unexpgap99), reps(`reps') dots saving(logs/gaps) replace 
}

if `"`incgen'"'!="" {
	simulate "gengap1 i" ovgap1=r(ovgap1) ovgap2=r(ovgap2) ovgap3=r(ovgap3) ovgap4=r(ovgap4) ovgap5=r(ovgap5) ovgap6=r(ovgap6) ovgap7=r(ovgap7) ovgap8=r(ovgap8) /*
	*/ ovgap9=r(ovgap9) ovgap10=r(ovgap10) ovgap11=r(ovgap11) ovgap12=r(ovgap12) ovgap13=r(ovgap13) ovgap14=r(ovgap14) ovgap15=r(ovgap15) ovgap16=r(ovgap16) ovgap17=r(ovgap17) /*
	*/ ovgap18=r(ovgap18) ovgap19=r(ovgap20) ovgap19=r(ovgap20) ovgap21=r(ovgap21) ovgap22=r(ovgap22) ovgap23=r(ovgap23) ovgap24=r(ovgap24) ovgap25=r(ovgap25) ovgap26=r(ovgap26) ovgap27=r(ovgap27) ovgap8=r(ovgap28) /*
	*/ ovgap29=r(ovgap29) ovgap30=r(ovgap30) ovgap31=r(ovgap31) ovgap32=r(ovgap32) ovgap33=r(ovgap33) ovgap34=r(ovgap34) ovgap35=r(ovgap35) ovgap36=r(ovgap36) ovgap37=r(ovgap37) /*
	*/ ovgap38=r(ovgap38) ovgap39=r(ovgap39) ovgap40=r(ovgap40) ovgap41=r(ovgap41) ovgap42=r(ovgap42) ovgap43=r(ovgap43) ovgap44=r(ovgap44) ovgap45=r(ovgap45) ovgap46=r(ovgap46) ovgap47=r(ovgap47) ovgap48=r(ovgap48) /*
	*/ ovgap49=r(ovgap49) ovgap50=r(ovgap50) ovgap51=r(ovgap51) ovgap52=r(ovgap52) ovgap53=r(ovgap53) ovgap54=r(ovgap54) ovgap55=r(ovgap55) ovgap56=r(ovgap56) ovgap57=r(ovgap57) /*
	*/ ovgap58=r(ovgap58) ovgap59=r(ovgap59) ovgap60=r(ovgap60) ovgap61=r(ovgap61) ovgap62=r(ovgap62) ovgap63=r(ovgap63) ovgap64=r(ovgap64) ovgap65=r(ovgap65) ovgap66=r(ovgap66) ovgap67=r(ovgap67) ovgap68=r(ovgap68) /*
	*/ ovgap69=r(ovgap69) ovgap70=r(ovgap70) ovgap71=r(ovgap71) ovgap72=r(ovgap72) ovgap73=r(ovgap73) ovgap74=r(ovgap74) ovgap75=r(ovgap75) ovgap76=r(ovgap76) ovgap77=r(ovgap77) /*
	*/ ovgap78=r(ovgap78) ovgap79=r(ovgap79) ovgap80=r(ovgap80) ovgap81=r(ovgap81) ovgap82=r(ovgap82) ovgap83=r(ovgap83) ovgap84=r(ovgap84) ovgap85=r(ovgap85) ovgap86=r(ovgap86) ovgap87=r(ovgap87) ovgap88=r(ovgap88) /*
	*/ ovgap89=r(ovgap89) ovgap90=r(ovgap90) ovgap91=r(ovgap91) ovgap92=r(ovgap92) ovgap93=r(ovgap93) ovgap94=r(ovgap94) ovgap95=r(ovgap95) ovgap96=r(ovgap96) ovgap97=r(ovgap97) /*
	*/ ovgap98=r(ovgap98) ovgap99=r(ovgap99) expgap1=r(expgap1) expgap2=r(expgap2) expgap3=r(expgap3) expgap4=r(expgap4) expgap5=r(expgap5) expgap6=r(expgap6) expgap7=r(expgap7) expgap8=r(expgap8) /*
	*/ expgap9=r(expgap9) expgap10=r(expgap10) expgap11=r(expgap11) expgap12=r(expgap12) expgap13=r(expgap13) expgap14=r(expgap14) expgap15=r(expgap15) expgap16=r(expgap16) expgap17=r(expgap17) /*
	*/ expgap18=r(expgap18) expgap19=r(expgap20) expgap19=r(expgap20) expgap21=r(expgap21) expgap22=r(expgap22) expgap23=r(expgap23) expgap24=r(expgap24) expgap25=r(expgap25) expgap26=r(expgap26) expgap27=r(expgap27) expgap8=r(expgap28) /*
	*/ expgap29=r(expgap29) expgap30=r(expgap30) expgap31=r(expgap31) expgap32=r(expgap32) expgap33=r(expgap33) expgap34=r(expgap34) expgap35=r(expgap35) expgap36=r(expgap36) expgap37=r(expgap37) /*
	*/ expgap38=r(expgap38) expgap39=r(expgap39) expgap40=r(expgap40) expgap41=r(expgap41) expgap42=r(expgap42) expgap43=r(expgap43) expgap44=r(expgap44) expgap45=r(expgap45) expgap46=r(expgap46) expgap47=r(expgap47) expgap48=r(expgap48) /*
	*/ expgap49=r(expgap49) expgap50=r(expgap50) expgap51=r(expgap51) expgap52=r(expgap52) expgap53=r(expgap53) expgap54=r(expgap54) expgap55=r(expgap55) expgap56=r(expgap56) expgap57=r(expgap57) /*
	*/ expgap58=r(expgap58) expgap59=r(expgap59) expgap60=r(expgap60) expgap61=r(expgap61) expgap62=r(expgap62) expgap63=r(expgap63) expgap64=r(expgap64) expgap65=r(expgap65) expgap66=r(expgap66) expgap67=r(expgap67) expgap68=r(expgap68) /*
	*/ expgap69=r(expgap69) expgap70=r(expgap70) expgap71=r(expgap71) expgap72=r(expgap72) expgap73=r(expgap73) expgap74=r(expgap74) expgap75=r(expgap75) expgap76=r(expgap76) expgap77=r(expgap77) /*
	*/ expgap78=r(expgap78) expgap79=r(expgap79) expgap80=r(expgap80) expgap81=r(expgap81) expgap82=r(expgap82) expgap83=r(expgap83) expgap84=r(expgap84) expgap85=r(expgap85) expgap86=r(expgap86) expgap87=r(expgap87) expgap88=r(expgap88) /*
	*/ expgap89=r(expgap89) expgap90=r(expgap90) expgap91=r(expgap91) expgap92=r(expgap92) expgap93=r(expgap93) expgap94=r(expgap94) expgap95=r(expgap95) expgap96=r(expgap96) expgap97=r(expgap97) /*
	*/ expgap98=r(expgap98) expgap99=r(expgap99) unexpgap1=r(unexpgap1) unexpgap2=r(unexpgap2) unexpgap3=r(unexpgap3) unexpgap4=r(unexpgap4) unexpgap5=r(unexpgap5) unexpgap6=r(unexpgap6) unexpgap7=r(unexpgap7) unexpgap8=r(unexpgap8) /*
	*/ unexpgap9=r(unexpgap9) unexpgap10=r(unexpgap10) unexpgap11=r(unexpgap11) unexpgap12=r(unexpgap12) unexpgap13=r(unexpgap13) unexpgap14=r(unexpgap14) unexpgap15=r(unexpgap15) unexpgap16=r(unexpgap16) unexpgap17=r(unexpgap17) /*
	*/ unexpgap18=r(unexpgap18) unexpgap19=r(unexpgap20) unexpgap19=r(unexpgap20) unexpgap21=r(unexpgap21) unexpgap22=r(unexpgap22) unexpgap23=r(unexpgap23) unexpgap24=r(unexpgap24) unexpgap25=r(unexpgap25) unexpgap26=r(unexpgap26) unexpgap27=r(unexpgap27) unexpgap8=r(unexpgap28) /*
	*/ unexpgap29=r(unexpgap29) unexpgap30=r(unexpgap30) unexpgap31=r(unexpgap31) unexpgap32=r(unexpgap32) unexpgap33=r(unexpgap33) unexpgap34=r(unexpgap34) unexpgap35=r(unexpgap35) unexpgap36=r(unexpgap36) unexpgap37=r(unexpgap37) /*
	*/ unexpgap38=r(unexpgap38) unexpgap39=r(unexpgap39) unexpgap40=r(unexpgap40) unexpgap41=r(unexpgap41) unexpgap42=r(unexpgap42) unexpgap43=r(unexpgap43) unexpgap44=r(unexpgap44) unexpgap45=r(unexpgap45) unexpgap46=r(unexpgap46) unexpgap47=r(unexpgap47) unexpgap48=r(unexpgap48) /*
	*/ unexpgap49=r(unexpgap49) unexpgap50=r(unexpgap50) unexpgap51=r(unexpgap51) unexpgap52=r(unexpgap52) unexpgap53=r(unexpgap53) unexpgap54=r(unexpgap54) unexpgap55=r(unexpgap55) unexpgap56=r(unexpgap56) unexpgap57=r(unexpgap57) /*
	*/ unexpgap58=r(unexpgap58) unexpgap59=r(unexpgap59) unexpgap60=r(unexpgap60) unexpgap61=r(unexpgap61) unexpgap62=r(unexpgap62) unexpgap63=r(unexpgap63) unexpgap64=r(unexpgap64) unexpgap65=r(unexpgap65) unexpgap66=r(unexpgap66) unexpgap67=r(unexpgap67) unexpgap68=r(unexpgap68) /*
	*/ unexpgap69=r(unexpgap69) unexpgap70=r(unexpgap70) unexpgap71=r(unexpgap71) unexpgap72=r(unexpgap72) unexpgap73=r(unexpgap73) unexpgap74=r(unexpgap74) unexpgap75=r(unexpgap75) unexpgap76=r(unexpgap76) unexpgap77=r(unexpgap77) /*
	*/ unexpgap78=r(unexpgap78) unexpgap79=r(unexpgap79) unexpgap80=r(unexpgap80) unexpgap81=r(unexpgap81) unexpgap82=r(unexpgap82) unexpgap83=r(unexpgap83) unexpgap84=r(unexpgap84) unexpgap85=r(unexpgap85) unexpgap86=r(unexpgap86) unexpgap87=r(unexpgap87) unexpgap88=r(unexpgap88) /*
	*/ unexpgap89=r(unexpgap89) unexpgap90=r(unexpgap90) unexpgap91=r(unexpgap91) unexpgap92=r(unexpgap92) unexpgap93=r(unexpgap93) unexpgap94=r(unexpgap94) unexpgap95=r(unexpgap95) unexpgap96=r(unexpgap96) unexpgap97=r(unexpgap97) /*
	*/ unexpgap98=r(unexpgap98) unexpgap99=r(unexpgap99), reps(`reps') dots saving(logs/gaps) replace 
}
if `"`pooled'"'!="" {
	simulate "gengap1 p" ovgap1=r(ovgap1) ovgap2=r(ovgap2) ovgap3=r(ovgap3) ovgap4=r(ovgap4) ovgap5=r(ovgap5) ovgap6=r(ovgap6) ovgap7=r(ovgap7) ovgap8=r(ovgap8) /*
	*/ ovgap9=r(ovgap9) ovgap10=r(ovgap10) ovgap11=r(ovgap11) ovgap12=r(ovgap12) ovgap13=r(ovgap13) ovgap14=r(ovgap14) ovgap15=r(ovgap15) ovgap16=r(ovgap16) ovgap17=r(ovgap17) /*
	*/ ovgap18=r(ovgap18) ovgap19=r(ovgap20) ovgap19=r(ovgap20) ovgap21=r(ovgap21) ovgap22=r(ovgap22) ovgap23=r(ovgap23) ovgap24=r(ovgap24) ovgap25=r(ovgap25) ovgap26=r(ovgap26) ovgap27=r(ovgap27) ovgap8=r(ovgap28) /*
	*/ ovgap29=r(ovgap29) ovgap30=r(ovgap30) ovgap31=r(ovgap31) ovgap32=r(ovgap32) ovgap33=r(ovgap33) ovgap34=r(ovgap34) ovgap35=r(ovgap35) ovgap36=r(ovgap36) ovgap37=r(ovgap37) /*
	*/ ovgap38=r(ovgap38) ovgap39=r(ovgap39) ovgap40=r(ovgap40) ovgap41=r(ovgap41) ovgap42=r(ovgap42) ovgap43=r(ovgap43) ovgap44=r(ovgap44) ovgap45=r(ovgap45) ovgap46=r(ovgap46) ovgap47=r(ovgap47) ovgap48=r(ovgap48) /*
	*/ ovgap49=r(ovgap49) ovgap50=r(ovgap50) ovgap51=r(ovgap51) ovgap52=r(ovgap52) ovgap53=r(ovgap53) ovgap54=r(ovgap54) ovgap55=r(ovgap55) ovgap56=r(ovgap56) ovgap57=r(ovgap57) /*
	*/ ovgap58=r(ovgap58) ovgap59=r(ovgap59) ovgap60=r(ovgap60) ovgap61=r(ovgap61) ovgap62=r(ovgap62) ovgap63=r(ovgap63) ovgap64=r(ovgap64) ovgap65=r(ovgap65) ovgap66=r(ovgap66) ovgap67=r(ovgap67) ovgap68=r(ovgap68) /*
	*/ ovgap69=r(ovgap69) ovgap70=r(ovgap70) ovgap71=r(ovgap71) ovgap72=r(ovgap72) ovgap73=r(ovgap73) ovgap74=r(ovgap74) ovgap75=r(ovgap75) ovgap76=r(ovgap76) ovgap77=r(ovgap77) /*
	*/ ovgap78=r(ovgap78) ovgap79=r(ovgap79) ovgap80=r(ovgap80) ovgap81=r(ovgap81) ovgap82=r(ovgap82) ovgap83=r(ovgap83) ovgap84=r(ovgap84) ovgap85=r(ovgap85) ovgap86=r(ovgap86) ovgap87=r(ovgap87) ovgap88=r(ovgap88) /*
	*/ ovgap89=r(ovgap89) ovgap90=r(ovgap90) ovgap91=r(ovgap91) ovgap92=r(ovgap92) ovgap93=r(ovgap93) ovgap94=r(ovgap94) ovgap95=r(ovgap95) ovgap96=r(ovgap96) ovgap97=r(ovgap97) /*
	*/ ovgap98=r(ovgap98) ovgap99=r(ovgap99) expgap1=r(expgap1) expgap2=r(expgap2) expgap3=r(expgap3) expgap4=r(expgap4) expgap5=r(expgap5) expgap6=r(expgap6) expgap7=r(expgap7) expgap8=r(expgap8) /*
	*/ expgap9=r(expgap9) expgap10=r(expgap10) expgap11=r(expgap11) expgap12=r(expgap12) expgap13=r(expgap13) expgap14=r(expgap14) expgap15=r(expgap15) expgap16=r(expgap16) expgap17=r(expgap17) /*
	*/ expgap18=r(expgap18) expgap19=r(expgap20) expgap19=r(expgap20) expgap21=r(expgap21) expgap22=r(expgap22) expgap23=r(expgap23) expgap24=r(expgap24) expgap25=r(expgap25) expgap26=r(expgap26) expgap27=r(expgap27) expgap8=r(expgap28) /*
	*/ expgap29=r(expgap29) expgap30=r(expgap30) expgap31=r(expgap31) expgap32=r(expgap32) expgap33=r(expgap33) expgap34=r(expgap34) expgap35=r(expgap35) expgap36=r(expgap36) expgap37=r(expgap37) /*
	*/ expgap38=r(expgap38) expgap39=r(expgap39) expgap40=r(expgap40) expgap41=r(expgap41) expgap42=r(expgap42) expgap43=r(expgap43) expgap44=r(expgap44) expgap45=r(expgap45) expgap46=r(expgap46) expgap47=r(expgap47) expgap48=r(expgap48) /*
	*/ expgap49=r(expgap49) expgap50=r(expgap50) expgap51=r(expgap51) expgap52=r(expgap52) expgap53=r(expgap53) expgap54=r(expgap54) expgap55=r(expgap55) expgap56=r(expgap56) expgap57=r(expgap57) /*
	*/ expgap58=r(expgap58) expgap59=r(expgap59) expgap60=r(expgap60) expgap61=r(expgap61) expgap62=r(expgap62) expgap63=r(expgap63) expgap64=r(expgap64) expgap65=r(expgap65) expgap66=r(expgap66) expgap67=r(expgap67) expgap68=r(expgap68) /*
	*/ expgap69=r(expgap69) expgap70=r(expgap70) expgap71=r(expgap71) expgap72=r(expgap72) expgap73=r(expgap73) expgap74=r(expgap74) expgap75=r(expgap75) expgap76=r(expgap76) expgap77=r(expgap77) /*
	*/ expgap78=r(expgap78) expgap79=r(expgap79) expgap80=r(expgap80) expgap81=r(expgap81) expgap82=r(expgap82) expgap83=r(expgap83) expgap84=r(expgap84) expgap85=r(expgap85) expgap86=r(expgap86) expgap87=r(expgap87) expgap88=r(expgap88) /*
	*/ expgap89=r(expgap89) expgap90=r(expgap90) expgap91=r(expgap91) expgap92=r(expgap92) expgap93=r(expgap93) expgap94=r(expgap94) expgap95=r(expgap95) expgap96=r(expgap96) expgap97=r(expgap97) /*
	*/ expgap98=r(expgap98) expgap99=r(expgap99) unexpgap1=r(unexpgap1) unexpgap2=r(unexpgap2) unexpgap3=r(unexpgap3) unexpgap4=r(unexpgap4) unexpgap5=r(unexpgap5) unexpgap6=r(unexpgap6) unexpgap7=r(unexpgap7) unexpgap8=r(unexpgap8) /*
	*/ unexpgap9=r(unexpgap9) unexpgap10=r(unexpgap10) unexpgap11=r(unexpgap11) unexpgap12=r(unexpgap12) unexpgap13=r(unexpgap13) unexpgap14=r(unexpgap14) unexpgap15=r(unexpgap15) unexpgap16=r(unexpgap16) unexpgap17=r(unexpgap17) /*
	*/ unexpgap18=r(unexpgap18) unexpgap19=r(unexpgap20) unexpgap19=r(unexpgap20) unexpgap21=r(unexpgap21) unexpgap22=r(unexpgap22) unexpgap23=r(unexpgap23) unexpgap24=r(unexpgap24) unexpgap25=r(unexpgap25) unexpgap26=r(unexpgap26) unexpgap27=r(unexpgap27) unexpgap8=r(unexpgap28) /*
	*/ unexpgap29=r(unexpgap29) unexpgap30=r(unexpgap30) unexpgap31=r(unexpgap31) unexpgap32=r(unexpgap32) unexpgap33=r(unexpgap33) unexpgap34=r(unexpgap34) unexpgap35=r(unexpgap35) unexpgap36=r(unexpgap36) unexpgap37=r(unexpgap37) /*
	*/ unexpgap38=r(unexpgap38) unexpgap39=r(unexpgap39) unexpgap40=r(unexpgap40) unexpgap41=r(unexpgap41) unexpgap42=r(unexpgap42) unexpgap43=r(unexpgap43) unexpgap44=r(unexpgap44) unexpgap45=r(unexpgap45) unexpgap46=r(unexpgap46) unexpgap47=r(unexpgap47) unexpgap48=r(unexpgap48) /*
	*/ unexpgap49=r(unexpgap49) unexpgap50=r(unexpgap50) unexpgap51=r(unexpgap51) unexpgap52=r(unexpgap52) unexpgap53=r(unexpgap53) unexpgap54=r(unexpgap54) unexpgap55=r(unexpgap55) unexpgap56=r(unexpgap56) unexpgap57=r(unexpgap57) /*
	*/ unexpgap58=r(unexpgap58) unexpgap59=r(unexpgap59) unexpgap60=r(unexpgap60) unexpgap61=r(unexpgap61) unexpgap62=r(unexpgap62) unexpgap63=r(unexpgap63) unexpgap64=r(unexpgap64) unexpgap65=r(unexpgap65) unexpgap66=r(unexpgap66) unexpgap67=r(unexpgap67) unexpgap68=r(unexpgap68) /*
	*/ unexpgap69=r(unexpgap69) unexpgap70=r(unexpgap70) unexpgap71=r(unexpgap71) unexpgap72=r(unexpgap72) unexpgap73=r(unexpgap73) unexpgap74=r(unexpgap74) unexpgap75=r(unexpgap75) unexpgap76=r(unexpgap76) unexpgap77=r(unexpgap77) /*
	*/ unexpgap78=r(unexpgap78) unexpgap79=r(unexpgap79) unexpgap80=r(unexpgap80) unexpgap81=r(unexpgap81) unexpgap82=r(unexpgap82) unexpgap83=r(unexpgap83) unexpgap84=r(unexpgap84) unexpgap85=r(unexpgap85) unexpgap86=r(unexpgap86) unexpgap87=r(unexpgap87) unexpgap88=r(unexpgap88) /*
	*/ unexpgap89=r(unexpgap89) unexpgap90=r(unexpgap90) unexpgap91=r(unexpgap91) unexpgap92=r(unexpgap92) unexpgap93=r(unexpgap93) unexpgap94=r(unexpgap94) unexpgap95=r(unexpgap95) unexpgap96=r(unexpgap96) unexpgap97=r(unexpgap97) /*
	*/ unexpgap98=r(unexpgap98) unexpgap99=r(unexpgap99), reps(`reps') dots saving(logs/gaps) replace 
}

* Predictions, standard errors and differentials 

gen olscoeff1 = olsdiff

forval i = 1/99 {

	su ovgap`i'
	if `i'==1 {
		gen pred1 = r(mean) if _n==`i'
		gen se_pred1 = r(sd) if _n==`i'
		gen rawgap = raw`i' if _n==`i'
	} 
	else {
		replace pred1 = r(mean) if _n==`i'
		replace se_pred1 = r(sd) if _n==`i'
		replace rawgap = raw`i' if _n==`i'
}
	
}

forval i = 1/99 {

	su expgap`i'
	if `i'==1 {
		gen chars1 = r(mean) if _n==`i'
		gen se_chars1 = r(sd) if _n==`i'
		} 
	else {
		replace chars1 = r(mean) if _n==`i'
		replace se_chars1 = r(sd) if _n==`i'
}
	
}



forval i = 1/99 {

	su unexpgap`i'
	if `i'==1 {
		gen coef1 = r(mean) if _n==`i'
		gen se_coef1 = r(sd) if _n==`i'
		gen loconf1 = coef1 - 1.96 * r(sd) if _n==`i'
		gen hiconf1 = coef1 + 1.96 * r(sd) if _n==`i'
	} 
	else {
		replace coef1 = r(mean) if _n==`i'
		replace se_coef1 = r(sd) if _n==`i'
		replace loconf1 = coef1 - 1.96 * r(sd) if _n==`i'
		replace hiconf1 = coef1 + 1.96 * r(sd) if _n==`i'
}
	
}
capture log c
if `"`adjust'"'!="" {
	log using results/`filename'_sel.log, replace
}
else{
	log using results/`filename'.log, replace
}
* Differentials

scalar li olsdiff
scalar li se_olsdiff

list rawgap pred1 se_pred1 chars1 se_chars1 coef1 se_coef1 in 1/99

gen q = _n/100
	replace q = . if q>0.99 /* Quintile number for graph */

log c

if `"`adjust'"'!="" {	
	twoway connected coef1 hiconf1 loconf1 olscoeff1 rawgap chars1 pred1 q, msymbol(o p p p p o o) mcolor(. . . . . gs10 .)  sch(sami) clpattern(solid dash dash dot "-." "." "__.") /*
	*/ xtitle("Quantile") ytitle("Gap") legend(on)/*
	*/ legend(label(1 "Coefficients") label(2 "Coef 95% confidence intervals") label(4 "OLS") label(5 "Raw gap") label(6 "Characteristics") label(7 "Predicted gap") order(1 2 4 5 6 7) position(3)) /*
	*/ xlabel(0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9) /*ylabel(-0.1 0.0 0.1 0.2 0.3 0.4 0.5 0.6) yscale(r(-0.1 0.6))*//*
	*/ saving(results/`filename'_sel.gph, replace)
}
else {
	twoway connected coef1 hiconf1 loconf1 olscoeff1 rawgap chars1 pred1 q, msymbol(o p p p p o o) mcolor(. . . . . gs10 .)  sch(sami) clpattern(solid dash dash dot "-." "." "__.") /*
	*/ xtitle("Quantile") ytitle("Gap") legend(on)/*
	*/ legend(label(1 "Coefficients") label(2 "Coef 95% confidence intervals") label(4 "OLS") label(5 "Raw gap") label(6 "Characteristics") label(7 "Predicted gap") order(1 2 4 5 6 7) position(3)) /*
	*/ xlabel(0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9) /*ylabel(-0.1 0.0 0.1 0.2 0.3 0.4 0.5 0.6) yscale(r(-0.1 0.6))*//*
	*/ saving(results/`filename'.gph, replace)
}
}
else {
if `"`group1'"' != "" {
	simulate "gengap g" ovgap1=r(ovgap1) ovgap2=r(ovgap2) ovgap3=r(ovgap3) ovgap4=r(ovgap4) ovgap5=r(ovgap5) ovgap6=r(ovgap6) ovgap7=r(ovgap7) ovgap8=r(ovgap8) /*
	*/ ovgap9=r(ovgap9) ovgap10=r(ovgap10) ovgap11=r(ovgap11) ovgap12=r(ovgap12) ovgap13=r(ovgap13) ovgap14=r(ovgap14) ovgap15=r(ovgap15) ovgap16=r(ovgap16) ovgap17=r(ovgap17) /*
	*/ ovgap18=r(ovgap18) ovgap19=r(ovgap19) expgap1=r(expgap1) expgap2=r(expgap2) expgap3=r(expgap3) expgap4=r(expgap4) expgap5=r(expgap5) expgap6=r(expgap6) expgap7=r(expgap7) expgap8=r(expgap8) /*
	*/ expgap9=r(expgap9) expgap10=r(expgap10) expgap11=r(expgap11) expgap12=r(expgap12) expgap13=r(expgap13) expgap14=r(expgap14) expgap15=r(expgap15) expgap16=r(expgap16) expgap17=r(expgap17) /*
	*/ expgap18=r(expgap18) expgap19=r(expgap19) unexpgap1=r(unexpgap1) unexpgap2=r(unexpgap2) unexpgap3=r(unexpgap3) unexpgap4=r(unexpgap4) unexpgap5=r(unexpgap5) unexpgap6=r(unexpgap6) unexpgap7=r(unexpgap7) unexpgap8=r(unexpgap8) /*
	*/ unexpgap9=r(unexpgap9) unexpgap10=r(unexpgap10) unexpgap11=r(unexpgap11) unexpgap12=r(unexpgap12) unexpgap13=r(unexpgap13) unexpgap14=r(unexpgap14) unexpgap15=r(unexpgap15) unexpgap16=r(unexpgap16) unexpgap17=r(unexpgap17) /*
	*/ unexpgap18=r(unexpgap18) unexpgap19=r(unexpgap19), reps(`reps') dots saving(logs/gaps) replace 
}

if `"`incgen'"'!="" {
	simulate "gengap i" ovgap1=r(ovgap1) ovgap2=r(ovgap2) ovgap3=r(ovgap3) ovgap4=r(ovgap4) ovgap5=r(ovgap5) ovgap6=r(ovgap6) ovgap7=r(ovgap7) ovgap8=r(ovgap8) /*
	*/ ovgap9=r(ovgap9) ovgap10=r(ovgap10) ovgap11=r(ovgap11) ovgap12=r(ovgap12) ovgap13=r(ovgap13) ovgap14=r(ovgap14) ovgap15=r(ovgap15) ovgap16=r(ovgap16) ovgap17=r(ovgap17) /*
	*/ ovgap18=r(ovgap18) ovgap19=r(ovgap19) expgap1=r(expgap1) expgap2=r(expgap2) expgap3=r(expgap3) expgap4=r(expgap4) expgap5=r(expgap5) expgap6=r(expgap6) expgap7=r(expgap7) expgap8=r(expgap8) /*
	*/ expgap9=r(expgap9) expgap10=r(expgap10) expgap11=r(expgap11) expgap12=r(expgap12) expgap13=r(expgap13) expgap14=r(expgap14) expgap15=r(expgap15) expgap16=r(expgap16) expgap17=r(expgap17) /*
	*/ expgap18=r(expgap18) expgap19=r(expgap19) unexpgap1=r(unexpgap1) unexpgap2=r(unexpgap2) unexpgap3=r(unexpgap3) unexpgap4=r(unexpgap4) unexpgap5=r(unexpgap5) unexpgap6=r(unexpgap6) unexpgap7=r(unexpgap7) unexpgap8=r(unexpgap8) /*
	*/ unexpgap9=r(unexpgap9) unexpgap10=r(unexpgap10) unexpgap11=r(unexpgap11) unexpgap12=r(unexpgap12) unexpgap13=r(unexpgap13) unexpgap14=r(unexpgap14) unexpgap15=r(unexpgap15) unexpgap16=r(unexpgap16) unexpgap17=r(unexpgap17) /*
	*/ unexpgap18=r(unexpgap18) unexpgap19=r(unexpgap19), reps(`reps') dots saving(logs/gaps) replace 
}
if `"`pooled'"'!="" {
	simulate "gengap p" ovgap1=r(ovgap1) ovgap2=r(ovgap2) ovgap3=r(ovgap3) ovgap4=r(ovgap4) ovgap5=r(ovgap5) ovgap6=r(ovgap6) ovgap7=r(ovgap7) ovgap8=r(ovgap8) /*
	*/ ovgap9=r(ovgap9) ovgap10=r(ovgap10) ovgap11=r(ovgap11) ovgap12=r(ovgap12) ovgap13=r(ovgap13) ovgap14=r(ovgap14) ovgap15=r(ovgap15) ovgap16=r(ovgap16) ovgap17=r(ovgap17) /*
	*/ ovgap18=r(ovgap18) ovgap19=r(ovgap19) expgap1=r(expgap1) expgap2=r(expgap2) expgap3=r(expgap3) expgap4=r(expgap4) expgap5=r(expgap5) expgap6=r(expgap6) expgap7=r(expgap7) expgap8=r(expgap8) /*
	*/ expgap9=r(expgap9) expgap10=r(expgap10) expgap11=r(expgap11) expgap12=r(expgap12) expgap13=r(expgap13) expgap14=r(expgap14) expgap15=r(expgap15) expgap16=r(expgap16) expgap17=r(expgap17) /*
	*/ expgap18=r(expgap18) expgap19=r(expgap19) unexpgap1=r(unexpgap1) unexpgap2=r(unexpgap2) unexpgap3=r(unexpgap3) unexpgap4=r(unexpgap4) unexpgap5=r(unexpgap5) unexpgap6=r(unexpgap6) unexpgap7=r(unexpgap7) unexpgap8=r(unexpgap8) /*
	*/ unexpgap9=r(unexpgap9) unexpgap10=r(unexpgap10) unexpgap11=r(unexpgap11) unexpgap12=r(unexpgap12) unexpgap13=r(unexpgap13) unexpgap14=r(unexpgap14) unexpgap15=r(unexpgap15) unexpgap16=r(unexpgap16) unexpgap17=r(unexpgap17) /*
	*/ unexpgap18=r(unexpgap18) unexpgap19=r(unexpgap19), reps(`reps') dots saving(logs/gaps) replace 
}

* Predictions, standard errors and differentials 

gen olscoeff1 = olsdiff

forval i = 1/19 {

	su ovgap`i'
	if `i'==1 {
		gen pred1 = r(mean) if _n==`i'
		gen se_pred1 = r(sd) if _n==`i'
		gen rawgap = raw`i' if _n==`i'
	} 
	else {
		replace pred1 = r(mean) if _n==`i'
		replace se_pred1 = r(sd) if _n==`i'
		replace rawgap = raw`i' if _n==`i'
}
	
}

forval i = 1/19 {

	su expgap`i'
	if `i'==1 {
		gen chars1 = r(mean) if _n==`i'
		gen se_chars1 = r(sd) if _n==`i'
		} 
	else {
		replace chars1 = r(mean) if _n==`i'
		replace se_chars1 = r(sd) if _n==`i'
}
	
}



forval i = 1/19 {

	su unexpgap`i'
	if `i'==1 {
		gen coef1 = r(mean) if _n==`i'
		gen se_coef1 = r(sd) if _n==`i'
		gen loconf1 = coef1 - 1.96 * r(sd) if _n==`i'
		gen hiconf1 = coef1 + 1.96 * r(sd) if _n==`i'
	} 
	else {
		replace coef1 = r(mean) if _n==`i'
		replace se_coef1 = r(sd) if _n==`i'
		replace loconf1 = coef1 - 1.96 * r(sd) if _n==`i'
		replace hiconf1 = coef1 + 1.96 * r(sd) if _n==`i'
}
	
}
capture log c
if `"`adjust'"'!="" {
	log using results/`filename'_sel.log, replace
}
else{
	log using results/`filename'.log, replace
}
* Differentials

scalar li olsdiff
scalar li se_olsdiff

list rawgap pred1 se_pred1 chars1 se_chars1 coef1 se_coef1 in 1/20

gen q = _n/20
	replace q = . if q>0.95 /* Quintile number for graph */

log c

if `"`adjust'"'!="" {	
	twoway connected coef1 hiconf1 loconf1 olscoeff1 rawgap chars1 pred1 q, msymbol(o p p p p o o) mcolor(. . . . . gs10 .)  sch(sami) clpattern(solid dash dash dot "-." "." "__.") /*
	*/ xtitle("Quantile") ytitle("Gap") legend(on)/*
	*/ legend(label(1 "Coefficients") label(2 "Coef 95% confidence intervals") label(4 "OLS") label(5 "Raw gap") label(6 "Characteristics") label(7 "Predicted gap") order(1 2 4 5 6 7) position(3)) /*
	*/ xlabel(0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9) /*ylabel(-0.1 0.0 0.1 0.2 0.3 0.4 0.5 0.6) yscale(r(-0.1 0.6))*//*
	*/ saving(results/`filename'_sel.gph, replace)
}
else {
	twoway connected coef1 hiconf1 loconf1 olscoeff1 rawgap chars1 pred1 q, msymbol(o p p p p o o) mcolor(. . . . . gs10 .)  sch(sami) clpattern(solid dash dash dot "-." "." "__.") /*
	*/ xtitle("Quantile") ytitle("Gap") legend(on)/*
	*/ legend(label(1 "Coefficients") label(2 "Coef 95% confidence intervals") label(4 "OLS") label(5 "Raw gap") label(6 "Characteristics") label(7 "Predicted gap") order(1 2 4 5 6 7) position(3)) /*
	*/ xlabel(0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9) /*ylabel(-0.1 0.0 0.1 0.2 0.3 0.4 0.5 0.6) yscale(r(-0.1 0.6))*//*
	*/ saving(results/`filename'.gph, replace)
}
}
*---------------------------------
* Clean up
*---------------------------------

forval i = 1/99 {
capture erase tmp/xfbf`i'.dta
capture erase tmp/xmbm`i'.dta
capture erase tmp/xfbm`i'.dta
capture erase tmp/xmbp`i'.dta
capture erase tmp/xfbp`i'.dta
}

capture erase tmp/xfbf.dta
capture erase tmp/xmbm.dta
capture erase tmp/xfbm.dta
capture erase tmp/xmbp.dta
capture erase tmp/xfbp.dta

clear
estimates clear

end



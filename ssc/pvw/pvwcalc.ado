*pvwcalc is a subroutine called by pvw, which implements predictive value weighting, as proposed by Lyles and Lin, Stats in Med, 2010; 29: 2297-2309
*version 1.1
*Jonathan Bartlett
*j.w.bartlett@bath.ac.uk

*this program actually runs PVW
capture program drop pvwcalc
program define pvwcalc, eclass
version 11.0
syntax varlist(fv), casesens(real) casespec(real) contsens(real) contspec(real) z(varname) y(varname) [c(varlist fv)]
preserve
logistic `z' `varlist'
predict piycstar, pr

*this is to ensure that the specified sens and spec do not conflict with the observed data
*following the restrictions given by Lyles 2010
gen se=`casesens'
replace se=`contsens' if `y'==0
replace se=piycstar+0.001 if piycstar>=se
gen sp=`casespec'
replace sp=`contspec' if `y'==0
replace sp=1-piycstar+0.001 if piycstar<=(1-sp)

gen term1=(se-1)*piycstar*(se*(piycstar-1))^(-1)
gen term2=(sp-1)*(piycstar-1)*(sp*piycstar)^(-1)
gen det=1/(term1*term2-1)
gen ppv = det*(term2-1)
gen npv = det*(term1-1)

expand 2, gen(truecov)

gen wgt=ppv if truecov==1 & `z'==1
replace wgt=1-ppv if truecov==0 & `z'==1
replace wgt=1-npv if truecov==1 & `z'==0
replace wgt=npv if truecov==0 & `z'==0

logistic `y' truecov `c' [pweight=wgt]
matrix B=e(b)
local sampsize = e(N)/2

restore
gen included=1
summ included
ereturn post B, obs(`sampsize') esample(included)

end

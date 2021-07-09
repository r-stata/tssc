program sampsi_sccs, rclass


*! version 1.3.0 Philip Ryan 2009-05-02
*! sample size estimation for self controlled case series design
*! adapted from: Musonda et al, Stats in Med 2006; 25:2618-2631 
*  binomial: based on Eqn (6) and (3)
*  signed root likelihood: based on Eqn (7) and (3)
*  SRL with age effects: based on Eqn (12) to give n, and on substituting [p_jay/1-SUM(p_jay)] 
*       for p_jay and p0=0 in Eqn (10) to give n1. 
*
*************
*  history  *
*************
*
*  version 1.0.0 2009-04-15 first posted on SSC
*  version 1.0.1 2009-04-21 temporarily disable n1 and n0 from age effects method [posted]
*  version 1.2.0 2009-05-01 fix n1 and n0 for age effects method (pers comm Paddy Farrington)
*  version 1.3.0 2009-05-02 further fix for age effects method (pers comm Paddy Farrington)
*
*!
*! syntax is:
*!
*! sampsi_sccs [anything] [, alpha(real 0.05) power(real 0.9) rho(real 2) 
*!   ONEsided MEthod(string)]
*!
*! where option [method] is one of binomial, SRL or age, and option [anything] must be ?

version 10

syntax [anything] [, Alpha(real 0.05) Power(real 0.9) RHO(real 2) ONEsided MEthod(string)]

if !inrange(`alpha',0,1) {
di _new as err "Alpha must lie between 0 and 1"
exit 198
}

if !inrange(`power',0,1) {
di _new as err "Power must lie between 0 and 1"
exit 198
}

if `rho' < 0 {
di _new as err "Rho must exceed 0"
exit 198
}


if "`anything'" != "" & "`anything'" != "?" {
      exit 198
}
if "`anything'" == "?" {
      which sampsi_sccs
      exit 0
}

local tail 2
if "`onesided'" != "" {
local tail 1
}

if "`method'" != "" & !inlist(lower(substr("`method'",1,3)), "bin", "srl", "age") {
di _new as err " invalid Method specified"
exit 198
}


if "`method'" == "" | lower(substr("`method'",1,3)) == "bin" {

* equation (6) and (3): Musonda et al Stats in Med 2006; 25:2618-2631 (page 2621)
* binomial method for self-controlled case series sample size

di _new
di _new in ye "Binomial method"
di _new(2) in ye "input " in wh "duration of post-exposure risk period (e.g.  2)" _col(75) _request(_w)
if `w' < 0 {
di _new as err "duration of risk must exceed 0"
exit 198
}

di in ye "input " in wh "duration of entire observation period (e.g.  200)" _col(75) _request(_W)
if `W' < 0 {
di _new as err "duration of observation period must exceed 0"
exit 198
}
if `w' > `W' {
di _new as err "risk period must not exceed total observation period"
exit 198
}

di in ye "input " in wh "proportion of subjects exposed at all during obs period (e.g. 1)" _col(75) _request(_p)
if `p' < 0 | `p' >1 {
di _new as err "proportion exposed must lie betweeen 0 and 1"
exit 198
}

local r = `w'/`W'
local num = ((invnormal(1-(`alpha'/`tail'))) + (abs(invnormal(1-`power'))))^2
local d1a = (`rho'*`r')/((`rho'*`r')+1 - `r')


local d1 = asin(sqrt(`d1a'))
local d2 = asin(sqrt(`r'))
local den = 4*((`d1' - `d2')^2)

local factor = (1+(`p'*`r'*(`rho'-1)))/(`p'*((`rho'*`r')+1-`r'))
local n1 = ceil(`num'/`den')
local n = ceil(`n1'*`factor')
local n0 = `n'-`n1'
di _new _dup(66) in ye "="
di in ye _dup(10) "=" " sample size for SCCS Design: binomial method " _dup(10) "="
di _dup(66) in ye "="
di _new in wh _skip(2) "`tail'-tailed alpha is:" _col(60) `alpha'
di _skip(2) "power is:" _col(60) `power'
di _skip(2) "relative incidence associated with exposure is:" _col(60) `rho'
di _skip(2) "post-exposure risk period is:" _col(60) `w'
di _new(2) in gr "  total number of events required in exposed subjects is:" _col(61) in ye `n1'
di _new(1)in gr  "  total number of events required in unexposed subjects is:" _col(61) in ye `n0'
di _new(1) in gr "  Total number of events required is:" _col(61) in ye `n'
di _dup(66) in ye "="

return scalar n_exp = `n1'
return scalar n_unexp = `n0'
return scalar n_total = `n'

} // end if for binomial





if lower("`method'") == "srl" {

* equation (7) and (3): Musonda et al Stats in Med 2006; 25:2618-2631 (page 2622)
* signed root likelihood method for self-controlled case series sample size

di _new
di _new in ye "Signed root likelihood method"
di _new(2) in ye "input " in wh "duration of post-exposure risk period (e.g.  2)" _col(75) _request(_w)
if `w' < 0 {
di _new as err "duration of risk must exceed 0"
exit 198
}

di in ye "input " in wh "duration of entire observation period (e.g.  200)" _col(75) _request(_W)
if `W' < 0 {
di _new as err "duration of observation period must exceed 0"
exit 198
}
if `w' > `W' {
di _new as err "risk period must not exceed total observation period"
exit 198
}

di in ye "input " in wh "proportion of subjects exposed at all during obs period (e.g. 1)" _col(75) _request(_p)
if `p' < 0 | `p' >1 {
di _new as err "proportion exposed must lie betweeen 0 and 1"
exit 198
}

local r = `w'/`W'
local b=ln(`rho')


local A11 = ((`rho'*`r')/((`rho'*`r')+1-`r'))*`b'
local A12 = ln((`rho'*`r')+1-`r')
local A1 = 2*(`A11' - `A12')

local B11 = ((`b')^2)*(`rho'*`r')*(1-`r')
local B12 = ((`rho'*`r')+1-`r')^2
local B1 = `B11'/(`A1'*`B12')

local num = ((invnormal(1-(`alpha'/`tail'))) + ((sqrt(`B1'))*(abs(invnormal(1-`power')))))^2
local den = `A1'

local factor = (1+(`p'*`r'*(`rho'-1)))/(`p'*((`rho'*`r')+1-`r'))
local n1 = ceil(`num'/`den')
local n = ceil(`n1'*`factor')
local n0 = `n'-`n1'

di _new _dup(66) in ye "="
di in ye _dup(3) "=" " sample size for SCCS Design: signed root likelihood method " _dup(3) "="
di _dup(66) in ye "="
di _new in wh _skip(2) "`tail'-tailed alpha is:" _col(60) `alpha'
di _skip(2) "power is:" _col(60) `power'
di _skip(2) "relative incidence associated with exposure is:" _col(60) `rho'
di _skip(2) "post-exposure risk period is:" _col(60) `w'
di _new(2) in gr "  total number of events required in exposed subjects is:" _col(61) in ye `n1'
di _new(1)in gr  "  total number of events required in unexposed subjects is:" _col(61) in ye `n0'
di _new(1) in gr "  Total number of events required is:" _col(61) in ye `n'
di _dup(66) in ye "="


return scalar n_exp = `n1'
return scalar n_unexp = `n0'
return scalar n_total = `n'

} // end if method is root




if lower(substr("`method'",1,3)) == "age" {

* equation (12) and (3): Musonda et al Stats in Med 2006; 25:2618-2631 (page 2625-6)
* signed root likelihood method for self-controlled case series sample size with age effects


di _new
di _new in ye "Signed root likelihood method controlling for age effects"

di _new
di in ye "input " in wh "number of age groups" _col(30) in ye " (e.g. 5)" _col(75) _request(_groups)
if `groups' <2 {
di _new as err " number of age groups must be at least 2"
exit 198
}

tempname K

matrix `K' = J(`groups',11,0)
forvalues i=1/`groups' {
mat `K'[`i',1] = `i'
}

di _new
mat `K'[1,2] = 1
forvalues i=2/`groups' {
di in ye "input " in wh "age specific incidence [relative to age group 1] in age group" in ye " `i'" _col(75) _request(_expd)
if `expd' <0 {
di _new as err " incidence must be non-negative"
exit 198
}
mat `K'[`i',2] = `expd'
mat `K'[`i',3] = ln(`expd')
}

di _new
forvalues i=1/`groups' {
di in ye "input " in wh "length of observation period for age group" in ye " `i'" _col(75) _request(_ejay)
if `ejay' <0 {
di _new as err " observation period must be non-negative"
exit 198
}

mat `K'[`i',4] = `ejay'
}

di _new
di in ye "input " in wh "post-exposure risk period [assumed the same for each group]" _col(75) _request(_estar)
if `estar' <0 {
di _new as err " risk period must be non-negative"
exit 198
}

forvalues i=1/`groups' {
mat `K'[`i',5] = `estar'
}

local rden = 0
forvalues i=1/`groups' {
local rden = `rden' + ((`K'[`i',2])*(`K'[`i',4]))
}

forvalues i=1/`groups' {
mat `K'[`i',6] = ((`K'[`i',2])*(`K'[`i',5]))/`rden'
}

forvalues i=1/`groups' {
mat `K'[`i',7] = (`rho'*`K'[`i',6]) / ((`rho'*`K'[`i',6]) +1-`K'[`i',6])
}

di _new
forvalues i=1/`groups' {
di in ye "input " in wh "proportion of subjects exposed during obs period in age group" in ye " `i'" _col(75) _request(_pjay)
if `pjay' < 0 | `pjay' >1 {
di _new as err "proportion exposed must lie betweeen 0 and 1"
exit 198
}
mat `K'[`i',8] = `pjay'
}


*** setup for n
local sumpjay = 0
forvalues i=1/`groups' {
local sumpjay = `sumpjay'+ `K'[`i',8]
}

if `sumpjay' >= 1 {
di _new as error "sum of proportions must be less than 1
exit 198
}
***


local p0 = 1-`sumpjay'


*** set up for n1
*
forvalues i=1/`groups' {
mat `K'[`i', 10] = `K'[`i',8]/`p0'
}
***

*** set up for n
local denvn = 0
forvalues i=1/`groups' {
local denvn = `denvn' + ( (`K'[`i',8]) * ( (`K'[`i',6]*`rho')+1-`K'[`i',6])  )
}

local denvn = `p0'+`denvn'

forvalues i=1/`groups' {
mat `K'[`i',9] = (`K'[`i',8]*((`K'[`i',6]*`rho')+1-`K'[`i',6]))/`denvn'
}
***


*** setup for n1
local denvn1 = 0
forvalues i=1/`groups' {
local denvn1 = `denvn1' + ( (`K'[`i',10]) * ( (`K'[`i',6]*`rho')+1-`K'[`i',6])  )
}

local denvn1 = 0 +`denvn1'

forvalues i=1/`groups' {
mat `K'[`i',11] = (`K'[`i',10]*((`K'[`i',6]*`rho')+1-`K'[`i',6]))/`denvn1'
}

***

*** setup for n
local hA =0
forvalues i=1/`groups' {
local hA = `hA'+ ( (`K'[`i',9]) * ( (`K'[`i',7]*ln(`rho')) - (ln((`K'[`i',6]*`rho')+1-`K'[`i',6] )) ) ) 
}
local A = 2*`hA'

local B1 = 0
forvalues i=1/`groups' {
local B1 = `B1' + ( `K'[`i',9] * `K'[`i',7]  * (1-`K'[`i',7])   )
}

local B = ((ln(`rho'))^2) * `B1'/`A'

local num = ((invnormal(1-(`alpha'/`tail'))) + ((sqrt(`B'))*(abs(invnormal(1-`power')))))^2
local den = `A'
***


*** setup for n1
local hA =0
forvalues i=1/`groups' {
local hA = `hA'+ ( (`K'[`i',11]) * ( (`K'[`i',7]*ln(`rho')) - (ln((`K'[`i',6]*`rho')+1-`K'[`i',6] )) ) ) 
}
local A = 2*`hA'

local B1 = 0
forvalues i=1/`groups' {
local B1 = `B1' + ( `K'[`i',11] * `K'[`i',7]  * (1-`K'[`i',7])   )
}

local B = ((ln(`rho'))^2) * `B1'/`A'

local num1 = ((invnormal(1-(`alpha'/`tail'))) + ((sqrt(`B'))*(abs(invnormal(1-`power')))))^2
local den1 = `A'
***

local n = ceil(`num'/`den')
local n1 = ceil(`num1'/`den1')
local n0 = `n'-`n1'

di _new _dup(66) in ye "="
di in ye _dup(10) "=" " sample size for SCCS Design with age effects " _dup(10) "="
di _dup(66) in ye "="
di _new in wh _skip(2) "`tail'-tailed alpha is:" _col(60) `alpha'
di _skip(2) "power is:" _col(60) `power'
di _skip(2) "relative incidence associated with exposure is:" _col(60) `rho'
di _skip(2) "common post-exposure risk period is:" _col(60) `estar'
di _new(2) in gr "  total number of events required in exposed subjects is:" _col(61) in ye `n1'
di _new(1)in gr  "  total number of events required in unexposed subjects is:" _col(61) in ye `n0'
di _new(1) in gr "  Total number of events required is:" _col(61) in ye `n'
di _dup(66) in ye "="


return scalar n_exp = `n1'
return scalar n_unexp = `n0'
return scalar n_total = `n'

} // end if method is age

end








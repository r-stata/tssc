program nlgmmcovearn
  version 10.0

* This programs estimates 8 non-linear GMM models
* for arbitrary number of years (specified in the year option)
* and arbitrary numbers of cohorts (specified in the cohort option)
* all models have factor(time) loadings on permanent and transitory
* 1 AR, no heterogeneity (model(1))
* 2 ARMA, no heterogeneity (model(2))
* 3 AR, random growth (model(3))
* 4 ARMA, random growth (model(4))
* 5 AR, random walk (model(5))
* 6 ARMA, random walk (model(6))
* 7 AR, random growth+random walk (model(7))
* 8 ARMA, random growth+random walk (cohort(n) model(8))


  
   syntax varlist [if] [,at(name) cohort(real $cc1) year(real $yy1) ///
 model(real $mm1)]


//retrieve parameters out of a matrix

* a=permanent variance
* r=rho
* l's and p's factor loadings
* v=variance of v
* e=variance of e
* t=theta
* w=variance of w

* This just counts the number of moments. First within cohort and then 
* Times each cohort


* Note nummoment=#cohorts*(#years+#years-1+#years-2..+1)

tempname num1 nummoment
scalar `num1'=0

local k=1
while `k'<=`year' {
scalar `num1'=`num1'+`k'
local ++k
}

scalar `nummoment'=`num1'* `cohort' 

* d1-k1 are dummies to pick out the right piece of nonlinear
* moment expression 

local kindex=1
while `kindex'<=`nummoment' {
  tempvar d`kindex'
gen double `d`kindex''=1 if _n==`kindex'
replace `d`kindex''=0 if `d`kindex''==.
*rename `d`kindex'' d`kindex'
local ++kindex
}










* Programme an AR model with no heterogeneity ///
*  (must specify model (1))

if `model'==1 {

local depmoment : word 1 of `varlist'

tempvar age age2
generate double `age'=1
generate double `age2'=1

tempname a r v e t b ab w


* Naming the time factor loadings
local k=1
while `k'<=`year' {
  tempvar l`k' p`k' 
local ++k
}

* Naming the Cohort factor loadings
local k=1
while `k'<=`cohort' {
  tempvar q`k' s`k' 
local ++k
}

scalar `a' = `at'[1,1]
scalar `r' =`at'[1,2]
scalar `v' =`at'[1,3]
scalar `e' =`at'[1,4]

local j=2
while `j'<=`year' {
local i=3+`j'
scalar `l`j'' =`at'[1,`i']
local ++j
}

local j=2
while `j'<=`year' {
local i=3+(`year'-1)+`j'
scalar `p`j'' =`at'[1,`i']
local ++j
}

local j=2
while `j'<=`cohort' {
local i=3+2*(`year'-1)+`j'
scalar `q`j'' =`at'[1,`i']
local ++j
}

local j=2
while `j'<=`cohort' {
local i=3+2*(`year'-1)+(`cohort'-1)+`j'
scalar `s`j'' =`at'[1,`i']
local ++j
}


scalar `b'=0
scalar `ab'=0
scalar `t'=0
scalar `q1'=1
scalar `s1'=1
scalar `p1' =1
scalar `l1' =1
scalar `w'=0


}



* Programme an ARMA model and no heterogeneity ///
*  (must specify model (2) and cohort(n)

else if `model'==2 {

local depmoment : word 1 of `varlist'

tempvar age age2
generate double `age'=1
generate double `age2'=1

tempname a r v e t b ab w


* Naming the time factor loadings
local k=1
while `k'<=`year' {
  tempname l`k' p`k' 
local ++k
}

* Naming the Cohort factor loadings
local k=1
while `k'<=`cohort' {
  tempname q`k' s`k' 
local ++k
}

scalar `a' = `at'[1,1]
scalar `r' =`at'[1,2]
scalar `v' =`at'[1,3]
scalar `e' =`at'[1,4]

local j=2
while `j'<=`year' {
local i=3+`j'
scalar `l`j'' =`at'[1,`i']
local ++j
}

local j=2
while `j'<=`year' {
local i=3+(`year'-1)+`j'
scalar `p`j'' =`at'[1,`i']
local ++j
}

local j=2
while `j'<=`cohort' {
local i=3+2*(`year'-1)+`j'
scalar `q`j'' =`at'[1,`i']
local ++j
}

local j=2
while `j'<=`cohort' {
local i=3+2*(`year'-1)+(`cohort'-1)+`j'
scalar `s`j'' =`at'[1,`i']
local ++j
}

local i=3+2*(`year'-1)+2*(`cohort'-1)+2
scalar `t'=`at'[1,`i']


scalar `b'=0
scalar `ab'=0
scalar `q1'=1
scalar `s1'=1
scalar `p1' =1
scalar `l1' =1
scalar `w'=0

}


* Programme an AR model with heterogeneity ///
*  (must specify model (3) and cohort(n)

else if `model'==3 {

local depmoment : word 1 of `varlist'
local age : word 2 of `varlist'
local age2 : word 3 of `varlist'


tempname a r v e t b ab w


* Naming the time factor loadings
local k=1
while `k'<=`year' {
  tempname l`k' p`k' 
local ++k
}

* Naming the Cohort factor loadings
local k=1
while `k'<=`cohort' {
  tempname q`k' s`k' 
local ++k
}



scalar `a' = `at'[1,1]
scalar `r' =`at'[1,2]
scalar `v' =`at'[1,3]
scalar `e' =`at'[1,4]

local j=2
while `j'<=`year' {
local i=3+`j'
scalar `l`j'' =`at'[1,`i']
local ++j
}

local j=2
while `j'<=`year' {
local i=3+(`year'-1)+`j'
scalar `p`j'' =`at'[1,`i']
local ++j
}

local j=2
while `j'<=`cohort' {
local i=3+2*(`year'-1)+`j'
scalar `q`j'' =`at'[1,`i']
local ++j
}

local j=2
while `j'<=`cohort' {
local i=3+2*(`year'-1)+(`cohort'-1)+`j'
scalar `s`j'' =`at'[1,`i']
local ++j
}

local i=3+2*(`year'-1)+2*(`cohort'-1)+2
scalar `b'=`at'[1,`i']

local i=3+2*(`year'-1)+2*(`cohort'-1)+3
scalar `ab' =`at'[1,`i']



scalar `t'=0

scalar `q1'=1
scalar `s1'=1
scalar `p1' =1
scalar `l1' =1
scalar `w'=0


}



* Programme an ARMA model with heterogeneity ///
*  (must specify model (4) and cohort(n)

else if `model'==4 {

local depmoment : word 1 of `varlist'
local age : word 2 of `varlist'
local age2 : word 3 of `varlist'


tempname a r v e t b ab w


* Naming the time factor loadings
local k=1
while `k'<=`year' {
  tempname l`k' p`k' 
local ++k
}

* Naming the Cohort factor loadings
local k=1
while `k'<=`cohort' {
  tempname q`k' s`k' 
local ++k
}



scalar `a' = `at'[1,1]
scalar `r' =`at'[1,2]
scalar `v' =`at'[1,3]
scalar `e' =`at'[1,4]

local j=2
while `j'<=`year' {
local i=3+`j'
scalar `l`j'' =`at'[1,`i']
local ++j
}

local j=2
while `j'<=`year' {
local i=3+(`year'-1)+`j'
scalar `p`j'' =`at'[1,`i']
local ++j
}

local j=2
while `j'<=`cohort' {
local i=3+2*(`year'-1)+`j'
scalar `q`j'' =`at'[1,`i']
local ++j
}

local j=2
while `j'<=`cohort' {
local i=3+2*(`year'-1)+(`cohort'-1)+`j'
scalar `s`j'' =`at'[1,`i']
local ++j
}

local i=3+2*(`year'-1)+2*(`cohort'-1)+2
scalar `b'=`at'[1,`i']

local i=3+2*(`year'-1)+2*(`cohort'-1)+3
scalar `ab' =`at'[1,`i']

local i=3+2*(`year'-1)+2*(`cohort'-1)+4
scalar `t' =`at'[1,`i']



scalar `q1'=1
scalar `s1'=1
scalar `p1' =1
scalar `l1' =1
scalar `w'=0


}



* Programme an AR model with random walk ///
*  (must specify model (5) and cohort(n)

else if `model'==5 {

local depmoment : word 1 of `varlist'
local age : word 2 of `varlist'
local age2 : word 3 of `varlist'


tempname a r v e t b ab w


* Naming the time factor loadings
local k=1
while `k'<=`year' {
  tempname l`k' p`k' 
local ++k
}

* Naming the Cohort factor loadings
local k=1
while `k'<=`cohort' {
  tempname q`k' s`k' 
local ++k
}



scalar `a' = `at'[1,1]
scalar `r' =`at'[1,2]
scalar `v' =`at'[1,3]
scalar `e' =`at'[1,4]

local j=2
while `j'<=`year' {
local i=3+`j'
scalar `l`j'' =`at'[1,`i']
local ++j
}

local j=2
while `j'<=`year' {
local i=3+(`year'-1)+`j'
scalar `p`j'' =`at'[1,`i']
local ++j
}

local j=2
while `j'<=`cohort' {
local i=3+2*(`year'-1)+`j'
scalar `q`j'' =`at'[1,`i']
local ++j
}

local j=2
while `j'<=`cohort' {
local i=3+2*(`year'-1)+(`cohort'-1)+`j'
scalar `s`j'' =`at'[1,`i']
local ++j
}

local i=3+2*(`year'-1)+2*(`cohort'-1)+2
scalar `w'=`at'[1,`i']


scalar `t'=0

scalar `q1'=1
scalar `s1'=1
scalar `p1' =1
scalar `l1' =1
scalar `b'=0
scalar `ab'=0


}



* Programme an ARMA model with random walk ///
*  (must specify model (6) and cohort(n)

else if `model'==6 {

local depmoment : word 1 of `varlist'
local age : word 2 of `varlist'
local age2 : word 3 of `varlist'


tempname a r v e t b ab w


* Naming the time factor loadings
local k=1
while `k'<=`year' {
  tempname l`k' p`k' 
local ++k
}

* Naming the Cohort factor loadings
local k=1
while `k'<=`cohort' {
  tempname q`k' s`k' 
local ++k
}



scalar `a' = `at'[1,1]
scalar `r' =`at'[1,2]
scalar `v' =`at'[1,3]
scalar `e' =`at'[1,4]

local j=2
while `j'<=`year' {
local i=3+`j'
scalar `l`j'' =`at'[1,`i']
local ++j
}

local j=2
while `j'<=`year' {
local i=3+(`year'-1)+`j'
scalar `p`j'' =`at'[1,`i']
local ++j
}

local j=2
while `j'<=`cohort' {
local i=3+2*(`year'-1)+`j'
scalar `q`j'' =`at'[1,`i']
local ++j
}

local j=2
while `j'<=`cohort' {
local i=3+2*(`year'-1)+(`cohort'-1)+`j'
scalar `s`j'' =`at'[1,`i']
local ++j
}

local i=3+2*(`year'-1)+2*(`cohort'-1)+2
scalar `w'=`at'[1,`i']

local i=3+2*(`year'-1)+2*(`cohort'-1)+3
scalar `t' =`at'[1,`i']



scalar `q1'=1
scalar `s1'=1
scalar `p1' =1
scalar `l1' =1
scalar `b'=0
scalar `ab'=0


}



* Programme an AR model with heterogeneity & rw///
*  (must specify model (7) and cohort(n)

else if `model'==7 {

local depmoment : word 1 of `varlist'
local age : word 2 of `varlist'
local age2 : word 3 of `varlist'


tempname a r v e t b ab w


* Naming the time factor loadings
local k=1
while `k'<=`year' {
  tempname l`k' p`k' 
local ++k
}

* Naming the Cohort factor loadings
local k=1
while `k'<=`cohort' {
  tempname q`k' s`k' 
local ++k
}



scalar `a' = `at'[1,1]
scalar `r' =`at'[1,2]
scalar `v' =`at'[1,3]
scalar `e' =`at'[1,4]

local j=2
while `j'<=`year' {
local i=3+`j'
scalar `l`j'' =`at'[1,`i']
local ++j
}

local j=2
while `j'<=`year' {
local i=3+(`year'-1)+`j'
scalar `p`j'' =`at'[1,`i']
local ++j
}

local j=2
while `j'<=`cohort' {
local i=3+2*(`year'-1)+`j'
scalar `q`j'' =`at'[1,`i']
local ++j
}

local j=2
while `j'<=`cohort' {
local i=3+2*(`year'-1)+(`cohort'-1)+`j'
scalar `s`j'' =`at'[1,`i']
local ++j
}

local i=3+2*(`year'-1)+2*(`cohort'-1)+2
scalar `b'=`at'[1,`i']

local i=3+2*(`year'-1)+2*(`cohort'-1)+3
scalar `ab' =`at'[1,`i']

local i=3+2*(`year'-1)+2*(`cohort'-1)+4
scalar `w' =`at'[1,`i']



scalar `t'=0

scalar `q1'=1
scalar `s1'=1
scalar `p1' =1
scalar `l1' =1


}



* Programme an ARMA model with heterogeneity & rw///
*  (must specify model (8) and cohort(n)

else if `model'==8 {

local depmoment : word 1 of `varlist'
local age : word 2 of `varlist'
local age2 : word 3 of `varlist'


tempname a r v e t b ab w


* Naming the time factor loadings
local k=1
while `k'<=`year' {
  tempname l`k' p`k' 
local ++k
}

* Naming the Cohort factor loadings
local k=1
while `k'<=`cohort' {
  tempname q`k' s`k' 
local ++k
}



scalar `a' = `at'[1,1]
scalar `r' =`at'[1,2]
scalar `v' =`at'[1,3]
scalar `e' =`at'[1,4]

local j=2
while `j'<=`year' {
local i=3+`j'
scalar `l`j'' =`at'[1,`i']
local ++j
}

local j=2
while `j'<=`year' {
local i=3+(`year'-1)+`j'
scalar `p`j'' =`at'[1,`i']
local ++j
}

local j=2
while `j'<=`cohort' {
local i=3+2*(`year'-1)+`j'
scalar `q`j'' =`at'[1,`i']
local ++j
}

local j=2
while `j'<=`cohort' {
local i=3+2*(`year'-1)+(`cohort'-1)+`j'
scalar `s`j'' =`at'[1,`i']
local ++j
}

local i=3+2*(`year'-1)+2*(`cohort'-1)+2
scalar `b'=`at'[1,`i']

local i=3+2*(`year'-1)+2*(`cohort'-1)+3
scalar `ab' =`at'[1,`i']

local i=3+2*(`year'-1)+2*(`cohort'-1)+4
scalar `w' =`at'[1,`i']

local i=3+2*(`year'-1)+2*(`cohort'-1)+5
scalar `t' =`at'[1,`i']


scalar `q1'=1
scalar `s1'=1
scalar `p1' =1
scalar `l1' =1


}




else {
*  display as error "Invalid"

*"Either you have failed to enter a model type 
*or the model type you have entered is invalid. 
*Please enter a model type between 1 and 8."

error 198
}


tempname K stu2 
scalar `K'= `e'*(1+`t'^2+2*`r'*`t') 


* just initialize the s-term that appears as a multiplier of K ///
* in the population moments. There will be `year’ of these

scalar `stu2'=1 

local k=3
local lagk=2

while `k'<=`year' {
tempname stu`k' 

scalar `stu`k''=`stu`lagk''+`r'^(2*(`lagk'-1))

local ++lagk
local ++k
}



// FILL IN THE VARIANCES FOR THE 7 COHORTS AND THE 8 TIME PERIODS

local c=1
while `c'<=`cohort' {

local j=1
while `j'<=`year' {

  tempvar c0`j'term`c'

local ++j
}
local ++c
}

tempvar c0sum
generate double `c0sum'=0

local c=1
while `c'<=`cohort' {

local ij=1+(`c'-1)* `year' 
local j=1
while `j'<=`year' {

if `j'==1 {

generate double `c0`j'term`c''=`d`ij''*(`q`c''^2*`p`j''^2* /// 
(`a'+`b'*`age2'+2*`ab'*`age'+`w'*`age')  ///
+`s`c''^2*`l`j''^2*(`v'))
}

else if `j'>1  {

generate double `c0`j'term`c''=`d`ij''*(`q`c''^2*`p`j''^2* /// 
(`a'+`b'*`age2'+2*`ab'*`age'+`w'*`age')  ///
+`s`c''^2*`l`j''^2*(`r'^(2*`j'-2)*`v'+(`K'*`stu`j'')))

}

replace `c0sum'=`c0sum'+`c0`j'term`c''
local ++ij


local ++j
}
local ++c
}





* FILL IN THE the s order COVARIANCES
* Note each cohort will have 1storder, 2nd order…(year-1) order covartiances
* and the number will depend on `year’
* For example a cohort will have (`year’-1) 1st order, (`year’-2) 2nd order..
* The big loop – indexed by z determines which order covariance we are
* with. The stuff inside the loop then runs through the years and cohorts 
* for that order of covariance

tempvar numcovorder
scalar `numcovorder'=`year'-1


local z=1
while `z'<=`numcovorder' {


local c=1
while `c'<=`cohort' {

local j=1
while `j'<=`year'-`z' {

  tempvar c`z'`j'term`c'

local ++j
}
local ++c
}

tempvar c`z'sum
generate double `c`z'sum'=0


local c=1
while `c'<=`cohort' {

* Note 57=#cohorts*(z*#years-sum(0,z-1))+1

* creating sum(0,z-1)

tempname zsum
scalar `zsum'=0

local k=1
while `k'<`z' {
scalar `zsum'=`zsum'+`k' 
local ++k
}

* Note if c=7 and year=8 the first term after equality
* Should be 57 for 1storder, 106 2nd order, 148…..

local ij=(`cohort'*(`z'*`year'-`zsum')+1) +(`c'-1)*(`year'-`z')


local aj=1

local jj=`z'+1


while `aj'<=(`year'-`z') {


if `aj'==1 {

generate double `c`z'`aj'term`c''=`d`ij''* (     ///
(`q`c''^2*`p`aj''*`p`jj'' *(`a'+ `b'*`age2' + ///
`b'*`age'*`z'+ ///
`ab'*(`age'+`age'+`z')+ `w'*`age')+ ///
`s`c''^2*`l`aj''*`l`jj''* (`r'^(`z')*`v'+ ///
`r'^(`z'-1)*`t'*`e')))

}

else if `aj'>1 {

generate double `c`z'`aj'term`c''=`d`ij''* (     ///
(`q`c''^2*`p`aj''*`p`jj'' *(`a'+ `b'*`age2' + ///
`b'*`age'*`z'+ ///
`ab'*(`age'+`age'+`z')+ `w'*`age')+ ///
`s`c''^2*`l`aj''*`l`jj''* (`r'^(`z'+2*`aj'-2)*`v'+ ///
`r'^(`z'-1)*`t'*`e'+`r'^(`z')*`K'*`stu`aj'')))

}

replace `c`z'sum'=`c`z'sum'+`c`z'`aj'term`c''

local ++aj
local ++ij
local ++jj
}
local ++c
}

local ++z
}




*  NEED TO ADD UP ALL (252) THE C’T’SUMS HERE 
* CALL IT DEPSUM


tempvar depsum
generate double `depsum'=0

local j=0
while `j'<=`numcovorder' {

replace `depsum'=`depsum'+`c`j'sum'

local ++j
}

//FILL IN DEPVAR

replace `depmoment'= `depsum' `if'



end


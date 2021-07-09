capture program drop gmmcovearn
* 1.0.1 Doris, O’Neill & Sweetman 9 August 2010
program gmmcovearn, eclass
  version 10.0

set more off

syntax namelist [if], modeln(real) yearn(real) [stvalue(string) ///  
 cohortn(real 1) newdataname(string)   ///
graph(real 0)    ///   
expvar(string) firstyr(real 1) ///
cohortvar(string) firstcohort(real 1) ]

marksample touse

local earningsvar `namelist'

preserve

matrix drop _all
 
global cc1=`cohortn'
global yy1=`yearn'
global mm1=`modeln'

if `modeln'==3|`modeln'==4|`modeln'==5|`modeln'==6|`modeln'==7|`modeln'==8 {
if "`expvar'"=="" {

display as error "You must specify an experience variable for this model"

error 198


}
}

if "`cohortvar'"=="" {
local cohortvar "cohort"
}

* Making list of parameters to be estimated

if `modeln'==1 {
local listparam "sigalpha rho sigv1 sige"
local k=2
while `k'<=`yearn' {
   local listparam "`listparam' l`k'"
   local ++k
}
local j=2

while `j'<=`yearn' {
   local listparam "`listparam' p`j'"
   local ++j
}
local i=2
while `i'<=`cohortn' {
   local listparam "`listparam' q`i'"
   local ++i
}
local z=2
while `z'<=`cohortn' {
   local listparam "`listparam' s`z'"
   local ++z
}
local nump=wordcount("`listparam'")
}

else if `modeln'==2 {
local listparam "sigalpha rho sigv1 sige"
local k=2
while `k'<=`yearn' {
   local listparam "`listparam' l`k'"
   local ++k
}
local j=2
while `j'<=`yearn' {
   local listparam "`listparam' p`j'"
   local ++j
}
local i=2
while `i'<=`cohortn' {
   local listparam "`listparam' q`i'"
   local ++i
}
local z=2
while `z'<=`cohortn' {
   local listparam "`listparam' s`z'"
   local ++z
}
local listparam "`listparam' theta"
local nump=wordcount("`listparam'")
}

else if `modeln'==3 {
local listparam "sigalpha rho sigv1 sige"
local k=2
while `k'<=`yearn' {
   local listparam "`listparam' l`k'"
   local ++k
}
local j=2
while `j'<=`yearn' {
   local listparam "`listparam' p`j'"
   local ++j
}
local i=2
while `i'<=`cohortn' {
   local listparam "`listparam' q`i'"
   local ++i
}
local z=2
while `z'<=`cohortn' {
   local listparam "`listparam' s`z'"
   local ++z
}
local listparam "`listparam' sigbeta covalphabeta"
local nump=wordcount("`listparam'")
}

else if `modeln'==4 {
local listparam "sigalpha rho sigv1 sige"
local k=2
while `k'<=`yearn' {
   local listparam "`listparam' l`k'"
   local ++k
}
local j=2
while `j'<=`yearn' {
   local listparam "`listparam' p`j'"
   local ++j
}
local i=2
while `i'<=`cohortn' {
   local listparam "`listparam' q`i'"
   local ++i
}
local z=2
while `z'<=`cohortn' {
   local listparam "`listparam' s`z'"
   local ++z
}
local listparam "`listparam' sigbeta covalphabeta theta"
local nump=wordcount("`listparam'")
}

else if `modeln'==5 {
local listparam "sigalpha rho sigv1 sige"
local k=2
while `k'<=`yearn' {
   local listparam "`listparam' l`k'"
   local ++k
}
local j=2
while `j'<=`yearn' {
   local listparam "`listparam' p`j'"
   local ++j
}
local i=2
while `i'<=`cohortn' {
   local listparam "`listparam' q`i'"
   local ++i
}
local z=2
while `z'<=`cohortn' {
   local listparam "`listparam' s`z'"
   local ++z
}
local listparam "`listparam' sigw"
local nump=wordcount("`listparam'")
}

else if `modeln'==6 {
local listparam "sigalpha rho sigv1 sige"
local k=2
while `k'<=`yearn' {
   local listparam "`listparam' l`k'"
   local ++k
}
local j=2
while `j'<=`yearn' {
   local listparam "`listparam' p`j'"
   local ++j
}
local i=2
while `i'<=`cohortn' {
   local listparam "`listparam' q`i'"
   local ++i
}
local z=2
while `z'<=`cohortn' {
   local listparam "`listparam' s`z'"
   local ++z
}
local listparam "`listparam' sigw theta"
local nump=wordcount("`listparam'")
}

else if `modeln'==7 {
local listparam "sigalpha rho sigv1 sige"
local k=2
while `k'<=`yearn' {
   local listparam "`listparam' l`k'"
   local ++k
}
local j=2
while `j'<=`yearn' {
   local listparam "`listparam' p`j'"
   local ++j
}
local i=2
while `i'<=`cohortn' {
   local listparam "`listparam' q`i'"
   local ++i
}
local z=2
while `z'<=`cohortn' {
   local listparam "`listparam' s`z'"
   local ++z
}
local listparam "`listparam' sigbeta covalphabeta sigw"
local nump=wordcount("`listparam'")
}

else if `modeln'==8 {
local listparam "sigalpha rho sigv1 sige"
local k=2
while `k'<=`yearn' {
   local listparam "`listparam' l`k'"
   local ++k
}
local j=2
while `j'<=`yearn' {
   local listparam "`listparam' p`j'"
   local ++j
}
local i=2
while `i'<=`cohortn' {
   local listparam "`listparam' q`i'"
   local ++i
}
local z=2
while `z'<=`cohortn' {
   local listparam "`listparam' s`z'"
   local ++z
}
local listparam "`listparam' sigbeta covalphabeta sigw theta"
local nump=wordcount("`listparam'")
}


if "`stvalue'"=="" {
	matrix stvalue2=(0.5,0.5,0.1,0.1)
	
	local noones=(2*`yearn')+(2*`cohortn')-4
		
	forvalues i=1/`noones' {
	matrix stvalue2=(stvalue2,1)
	}
	if `modeln'==2 {
		matrix stvalue2=(stvalue2,-0.5)
		}
	if `modeln'==3|`modeln'==4 {
		matrix stvalue2=(stvalue2,0,0)
		}
	if `modeln'==4 {
		matrix stvalue2=(stvalue2,-0.5)
		}
	if `modeln'==5|`modeln'==6 {
		matrix stvalue2=(stvalue2,0)
		}
	if `modeln'==6 {
		matrix stvalue2=(stvalue2,-0.5)
		}
	if `modeln'==7|`modeln'==8 {
		matrix stvalue2=(stvalue2,0,0,0)
		}
	if `modeln'==8 {
		matrix stvalue2=(stvalue2,-0.5)
		}
}

else {
matrix stvalue2=(`stvalue')
}


* This part creates the moments needed

quietly keep if `touse'

* Designate the earnings and (if relevant to the model) experience variables, and ///
create the expsquared variable


local y1 `earningsvar'`firstyr'
if `modeln'==3|`modeln'==4|`modeln'==5|`modeln'==6|`modeln'==7|`modeln'==8 { 
local agev1 `expvar'`firstyr'
tempvar expsq1 
quietly gen `expsq1'=`agev1'^2
}
forvalues yrno=2/`yearn' {
local yr=`firstyr'+`yrno'-1
local y`yrno' `earningsvar'`yr'
if `modeln'==3|`modeln'==4|`modeln'==5|`modeln'==6|`modeln'==7|`modeln'==8 {
local agev`yrno' `expvar'`yr'
tempvar expsq`yrno'
quietly gen `expsq`yrno''=`agev`yrno''^2
}
}

* Create a variable for cohort number, equal to one for all individuals ///
if there are no cohort effects in the model, and running from 1 to cohortn ///
if there are cohort effects.

tempvar cohortno
if `cohortn'==1 {
quietly gen `cohortno'=1
}

else {
quietly gen `cohortno'=1 if `cohortvar'==`firstcohort' 
forvalues co=2/`cohortn' {
quietly replace `cohortno'=`co' if `cohortvar'==`firstcohort'+`co'-1
}
}


* Get pairwise covariances, average exp and ///
average of exp squared and save them as scalars

* Note: aveagecovyr1yr2 is exp in yr1

forvalues co=1/`cohortn' {
forvalues yr=1/`yearn' {
local i=`yr'
if `modeln'==3|`modeln'==4|`modeln'==5|`modeln'==6|`modeln'==7|`modeln'==8 {
quietly corr `y`i'' `y`i'' if `agev`yr''~=. & `cohortno'==`co', covariance
}
else if `modeln'==1|`modeln'==2 {
quietly corr `y`i'' `y`i'' if `cohortno'==`co', covariance
}


scalar var`co'`i'=r(cov_12)
scalar n`co'`i'=r(N)
if `modeln'==3|`modeln'==4|`modeln'==5|`modeln'==6|`modeln'==7|`modeln'==8 { 
quietly sum `agev`i'' if `y`i''~=. & `cohortno'==`co'
scalar aveagevar`co'`i'=r(mean)
quietly sum `expsq`i'' if `y`i''~=. & `cohortno'==`co'
scalar aveagesqvar`co'`i'=r(mean)
}
local j=`yr'+1
while `j'<=`yearn' {
if `modeln'==3|`modeln'==4|`modeln'==5|`modeln'==6|`modeln'==7|`modeln'==8 {
quietly corr `y`i'' `y`j'' if `agev`yr''~=.  & `agev`j''~=.   & ///
 `cohortno'==`co', covariance
}
else if `modeln'==1|`modeln'==2 {
quietly corr `y`i'' `y`j'' if `cohortno'==`co', covariance
}

scalar cov`co'`i'`j'=r(cov_12)
scalar n`co'`i'`j'=r(N)
if `modeln'==3|`modeln'==4|`modeln'==5|`modeln'==6|`modeln'==7|`modeln'==8 { 
quietly sum `agev`i'' if `y`i''~=. & `y`j''~=. & `cohortno'==`co'
scalar aveagecov`co'`i'`j'=r(mean)
quietly sum `expsq`i'' if `y`i''~=. & `y`j''~=. & `cohortno'==`co'
scalar aveagesqcov`co'`i'`j'=r(mean)
}
local j=`j'+1
}
}
}




* Make matrices containing the variances and covariances in the ///
*first column,average experience in the second column and average experience ///
*squared in the third column. There will be yearn*cohortn variances///

*and (yearn-1)*cohortn+(yearn-2)*cohortn+(yearn-3)*cohortn+... covariances

if `modeln'==3|`modeln'==4|`modeln'==5|`modeln'==6|`modeln'==7|`modeln'==8 {

tempname novars
scalar `novars'=`yearn'*`cohortn'

matrix vars=J(`novars',4,.)

local i=1
while `i'<=`novars' {
forvalues co=1/`cohortn' {
forvalues yr=1/`yearn' {
matrix vars[`i',1]=var`co'`yr'
matrix vars[`i',2]=aveagevar`co'`yr'
matrix vars[`i',3]=aveagesqvar`co'`yr'
matrix vars[`i',4]=n`co'`yr'

local ++i
}
}
}


local c=`yearn' -1
forvalues per=1/`c' {
local p=`cohortn'*(`c'-`per'+1)
matrix per`per'covs=J(`p',4,.)
local i=1
while `i'<=`p' {
forvalues co=1/`cohortn' {
local yr1=1
while `yr1'<=`yearn' -`per' {
local yr2=`yr1'+`per'
matrix per`per'covs[`i',1]=cov`co'`yr1'`yr2'
matrix per`per'covs[`i',2]=aveagecov`co'`yr1'`yr2'
matrix per`per'covs[`i',3]=aveagesqcov`co'`yr1'`yr2'
matrix per`per'covs[`i',4]=n`co'`yr1'`yr2'
local ++i
local drop yr2
local ++yr1
}
}
}
}

local p=1

while `p' <=`yearn' {
local  per`p'covs "\per`p'covs"
local ++p
}


local covlist "vars"

local d=`yearn'-1
local p=1
while `p'<= `d' {
local covlist "`covlist'`per`p'covs'"
local ++p
}

tempname datamatrix

matrix `datamatrix'= `covlist'
matrix colnames `datamatrix' = moment aveexp aveexp2 nobsmoment

* matrix list `datamatrix'

}

else if `modeln'==1|`modeln'==2 {

tempname novars
scalar `novars'=`yearn'*`cohortn'

matrix vars=J(`novars',2,.)

local i=1
while `i'<=`novars' {
forvalues co=1/`cohortn' {
forvalues yr=1/`yearn' {
matrix vars[`i',1]=var`co'`yr'
matrix vars[`i',2]=n`co'`yr'
local ++i
}
}
}


local c=`yearn' -1
forvalues per=1/`c' {
local p=`cohortn'*(`c'-`per'+1)
matrix per`per'covs=J(`p',2,.)
local i=1
while `i'<=`p' {
forvalues co=1/`cohortn' {
local yr1=1
while `yr1'<=`yearn' -`per' {
local yr2=`yr1'+`per'
matrix per`per'covs[`i',1]=cov`co'`yr1'`yr2'
matrix per`per'covs[`i',2]=n`co'`yr1'`yr2'

local ++i
local drop yr2
local ++yr1
}
}
}
}

local p=1

while `p' <=`yearn' {
local  per`p'covs "\per`p'covs"
local ++p
}


local covlist "vars"

local d=`yearn'-1
local p=1
while `p'<= `d' {
local covlist "`covlist'`per`p'covs'"
local ++p
}


tempname datamatrix

matrix `datamatrix'= `covlist'
matrix colnames `datamatrix' = moment nobsmoment

* matrix list `datamatrix'

}

drop _all

quietly svmat float `datamatrix', names(col)


if "`newdataname'"~="" {
quietly save `newdataname', replace
use `newdataname'
}
else if "`newdataname'"=="" {
tempname tempdata
quietly save `tempdata', replace
use `tempdata'
}



forvalues yr=1/`yearn' {

scalar moment`yr'=moment[`yr']
ereturn scalar moment`yr'= moment`yr'

}
if `modeln'==3|`modeln'==4|`modeln'==5|`modeln'==6|`modeln'==7|`modeln'==8 { 


nl gmmcovearn @ moment aveexp aveexp2, parameters("`listparam' ") ///
initial(stvalue2) ///
 cohort(`cohortn') year(`yearn') model(`modeln') ///
leave
}

else if `modeln'==1|`modeln'==2 {
nl gmmcovearn @ moment, parameters("`listparam' ") ///
initial(stvalue2) ///
 cohort(`cohortn') year(`yearn') model(`modeln')  ///
leave
}



scalar rss=e(rss)

matrix coef=e(b)

matrix coef2=J(1,`nump',0) 
forvalues i=1/`nump'{ 

matrix coef2[1,`i']=coef[1, `i' ]
} 

predictnl fhat=predict()


mkmat fhat, matrix(ftemp)
local m=1
local c=1
while `c'<=`cohortn' {
local i=1
while  `i'<= `yearn'{ 
scalar f`c'`i'`i'=ftemp[`m',1] 
local ++m
local ++i 
}
local ++c

}




/*now covariances, there are numcovorder terms eg 8 variances*4=32 then 7*4 1 period covariance etc different orders*/

tempvar numcovorder 
scalar `numcovorder'=`yearn'-1 


local m=(`cohortn'*`yearn')+1 

local z=1 
while `z'<=`numcovorder' {  
local c=1

while `c'<=`cohortn' {
local j=1 
while `j'<= `yearn'- `z' { 
local k=`j'+`z'
scalar f`c'`j'`k'=ftemp[`m',1] 
local ++m 
local ++j 
} 
local ++c
}


local ++z 
} 
************introducing the pertemp progam here*************




* Programme an AR model with no heterogeneity ///
*  (must specify model (1) and cohort(n))

if `modeln'==1 {


tempvar age age2
generate double `age'=1
generate double `age2'=1

tempname a r v e t b ab w


* Naming the time factor loadings
local k=1
while `k'<=`yearn' {
  tempname l`k' p`k' 
local ++k
}

* Naming the Cohort factor loadings
local k=1
while `k'<=`cohortn' {
  tempname q`k' s`k' 
local ++k
}

scalar `a' = coef2[1,1]
scalar `r' = coef2[1,2]
scalar `v' = coef2[1,3]
scalar `e' =coef2[1,4]

local j=2
while `j'<=`yearn' {
local i=3+`j'
scalar `l`j'' =coef2[1,`i']
local ++j
}

local j=2
while `j'<=`yearn' {
local i=3+(`yearn'-1)+`j'
scalar `p`j'' =coef2[1,`i']
local ++j
}

local j=2
while `j'<=`cohortn' {
local i=3+2*(`yearn'-1)+`j'
scalar `q`j'' =coef2[1,`i']
local ++j

}

local j=2
while `j'<=`cohortn' {
local i=3+2*(`yearn'-1)+(`cohortn'-1)+`j'
scalar `s`j'' =coef2[1,`i']
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

else if `modeln'==2 {


tempvar age age2
generate double `age'=1
generate double `age2'=1

tempname a r v e t b ab w


* Naming the time factor loadings
local k=1
while `k'<=`yearn' {
  tempname l`k' p`k' 
local ++k
}

* Naming the Cohort factor loadings
local k=1
while `k'<=`cohortn' {
  tempname q`k' s`k' 
local ++k
}

scalar `a' = coef2[1,1]
scalar `r' =coef2[1,2]
scalar `v' =coef2[1,3]
scalar `e' =coef2[1,4]

local j=2
while `j'<=`yearn' {
local i=3+`j'
scalar `l`j'' =coef2[1,`i']
local ++j
}

local j=2
while `j'<=`yearn' {
local i=3+(`yearn'-1)+`j'
scalar `p`j'' =coef2[1,`i']
local ++j
}

local j=2
while `j'<=`cohortn' {
local i=3+2*(`yearn'-1)+`j'
scalar `q`j'' =coef2[1,`i']
local ++j
}

local j=2
while `j'<=`cohortn' {
local i=3+2*(`yearn'-1)+(`cohortn'-1)+`j'
scalar `s`j'' =coef2[1,`i']
local ++j
}

local i=3+2*(`yearn'-1)+2*(`cohortn'-1)+2
scalar `t'=coef2[1,`i']


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

else if `modeln'==3 {

tempvar age age2
quietly generate double `age'=aveexp
quietly generate double `age2'=aveexp2


tempname a r v e t b ab w


* Naming the time factor loadings
local k=1
while `k'<=`yearn' {
  tempname l`k' p`k' 
local ++k
}

* Naming the Cohort factor loadings
local k=1
while `k'<=`cohortn' {
  tempname q`k' s`k' 
local ++k
}



scalar `a' = coef2[1,1]
scalar `r' =coef2[1,2]
scalar `v' =coef2[1,3]
scalar `e' =coef2[1,4]

local j=2
while `j'<=`yearn' {
local i=3+`j'
scalar `l`j'' =coef2[1,`i']
local ++j
}

local j=2
while `j'<=`yearn' {
local i=3+(`yearn'-1)+`j'
scalar `p`j'' =coef2[1,`i']
local ++j
}

local j=2
while `j'<=`cohortn' {
local i=3+2*(`yearn'-1)+`j'
scalar `q`j'' =coef2[1,`i']
local ++j
}

local j=2
while `j'<=`cohortn' {
local i=3+2*(`yearn'-1)+(`cohortn'-1)+`j'
scalar `s`j'' =coef2[1,`i']
local ++j
}

local i=3+2*(`yearn'-1)+2*(`cohortn'-1)+2
scalar `b'=coef2[1,`i']

local i=3+2*(`yearn'-1)+2*(`cohortn'-1)+3
scalar `ab' =coef2[1,`i']



scalar `t'=0

scalar `q1'=1
scalar `s1'=1
scalar `p1' =1
scalar `l1' =1
scalar `w'=0


}



* Programme an ARMA model with heterogeneity ///
*  (must specify model (4) and cohort(n)

else if `modeln'==4 {


tempvar age age2
quietly generate double `age'=aveexp
quietly generate double `age2'=aveexp2



tempname a r v e t b ab w


* Naming the time factor loadings
local k=1
while `k'<=`yearn' {
  tempname l`k' p`k' 
local ++k
}

* Naming the Cohort factor loadings
local k=1
while `k'<=`cohortn' {
  tempname q`k' s`k' 
local ++k
}



scalar `a' = coef2[1,1]
scalar `r' =coef2[1,2]
scalar `v' =coef2[1,3]
scalar `e' =coef2[1,4]

local j=2
while `j'<=`yearn' {
local i=3+`j'
scalar `l`j'' =coef2[1,`i']
local ++j
}

local j=2
while `j'<=`yearn' {
local i=3+(`yearn'-1)+`j'
scalar `p`j'' =coef2[1,`i']
local ++j
}

local j=2
while `j'<=`cohortn' {
local i=3+2*(`yearn'-1)+`j'
scalar `q`j'' =coef2[1,`i']
local ++j
}

local j=2
while `j'<=`cohortn' {
local i=3+2*(`yearn'-1)+(`cohortn'-1)+`j'
scalar `s`j'' =coef2[1,`i']
local ++j
}

local i=3+2*(`yearn'-1)+2*(`cohortn'-1)+2
scalar `b'=coef2[1,`i']

local i=3+2*(`yearn'-1)+2*(`cohortn'-1)+3
scalar `ab' =coef2[1,`i']

local i=3+2*(`yearn'-1)+2*(`cohortn'-1)+4
scalar `t' =coef2[1,`i']



scalar `q1'=1
scalar `s1'=1
scalar `p1' =1
scalar `l1' =1
scalar `w'=0


}



* Programme an AR model with random walk ///
*  (must specify model (5) and cohort(n)

else if `modeln'==5 {

tempvar age age2
quietly generate double `age'=aveexp
quietly generate double `age2'=aveexp2


tempname a r v e t b ab w


* Naming the time factor loadings
local k=1
while `k'<=`yearn' {
  tempname l`k' p`k' 
local ++k
}

* Naming the Cohort factor loadings
local k=1
while `k'<=`cohortn' {
  tempname q`k' s`k' 
local ++k
}



scalar `a' = coef2[1,1]
scalar `r' =coef2[1,2]
scalar `v' =coef2[1,3]
scalar `e' =coef2[1,4]

local j=2
while `j'<=`yearn' {
local i=3+`j'
scalar `l`j'' =coef2[1,`i']
local ++j
}

local j=2
while `j'<=`yearn' {
local i=3+(`yearn'-1)+`j'
scalar `p`j'' =coef2[1,`i']
local ++j
}

local j=2
while `j'<=`cohortn' {
local i=3+2*(`yearn'-1)+`j'
scalar `q`j'' =coef2[1,`i']
local ++j
}

local j=2
while `j'<=`cohortn' {
local i=3+2*(`yearn'-1)+(`cohortn'-1)+`j'
scalar `s`j'' =coef2[1,`i']
local ++j
}

local i=3+2*(`yearn'-1)+2*(`cohortn'-1)+2
scalar `w'=coef2[1,`i']


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

else if `modeln'==6 {

tempvar age age2
quietly generate double `age'=aveexp
quietly generate double `age2'=aveexp2


tempname a r v e t b ab w


* Naming the time factor loadings
local k=1
while `k'<=`yearn' {
  tempname l`k' p`k' 
local ++k
}

* Naming the Cohort factor loadings
local k=1
while `k'<=`cohortn' {
  tempname q`k' s`k' 
local ++k
}



scalar `a' = coef2[1,1]
scalar `r' =coef2[1,2]
scalar `v' =coef2[1,3]
scalar `e' =coef2[1,4]

local j=2
while `j'<=`yearn' {
local i=3+`j'
scalar `l`j'' =coef2[1,`i']
local ++j
}

local j=2
while `j'<=`yearn' {
local i=3+(`yearn'-1)+`j'
scalar `p`j'' =coef2[1,`i']
local ++j
}

local j=2
while `j'<=`cohortn' {
local i=3+2*(`yearn'-1)+`j'
scalar `q`j'' =coef2[1,`i']
local ++j
}

local j=2
while `j'<=`cohortn' {
local i=3+2*(`yearn'-1)+(`cohortn'-1)+`j'
scalar `s`j'' =coef2[1,`i']
local ++j
}

local i=3+2*(`yearn'-1)+2*(`cohortn'-1)+2
scalar `w'=coef2[1,`i']

local i=3+2*(`yearn'-1)+2*(`cohortn'-1)+3
scalar `t' =coef2[1,`i']



scalar `q1'=1
scalar `s1'=1
scalar `p1' =1
scalar `l1' =1
scalar `b'=0
scalar `ab'=0


}



* Programme an AR model with heterogeneity & rw///
*  (must specify model (7) and cohort(n)

else if `modeln'==7 {

tempvar age age2
quietly generate double `age'=aveexp
quietly generate double `age2'=aveexp2


tempname a r v e t b ab w


* Naming the time factor loadings
local k=1
while `k'<=`yearn' {
  tempname l`k' p`k' 
local ++k
}

* Naming the Cohort factor loadings
local k=1
while `k'<=`cohortn' {
  tempname q`k' s`k' 
local ++k
}



scalar `a' = coef2[1,1]
scalar `r' =coef2[1,2]
scalar `v' =coef2[1,3]
scalar `e' =coef2[1,4]

local j=2
while `j'<=`yearn' {
local i=3+`j'
scalar `l`j'' =coef2[1,`i']
local ++j
}

local j=2
while `j'<=`yearn' {
local i=3+(`yearn'-1)+`j'
scalar `p`j'' =coef2[1,`i']
local ++j
}

local j=2
while `j'<=`cohortn' {
local i=3+2*(`yearn'-1)+`j'
scalar `q`j'' =coef2[1,`i']
local ++j
}

local j=2
while `j'<=`cohortn' {
local i=3+2*(`yearn'-1)+(`cohortn'-1)+`j'
scalar `s`j'' =coef2[1,`i']
local ++j
}

local i=3+2*(`yearn'-1)+2*(`cohortn'-1)+2
scalar `b'=coef2[1,`i']

local i=3+2*(`yearn'-1)+2*(`cohortn'-1)+3
scalar `ab' =coef2[1,`i']

local i=3+2*(`yearn'-1)+2*(`cohortn'-1)+4
scalar `w' =coef2[1,`i']



scalar `t'=0

scalar `q1'=1
scalar `s1'=1
scalar `p1' =1
scalar `l1' =1


}



* Programme an ARMA model with heterogeneity & rw///
*  (must specify model (8) and cohort(n)

else if `modeln'==8 {

tempvar age age2
quietly generate double `age'=aveexp
quietly generate double `age2'=aveexp2


tempname a r v e t b ab w


* Naming the time factor loadings
local k=1
while `k'<=`yearn' {
  tempname l`k' p`k' 
local ++k
}

* Naming the Cohort factor loadings
local k=1
while `k'<=`cohortn' {
  tempname q`k' s`k' 
local ++k
}



scalar `a' = coef2[1,1]
scalar `r' =coef2[1,2]
scalar `v' =coef2[1,3]
scalar `e' =coef2[1,4]

local j=2
while `j'<=`yearn' {
local i=3+`j'
scalar `l`j'' =coef2[1,`i']
local ++j
}

local j=2
while `j'<=`yearn' {
local i=3+(`yearn'-1)+`j'
scalar `p`j'' =coef2[1,`i']
local ++j
}

local j=2
while `j'<=`cohortn' {
local i=3+2*(`yearn'-1)+`j'
scalar `q`j'' =coef2[1,`i']
local ++j
}

local j=2
while `j'<=`cohortn' {
local i=3+2*(`yearn'-1)+(`cohortn'-1)+`j'
scalar `s`j'' =coef2[1,`i']
local ++j
}

local i=3+2*(`yearn'-1)+2*(`cohortn'-1)+2
scalar `b'=coef2[1,`i']

local i=3+2*(`yearn'-1)+2*(`cohortn'-1)+3
scalar `ab' =coef2[1,`i']

local i=3+2*(`yearn'-1)+2*(`cohortn'-1)+4
scalar `w' =coef2[1,`i']

local i=3+2*(`yearn'-1)+2*(`cohortn'-1)+5
scalar `t' =coef2[1,`i']


scalar `q1'=1
scalar `s1'=1
scalar `p1' =1
scalar `l1' =1


}





******************

else {
*  display as error "Invalid"

*"Either you have failed to enter a model type 
*or the model type you have entered is invalid. 
*Please enter a model type between 1 and 8."

error 198
} 
******************************

tempname K stu2 
scalar `K'= `e'*(1+`t'^2+2*`r'*`t') 



* just initialize the s-term that appears as a multiplier of K ///
* in the population moments. There will be `yearn’ of these

scalar `stu2'=1 

local k=3
local lagk=2

while `k'<=`yearn' {
tempname stu`k' 

scalar `stu`k''=`stu`lagk''+`r'^(2*(`lagk'-1))

local ++lagk
local ++k
}



**



local c=1
while `c'<=`cohortn' {

local j=1
while `j'<=`yearn' {

tempvar c0`j'term`c' perm`j'term`c'  temp`j'term`c' 

local ++j
}
local ++c
}

tempvar c0sum
quietly generate double `c0sum'=0

local c=1
while `c'<=`cohortn' {

local j=1
while `j'<=`yearn' {





if `j'==1 {

scalar perm`j'term`c'=(`q`c''^2*`p`j''^2* /// 
(`a'+`b'*`age2'[`j'+(`c'-1)*`yearn']+2*`ab'*`age'[`j'+(`c'-1)*`yearn'] ///
+`w'*`age'[`j'+(`c'-1)*`yearn']))


ereturn scalar perm`j'term`c'= perm`j'term`c'


scalar temp`j'term`c'=(`s`c''^2*`l`j''^2* ///
(`v'))



ereturn scalar temp`j'term`c'= temp`j'term`c'

}

else if `j'~=1 {

scalar perm`j'term`c'=(`q`c''^2*`p`j''^2* /// 
(`a'+`b'*`age2'[`j'+(`c'-1)*`yearn']+2*`ab'*`age'[`j'+(`c'-1)*`yearn'] ///
+`w'*`age'[`j'+(`c'-1)*`yearn']))


ereturn scalar perm`j'term`c'= perm`j'term`c'


scalar temp`j'term`c'=(`s`c''^2*`l`j''^2* ///
(`r'^(2*`j'-2)*`v'+(`K'*`stu`j'')))



ereturn scalar temp`j'term`c'= temp`j'term`c'


}

local ++j
}
local ++c
}

matrix permtemp=J(`novars',4,0) 
local cvarlist " "


local c=1
while `c'<=`cohortn'{

local j=1
while `j'<=`yearn' {

local cvarlist  " `cvarlist' cohort`c'year`j'"



matrix permtemp[`j'+(`c'-1)*`yearn',1]= perm`j'term`c'



matrix permtemp[`j'+(`c'-1)*`yearn',2]= temp`j'term`c'
matrix permtemp[`j'+(`c'-1)*`yearn',4]= /// 
(perm`j'term`c')/(perm`j'term`c'+ temp`j'term`c')
matrix permtemp[`j'+(`c'-1)*`yearn',3]= /// 
(perm`j'term`c'+ temp`j'term`c')


local ++j


}
local ++c
}




matrix rownames permtemp=`cvarlist'
matrix colnames permtemp= perm temp total %perm



* bringing in derivatives which is numoments*nuparameter

mkmat `listparam', matrix(temp)  
ereturn matrix rtemp temp  
  

drop _all 

*
*

/* Step 3 Brings back in the earnings residuals. Note sample size 
may differ for each year */

restore



tempvar cohortno
if `cohortn'==1 {
quietly gen `cohortno'=1
}


else {
quietly gen `cohortno'=1 if `cohortvar'==`firstcohort' 
forvalues co=2/`cohortn' {
quietly replace `cohortno'=`co' if `cohortvar'==`firstcohort'+`co'-1
}
}





/* calculating sample size for each year*/

local j=1
while `j'<=`cohortn' {

forvalues yr=1/`yearn' {
tempvar n`j'
if `modeln'==3|`modeln'==4|`modeln'==5|`modeln'==6|`modeln'==7|`modeln'==8 {
 quietly sum `y`yr'' if `agev`yr''~=. & `cohortno'==`j'
}
else if `modeln'==1|`modeln'==2 {
 quietly sum `y`yr'' if `cohortno'==`j'
}
quietly gen `n`j''`yr'=_result(1) 
} 

local ++j
}

tempvar ntot
quietly gen `ntot'=_N 



/* Step 4 calculating deviations m* and then m=M* if M*>0 and m=0 if m*==.*/
local j=1
while `j'<=`cohortn' {


forvalues yr=1/`yearn' { 
tempvar wbar1`j'`yr'
quietly egen `wbar1`j'`yr''=mean(`y`yr'') if `cohortno'== `j'
} 
local ++j
}

local j=1
while `j'<=`cohortn' {


forvalues yr2=1/`yearn' { 
tempvar wbar2`j'`yr2'
quietly egen `wbar2`j'`yr2''=mean(`y`yr2'') if `cohortno'== `j'
} 
local ++j
}




local j=1
while `j'<=`cohortn' {



forvalues yr=1/`yearn'{ 
forvalues yr2=1/`yearn' { 


if `yr2'>=`yr' { 
tempvar wdev`j'`yr'`yr2'
quietly gen `wdev`j'`yr'`yr2''= (`y`yr''- `wbar1`j'`yr'')* ///
(`y`yr2''- `wbar2`j'`yr2'')-f`j'`yr'`yr2' if `cohortno'== `j'
quietly replace `wdev`j'`yr'`yr2''=0 if `wdev`j'`yr'`yr2''==. 
} 

} 
} 

local ++j
}



/* [(D'AD)-1D'AVAD((D'AD)-1] is the formula for the standard error from Haider's JOLE paper*/
*
*
/*Step 5 calculating the A matrix*/
/*A =(inverse(pi)* inv(pi))  where pi is a diagonal matrix of dimension m*m where m is the number of moments. the ith diagonal contains the number of observations used to calculate the ith moment/total N.*/


/* creating the r-dummy variable from haider page 829=1 if moment nonzero, zero otherwise*/

local j=1
while `j'<=`cohortn' {


forvalues yr=1/`yearn' { 
forvalues yr2=1/`yearn' { 

if `yr2'>=`yr' { 
tempvar r`j'`yr'`yr2'
quietly gen `r`j'`yr'`yr2''= `wdev`j'`yr'`yr2''~=0  
 quietly sum `r`j'`yr'`yr2''
tempvar n1`j'`yr'`yr2' 
quietly gen `n1`j'`yr'`yr2''=_result(3)*_N   
scalar n`j'`yr'`yr2'= `n1`j'`yr'`yr2'' 
* this calculates the correct n for each moment, it adds up the number of 1's 

} 

} 
} 

local ++j
}




/*the A matrix see Haider page 830, here P(pi in haider)is a m*m with nyryr/N on diagonal where m=(yearn)*(yearn+1)/2*/




*
local numoment= (`yearn'*(`yearn'+1)/2)* `cohortn' 


matrix pv=J(`numoment',1,0)
local m=1
local j=1
while `j'<=`cohortn' {
local i=1
while  `i'<= `yearn' { 
matrix pv[`m',1]=n`j'`i'`i'/_N
local ++m

local ++i 
} 
local ++j

}



local m=(`yearn' *`cohortn')+1 
local z=1 
while `z'<=`numcovorder' {  
local c=1
while `c'<=`cohortn' {
local j=1 
local k=`j'+`z'
while `j'<= `yearn' - `z' { 
local k=`j'+`z'
matrix pv[`m',1]=n`c'`j'`k'/_N
local ++m 
local ++j 
} 

local++c
}

local ++z 
} 





matrix P=diag(pv) 
matrix A=(inv(P))*(inv(P))



*





/* Step 6 Creating the V matrix,V=E(mm')=1/_N sum (mm') (m includes zeros),htemp is 36*_N*/

*creating the variable list for making the matrix of wdev11, wdev22 etc

local wvarlist " "

local c=1
while `c' <= `cohortn'{ 

local i=1
while  `i'<= `yearn' { 
local wvarlist  " `wvarlist' `wdev`c'`i'`i''"
local ++i
}
local ++c
}




local m=(`cohortn'*`yearn')  +1 
local z=1 
while `z'<=`numcovorder' {  
local c=1
while `c' <= `cohortn'{ 
local j=1 
while `j'<= `yearn' - `z' { 
local k=`j'+`z'
local wvarlist  " `wvarlist' `wdev`c'`j'`k''"
local ++m 
local ++j 
} 
local ++c
}

local ++z 
}



tempvar id weight
quietly generate double `id'=_n
sort `id'
quietly generate double `weight'=1
matrix opaccum hhtotal=`wvarlist', group(`id') opvar(`weight') noconstant



matrix V1=hhtotal/_N 
                  
*
*


* Step 7  creating D (numoment*nparameters)matrix which is the average of the derivatives for the nonzeros and the zeros. The first row for example, looks at the derivatives for the first moment this needs to replicated n19941994  times... and similarly for all other rows. Need to multiply the derivative* (number of non-zero derivatives)and divide by N to get an average but pv is a 36*1 vector with is nyr1yr2/N so need to multiply rtemp(R)[36*19] element by element by pv. the row of pv gives number of non-zero derivaties/N already. the stuff below should represent element by element multiplication.  


matrix D=J(`numoment',`nump',0)
matrix B1=pv' 
matrix R=e(rtemp)
forvalues j=1/`nump'{ 
forvalues i=1/`numoment'{
matrix D[`i',`j']= pv[`i',1]*R[`i',`j'] 
} 
} 



matrix D1=D*(-1) 


* to avoid Stat precision problems with symmetry.

matrix vcv2=(inv(D1'*D1))*(D1'*V1*D1)* (inv(D1'*D1)) 
matrix vcv=(vcv2+vcv2')/2


/* getting the diagonal elements of var/cov matrix and putting it in vector*/
matrix dvcv=vecdiag(vcv) 
matrix dvcvn=dvcv/_N 

/* getting the square root of each element of the diagonal matrix, element by element*/
matrix se=J(`nump',2 ,0) 
forvalues i=1/`nump'{ 

matrix se[`i',2]=((dvcvn[1,`i'])^.5)
matrix se[`i',1]=coef[1,`i']
} 
matrix rownames se = `listparam'
matrix colnames se = coef sterror

tempname b
matrix `b'=coef2
matrix colnames `b' = `listparam'

tempname V
matrix `V'=vcv/_N
matrix colnames `V' = `listparam'
matrix rownames `V' = `listparam'

ereturn clear
ereturn post `b' `V'
dis " coefficients and corrected standard errors below"
ereturn display


matrix rownames permtemp=`cvarlist'
matrix colnames permtemp= perm temp total %perm


* matrix list permtemp

tempvar c0sum
quietly generate double `c0sum'=0

local c=1
while `c'<=`cohortn' {

local j=1
while `j'<=`yearn' {



matrix VV=vcv/_N 



local ++j
}

local ++c
}



tempname moment1 

matrix `moment1'=`datamatrix'[1. ..,1]

if `modeln'==3|`modeln'==4|`modeln'==5|`modeln'==6|`modeln'==7|`modeln'==8 {
matrix `age'=`datamatrix'[1. ..,2]
matrix `age2'=`datamatrix'[1. ..,3]


}

*******************************************************************

*Now create the sample variance covariance matrix for each cohort in matrix form



// FILL IN THE VARIANCES FOR THE 7 COHORTS AND THE 8 TIME PERIODS

local c=1
while `c'<=`cohortn' {

  tempname earnmoment`c'

matrix `earnmoment`c''= J(`yearn',`yearn',0)

local ++c
}



local c=1
while `c'<=`cohortn' {

local ij=1+(`c'-1)* `yearn' 
local j=1
while `j'<=`yearn' {


matrix `earnmoment`c''[`j',`j']= `moment1'[`ij',1]


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
scalar `numcovorder'=`yearn'-1


local z=1
while `z'<=`numcovorder' {



local c=1
while `c'<=`cohortn' {

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

local ij=(`cohortn'*(`z'*`yearn'-`zsum')+1) +(`c'-1)*(`yearn'-`z')


local aj=1

local jj=`z'+1


while `aj'<=(`yearn'-`z') {


matrix  `earnmoment`c''[`z'+`aj', `aj']= `moment1'[`ij',1]
matrix  `earnmoment`c''[`aj', `z'+`aj']= `moment1'[`ij',1]


local ++aj
local ++ij
local ++jj
}

local ++c
}

local ++z
}

local c=1
while `c'<=`cohortn' {

tempname mearnmoment`c' 
matrix `mearnmoment`c''=`earnmoment`c''

ereturn matrix moment`c'=`earnmoment`c''
local ++c
}

*********************************************************
* now to create the graphs

*** 
* Create a variable with actual variances for each cohort for use in graphe


local c=1

while `c'<=`cohortn' {

tempname earnvar`c'
matrix `earnvar`c''= J(`yearn',1,0)

local i=1 

while `i'<=`yearn' {


matrix `earnvar`c''[`i',1]= `mearnmoment`c''[`i', `i']


local ++i
}
matrix colnames `earnvar`c''=earnvar`c' 

svmat `earnvar`c'', name(col)
tempvar earnmvar`c' 

rename earnvar`c' `earnvar`c''

local ++c
}




tempname yearvect
matrix `yearvect'=J(`yearn', 1 ,0)
matrix colnames `yearvect'=yearvect


local y=1
while `y'<=`yearn' {

matrix `yearvect'[`y',1]= `y'

local ++y

}

svmat `yearvect', name(col)
tempvar yearvect
rename yearvect `yearvect'

label var `yearvect' "Year"


local c=1
while `c'<=`cohortn' {
tempname permtemp`c'

matrix `permtemp`c''= permtemp[(`c'-1)* `yearn'+1.. `c'*`yearn',1..4]
matrix colnames `permtemp`c''=perm`c' temp`c' total`c' propperm`c'
svmat `permtemp`c'', name(col)
tempvar perm`c' temp`c' total`c' propperm`c'

tempname mperm`c' mtemp`c'
matrix `mperm`c''= permtemp[(`c'-1)* `yearn'+1.. `c'*`yearn',1]
matrix `mtemp`c''= permtemp[(`c'-1)* `yearn'+1.. `c'*`yearn',2]


rename perm`c' `perm`c''
rename temp`c' `temp`c''
rename total`c' `total`c''
rename propperm`c' `propperm`c''

label var `perm`c'' "perm`c'"
label var `temp`c'' "temp`c'"
label var `total`c'' "predicted_total`c'"
label var `earnvar`c'' "actual_total`c'"

tempname avpropperm`c'
quietly sum `propperm`c''
scalar `avpropperm`c''=r(mean)

* display "The average proportion permanent for cohort"`c' " is "`avpropperm`c''


ereturn matrix perm`c'=`mperm`c''
ereturn matrix temp`c'=`mtemp`c''


local ++c
}



if `graph'==1 {


local p=1
while `p'<=`cohortn' {

quietly scatter `perm`p'' `temp`p'' `total`p'' `earnvar`p'' `yearvect' , c(l l l l) lpattern(l l l -) ///
s(Oh S X +) saving(graphn`p',replace) nodraw


local ++p
}




local graphlist ""

local p=1
while `p'<=`cohortn' {
local graphlist "`graphlist' graphn`p'.gph"
graph use graphn`p', nodraw
local ++p
}

graph combine `graphlist'

}

* Delete the temporary data set, if not required

if "`newdataname'"=="" {
erase `tempdata'.dta
}


end

























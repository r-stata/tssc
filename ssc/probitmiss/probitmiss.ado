
capture program drop probitmiss

program probitmiss, eclass
  version 10.0


* This programs estimates Conniffe-OíNeill estimator for missing data


* First stage is to estimate Chehserís fully efficient ML estimator 
* of the probit model with a constant and one common variable
  
syntax varlist(min=3) [if] [in] [, numw(real 1)]

tokenize `varlist'
local lhsvar "`1'"


local p=1

while `p' <=`numw' {
macro shift 1
local w`p' "`1'"
local ++p
}

local wvarlist ""

local p=1
while `p'<=`numw' {
local wvarlist "`wvarlist' `w`p'' "
local ++p
}

*macro shift 1
*local wvarlist "`1'"

macro shift 1
local xvarlist "`*'"


* Probably should have tokenized xvarlist but because I did I had to adjust
* below

tokenize `varlist'

* First I count the number of variables in the X-matrix

local k=1

while "``k''"!="" {
    local ++k
}


* need to adjust for ìzî ìwî and starting k at 1 not zero.
tempname numvarx matcount rsscount numvarxcons
scalar `numvarx'=`k'-`numw'-2
scalar `rsscount'= `numvarx'+1
scalar `numvarxcons'= `numvarx'+1

dis "number of xís is"
dis `numvarx'

dis "number of wís is"
dis  `numw'


scalar `matcount'=`numw'+`numvarxcons'

tempname kl dimsigw

scalar `kl'=`numvarxcons'*`numw'
scalar `dimsigw'=(`numw'/2)*( `numw'+1)



tokenize `xvarlist'

local p=1

while `p' <=`numvarx' {
local xvar`p' "`1'"
macro shift 1
local ++p
}

*sum `xvar1'
*sum `xvar3'


local k=`numvarx'
local lastxvar "`xvar`k''"



quietly summ `lastxvar'  

local xvarlist2 ""

local p=1
local xymodel=`numvarx'-1 

while `p'<=`xymodel' {
local xvarlist2 "`xvarlist2' `xvar`p'' "
local ++p
}







sort `w1'

* Run first stage regression using w1 on x and save parameters
* Just to get numbers of observations


quietly regress `w1' `xvarlist'

tempname nc ntotal
tempvar missdata1 missdata

scalar `nc'=e(N)
gen `missdata1'=e(sample)
gen `missdata'=1 if `missdata1'==0
replace `missdata'=0 if `missdata1'==1

quietly summ `missdata' 
scalar `ntotal'=r(N)


* Now run first stage regression of x on w
* For each of the wís and save parameters
* In the overall matrix C



local k=1
while `k'<=`numw' {


quietly regress `w`k'' `xvarlist'

tempname olsparam`k' c`k' resid`k' sigmaww`k'
tempvar res`k' 

predict `res`k'', resid



* note e(b) is a (1xk) with the constant in the last position

matrix `olsparam`k''=e(b)
matrix `c`k''=`olsparam`k'''

scalar `sigmaww`k''=e(rss)/(e(N)- `rsscount')


local ++k
}


* Create overall C

tempname C
matrix `C'=`c1'


local k=2
while `k'<=`numw' {
matrix `C'=`C', `c`k''
local ++k
}


* Generate the var-covar matrix of e_w


tempname SIGMAW
matrix `SIGMAW'=J(`numw',`numw',0)


local k=1
	while `k'<=`numw' {

local j=1
	while `j'<=`numw' {

tempvar sigma`k'`j'

gen `sigma`k'`j'' =sum(`res`k''*`res`j'')

matrix `SIGMAW'[`k', `j']= `sigma`k'`j''[`nc']/( `nc'-`rsscount')

local ++j
}
local ++k
}





* Create the matrix Vec(DELTA-SIGMAW)

* Create the matrix Vec(DELTA-SIGMAW)


tempname vecdeltasigw 

local k=1

while `k'<=`numw' {

tempname vec`k'

matrix `vec`k''=`SIGMAW'[`k'.. `numw', `k']

local ++k
}

local k=2

matrix `vecdeltasigw'=`vec1'
while `k'<=`numw' {

matrix `vecdeltasigw'=`vecdeltasigw' \ `vec`k''

local ++k
}


tempname testone

scalar `testone'=`vecdeltasigw'[2,1]^2+`vecdeltasigw'[1,1]*`vecdeltasigw'[3,1]





* create VecC

tempname VecC
matrix `VecC'=vec(`C')



* Create the Variance-Cov matrix of SIGMAW.
* To do this I need (L/2)*(L+1) matrices each of dimension (LxL)
* I call these covvec11, covvec21,Ö.covvecLL.
* These will be used to make the lower triangular matrix of the
* Var-cov of Vec(SIGMAW) from which I can then create the 
* Var-cov matrix of Vec(DELTA-SIGMAW)


local k=1
       while `k'<=`numw' {
local m=1
       while `m'<=`k' {

tempname covvec`k'`m'

matrix `covvec`k'`m''=J(`numw', `numw',0)

local j=1
       while `j'<=`numw' {
local l=1
       while `l'<=`numw' {
       
       
       matrix `covvec`k'`m''[`j', `l']= `SIGMAW'[`j', `l']*  ///
       `SIGMAW'[`k', `m']+ `SIGMAW'[`j', `m']* `SIGMAW'[`k', `l']
       
       
       local ++l
       }
       
       local ++j
       }
       
local ++m
}

local ++k
}




local k=1
       while `k'<=`numw' {
local m=1
       while `m'<=`k' {

tempname covvec2`k'`m'


if `k'==`m' {

mata: st_matrix("`covvec2`k'`m''",lowertriangle(st_matrix("`covvec`k'`m''")))

matrix `covvec2`k'`m''=`covvec2`k'`m''[`k'..`numw', `m'..`numw']
}

else {

matrix `covvec2`k'`m''=`covvec`k'`m''[`k'..`numw', `m'..`numw']

}

local ++m
}

local ++k
}




local m=2
       while `m'<=`numw' {
local k=1
       while `k'<`m' {

tempname covvec2`k'`m' r`k'`m' c`k'`m'

scalar `r`k'`m''=`numw'-`k'+1
scalar `c`k'`m''=`numw'-`m'+1

matrix `covvec2`k'`m''=J(`r`k'`m'', `c`k'`m'',0)

local ++k
}
local ++m
}


local k=1
       while `k'<=`numw' {
       tempname rowmat`k'
       
       matrix `rowmat`k''=`covvec2`k'1'

local m=2
while `m'<=`numw' {

       matrix `rowmat`k''=`rowmat`k'',`covvec2`k'`m''
       
       local ++m
       }
       local ++k
       }
       
* now stack all on top

local k=2
       
       tempname VSIGMAW1 VSIGMAW
       matrix `VSIGMAW1'=`rowmat1'

       while `k'<=`numw' {

       matrix `VSIGMAW1'=`VSIGMAW1' \ `rowmat`k''
       
       local ++k
       }


mata: st_matrix("`VSIGMAW'", makesymmetric(st_matrix("`VSIGMAW1'")))




matrix `VSIGMAW'=`VSIGMAW'/( `nc'-`rsscount')
*matrix `VSIGMAW'=`VSIGMAW'/( `nc')




* Run probit model of y on x and w

quietly probit `lhsvar' `wvarlist' `xvarlist'

tempname probitpar probitcov probx probw probcovwx sigmayw rho2 probvarx tempname probvarw seprobw count1 sigmayw1 probcovwxprime 
matrix `probitpar'=e(b)
matrix `probitcov'=e(V)

scalar  `count1'=`numw'+1


matrix `probw'=`probitpar'[1,1.. `numw']'
matrix `probx'=`probitpar'[1,`count1'..`matcount']'




matrix `probcovwx'=`probitcov'[`count1'..`matcount',1.. `numw']
matrix `probcovwxprime'=`probcovwx''


matrix `probvarx'=`probitcov'[`count1'..`matcount', `count1'..`matcount']
matrix `probvarw'=`probitcov'[1.. `numw',1.. `numw']


tempname seprobcomp
scalar `seprobcomp'=`probvarw'[1,1]^.5


*Create the theta vector

tempname theta

matrix `theta'=`probx' \ `probw' \ `VecC' \ `vecdeltasigw'


* Now use our estimates to create the efficient estimator eqt (10)
tempname achesher matvary vary

tempname aa
matrix `aa'=`probw''


matrix `matvary'=(1+`aa' *`SIGMAW'*`probw')
scalar `vary'=`matvary'[1,1]
matrix `achesher'=(`probx'+`C'*`probw')/((`vary')^.5)



* Calculating the variance of Chesher (equation (13) in our paper)

* predict the sum of the X-squareds
* Note in missing values model we need to keep track of sample size 
* maybe by using the [if] statement in probit to keep track of sample size.



tempname XprimeX invXprimeX VarC

* Note matrix accum automatically adds a constant as last variable
* See prog manual page 239.

sort `w1'
matrix accum `XprimeX'= `xvarlist' if `missdata'==0
matrix `invXprimeX'=invsym(`XprimeX')
matrix `VarC'=`SIGMAW'#`invXprimeX'


* Create the matrix Vartheta

tempname zero1 zero2 zero3 zero4 zero5 zero6 zero7 zero8 zero9 zero10



matrix `zero1'= J(`numvarxcons', `kl',0)
matrix `zero2'= J(`numvarxcons', `dimsigw',0)

matrix `zero3'= J(`numw', `kl',0)
matrix `zero4'= J(`numw', `dimsigw',0)
matrix `zero5'= J(`kl', `numvarxcons',0)
matrix `zero6'= J(`kl', `numw',0)
matrix `zero7'= J(`kl', `dimsigw',0)
matrix `zero8'= J(`dimsigw', `numvarxcons',0)
matrix `zero9'= J(`dimsigw', `numw',0)
matrix `zero10'= J(`dimsigw', `kl',0)

tempname rowv1 rowv2 rowv3 rowv4

matrix `rowv1'=`probvarx',`probcovwx', `zero1', `zero2'
matrix `rowv2'=`probcovwxprime', `probvarw', `zero3', `zero4'
matrix `rowv3'=`zero5',`zero6', `VarC', `zero7'
matrix `rowv4'=`zero8', `zero9',  `zero10', `VSIGMAW'

tempname Vtheta


matrix `Vtheta'=`rowv1' \ `rowv2' \ `rowv3' \ `rowv4'

* This is just used for Denis new formal for varchesher

tempname rowv12 rowv22 rowv32 

matrix `rowv12'=`probvarx',`probcovwx', `zero1'
matrix `rowv22'=`probcovwxprime', `probvarw', `zero3'
matrix `rowv32'=`zero5',`zero6', `VarC'

tempname Vtheta2


matrix `Vtheta2'=`rowv12' \ `rowv22' \ `rowv32' 



tempname cas v1 v2 v3 v4 varchesher II

*matrix `II'=I(`rsscount')
*matrix `cas'= (`c1'-`achesher'*`sigmayw')
*matrix `v1'=(`probvarx'+`cas'* `probcovwx''+`probcovwx'*`cas'')
*matrix `v2'=`probvarw'*(`cas'*`cas'')
*matrix `v3'=(1-`rho2')*(`v1'+`v2')
*matrix `v4'=`rho2'*`invXprimeX'
*matrix `varchesher'=`v3'+`v4'+`achesher'*`achesher''*(`rho2')^2/(2*`nc')



* Note var-cheasher is going to be replaced by
* expression on top[ of page 5 which involves a_theta and Vtheta



* Calculating da/dtheta
* This involves da/dbx da/dbw da/dc and da/dsigma pieces

* first da/db_x


* Calculating the a_x a_w pieces


tempname axtemp ax1 ax
matrix `axtemp'=((1+`aa'*`SIGMAW'*`probw'))
scalar `ax1'=1/(`axtemp'[1,1] ^.5)
matrix `ax'=I(`numvarxcons')* `ax1'



* The following creates a vector with the aws for each of the xís.

tempname aw1 aw 


matrix `aw1'=`SIGMAW'*`probw'
matrix `aw'=J(`numw',`numvarxcons',0)


local k=1
while `k'<=`numvarxcons' {

local l=1
while `l'<=`numw' {

matrix `aw'[`l',`k']= `C'[`k', `l']/ ///
((`vary')^.5) ///
- (`achesher'[`k',1]* `aw1'[`l',1]) ///
/(`vary')

local ++l
}
local ++k
}


* Now a_cís 

tempname II

matrix `II'=I(`numvarxcons')

local i=1
while `i'<=`numw' {
tempname topc`i'

matrix `topc`i''=`II'*`probw'[`i',1]/(`vary')^.5

local ++i
}

tempname ac
matrix `ac'=`topc1'

local j=2
while `j'<=`numw' {

matrix `ac'=`ac' \ `topc`j''

local ++j
}



* Now the a_sigwís.

* To do this first need to create the matrix G 

local k=1

while `k'<=`numw' {
tempname probwtemp`k'

matrix `probwtemp`k''= `probw'[`k'..`numw',1]*`probw'[`k',1]*2
matrix `probwtemp`k''[1,1]= `probwtemp`k''[1,1]/2

local ++k
}

tempname G

matrix `G'=`probwtemp1'

local k=2
while `k'<=`numw' {

matrix `G'=`G' \ `probwtemp`k''

local ++k
}

tempname asigma asigma1 asigma12
matrix `asigma1'=-(2*(1+`probw''*`SIGMAW'*`probw'))
scalar `asigma12'=1/`asigma1'[1,1]
matrix `asigma'=(`asigma12')*`G'*`achesher''


* Now just bring the daís into one big vector


tempname datheta datheta2

matrix `datheta'=`ax' \ `aw' \ `ac' \ `asigma'
matrix `datheta2'=`ax' \ `aw' \ `ac' 


* Just check Denis formula for contribution og varw to overall variance.

tempname test1 test3 test4 test5 test6 test7
matrix `test1'=`asigma''*`VSIGMAW'*`asigma'


matrix `test3'=(`aa' *`SIGMAW'*`probw') 
matrix `test4'=`achesher'*`achesher''*((`test3'[1,1])^2)/ ///
((2*`vary'^2)*(`nc'-`rsscount'))


scalar `test5'=(2*`test3'[1,1]^2)/(`nc'-`rsscount')

matrix `test6'=`G''*`VSIGMAW'*`G'

scalar `test7'=`test6'[1,1]



* Now create the variance of Chesher

tempname varchesher varchesher2

matrix `varchesher'=`datheta''*`Vtheta'*`datheta'
matrix `varchesher2'=`datheta2''*`Vtheta2'*`datheta2'+`test4'

*display "This is the variance of chesher using full model (with H)"
*matrix list `varchesher' 

*display "This is the variance of chesher using reduced formual (without H)"
*matrix list `varchesher2' 


* Now create the thetax and thetaw weigthing matrix for the efficient estimator 

tempname thetax thetaw
matrix `thetax'=`probvarx'*`ax'+`probcovwx'*`aw'
matrix `thetaw'= `probcovwx''*`ax'+`probvarw'*`aw'




* Run the simple probit model (not needed in latest spec)

quietly probit `lhsvar' `xvarlist' if `missdata'==0


tempname probitpar2 probx2 probitsimplecov varsimple astar
matrix `probitpar2'=e(b)'
matrix `astar'=`probitpar2'
matrix `probx2'=`probitpar2'
matrix `probitsimplecov'=e(V)
matrix `varsimple'=`probitsimplecov'



* Now we want to estimate probit of z on X for the extra (n-r) observations
* that is we want to get the abar

quietly probit `lhsvar' `xvarlist' if `missdata'==1

tempname probitparmiss abar probitcovabar varabar

matrix `probitparmiss'=e(b)'
matrix `abar'=`probitparmiss'
matrix `probitcovabar'=e(V)
matrix `varabar'=`probitcovabar'



* Now create ahat which is the efficient estimator of a with all data
* Conniffe 1997 eqt(1)
* This is not needed for latest approach


tempname ahatpart1 ahatpart2 ahat temp temp2


matrix `ahatpart1'=(`varabar'*inv(`varabar'+`varchesher'))*`achesher'
matrix `ahatpart2'=(`varchesher'*invsym(`varabar'+`varchesher'))* `abar'
matrix `ahat'=`ahatpart1'+`ahatpart2'

*Variance of ahat eqt(14)

tempname vhat

matrix `vhat'=`varchesher'*(inv(`varabar'+`varchesher'))*`varabar'

* using linear probit model for correction
* 

tempname amisslprob anomisslprob 

quietly regress `lhsvar' `xvarlist' if `missdata'==1
matrix `amisslprob'=e(b)'

quietly regress `lhsvar' `xvarlist' if `missdata'~=1
matrix `anomisslprob'= e(b)'



*** NOW PULL THE ELEMENTS INTO OUR EFFICIENT ESTIMATOR of bx 
*** Check dimensions of achesher and abar and probx as regards constant

tempname bxeff vsum bxeff2 bxlprob
matrix `vsum'=`varchesher'+`varabar'


matrix `bxeff'=`probx'-`thetax'*invsym(`vsum')*(`achesher'-`abar')
matrix `bxeff2'=`probx'-`thetax'*invsym(`vsum')*(`astar'-`abar')
matrix `bxlprob'=`probx'-`thetax'*invsym(`vsum')*(`anomisslprob'-`amisslprob')


*** NOW PULL THE ELEMENTS INTO Variance of OUR EFFICIENT ESTIMATOR eqt (15)


tempname varbeff 

matrix `varbeff'=`probvarx'-`thetax'*invsym(`vsum')*`thetax''





*** NOW PULL THE ELEMENTS INTO OUR EFFICIENT ESTIMATOR of bw 

tempname bweff bweff2 bwlprob

matrix `bweff'=`probw'-`thetaw'*invsym(`vsum')*(`achesher'-`abar')
matrix `bweff2'=`probw'-`thetaw'*invsym(`vsum')*(`astar'-`abar')
matrix `bwlprob'=`probw'-`thetaw'*invsym(`vsum')*(`anomisslprob'-`amisslprob')





*** NOW PULL THE ELEMENTS INTO Variance of OUR EFFICIENT ESTIMATOR of bw

tempname varbeffw sebeffw

matrix `varbeffw'=`probvarw'-`thetaw'*invsym(`vsum')*`thetaw''
scalar `sebeffw'=`varbeffw'[1,1]^.5



*** NOW PULL THE ELEMENTS INTO Covar of bx and bw

tempname covbwbx 
matrix `covbwbx'=`probcovwx'-`thetax'*invsym(`vsum')*`thetaw''

*** PULL TOGETHER TO GET FINAL B-vector & final VAR-COV MATRIX

tempname bfinal
matrix `bfinal'=(`bweff')\(`bxeff')

tempname varfinal 
matrix `varfinal'=(((`varbeffw')\(`covbwbx'))')\((`covbwbx'),(`varbeff'))



* Now do a Hausman test for MAR

probit `lhsvar' `wvarlist' `xvarlist' 

tempname b V hausa hausb hausc haus

matrix `b' =`bfinal''

matrix colnames `b' = `wvarlist' `xvarlist' cons


matrix `V' =(`varfinal')
matrix colnames `V' = `wvarlist' `xvarlist' cons
matrix rownames `V' = `wvarlist' `xvarlist' cons


tempname probxslope bxeffslope probvarxslope varbeffslope
tempname hausaslope hausbslope hauscslope hausslope

* Doing the Hausman test for the full set of coefficients

matrix `hausa'=(`probx'-`bxeff')

matrix `hausb'=invsym(`probvarx'-`varbeff')
matrix `hausc'=`hausa''*`hausb'*`hausa'
scalar `haus'=`hausc'[1,1]



* Doing the Hausman test for the slope coefficients

matrix `probxslope'=`probx'[1..`numvarx',1]
matrix `bxeffslope'=`bxeff'[1..`numvarx',1]
matrix `probvarxslope'=`probvarx'[1..`numvarx',1.. `numvarx']
matrix `varbeffslope'=`varbeff'[1..`numvarx',1.. `numvarx']

matrix `hausaslope'=(`probxslope'-`bxeffslope')
matrix `hausbslope'=invsym(`probvarxslope'-`varbeffslope')
matrix `hauscslope'=`hausaslope''*`hausbslope'*`hausaslope'
scalar `hausslope'=`hauscslope'[1,1]

* Doing Hausman test using Chesher & Conniffe

tempname probxslopec bxeffslopec probvarxslopec varbeffslopec
tempname hausaslopec hausbslopec hauscslopec hausslopec

matrix `probxslopec'=`achesher'[1..`numvarx',1]
matrix `bxeffslopec'=`ahat'[1..`numvarx',1]
matrix `probvarxslopec'=`varchesher'[1..`numvarx',1..`numvarx']
matrix `varbeffslopec'=`vhat'[1..`numvarx',1..`numvarx']



matrix `hausaslopec'=(`probxslopec'-`bxeffslopec')
matrix `hausbslopec'=invsym(`probvarxslopec'-`varbeffslopec')
matrix `hauscslopec'=`hausaslopec''*`hausbslopec'*`hausaslopec'
scalar `hausslopec'=`hauscslopec'[1,1]



ereturn clear

tempvar touse

qui gen byte `touse'=e(sample)
ereturn post `b' `V', depname(`1') esample(`touse')


ereturn display

ereturn scalar N=`nc'
ereturn scalar N2=`ntotal'
ereturn scalar Chi2=`hausslope'
ereturn scalar seb=`sebeffw'
ereturn scalar sebcomp=`seprobcomp'
ereturn matrix achesher=`achesher'
ereturn matrix bxeff2=`bxeff2'
ereturn matrix bwlprob=`bwlprob'
ereturn matrix bxlprob=`bxlprob'
ereturn matrix anomisslprob=`anomisslprob'
ereturn matrix amisslprob=`amisslprob'


*dis ""
*dis "Hausman test using Chesher & Conniffe for MAR"
*dis _newline 
*dis _skip(3) "Chi2 Test Statistic" _skip(2) `hausslopec' 
*dis _skip(3) "Degrees of Freedom" "(" `numvarx' ")"  
*dis _newline
*dis _skip(3) "p-value" _skip(1) chi2tail(`numvarx', `hausslopec')

*dis ""
*dis as text "{hline 78}"

dis ""
dis "Hausman type test for MAR on slope coefficients"
dis _newline 
dis _skip(3) "Chi2 Test Statistic" _skip(2) `hausslope' 

dis _skip(3) "Degrees of Freedom" "(" `numvarx' ")"  
dis _newline
dis _skip(3) "p-value" _skip(1) chi2tail(`numvarx', `hausslope')

dis ""
dis as text "{hline 78}"


end






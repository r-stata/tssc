*! Date        : 6 Dec 2006
*! Version     : 1.04
*! Authors     : Adrian Mander
*! Email       : adrian.mander@mrc-hnr.cam.ac.uk
*!
*! Description : clogit allowing weights to vary within group()
*! The weights are within strata weights.. NOT frequency weights!!!

/*
6Dec06 v1.04 - Solves one bug about dropping sets of non-varying exposure or outcome

NOTE use the union pre-load dataset to see problem with multiple events per paired set.. this is
still a problem

*/

/* Need to implement replay() */

program define wclogit, eclass
version 7.0
syntax [varlist] [if] [in] [aweight/] , Group(varname) [Level(int $S_level) OR ]
preserve

marksample touse

/* Check for explanatory variables that do not change within risksets */

tokenize `varlist'
local depvar "`1'"

local newvlist ""
_rmcoll `varlist'
local list "`r(varlist)'"
foreach var of local list {
   qui sort `group' `var'
   qui by `group': gen grpn = _N if `touse'
   qui by `group' `var': gen subgrpn = _N if `touse'
   qui count if subgrpn==grpn & `touse'
   if `r(N)'==_N {
     di as txt "note: `var' omitted due to no within-group variance."
   }
   if `r(N)'<_N {
     local newvlist "`newvlist' `var'"
   }
   drop grpn subgrpn
}

/* Disease must be binary!!! */

local i 1
foreach var of local newvlist {
  if `i'~=1 {
    local sublist "`sublist' `var'"
  }
  if `i'==1 {
    local case "`var'"
    local i=`i'+1
  }
  qui drop if `var'==.
}

tempname wght Xb sum theta grp ade

qui clogit `newvlist', group(`group') `or' nolog
mat beta = get(_b) 

/* The algorithm breaks if there is some perfect matched sets.. and the
weights shouldn't affect this... 
*/
qui gen `ade'=e(sample)
qui su `ade'
if r(min)==0 {
  di as error "Warning : Dropping lines of data due to all positive or all negative outcomes"
  drop if `ade'==0
  drop `ade'
}


cap estimates clear

if "`exp'"=="" {
	gen `wght' =1
}
else gen `wght'=`exp'

sort `group'

local names: colnames(beta)

local oldlik  0
local likhood 1
local i 1
di
while (abs(`likhood'-`oldlik')>0.000001) {

  /*
    1) Create the X by beta variable beta should contain all the variables in model 
    2) Then sum all WiQi per risk set for `sum'
    3) Then calc the likelihood of risk set w

matrix score creates Xb  given the current beta  and Xb is just a tempname
Theta therefore consists of the exponential of the previous data.. this is where a large beta messes up!!!!

  */

  matrix score double `Xb' = beta
  qui gen double `theta' = exp(`Xb')
  qui by `group': gen double `sum' = sum(`theta'*`wght')
  qui by `group': gen double w = `theta'*`wght'/`sum'[_N]

/*
A debug
su `Xb' w `sum' `theta'
mat list beta
*/

/* MY test on what is happening with score function... this is probably
only going to work when weights sum to 1 within group... i.e. probability weights.

  qui by `group': gen double l=sum(`theta'*`wght')
  qui by `group': gen double k=sum(`theta'*`wght'*e)
  qui by `group': gen double score = cond(d==1,e,.)-k/l
  qui by `group': gen kl = k/l if _n==_N
*/

/* I think this is another way of calculating the matrices 
NO need it to get `w'
*/

  parse "`sublist'", parse(" ")
  local sw ""
  local w  ""
  local no 1
  while "`1'"~="" {
/* square rooting w here because of mat accum later */
 /* OLDWAY   qui gen double w`no' = `1'*sqrt(w) */
/*Not sure this correct */
    qui gen double w`no' = `1'*sqrt(w) 

    qui by `group': gen double s`no' = sum(`1'*w)
    local sw = "`sw'"+" s`no'"
    local w = "`w'"+" w`no'"
    mac shift
    local no = `no'+1
  }

/*
   A contains the x-value for the case
   AA contains  W*x summed
   B = also W*x summed
   C = W^2*x^2
*/
  qui by `group': gen `grp'= _n==_N
  qui matrix accum A = `case' `sublist' , nocons
  qui matrix accum AA = w `sublist', nocons
  qui matrix accum B = `w', nocons
  qui matrix accum C = `sw' if `grp'==1, nocons

/*
di "theta `theta' weight `wght' sum `sum' Xb `Xb' "
blist
*/


/*
  Solution is when the score U = 0 
  change in gradient is U/V.... add this to previous estimate

U2 wrong

*/

  mat U1 = A[1,2...]
  mat U2 = AA[1,2...]
  matrix U = U1-U2
  matrix V = B-C
  mat Vinv = syminv(V)
  mat grad = U*Vinv
  mat nbeta = beta + grad
  mat beta = nbeta

  matrix colnames beta = `names'
  matrix colnames Vinv = `names'
  matrix rownames Vinv = `names'

  drop `Xb'
  drop `theta'
  drop `sum'
  drop w
  drop `sw'
  drop `w'
  drop `grp'

/* Calculate loglikelihood */

  qui matrix score `Xb' = beta
  qui gen double `theta' = exp(`Xb')
  qui by `group':gen temp=sum(`theta')
  qui by `group': gen double temp1 = cond(`case'==1, ln(`theta'[_n]/temp[_N]),0)
  qui replace temp1= sum(temp1)
  local oldlik = `likhood'
  local likhood = temp1[_N]
  di as txt "Iteration `i':   log likelihood =", as res round(`likhood',0.00000001)
  drop temp*
  drop `theta'
  drop `Xb'
  local i= `i'+1
}

/* The _N is your obs because weights are within strata weights and this should be individual data*/
local obs = _N


estimates post beta Vinv, depname("`case'") obs(`obs')
qui testparm `newvlist'
di
local len=79-length("`obs'")
di as txt "Strata-varying weighted clogit ", _col(51) "Number of obs", _col(67) "=", _col(`len') as res `obs'
di as txt _col(51) "Wald chi2(",as res `r(df)',as txt ")", _col(67) "=", _col(73) as res %6.3f `r(chi2)'
di as txt _col(51) "Prob > chi2", _col(67) "=", _col(74) as res %4.3f `r(p)'
di as txt "Log likelihood =", as res round(`likhood',0.00000001)
di
if "`or'"~="" { estimates display, eform(Odds Ratio) }
else { estimates display }

est scalar ll= `likhood'
est scalar df_m=colsof(nbeta)
/*est scalar r2_p = `r(p)'
*/
est local cmd = "wclogit"
est local group= "`group'"
est local predict "wclogit_p"
est local depvar "`depvar'"
est local chi2type "Wald"


restore
end


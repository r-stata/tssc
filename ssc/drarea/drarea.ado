*! Date    : 27 October 2014
*! Version : 1.08
*! Author  : Adrian Mander
*! Email   : adrian.mander@mrc-bsu.cam.ac.uk

/*
 2/4/07   v1.02 allows the user to specify the overlap colour as the third color in the color() option
 2/4/07   v1.03 allows the overlapping areas to be saved into the dataset but to get 3 overlapping areas doesn't work so isn't a documented feature.
20/9/07   v1.04 allows additional twoway plots to be added
29/5/13   v1.05 fixes the help file
 9/5/14   v1.06 fixes a bug found by Anna Drabik to handle values being equal
12/5/14   v1.07 fixes a legend bug
27/10/14  v1.08 fixes another bug with overlapping lines... zone 2-4
*/
 
program def drarea 
version 9.2
syntax varlist(min=5 max=5) [if] [in] [, Color(string asis) Add Generate(string) TWOWAY(string asis) *]
local xoptions "`options'"
if "`generate'"=="" preserve

marksample touse
qui keep if `touse'

tempvar zone zone1 zonelast zonefuture lineorder lineorder2 h4 l4

/* Setup the local macros with variable names */
local i 1
foreach v of local varlist {
  if `i'==1   local h1 "`v'"
  if `i'==2   local l1 "`v'"
  if `i'==3   local h2 "`v'"
  if `i'==4   local l2 "`v'"
  if `i++'==5 local  x "`v'"
}
qui sort `x'
qui gen `lineorder' = _n
qui gen `lineorder2' = -1*_n

/* Check to see if the order of the variables are correct or in fact that hi and lo are in the
correct direction.
The rarea doesn't really care about the range order and so overlapping can occur (this becomes too painful to
do when doing the overlap shading
*/

qui count if `h1' <`l1' 
if `r(N)'>0 {
  di as error "Warning `h1' has `r(N)' values lower than `l1' (which makes NO sense)"
  di as error "Changing these values...."
  replace `h1'=`l1' if `h1'<`l1'
}
qui count if `h2' <`l2' 
if `r(N)'>0 {
  di as error "Warning `h2' has `r(N)' values lower than `l2' (which makes NO sense)"
  di as error "Changing these values...."
  replace `h2'=`l2' if `h2'<`l2'
}

/************************************************************
 * Calculate the zones, next zone, future and last zone 
 * for v1.06 I changed > to >= to try and handle equality!
 ************************************************************/
qui gen `zone' = ((`h2'>=`h1')*(`l2'>=`h1')*(`l2'>=`l1')*(`h2'>=`l1'))*1 + ////  /*  h2 l2 h1 l1 */
               ((`h2'>=`h1')*(`l2'<`h1')*(`l2'>=`l1')*(`h2'>=`l1'))*2 + ////     /*  h2 h1 l2 l1 */ 
               ((`h2'>=`h1')*(`l2'<`h1')*(`l2'<`l1')*(`h2'>=`l1'))*3 + ////      /*  h2 h1 l1 l2 */
               ((`h2'<`h1')*(`l2'<`h1')*(`l2'<`l1')*(`h2'<`l1'))*4 + ////        /*  h1 l1 h2 l2 */
               ((`h2'<`h1')*(`l2'<`h1')*(`l2'<`l1')*(`h2'>=`l1'))*5 + ////       /*  h1 h2 l1 l2 */ 
               ((`h2'<`h1')*(`l2'<`h1')*(`l2'>=`l1')*(`h2'>=`l1'))*6             /*  h1 h2 l2 l1 */
qui gen `zone1' = `zone'[_n+1]
qui gen `zonelast' = `zone' in 1
qui replace `zonelast' = cond(`zone'==4 | `zone'==1, `zonelast'[_n-1], `zone')
sort `lineorder2'
qui gen `zonefuture' = `zone' in 1
qui replace `zonefuture' = cond(`zone'==4 | `zone'==1, `zonefuture'[_n-1], `zone')
sort `x' `lineorder'

/* 
Used my blist for debugging 

blist
*/

/* Now for each zone change I have to find out the bits that overlap and add
these data to the end...
Of course as soon as x is sorted then everything goes in the right position

Missing data can occur for hi or lo and extrapolation occurs.. I use this fact in
some of the calculations

*/
local nobs = _N
local lobs = _N

forv i=1/`nobs' {
  if `zone'[`i']~=`zone'[`i'+1] & `i'<`nobs' {
    qui set obs `++lobs'

      if (`zone'[`i']==1 & `zone1'[`i']==2) {
        qui _calc `h1'[`i'] `h1'[`i'+1] `l2'[`i'] `l2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(l)' in `lobs'
        qui replace `l1' = `r(h)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
      }
      if (`zone'[`i']==1 & `zone1'[`i']==3) { /* the lines cross twice between zones... */
        qui _calc `h1'[`i'] `h1'[`i'+1] `l2'[`i'] `l2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `h1' in `lobs'
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
        qui set obs `++lobs'
        qui _calc `l1'[`i'] `l1'[`i'+1] `l2'[`i'] `l2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `h1' in `lobs'
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
      }
      if (`zone'[`i']==1 & `zone1'[`i']==4) | (`zone'[`i']==4 & `zone1'[`i']==1) { /* 4 lines cross */
        qui _calc `l1'[`i'] `l1'[`i'+1] `l2'[`i'] `l2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = . in `lobs'
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs' 
        qui set obs `++lobs'
        qui _calc `h1'[`i'] `h1'[`i'+1] `h2'[`i'] `h2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(h)' in `lobs'
        qui replace `l1' = . in `lobs'
        qui replace `x' = `r(x)' in `lobs'
        qui set obs `++lobs'
        qui _calc `h1'[`i'] `h1'[`i'+1] `l2'[`i'] `l2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = . in `lobs'
        qui replace `l1' = `r(h)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
        qui set obs `++lobs'
        qui _calc `h2'[`i'] `h2'[`i'+1] `l1'[`i'] `l1'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(h)' in `lobs'
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
     }
     if (`zone'[`i']==1 & `zone1'[`i']==5) { /* Two lines cross */
        qui _calc `l1'[`i'] `l1'[`i'+1] `l2'[`i'] `l2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = . in `lobs'
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs' 
        qui set obs `++lobs'
        qui _calc `h1'[`i'] `h1'[`i'+1] `h2'[`i'] `h2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(h)' in `lobs'
        qui replace `l1' = . in `lobs'
        qui replace `x' = `r(x)' in `lobs'
        qui set obs `++lobs'
        qui _calc `h1'[`i'] `h1'[`i'+1] `l2'[`i'] `l2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = . in `lobs'
        qui replace `l1' = `r(h)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
     }
      if `zone'[`i']==1 & `zone1'[`i']==6 { /* Two lines cross */
        qui _calc `h1'[`i'] `h1'[`i'+1] `h2'[`i'] `h2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(h)' in `lobs'
        qui replace `l1' = . in `lobs'
        qui replace `x' = `r(x)' in `lobs'
        qui set obs `++lobs'
        qui _calc `h1'[`i'] `h1'[`i'+1] `l2'[`i'] `l2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = . in `lobs'
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
     }

/* from 2 */
      if `zone'[`i']==2 & `zone1'[`i']==1 {
        qui _calc `h1'[`i'] `h1'[`i'+1] `l2'[`i'] `l2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(h)' in `lobs'
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
      }
      if `zone'[`i']==2 & `zone1'[`i']==3 {
        qui _calc `l1'[`i'] `l1'[`i'+1] `l2'[`i'] `l2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = . in `lobs'
        qui replace `l1' = `r(h)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
      }
     if (`zone'[`i']==2 & `zone1'[`i']==4) { /* Three lines cross */
        qui _calc `l1'[`i'] `l1'[`i'+1] `l2'[`i'] `l2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = . in `lobs'
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs' 
        qui set obs `++lobs'
        qui _calc `h1'[`i'] `h1'[`i'+1] `h2'[`i'] `h2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(h)' in `lobs'
        qui replace `l1' = . in `lobs'
        qui replace `x' = `r(x)' in `lobs'
        qui set obs `++lobs'
        qui _calc `h2'[`i'] `h2'[`i'+1] `l1'[`i'] `l1'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(h)' in `lobs'
        qui replace `l1' = . in `lobs'
        qui replace `x' = `r(x)' in `lobs'
     }
     if (`zone'[`i']==4 & `zone1'[`i']==2) { /* Three lines cross */
        qui _calc `l1'[`i'] `l1'[`i'+1] `l2'[`i'] `l2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = . in `lobs'
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs' 
        qui set obs `++lobs'
        qui _calc `h1'[`i'] `h1'[`i'+1] `h2'[`i'] `h2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(h)' in `lobs'
        qui replace `l1' = . in `lobs'
        qui replace `x' = `r(x)' in `lobs'
        qui set obs `++lobs'
        qui _calc `h2'[`i'] `h2'[`i'+1] `l1'[`i'] `l1'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(h)' in `lobs'
        qui replace `l1' = . in `lobs'
        qui replace `x' = `r(x)' in `lobs'
     }
      if `zone'[`i']==2 & `zone1'[`i']==5 { /* Double cross */
        qui _calc `l1'[`i'] `l1'[`i'+1] `l2'[`i'] `l2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = . in `lobs'
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
        qui set obs `++lobs'
        qui _calc `h1'[`i'] `h1'[`i'+1] `h2'[`i'] `h2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(h)' in `lobs'
        qui replace `l1' = . in `lobs'
        qui replace `x' = `r(x)' in `lobs'
      }
      if `zone'[`i']==2 & `zone1'[`i']==6 {
        qui _calc `h1'[`i'] `h1'[`i'+1] `h2'[`i'] `h2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(h)' in `lobs'
        qui replace `l1' = . in `lobs'
        qui replace `x' = `r(x)' in `lobs'
      }

/* from 3*/

      if `zone'[`i']==3 & `zone1'[`i']==1 { 
        qui _calc `l1'[`i'] `l1'[`i'+1] `l2'[`i'] `l2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `h1' in `lobs'
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
        qui set obs `++lobs'
        qui _calc `h1'[`i'] `h1'[`i'+1] `l2'[`i'] `l2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `h1' in `lobs'
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
      }
      if `zone'[`i']==3 & `zone1'[`i']==2 {
        qui _calc `l1'[`i'] `l1'[`i'+1] `l2'[`i'] `l2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `h1' in `lobs'
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
      }
      if `zone'[`i']==3 & `zone1'[`i']==4 {
        qui _calc `h2'[`i'] `h2'[`i'+1] `h1'[`i'] `h1'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(h)' in `lobs'
        qui replace `l1' = . in `lobs'
        qui replace `x' = `r(x)' in `lobs'
        qui set obs `++lobs'
        qui _calc `h2'[`i'] `h2'[`i'+1] `l1'[`i'] `l1'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(h)' in `lobs'
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
      }
      if `zone'[`i']==3 & `zone1'[`i']==5 { 
        qui _calc `h1'[`i'] `h1'[`i'+1] `h2'[`i'] `h2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(h)' in `lobs'
        qui replace `l1' = . in `lobs'
        qui replace `x' = `r(x)' in `lobs'
      }
      if `zone'[`i']==3 & `zone1'[`i']==6 { /* upper and lower lines cross */
        qui _calc `l1'[`i'] `l1'[`i'+1] `l2'[`i'] `l2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `h1' in `lobs'
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
        qui set obs `++lobs'
        qui _calc `h1'[`i'] `h1'[`i'+1] `h2'[`i'] `h2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(l)' in `lobs'
        qui replace `l1' = . in `lobs'
        qui replace `x' = `r(x)' in `lobs'
      }

      if `zone'[`i']==4 & `zone1'[`i']==3 {
        qui _calc `h2'[`i'] `h2'[`i'+1] `h1'[`i'] `h1'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(h)' in `lobs'
        qui replace `l1' = . in `lobs'
        qui replace `x' = `r(x)' in `lobs'
        qui set obs `++lobs'
        qui _calc `h2'[`i'] `h2'[`i'+1] `l1'[`i'] `l1'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(h)' in `lobs'
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
      }
      if `zone'[`i']==4 & `zone1'[`i']==5 {
        qui _calc `h2'[`i'] `h2'[`i'+1] `l1'[`i'] `l1'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(h)' in `lobs'
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
      }
      if `zone'[`i']==4 & `zone1'[`i']==6 { /* Two lines cross */
        qui _calc `h2'[`i'] `h2'[`i'+1] `l1'[`i'] `l1'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(l)' in `lobs'  /* Dots stop another calculation being performed :) */
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
        qui set obs `++lobs'
        qui _calc `l2'[`i'] `l2'[`i'+1] `l1'[`i'] `l1'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = . in `lobs'
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
      }

      if `zone'[`i']==5 & `zone1'[`i']==1 { /* Two lines cross */
        qui _calc `h1'[`i'] `h1'[`i'+1] `h2'[`i'] `h2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(h)' in `lobs'
        qui replace `l1' = . in `lobs'
        qui replace `x' = `r(x)' in `lobs'
        qui set obs `++lobs'
        qui _calc `l1'[`i'] `l1'[`i'+1] `l2'[`i'] `l2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = . in `lobs'
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
     }
     if `zone'[`i']==5 & `zone1'[`i']==2 { /* Double cross */
        qui _calc `l1'[`i'] `l1'[`i'+1] `l2'[`i'] `l2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = . in `lobs'
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
        qui set obs `++lobs'
        qui _calc `h1'[`i'] `h1'[`i'+1] `h2'[`i'] `h2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(h)' in `lobs'
        qui replace `l1' = . in `lobs'
        qui replace `x' = `r(x)' in `lobs'
      }
      if `zone'[`i']==5 & `zone1'[`i']==3 { 
        qui _calc `h1'[`i'] `h1'[`i'+1] `h2'[`i'] `h2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(h)' in `lobs'
        qui replace `l1' = . in `lobs'
        qui replace `x' = `r(x)' in `lobs'
      }
      if `zone'[`i']==5 & `zone1'[`i']==4 {
        qui _calc `h2'[`i'] `h2'[`i'+1] `l1'[`i'] `l1'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(l)' in `lobs'
        qui replace `l1' = `r(h)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
      }
      if `zone'[`i']==5 & `zone1'[`i']==6 {
        qui _calc `l1'[`i'] `l1'[`i'+1] `l2'[`i'] `l2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = . in `lobs'
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
      }

/* 6 */
      if `zone'[`i']==6 & `zone1'[`i']==1 { /* Two lines cross */
        qui _calc `h1'[`i'] `h1'[`i'+1] `h2'[`i'] `h2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(h)' in `lobs'
        qui replace `l1' = . in `lobs'
        qui replace `x' = `r(x)' in `lobs'
        qui set obs `++lobs'
        qui _calc `h1'[`i'] `h1'[`i'+1] `l2'[`i'] `l2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = . in `lobs'
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
     }
      if `zone'[`i']==6 & `zone1'[`i']==2 {
        qui _calc `h1'[`i'] `h1'[`i'+1] `h2'[`i'] `h2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(h)' in `lobs'
        qui replace `l1' = . in `lobs'
        qui replace `x' = `r(x)' in `lobs'
      }
      if `zone'[`i']==6 & `zone1'[`i']==3 { /* Two lines cross */
        qui _calc `l1'[`i'] `l1'[`i'+1] `l2'[`i'] `l2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = . in `lobs'
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
        qui set obs `++lobs'
        qui _calc `h1'[`i'] `h1'[`i'+1] `h2'[`i'] `h2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(l)' in `lobs'
        qui replace `l1' = . in `lobs'
        qui replace `x' = `r(x)' in `lobs'
     }
     if `zone'[`i']==6 & `zone1'[`i']==4 { /* Two lines cross */
        qui _calc `l2'[`i'] `l2'[`i'+1] `l1'[`i'] `l1'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = . in `lobs'  /* Dots stop another calculation being performed :) */
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
        qui set obs `++lobs'
        qui _calc `h2'[`i'] `h2'[`i'+1] `l1'[`i'] `l1'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `r(l)' in `lobs'
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
      }
      if `zone'[`i']==6 & `zone1'[`i']==5 {
        qui _calc `l1'[`i'] `l1'[`i'+1] `l2'[`i'] `l2'[`i'+1] `x'[`i'] `x'[`i'+1]
        qui replace `h1' = `h1' in `lobs'
        qui replace `l1' = `r(l)' in `lobs'
        qui replace `x' = `r(x)' in `lobs'
      }
  }
}
qui sort `x' `lineorder'

/*
blist
*/
/*
Generate the variables for the overlapping area 

The imputed points at the junction zone==. shouldn't be plotted for the original data
zone is the current zone the points are in.
*/

qui gen `h4'     = `h1' if `zone'==2 
qui replace `h4' = `h1' if `zone'==3
qui replace `h4' = `h2' if `zone'==5
qui replace `h4' = `h2' if `zone'==6
qui replace `h4' = `h1' if `zone'==.
qui replace `h4' = `h1' if `zone'==1
qui replace `h4' = `h1' if `zone'==4

qui gen `l4'     = `l2' if `zone'==2 
qui replace `l4' = `l1' if `zone'==3
qui replace `l4' = `l1' if `zone'==5
qui replace `l4' = `l2' if `zone'==6
qui replace `l4' = `l1' if `zone'==.
qui replace `l4' = `h1' if `zone'==1
qui replace `l4' = `h1' if `zone'==4

/* Corrections for all the switching over of the base line... choosing top or bottom 
Because rarea doesn't stop at missing data the in between overlapping areas turn into a line
The line is secretly attached to one of the range plots so you don't see the magic!
zone1 is the next zone.
*/
qui replace `h4' = `l1' if `zone'==4 & ( `zone1'==6 | `zone1'==5 )
qui replace `l4' = `l1' if `zone'==4 & ( `zone1'==6 | `zone1'==5 )
qui replace `h4' = `l1' if `zone'==4 & `zone1'==4 & (`zonelast'==5 | `zonelast'==6) 
qui replace `l4' = `l1' if `zone'==4 & `zone1'==4 & (`zonelast'==5 | `zonelast'==6)
qui replace `h4' = `l1' if `zone'==4 & `zone1'==. & (`zonelast'==5 | `zonelast'==6) 
qui replace `l4' = `l1' if `zone'==4 & `zone1'==. & (`zonelast'==5 | `zonelast'==6)
qui replace `h4' = `l1' if `zone'==4 & `zone1'==4 & (`zonefuture'==5) 
qui replace `l4' = `l1' if `zone'==4 & `zone1'==4 & (`zonefuture'==5)
qui replace `h4' = `l1' if `zone'==4 & `zone1'==4 & (`zonelast'==2) 
qui replace `l4' = `l1' if `zone'==4 & `zone1'==4 & (`zonelast'==2)
qui replace `h4' = `l1' if `zone'==4 & `zone1'==1 
qui replace `l4' = `l1' if `zone'==4 & `zone1'==1
qui replace `h4' = `l1' if `zone'==4 & `zone1'==2  
qui replace `l4' = `l1' if `zone'==4 & `zone1'==2 
qui replace `h4' = `l1' if `zone'==4 & `zone1'==3  
qui replace `l4' = `l1' if `zone'==4 & `zone1'==3

/*
blist `h1' `l1' `h2' `l2' `x' `zone' `zone1' `zonelast' `zonefuture' `h4' `l4'
*list
*/

if `"`color'"'==`""' local color "red yellow"

local i 1
local rgb 1
if `"`color'"'~=`""' {
  foreach col in `color' {
    local j 1
    foreach comp of local col {
      if `j'==1 local r "r"
      if `j'==2 local r "g"
      if `j++'==3 local r "b"
      if real("`comp'")~=. {
        local `r'`i'=real("`comp'")
        local rgb 0
      }
    }
    if `rgb' {
      _rgb `col'
      local r`i' = `r(r)'
      local g`i' = `r(g)'
      local b`i' = `r(b)'
    }
    local c`i' "`r`i'' `g`i'' `b`i''"
    local `i++'
  }
  local r3 = int( (`r1'+`r2')/2 ) 
  local g3 = int( (`g1'+`g2')/2 ) 
  local b3 = int( (`b1'+`b2')/2 ) 
  if `"`c3'"'=="" local c3 "`r3' `g3' `b3'"

/*
di "`c1'   `r1'  `g1' `b1'"
di `c2'
di `c3'
*/

}

if "`add'"~="" local xtra "(scatter `h4' `x', ms(x) mc(black) ) (scatter `l4' `x', ms(x) mcolor(red) )" 

twoway (rarea `h1' `l1' `x' if `zone'~=., fc("`c1'") lc(black) lw(0) ) (rarea `h2' `l2' `x' if `zone'~=., fc("`c2'")  lc(black) lw(0) ) ////
 (rarea `h4' `l4' `x', fc("`c3'") lc(black) lw(none) ) `xtra' `twoway',  scheme(s2color)  legend(order(1 2)) `xoptions'

/* To generate the variables in the above command */

if "`generate'"~="" {
  local i 1
  foreach v of local generate {
    if `i'==1 qui gen `v'=`h4'
    if `i'==2 qui gen `v'=`l4'
    local `i++'
  }
  qui gen zone=`zone'
  if `i'==2 di "{error}Warning: You need to specify 2 variables in the {bf:generate} option"
}

if "`generate'"=="" restore

end

/*
 Do the calculation of where lines intercept
*/
pr _calc, rclass
args hi hii li lii xi xii
local xcross =  (`li'-`hi')/( (`hii'-`hi')/(`xii'-`xi') - (`lii'-`li')/(`xii'-`xi')  )
return local h = `hi'+`xcross'/(`xii'-`xi')*(`hii'-`hi') 
return local l = `li'+`xcross'/(`xii'-`xi')*(`lii'-`li')
return local x = `xi'+`xcross' 
end

/* code pinched from Nick Winter's full_palette */

prog def _rgb, rclass
args basecolor

capture findfile color-`basecolor'.style
if _rc {
  di as err "{p 0 4 4}"
  di as err "color `basecolor' not found{break}"
  di as err "Type -graph query colorstyle-"
  di as err "for a list of colornames."
  di as err "{p_end}"
  exit 111
}
local fn `"`r(fn)'"'

tempname hdl
file open `hdl' using `"`fn'"', read text
file read `hdl' line
while r(eof)==0 {
  if index(`"`line'"',"set rgb")~=0 {
    local newlline = trim(substr(`"`line'"',index(`"`line'"',"set rgb")+7,.) )
    tokenize `newlline'
    return local r =`1'
    return local g =`2'
    return local b =`3'
    file close `hdl'
    continue, break
  }
  file read `hdl' line
}

end


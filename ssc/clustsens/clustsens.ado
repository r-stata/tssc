*! version 1.0 P.MILLAR 18Mar2005
*! This software can be used for non-commercial purposes only. 
*! The copyright is retained by the developer.
*! Copyright 2005 Paul Millar

/* this program runs the cluster command many times to look at variation in its results */
program clustsens, byable(recall)
   version 7.0
   syntax varlist(numeric) [if] [in], [reps(integer 100) k(integer 3) seed(string) type(string) distopt(string) detail dots] 
 
if "`type'" =="" {
   local type="kmeans"
   }
 if "`distopt'" =="" {
   local distopt="L2"
   }
 
if length("`seed'")==0 {
  set seed 12345789
  }
else {
  set seed `seed'
  }

tempname CLUST ONECLUST

di as text "Checking variability using `distopt' "

mat CLUST=J(`reps',`k',0)
mat ONECLUST=J(`k',1,0)
quietly summ `varlist' `if' `in'
local N=r(N)
 
forvalues i = 1/`reps' {
  local varnam="cl"+string(`i',"%04.0f")
  capture tab `varnam' 
  if _rc == 0 {
    drop `varnam'
    }
  quietly cluster `type' `varlist' `if' `in', k(`k') gen(`varnam') `distopt'
  local seedno`i'="`c(seed)'"
  if "`dots'" == "dots" {
    di _continue as input "."
    }
  forvalues j = 1/`k' {
    quietly means `varlist' if `varnam' == `j'
    local n`j'=r(N)
    local avg`j'=r(mean)
    mat ONECLUST[`j',1]=`n`j''
    }
  matsort ONECLUST
  forvalues j = 1/`k' {
    mat CLUST[`i',`j']=ONECLUST[`j',1]
    }
  }

/* dump the individual results if requested */
if "`detail'" == "detail" {
//  mat list CLUST
  di as text " "
  di _continue " Rep#"
  forvalues grpno =1/`k' {
    di _continue " N Grp" %3.0f `grpno'
    }
  di _continue " Seed"
  di _newline " ----" _continue
  forvalues grpno =1/`k' {
    di _continue " --------"
    }
  di _continue " -------------------------------------"
  forvalues i=1/`reps' {
    di _newline as text %5.0f `i' _continue
    forvalues grpno =1/`k' {
      di _continue as result %9.0f CLUST[`i',`grpno']
      }
    di _continue " `seedno`i''"
    }
  }

di _newline " "
di as text "Size of group varies as follows:"
di " "
di as text "Cluster  Avg.   SD     Min    Max "
di as text "------  ----- ------ ------ ------"

forvalues j=1/`k' {
  local sum=0
  local min=`N'+1
  local max=-1
  forvalues i = 1/`reps' {
    if CLUST[`i',`j'] < `min' {
      local min=CLUST[`i',`j']
      }
    if CLUST[`i',`j'] > `max' {
      local max=CLUST[`i',`j']
      }
    local sum=`sum'+CLUST[`i',`j']
    }
  local nbar=`sum'/`reps'
  local devs=0
  forvalues i = 1/`reps' {
    local devs=`devs'+ ((CLUST[`i',1]-`nbar')^2)
    }
  local sd=(`devs'/`reps')^(0.5)
  di as text %6.0f `j' " " as result %6.0f `nbar' " " %6.1f `sd' " " %6.0f `min' " " %6.0f `max'
  }

end

*! version 1.0 P.MILLAR 18Apr2011
*! This software can be used for non-commercial purposes only. 
*! The copyright is retained by the developer.
*! Copyright 2005-2011 Paul Millar

/* this program samples the cluster command many times to estimate group assignment in the population */
program clustpop, byable(recall) rclass
   version 7.0
   syntax varlist(numeric) [if] [in], [reps(integer 30) k(integer 3) seed(string) type(string) alpha(real 0.05) distopt(string) dots] 
 
if "`type'" =="" {
   local type="kmeans"
   }
 if "`distopt'" =="" {
   local distopt="L2"
   }
 
if length("`seed'")>0 {
  set seed `seed'
  }

if `alpha' > 1.0 | `alpha' < 0.0 {
  di as errror "alpha must be between 0.0 and 1.0"
  exit 198
  }


tempname SAVEMEAN RANK SORTCLUST 
tempvar modes modecount modeprop popgroup popprob newgroup sumvar
forvalues i=1/`k' {
  tempname countvar`i'
  qui gen `countvar`i''=0
  }


/* di as text "Checking variability using `distopt' " */

mat `SORTCLUST'=J(`k',1,0)
qui gen `sumvar'=.
qui gen `newgroup'=.

local savevars="`varlist'"
local nvars=wordcount("`savevars'")
tokenize "`savevars'"
local addvars="`1'"
forvalues ivar=2/`nvars' {
  local addvars="`addvars' + ``ivar'' "
  }
 
forvalues i = 1/`reps' {
  qui cluster `type' `varlist' `if' `in', k(`k') `distopt'
  local varname=s(names)
  local clvar`i'="`varname'"
  if `i' == 1 {
    local outvar1=subinstr("`varname'","clus","cluspop",1)
    local outvar2=subinstr("`varname'","clus","clusprop",1)
    local outvar3=subinstr("`varname'","clus","clusprob",1)
    }

/* sort the groups so that they are in order each time */
  qui replace `sumvar'=`addvars'
  forvalues igroup=1/`k' {
    qui mean `sumvar' if `varname' == `igroup'
    mat `SAVEMEAN'=e(b)
    mat `SORTCLUST'[`igroup',1]=`SAVEMEAN'[1,1]
    }
  matsort `SORTCLUST'
  mat `RANK'=r(rank)
  qui replace `newgroup'=.
  forvalues igroup=1/`k' {
    local oldgroup=`RANK'[`igroup',1]
    qui replace `newgroup' = `oldgroup' if `varname' == `igroup'
    }
  qui replace `varname'=`newgroup'
  if "`dots'" == "dots" {
    di _continue as input "."
    }
  }

/* this section calculates the mode for each case, then estimates the probability that it the true group assignment */
local nobs=_N
/* mat `COUNT'=J(`nobs',`k',0) */

/* get the count for each group assignment */
forvalues i=1/`nobs' {
  forvalues j=1/`reps' {
    local gp=`clvar`j'' in `i'
    if "`gp'" != "." {
      local lastcount=`countvar`gp'' in `i'
      local lastcount=`lastcount'+1
      qui replace `countvar`gp''=`lastcount' in `i'
      }
    }
  }

qui gen `modes'=.
qui gen `modecount'=.
qui gen `modeprop'=.
qui gen `popprob'=.
qui gen `popgroup'=.

/* find the highest count (or mode) */
forvalues i=1/`nobs' {
  local mode=0
  local maxcount=0
  forvalues j=1/`k' {
    local curcount=`countvar`j'' in `i'
    if `curcount' > `maxcount' {
      local maxcount=`curcount'
      local mode=`j'
      }
    }
  qui replace `modes' = `mode' in `i'
  qui replace `modecount' = `maxcount' in `i'
  local prop=`maxcount'/`reps'
  qui replace `modeprop' = `prop' in `i'
  local pval=(1-(`alpha'/2))
  local z=invnormal(`pval')
  local sd=sqrt((`prop'*(1-`prop'))/(`reps'-1))
  local prob=`prop' - (`z'*`sd')
  qui replace `popprob' = `prob' in `i'
  if `prob' >= 0.5 {
    qui replace `popgroup' = `mode' in `i'
    }
/*  di "i=`i', mode=`mode', maxcount=`maxcount', prop=`prop', prob=`prob'" */
  }

forvalues i=1/`reps' {
  qui drop `clvar`i''
  }

qui summ `varlist'
local n1=r(N)
qui summ `popgroup'
local n2=r(N)

di " "
di as result "`n2'" as text " valid cases found, out of " as result "`n1'" as text " original cases"

qui gen `outvar1'=`popgroup'
qui gen `outvar2'=`modeprop'
qui gen `outvar3'=`popprob'

di " "
di as text "Variables generated:"
di as text "--------------------"
di as result "`outvar1'" as text " contains estimated group assignments"
di as result "`outvar2'" as text " contains estimate of proportion of cases in population with this group assignment"
di as result "`outvar3'" as text " contains lower bound of probability of proportion in the population"


mat drop `SAVEMEAN' `RANK' `SORTCLUST' 



end

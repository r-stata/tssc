program mcmcreg, eclass

  /* version 1.0, 4 jan 2012 */
  /* sam schulhofer-wohl, federal reserve bank of minneapolis */

  version 12.0

  syntax varlist(numeric) [if] [in] [fw aw], saving(string asis) d0(real) [iterate(integer 100) seed(integer 12345) replace nolog noconstant]
  local mycmdline `0'

  *confirm we have somewhere to put the results, otherwise abort now
  if "`replace'"=="" capture confirm new file `saving'
  else capture save `saving', `replace'
  if _rc error _rc

  if "`log'"=="nolog" local showiter=0
  else local showiter=1
	
  marksample touse
  unab vars : `varlist'
  gettoken y x : vars
  
  if "`weight'"~="" {
    tempvar w
    qui gen double `w' `exp'
    local usew=1
    }
  else {
    local w ""
    local usew=0
    }
  if "`weight'"=="aweight" local aw=1
  else local aw=0
  if "`constant'"=="noconstant" local c=0
  else local c=1
  
  *make sure we have either a rhs variable or a constant
  local nx : word count `x'
  if `nx'==0 & `c'==0 {
    di "must specify at least one independent variable or include a constant."
    error 101
    }

  *store the original data
  tempfile temp
  qui save `temp', replace

  *keep only the data we want
  qui keep if `touse'

  *remove collinear variables
  _rmcoll `x', `constant' forcedrop
  local x `r(varlist)'
  local nx : word count `x'
  if `nx'>0 local usex 1
  else local usex 0
  
  *get number of observations
  local N=_N

  *estimate a linear regression 
  mata: mcmclinear_reg("`y'","`x'",`iterate',`seed',`d0',`c',"`w'",`usew',`aw',`showiter',`usex')

  *name the returned estimation results and calculate b and V matrices
  qui gen double iter=_n-1
  if `nx'>0 {
    forvalues i=1/`nx' {
      local j : word `i' of `x'
      local k : permname beta_`j'
      rename beta`i' `k'
      }
    }
  if `c'==1 {
    local i=`nx'+1
    rename beta`i' beta__cons
    }
  order iter

  *save
  qui compress
  qui save `saving', `replace'
  *restore original data
  qui use `temp', clear

  *return
  ereturn post [`weight' `exp'], depname(`y') esample(`touse') obs(`N')
  ereturn local cmd "mcmcreg"
  ereturn local cmdline mcmcreg `mycmdline'

end


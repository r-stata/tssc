program lisrelinput, byable(recall) rclass
  version 8.2
  syntax varlist(numeric) [, ND(integer 2) PW]

tempname logfile filehandle
tempvar sampsize

local nvars=wordcount("`varlist'")
if `nvars' <= 0 {
  di as error "No variables specified"
  exit 198
  }
if `nd' <= 0 | `nd' > 6 {
  di as error "Number of decimals must be between 1 and 6"
  exit 198
  }

local width=`nd'+4

if "`pw'" != "pw" { 
  qui regress `varlist'
  qui gen byte `sampsize'=e(sample)
  local cond=" if `sampsize'"
  }
  
/* create the line containing the standard deviations */
forvalues i=1/`nvars' {
  local var=word("`varlist'",`i')
  qui summ `var'
  local sd=r(sd)
  local sdval=trim(string(`sd',"%24.`nd'f"))
  local sdline="`sdline' `sdval'"
  }

/* create the lines containing the correlations */
local minobs=99999999
local maxobs=0
forvalues i=1/`nvars' {
  forvalues j=1/`i' {
    local var1=word("`varlist'",`i')
    local var2=word("`varlist'",`j')
//    di as text "corr `var1' `var2' `cond'"
    qui corr `var1' `var2' `cond'
    local corr=r(rho)
    local cases=r(N)
    if `cases' < `minobs' {
      local minobs=`cases'
      }
    if `cases' > `maxobs' {
      local maxobs=`cases'
      }
    local rval=trim(string(`corr',"%24.`nd'f"))
    local corrline`i'="`corrline`i'' `rval'"
    }
  }
      
if "`pw'" == "pw" & `minobs' != `maxobs' { 
  di as result "The pairwise number of observations ranged from `minobs' to `maxobs'"
  di " "
  }

di " "
di as input "DA NI=`nvars' NO=`minobs' MA=KM"
di as input " "
di as input "LA"
di as input "`varlist'"
di as input " "
di as input "SD"
di as input "`sdline'"
di " "
di "KM"
forvalues i=1/`nvars' {
  di "`corrline`i''"
  }
di " "


end


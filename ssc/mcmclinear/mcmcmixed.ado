program mcmcmixed, eclass

  /* version 1.0, 5 jan 2012 */
  /* sam schulhofer-wohl, federal reserve bank of minneapolis */

  version 12.0

  local mycmdline `0'

  _parse expand cmd op : 0, common(saving(string asis) iterate(integer) seed(integer) replace d0(real) delta0(real) nolog)
  /* allows fw, aw in the FE equation, no weights in the RE equation */

  if `cmd_n'>2 {
    di "only one random-effects equation allowed."
    error 101
    }
  else if `cmd_n'==1 {
    *just a regression
    mcmcreg `mycmdline'
    }
  else {
    *parse the estimation options
    local 0 ", `op_op'"
    syntax, saving(string asis) d0(real) delta0(name) [iterate(integer 100) seed(integer 12345) replace nolog]
    if "`log'"=="nolog" local showiter=0
    else local showiter=1
    *confirm we have somewhere to put the results, otherwise abort now
    if "`replace'"=="" capture confirm new file `saving'
    else capture save `saving', `replace'
    if _rc error _rc

    *parse the fixed-effects equation
    local 0 "`cmd_1'"
    syntax varlist(numeric) [if] [in] [fw aw] [, noconstant]
    marksample touse
    unab vars : `varlist'
    gettoken y x : vars
    local weightfe "`weight'"
    local expfe "`exp'"
    local constantfe "`constant'"
    if "`weightfe'"~="" {
      tempvar wfe
      qui gen double `wfe' `expfe'
      local usewfe=1
      }
    else {
      local wfe ""
      local usewfe=0
      }
    if "`weightfe'"=="aweight" local awfe=1
    else local awfe=0
    if "`constantfe'"=="noconstant" local cfe=0
    else local cfe=1
    *make sure we have either a rhs variable or a constant in the fixed-effects equation
    local nx : word count `x'
    if `nx'==0 & `cfe'==0 {
      di "fixed-effects equation must specify at least one independent variable or include a constant."
      error 101
      }

    *parse the random-effects equation
    if strpos("`cmd_2'",":")==0 error 101
    gettoken levelorig 0 : cmd_2, parse(":")
    gettoken junk 0 : 0, parse(": ")
    local varlist ""
    local constant ""
    syntax [varlist(numeric default=none)] [, noconstant]
    if subinstr("`varlist'"," ","",.)~="" unab z : `varlist'
    else local z ""
    markout `touse' `levelorig' `z', strok
    local constantre "`constant'"
    if "`constantre'"=="noconstant" local cre=0
    else local cre=1
    *make sure we have either a rhs variable or a constant in the random-effects equation
    local nz : word count `z'
    if `nz'==0 & `cre'==0 {
      di "random-effects equation must specify at least one independent variable or include a constant."
      error 101
      }

    *store the original data
    tempfile temp
    qui save `temp', replace
  
    *keep only the data we want
    qui keep if `touse'

    *remove collinear variables
    _rmcoll `x', `constantfe' forcedrop
    local x `r(varlist)'
    local nx : word count `x'
    if `nx'>0 local usex 1
    else local usex 0
    _rmcoll `z', `constantre' forcedrop
    local z `r(varlist)'
    local nz : word count `z'
    if `nz'>0 local usez 1
    else local usez 0

    *identify and sort the groups
    tempvar levelvar
    egen double `levelvar'=group(`levelorig')
    sort `levelvar'
    qui sum `levelvar', meanonly
    local ng=r(max)

    *get number of observations
    local N=_N
    
    *parse delta0
    tempname mydelta0
    capture confirm matrix `delta0'
    if !_rc {
      if rowsof(`delta0')==`nz'+`cre' & colsof(`delta0')==`nz'+`cre' {
        tempname delta0sym delta0posdef
        mata: st_numscalar("`delta0sym'",issymmetric(st_matrix("`delta0'")))
        if `delta0sym' {
          mata: st_numscalar("`delta0posdef'",min(symeigenvalues(st_matrix("`delta0'"))))
          if `delta0posdef'>0 & `delta0posdef'<.  matrix `mydelta0'=`delta0'
          else delta0err
          }
        else delta0err
        }
      else if ((rowsof(`delta0')==`nz'+`cre' & colsof(`delta0')==1) | (rowsof(`delta0')==1 & colsof(`delta0')==`nz'+`cre')) {
        tempname delta0minmax
        mata: st_matrix("`delta0minmax'",minmax(st_matrix("`delta0'"),1))
        if `delta0minmax'[1,1]>0 & `delta0minmax'[1,2]<. matrix `mydelta0'=diag(`delta0')
        else delta0err
        }
      else if rowsof(`delta0')==1 & colsof(`delta0')==1 & `delta0'[1,1]>0 & `delta0'[1,1]<. matrix `mydelta0'=`delta0'*I(`nz'+`cre')
      else delta0err
      }
    else {
      capture confirm scalar `delta0'
      if !_rc {
        if `delta0'>0 & `delta0'<. matrix `mydelta0'=`delta0'*I(`nz'+`cre')
        else delta0err
        }
      else delta0err
      }
    
    *estimate
    tempname Sigmarows Sigmacols
    mata: mcmclinear_mixed("`y'","`x'","`z'","`levelvar'",`iterate',`seed',`d0',"`mydelta0'",`cfe',`cre',"`wfe'",`usewfe',`awfe',`showiter',`ng',"`Sigmarows'","`Sigmacols'",`usex',`usez')

    *name the returned estimation results and calculate b and V matrices
    qui gen double iter=_n-1
    if `nx'>0 {
      forvalues i=1/`nx' {
        local j : word `i' of `x'
        local k : permname beta_`j'
        rename beta`i' `k'
        }
      }
    if `cfe'==1 {
      local i=`nx'+1
      rename beta`i' beta__cons
      }
    forvalues g=1/`ng' {
      if `nz'>0 {
        forvalues i=1/`nz' {
          local j : word `i' of `z'
          local k : permname theta`g'_`j'
          local l=(`g'-1)*(`nz'+`cre')+`i'
          rename theta`l' `k'
          }
        }
      if `cre'==1 {
        local l=(`g'-1)*(`nz'+`cre')+`nz'+1
        rename theta`l' theta`g'__cons
        }
      }
    local nsigma=(`nz'+`cre')*(`nz'+`cre'+1)/2
    forvalues j=1/`nsigma' {
      local r=`Sigmarows'[`j',1]
      local c=`Sigmacols'[`j',1]
      rename Sigma`j' Sigma_`r'_`c'
      }
    order iter

    *save
    qui compress
    qui save `saving', `replace'

    *restore original data
    qui use `temp', clear

    *return
    ereturn post [`weightfe' `expfe'], depname(`y') esample(`touse') obs(`N')
    ereturn local cmd "mcmcmixed"
    ereturn local cmdline mcmcmixed `mycmdline'
    }

end

program delta0err
  di "delta0 must be a positive scalar, an Nz-by-1 or 1-by-Nz vector of positive numbers, or a symmetric Nz-by-Nz positive definite matrix."
  error 101 
end


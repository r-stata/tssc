*! rii Version 1.0.2 bzelner@duke.edu & dan.blanchette@duke.edu  07Aug2009
*! Duke University's Fuqua School of Business
program intgph 
version 9.2

local cmd : word 1 of `0'
local 0 : subinstr local 0 "`cmd'" ""
//unabreviate command
unabcmd `cmd'
local cmd "`r(cmd)'"
if ! inlist("`cmd'","probit","logit","poisson","nbreg") {
  display as error "{helpb intgph} can only be run with {helpb logit}, {helpb probit}, {helpb poisson}, or {helpb nbreg}"
  exit 499
}

syntax varlist(numeric) [if] [in] [fweight pweight iweight],  ivars(varlist numeric min=2) ///  
                      [ setx(string) MODdata xinc(integer 100) XTitle(string) YTitle(string) genname(string) verbose ///
                        cmdopts(string) Level(integer 95) sims(integer 1000)  difvals(string) SLOPETest(string) ///
                        gphsym gphdif Gphopts(string) ] 

capture which estsimp
if _rc != 0 {
  display as error "need to install Clarify to run intgph"
  display as text "{stata finit clarify estsimp : findit clarify estsimp}"
  exit 499
}

if !missing(`"`weight'"') {
  local weight `"[`weight'`exp']"'
}

if !missing(`"`cmdopts'"') {
  local comma : word 1 of `cmdopts'
  if `"`comma'"' == "," {
    local cmdopts : subinstr local cmdopts "," ""  
  }
}

local setx_set = 1
if missing(`"`setx'"') {
  local setx_set = 0
  local setx = "mean"
}
if !missing(`"`level'"') {
  if !inrange(`level',1,99) {
    display as error "{cmd:level(`level')} has to between 1 and 99"
    exit 198
  }
}

if `xinc' < 0  {
  display as error "{cmd: xinc()} must be a positive integer"
  exit 198
}

//make sure varlist is a unique varlist
quietly ds *
local varlist_orig `r(varlist)'
local invlist : list dups varlist
if !missing("`invlist'") {
  local varlist : list uniq varlist
}

local invlist : list dups ivars
if !missing("`invlist'") {
  display as error "need to specify two different ivars" 
  exit 198
}


local varlist2 `varlist' `ivars'
local invlist : list dups varlist2
if !missing("`invlist'") {
  display as error "ivars: `ivars'  cannot be in the submitted variable list"
  exit 198
}

if !missing(`"`difvals'"') {
  local ndifvals : word count `difvals'
  if `ndifvals' > 2 {
    display as error "only two values can be specified in {cmd:difvals()}"
    exit 198
  }
  else if `ndifvals' == 1 {
    display as error "two values have to be specified in {cmd:difvals()}"
    exit 198
  }
  local mdifval_lo : word 1 of `difvals'
  local mdifval_up : word 2 of `difvals'
  capture confirm number `mdifval_lo'
  local lo_not = _rc
  capture confirm number `mdifval_up'
  local up_not = _rc
  if `lo_not' | `up_not' {
    display as error "both values specified in {cmd:difvals()} have to be numeric"
    exit 198
  }
  tempvar difval_lo difval_up
  scalar `difval_lo' = `mdifval_lo'
  scalar `difval_up' = `mdifval_up'
  if `difval_lo' == `difval_up' {
    display as error "values specified in {cmd:difvals()} have to different values"
    exit 198
  }
  if `difval_lo' > `difval_up' {
    tempvar templo
    scalar `templo' = `difval_lo'
    scalar `difval_lo' = `difval_up'
    scalar `difval_up' = `difval_lo'
  }  
}

if missing("`moddata'") {
   preserve 
}

local nvars "X Y0 Y1 Y0lb Y1lb Y0ub Y1ub dY dYlb dYub" 
quietly ds * 
local allvars `r(varlist)'
local dupnewvars "`allvars' `nvars'"
local notnew : list dups dupnewvars
local nnotnew : word count `notnew'
if `nnotnew' > 1 {
  local s = "s"
}
if (!missing("`notnew'")) {
  display as error "{helpb intgph} generates variables `nvars'" 
  display as error "and your dataset already has variable`s' `notnew'" 
  display as error "either drop or rename before running {helpb intgph}" 
  exit 198
}

if !missing("`newvar'") {
  local genname  genname(`newvar')
}


local dummy0
local dummy1
local continuous0
local continuous1
local c = 0
foreach ivar of local ivars {
  quietly summarize `ivar' , detail
  if inlist(r(p50),0,1) & inlist(r(min),0,1) & inlist(r(max),0,1) {  // dummy
    local dummy`c' `ivar'
  }
  else {  // continuous
    local continuous`c' `ivar'
  }
  local c = `c' + 1
}

if !missing("`dummy0'") & missing("`dummy1'") {
  display as error "`dummy0' must be continuous and `continuous1' can be continuous or binary" 
  exit 198
}
else if !missing("`dummy0'") & !missing("`dummy1'") {
  display as error "`dummy0' must be continuous and `dummy1' can be continuous or binary" 
  exit 198
}
else if missing("`dummy0'") & !missing("`dummy1'") {
  local ivar0 `continuous0'
  local ivar1 `dummy1'
}
else {
  local ivar0 `continuous0'
  local ivar1 `continuous1'
}

// check that ivars are not in setx 
if `setx_set' == 1 {
  local sp_setx `" `setx' "'  // add a space before and after setx
  local len_setx : length local sp_setx
  forvalues n = 0/1 {
    local sp_setx : subinstr local sp_setx " `ivar`n'' " "", all
    local len_tsetx : length local sp_setx
    if `len_tsetx' < `len_setx' {
      display as error "ivars are not allowed to be specified in the setx() option"
      exit 198
    }
  }
}

if strlen("`ivar0'") < 15 {
  local pre_int = "`ivar0'"
}
else {
  local pre_int = substr("`ivar0'",1,15)
}
if strlen("`ivar1'") < 15 {
  local post_int = "`ivar1'"
}
else {
  local post_int = substr("`ivar1'",1,15)
}

local ivar0Xivar1 = "`pre_int'X`post_int'"
capture confirm new variable `pre_int'X`post_int'
if _rc != 0 {
  display as error "`ivar0Xivar1' needs to be generated by {helpb intgph} either drop it or rename it"
  exit 198
}


quietly generate `ivar0Xivar1' = `ivar0' * `ivar1'
local varlist `varlist' `ivars' `ivar0Xivar1'

set seed 9999
capture `cmd' `varlist' `if' `in' `weight' , `cmdopts'
if _rc == 0 {
  // regenerate the varlist in case not all vars are used in model
  tempname cmat
  matrix `cmat' = e(b)
  local evlist : colnames `cmat'
  local evlist " `evlist' "
  local varlist : subinstr local evlist " _cons " ""  // drop _cons
  local varlist `e(depvar)' `varlist'
  local depvar `e(depvar)'

  // test if ivars and ivar0Xivar1 still in varlist, need to have var names surrounded by spaces
  local ivarsx `" `ivars' `ivar0Xivar1' "'
  local varlist2 `varlist' `ivarsx'
  local invlist : list dups varlist2
  if missing("`invlist'") {
    display as error "`ivarsx' have been dropped by `cmd'"
    exit 499
  }
  else {
    local both : word count `invlist'
    if `both' == 1 {
      local notin : subinstr local ivarsx " `invlist' " ""
      display as error "`notin' have been dropped by `cmd'"
      if strpos("`notin'","`ivar0Xivar1'") {
        display as error "`ivar0Xivar1' is the product of the interaction vars"
      }
      exit 499
    }
    if `both' == 2 {
      local notin : subinstr local ivarsx " `invlist' " ""
      display as error "`notin' has been dropped by `cmd'"
      if strpos("`notin'","`ivar0Xivar1'") {
        display as error "`ivar0Xivar1' is the product of the interaction vars"
      }
      exit 499
    }
  }

  matrix drop `cmat'
  tempvar esample
  generate `esample' =  e(sample)
  display as text _n `"estsimp `cmd' `varlist' `if' `in' `weight' , sims(`sims') `genname' `cmdopts' "'
  display as text    `"`ivar0Xivar1' is the product of the interaction vars"'
                       estsimp `cmd' `varlist' `if' `in' `weight' , sims(`sims') `genname' `cmdopts'
}
else {
  // let estsimp provide the error message
  display as text _n `"estsimp `cmd' `varlist' `if' `in' `weight', sims(`sims') `genname' `cmdopts' "'
                       estsimp `cmd' `varlist' `if' `in' `weight', sims(`sims') `genname' `cmdopts' 
}



quietly {
  foreach var of newlist X Y0 Y1 Y0lb Y1lb Y0ub Y1ub dY dYlb dYub  {
    generate `var' = .
  }

  if missing("`gphdif'") {
    if inlist("`cmd'","probit","logit") {
      label variable dY   "Difference in predicted probabilities"
      if missing(`"`ytitle'"') {
        local ytitle "Change in Pr(`depvar'=1)" 
      }
    }
    else if inlist("`cmd'","poisson","nbreg") {
      label variable dY   "Difference in predicted incidence"
      if missing(`"`ytitle'"') {
        local ytitle "Change in E(`depvar')"
      }
    }
  }
  else if !missing("`gphdif'") {
    if inlist("`cmd'","probit","logit") {
      label variable dY   "Difference in predicted probabilities"
      if missing(`"`ytitle'"') {
        local ytitle "Pr(`depvar'=1)"
      }
    }
    else if inlist("`cmd'","poisson","nbreg") {
      label variable dY   "Difference in predicted incidence"
      if missing(`"`ytitle'"') {
        local ytitle "E(`depvar')"
      }
    }
  }


  label variable dYlb "Lower bound of `level'% confidence interval for dY"
  label variable dYub "Upper bound of `level'% confidence interval for dY"

  if missing(`"`xtitle'"') {
    local xtitle "`ivar0'"
  }

  tempvar ivar0_mean ivar0_sd ivar0_min ivar0_max ivar1_mean ivar1_sd ivar1_min ivar1_max  
  local c = 0
  foreach ivar of local ivars {
    summarize `ivar'  if `esample' == 1, detail
    if "`continuous`c''" == "`ivar'" {
      scalar `ivar`c'_mean' = `r(mean)'
      scalar `ivar`c'_sd' = `r(sd)'
      scalar `ivar`c'_min' = `r(min)'
      scalar `ivar`c'_max' = `r(max)'
    }
    else {
      scalar `ivar`c'_min' = 0
      scalar `ivar`c'_max' = 1
    }
    local c = `c' + 1
  }

  tempvar lev0 lev1

  if !missing(`"`difvals'"') {
    tempvar ivar_min ivar_max
    scalar `ivar_min' = min(`ivar0_min',`ivar1_min')
    scalar `ivar_max' = max(`ivar0_max',`ivar1_max')
    if (`difval_lo' < `ivar_min') | (`difval_up' > `ivar_max') {
      display as error "both values specified in {cmd:difvals()} have to be inside the range of one of the {cmd:ivars(`vars')}"
      exit 198
    }
    if (`difval_lo' >= `ivar0_min' & `difval_up' <= `ivar0_max') & (`difval_lo' >= `ivar1_min' & `difval_up' <= `ivar1_max') { 
      scalar `lev0' = `difval_lo'
      scalar `lev1' = `difval_up'
    }
    else if (`difval_lo' >= `ivar1_min' & `difval_up' <= `ivar1_max') { 
      scalar `lev0' = `difval_lo'
      scalar `lev1' = `difval_up'
    }
    else if (`difval_lo' >= `ivar0_min' & `difval_up' <= `ivar0_max') { 
      scalar `lev0' = `difval_lo'
      scalar `lev1' = `difval_up'
      // ivars need to be switched
      local tivar = "`ivar1'"
      local ivar1 = "`ivar0'"
      local ivar0 = "`tivar'"
      local c = 0
      foreach ivar of varlist `ivar0' `ivar1' {
        summarize `ivar'  if `esample' == 1, detail
        if "`continuous`c''" == "`ivar'" {
          scalar `ivar`c'_mean' = `r(mean)'
          scalar `ivar`c'_sd' = `r(sd)'
          scalar `ivar`c'_min' = `r(min)'
          scalar `ivar`c'_max' = `r(max)'
        }
        else {
          scalar `ivar`c'_min' = 0
          scalar `ivar`c'_max' = 1
        }
        local c = `c' + 1
      }
    }
    else {
      display as error "both values specified in {cmd:difvals()} have to be inside the range of one of the {cmd:ivars(`vars')}"
      exit 198
    }
  }
  
  // if dummy var is does not contain both 0 and 1, then `cmd' will drop it
  if inlist("`ivar1'","`dummy0'","`dummy1'") {
    scalar `lev0' = 0
    scalar `lev1' = 1
    local ivar1_lo = 0
    local ivar1_up = 1
  }
  else if "`ivar1'" == "`continuous0'" {
    if missing(`"`difvals'"') {
      scalar `lev0' = `ivar0_mean'
      scalar `lev1' = `ivar0_mean' + `ivar0_sd'
    }
    local ivar1_lo = `lev0'
    local ivar1_up = `lev1'
  }
  else if "`ivar1'" == "`continuous1'" {
    if missing(`"`difvals'"') {
      scalar `lev0' = `ivar1_mean'
      scalar `lev1' = `ivar1_mean' + `ivar1_sd'
    }
    local ivar1_lo = `lev0'
    local ivar1_up = `lev1'
  }
  
  label variable Y0 "Predicted probability when `ivar1' takes value of `ivar1_lo'"
  label variable Y1 "Predicted probability when `ivar1' takes value of `ivar1_up'"


 local quietly = "quietly"
  if !missing("`verbose'") {
    local quietly = "noisily"
  }
  
  local bottom = (100 - `level')/2
  local top = 100 - `bottom' 

  label variable X    "X values for chart"
  label variable Y0lb "Lower bound of `level'% confidence interval for Y0" 
  label variable Y0ub "Upper bound of `level'% confidence interval for Y0"
  label variable Y1lb "Lower bound of `level'% confidence interval for Y1"
  label variable Y1ub "Upper bound of `level'% confidence interval for Y1"

  local nivars = 1
  foreach var of local varlist {
    if `nivars' > 1 {  // first var is left-hand var
      summarize `var'  if `esample' == 1, detail
      if r(min) == 0 & r(max) == 1 & r(mean) > .5 {
        local setx_d = 1
      }
      else if r(min) == 0 & r(max) == 1 & r(mean) <= .5 {
        local setx_d = 0
      }
      else if r(min) == 0 & r(max) == 0 {
        local setx_d = 0
      }
      else if r(min) == 1 & r(max) == 1 {
        local setx_d = 1
      }
      else {
        local setx_d = "mean"
      }
      `quietly' display as text _n `"setx `var' `setx_d'"'
                                     setx `var' `setx_d' 
      setx `setx_d'
    }
    local nivars = `nivars' + 1
  }

  if `setx_set' == 1 {
    setx `setx'
  }

  forvalues obs = 1(1)`xinc' {
    replace X = `ivar0_min' + (`obs' - 1) * (`ivar0_max' - `ivar0_min') / (`xinc' - 1) in `obs'

    `quietly' display as text _n `"setx `ivar0' `= X[`obs']'"'
                                   setx `ivar0' `= X[`obs']'
  
    foreach lev of numlist 0 1 { 
      `quietly' display as text _n `"setx `ivar1' `=`lev`lev''' `ivar0Xivar1' `=`lev`lev'''*`= X[`obs']'"'
      `quietly' display as text    `"`ivar0Xivar1' is the product of the interaction vars"'
                                     setx `ivar1' `=`lev`lev''' `ivar0Xivar1' `=`lev`lev'''*`= X[`obs']'
      tempvar Y`lev'_tmp 
      if inlist("`cmd'","probit","logit") {
        local simqi_opts  genpr(`Y`lev'_tmp') prval(1)
      }
      if inlist("`cmd'","poisson","nbreg") {
        local simqi_opts  genev(`Y`lev'_tmp') 
      }
      `quietly' display as text _n `"simqi, `simqi_opts' "'
      `quietly' display as text    `"`Y`lev'_tmp' is a tempvar "'
                                     simqi, `simqi_opts'
      summarize `Y`lev'_tmp', meanonly
      replace Y`lev' = r(mean) in `obs' 
      _pctile `Y`lev'_tmp', p(`bottom', `top')
      replace Y`lev'lb =  r(r1) in `obs'
      replace Y`lev'ub = r(r2) in `obs'
    } 	  	  	  	  	  	  	  	  	 
    tempvar dY_tmp
    generate `dY_tmp' = `Y1_tmp' - `Y0_tmp'
    summarize `dY_tmp', meanonly
    replace dY = r(mean) in `obs'
    _pctile `dY_tmp', p(`bottom',`top')
    replace dYlb = r(r1) in `obs'
    replace dYub = r(r2) in `obs'
    drop `Y0_tmp' `Y1_tmp' `dY_tmp'
  } 	  	  	  	  	  	  	  	  	  	 
} // end of quietly


if missing("`gphsym'") & missing("`gphdif'") {
  display as text `"twoway rbar dYub dYlb X, mw msize(1) lcolor(gs0) fcolor(gs16) || line dY X, color(gs0) || "' _c 
  display as text `", legend(off) xtitle("`xtitle'") ytitle("`ytitle'") graphregion(fcolor(gs16)) `gphopts' "'
                    twoway rbar dYub dYlb X, mw msize(1) lcolor(gs0) fcolor(gs16) || line dY X, color(gs0) ||  ///
                    , legend(off) xtitle("`xtitle'") ytitle("`ytitle'") graphregion(fcolor(gs16)) `gphopts' 
}
else if !missing("`gphsym'") & missing("`gphdif'") {
  tempvar dYsig 
  generate `dYsig' = dY  if sign(dYlb) == sign(dYub) & sign(dYlb) != 0
  display as text `"twoway scatter `dYsig' X, m(O) msize(medsmall) mc(black) || line dY X, color(gs0) || "' _c 
  display as text `", legend(off) xtitle("`xtitle'") ytitle("`ytitle'") graphregion(fcolor(gs16)) `gphopts' "'
                    twoway scatter `dYsig' X, m(O) msize(medsmall) mc(black) || line dY X, color(gs0) ||  ///
                    , legend(off) xtitle("`xtitle'") ytitle("`ytitle'") graphregion(fcolor(gs16)) `gphopts'
  drop `dYsig'
}
else if missing("`gphsym'") & !missing("`gphdif'") {
  display as text `"twoway rbar Y0ub Y0lb X, mw msize(1) lcolor(gs0) fcolor(gs16) || line Y0 X, color(gs0) lp(solid) ||  "' _c 
  display as text `"  rspike Y1ub Y1lb X, lcolor(gs0) lp(dot) || line Y1 X, color(gs0) lp(dash) || ,  ///"' _c 
  display as text `"  leg(order(2 - " " 4)) xtitle("`xtitle'") ytitle("`ytitle'") graphregion(fcolor(gs16)) `gphopts' "'
                    twoway rbar Y0ub Y0lb X, mw msize(1) lcolor(gs0) fcolor(gs16) || line Y0 X, color(gs0) lp(solid) ||  ///
                      rspike Y1ub Y1lb X, lcolor(gs0) lp(dot) || line Y1 X, color(gs0) lp(dash) || , ///
                      leg(order(2 - " " 4)) xtitle("`xtitle'") ytitle("`ytitle'") graphregion(fcolor(gs16)) `gphopts'

}
else if !missing("`gphsym'") & !missing("`gphdif'") {
  tempvar Y0sig Y1sig 
  generate `Y0sig' = Y0  if sign(Y0lb) == sign(Y0ub) & sign(Y0lb) != 0
  generate `Y1sig' = Y1  if sign(Y1lb) == sign(Y1ub) & sign(Y1lb) != 0
  display as text `"twoway scatter `Y0sig' X, m(O) msiz(medsmall) mc(black) || line Y0 X, color(gs0) lp(solid) ||  ///"'  _c
  display as text `"  scatter `Y1sig' X, m(O) msiz(medsmall) mc(black) || line Y1 X, color(gs0) lp(dash) || , "'  _c
  display as text `"  leg(order(2 - " " 4)) xtitle("`xtitle'") ytitle("`ytitle'") graphregion(fcolor(gs16)) `gphopts' "'  
                    twoway scatter `Y0sig' X, m(O) msiz(medsmall) mc(black) || line Y0 X, color(gs0) lp(solid) ||  ///
                      scatter `Y1sig' X, m(O) msiz(medsmall) mc(black) || line Y1 X, color(gs0) lp(dash) || , ///
                      leg(order(2 - " " 4)) xtitle("`xtitle'") ytitle("`ytitle'") graphregion(fcolor(gs16)) `gphopts'
  drop `Y0sig' `Y1sig'
}



if !missing(`"`slopetest'"') { 
  quietly { 

    // let confirm provide error message and exit
    confirm new variable y1_tmp y0_tmp


    local nvals: word count `slopetest'
    if mod(`nvals',2) != 0 {
      display as error "you have submitted: {opt slopetest(`slopetest')} "
      display as error " there needs to be an even number of values"
      exit 198
    }

    local npairs = 0
    forvalues n = 1/`nvals' {
      if mod(`n',2) == 0 {
        local npairs = `npairs' + 1 
      }
    }

    summarize X , detail
    tempvar minX maxX
    scalar `minX' = r(min)
    scalar `maxX' = r(max)

    local np = 0
    forvalues n = 1/`npairs' {
      local np = `np' + `n'
      local val1 : word `np' of `slopetest'
      local np = `np'+1
      local val2 : word `np' of `slopetest'
      if !inrange(`val1',`minX',`maxX') | !inrange(`val2',`minX',`maxX')  {
         display as error "{cmd:slopetest} values `slopetest' are not within the range of X: "
         display as error " min: `=`minX'' and max: `=`maxX''"
         exit 198
      }
      local pair "`val1' `val2'"
      
      tempvar ydif1 ydif0
      local valnum = 0
      foreach unc_lev in `val1' `val2' {
        `quietly' display as text _n `"setx `ivar0' `unc_lev'"'
                                       setx `ivar0' `unc_lev'

        foreach lev of numlist 0 1 {
          `quietly' display as text _n `"setx `ivar1' `=`lev`lev''' `ivar0Xivar1' `unc_lev'*`=`lev`lev'''"'
          `quietly' display as text    `"`ivar0Xivar1' is the product of the interaction vars"'
                                         setx `ivar1' `=`lev`lev''' `ivar0Xivar1' `unc_lev'*`=`lev`lev'''

          `quietly' display as text _n `"simqi, genpr(y`lev'_tmp) prval(1)"'
                                         simqi, genpr(y`lev'_tmp) prval(1)
        }
        generate `ydif`valnum'' = y1_tmp - y0_tmp
        local valnum = `valnum' + 1
        drop  y1_tmp y0_tmp   
      }
    
      generate ddY`n' = `ydif1' - `ydif0'  
      drop `ydif1' `ydif0'
      summarize ddY`n', meanonly

      local b1 = 100 - `level' 
      local t1 = 99
      if r(mean) < 0 {
        local b1 = 1 
        local t1 = `level'
      }
      local pb1 = min(`bottom',`b1')
      local pb2 = max(`bottom',`b1')
      local pt1 = min(`top',`t1')
      local pt2 = max(`top',`t1')
      noisily display "Double difference for values (`pair') of `ivar0' = `r(mean)'"
      if r(mean) != 0 {
        _pctile ddY`n', p(`pb1',`pb2',`pt1',`pt2') 
        noisily display "95% two-tailed CI: `r(r1)', `r(r3)'"
        noisily display "95% one-tailed CI: `r(r2)', `r(r4)'"
      }
    }
  }
}

drop `esample' `ivar0Xivar1'

if missing("`moddata'") {
   restore
}
else {
  display as result _n "the following variables have been generated:"
  quietly ds *
  local newvarlist 
  foreach var of varlist _all {
    local var_in : list posof "`var'" in varlist_orig
    if `var_in' == 0 {
      local newvarlist `newvarlist' `var'
    }

  } 
  describe `newvarlist', fullnames
}


end

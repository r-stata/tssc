*! version 2.2.2  20july2018

program define scores, byable(onecall) sortpreserve
  version 9.2
  gettoken newv 0 : 0, parse("=")
  local newv = trim("`newv'")
  gettoken opt 0 : 0, parse("(")
  local opt = trim(subinstr("`opt'","=","",1))
  gettoken vars 0 : 0, match(parns)
  local 0 = "`vars' `0'"
  syntax varlist(numeric) [if] [in] [fweight aweight iweight] [, minvalid(integer 1) nv(integer 1) SCore(name) MINval(integer 0) MAXval(integer 0) P(real 50) ENDshift(real 0) Center(real 0.5) Auto replace]
  marksample touse, nov
  if `nv' != 1 {
    local minvalid = `nv'
  }
  if ("`score'"=="c") {
    local score = "centered"
  }
  if ("`score'"=="p" | "`score'"=="po") {
    local score = "pomp"
  }
  if ("`score'"=="pp") {
    local score = "prop"
  }
  if ("`score'"=="sp") {
    local score = "sprop"
  }
  if ("`opt'"=="tot") {
    local opt = "total"
  }
  if ("`opt'"=="med") {
    local opt = "median"
  }
  if ("`opt'"=="median") {
    if c(stata_version) < 11.2 {
      di as error "Median scores require at least Stata version 11.2, current version is `c(stata_version)'"
      di "-scores- not executed"
      exit 498
    }
    else {
      version 11.2
    }
  }
  if ("`opt'"=="pct") {
    local opt = "pctile"
  }
  if ("`opt'"=="pctile") {
    if c(stata_version) < 11.2 {
      di as error "Percentile scores require at least Stata version 11.2, current version is `c(stata_version)'"
      di "-scores- not executed"
      exit 498
    }
    else {
      version 11.2
    }
  }
  if ("`varlist'")==("`newv'") {
    tempvar nv
	qui gen `nv' = `varlist'
	local varlist = "`nv'"
  }
  if subinword("`varlist'","`newv'"," ",.) != "`varlist'" {
    display as error "{hi:newvar (`newv')} may not be an element of {hi:varlist (`varlist')}"
    display "-scores- not executed"
    exit 498
  }
  tempvar nvalid tmpscore m_stat gr grcons
  if inlist("`opt'","min","max","total","mean","median","pctile","sd")==0 {
    display as error "{hi:={it:function}(varlist)} must specify one of {hi:min}, {hi:max}, {hi:total}, {hi:mean}," _n "{hi:median}, {hi:pctile}, or {hi:sd} as {it:function}"
    display "-scores- not executed"
    exit 498
  }
  if inlist("`score'","z_2","z","centered","sd2","pomp","prop","sprop") & "`opt'"!="mean" {
    display as error "{hi:score(`score')} is a valid option only if {hi:{it:function}(varlist)} = {hi:{it:mean}}"
    display "-scores- not executed"
    exit 498
  }
  local egenopt = ""
  if "`opt'"=="pctile" {
    if float(`p') <= 0 | float(`p') >= 100 {
      display as error "To specify the {hi:#th} percentile a value of the open interval {hi:]0,100[} must be used"
      display "-scores- not executed
      exit 498
    }
    local egenopt = ", p(`p')"
  }
  if "`score'"=="prop" {
    if float(`endshift') < 0 | float(`endshift') >= .5 {
      display as error "To shift the endpoints of the proportion [0,1]" _n "{hi:endshift} must be a value of the half open interval {hi:[0,0.5[}"
      display "-scores- not executed
      exit 498
    }
  }
  if "`score'"=="sprop" {
    if float(`center') < 0 | float(`center') > 1 {
      display as error "The {hi:center} of a shrunken proportion must be a value of the closed interval {hi:[0,1]}"
      display "-scores- not executed
      exit 498
    }
  }
  if inlist("`score'","","z_2","z","centered","sd2","pomp","prop","sprop")==0 {
    display as error "{hi:`score'} is an invalid argument of option {hi:score()}"
    display "-scores- not executed"
    exit 498
  }
  if (`minvalid' < 1) {
    display as error "value specified in {hi:minvalid({it:#})} may not be less than 1"
    display "-scores- not executed"
    exit 498
  }
  local k: word count `varlist'
  if (`minvalid' > `k') {
    display as error "value specified in {hi:minvalid({it:#})} may not be greater than"
    display as error "the number of variables specified in {hi:={it:function}(varlist)} (=`k')"
    display "-scores- not executed"
    exit 498
  }
  if inlist("`score'","pomp","prop","sprop") {
    if "`auto'"=="auto" {
      foreach vname of varlist `varlist' {
        local vlab: value label `vname'
        if "`vlab'"=="" {
          di as error "Option {hi:auto} requires value labels of all variables of {hi:varlist}."
          di as error "{hi:`vname'} has no value labels."
          di "-scores- not executed"
          exit 498
        }
        qui label list `vlab'
        local firstv: word 1 of `varlist'
        if "`firstv'"=="`vname'" {
          local minval = `r(min)'
          local maxval = `r(max)'
        }
        else {
          if `minval' != `r(min)' | `maxval' != `r(max)' {
            di as error "The range of labeled values of {hi:`vname'} differs from the range of labeled values of {hi:`firstv'}."
            di "-scores- not executed"
            exit 498
          }
        }
      }
    }
    if (`minval'>=`maxval') {
      display as error "{hi:minval({it:#})} and {hi:maxval({it:#})} options should allow {hi:minval} to be less than {hi:maxval}"
      display "-scores- not executed"
      exit 498
    }
  }
  if "`replace'"=="" {
    capture confirm new var `newv'
    if _rc > 0 {
      di as error "variable {bf:`newv'} already defined
	  exit 110
    }
	else qui gen `newv' = .
  }
  else {
    capture confirm new var `newv'
	if _rc==0 qui gen `newv' = .
  }
  if inlist("`score'","z_2","z","centered","sd2","sprop") {  // prefix by: or weights are relevant
    if "`_byvars'"=="" {
      qui gen int `grcons' = 1
      local _byvars = "`grcons'"
    }
    qui egen `gr' = group(`_byvars'), missing
    qui replace `gr' = . if !`touse'
    qui levelsof `gr', local(K)
    qui replace `newv' = .
    foreach k of local K {
      cap drop `nvalid'
      cap drop `tmpscore'
      qui egen `nvalid'=rownonmiss(`varlist') if `touse' & `gr'==`k'
      qui egen double `tmpscore' = row`opt'(`varlist') if `touse' & `gr'==`k' `egenopt'
      qui replace `tmpscore' = cond(`nvalid'>=`minvalid',`tmpscore', .)
      if "`score'" != "" {
        qui sum `tmpscore' if `touse' & `gr'==`k' [`weight' `exp']
        if r(sum_w) > 0 {
          if "`score'"=="z" | "`score'"=="z_2" {
            qui replace `tmpscore' = (`tmpscore'-r(mean))/r(sd)
			if "`score'"=="z_2" qui replace `tmpscore' = `tmpscore'/2
            if r(sd)==0 {
              if "`_byvars'" == "`grcons'" {
                di "Warning: Standard deviation of {hi:`tmpscore'} = 0,"
              }
              else {
                di "Warning: Standard deviation of {hi:`tmpscore'} in group {hi:`k'} = 0,"
              }
			  if "`score'"=="z_2" di "z_2-scores of {hi:`tmpscore'} have been set to missing for all cases."
              else di "z-scores of {hi:`tmpscore'} have been set to missing for all cases."
            }
          }
          else if "`score'"=="centered" {
            qui replace `tmpscore' = (`tmpscore'-r(mean))
          }
          else if "`score'"=="sd2" {
            qui replace `tmpscore' = (`tmpscore'/(2*r(sd)))
          }
          else if "`score'"=="sprop" {
            qui replace `tmpscore' = (`tmpscore'-`minval')/(`maxval'-`minval')
            qui replace `tmpscore' = (`tmpscore'*(r(sum_w)-1)+`center')/r(sum_w)
            cap drop `m_stat'
            qui egen `m_stat' = rowmin(`varlist') if `touse' & `gr'==`k'
            qui sum `m_stat' if `touse' & `gr'==`k' [`weight' `exp']
            drop `m_stat'
            if r(min)<`minval' {
              di "Warning: Value(s) of {hi:{it:varlist}} less than {hi:minval(`minval')}."
            }
            qui egen `m_stat' = rowmax(`varlist') if `touse' & `gr'==`k'
            qui sum `m_stat' if `touse' & `gr'==`k' [`weight' `exp']
            if r(max)>`maxval' {
              di "Warning: Value(s) of {hi:{it:varlist}} greater than {hi:maxval(`maxval')}."
            }
          }
        }
      }
      qui replace `newv' = `tmpscore' if `tmpscore' < .
    }
  }
  else {   //  prefix by: or weights are not relevant
    qui egen `nvalid'=rownonmiss(`varlist') if `touse'
    qui egen double `tmpscore' = row`opt'(`varlist') if `touse' `egenopt'
    qui replace `tmpscore' = cond(`nvalid'>=`minvalid',`tmpscore', .)
    if "`score'" != "" {
      qui sum `tmpscore' if `touse'
      if r(N) > 0 {
        if inlist("`score'","pomp","prop") {
          qui replace `tmpscore' = (`tmpscore'-`minval')/(`maxval'-`minval')
          qui if "`score'"=="pomp" replace `tmpscore' = 100*`tmpscore'
          if "`score'"=="prop" & float(`endshift') > 0 {
            qui replace `tmpscore' = `tmpscore' + `endshift' if float(`tmpscore')==0
            qui replace `tmpscore' = `tmpscore' - `endshift' if float(`tmpscore')==1
          }
          qui egen `m_stat' = rowmin(`varlist') if `touse'
          qui sum `m_stat' if `touse'
          drop `m_stat'
          if r(min)<`minval' {
            di "Warning: Value(s) of {hi:{it:varlist}} less than {hi:minval(`minval')}."
          }
          qui egen `m_stat' = rowmax(`varlist') if `touse'
          qui sum `m_stat' if `touse'
          if r(max)>`maxval' {
            di "Warning: Value(s) of {hi:{it:varlist}} greater than {hi:maxval(`maxval')}."
          }
        }
      }
    }
    qui replace `newv' = `tmpscore'
  }
  qui sum `newv' if `touse' [`weight' `exp']  //  to create returns of -summarize- of the scores created
end

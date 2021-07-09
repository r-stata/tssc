pr de evhistplot
* Plot of events in an observation window
*! 0.1 HS, Apr 10, 2008
*! 0.2 HS, July 2, 2008  Handles one event date variable + local variable names

version 9.0
syntax varlist [if] [in], id(string) start(string) end(string) [evtype(varname) nsub(integer 0) birth(varname) agescale(real 365.25) Msymbol(string) MSIZe(string) *]
qui {

  preserve
  tempvar evdate obstype
  if "`if' `in'" ~= " " {
    keep `if' `in'
  }
  tokenize `varlist'
  local i = 0
  while "`*'" ~= "" {
    local i = `i' + 1
    local x`i' `1'
    macro shift
  }
  if strpos(`"`id'"', ",") == 0 {
    confirm variable `id'
  }
  else {
    tokenize `"`id'"', parse(",")
    local id `1'
    local plot `3'
    local plot = trim("`plot'")
    if "`plot'" ~= "plot" {
      di in red "The option `plot' is not allowed"
      exit
    }
  }

  * Evtype NOT specified
  if "`evtype'" == "" {
    local case = 0
  }
  * One event variable with evtype specified
  if "`evtype'" ~= "" & `i' == 1 {
    local case = 1
  }
  * Two or more event variables with evtype specified
  if "`evtype'" ~= "" & `i' > 1 {
    local case = 2
  }

  if `case' == 2 {
    levelsof `evtype', local(evtp)
    local i = 1
    foreach j of local evtp {
      local i = `i' + 1
      capture drop x`i'
      tempvar x`i'
      gen `x`i'' = `x1' if `evtype' == `j'
      local evlab : label (`evtype') `j'
      la var `x`i'' "`evlab'"
    }

    local var1ind = 1
    tokenize `varlist'
    while "`*'" ~= "" {
      if `var1ind' == 0 {
        local i = `i' + 1
        local x`i' `1'
      }
      local var1ind = 0
      macro shift
    }

    drop `x1'
    local i = `i' - 1
    forv k = 1/`i' {
      local kp1 = `k' + 1
      local x`k' `x`kp1''
    }
  }

  local nvars = `i'

  forv i = 1/`nvars' {
    replace `x`i'' = . if (`x`i'' < d(`start') | `x`i'' > d(`end'))
  }

  tempvar idtag rndid1 rndid
  
  egen `idtag' = tag(`id')
  gen `rndid1' = uniform() if `idtag'
  egen `rndid' = min(`rndid1'), by(`id')
  
  tempvar idnum 
  egen `idnum' = group(`rndid')
  lab var `idnum' "Subject ID"
  if `nsub' > 0 {
    keep if `idnum' <= `nsub'
  }

  if "`plot'" ~= "" {
    local idnum = "`id'"
  }

  if `case' == 0 | `case' == 2 {
    tempfile workdat longdat
    sa `workdat'
    
    forv i = 1/`nvars' {
      use `workdat', clear
      local varlab`i' : variable label `x`i''
      if "`varlab`i''" == "" {
        local varlab`i' = "`x`i''"
      }
      
      keep `idnum' `x`i'' `birth'
      rename `x`i'' `evdate'
      gen `obstype' = `i'
      if `i' > 1 {
        append using `longdat'
      }
      sa `longdat', replace
    }
  }
  
  if `case' == 1 {
    rename `x1' `evdate'
    rename `evtype' `obstype'
    levelsof `obstype', local(obstypes)
    local nvars = 0
    foreach i of local obstypes {
      local varlab`i' :  label (`obstype') `i'
      local nvars = `nvars' + 1
    }
    keep `idnum' `evdate' `obstype' `birth'
  }

  if "`birth'" == "" {
    forv i = 1/`nvars' {
      tempvar y`i'
      gen `y`i'' = `idnum' if `obstype' == `i'
      la var `y`i'' "`varlab`i''"
      local yvars = "`yvars' `y`i''"
      local ytit = "Subject ID"
    }
    tempvar tmpdat tmpy
    gen `tmpy' = `idnum'
    bys `idnum' (`evdate'): gen `tmpdat' = d(`start') if _n == 1
    bys `idnum' (`evdate'): replace `tmpdat' = d(`end') if _n == _N
  }
  else {
    forv i = 1/`nvars' {
      tempvar y`i'
      gen `y`i'' = (`evdate' - `birth') / `agescale' if `obstype' == `i'
      la var `y`i'' "`varlab`i''"
      local yvars = "`yvars' `y`i''"
      local ytit = "Age"
    }
    tempvar tmpdat tmpy
    bys `idnum' (`evdate'): gen `tmpy' = (max(d(`start'), `birth') - `birth') / `agescale' if _n == 1
    bys `idnum' (`evdate'): replace `tmpy' = (d(`end') - `birth') / `agescale' if _n == _N
    bys `idnum' (`evdate'): gen `tmpdat' = max(d(`start'), `birth') if _n == 1
    bys `idnum' (`evdate'): replace `tmpdat' = d(`end') if _n == _N
  }
  
  if "`msymbol'" == "" & "`msize'" == "" {
    forv i = 1/`nvars' {
      local msymbs = "`msymbs' o"
      local msz = "`msz' 1"
    }
  }
  else {
    local msymbs = "`msymbol'"
  }
  
  format %d `tmpdat'
  la var `tmpy' "Subjects"
  sort `idnum' ``evdate''
  
  twoway (scatter `tmpy' `tmpdat', c(L) m(i) lc(gs14) lw(.1) ) (scatter `yvars' `evdate', msymbol(`msymbs') msize(`msz') ytitle(`ytit') xtitle("Time") `options')
  
}
end

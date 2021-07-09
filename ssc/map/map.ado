capture: program drop map
program define map
  syntax varlist using/ [if/] [in/], Values(string) [GENerate(name)]

  version 16

  capture: confirm file `using'
  if (_rc == 601){
    display as error "file `using' not found in the current directory"
    exit
  }

  if ("`generate'" != "") local newVar `generate'
  else local newVar `values'
  capture: confirm new variable `newVar'
  if (_rc == 110){
    display as error "variable `newVar' already defined"
    exit
  }

  quietly: frame
  local originalFrame `r(currentframe)'

  tempname tempFrame
  tempvar tempLink
  tempvar tempVar

  frame create `tempFrame'
  frame `tempFrame'{

    local file = substr("`using'",-4,.)
    if inlist("`file'",".csv",".dta"){
      if ("`file'" == ".csv") import delimited `using', varnames(1) enc("utf-8")
      if ("`file'" == ".dta") use `using'
    }
    else{
      display "`file'"
      display as error "mapping datasets must be in a .csv and .dta file format"
      exit
    }

    foreach var in `varlist'{
      frame `originalFrame': confirm variable `var'
      if (_rc == 111){
        display as error "variable `var' not found in mapping dataset"
        exit
      }
      confirm variable `var'
      if (_rc == 111){
        display as error "variable `var' not found in mapping dataset"
        exit
      }
      frame `originalFrame': local varO: type `var'
      local varU: type `var'
      if (substr("`varO'",1,3) != substr("`varU'",1,3)){
        display as error "variable `var' is stored as {bf:`varU'} in the matching dataset"
        display as error "original variable is {bf:`varO'}"
        exit
      }
    }

    capture: confirm `values'
    if (_rc == 111){
      display as error "variable `values' not found in the mapping dataset"
      exit
    }
  }

  capture: frlink m:1 `varlist', frame(`tempFrame') generate(`tempLink')
  if (_rc == 459){
    display as error "mapping dataset contains multiple observations with the same key"
    exit
  }
  quietly: frget `tempVar'=`values', from(`tempLink')

  local N: word count `varlist'
  local lastVar: word `N' of `varlist'

  quietly: clonevar `newVar' = `tempVar' `if' `in'
  quietly: order `newVar', after(`lastVar')
end

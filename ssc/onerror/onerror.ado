capture: program drop onerror
program define onerror
  syntax anything(name=expression id=expression equalok), ///
  [Display(string) Error(integer -1)]

  version 14

  * Parsing the local -anything-
  capture{
    tokenize `"`expression'"', parse(" ")
    local type `1'
    macro shift
    local evaluation `*'
  }

  * Error checking
  if !inlist("`type'","confirm","assert","display","exp"){
    noisily: display as error "onerror supports " "{bf:confirm}, {bf:assert}, or {bf:display} commands, or {bf:exp}"
    exit
  }

  if inlist("`type'","display","exp") & (`error' != -1){
    noisily: display as error "option {bf:error} only allowed with {bf:confirm} or {bf:assert}"
    exit
  }

  if (`error' == -1) local theError "_rc != 0"
  else local theError "_rc == `error'"

  if ("`display'" == "") local tell "program interrupted"
  else local tell `display'

  * Program
  if inlist("`type'","confirm","assert","display"){
    capture: `type' `evaluation'
    if(`theError'){
      noisily: display as error "`tell'"
      exit
    }
  }
  if("`type'" == "exp"){
    if(`evaluation'){
      noisily: display as error "`tell'"
      exit
    }
  }
end

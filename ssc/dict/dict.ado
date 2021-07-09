*******************************************************************************
* dict.ado
* version 2.0

* author: Daniel Alves Fernandes
* contact: daniel.fernandes@eui.eu
*******************************************************************************

capture: program drop dict

capture: program drop dict_functions
capture: program drop dict_define
capture: program drop dict_list
capture: program drop dict_count
capture: program drop dict_getindex
capture: program drop dict_getvalues

capture: program drop dict_loop
capture: program drop dict_parse_prefix

program define dict
  version 16

  capture: _on_colon_parse `0'
  if (_rc == 0) dict_loop `0'
  else{
    dict_functions `1' `2'
    if ("`r(frame)'" == "new") dict_`r(function)' `0'
    else    frame `r(dframe)': dict_`r(function)' `0'

  }
end

program define dict_functions, rclass
  syntax namelist(id="function and frame name" min=2 max=2), *

  tokenize `namelist'
  if inlist("`1'","define"){
    return local frame "new"
    return local function `1'
  }
  else if inlist("`1'","list","count","getindex","getvalues"){
    return local dframe `2'
    return local function `1'
  }
  else{
    noisily: display as error "function {bf:`1'} not available"
    exit 198
  }
end

program define dict_define
  syntax namelist(min=2 max=2), [From(string) Cols(namelist) replace]
  tokenize `namelist'

  local opts = 0
  if ("`from'" != "") local ++opts
  if ("`cols'" != "") local ++opts

  if (`opts' == 0){
    noisily: display as error ///
    "either option {bf:from()} or {bf:cols()} is required"
    exit 198
  }
  else if (`opts' > 1){
    noisily: display as error ///
    "options {bf:from()} and {bf:cols()} may not be combined"
    exit 184
  }

  if ("`from'" != ""){
    confirm file "`from'"
    if      (substr("`from'",-4,.) == ".csv") local type csv
    else if (substr("`from'",-4,.) == ".dta") local type dta
    else{
      noisily: display as error ///
      "{bf:dict define} only supports .csv or .dta files"
    }
  }

  quietly: frame
  if ("`r(currentframe)'" == "`2'"){
    noisily: display as error ///
    "specified frame cannot be the same as the active frame"
    exit 198
  }
  if ("`replace'" == "replace") capture: frame drop `2'
  confirm new frame `2'

  frame create `2'
  frame `2'{
    if ("`from'" != ""){
      if ("`type'" == "csv") qui: import delim "`from'", varn(1) case(preserve)
      if ("`type'" == "dta") qui: use "`from'"
    }
    else if ("`cols'" != ""){
      noisily: input strL(`cols')
      quietly: compress
    }
  }
end

program define dict_list
  syntax namelist(min=2 max=2) [if] [in], [Cols(namelist)]
  tokenize `namelist'

  confirm frame `2'
  frame `2'{
    noisily: list `cols' `if' `in', clean compress
  }
end

program define dict_count, rclass
  syntax namelist(min=2 max=2)
  tokenize `namelist'

  confirm frame `2'
  frame `2'{
    quietly: count
  }
  noisily: display as text `r(N)'
  return scalar N = `r(N)'
end

program define dict_getindex, rclass
  syntax namelist(min=2 max=2) [if] [in], [Match(string)]
  tokenize `namelist'

  if !inlist("`match'","","first","last","unique","all"){
    noisily: display as error "option {bf:match} incorrectly specified"
    exit 198
  }

  confirm frame `2'
  frame `2'{
    tempvar obs
    gen `obs' = _n
    quietly: levelsof `obs' `if' `in', local(list) clean
  }

  if (`r(N)' == 0){
    noisily display as text ///
    "no observations in {bf:`2'} match the specified criteria"
    exit
  }

  if inlist("`match'","","unique"){
    if (`r(N)' == 1){
      noisily: display as text `r(levels)'
      return scalar i = `r(levels)'
    }
    else{
      noisily display as text ///
      "more than one observation in {bf:`2'} match the specified criteria"
      exit
    }
  }
  else if ("`match'" == "first"){
    tokenize `list'
    noisily: display as text `1'
    return scalar i = `1'
  }
  else if ("`match'" == "last"){
    local last: list sizeof list
    tokenize `list'
    noisily: display as text ``last''
    return scalar i = ``last''
  }
  else if ("`match'" == "all"){
    noisily: display as text "`r(levels)'"
    return local i `r(levels)'
  }
end

program define dict_getvalues, rclass
  syntax namelist(min=2 max=2) [if] [in], [Match(string)]
  tokenize `namelist'

  if !inlist("`match'","","first","last","unique"){
    noisily: display as error "option {bf:match} incorrectly specified"
    exit 198
  }

  confirm frame `2'
  frame `2'{
    tempvar obs
    gen `obs' = _n
    quietly: levelsof `obs' `if' `in', local(list) clean
  }

  if (`r(N)' == 0){
    noisily display as text ///
    "no observations in {bf:`2'} match the specified criteria"
    exit
  }

  if inlist("`match'","","unique"){
    if (`r(N)' == 1) local i = `r(levels)'
    else{
      noisily display as text ///
      "more than one observation in {bf:`2'} match the specified criteria"
      exit
    }
  }
  else if ("`match'" == "first"){
    tokenize `list'
    local i = `1'
  }
  else if ("`match'" == "last"){
    local last: list sizeof list
    tokenize `list'
    local i = ``last''
  }

  frame `2'{
    drop `obs'
    foreach var of varlist _all{
      local value: display `var'[`i']
      return local `var' `"`value'"'
    }
  }
end

program define dict_parse_prefix, rclass
  syntax name(name=dframe id="frame"), [arg(string) Index(integer 0) code]

  confirm frame `dframe'
  quietly: frame
  local mframe: display "`r(currentframe)'"
  if ("`dframe'" == "`mframe'"){
    noisily: display as error ///
    "{bf:dict} cannot run when the dictionary list is in the active frame"
    exit 198
  }

  if (strlen("`arg'") == 0) local arg %
  if !inlist("`arg'","%","@","#","§"){
    n: display as error "available characters in option arg: % @ # §"
    exit 197
  }

  quietly frame `dframe': count
  capture: assert (`index' >= 0) & (`index' <= `r(N)')
  if (_rc == 9){
    n: display as error "passed index value is out of range"
    exit 125
  }

  return local dframe `dframe'
  return local mframe `mframe'
  return local code   `code'
  return local arg    `arg'
  return local index  `index'
end

program define dict_loop
  _on_colon_parse `0'
  local prefix `"`s(before)'"'
  local command `"`s(after)'"'

  dict_parse_prefix `prefix'
  local dframe `r(dframe)'
  local mframe `r(mframe)'
  local code   `r(code)'
  local arg    `r(arg)'
  local index  `r(index)'

  frame `dframe'{
    quietly: ds
    local arguments `r(varlist)'

    capture: assert `"`command'"' != subinstr(`"`command'"',"`arg'","",.)
    if (_rc == 9){
      noisily: display as text ///
      "the command does not contain any arguments. dict ignored."
      noisily: `dB' frame `current_frame': `command'
      exit
    }

    local cmd_parse: display `"`command'"'
    local cmd_args
    local cmd_match = 1
    while (`cmd_match' == 1){
      if regexm(`"`cmd_parse'"',"`arg'[a-zA-Z0-9_]*"){
        local cmd_args: display "`cmd_args' " regexs(0)
      }
      local cmd_parse: ///
      display regexr(`"`cmd_parse'"',"`arg'[a-zA-Z0-9_]*","")
      local cmd_match = regexm(`"`cmd_parse'"',"`arg'[a-zA-Z0-9_]*")
    }
    local cmd_args: display subinstr("`cmd_args'","`arg'","",.)
    capture: confirm variable `cmd_args', exact
    if (_rc == 111){
      noisily: display as error "some arguments not found in dictionary"
      exit 111
    }

    if (`index' == 0){
      forvalues i = 1/`=_N'{
        local cmd `"`command'"'
        foreach a in `arguments'{
          local val: display `a'[`i']
          local cmd: display subinstr(`"`cmd'"',"`arg'`a'",`"`val'"',.)
        }
        if ("`code'" == "code") noisily: display as input strtrim(`"`cmd'"')
        noisily frame `mframe': `cmd'
      }
    }
    else{
      local cmd `"`command'"'
      foreach a in `arguments'{
        local val: display `a'[`index']
        local cmd: display subinstr(`"`cmd'"',"`arg'`a'",`"`val'"',.)
      }
      if ("`code'" == "code") noisily: display as input strtrim(`"`cmd'"')
      noisily frame `mframe': `cmd'
    }
  }
end

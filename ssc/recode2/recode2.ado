*! Version 1.1,  4Jun2000

* John Hendrickx <J.Hendrickx@mailbox.kun.nl>
* Nijmegen Business School, University of Nijmegen, The Netherlands

* Version 1.0, 26Apr2000
* Version 1.1, 4Jun2000, varlist using was not properly expanded

program define recode2
  version 6
  * front end for "recode"
  * allows a varlist, an into varlist, parentheses in rules
  * compatible with SPSS recode syntax

  * Syntax: recode2 varlist [:] rules [> newvarlist]

  * translate "to"s in varlist(s)
  local cmd: subinstr local 0 " to " "-", all

  * get the varlist
  * if a colon is present, use it as the delimiter,
  * otherwise if an opening parentheses is present, use that
  * otherwise, use the first word as varname
  gettoken vlist dothis : cmd, parse(":")
  if "`dothis'" == "" {
    gettoken vlist dothis : cmd, parse("(")
    if "`dothis'" == "" {
      gettoken vlist dothis : cmd
    }
  }
  else {
    * if a colon was used as the delimiter, 
    * do a seconde gettoken to get rid of it
    gettoken colon dothis : dothis, parse(":")
  }

  * change "into" to ">" 
  local dothis: subinstr local dothis " into "   ">", all
  * get the newvarlist, if present
  gettoken dothis newvars : dothis, parse(">")
  if "`newvars'" ~= "" {
    gettoken gt newvars : newvars, parse(">")
    * unabreviate the newvars
    unabnew `newvars'
    local nvlist "`s(nvlist)'"
    sreturn clear
  }

  * translate SPSS keywords into Stata equivalents
  local dothis: subinstr local dothis "lo"       "min"     ,all
  local dothis: subinstr local dothis "lowest"   "min"     ,all
  local dothis: subinstr local dothis "hi"       "max"     ,all
  local dothis: subinstr local dothis "highest"  "max"     ,all
  local dothis: subinstr local dothis "else"     "*"       ,all
  local dothis: subinstr local dothis "missing"  "."       ,all
  local dothis: subinstr local dothis "sysmis"   "."       ,all
  local dothis: subinstr local dothis " thru "   "/"       ,all
  local dothis: subinstr local dothis ","        " "       ,all
  local dothis: subinstr local dothis "("        " "       ,all
  local dothis: subinstr local dothis ")"        " "       ,all

  unab vlist : `vlist'
  * loop through the varlist and do the recode
  tokenize "`vlist'"
  while "`1'" ~= "" {
    if "`newvars'" ~= "" {
      gettoken curvar nvlist : nvlist
      if "`curvar'" == "" {
        display in red "Error: not enough variables to recode into"
        exit
      }
      display "gen `curvar'=`1'"
      gen `curvar'=`1'
    }
    else {
      local curvar "`1'"
    }
    display "recode `curvar' `dothis'"
    recode `curvar' `dothis'
    macro shift
  }
end

program define unabnew, sclass
  version 6
  * "unab" for a newvarlist
  syntax newvarlist
  sreturn local nvlist "`varlist'"
end

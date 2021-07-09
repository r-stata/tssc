*! version 1.0 P.MILLAR 18Mar2005
*! This software can be used for non-commercial purposes only. 
*! The copyright is retained by the developer.
*! Copyright 2005 Paul Millar
program define matsort, rclass
version 7.0
args matname sortcol dir rankonly
/* --------------------------- */
/* This program sorts a matrix */
/* --------------------------- */
 
capture matrix list `matname'
if _rc != 0 {
  di as error "`matname' is not a matrix"
  exit 198
  }

/* set default values */
if "`dir'" == "" {
  local dir = "u"
  }
if "`sortcol'" == "" {
  local sortcol=1
  }
if "`rankonly'" == "" {
  local rankonly="replace"
  }

tempname A

local dir=substr("`dir'",1,1)
if "`dir'" == "d" {
  local down=1
  }
else if "`dir'" == "u" {
  local down=0
  }
else {
  di as error "Sort direction must be either up (for ascending) or down (for descending)"
  exit 198
  }

if "`rankonly'" == "replace" {
  local replace=1
  }
else if "`rankonly'" == "rankonly" {
  local replace=0
  }
else {
  di as error "Replace option must be either replace or rankonly: `rankonly'"
  exit 198
  }

matrix `A' = `matname'

local nrows = rowsof(`A')
local ncols = colsof(`A')
if `sortcol' > `ncols' | `sortcol' < 1 {
  di as error "Invalid column number specified: `sortcol'"
  exit 198
  }

// di "About to sort matrix `matname', sortcol=`sortcol', dir=`dir', nrows=`nrows', ncols=`ncols'"

local names : rownames `A' 
tokenize `names'

/* initialize */
matrix rank = J(`nrows',1,0)
matrix order = J(`nrows',1,0)
forvalues i=1/`nrows' {
  matrix order[`i',1]=`i'
  }

/* ----------- */
/* now we sort */
/* ----------- */
forvalues i=1/`nrows' {
// di "matrix element `i', value=" `A'[`i',`sortcol']
  local max=  -2147483647
  local min=   2147483620
  local highest=0
  forvalues j=`i'/`nrows' {
    local curval=`A'[`j',`sortcol']
    if (`down'==1 & `max' < `curval') | (`down'==0 & `min' > `curval')  {
      local highest = `j'
      local max = `curval'
      local min = `curval'
      }
    }
// di "found the best value=" %7.6f `A'[`highest',`sortcol'] ", at " %3.0f `i' ", switching with " %3.0f `highest' " and ``i'' with ``highest''"
  local saver=order[`i',1]
  matrix order[`i',1]=order[`highest',1]
  matrix order[`highest',1]=`saver' 
  forvalues k=1/`ncols' {
    local saver=`A'[`i',`k']
    matrix `A'[`i',`k']=`A'[`highest',`k']
    matrix `A'[`highest',`k']=`saver'
    }
  }

forvalues i=1/`nrows' {
  local j=order[`i',1]
  matrix rank[`j',1]=`i'
  }

local rn1=" "
local nrn=1
forvalues i=1/`nrows' {
  local row=order[`i',1]
  local lstr=length("`rn`nrn''")+length(" ``row''")
  if `lstr' > 80 {
    local nrn=`nrn'+1
    local rn`nrn'=" "
    }
  local rn`nrn'="`rn`nrn''" + " ``row''"
// di "`i':`row'"
// di "rn`nrn'=`rn`nrn''"
  }

mat rownames `A'=`rn1' `rn2' `rn3' `rn4' `rn5' `rn6' `rn7' `rn8' `rn9' `rn10' `rn11' `rn12' `rn13' `rn14' `rn15' `rn16' `rn17' `rn18' `rn19' `rn20'  `rn21' `rn22' `rn23' `rn24' `rn25' `rn26' `rn27' `rn28' `rn29' `rn30'  `rn31' `rn32' `rn33' `rn34' `rn35' `rn36' `rn37' `rn38' `rn39' `rn40' `rn41' `rn42' `rn43' `rn44' `rn45' `rn46' `rn47' `rn48' `rn49' `rn50' 
if `replace' == 1 {
  mat `matname'=`A'
  }
mat drop `A'
return matrix rank = rank
return matrix order = order
 
end

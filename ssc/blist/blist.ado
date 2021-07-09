*! Date        : 29 July 2005
*! Version     : 1.42
*! Authors     : Adrian Mander
*! Email       : adrian.mander@mrc-hnr.cam.ac.uk
*! Description : Listing values of variables

prog def blist, byable(recall)
version 9.0
syntax [varlist] [if]
preserve

marksample touse, novarlist

qui count if `touse'
if `r(N)'==0 {
   di as text "No Observations"
   exit(2000)
}

/*
  _wlist will list the variables and return the remainder varlist in the macro.. 
 hence keep looping until you run out of variables
*/

di
_wlist `varlist' if `touse'
while "`r(varlist)'"~="" {
  _wlist `r(varlist)' if `touse'
}

restore

end


prog def _wlist, rclass
syntax [varlist] [if]

marksample touse2, novarlist

/* Find the maximum number of display columns.. take away 5 */

local maxcol:set linesize
local maxcol = `maxcol'-5

/* 
Set up the text for each line 

Maxlength 0
# vars 1
Create variables containing the text.
*/

local maxlen 0
local nvar 1
foreach var of varlist `varlist' {
  tempvar sv`nvar' temp
  
  cap confirm numeric variable `var'
  if _rc==0 {
    qui gen `sv`nvar'' = trim(string(`var')) if `touse2'
    qui replace `sv`nvar''= cond(index(`sv`nvar'',".")~=0,substr(`sv`nvar'',1,index(`sv`nvar'',"."))+substr(`sv`nvar'',index(`sv`nvar'',".")+1,3), `sv`nvar'') if `touse2'
  }
  else qui gen `sv`nvar'' = `var' if `touse2'
  
  qui compress `sv`nvar''
  qui gen `temp' = length(`sv`nvar'') if `touse2'
  qui summ `temp' if `touse2'
  local s`nvar' = r(max)
  local len = length("`var'")
  if `len'>`maxlen' local maxlen = `len' 
  local `nvar++'
}

local novars = `nvar'-1


local lastvar 0
forvalues i = `maxlen'(-1)1 {
  local column 1
  local nvar 1
  local line ""
  local nomore 0
  foreach var of varlist `varlist' {
    
    if `nomore'==0 {
      local midpt = `column'+int(`s`nvar''/2)+2
      local column = `column'+`s`nvar''+2

      if length("`var'")>= `i' {
        local entry = substr("`var'",length("`var'")-`i'+1,1)
        if `column'<`maxcol'  local line "`line'{col `midpt'}{input:`entry'}"
      }
    }
    if `column'>=`maxcol' {
      if `nomore'==0 local lastvar = `nvar'-1 
      local nomore 1
    }
    
    if `i'==`maxlen' & `column'>=`maxcol'   local whatsleft "`whatsleft' `var'"
    
    local nvar=`nvar'+1
  }
  di in smcl "`line'"
  
  if `lastvar'==0  local lastvar = `nvar'-1 
  
/* DO TOP of boxes */
  
  if `i'==1 {
    local column2 = `s1'+1
    local line "{text:{c TLC}}{dup `column2':{text:{c -}}}"
    local line2 "{text:{c BLC}}{dup `column2':{text:{c -}}}"
    local nvar 1
    local column 1
    foreach var of varlist `varlist' {
      local nxvar = `nvar'+1
      local column = `column'+`s`nvar''+2
      if `nvar'~=`lastvar'  local column2 = `s`nxvar''+1 
      else  local column2 0 
      if `nvar'==1 {
        if `nvar'<`lastvar' {
          local line "`line'{col `column'}{text:{c TT}}{dup `column2':{text:{c -}}}"
          local line2 "`line2'{col `column'}{text:{c BT}}{dup `column2':{text:{c -}}}"
        }
        else {
          local line "`line'{col `column'}{text:{c TRC}}"
          local line2 "`line2'{col `column'}{text:{c BRC}}"
        }
      }
      else {
          if `nvar'<`lastvar' {
            local line "`line'{col `column'}{text:{c TT}}{dup `column2':{text:{c -}}}"
            local line2 "`line2'{col `column'}{text:{c BT}}{dup `column2':{text:{c -}}}"
          }
          if `nvar'==`lastvar' {
            local line "`line'{col `column'}{text:{c TRC}}"
            local line2 "`line2'{col `column'}{text:{c BRC}}"
          }
      }
      local nvar = `nvar'+1
    }
    di in smcl "`line'"
  }
}


return local varlist "`whatsleft'"

/* This is the set of commands to display each line.. */

local nlines = _N
forvalues i=1/`nlines' {
  local nvar 1

  if `touse2'[`i']==0 continue  /* I think this is the only place that needs an if.. */

  foreach var of varlist `varlist' {
    
    if `nvar'<=`lastvar' {
      
      if `nvar'==1 {
        local line ""
        local column 3
      }
      local entry = `sv`nvar''[`i']
      if `nvar'<=`lastvar' {
        if `nvar'~=`lastvar' local line "`line'{text:{c |}}{col `column'}{result:{ralign `s`nvar'':`entry'}}"
        else  local line "`line'{text:{c |}}{col `column'}{result:{ralign `s`nvar'':`entry'}}{text:{c |}}"  
      }
    
      local column = `column'+`s`nvar''+2
      local nvar=`nvar'+1
    }
    
  }
  di in smcl "`line'"
}

di in smcl "`line2'"

end

*! Date        : 10 Aug 2005
*! Version     : 1.06
*! Authors     : Adrian Mander
*! Email       : adrian.mander@mrc-hnr.cam.ac.uk
*! Description : convert columns of your stata data into the right format for bugs!!

*! example   bugsdat moth chi extra, dim(8,2) 

program define bugsdat
version 9.0
preserve
syntax [varlist] [if] [, File(string) Dim(string) Name(string) DATA(string asis) DATA2(string asis) ]

if "`if'"~="" qui keep `if'

cap log close
if "`file'"~="" qui log using "`file'",text replace
else  qui log using bugs.dat, replace text

if "`dim'"~="" local xtra "= structure(.Data"
else local xtra ""


local linesize `c(linesize)'

local nvar 1
di as text ""
local nxline "list(`data'"
di `"`nxline'"'
local nxline "`data2'"
foreach var of local varlist {

  if "`name'"~="" local navar:word `nvar' of `name'
  else local navar "`var'"
  if "`navar'"=="" local navar "`var'"

  cap confirm string variable `var'
  if _rc~=0 local comp "."
  else local comp `" "" "'

  /* For the first variable you don't need a comma before the variable name */ 
  if `nvar++'==1 {
    if length(`"`nxline'`navar'`xtra'=c("')<=`c(linesize)'  local nxline `"`nxline'`navar'`xtra'=c("'
    else {
      di `"`nxline'"'
      local nxline `"`navar'`xtra'=c("'
    }
  }
  else {
    if length(`"`nxline',`navar'`xtra'=c("')<=`c(linesize)' local nxline `"`nxline',`navar'`xtra'=c("'
    else {
      di `"`nxline'"'
      local nxline `",`navar'`xtra'=c("'
    }
  }

  /* loop through the lines of the variable and print values */
  forv i=1/`=_N'{
    if `i'==1 {				/* the first entry doesn't need commas */
       if `var'[`i']==`comp'  {
         if length(`"`nxline'NA"')<=`c(linesize)' local nxline `"`nxline'NA"'
         else {
           di `"`nxline'"'
           local nxline `"NA"'
         }
       }
       else {
         local temp = `var'[`i']
         if length(`"`nxline'`temp'"')<=`c(linesize)' local nxline `"`nxline'`temp'"'
         else {
           di `"`nxline'"'
           local nxline `"`temp'"'
         }
       }
    }
    else {
      if `var'[`i']==`comp' {
        if length(`"`nxline',NA"')<=`c(linesize)' local nxline `"`nxline',NA"'
         else {
           di `"`nxline'"'
           local nxline `",NA"'
         }
      }
      else {
        local temp =`var'[`i']
        if length(`"`nxline',`temp'"')<=`c(linesize)' local nxline `"`nxline',`temp'"'
        else {
          di `"`nxline'"'
          local nxline `",`temp'"'
        }
      }
    }
  }

  if length(`"`nxline')"')<=`c(linesize)' local nxline `"`nxline')"'
  else { 
    di `"`nxline'"'
    local nxline ")"
  }
  if "`dim'"~="" {
    if length(`"`nxline',.Dim=c(`dim'))"')<=`c(linesize)' local nxline `"`nxline',.Dim=c(`dim'))"'
    else {
      di `"`nxline'"'
      local nxline `",.Dim=c(`dim'))"'
    }
  }
}

if length(`"`nxline')"')<=`c(linesize)' di `"`nxline')"'
else { 
 di `"`nxline'"'
 di ")"
}

qui log close
restore
end

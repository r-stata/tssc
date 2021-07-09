*! Date        : 3 April 2006
*! Version     : 1.03
*! Authors     : Adrian Mander
*! Email       : adrian.mander@mrc-hnr.cam.ac.uk
*! Description : Finding modes

pr mmodes
version 9.1
preserve
syntax [varlist]

foreach var of local varlist {
  cap confirm numeric v `var'
  if _rc==0 local newvlist "`newvlist' `var'"
  else di as error "WARNING: `var' excluded from table because it is a string variable"
}

tempvar temp
qui gen `temp' =.

/* figure out the string length of the variable names */
local len 0
foreach var of local newvlist {
  if length("`var'")>`len' local len=length("`var'")  
}
if `len'>8 local adj = `len'-8
else local adj 0

di as text in smcl "{c TLC}{dup `=10+`adj'':{c -}}{c TT}{dup 10:{c -}}{c TT}{dup 23:{c -}}{c TRC}"
di as text in smcl "{c |} Varname  {col `=12+`adj''}{c |}  Mode(s) {c |} Freq         ( %)     {c |}"
di as text in smcl "{c LT}{dup `=10+`adj'':{c -}}{c +}{dup 10:{c -}}{c +}{dup 23:{c -}}{c RT}"

local first 1
foreach var of local newvlist {
  if `first++'~=1 di as text in smcl "{c LT}{dup `=10+`adj'':{c -}}{c +}{dup 10:{c -}}{c +}{dup 23:{c -}}{c RT}"
  qui sort `var'
  qui by `var': replace `temp' =_N
  qui su `temp'  
  local modefreq : di %8.0g `r(max)'
  local modeperc : di %6.2f `r(max)'*100/_N

  sort `temp' `var'
  tempvar howmanymodes
  qui by `temp' `var': gen `howmanymodes' = cond(_n==1 & `temp'==`modefreq',1,0)
  qui count if `howmanymodes'==1
  local modenumber = `r(N)'
  qui replace `howmanymodes'=sum(`howmanymodes')
  forv i=1/`modenumber' {
    qui su `var' if `howmanymodes'==`i'
    local mode: di %8.5g `r(mean)'
    if `i'==1 di as text in smcl "{c |}" as res " `var' " as text "{col `=12+`adj''}{c |}" as res " `mode' " as text "{c |}" as res " `modefreq' `fre' " as text "{col `=30+`adj''}(" as res " `modeperc'% " as text ") {col `=45+`adj''}{c |}"
    else      di as text in smcl "{c |}" as res "       " as text "{col `=12+`adj''}{c |}" as res " `mode' " as text "{c |}" as res " `modefreq' `fre' " as text "{col `=30+`adj''}(" as res " `modeperc'% " as text ") {col `=45+`adj''}{c |}"
  }
}
di as text in smcl "{c BLC}{dup `=10+`adj'':{c -}}{c BT}{dup 10:{c -}}{c BT}{dup 23:{c -}}{c BRC}"


restore
end

*! version 1.0.0 TJS 9jun2000
program define nct2inv, rclass
  version 6.0
  args p delta df

di
if "`p'" == "" { 
  di in gr "Syntax for " in wh "nct2inv " in gr "is: " _n
  di in wh "  nct2inv " in gr "p delta df" _n
  di in gr "    where " in wh "p     " _c 
  di in gr "is the desired total probability in the tails"
  di in wh "          delta " in gr "is the noncentrality parameter"
  di in wh "          df    " in gr "is the degrees of freedom" _n
  di in wh "  nct2inv " in gr "computes " in wh "t'" _c 
  di in gr " such that P(|t| <= " in wh "t'" in gr " | " in wh "delta" _c
  di in gr ", " in wh "df" in gr ") = 1 - " in wh "p"
  di in gr "          and returns the value in result " _c 
  di in wh "r(t) " in gr "and global " in wh "S_1" in gr "." 
  global S_1 = .
  return scalar t = .
  exit 9
  }

if `p' < 0 | `p' > .5 {
  di in re "p must be between 0 and .5"
  global S_1 = .
  return scalar t = .
  exit 498
  }

if `df' != int(`df') | `df' < 1 {
  di in re "degrees of freedom must be a positive integer"
  global S_1 = .
  return scalar t = .
  exit 498
  }

capture which nct2
if _rc == 111 {
  di in re "nct2inv requires installation of helper program nct2."
  di in wh "  (nct2 is included with the distribution files " _c
  di in wh "for nct2inv"
  di in wh "   or can be obtained by contacting T. J. Steichen " _c
  di in wh "at steicht@rjrt.com)."
  global S_1 = .
  return scalar t = .
  exit 111
  }
capture which ridder
if _rc == 111 {
  di in re "nct2inv requires installation of program ridder."
  di in wh "  (see STB-24, insert ssi5.4 for ridder)."
  global S_1 = .
  return scalar t = .
  exit 111
  }
capture which nctprob
if _rc == 111 {
  di in re "nct2inv requires installation of program nctprob."
  di in wh "  (contact T. J. Steichen at steicht@rjrt.com for nctprob)."
  global S_1 = .
  return scalar t = .
  exit 111
  }

local min = `delta'
local max = `delta' + 100 / sqrt(`df')

cap ridder nct2 X `delta' `df' returns macro S_1 = `p' /* 
  */ from `min' to `max'
if _rc == 430 {
  local min = $S_1 - 1
  local max = $S_1 + 1
  qui ridder nct2 X `delta' `df' returns macro S_1 = `p' /* 
    */from `min' to `max'
  }
if _rc == 409 {
  di in re "internal error in guessing range: solution not bounded."
  di in wh "   (please report this error to T. J. Steichen at "
  di in wh "    steicht@rjrt.com, along with command attempted)."
  global S_1 = .
  return scalar t = .
  exit 409
  }
if _rc == 198 {
  di in re "nct2inv requires version 3.0.5 or later of integ."
  di in wh "   (use " in ye "which integ " _c
  di in wh "to check version number)."
  global S_1 = .
  return scalar t = .
  exit 198
  }

global S_1 = abs($S_1)
return scalar t = $S_1

di _n in gr "  |t'| ="  in ye %10.6f $S_1

di _n in gr "  P(|t| <= " in ye $S_1 in gr " | delta = " _c
di    in gr `delta' ", df = " `df' ") = 1 - " `p'


end

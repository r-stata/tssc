*! version 1.0.0 TJS 9jun2000
program define nctncp, rclass
  version 6.0

  args t p df

if "`p'" == "" { 
  di in gr "Syntax for " in wh "nctncp" in gr " is:" _n
  di in wh "  nctncp " in gr "t' p df" _n
  di in gr "    where " in wh "t' " in gr "is the observed t"
  di in wh "          p  " in gr "is the probability"
  di in wh "          df " in gr "is the degrees of freedom" _n
  di in wh "  nctncp " in gr "computes " in wh "delta" _c
  di in gr " such that P(t<=" in wh "t'" in gr "| " in wh "delta" _c
  di in gr ", " in wh "df" in gr ") = " in wh "p"
  di in gr "          and returns the value in result " _c 
  di in wh "r(delta) " in gr "and global " in wh "S_1" in gr "." 
  global S_1 = .
  return scalar delta = .
  exit 9
  }

if `p' < 0 | `p' > 1 {
  di in re "p must be between 0 and 1"
  global S_1 = .
  return scalar delta = .
  exit 498
  }

if `df' != int(`df') | `df' < 1 {
  di in re "degrees of freedom must be a positive integer"
  global S_1 = .
  return scalar delta = .
  exit 498
  }

capture which ridder
if _rc == 111 {
  di in re "nctncp requires installation of program ridder."
  di in wh "  (see STB-24, insert ssi5.4 for ridder)."
  global S_1 = .
  return scalar delta = .
  exit 111
  }
capture which nctprob
if _rc == 111 {
  di in re "nctncp requires installation of program nctprob."
  di in wh "  (contact T. J. Steichen at steicht@rjrt.com for nctprob)."
  global S_1 = .
  return scalar delta = .
  exit 111
  }

local min = `t' - 100 / (`df'^.44)
local max = `t' + 100 / (`df'^.44)
if `p' > 0.5 { local max = `t' }
else { local min = `t' }

cap ridder nctprob `t' X `df' returns macro S_1 = `p' /*
   */ from `min' to `max'
if _rc == 430 {
  local min = $S_1 - 1
  local max = $S_1 + 1
  qui ridder nctprob `t' X `df' returns macro S_1 = `p' /* 
   */ from `min' to `max'
  }
if _rc == 409 {
  di in re "internal error in guessing range: solution not bounded."
  di in wh "   (please report this error to T. J. Steichen at "
  di in wh "    steicht@rjrt.com, along with command attempted)."
  global S_1 = .
  return scalar delta = .
  exit 409
  }
if _rc == 198 {
  di in re "nctncp requires version 3.0.5 or later of integ."
  di in wh "   (use " in ye "which integ " _c
  di in wh "to check version number)."
  global S_1 = .
  return scalar delta = .
  exit 198
  }

return scalar delta = $S_1

di _n in gr "  delta =" in ye %10.6f $S_1

di _n in gr "  P(t <= " `t' " | delta = " _c
di    in ye $S_1 in gr ", df = " `df' _c
di    in gr ") = " `p'

end

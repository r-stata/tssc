*! version 1.0.0 TJS 9jun2000
program define ncfncp, rclass
  version 6.0

  args F p v1 v2

if "`p'" == "" { 
  di
  di in gr "Syntax for " in wh "ncfncp" in gr " is:" _n
  di in wh "  ncfncp " in gr "F' p v1 v2" _n
  di in gr "    where " in wh "F' " in gr "is the observed F"
  di in wh "          p  " in gr "is the probability"
  di in wh "          v1 " in gr "is the numerator degrees of freedom" 
  di in wh "          v2 " in gr "is the denominator degrees of freedom" _n
  di in wh "  ncfncp " in gr "computes " in wh "lambda" _c
  di in gr " such that P(F <= " in wh "F'" in gr " | " in wh "lambda" _c
  di in gr ", " in wh "v1" in gr ", " in wh "v2" in gr ") = " in wh "p"
  di in gr "          and returns the value in result " _c 
  di in wh "r(lambda) " in gr "and global " in wh "S_1" in gr "." 
  global S_1 = .
  return scalar lambda = .
  exit 9
  }

if `p' < 0 | `p' > 1 {
  di in re "p must be between 0 and 1"
  global S_1 = .
  return scalar lambda = .
  exit 498
  }

if `v1' <= 0 | `v2' < 0 {
  di in re "degrees of freedom must be positive"
  global S_1 = .
  return scalar lambda = .
  exit 498
  }

capture which ridder
if _rc == 111 {
  di in re "ncfncp requires installation of program ridder."
  di in wh "  (see STB-24, insert ssi5.4 for ridder)."
  global S_1 = .
  return scalar lambda = .
  exit 111
  }
capture which ncfprob
if _rc == 111 {
  di in re "ncfncp requires installation of program ncfprob."
  di in wh "  (contact T. J. Steichen at steicht@rjrt.com for ncfprob)."
  global S_1 = .
  return scalar lambda = .
  exit 111
  }

local min = max(`F' - 100, 0)
local max = `F' + 100
if `p' > 0.5 { local max = `F' }
else { local min = `F' }

cap ridder ncfprob `F' X `v1' `v2' returns macro S_1 = `p' /*
   */ from `min' to `max'
if _rc == 430 {
  local min = $S_1 - 1
  local max = $S_1 + 1
  qui ridder ncfprob `F' X `v1' `v2' returns macro S_1 = `p' /* 
   */ from `min' to `max'
  }
if _rc == 409 {
  di in re "internal error in guessing range: solution not bounded."
  di in wh "   (please report this error to T. J. Steichen at "
  di in wh "    steicht@rjrt.com, along with command attempted)."
  global S_1 = .
  return scalar lambda = .
  exit 409
  }

return scalar lambda = $S_1

di _n in gr "  lambda =" in ye %10.6f $S_1

di _n in gr "  P( F <= " `F' " | lambda = " _c
di    in ye $S_1 in gr ", v1 = " `v1' _c
di    in gr ", v2 = " `v2' " ) = " `p'

end

*! version 1.0.0 TJS 9jun2000
program define ncfinv, rclass
  version 6.0

  args p lambda v1 v2

if "`p'" == "" {
  di 
  di in gr "Syntax for " in wh "ncfinv" _c
  di in gr ", the inverse cumulative non-central F distribution, is:" _n
  di in wh "  ncfinv " in gr "p lambda v1 v2" _n
  di in gr "    where " in wh "p " in gr "     is the probability"
  di in wh "          lambda " in gr "is the noncentrality parameter"
  di in wh "          v1 " in gr "    is the numerator degrees of freedom" 
  di in wh "          v2 " in gr "    is the denominator degrees of freedom" _n
  di in wh "  ncfinv " in gr "computes " in wh "F'" in gr " such that" _c
  di in gr " P(F <= " in wh "F'" in gr " | " in wh "lambda" in gr ", " _c
  di in wh "v1" in gr ", " in wh "v2" in gr ") = " in wh "p"
  di in gr "          and returns the value in result " _c 
  di in wh "r(F) " in gr "and global " in wh "S_1" in gr "." 
  global S_1 = .
  return scalar F = .
  exit 9
  }

if `p' < 0 | `p' > 1 {
  di in re "p must be between 0 and 1"
  global S_1 = .
  return scalar F = .
  exit 498
  }

if `v1' <= 0 | `v2' <= 0 {
  di in re "degrees of freedom must be positive"
  global S_1 = .
  return scalar F = .
  exit 498
  }

capture which ridder
if _rc == 111 {
  di in re "ncfinv requires installation of program ridder."
  di in wh "  (see STB-24, insert ssi5.4 for ridder)."
  global S_1 = .
  return scalar F = .
  exit 111
  }
capture which ncfprob
if _rc == 111 {
  di in re "ncfinv requires installation of program ncfprob."
  di in wh "  (contact T. J. Steichen at steicht@rjrt.com for ncfprob)."
  global S_1 = .
  return scalar F = .
  exit 111
  }

local min = max(`lambda' - 100, 0)
local max = `lambda' + 100
if `p' < 0.5 { local max = `lambda' }
else { local min = `lambda' }

cap ridder ncfprob X `lambda' `v1' `v2' returns macro S_1 = `p' /*
   */ from `min' to `max'
if _rc == 430 {
  local min = $S_1 - 1
  local max = $S_1 + 1
  qui ridder ncfprob X `lambda' `v1' `v2' returns macro S_1 = `p' /* 
   */ from `min' to `max'
  }
if _rc == 409 {
  di in re "internal error in guessing range: solution not bounded."
  di in wh "   (please report this error to T. J. Steichen at "
  di in wh "    steicht@rjrt.com, along with command attempted)."
  global S_1 = .
  return scalar F = .
  exit 409
  }

return scalar F = $S_1

di _n in gr "  F' =" in ye %10.6f $S_1

di _n in gr "  P( F <= " in ye $S_1 in gr " | lambda = " _c
di    in wh `lambda' in gr ", v1 = " in wh `v1' _c
di    in gr ", v2 = " in wh `v2' in gr " ) = " in wh `p'

end

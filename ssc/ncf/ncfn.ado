*! version 1.0.0 TJS 9jun2000
program define ncfn, rclass
  version 6.0

  args F lambda p v1 min max

if "`p'" == "" {
  di 
  di in gr "Syntax for " in wh "ncfn" in gr " is:" _n
  di in wh "  ncfn " in gr "F' lambda p v1" _n
  di in gr "    where " in wh "F'    " in gr "is the observed F"
  di in wh "          lambda " in gr "is the noncentrality parameter"
  di in wh "          p  " in gr "    is the probability"
  di in wh "          v1 " in gr "    is the numerator degrees of freedom" _n
  di in wh "  ncfn " in gr "computes " in wh "v2" in gr ", the denominator" _c
  di in gr " degrees of freedom,"
  di in gr "          such that" _c
  di in gr " P(F <= " in wh "F'" in gr " | " in wh "lambda" in gr "," _c
  di in wh " v1" in gr ", " in wh "v2" in gr ") = " in wh "p"
  di in gr "          and returns the value in result" _c 
  di in wh " r(v2) " in gr "and global " in wh "S_1" in gr "." 
  global S_1 = .
  return scalar v2 = .
  exit 9
  }

if `p' < 0 | `p' > 1 {
  di in re "p must be between 0 and 1"
  global S_1 = .
  return scalar v2 = .
  exit 498
  }

if `v1' <= 0 {
  di in re "numerator degrees of freedom must be positive"
  global S_1 = .
  return scalar v2 = .
  exit 498
  }

if `F' <= 0 {
  di in re "observed F' must be positive"
  global S_1 = .
  return scalar v2 = .
  exit 498
  }

capture which ridder
if _rc == 111 {
  di in re "ncfn requires installation of program ridder."
  di in wh "  (see STB-24, insert ssi5.4 for ridder)."
  global S_1 = .
  return scalar v2 = .
  exit 111
  }
capture which ncfprob
if _rc == 111 {
  di in re "ncfn requires installation of program ncfprob."
  di in wh "  (contact T. J. Steichen at steicht@rjrt.com for ncfprob)."
  global S_1 = .
  return scalar v2 = .
  exit 111
  }

if "`min'" == "" { local min = 1 }
if "`max'" == "" { local max = 10000 }

qui cap ridder ncfprob `F' `lambda' `v1' X returns macro S_1 = `p' /*
   */ from `min' to `max'
if _rc == 430 {
  local min = max($S_1 - 2, 1)
  local max = $S_1 + 2
  qui ridder ncfprob `F' `lambda' `v1' X returns macro S_1 = `p' /* 
   */ from `min' to `max'
  }
if _rc == 409 {
  di in re "error: calculated v2 > 10,000"
  global S_1 = .
  return scalar v2 = .
  exit 409
  }

return scalar v2 = $S_1

di _n in gr "  v2 =" in ye %10.6f $S_1

di _n in gr "  P( F <= " `F' " | lambda = " _c
di    in gr `lambda' ", v1 = " `v1' _c
di    in gr ", v2 = " in ye $S_1 in gr " ) = " `p'

end

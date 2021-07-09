*! version 1.0.0 TJS 9jun2000
program define nct2, rclass
version 6.0
   args t delta df
   tempname p1 p2 ps

if "`df'" == "" { 
  di in gr "Syntax for " in wh "nct2" in gr " is: " _n
  di in wh "  nct2 " in gr "t' delta df" _n
  di in gr "  where " in wh "t'    " in gr "is the observed t"
  di in wh "        delta " in gr "is the noncentrality parameter"
  di in wh "        df    " in gr "is the degrees of freedom" _n
  di in wh "  nct2 " in gr "computes " in wh "p" _c 
  di in gr " such that P(|t|<=" in wh "t'" in gr "| " in wh "delta" _c
  di in gr ", " in wh "df" in gr ") = 1 - " in wh "p"
  di in gr "          and returns the value in result " _c 
  di in wh "r(p) " in gr "and global " in wh "S_1" in gr "." 

  global S_1 = .
  return scalar p = .
  exit 9
  }

capture which nctprob
if _rc == 111 {
   di in re "nct2 requires installation of program nctprob."
   di in wh "  (contact T. J. Steichen at steicht@rjrt.com for nctprob)."
   global S_1 = .
   return scalar p = .
   exit 111
   }

qui nctprob `t' `delta' `df'
if _rc == 198 {
   di in re "nct2 requires version 3.0.5 or later of integ."
   di in wh "   (use " in ye "which integ " _c
   di in wh "to check version number)."
   global S_1 = .
   return scalar p = .
   exit 198
   }
scalar `p2' = 1 - $S_1

local t = -`t' 
qui nctprob `t' `delta' `df'
scalar `p1' = $S_1

scalar `ps' = `p2' + `p1'
global S_1 = `ps'
return scalar p = `ps'
local t = -`t'

di _n in gr " P( t  <= " -`t' " | delta = " _c
di    in gr `2' ", df = " `3' ") = " in ye `p1'

di    in gr " P( t  >=  " `t' " | delta = " _c
di    in gr `2' ", df = " `3' ") = " in ye `p2'

di    in gr " P(|t| <=  " `t' " | delta = " _c
di    in gr `2' ", df = " `3' ") = " in ye `ps'

end

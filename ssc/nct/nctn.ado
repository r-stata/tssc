*! version 1.0.0 TJS 9jun2000
program define nctn, rclass
  version 6.0

args t delta p st
if "`st'" != "step" {local star "*"}
if lower("`st'") == "z" { local zstar " "}
else {local zstar "*"}

if "`p'" == "" { 
  di in gr "Syntax for " in wh "nctn" in gr " is:" _n
  di in wh "  nctn " in gr "t' delta p" _n
  di in gr "    where " in wh "t'    " in gr "is the observed t"
  di in wh "          delta " in gr "is the noncentrality parameter"
  di in wh "          p     " in gr "is the probability" _n
  di in wh "  nctn " in gr "computes the minimum " in wh "n" _c
  di in gr " such that, for " in wh "df " in gr "= " in wh "n" _c
  di in gr " - 1, "
  di in gr "    when " in wh "p" in gr " < 0.5," _c
  di in gr "     P(t<=" in wh "t'" in gr "|" in wh "delta" _c
  di in gr ", " in wh "df" in gr ") <= " in wh "p" in gr ", and " 
  di in gr "    when " in wh "p" in gr " > 0.5," _c
  di in gr " 1 - P(t<=" in wh "t'" in gr "|" in wh "delta" _c
  di in gr ", " in wh "df" in gr ") <= " in wh "p" in gr "." _n 
  di in gr "  The minimum " in wh "n" in gr " is returned in result " _c
  di in wh "r(n) " in gr "and global " in wh "S_1" in gr "." 
  global S_1 = .
  return scalar n = .
  exit 9
  }

capture which nctprob
if _rc == 111 {
  di in re "nctn requires installation of program nctprob."
  di in wh "  (contact T. J. Steichen at steicht@rjrt.com for nctprob)."
  global S_1 = .
  return scalar n = .
  exit 111
  }

local z = `t' - `delta'
qui nctprob `t' `delta' 1
local pr = r(p)
local zp = normprob(`z')
`star' di "nctprob(1):" `pr'
`star' di "z(inf):" `zp'
local mn = min(`pr', `zp')
local mx = max(`pr', `zp')
if `mn' > `p' | `mx' < `p' {
  di in re "inconsistent parameters, no solution possible"
  di in bl "note: permissible range for p given t' and delta is " _c
  di in bl %6.4f `mn' " to " %6.4f `mx'
  global S_1 = .
  return scalar n = .
  exit 459 
  } 

`zstar' di in bl "note: if " in wh "p" in bl " = "_c
`zstar' di in ye %6.4f `p' in bl " approaches " _c
`zstar' di in ye %6.4f `zp' in bl " = P(z < " _c
`zstar' di in wh "t'" in bl " - " in wh "delta" in bl "),"
`zstar' di in wh "n " in bl "approaches infinity and " _c
`zstar' di in bl "convergence time increases greatly."
`zstar' global S_1 = .
`zstar' return scalar n = .
`zstar' exit 9     

local sign "<"
local df = 1
local pr = 1
qui nctprob `t' `delta' 1
local pr1 = r(p)
qui nctprob `t' `delta' 2
local pr2 = r(p)
if `pr2' > `pr1' {
  local sign ">"
  local pr = 0
  }

local step = int(abs(`zp' - `pr1') / abs(`zp' - `p'))
local df = `step'

local f 0

while `f' == 0 {
  qui nctprob `t' `delta' `df'
  local pr0 = `pr'
  local pr = r(p)
  `star' di "df: " `df' "  step: " `step' "  p: " `pr'
  if `p' `sign' `pr' { local df = `df' + `step' }
  else { 
    if `step' == 1 & sign((`pr'-`p')/(`pr0'-`p')) < 0 { local f 1 }
    else {
      local step = max(1, int(`step' / 2))
      local df = `df' - `step'
      }
    }
  }

di in gr "for n = " in ye `df' + 1 in gr ", df = " in ye `df' _c
if `pr' < `p' { 
  di in gr " and p = " `pr' _c
  di in gr " <= " `p' "." 
  }
else {
  di in gr " and 1 - p = " 1 - `pr' _c
  di in gr " <= " 1 - `p' " = 1 - " `p' "." 
  }
global S_1 = `df'
return scalar n = `df'

end

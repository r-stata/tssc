*! version 1.0.1 TJS 9jun2000
program define ncfprob, rclass
  version 6.0
  args F lambda v1 v2 extra

if "`F'" == "" { 
  di
  di in gr "ncfprob: the cumulative non-central F " _c
  di in gr "distribution, from zero to F'" _n
  di in gr "Syntax:" _n 
  di in wh "  ncfprob F' lambda v1 v2" _n
  di in gr "  where " in wh "F'     " in gr "is the observed F"
  di in wh "        lambda " in gr "is the noncentrality parameter"
  di in wh "        v1     " in gr "is the numerator degrees of freedom"
  di in wh "        v2     " in gr "is the denominator degrees of freedom" _n
  di in wh "  ncfprob " in gr "computes " in wh "p" _c 
  di in gr " such that P( F <= " in wh "F'" in gr " | " in wh "lambda" _c
  di in gr ", " in wh "v1" in gr ", " in wh "v2" in gr " ) = p"
  di in gr "          and returns the p-value in result " _c 
  di in wh "r(p) " in gr "and global " in wh "S_1" in gr "." 
  global S_1 = .
  return scalar p = .
  exit
  }

if "`extra'" != "" {
  di in re "too many arguments"
  global S_1 = .
  return scalar p = .
  exit 123
  }

if "`v2'" == "" {
  di in re "too few arguments"
  global S_1 = .
  return scalar p = .
  exit 122
  }

if `F' < 0 | `lambda' < 0 {
  if `F' < 0      { di in re "observed F' must be non-negative" }
  if `lambda' < 0 { di in re "noncentrality must be non-negative" }
  global S_1 = .
  return scalar p = .
  exit 125
  }

capture numlist "`v1' `v2'", r(>0) 
if _rc {
  local rc = _rc 
  di in re "degrees of freedom must be positive"
  global S_1 = .
  return scalar p = .
  exit `rc'
  }

tempname sum term
local j = 0
local flag = 1

scalar `sum' = exp(-`lambda') * (1 - fprob(`v1',`v2',`F'))

while `flag' & `lambda' > 0 {
	local j = `j' + 1
	local v = `v1' + 2 * `j'
	scalar `term' = exp(log(`lambda'^`j') +       /*
		*/ log(1 - fprob(`v',`v2',`v1'*`F'/`v')) /*
		*/ - lnfact(`j') - `lambda')
	if `term' < 10^-14 * `sum' { local flag = 0 } 
	if `term' == . { 
		local flag = 0 
		scalar `term' = 0
	} 
	scalar `sum' = `sum' + `term'
}

di _n in gr "  p =" in ye %10.6f `sum'

di _n in gr "  P( F <= " `F' " | lambda = " _c
di    in gr `lambda' ", v1 = " `v1' _c
di    in gr ", v2 = " `v2' " ) = " in ye `sum'

global S_1 = `sum'
return scalar p = `sum'

exit
end

/* ----------------------------------------------------------------

Note: the formula implemented above is: 

let  F'  be the observed F value
     L   be the non-centrality parameter
     V1  be the numerator degrees of freedom
     V2  be the denominator degrees of freedom

and  P(F < F'| a, b)  be the probabilty from the central F distribution 

then
                               inf
  P(F<F'|L,V1,V2) = exp(-L) * SUM  L^j * P(F < F'*V1/v | v, V2) / j!  
                               j=0
  
   	where v = V1 + 2*j   and inf = infinity

   ---------------------------------------------------------------- */


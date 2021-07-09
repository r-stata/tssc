*! version 1.0.1 TJS 9jun2000
program define nctprob, rclass
  version 6.0
  args t delta df extra

if "`df'" == "" | "`extra'" != "" { 
  di in gr "Syntax for " in wh "nctprob" _c
  di in gr ", the cumulative non-central t"
  di in gr "distribution from negative infinity to t', is: " _n
  di in wh "  nctprob " in gr "t' delta df" _n
  di in gr "  where " in wh "t'    " in gr "is the observed t"
  di in wh "        delta " in gr "is the noncentrality parameter"
  di in wh "        df    " in gr "is the degrees of freedom" _n
  di in wh "  nctprob " in gr "computes " in wh "p" _c 
  di in gr " such that P(t<=" in wh "t'" in gr "| " in wh "delta" _c
  di in gr ", " in wh "df" in gr ") = " in wh "p"
  di in gr "          and returns the value in result " _c 
  di in wh "r(p) " in gr "and global " in wh "S_1" in gr "." 
  global S_1 = .
  return scalar p = .
  exit 9
  }

if `df' != int(`df') | `df' < 1 {
  di in re "degrees of freedom must be a positive integer"
  global S_1 = .
  return scalar p = .
  exit 498
  }

local even = mod(`df',2) == 0

/* numerical calculation of C(h,a) requires -preserve- 
   but C(h,a) is only needed for odd df's                      */
if !`even' { preserve }

tempname A B h a p C M0 M1 M2 ak Mo Me k Mk
tempvar x y

scalar `A' = `t' / sqrt(`df')
scalar `B' = `df' / (`df' + (`t')^2)
scalar `h' = `delta' * sqrt(`B')

if `even' { scalar `p' = normprob(-(`delta')) }
else {     
  scalar `p' = normprob(-(`delta' * sqrt(`B')))
  scalar `a' = abs(`A')
  qui range `x' 0 `a' 1001   
  gen `y' = exp(-((`h')^2 / 2) * (1 + (`x')^2)) / (1 + (`x')^2)
  qui integ `y' `x'
  scalar `C' = r(integral)/ (2 * _pi)
  scalar `p' = `p' + 2 * `C' * sign(`A')
  }
if `df' == 1 {
  di _n in gr "  p =" in ye %10.6f `p'
  di _n in gr "  P(t <= " `t' " | delta = " _c
  di    in gr `delta' ", df = " `df' _c
  di    in gr ") = " in ye `p'
  global S_1 = `p'
  return scalar p = `p'
  exit
  }

scalar `M0' = `A' * sqrt(`B') * normd(`delta' * sqrt(`B')) 
scalar `M0' = `M0' * normprob(`delta' * `A' * sqrt(`B'))
if `df' == 2 {
  scalar `p' = `p' + sqrt(2 * _pi) * `M0' 
  di _n in gr "  p =" in ye %10.6f `p'
  di _n in gr "  P(t <= " `t' " | delta = " _c
  di    in gr `delta' ", df = " `df' _c
  di    in gr ") = " in ye `p'
  global S_1 = `p'
  return scalar p = `p'
  exit
  }

scalar `M1' = `A' * normd(`delta') / sqrt(2 * _pi)
scalar `M1' = `B' * (`delta' * `A' * `M0' + `M1')
if `df' == 3 {
  scalar `p' = `p' + 2 * `M1'
  di _n in gr "  p =" in ye %10.6f `p'
  di _n in gr "  P(t <= " `t' " | delta = " _c
  di    in gr `delta' ", df = " `df' _c
  di    in gr ") = " in ye `p'
  global S_1 = `p'
  return scalar p = `p'
  exit
  }

scalar `M2' = `B' * ( `delta' * `A' * `M1' + `M0') / 2
if `df' == 4 {
  scalar `p' = `p' + sqrt(2 * _pi) * (`M0' + `M2')
  di _n in gr "  p =" in ye %10.6f `p'
  di _n in gr "  P(t <= " `t' " | delta = " _c
  di    in gr `delta' ", df = " `df' _c
  di    in gr ") = " in ye `p'
  global S_1 = `p'
  return scalar p = `p'
  exit
  }

* calculate Mk's for k = 3 to `df'-2 and sum odds and evens
scalar `ak' = 1
scalar `Mo' = `M1'
scalar `Me' = `M0' + `M2'
scalar `k' = 3
while `k' <= `df' - 2 {
  scalar `ak' = 1 / ((`k' - 2) * `ak')
  scalar `Mk' = `ak' * `delta' * `A' * `M2' + `M1'
  scalar `Mk' = (`k'-1) * `B' * `Mk' / `k'
  if mod(`k',2) == 0 { scalar `Me' = `Me' + `Mk' }
  else               { scalar `Mo' = `Mo' + `Mk' }
  scalar `M1' = `M2'
  scalar `M2' = `Mk' 
  scalar `k' = `k' + 1
  }
if `even' { scalar `p' = `p' + sqrt(2 * _pi) * `Me' }
else      { scalar `p' = `p' + 2 * `Mo' }

di _n in gr "  p =" in ye %10.6f `p'
di _n in gr "  P(t <= " `t' " | delta = " _c
di    in gr `delta' ", df = " `df' _c
di    in gr ") = " in ye `p'

global S_1 = `p'
return scalar p = `p'

exit
end

/* ------------------------------------------------------------

Note: formula implemented above is from 
      D. B. Owen (Technometrics 10(3):445-478, 1968)


Let
     t be the observed t-value
     d be the non-centrality parameter
     v be the degrees of freedom

     G(z)  be the cumulative standard Normal distribution
     G'(z) be the standard Normal density function

Define

     A = t / sqrt(v)

     B = v / (v + t^2)

then

     M  = 0
      -1

     M  = A * sqrt(B) * G'(d * sqrt(B)) * G(d * A * sqrt(B))
      0
   
     M  = B * [ d * A * M + A * G'(d) / sqrt(2 * pi)]
      1                  0

     M  = B * [ d * A * M + M ]
      2                  0   1

and, for k>= 3,    

     M  = (k - 1) * B * [ a  * d * A * M   + M   ] / k
      k                    k            k-1   k-2
  
     where a  = 1 / [(k - 2) * a   ]     and   a  = 1 
            k                   k-1             2


Finally, for even df's,
 
P{T <= t | d, v} = 
 G(-d) + sqrt(2 * pi) * [M + M + ... + M   ] 
                          0   2         v-2
  
and for odd df's, 

P{T <= t | d, v} = 
 G(-d * sqrt(B)) + 2 * C(d * sqrt(B), A) + 2 * [M + M + ... + M   ]
                                                 1   3         v-2


 where
                               abs(a)
                         1       /   exp[-h^2 / 2 * (1 + x^2)]
     C(h,a) = sign(a) --------   |  --------------------------- dx  
                       2 * pi    /            1 + x^2
                                x=0


Note: integral C(h,a) is computed numerically in this program.
    
------------------------------------------------------------   */


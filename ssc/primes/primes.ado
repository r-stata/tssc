*! prime numbers; by Stas Kolenikov, 02-11-2005
program define primes
  version 9
  syntax anything, CLEAR

  local top=`anything'
  drop _all
  qui {
     set obs `top'
     tempname p kk
     g long prime = _n
     drop in 1
     forvalues k=1/`top' {
        local kk=int(sqrt(`k'))
        forvalues i=1/`kk' {
           * pick a prime number from already filtered list
           scalar `p'=prime[`i']
           if `p'*`p' > `k' {
               * the number in question, `k', is a prime
               continue, break
           }
           if mod(`k',`p')==0 {
              * found a divisor
              drop if prime == `k'
              continue, break
           }
        }
     }
  }

end

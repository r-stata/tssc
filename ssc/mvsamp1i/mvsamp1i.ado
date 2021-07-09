*! version 2.0.0   16 June 2008   DEM

program define mvsamp1i
   version 5.0

   parse "`*'", parse(" ,")
   confirm number `1'
   tempname lambda

   scalar `lambda' = `1'
   mac shift
   local dalpha = 1 - $S_level/100

   local options "Alpha(real `dalpha') Power(real 0.90) NY(int 1) NX(int 1) NC(int 0) N(int 0)" 

   parse "`*'"

   if `alpha'<=0 | `alpha'>=1 {
           di in red "alpha() out of range"
           exit 198
   }

   if `power'<=0 | `power'>=1 {
            di in red "power() out of range"
            exit 198
   }
   if `n'<0 {
           di in red "n() out of range"
           exit 198
   }
   if `ny'<0 {
           di in red "ny() out of range"
           exit 198
   }
   if `nx'<0 {
           di in red "nx() out of range"
           exit 198
   }
   if `nc'<0 {
           di in red "nc() out of range"
           exit 198
   }

   tempname dfn zz s zpower uppern lowern lastn thisn
   scalar `dfn' = `nx' * `ny'
   scalar `zz' = `nx'*`nx' + `ny'*`ny' - 5
   if `zz' > 0 {
      scalar `s' = sqrt( (`dfn'*`dfn' - 4) / `zz' )
   }
   else scalar `s' = 1

   if `n' == 0 {
      scalar `zpower' = `power'
      scalar `uppern' = 100
      scalar `lowern' = 0
      scalar `lastn' = 0
      scalar `thisn' = 100
      local i 0
      while `i' < 100 & `thisn' != `lastn' {
         local i = `i' + 1
         mvpowi `alpha' `lambda' `thisn' `ny' `nx' `nc' `dfn' `s'

         if round(1-$S_3,.0001) == 1-`zpower' {
            scalar `lastn' = `thisn'
            scalar `uppern' = `thisn'
            if `thisn' > `lowern' {
               scalar `thisn' = `thisn' - 1
            }
         }
         else if $S_3 > `zpower' {
               scalar `lastn' = `thisn'
               scalar `uppern' = `thisn'
               scalar `thisn' = `lowern' + int( (`uppern' - `lowern') / 2 )
         }
         else {
              if `thisn' >= `uppern' {
                 scalar `lastn' = `thisn'
                 scalar `uppern' = 10 * `thisn'
                 scalar `lowern' = `lastn'
                 scalar `thisn' = `lowern' + int( (`uppern' - `lowern') / 2 )
              }
              else {
                 scalar `lastn' = `thisn'
                 scalar `lowern' = `lastn'
                 scalar `thisn' = `lowern' + int( (`uppern' - `lowern') / 2 )
              }
         }
      }
   }
   else {
      mvpowi `alpha' `lambda' `n' `ny' `nx' `nc' `dfn' `s'
   }

   display _newline _col(15) "MULTIVARIATE POWER ANALYSIS" _newline
   display _col(3) "N" _dup(29) "." _col(34) $S_1
   display _col(3) "Alpha" _dup(25) "." _col(34) %6.4f $S_2
   local ss = 30 - length("Beta (power)")
   display _col(3) "Power (Beta)" _dup(`ss') "." _col(34) %6.4f $S_3 " (" %6.4f 1-$S_3 ")"
   local ss = 30 - length("Wilks' Lambda")
   display _col(3) "Wilks' Lambda" _dup(`ss') "." _col(34) %6.4f $S_4
   local ss = 30 - length("Effect Size")
   display _col(3) "Effect Size" _dup(`ss') "." _col(34) round($S_5, .0001)
   display _col(3) "F" _dup(29) "." _col(34) %6.4f $S_6
   local ss = 30 - length("Hypothesis df")
   display _col(3) "Hypothesis df" _dup(`ss') "." _col(34) $S_7
   local ss = 30 - length("Error df")
   display _col(3) "Error df" _dup(`ss') "." _col(34) round($S_8, .0001)
   local ss = 30 - length("R-squared")
   display _col(3) "R-squared" _dup(`ss') "." _col(34) %6.4f $S_9
   local ss = 30 - length("Adjusted R-squared")
   display _col(3) "Adjusted R-squared" _dup(`ss') "." _col(34) %6.4f $S_10
   local ss = 30 - length("Noncentrality Parameter")
   display _col(3) "Noncentrality Parameter" _dup(`ss') "." _col(34) round($S_11,.0001)

end

program define mvpowi
   version 5.0
   local alpha `1'
   local lambda `2'
   local n `3'
   local ny `4'
   local nx `5'
   local nc `6'
   local dfn `7'
   local s `8'
   local m = `n' - `nc' - (`ny' + `nx' + 3) / 2
   local dfd = `m' * `s' + 1 - `dfn' / 2
   local effsize = 1 / `lambda'^(1/`s') - 1
   local F = `effsize' * ( `dfd' / `dfn' )
   local r2 = 1 - `lambda'
   local adjr2 = 1 - (1 - `r2') * ( (`dfd'+`dfn') / `dfd' ) ^ `s'
   local noncent = `effsize' * (`dfn' + `dfd' + 1)
   local fcrit = invfprob(`dfn', `dfd', `alpha')
   local __zx = (`dfn' * `fcrit') / `dfd'
   local __zy = (`dfn' + 2*`noncent') / (`dfn' + `noncent')
   local __zbeta = ( sqrt(2*(`dfn'+`noncent') - `__zy') - sqrt((2*`dfd' - 1) * `__zx') ) / sqrt(`__zx' + `__zy')
   global S_1 = `n'
   global S_2 = `alpha'
   global S_3 = normprob(`__zbeta')
   global S_4 = `lambda'
   global S_5 = `effsize'
   global S_6 = `F'
   global S_7 = `dfn'
   global S_8 = `dfd'
   global S_9 = `r2'
   global S_10 = `adjr2'
   global S_11 = `noncent'
end

*! version 1.10 97/02/19; 26/03/2020
program define numodes
version 11.0
*First written: 97/02/19; last revised 01/04/97; 26/03/2020
*Authors: Salgado-Ugarte I.H., M. Shimizu, and T. Taniuchi
*This program calculates the number of modes of a density estimation or
*a frequency distribution and if desired lists their estimated values

local varlist "req ex min(2) max(2)"
local if "opt"
local in "opt"
local options "modes"

parse "`*'"
parse "`varlist'", parse(" ")
quietly {
preserve

tempvar difvar inmo sumo
gen `difvar'=`1'[_n+1] - `1'[_n] `if' `in'
gen `inmo' = 0
replace `inmo'=1 if `difvar'[_n]>=0 & `difvar'[_n+1] < 0
gen `sumo' = sum(`inmo')
local numo= `sumo'[_N]
noi di as text _newline "Number of modes = " as res `numo'

if "`modes'"~="" {
   tempvar modes
   gen `modes'=.
   replace `modes'=`2' if `inmo'[_n-1]==1 
   sort `modes'
   local i = 1
   noi di as text _newline _dup(75) "_"
   local title " Modes in density/frequency estimation"
   noi di as text "`title'"
   noi di as text _dup(75) "-"
   while `i'<`numo'+1 {
      noi di as text " Mode ( " %4.0f as res `i' as text " ) = " %12.4f as res `modes'[`i']
      local i = `i'+1
      }
   noi di as text _dup(75) "_"
   sort `2'
   }
}

end

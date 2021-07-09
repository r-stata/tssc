*! version 1.10 2008/02/14; 26/03/2020; 08/08/2020
program define nuamodes
version 11.0
*First written: 2008/02/14; last revised 2008/02/14; last update 26/03/2020
*Authors: Salgado-Ugarte I.H., M. Shimizu, and T. Taniuchi
*This program calculates the number of antimodes of a density estimation or
*a frequency distribution and if desired lists their estimated values

local varlist "req ex min(2) max(2)"
local if "opt"
local in "opt"
local options "amodes"

parse "`*'"
parse "`varlist'", parse(" ")
quietly {
preserve

tempvar difvar inamo suamo index
gen `difvar'=`1'[_n+1] - `1'[_n] `if' `in'
gen `inamo' = 0
replace `inamo'=1 if `difvar'[_n]<=0 & `difvar'[_n+1] > 0
gen `index' = _n if `1'!=.
sum `1'
local np=r(N)
replace `inamo'=0 if `index'==1
replace `inamo'=0 if `index'==`np'-1
gen `suamo' = sum(`inamo')
local nuamo= `suamo'[_N]
noi di as text _newline "Number of antimodes = " as res `nuamo'

if "`amodes'"~="" {
   tempvar amodes
   gen `amodes'=.
   replace `amodes'=`2' if `inamo'[_n-1]==1 
   sort `amodes'
   local i = 1
   noi di as text _newline _dup(75) "_"
   local title " Antimodes in density/frequency estimation"
   noi di as text "`title'"
   noi di as text _dup(75) "-"
   while `i'<`nuamo'+1 {
     noi di as text " Antimode ( " %4.0f as res `i' as text " ) = " %12.4f as res `amodes'[`i']
     local i = `i'+1
     }
   noi di as text _dup(75) "_"
   sort `2'
   }


}

end

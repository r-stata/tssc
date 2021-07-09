* This program calculates the number of redundant parameters within all fixed effects
* It is based on the algorithm proposed by Abowed et al (2002), and uses the command a2group
* It has been tested to run under stata 12 or greater.
capture program drop nredound
program define nredound, eclass
syntax varlist [if] [in]
marksample touse

local M=0
capture preserve

foreach i in `varlist' {
  qui:compress `i'
  local test: type `i' 
  if "`test'"!="byte" & "`test'"!="int" & "`test'"!="long"  {
     di in red "One of the FE variables is not byte, int or long"
     exit 322
  }
}

_rmcoll `varlist', forcedrop
local varlist2=r(varlist)
local ini=wordcount("`varlist2'")+1

if `ini'>7 {
display "Cannot include more than 7 distinct variables"
exit 198
}

qui:keep if `touse'
qui:keep `varlist2'
tempvar n
qui:bysort `varlist2':gen `n'=_n
qui:keep if `n'==1
qui:drop `n'

local j=0
local vl
foreach i in `varlist2' {
local j=`j'+1
ren `i' v`j'
local vl `vl' v`j'	
}
tuples `vl'

forvalues i=`ini'/`ntuples' {
   di "." _cont
   local X=wordcount("`tuple`i''")
   if `X'==2 {
   local i1:word 1 of `tuple`i''
   local i2:word 2 of `tuple`i''
   tempvar `i1'`i2'
   capture noisily: qui:a2group , individual(`i1') unit(`i2') groupvar(``i1'`i2'')
   qui:distinct ``i1'`i2''
   local M=`M'+r(ndistinct)
   }
   
   if `X'==3 {
   local i1:word 1 of `tuple`i''
   local i2:word 2 of `tuple`i''
   local i3:word 3 of `tuple`i''
   tempvar `i1'`i2'`i3'
   capture noisily: qui:a2group , individual(``i1'`i2'') unit(`i3') groupvar(``i1'`i2'`i3'')
   qui:distinct ``i1'`i2'`i3''
   local M=`M'-r(ndistinct)
   }
 
   if `X'==4 {
   local i1:word 1 of `tuple`i''
   local i2:word 2 of `tuple`i''
   local i3:word 3 of `tuple`i''
   local i4:word 4 of `tuple`i''
   tempvar `i1'`i2'`i3'`i4'
   capture noisily: qui:a2group , individual(``i1'`i2'`i3'') unit(`i4') groupvar(``i1'`i2'`i3'`i4'')
   qui:distinct ``i1'`i2'`i3'`i4''
   local M=`M'+r(ndistinct)
   }
   
   if `X'==5 {
   local i1:word 1 of `tuple`i''
   local i2:word 2 of `tuple`i''
   local i3:word 3 of `tuple`i''
   local i4:word 4 of `tuple`i''
   local i5:word 5 of `tuple`i''
   tempvar `i1'`i2'`i3'`i4'`i5'
   capture noisily: qui:a2group , individual(``i1'`i2'`i3'`i4'') unit(`i5') groupvar(``i1'`i2'`i3'`i4'`i5'')
   qui:distinct ``i1'`i2'`i3'`i4'`i5''
   local M=`M'-r(ndistinct)
   }
   if `X'==6 {
   local i1:word 1 of `tuple`i''
   local i2:word 2 of `tuple`i''
   local i3:word 3 of `tuple`i''
   local i4:word 4 of `tuple`i''
   local i5:word 5 of `tuple`i''
   local i6:word 6 of `tuple`i''
   tempvar `i1'`i2'`i3'`i4'`i5'`i6'
   capture noisily: qui:a2group , individual(``i1'`i2'`i3'`i4'`i5'') unit(`i6') groupvar(``i1'`i2'`i3'`i4'`i5'`i6'')
   qui:distinct ``i1'`i2'`i3'`i4'`i5'`i6''
   local M=`M'+r(ndistinct)
   }
   if `X'==7 {
   local i1:word 1 of `tuple`i''
   local i2:word 2 of `tuple`i''
   local i3:word 3 of `tuple`i''
   local i4:word 4 of `tuple`i''
   local i5:word 5 of `tuple`i''
   local i6:word 6 of `tuple`i''
   local i7:word 7 of `tuple`i''
   tempvar `i1'`i2'`i3'`i4'`i5'`i6'`i7'
   capture noisily: qui:a2group , individual(``i1'`i2'`i3'`i4'`i5'`i6'') unit(`i7') groupvar(``i1'`i2'`i3'`i4'`i5'`i6'`i7'')
   qui:distinct ``i1'`i2'`i3'`i4'`i5'`i6'`i7''
   local M=`M'-r(ndistinct)
   }
}
if _rc==0 {
restore
}
display _newline "Number of redundant parameters: `M'" 
ereturn scalar M=`M'
end



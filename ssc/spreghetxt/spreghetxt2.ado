program define spreghetxt2
version 11.0
args todo b lf
tempvar XB Ys Tm Ys12 Ys22 Con ZB idv itv Time
tempname Sigu Sige
local NC=e(NC)
qui count 
local N = r(N)
local NT=`N'/`NC'
qui cap drop `idv'
qui cap drop `itv'
gen `idv'= ceil(_n/`NT')
gen `itv' = _n-(`idv'-1)*`NT'
qui xtset `idv' `itv'
mleval `XB'  = `b', eq(1)
mleval `ZB'  = `b', eq(2)
mleval `Sigu'= `b', eq(3) scalar
mleval `Sige'= `b', eq(4) scalar
qui gen double `Ys' = $ML_y1 - `XB'
qui by `idv': gen `Tm' = cond(_n==_N,_N,.)
qui by `idv': gen double `Ys12' = cond(_n==_N, sum(`Ys')^2,.)
qui by `idv': gen double `Ys22' = cond(_n==_N, sum(`Ys'^2),.)
qui gen double `Con' = `Sigu'^2/(`Tm'*`Sigu'^2+`Sige'^2)
qui mlsum `lf' = -0.5*((`Ys22'-`Con'*`Ys12')/(`Sige'*exp(`ZB'))^2 + ///
 log(`Tm'*(`Sigu'*exp(`ZB'))^2/(`Sige'*exp(`ZB'))^2+1) ///
 +`Tm'*log(2*_pi*(`Sige'*exp(`ZB'))^2)) if `Tm'~=.
end


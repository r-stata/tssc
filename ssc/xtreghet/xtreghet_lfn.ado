program define xtreghet_lfn
version 11.0
args todo b lnf
tempvar XB Ys Tm Ys12 Ys22 Con idv itv
tempname Sigu Sige idv itv
mata: `idv'= st_matrix("idv")
mata: `itv'= st_matrix("itv")
getmata `idv' , force replace
getmata `itv' , force replace
qui xtset `idv' `itv'
mleval `XB'  = `b', eq(1)
mleval `Sigu'= `b', eq(2) scalar
mleval `Sige'= `b', eq(3) scalar
qui gen double `Ys' = $ML_y1 - `XB'
qui by `idv': gen `Tm' = cond(_n==_N,_N,.)
qui by `idv': gen double `Ys12' = cond(_n==_N, sum(`Ys')^2,.)
qui by `idv': gen double `Ys22' = cond(_n==_N, sum(`Ys'^2),.)
qui gen double `Con' = `Sigu'^2/(`Tm'*`Sigu'^2+`Sige'^2)
qui mlsum `lnf' = -0.5*((`Ys22'-`Con'*`Ys12')/`Sige'^2 + ///
 ln(`Tm'*`Sigu'^2/`Sige'^2+1)+`Tm'*ln(2*_pi*`Sige'^2)) if `Tm'~=.
end


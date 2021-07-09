 program define spregxt34
 version 11.2
 qui {
 args todo b lf
 tempvar XB Ys Tm Ys12 Ys22 Con ZB idv itv
 tempname Sigu Sige
 getmata `idv'=idv , replace force
 getmata `itv'=itv , replace force
 xtset `idv' `itv'
 mleval `XB'  = `b', eq(1)
 mleval `ZB'  = `b', eq(2)
 mleval `Sigu'= `b', eq(3) scalar
 mleval `Sige'= `b', eq(4) scalar
 gen double `Ys' = $ML_y1 - `XB'
 by `idv': gen `Tm' = cond(_n==_N,_N,.)
 by `idv': gen double `Ys12' = cond(_n==_N, sum(`Ys')^2,.)
 by `idv': gen double `Ys22' = cond(_n==_N, sum(`Ys'^2),.)
 gen double `Con' = `Sigu'^2/(`Tm'*`Sigu'^2+`Sige'^2)
 mlsum `lf' = -0.5*((`Ys22'-`Con'*`Ys12')/(`Sige'*exp(`ZB'))^2 + ///
 log(`Tm'*(`Sigu'*exp(`ZB'))^2/(`Sige'*exp(`ZB'))^2+1) ///
 +`Tm'*log(2*_pi*(`Sige'*exp(`ZB'))^2)) if `Tm'~=.
 }
 end


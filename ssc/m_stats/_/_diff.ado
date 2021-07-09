/* _diff - Evaluates the difference between the ECDFs of two interpoint distance distributions in two subsamples using equiprobable binning
Pietro Tebaldi , Harvard School of Public Health and Bocconi University
July 2010 */

program define _diff , rclass
version 10.1
syntax  , x(varname) y(varname) g(varname) [bins(integer 20)]
tempvar X1 Y1 X2 Y2
tempname d F1 F2 difF
quietly {
// separate the two samples and store them
gen `X1' = `x' if `g'==0
gen `Y1' = `y' if `g'==0
gen `X2' = `x' if `g'==1
gen `Y2' = `y' if `g'==1
preserve
// binning using the pooled sample
dbins `y' `x' , bins(`bins') 
mat `d' = r(d)
clear
restore
preserve
// ECDF for the interpoint distances within sample 1 only
drop if `X1' == .
Fhat `X1' `Y1' , d(`d')
mat `F1' = r(Fhat)
restore
preserve
// ECDF for the interpoint distances within sample 2 only
drop if `X2' == .
Fhat `X2' `Y2' , d(`d')
mat `F2' = r(Fhat)
mat `difF' = `F1'-`F2' // difference between the two ECDFs
// return results and restore the dataset
return matrix d = `d'
return matrix Fhat1 = `F1'
return matrix Fhat2 = `F2'
return matrix difF = `difF'
restore
count if `X1' != .
return scalar N1 = r(N)
count if `X2' != .
return scalar N2 = r(N)
count
return scalar N = r(N)
}
end

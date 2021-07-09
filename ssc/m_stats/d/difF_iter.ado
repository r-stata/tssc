/* difF_iter - Returns the difference between the ECDFs of two interpoint distance distributions in two subsamples at the cutoffs d
NOT TO BE USED INTERACTIVELY - AUXILIARY FUNCTION TO Mtest COMMAND (Monte Carlo permutations)
Pietro Tebaldi , Harvard School of Public Health and Bocconi University
July 2010 */

program define difF_iter , rclass
version 10.1
syntax , x(varname) y(varname) g(varname) d(namelist)
tempvar X1 Y1 X2 Y2
tempname F1 F2 difF
quietly {
// separate the two samples and store them
gen `X1' = `x' if `g'==0
gen `Y1' = `y' if `g'==0
gen `X2' = `x' if `g'==1
gen `Y2' = `y' if `g'==1
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
// return result and restore the dataset
return matrix difF = `difF'
restore
}
end

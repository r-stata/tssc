/* Mst_iter - returns the observed two-sample M statistic 
NOT TO BE USED INTERACTIVELY - AUXILIARY FUNCTION TO Mtest COMMAND (Monte Carlo permutations)
Pietro Tebaldi , Harvard School of Public Health and Bocconi University
July 2010 */

program define Mst_iter , rclass // do not use to compute M - only in the Monte Carlo permutation
version 10.1
syntax , x(varname) y(varname) g(varname) sinv(namelist) d(namelist)
tempname dF M
difF_iter , x(`x') y(`y') g(`g') d(`d')
matrix `dF' = r(difF)
matrix `M' = (`dF')'*(`sinv')*`dF'
return scalar M = `M'[1,1]
end

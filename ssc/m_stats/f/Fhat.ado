/* Fhat - Evaluates the ECDF of the interpoint distance distribution for a given dataset of coordinates at a given set of cutoff points

Pietro Tebaldi , Harvard School of Public Health and Bocconi University
July 2010 */

program define Fhat , rclass
version 10.1
syntax varlist(min=2 max=2)  , d(namelist)
tempname N ld F
capture count
local N = r(N)
eucldist `varlist'
local ld = rowsof(`d')
mat `F' = J(`ld',1,.) 
forvalues i = 1/`ld' {
capture count if TotDist <= `d'[`i',1]
mat `F'[`i',1] = r(N)/comb(`N',2)
}
return matrix Fhat = `F'
clear
end
